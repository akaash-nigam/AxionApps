#!/bin/bash

# MySpatial Life - Xcode Project Creation Script
# This script helps create a proper Xcode project for the visionOS app

set -e

echo "🎮 MySpatial Life - Xcode Project Setup"
echo "========================================"
echo ""

# Check if Xcode is installed
if ! command -v xcodebuild &> /dev/null; then
    echo "❌ Error: Xcode is not installed"
    echo "Please install Xcode 16.0+ from the Mac App Store"
    exit 1
fi

# Check Xcode version
XCODE_VERSION=$(xcodebuild -version | head -n 1 | awk '{print $2}')
echo "✅ Xcode version: $XCODE_VERSION"

# Check for visionOS SDK
if ! xcodebuild -showsdks | grep -q "visionOS"; then
    echo "❌ Error: visionOS SDK not found"
    echo "Please install visionOS SDK from Xcode Settings → Platforms"
    exit 1
fi

echo "✅ visionOS SDK found"
echo ""

# Instructions for creating project
echo "📋 Manual Steps Required (Xcode project creation cannot be fully automated)"
echo "============================================================================"
echo ""
echo "Please follow these steps in Xcode:"
echo ""
echo "1. OPEN XCODE"
echo "   - Launch Xcode 16.0+"
echo ""
echo "2. CREATE NEW PROJECT"
echo "   - File → New → Project"
echo "   - Select 'visionOS' platform tab"
echo "   - Choose 'App' template"
echo "   - Click 'Next'"
echo ""
echo "3. PROJECT SETTINGS"
echo "   - Product Name: MySpatialLife"
echo "   - Team: Select your Apple Developer account"
echo "   - Organization Identifier: com.yourname (use your own)"
echo "   - Bundle Identifier: com.yourname.MySpatialLife"
echo "   - Interface: SwiftUI"
echo "   - Language: Swift"
echo "   - ✅ Include Tests"
echo "   - Click 'Next'"
echo ""
echo "4. SAVE LOCATION"
echo "   - Navigate to: $(pwd)"
echo "   - Create a NEW folder called 'MySpatialLife_Xcode'"
echo "   - Click 'Create'"
echo ""
echo "5. COPY SOURCE FILES"
echo "   After Xcode project is created, run:"
echo "   ./copy_source_files.sh"
echo ""
echo "6. ADD EXISTING FILES TO PROJECT"
echo "   - In Xcode, delete the auto-generated files:"
echo "     • ContentView.swift"
echo "     • MySpatialLifeApp.swift (Xcode's version)"
echo "   - Right-click project root → Add Files to 'MySpatialLife'"
echo "   - Navigate to MySpatialLife/MySpatialLife/"
echo "   - Select ALL folders (App, Core, Game, etc.)"
echo "   - ✅ Copy items if needed"
echo "   - ✅ Create groups"
echo "   - ✅ Add to target: MySpatialLife"
echo "   - Click 'Add'"
echo ""
echo "7. CONFIGURE PROJECT SETTINGS"
echo "   - Select MySpatialLife target"
echo "   - General tab:"
echo "     • Display Name: MySpatial Life"
echo "     • Bundle Identifier: (verify correct)"
echo "     • Version: 1.0"
echo "     • Build: 1"
echo "     • Minimum Deployments: visionOS 2.0"
echo "   - Signing & Capabilities:"
echo "     • Team: Select your team"
echo "     • ✅ Automatically manage signing"
echo "     • Click '+' to add capabilities:"
echo "       - ARKit"
echo "       - World Sensing"
echo "       - Hand Tracking"
echo "   - Info tab:"
echo "     • Replace with our Info.plist content (already in MySpatialLife/)"
echo ""
echo "8. ADD SWIFT PACKAGE DEPENDENCIES"
echo "   - File → Add Package Dependencies"
echo "   - Add these packages:"
echo "     • https://github.com/apple/swift-algorithms"
echo "     • https://github.com/apple/swift-collections"
echo "     • https://github.com/apple/swift-numerics"
echo "   - For each, select: Up to Next Major Version"
echo "   - Add to target: MySpatialLife"
echo ""
echo "9. BUILD AND RUN"
echo "   - Select 'Apple Vision Pro' simulator"
echo "   - Press Cmd+R to build and run"
echo "   - Or press Cmd+B to just build"
echo ""
echo "================================================"
echo "✅ Ready to create Xcode project!"
echo "================================================"
echo ""
echo "Alternative: Quick Setup Script"
echo "If you want to try automated project creation (experimental):"
echo "  ./generate_xcodeproj.sh"
echo ""
