# Quick Start Guide

## 🚀 Get Running in 5 Minutes

### Prerequisites

- ✅ macOS 12.0+ (Monterey or later)
- ✅ Xcode installed (from Mac App Store)
- ✅ Logic Pro X
- ✅ MIDI keyboard (e.g., Arturia KeyLab Essential 49)

---

## Step 1: Build the App (2 minutes)

### Using Xcode (Recommended)

1. **Open Xcode**
2. **File** → **New** → **Project**
3. Select **macOS** → **App**
4. Name it: **GatedMuteController**
5. Click **Next** → **Create**

6. **Add the source files**:
   - Right-click on project folder → **Add Files**
   - Add these 3 files from `Sources/GatedMuteController/`:
     - `main.swift`
     - `AppDelegate.swift`
     - `MIDIController.swift`
   - ✅ Check **"Copy items if needed"**

7. **Delete the default files**:
   - Delete `AppDelegate.swift` (the auto-generated one)
   - Delete `Main.storyboard`

8. **Configure Info.plist**:
   - Click `Info.plist`
   - Add new row: `LSUIElement` = `YES` (Boolean)
   - Delete: "Main storyboard file base name" (if present)

9. **Build**: Press **⌘B**

10. **Run**: Press **⌘R**

✅ **You should see a music note icon in your menu bar!**

---

## Step 2: Configure Logic Pro X (1 minute)

1. Open **Logic Pro X**
2. Go to **Logic Pro** → **Control Surfaces** → **Setup...**
3. Click **Install** (in the toolbar)
4. Find **"Gated Mute Controller"** in the left panel
5. Select it and click **Add**
6. Close the window

✅ **Logic now recognizes the controller!**

---

## Step 3: Connect Your MIDI Keyboard (1 minute)

1. **Click the music note icon** in the menu bar
2. Go to **MIDI Input Device**
3. Select your MIDI keyboard (e.g., "KeyLab Essential 49")

✅ **Connected!**

---

## Step 4: Configure Your Keyboard (1 minute)

Make sure your MIDI keyboard sends on **Channel 16** for the control notes.

### For Arturia KeyLab Essential 49:
1. Press the **MIDI** button
2. Use the keypad to set channel: **16**
3. Press **MIDI** again to confirm

✅ **Ready to go!**

---

## Step 5: Test It! (30 seconds)

1. In Logic Pro X, create a new project with a few tracks
2. On your MIDI keyboard, press and **HOLD** the **C1** key (lowest C on most keyboards)
3. **Track 1 should mute** while you hold it
4. **Release the key** → Track 1 unmutes

🎉 **It works!**

---

## MIDI Note Mappings Cheat Sheet

### Mute Controls (Octave 1)

| Key | Track | Key | Track |
|-----|-------|-----|-------|
| C1  | Track 1 | F#1 | Track 7 |
| C#1 | Track 2 | G1  | Track 8 |
| D1  | Track 3 | G#1 | Track 9 |
| D#1 | Track 4 | A1  | Track 10 |
| E1  | Track 5 | A#1 | Track 11 |
| F1  | Track 6 | B1  | Track 12 |

### Solo Controls (Octave 2)

Same pattern, but **one octave higher** (C2-B2)

---

## Troubleshooting

### "Music note doesn't appear in menu bar"

- Check that `LSUIElement = YES` in Info.plist
- Rebuild the app

### "Logic doesn't see the controller"

- Make sure the app is running (menu bar icon present)
- Restart Logic Pro X
- Check Control Surfaces → Setup → Install

### "Keys don't do anything"

1. **Check MIDI Channel**: Your keyboard must send on **Channel 16**
2. **Check Device Selection**: Menu bar icon → MIDI Input Device
3. **Check Logic**: Control Surfaces should show "Gated Mute Controller"

### "Tracks 9-12 don't work"

- Standard Mackie Control supports 8 tracks directly
- Tracks 9-12 use extended protocol (may need testing)
- Tracks 1-8 are guaranteed to work

---

## Usage Tips

### Perfect for Mixing

- **A/B Comparisons**: Quickly mute/unmute to hear differences
- **Soloing**: Solo a track momentarily without losing your mix
- **Live Performance**: Dynamic mute control during playback

### Workflow Tips

- Use **left hand** for mute/solo while adjusting faders with mouse
- Assign **most-used tracks** to the first 8 slots for best compatibility
- Combine with Logic's **automation** for creative effects

---

## Need More Help?

📖 **Full Documentation**: See `README.md`
🔧 **Build Issues**: See `BUILD_WITH_XCODE.md`
🛠️ **Troubleshooting**: See `SETUP_GUIDE.md`

---

## What's Next?

Now that you have it running:

- ✅ Explore the menu bar options
- ✅ View the mappings reference (click menu bar icon → "Show Mappings")
- ✅ Try the solo controls (C2-B2)
- ✅ Customize the mappings in the code if desired

**Happy Mixing!** 🎚️🎵
