import Cocoa

// Entry point for the macOS menu bar application
let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate

// Set activation policy to accessory (menu bar app without dock icon)
app.setActivationPolicy(.accessory)

// Run the application
app.run()
