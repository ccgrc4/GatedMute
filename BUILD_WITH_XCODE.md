# Building with Xcode (Recommended Method)

Due to Swift SDK compatibility issues with command-line tools, **Xcode is the recommended way to build this project**.

## Step-by-Step: Creating the Xcode Project

### 1. Create New Xcode Project

1. Open **Xcode**
2. **File** → **New** → **Project**
3. Select **macOS** → **App**
4. Configure:
   - **Product Name**: `GatedMuteController`
   - **Team**: Select your team or "None"
   - **Organization Identifier**: `com.gatedmute`
   - **Interface**: Select **Storyboard** (we'll modify this)
   - **Language**: **Swift**
   - **Use Core Data**: Unchecked
   - **Include Tests**: Optional
5. Click **Next**, choose location, click **Create**

### 2. Add Source Files

1. In Xcode's file navigator (left sidebar), **right-click** on the `GatedMuteController` folder
2. Choose **Add Files to "GatedMuteController"...**
3. Navigate to the project directory and select:
   - `MIDIController.swift`
   - `main.swift`
4. Make sure **"Copy items if needed"** is **checked**
5. Click **Add**

### 3. Replace AppDelegate

1. In Xcode, select the existing `AppDelegate.swift`
2. Press **Delete** → **Move to Trash**
3. Add our `AppDelegate.swift`:
   - **Right-click** on project folder
   - **Add Files to "GatedMuteController"...**
   - Select `AppDelegate.swift`
   - Check **"Copy items if needed"**
   - Click **Add**

### 4. Remove Storyboard (We're using menu bar UI)

1. Select `Main.storyboard` in the file navigator
2. Press **Delete** → **Move to Trash**
3. Select the project icon at the top of the navigator
4. Go to **Info** tab
5. Find **"Main storyboard file base name"** and delete that entire row
6. Find **"Application Scene Manifest"** and delete that entire section

### 5. Configure Info.plist

1. Select `Info.plist` in the navigator
2. Add/Modify these keys (right-click → **Add Row**):

| Key | Type | Value |
|-----|------|-------|
| **LSUIElement** | Boolean | **YES** |
| **LSMinimumSystemVersion** | String | **12.0** |
| **CFBundleDisplayName** | String | **Gated Mute Controller** |

**Important**: `LSUIElement = YES` makes this a menu bar app (no dock icon).

### 6. Configure Project Settings

1. Click the **project icon** at the top of the navigator
2. Select the **GatedMuteController** target
3. Go to **General** tab:
   - **Minimum Deployments**: **macOS 12.0** or later
4. Go to **Signing & Capabilities** tab:
   - Choose your **Team** or select **Sign to Run Locally**
   - **Bundle Identifier**: `com.gatedmute.controller`

### 7. Add CoreMIDI Framework (Should be automatic, but verify)

1. With target selected, go to **Build Phases** tab
2. Expand **Link Binary With Libraries**
3. Verify these frameworks are present (click **+** to add if missing):
   - `Cocoa.framework`
   - `CoreMIDI.framework`
   - `CoreFoundation.framework`

### 8. Build and Run

1. Press **⌘B** to build (or Product → Build)
2. If build succeeds, press **⌘R** to run
3. Look for the **music note icon** in your menu bar!

## Troubleshooting Xcode Build

### "Undefined symbol: AppDelegate"

**Fix**: Make sure you removed the `@main` attribute from `AppDelegate.swift`. We use `main.swift` as the entry point.

### "Cannot find 'MIDIClientRef' in scope"

**Fix**: CoreMIDI framework not linked. Go to Build Phases → Link Binary With Libraries → Add `CoreMIDI.framework`

### "Missing Info.plist"

**Fix**: Info.plist should be in the project root. Xcode creates this automatically. Just add the `LSUIElement` key.

### App builds but doesn't appear

**Fix**: Check that `LSUIElement` is set to `YES` in Info.plist. This makes it a menu bar app.

### "Signing certificate not found"

**Fix**:
- Go to **Signing & Capabilities**
- Uncheck **Automatically manage signing**
- Select **Sign to Run Locally** from Team dropdown
- OR: Create a free Apple Developer account

## Creating an Application Bundle

### Option 1: Archive for Distribution

1. **Product** → **Archive**
2. Once archived, click **Distribute App**
3. Choose **Copy App**
4. Select destination folder
5. You'll get a `GatedMuteController.app` bundle

### Option 2: Use Built Product

1. After building (⌘B), go to **Product** → **Show Build Folder in Finder**
2. Navigate to `Products/Debug/GatedMuteController.app`
3. Copy this `.app` bundle wherever you want

### Option 3: Build for Release

1. **Product** → **Scheme** → **Edit Scheme**
2. Select **Run** in left sidebar
3. Change **Build Configuration** to **Release**
4. Build (⌘B)
5. Find the app in the build folder (it will be optimized and smaller)

## Installing the App

Once you have `GatedMuteController.app`:

```bash
# Copy to Applications folder
cp -r GatedMuteController.app /Applications/

# Or just run it from anywhere
open GatedMuteController.app
```

## Distributing to Other Macs

### For Personal Use (No Notarization)

1. Build the app as described above
2. Zip the `.app` bundle:
   ```bash
   zip -r GatedMuteController.zip GatedMuteController.app
   ```
3. Share the zip file
4. Recipients: Right-click → **Open** (to bypass Gatekeeper)

### For Public Distribution (Requires Notarization)

1. Join **Apple Developer Program** ($99/year)
2. Archive the app (**Product** → **Archive**)
3. Click **Distribute App** → **Developer ID**
4. Follow Apple's notarization process
5. Once notarized, the app will run on any Mac without warnings

## Next Steps

After successfully building:

1. **Launch** the app (music note icon in menu bar)
2. **Configure Logic Pro X**:
   - Logic Pro → Control Surfaces → Setup
   - Install "Gated Mute Controller"
3. **Select MIDI device** from the menu bar
4. **Test**: Press C1 to mute Track 1!

## Additional Resources

- [Xcode Documentation](https://developer.apple.com/documentation/xcode)
- [CoreMIDI Framework](https://developer.apple.com/documentation/coremidi/)
- [Code Signing Guide](https://developer.apple.com/support/code-signing/)

---

**Need Help?** Check the main README.md for troubleshooting or the SETUP_GUIDE.md for alternative build methods.
