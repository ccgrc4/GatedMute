# Setup Guide - Gated Mute Controller

## Quick Start (Recommended Method)

Since the command-line Swift compiler has SDK compatibility issues, the best way to build this project is using **Xcode**.

### Method 1: Using Xcode (Recommended)

1. **Open Xcode** (download from Mac App Store if needed)

2. **Create New Project**
   - File → New → Project
   - Choose **macOS** → **App**
   - Product Name: `GatedMuteController`
   - Interface: **Storyboard** or **SwiftUI** (we'll replace the UI)
   - Language: **Swift**
   - Click **Next** and save

3. **Replace Files**
   ```bash
   # Copy our Swift files into the Xcode project
   cp AppDelegate.swift /path/to/XcodeProject/GatedMuteController/
   cp MIDIController.swift /path/to/XcodeProject/GatedMuteController/
   cp Info.plist /path/to/XcodeProject/GatedMuteController/
   ```

4. **Add to Xcode Project**
   - Drag the files into Xcode's file navigator
   - Make sure "Copy items if needed" is checked
   - Click **Finish**

5. **Configure Project Settings**
   - Select the project in the navigator
   - Go to **Signing & Capabilities**
   - Choose your development team or sign to run locally
   - Make sure **LSUIElement** is set to **YES** in Info.plist (menu bar app)

6. **Build and Run**
   - Press **⌘R** or click the **Play** button
   - The app will compile and run
   - Look for the music note icon in your menu bar

### Method 2: Using Swift Package Manager

Create a `Package.swift` file:

```swift
// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "GatedMuteController",
    platforms: [.macOS(.v12)],
    targets: [
        .executableTarget(
            name: "GatedMuteController",
            dependencies: [],
            path: ".",
            sources: ["AppDelegate.swift", "MIDIController.swift"]
        )
    ]
)
```

Then build:
```bash
swift build -c release
./.build/release/GatedMuteController
```

### Method 3: Fix the Build Script (Advanced)

The build script fails due to SDK version mismatch. To fix:

1. **Update Xcode Command Line Tools**:
   ```bash
   sudo xcode-select --install
   sudo xcode-select --reset
   ```

2. **Use Xcode's Swift compiler**:
   Edit `build.sh` to use Xcode's Swift compiler:
   ```bash
   SWIFT_COMPILER="/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/swiftc"

   $SWIFT_COMPILER -o "$MACOS_DIR/$APP_NAME" \
       -framework Cocoa \
       -framework CoreMIDI \
       -framework CoreFoundation \
       -target arm64-apple-macos12.0 \
       -sdk /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk \
       AppDelegate.swift \
       MIDIController.swift
   ```

## After Building

Once you have a working `.app` bundle:

1. **Launch the app**
   - Double-click the app or run from Xcode
   - A music note icon appears in your menu bar

2. **Configure Logic Pro X**
   - Open Logic Pro X
   - Logic Pro → Control Surfaces → Setup
   - Click "Install"
   - Select "Gated Mute Controller"
   - Click "Add"

3. **Select MIDI Input**
   - Click the menu bar icon
   - MIDI Input Device → Select your keyboard

4. **Test It!**
   - Press C1 (MIDI note 36) on your keyboard
   - Track 1 should mute while held, unmute when released

## Troubleshooting Build Issues

### "Could not build module 'Foundation'"

**Solution**: Use Xcode instead of command-line build. Xcode handles SDK linking automatically.

### "SDK is not supported by the compiler"

**Cause**: Command Line Tools version doesn't match your macOS SDK

**Solution**:
- Update Command Line Tools: `sudo xcode-select --install`
- OR: Use Xcode to build (recommended)

### "Missing Info.plist"

**Solution**: Make sure Info.plist is in the same directory as the Swift files, or in the Resources folder if using Xcode.

### "App crashes on launch"

**Check**:
1. Info.plist has correct bundle ID
2. LSUIElement is set to true (for menu bar app)
3. Console.app for crash logs

## Alternative: Pre-built Binary (If Available)

If someone has shared a pre-built `.app` file:

1. Download `GatedMuteController.app`
2. Right-click → Open (to bypass Gatekeeper)
3. Grant permissions if prompted
4. Follow "After Building" steps above

## Development Tips

### Testing Without Logic Pro X

You can test MIDI communication using:
- **MIDI Monitor** (free app): See incoming MIDI messages
- **IAC Driver**: Create virtual MIDI bus in Audio MIDI Setup

### Debugging MIDI Issues

Add logging to `MIDIController.swift`:

```swift
private func handleNoteOn(note: UInt8) {
    print("📥 Received Note On: \(note) on Channel 16")
    if let mackieCommand = mapNoteToMackieControl(note: note) {
        print("📤 Sending Mackie Control: Note \(mackieCommand.note) (\(mackieCommand.type))")
        sendMackieControlToggle(note: mackieCommand.note, type: mackieCommand.type)
    }
}
```

Run from Xcode and check the console output.

### Viewing MIDI Devices

```swift
// In Xcode or Swift REPL
import CoreMIDI

let sourceCount = MIDIGetNumberOfSources()
for i in 0..<sourceCount {
    let source = MIDIGetSource(i)
    var name: Unmanaged<CFString>?
    MIDIObjectGetStringProperty(source, kMIDIPropertyName, &name)
    if let deviceName = name?.takeRetainedValue() {
        print("MIDI Source: \(deviceName)")
    }
}
```

## Next Steps

Once built successfully:
1. Read the main **README.md** for full usage instructions
2. Check **MIDI Note Mappings** section
3. Configure your KeyLab to send on Channel 16
4. Start mixing with gated mute/solo! 🎚️
