import Foundation
import CoreMIDI

/// Main MIDI controller class that manages virtual MIDI destination and input handling
class MIDIController {

    // MARK: - Properties

    private var midiClient: MIDIClientRef = 0
    private var virtualDestination: MIDIEndpointRef = 0
    private var inputPort: MIDIPortRef = 0
    private var selectedInputDeviceID: MIDIUniqueID = 0

    var isActive: Bool = false
    var statusCallback: ((String) -> Void)?

    // MARK: - Initialization

    init() {
        setupMIDIClient()
    }

    deinit {
        cleanup()
    }

    // MARK: - Setup

    private func setupMIDIClient() {
        var status: OSStatus

        // Create MIDI client
        status = MIDIClientCreate("GatedMuteController" as CFString, nil, nil, &midiClient)
        guard status == noErr else {
            print("Error creating MIDI client: \(status)")
            return
        }

        // Create virtual destination
        status = MIDIDestinationCreateWithBlock(
            midiClient,
            "Gated Mute Controller" as CFString,
            &virtualDestination
        ) { [weak self] (packetList, _) in
            // Virtual destination receives messages from Logic
            // We don't need to process these (Logic sends us feedback)
        }

        guard status == noErr else {
            print("Error creating virtual destination: \(status)")
            return
        }

        // Create input port for receiving from KeyLab
        status = MIDIInputPortCreateWithProtocol(
            midiClient,
            "Input" as CFString,
            .midi_1_0,
            &inputPort
        ) { [weak self] (eventList, _) in
            self?.handleMIDIEvents(eventList)
        }

        guard status == noErr else {
            print("Error creating input port: \(status)")
            return
        }

        statusCallback?("MIDI Client initialized successfully")
    }

    // MARK: - Device Selection

    func getAvailableInputDevices() -> [(name: String, id: MIDIUniqueID)] {
        var devices: [(name: String, id: MIDIUniqueID)] = []
        let sourceCount = MIDIGetNumberOfSources()

        for i in 0..<sourceCount {
            let source = MIDIGetSource(i)
            var name: Unmanaged<CFString>?
            var uniqueID: Int32 = 0

            MIDIObjectGetStringProperty(source, kMIDIPropertyName, &name)
            MIDIObjectGetIntegerProperty(source, kMIDIPropertyUniqueID, &uniqueID)

            if let deviceName = name?.takeRetainedValue() as String? {
                devices.append((name: deviceName, id: MIDIUniqueID(uniqueID)))
            }
        }

        return devices
    }

    func selectInputDevice(withID uniqueID: MIDIUniqueID) {
        // Disconnect from previous device
        if selectedInputDeviceID != 0 {
            disconnectFromDevice(withID: selectedInputDeviceID)
        }

        // Find and connect to new device
        let sourceCount = MIDIGetNumberOfSources()
        for i in 0..<sourceCount {
            let source = MIDIGetSource(i)
            var deviceID: Int32 = 0
            MIDIObjectGetIntegerProperty(source, kMIDIPropertyUniqueID, &deviceID)

            if MIDIUniqueID(deviceID) == uniqueID {
                let status = MIDIPortConnectSource(inputPort, source, nil)
                if status == noErr {
                    selectedInputDeviceID = uniqueID
                    isActive = true
                    statusCallback?("Connected to input device")
                } else {
                    statusCallback?("Error connecting to device: \(status)")
                }
                return
            }
        }
    }

    private func disconnectFromDevice(withID uniqueID: MIDIUniqueID) {
        let sourceCount = MIDIGetNumberOfSources()
        for i in 0..<sourceCount {
            let source = MIDIGetSource(i)
            var deviceID: Int32 = 0
            MIDIObjectGetIntegerProperty(source, kMIDIPropertyUniqueID, &deviceID)

            if MIDIUniqueID(deviceID) == uniqueID {
                MIDIPortDisconnectSource(inputPort, source)
                break
            }
        }
    }

    // MARK: - MIDI Event Handling

