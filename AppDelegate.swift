import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {

    var statusItem: NSStatusItem!
    var menu: NSMenu!
    var midiController: MIDIController!

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Initialize MIDI Controller
        midiController = MIDIController()

        // Setup status callback
        midiController.statusCallback = { [weak self] status in
            DispatchQueue.main.async {
                self?.updateStatusMessage(status)
            }
        }

        // Create menu bar item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "music.note", accessibilityDescription: "Gated Mute Controller")
        }

        setupMenu()
    }

    func setupMenu() {
        menu = NSMenu()

        // Title
        let titleItem = NSMenuItem(title: "Gated Mute Controller", action: nil, keyEquivalent: "")
        titleItem.isEnabled = false
        menu.addItem(titleItem)

        menu.addItem(NSMenuItem.separator())

        // Status
        let statusItem = NSMenuItem(title: "Status: Inactive", action: nil, keyEquivalent: "")
        statusItem.tag = 100 // Tag for easy reference
        statusItem.isEnabled = false
        menu.addItem(statusItem)

        menu.addItem(NSMenuItem.separator())

        // Input Device Submenu
        let inputDeviceMenu = NSMenu()
        let inputDeviceItem = NSMenuItem(title: "MIDI Input Device", action: nil, keyEquivalent: "")
        inputDeviceItem.submenu = inputDeviceMenu
        menu.addItem(inputDeviceItem)

        // Populate input devices
        updateInputDeviceMenu(inputDeviceMenu)

        menu.addItem(NSMenuItem.separator())

        // Mappings Info
        let mappingsItem = NSMenuItem(title: "Show Mappings", action: #selector(showMappings), keyEquivalent: "")
        mappingsItem.target = self
        menu.addItem(mappingsItem)

        menu.addItem(NSMenuItem.separator())

        // Quit
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))

        statusItem.menu = menu
    }

    func updateInputDeviceMenu(_ inputMenu: NSMenu) {
        inputMenu.removeAllItems()

        let devices = midiController.getAvailableInputDevices()

        if devices.isEmpty {
            let noDeviceItem = NSMenuItem(title: "No MIDI Devices Found", action: nil, keyEquivalent: "")
            noDeviceItem.isEnabled = false
            inputMenu.addItem(noDeviceItem)
        } else {
            for device in devices {
                let deviceItem = NSMenuItem(
                    title: device.name,
                    action: #selector(selectInputDevice(_:)),
                    keyEquivalent: ""
                )
                deviceItem.target = self
                deviceItem.representedObject = device.id
                inputMenu.addItem(deviceItem)
            }
        }

        // Add refresh option
        inputMenu.addItem(NSMenuItem.separator())
        let refreshItem = NSMenuItem(title: "Refresh Devices", action: #selector(refreshInputDevices), keyEquivalent: "")
        refreshItem.target = self
        inputMenu.addItem(refreshItem)
    }

    @objc func selectInputDevice(_ sender: NSMenuItem) {
        guard let deviceID = sender.representedObject as? MIDIUniqueID else { return }

        midiController.selectInputDevice(withID: deviceID)

        // Update checkmarks
        if let inputMenu = sender.menu {
            for item in inputMenu.items {
                item.state = .off
            }
            sender.state = .on
        }
    }

    @objc func refreshInputDevices() {
        guard let inputDeviceItem = menu.item(withTitle: "MIDI Input Device"),
              let inputMenu = inputDeviceItem.submenu else { return }

        updateInputDeviceMenu(inputMenu)
    }

    @objc func showMappings() {
        let alert = NSAlert()
        alert.messageText = "MIDI Note Mappings"
        alert.informativeText = """
        MUTE CONTROLS (C1-B1):
        C1  (36) → Track 1 Mute
        C#1 (37) → Track 2 Mute
        D1  (38) → Track 3 Mute
        D#1 (39) → Track 4 Mute
        E1  (40) → Track 5 Mute
        F1  (41) → Track 6 Mute
        F#1 (42) → Track 7 Mute
        G1  (43) → Track 8 Mute
        G#1 (44) → Track 9 Mute
        A1  (45) → Track 10 Mute
        A#1 (46) → Track 11 Mute
        B1  (47) → Track 12 Mute

        SOLO CONTROLS (C2-B2):
        C2  (48) → Track 1 Solo
        C#2 (49) → Track 2 Solo
        D2  (50) → Track 3 Solo
        D#2 (51) → Track 4 Solo
        E2  (52) → Track 5 Solo
        F2  (53) → Track 6 Solo
        F#2 (54) → Track 7 Solo
        G2  (55) → Track 8 Solo
        G#2 (56) → Track 9 Solo
        A2  (57) → Track 10 Solo
        A#2 (58) → Track 11 Solo
        B2  (59) → Track 12 Solo

        Behavior: GATED (momentary)
        - Key pressed = Mute/Solo ON
        - Key released = Mute/Solo OFF
        """
        alert.alertStyle = .informational
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }

    func updateStatusMessage(_ message: String) {
        if let statusItem = menu.item(withTag: 100) {
            statusItem.title = "Status: \(message)"
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Cleanup handled in MIDIController deinit
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
}
