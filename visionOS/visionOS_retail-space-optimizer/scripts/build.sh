#!/bin/bash

# Build script for Retail Space Optimizer

set -e

echo "🔨 Building Retail Space Optimizer..."

cd RetailSpaceOptimizer

# Parse arguments
CONFIGURATION="Debug"
CLEAN=false
ARCHIVE=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --release)
            CONFIGURATION="Release"
            shift
            ;;
        --clean)
            CLEAN=true
            shift
            ;;
        --archive)
            ARCHIVE=true
            CONFIGURATION="Release"
            shift
            ;;
        *)
            echo "Unknown option: $1"
            echo "Usage: $0 [--release] [--clean] [--archive]"
            exit 1
            ;;
    esac
done

# Clean if requested
if [ "$CLEAN" = true ]; then
    echo "🧹 Cleaning build folder..."
    rm -rf ~/Library/Developer/Xcode/DerivedData
    xcodebuild clean -scheme RetailSpaceOptimizer
fi

# Build or archive
if [ "$ARCHIVE" = true ]; then
    echo "📦 Creating archive for App Store distribution..."
    xcodebuild archive \
        -scheme RetailSpaceOptimizer \
        -destination generic/platform=visionOS \
        -archivePath ../build/RetailSpaceOptimizer.xcarchive \
        -configuration $CONFIGURATION

    echo ""
    echo "✅ Archive created successfully!"
    echo "Location: build/RetailSpaceOptimizer.xcarchive"
    echo ""
    echo "Next steps:"
    echo "1. Open Xcode Organizer: Window > Organizer"
    echo "2. Select your archive"
    echo "3. Click 'Distribute App'"
else
    echo "🔨 Building $CONFIGURATION configuration..."
    xcodebuild build \
        -scheme RetailSpaceOptimizer \
        -destination 'platform=visionOS Simulator,name=Apple Vision Pro' \
        -configuration $CONFIGURATION

    echo ""
    echo "✅ Build completed successfully!"
fi
