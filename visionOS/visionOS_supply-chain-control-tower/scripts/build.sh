#!/bin/bash

# Build script for Supply Chain Control Tower
#
# Usage:
#   ./scripts/build.sh [options]
#
# Options:
#   --scheme SCHEME      Build scheme (default: SupplyChainControlTower)
#   --config CONFIG      Build configuration (Debug|Release, default: Debug)
#   --destination DEST   Build destination (default: visionOS Simulator)
#   --clean             Clean before building
#   --help              Show this help message

set -e  # Exit on error
set -u  # Exit on undefined variable

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
SCHEME="SupplyChainControlTower"
CONFIGURATION="Debug"
DESTINATION="platform=visionOS Simulator,name=Apple Vision Pro"
CLEAN=false
VERBOSE=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --scheme)
            SCHEME="$2"
            shift 2
            ;;
        --config)
            CONFIGURATION="$2"
            shift 2
            ;;
        --destination)
            DESTINATION="$2"
            shift 2
            ;;
        --clean)
            CLEAN=true
            shift
            ;;
        --verbose)
            VERBOSE=true
            shift
            ;;
        --help)
            head -n 12 "$0" | tail -n 11
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            exit 1
            ;;
    esac
done

# Function to log with color
log() {
    local color=$1
    shift
    echo -e "${color}$*${NC}"
}

# Check if Xcode is installed
if ! command -v xcodebuild &> /dev/null; then
    log "$RED" "Error: xcodebuild not found. Please install Xcode."
    exit 1
fi

log "$BLUE" "==================================="
log "$BLUE" "Supply Chain Control Tower - Build"
log "$BLUE" "==================================="
echo ""
log "$GREEN" "Scheme:        $SCHEME"
log "$GREEN" "Configuration: $CONFIGURATION"
log "$GREEN" "Destination:   $DESTINATION"
echo ""

# Clean if requested
if [ "$CLEAN" = true ]; then
    log "$YELLOW" "Cleaning build directory..."
    xcodebuild clean \
        -scheme "$SCHEME" \
        -configuration "$CONFIGURATION" \
        -destination "$DESTINATION" \
        2>&1 | grep -v "^$"
    log "$GREEN" "✓ Clean complete"
    echo ""
fi

# Build
log "$YELLOW" "Building project..."

if [ "$VERBOSE" = true ]; then
    xcodebuild build \
        -scheme "$SCHEME" \
        -configuration "$CONFIGURATION" \
        -destination "$DESTINATION" \
        -parallelizeTargets \
        -quiet
else
    xcodebuild build \
        -scheme "$SCHEME" \
        -configuration "$CONFIGURATION" \
        -destination "$DESTINATION" \
        -parallelizeTargets \
        -quiet \
        | xcpretty 2>/dev/null || cat
fi

BUILD_STATUS=${PIPESTATUS[0]}

if [ $BUILD_STATUS -eq 0 ]; then
    log "$GREEN" "✓ Build successful!"
else
    log "$RED" "✗ Build failed with status $BUILD_STATUS"
    exit $BUILD_STATUS
fi

echo ""
log "$BLUE" "==================================="
log "$GREEN" "Build completed successfully!"
log "$BLUE" "==================================="
