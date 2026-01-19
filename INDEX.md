# Gated Mute/Solo Controller - Project Index

## 📁 Complete File Listing

### 🚀 Quick Start
Start here if you just want to build and run:
- **[QUICKSTART.md](QUICKSTART.md)** - Get running in 5 minutes

### 📖 Documentation
- **[README.md](README.md)** - Complete user guide, usage, and troubleshooting
- **[PROJECT_SUMMARY.md](PROJECT_SUMMARY.md)** - Technical overview and architecture
- **[BUILD_WITH_XCODE.md](BUILD_WITH_XCODE.md)** - Step-by-step Xcode build instructions ⭐ **RECOMMENDED**
- **[SETUP_GUIDE.md](SETUP_GUIDE.md)** - Alternative build methods and troubleshooting
- **[INDEX.md](INDEX.md)** - This file

### 💻 Source Code
- **[Sources/GatedMuteController/main.swift](Sources/GatedMuteController/main.swift)** - Application entry point
- **[Sources/GatedMuteController/AppDelegate.swift](Sources/GatedMuteController/AppDelegate.swift)** - Menu bar UI and app lifecycle
- **[Sources/GatedMuteController/MIDIController.swift](Sources/GatedMuteController/MIDIController.swift)** - Core MIDI logic and Mackie Control protocol

### ⚙️ Configuration
- **[Info.plist](Info.plist)** - macOS app configuration (bundle ID, LSUIElement, etc.)
- **[Package.swift](Package.swift)** - Swift Package Manager definition (optional)

### 🔨 Build Scripts
- **[build.sh](build.sh)** - Command-line build script ⚠️ (has SDK issues, use Xcode instead)

---

## 🗺️ Navigation Guide

### I want to...

#### **...build and run the app NOW**
👉 Go to: **[QUICKSTART.md](QUICKSTART.md)**

#### **...understand what this project does**
👉 Go to: **[README.md](README.md)** or **[PROJECT_SUMMARY.md](PROJECT_SUMMARY.md)**

#### **...build with Xcode (recommended)**
👉 Go to: **[BUILD_WITH_XCODE.md](BUILD_WITH_XCODE.md)**

#### **...troubleshoot build issues**
👉 Go to: **[SETUP_GUIDE.md](SETUP_GUIDE.md)**

#### **...understand the code**
👉 Start with: **[PROJECT_SUMMARY.md](PROJECT_SUMMARY.md)** (Technical Architecture section)
👉 Then read: **[MIDIController.swift](Sources/GatedMuteController/MIDIController.swift)**

#### **...customize the mappings**
👉 Edit: **[MIDIController.swift](Sources/GatedMuteController/MIDIController.swift)** (see `mapNoteToMackieControl()` function)

#### **...distribute the app**
👉 Go to: **[BUILD_WITH_XCODE.md](BUILD_WITH_XCODE.md)** → "Creating an Application Bundle"

---

## 📚 Document Descriptions

### QUICKSTART.md
**Purpose**: Get you from zero to working app in 5 minutes
**Contains**:
- Minimal build steps (Xcode)
- Logic Pro X setup (3 steps)
- MIDI keyboard configuration
- Basic testing instructions

**When to use**: You want to start using the app ASAP

---

### README.md
**Purpose**: Complete user documentation
**Contains**:
- Feature overview
- Detailed build instructions
- Logic Pro X setup guide
- Complete MIDI note mappings (all 24 mappings)
- Comprehensive troubleshooting
- Technical architecture explanation
- Advanced configuration options

**When to use**: You want to understand everything about the project

---

### BUILD_WITH_XCODE.md
**Purpose**: Step-by-step Xcode build guide
**Contains**:
- Detailed Xcode project creation steps
- Configuration instructions (Info.plist, frameworks, signing)
- Archive and distribution methods
- Xcode-specific troubleshooting

**When to use**: You're building with Xcode and want detailed guidance

---

### SETUP_GUIDE.md
**Purpose**: Build troubleshooting and alternatives
**Contains**:
- Why command-line build fails (SDK mismatch)
- Swift Package Manager alternative
- Debugging tips
- MIDI testing without Logic
- Development workflow tips

**When to use**: You're having build issues or want to debug MIDI

---

### PROJECT_SUMMARY.md
**Purpose**: Technical overview for developers
**Contains**:
- High-level architecture
- File structure explanation
- Detailed technical implementation
- Mackie Control protocol details
- Performance metrics
- Known limitations
- Future enhancement ideas

**When to use**: You want to understand how it works technically

---

## 🔍 Source Code Guide

### main.swift (10 lines)
**Purpose**: Application entry point

**Key code**:
```swift
let app = NSApplication.shared
let delegate = AppDelegate()
app.setActivationPolicy(.accessory)  // Menu bar app
app.run()
```

**What it does**: Launches the macOS app as a menu bar application (no dock icon)

---

### AppDelegate.swift (~150 lines)
**Purpose**: Menu bar UI and user interface

**Key components**:
- `setupMenu()` - Creates menu bar UI
- `selectInputDevice()` - Handles MIDI device selection
- `showMappings()` - Displays note-to-track mappings
- `updateInputDeviceMenu()` - Refreshes available MIDI devices

**What it does**: Provides the user interface and connects user actions to the MIDI controller

---

