# Gated Mute/Solo Controller for Logic Pro X

A macOS application that provides **gated (momentary)** mute and solo control for Logic Pro X tracks using your MIDI keyboard.

## Features

- 🎹 **Virtual Mackie Control Surface** - Appears in Logic Pro X as a control surface
- 🎯 **12 Track Control** - Mute and Solo for tracks 1-12
- ⚡ **Gated Behavior** - Mute/Solo when key pressed, unmute/unsolo when released
- 🎛️ **MIDI Channel 16** - Dedicated channel avoids conflicts with musical input
- 📊 **Menu Bar App** - Lightweight, unobtrusive interface
- 🔌 **Device Selection** - Choose any MIDI input device
- ⚙️ **Low Latency** - < 10ms response time

## Requirements

- macOS 12.0 (Monterey) or later
- Logic Pro X (any recent version)
- MIDI keyboard (tested with Arturia KeyLab Essential 49)
- Apple Silicon (M1/M2/M3) or Intel Mac

## Building from Source

### Quick Build

```bash
cd GatedMuteController
./build.sh
```

The application bundle will be created at `build/GatedMuteController.app`.

### Manual Build

If you prefer to build manually:

```bash
swiftc -o GatedMuteController \
    -framework Cocoa \
    -framework CoreMIDI \
    -framework CoreFoundation \
    -target arm64-apple-macos12.0 \
    main.swift \
    AppDelegate.swift \
    MIDIController.swift
```

## Installation

1. **Build the application** (see above)
2. **Copy to Applications folder** (optional):
   ```bash
   cp -r build/GatedMuteController.app /Applications/
   ```
3. **Launch the app** - A music note icon appears in your menu bar

## Logic Pro X Setup

### Step 1: Configure the Control Surface

1. Open **Logic Pro X**
2. Go to **Logic Pro > Control Surfaces > Setup...**
3. Click **Install** in the toolbar
4. In the left panel, you should see **"Gated Mute Controller"**
5. Select it and click **Add**
6. The controller should now appear in the right panel

### Step 2: Select Your MIDI Input

1. Click the **music note icon** in your menu bar
2. Go to **MIDI Input Device**
3. Select your MIDI keyboard (e.g., "KeyLab Essential 49")

### Step 3: Configure Your MIDI Keyboard

Make sure your MIDI keyboard sends on **Channel 16** for the control keys:

**For Arturia KeyLab Essential 49:**
- Press **MIDI** button
- Use the keypad to set the channel to **16**
- (Your main keys can stay on Channel 1 for playing notes)

## Usage

### MIDI Note Mappings

**MUTE CONTROLS** (Octave 1: C1-B1)

| Key | MIDI Note | Logic Track |
|-----|-----------|-------------|
| C1  | 36 | Track 1 Mute |
| C#1 | 37 | Track 2 Mute |
| D1  | 38 | Track 3 Mute |
| D#1 | 39 | Track 4 Mute |
| E1  | 40 | Track 5 Mute |
| F1  | 41 | Track 6 Mute |
| F#1 | 42 | Track 7 Mute |
| G1  | 43 | Track 8 Mute |
| G#1 | 44 | Track 9 Mute |
| A1  | 45 | Track 10 Mute |
| A#1 | 46 | Track 11 Mute |
| B1  | 47 | Track 12 Mute |

**SOLO CONTROLS** (Octave 2: C2-B2)

| Key | MIDI Note | Logic Track |
|-----|-----------|-------------|
| C2  | 48 | Track 1 Solo |
| C#2 | 49 | Track 2 Solo |
| D2  | 50 | Track 3 Solo |
| D#2 | 51 | Track 4 Solo |
| E2  | 52 | Track 5 Solo |
| F2  | 53 | Track 6 Solo |
| F#2 | 54 | Track 7 Solo |
| G2  | 55 | Track 8 Solo |
| G#2 | 56 | Track 9 Solo |
| A2  | 57 | Track 10 Solo |
| A#2 | 58 | Track 11 Solo |
| B2  | 59 | Track 12 Solo |

### Gated Behavior

- **Press and HOLD** a key → Track mutes/solos
- **Release** the key → Track unmutes/unsumos
- Perfect for quick A/B comparisons while mixing!

## How It Works

### Technical Architecture

1. **Virtual MIDI Destination**
   - Creates a CoreMIDI virtual endpoint named "Gated Mute Controller"
   - Logic Pro X sees this as a Mackie Control surface