    private func handleMIDIEvents(_ eventList: UnsafePointer<MIDIEventList>) {
        let packet = MIDIEventListPointer(eventList)

        for event in packet {
            // Parse MIDI event
            guard let words = event.words else { continue }

            let statusByte = UInt8((words.0 >> 16) & 0xFF)
            let data1 = UInt8((words.0 >> 8) & 0xFF)
            let data2 = UInt8(words.0 & 0xFF)

            let messageType = statusByte & 0xF0
            let channel = statusByte & 0x0F

            // Only process messages on Channel 16 (0x0F in zero-indexed)
            guard channel == 0x0F else { continue }

            // Process Note On/Off messages
            if messageType == 0x90 { // Note On
                if data2 > 0 {
                    handleNoteOn(note: data1)
                } else {
                    handleNoteOff(note: data1)
                }
            } else if messageType == 0x80 { // Note Off
                handleNoteOff(note: data1)
            }
        }
    }

    private func handleNoteOn(note: UInt8) {
        // Map KeyLab note to Mackie Control command
        if let mackieCommand = mapNoteToMackieControl(note: note) {
            sendMackieControlToggle(note: mackieCommand.note, type: mackieCommand.type)
        }
    }

    private func handleNoteOff(note: UInt8) {
        // On key release, send another toggle to return to original state (gated behavior)
        if let mackieCommand = mapNoteToMackieControl(note: note) {
            sendMackieControlToggle(note: mackieCommand.note, type: mackieCommand.type)
        }
    }

    // MARK: - Note Mapping

    private func mapNoteToMackieControl(note: UInt8) -> (note: UInt8, type: String)? {
        // Mute mappings: C1 (36) to B1 (47) -> Tracks 1-12
        if note >= 36 && note <= 47 {
            let track = note - 36
            if track < 8 {
                // Tracks 1-8: Direct Mackie Control mute notes (16-23)
                return (note: 16 + track, type: "mute")
            } else {
                // Tracks 9-12: Need bank switching or extended protocol
                // For now, we'll use a workaround with higher note numbers
                // This may require testing with Logic Pro X
                return (note: 24 + (track - 8), type: "mute")
            }
        }

        // Solo mappings: C2 (48) to B2 (59) -> Tracks 1-12
        if note >= 48 && note <= 59 {
            let track = note - 48
            if track < 8 {
                // Tracks 1-8: Direct Mackie Control solo notes (8-15)
                return (note: 8 + track, type: "solo")
            } else {
                // Tracks 9-12: Extended mapping
                return (note: 16 + (track - 8), type: "solo")
            }
        }

        return nil
    }

    // MARK: - Mackie Control Communication

    private func sendMackieControlToggle(note: UInt8, type: String) {
        // Send Note On (127) followed by Note Off (0) to simulate button press
        sendMackieControlNote(note: note, velocity: 127)

        // Small delay to ensure Logic processes the messages separately
        usleep(5000) // 5ms delay

        sendMackieControlNote(note: note, velocity: 0)
    }

    private func sendMackieControlNote(note: UInt8, velocity: UInt8) {
        guard virtualDestination != 0 else { return }

        // Mackie Control uses Channel 1 (0x00 in zero-indexed)
        let statusByte: UInt8 = 0x90 // Note On on Channel 1

        var packetList = MIDIPacketList()
        var packet = MIDIPacketListInit(&packetList)

        let midiData: [UInt8] = [statusByte, note, velocity]
        packet = MIDIPacketListAdd(
            &packetList,
            1024,
            packet,
            0,
            midiData.count,
            midiData
        )

        // Send to all destinations that are connected to our virtual destination
        // Logic Pro X will receive this through the virtual MIDI port
        let destCount = MIDIGetNumberOfDestinations()
        for i in 0..<destCount {
            let dest = MIDIGetDestination(i)
            var name: Unmanaged<CFString>?
            MIDIObjectGetStringProperty(dest, kMIDIPropertyName, &name)

            // Send to all Logic-related destinations
            if let destName = name?.takeRetainedValue() as String?,
               destName.contains("Logic") || destName.contains("IAC") {
                MIDISend(inputPort, dest, &packetList)
            }
        }
    }

    // MARK: - Cleanup

    private func cleanup() {
        if inputPort != 0 {
            MIDIPortDispose(inputPort)
        }
        if virtualDestination != 0 {
            MIDIEndpointDispose(virtualDestination)
        }
        if midiClient != 0 {
            MIDIClientDispose(midiClient)
        }
    }
}