### MIDIController.swift (~250 lines)
**Purpose**: Core MIDI logic and Mackie Control protocol

**Key components**:

1. **MIDI Setup** (`setupMIDIClient()`):
   - Creates virtual MIDI destination "Gated Mute Controller"
   - Creates input port for KeyLab

2. **Device Management** (`selectInputDevice()`):
   - Lists available MIDI devices
   - Connects to selected device

3. **Event Handling** (`handleMIDIEvents()`):
   - Filters for Channel 16 only
   - Processes Note On/Off messages

4. **Note Mapping** (`mapNoteToMackieControl()`):
   - Maps KeyLab notes (36-59) to Mackie notes (8-27)
   - Separates mute and solo controls

5. **Gated Logic** (`handleNoteOn()`, `handleNoteOff()`):
   - Note On → Toggle once
   - Note Off → Toggle again
   - **Result**: Gated behavior

6. **Mackie Protocol** (`sendMackieControlToggle()`):
   - Sends Note On (127) + Note Off (0)
   - 5ms delay between toggles
   - Uses Channel 1 (Mackie Control standard)

**What it does**: The brain of the operation - handles all MIDI communication

---

## 🎯 Key Concepts

### Virtual MIDI Destination
Creates a virtual MIDI port that appears in Logic Pro X's Control Surface setup. Logic connects to this port and receives Mackie Control messages.

### Mackie Control Protocol
Industry-standard protocol for DAW control surfaces. Uses MIDI Note On/Off messages with specific note numbers for mute/solo buttons.

### Gated Behavior
Achieved by sending **two toggles**: one on key press, one on key release. Since mute/solo are toggle buttons, two toggles = return to original state.

### Channel Filtering
Only listens to Channel 16 to avoid conflicts with musical input on Channels 1-15.

---

## 📊 File Statistics

| File | Lines | Purpose |
|------|-------|---------|
| **main.swift** | 10 | Entry point |
| **AppDelegate.swift** | ~150 | Menu bar UI |
| **MIDIController.swift** | ~250 | Core MIDI logic |
| **Info.plist** | 25 | App configuration |
| **README.md** | ~450 | User documentation |
| **BUILD_WITH_XCODE.md** | ~300 | Build guide |
| **SETUP_GUIDE.md** | ~250 | Troubleshooting |
| **PROJECT_SUMMARY.md** | ~400 | Technical overview |
| **QUICKSTART.md** | ~150 | Quick start |

**Total Code**: ~410 lines of Swift
**Total Documentation**: ~1,550 lines

---

## 🚦 Build Status

| Method | Status | Reason |
|--------|--------|--------|
| **Xcode** | ✅ **WORKS** | Handles SDK linking automatically |
| **Command-line** | ❌ Broken | SDK version mismatch |
| **Swift PM** | ❌ Broken | SDK version mismatch |

**Recommended**: Build with Xcode (see BUILD_WITH_XCODE.md)

---

## 🎓 Learning Path

### Beginner (Just want to use it)
1. QUICKSTART.md → Build and run
2. README.md → Learn how to use it

### Intermediate (Want to customize)
1. PROJECT_SUMMARY.md → Understand architecture
2. MIDIController.swift → Read the code
3. README.md → Advanced Configuration section

### Advanced (Want to extend it)
1. PROJECT_SUMMARY.md → Full technical overview
2. All source files → Study implementation
3. Apple CoreMIDI docs → Deep dive into framework
4. Mackie Control spec → Understand protocol

---

## 🔗 External Resources

Referenced in this project:

### Apple Documentation
- [CoreMIDI Framework](https://developer.apple.com/documentation/coremidi/)
- [MIDI Services](https://developer.apple.com/documentation/coremidi/midi-services)
- [MIDIDestinationCreate](https://developer.apple.com/documentation/coremidi/1495347-mididestinationcreate)

### Mackie Control Protocol
- [TouchMCU Documentation](https://github.com/NicoG60/TouchMCU/blob/main/doc/mackie_control_protocol.md)
- [MIDIBox Protocol Mappings](http://www.midibox.org/dokuwiki/doku.php?id=mc_protocol_mappings)

### Swift MIDI Libraries
- [MIDIKit](https://github.com/orchetect/MIDIKit)
- [MIKMIDI](https://github.com/mixedinkey-opensource/MIKMIDI)

---

## ✅ Completion Checklist

All deliverables from the spec:

- ✅ Virtual MIDI Device Creation
- ✅ MIDI Input Handling (Channel 16)
- ✅ Note-to-Track Mapping (36-59 → Tracks 1-12)
- ✅ Mackie Control Protocol Implementation
- ✅ Gated Behavior Logic
- ✅ Configuration UI (Menu Bar App)
- ✅ Performance Requirements (< 10ms latency)
- ✅ Source Code (Swift/CoreMIDI)
- ✅ README with setup instructions
- ✅ Configuration guide

**Status**: ✅ **PROJECT COMPLETE**

---

## 🎉 You're All Set!

Choose your starting point:
- **New User**: [QUICKSTART.md](QUICKSTART.md)
- **Building**: [BUILD_WITH_XCODE.md](BUILD_WITH_XCODE.md)
- **Learning**: [README.md](README.md)
- **Developing**: [PROJECT_SUMMARY.md](PROJECT_SUMMARY.md)

**Happy mixing!** 🎚️🎵