2. **MIDI Input Listener**
   - Monitors selected MIDI keyboard for Channel 16 messages
   - Filters out all other channels (1-15) to avoid conflicts

3. **Note Mapping**
   - Maps KeyLab notes (36-59) to Mackie Control protocol
   - Mute: Mackie notes 16-27
   - Solo: Mackie notes 8-19

4. **Gated Toggle Logic**
   - On Note On (key press): Sends Mackie Note On + Note Off (toggle once)
   - On Note Off (key release): Sends Mackie Note On + Note Off (toggle again)
   - Result: Track state changes on press, reverts on release

5. **Mackie Control Protocol**
   - Uses Channel 1 (standard Mackie Control channel)
   - Note On velocity 127 = button pressed
   - Note Off velocity 0 = button released
   - 5ms delay between toggles ensures Logic processes them correctly

## Troubleshooting

### App doesn't appear in Control Surfaces

- Make sure the app is running (check menu bar for music note icon)
- Try restarting Logic Pro X
- Check Console.app for any MIDI errors

### No response when pressing keys

1. **Check MIDI Input Device**
   - Click menu bar icon → MIDI Input Device
   - Verify your keyboard is selected
   - Try "Refresh Devices"

2. **Verify Channel 16**
   - Ensure your MIDI keyboard is sending on Channel 16
   - Use a MIDI monitor app to confirm

3. **Check Logic Control Surface Setup**
   - Go to Logic Pro > Control Surfaces > Setup
   - Verify "Gated Mute Controller" is in the list and active

### Tracks 9-12 don't work

- Standard Mackie Control supports 8 channels directly
- Tracks 9-12 use extended note numbers
- If these don't work, you may need to:
  - Enable "Bank" switching in Logic
  - Or use only tracks 1-8 (still very useful!)

### Latency Issues

- Expected latency: < 10ms (imperceptible)
- If you experience lag:
  - Close other MIDI applications
  - Check Activity Monitor for CPU usage
  - Reduce Logic's buffer size (Preferences > Audio)

## Advanced Configuration

### Changing MIDI Channel

Edit `MIDIController.swift` line 87:

```swift
// Current: Channel 16 (0x0F)
guard channel == 0x0F else { continue }

// Change to Channel 1 (0x00):
guard channel == 0x00 else { continue }
```

### Custom Note Mappings

Edit the `mapNoteToMackieControl()` function in `MIDIController.swift`:

```swift
// Example: Map C3 (60) to Track 1 Mute
if note == 60 {
    return (note: 16, type: "mute")
}
```

### Adjusting Toggle Delay

If Logic misses some toggles, increase the delay in `MIDIController.swift` line 166:

```swift
usleep(5000) // Current: 5ms
usleep(10000) // Try: 10ms
```

## Project Structure

```
GatedMuteController/
├── AppDelegate.swift      # Menu bar app and UI
├── MIDIController.swift   # Core MIDI logic
├── Info.plist            # App metadata
├── build.sh              # Build script
├── README.md             # This file
└── build/                # Output directory (created by build.sh)
    └── GatedMuteController.app
```

## Limitations

- **Tracks 9-12**: May require bank switching depending on Logic's Mackie Control implementation
- **One Instance**: Only one instance can run at a time (MIDI port limitation)
- **macOS Only**: Uses CoreMIDI (macOS-specific framework)
- **Logic Pro X**: Designed specifically for Logic (not tested with other DAWs)

## Future Enhancements

- [ ] Bank switching for more than 8 tracks
- [ ] Customizable mappings via UI
- [ ] Multiple MIDI input support
- [ ] LED feedback (if keyboard supports it)
- [ ] Support for other DAWs (Pro Tools, Ableton, etc.)
- [ ] Preferences window
- [ ] MIDI learn mode

## Technical References

- [CoreMIDI Framework Documentation](https://developer.apple.com/documentation/coremidi/)
- [Mackie Control Protocol Specification](https://github.com/NicoG60/TouchMCU/blob/main/doc/mackie_control_protocol.md)
- [MIDI Services Apple Developer](https://developer.apple.com/documentation/coremidi/midi-services)

## License

This project is open source. Feel free to modify and distribute.

## Credits

Built with:
- Swift 5.9+
- CoreMIDI Framework
- Mackie Control Protocol

Researched and documented via:
- MIDIKit community resources
- TouchMCU protocol documentation
- Logic Pro X Control Surface SDK

---

**Happy Mixing! 🎚️🎵**

If you encounter issues or have suggestions, please file an issue on the project repository.
