#!/bin/bash

# Build script for Gated Mute Controller
# This script compiles the Swift files and creates an application bundle

set -e

echo "Building Gated Mute Controller..."

# Configuration
APP_NAME="GatedMuteController"
BUNDLE_ID="com.gatedmute.controller"
BUILD_DIR="build"
APP_BUNDLE="$BUILD_DIR/$APP_NAME.app"
CONTENTS_DIR="$APP_BUNDLE/Contents"
MACOS_DIR="$CONTENTS_DIR/MacOS"
RESOURCES_DIR="$CONTENTS_DIR/Resources"

# Clean previous build
rm -rf "$BUILD_DIR"

# Create bundle structure
mkdir -p "$MACOS_DIR"
mkdir -p "$RESOURCES_DIR"

# Compile Swift files
echo "Compiling Swift files..."
swiftc -o "$MACOS_DIR/$APP_NAME" \
    -framework Cocoa \
    -framework CoreMIDI \
    -framework CoreFoundation \
    -target arm64-apple-macos12.0 \
    AppDelegate.swift \
    MIDIController.swift

# Copy Info.plist
cp Info.plist "$CONTENTS_DIR/"

# Create PkgInfo
echo "APPL????" > "$CONTENTS_DIR/PkgInfo"

# Make executable
chmod +x "$MACOS_DIR/$APP_NAME"

echo ""
echo "✅ Build complete!"
echo "Application bundle created at: $APP_BUNDLE"
echo ""
echo "To run the app:"
echo "  open $APP_BUNDLE"
echo ""
echo "To install (optional):"
echo "  cp -r $APP_BUNDLE /Applications/"
