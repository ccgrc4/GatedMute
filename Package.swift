// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "GatedMuteController",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .executable(
            name: "GatedMuteController",
            targets: ["GatedMuteController"]
        )
    ],
    targets: [
        .executableTarget(
            name: "GatedMuteController",
            dependencies: [],
            path: ".",
            sources: [
                "main.swift",
                "AppDelegate.swift",
                "MIDIController.swift"
            ],
            linkerSettings: [
                .linkedFramework("Cocoa"),
                .linkedFramework("CoreMIDI"),
                .linkedFramework("CoreFoundation")
            ]
        )
    ]
)
