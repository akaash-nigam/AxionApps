#!/bin/bash

# =============================================================================
# Financial Trading Dimension - Build Script
# =============================================================================
# Builds the project for different configurations and runs validation
# Usage: ./scripts/build.sh [debug|release] [simulator|device]
# =============================================================================

set -e  # Exit on error
set -u  # Exit on undefined variable

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
PROJECT_NAME="FinancialTradingDimension"
SCHEME_NAME="FinancialTradingDimension"
WORKSPACE="${PROJECT_NAME}.xcworkspace"
BUILD_DIR="build"
DERIVED_DATA="DerivedData"

# Parse arguments
CONFIGURATION="${1:-debug}"  # debug or release
DESTINATION_TYPE="${2:-simulator}"  # simulator or device

# Convert to proper case
if [ "$CONFIGURATION" = "debug" ]; then
    XCODE_CONFIGURATION="Debug"
elif [ "$CONFIGURATION" = "release" ]; then
    XCODE_CONFIGURATION="Release"
else
    echo -e "${RED}Error: Invalid configuration '$CONFIGURATION'. Use 'debug' or 'release'${NC}"
    exit 1
fi

# Set destination
if [ "$DESTINATION_TYPE" = "simulator" ]; then
    DESTINATION="platform=visionOS Simulator,name=Apple Vision Pro"
elif [ "$DESTINATION_TYPE" = "device" ]; then
    DESTINATION="platform=visionOS,id=<device-id>"  # Replace with actual device ID
else
    echo -e "${RED}Error: Invalid destination '$DESTINATION_TYPE'. Use 'simulator' or 'device'${NC}"
    exit 1
fi

# Functions
print_header() {
    echo -e "\n${BLUE}===================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}===================================${NC}\n"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

# Main build process
main() {
    print_header "Financial Trading Dimension Build Script"

    print_info "Configuration: $XCODE_CONFIGURATION"
    print_info "Destination: $DESTINATION_TYPE"
    print_info "Build Directory: $BUILD_DIR"

    # Step 1: Clean
    print_header "Step 1: Cleaning Previous Build"
    clean_build

    # Step 2: Resolve Dependencies
    print_header "Step 2: Resolving Dependencies"
    resolve_dependencies

    # Step 3: Lint
    print_header "Step 3: Running SwiftLint"
    run_swiftlint

    # Step 4: Build
    print_header "Step 4: Building Project"
    build_project

    # Step 5: Run Tests (only in debug mode)
    if [ "$CONFIGURATION" = "debug" ]; then
        print_header "Step 5: Running Tests"
        run_tests
    fi

    # Step 6: Archive (only in release mode for device)
    if [ "$CONFIGURATION" = "release" ] && [ "$DESTINATION_TYPE" = "device" ]; then
        print_header "Step 6: Creating Archive"
        create_archive
    fi

    print_header "Build Completed Successfully!"
    print_success "Build artifacts available in: $BUILD_DIR"
}

clean_build() {
    if [ -d "$BUILD_DIR" ]; then
        print_info "Removing $BUILD_DIR directory..."
        rm -rf "$BUILD_DIR"
    fi

    if [ -d "$DERIVED_DATA" ]; then
        print_info "Removing $DERIVED_DATA directory..."
        rm -rf "$DERIVED_DATA"
    fi

    # Xcode clean
    print_info "Running xcodebuild clean..."
    xcodebuild clean \
        -scheme "$SCHEME_NAME" \
        -configuration "$XCODE_CONFIGURATION" \
        -destination "$DESTINATION" \
        > /dev/null 2>&1 || true

    print_success "Clean completed"
}

resolve_dependencies() {
    print_info "Resolving Swift Package Manager dependencies..."

    xcodebuild -resolvePackageDependencies \
        -scheme "$SCHEME_NAME" \
        -configuration "$XCODE_CONFIGURATION"

    print_success "Dependencies resolved"
}

run_swiftlint() {
    if command -v swiftlint >/dev/null 2>&1; then
        print_info "Running SwiftLint..."

        if swiftlint --strict; then
            print_success "SwiftLint passed with no warnings"
        else
            print_warning "SwiftLint found issues. Review output above."
            # Don't fail build, just warn
        fi
    else
        print_warning "SwiftLint not installed. Skipping lint check."
        print_info "Install with: brew install swiftlint"
    fi
}

build_project() {
    print_info "Building $SCHEME_NAME..."

    mkdir -p "$BUILD_DIR"

    xcodebuild build \
        -scheme "$SCHEME_NAME" \
        -configuration "$XCODE_CONFIGURATION" \
        -destination "$DESTINATION" \
        -derivedDataPath "$DERIVED_DATA" \
        CONFIGURATION_BUILD_DIR="$BUILD_DIR" \
        CODE_SIGN_IDENTITY="" \
        CODE_SIGNING_REQUIRED=NO \
        CODE_SIGNING_ALLOWED=NO \
        | xcpretty || exit 1

    print_success "Build completed"
}

run_tests() {
    print_info "Running unit tests..."

    xcodebuild test \
        -scheme "$SCHEME_NAME" \
        -configuration "$XCODE_CONFIGURATION" \
        -destination "$DESTINATION" \
        -derivedDataPath "$DERIVED_DATA" \
        -enableCodeCoverage YES \
        | xcpretty || exit 1

    print_success "Tests completed"

    # Generate code coverage report
    generate_coverage_report
}

generate_coverage_report() {
    print_info "Generating code coverage report..."

    # Find the latest test result bundle
    RESULT_BUNDLE=$(find "$DERIVED_DATA" -name "*.xcresult" | head -n 1)

    if [ -n "$RESULT_BUNDLE" ]; then
        xcrun xccov view --report "$RESULT_BUNDLE" > "$BUILD_DIR/coverage.txt"
        print_success "Coverage report saved to $BUILD_DIR/coverage.txt"

        # Display coverage percentage
        COVERAGE=$(xcrun xccov view --report "$RESULT_BUNDLE" | grep "FinancialTradingDimension" | awk '{print $4}')
        print_info "Code Coverage: $COVERAGE"
    else
        print_warning "Could not find test results for coverage report"
    fi
}

create_archive() {
    print_info "Creating archive..."

    ARCHIVE_PATH="$BUILD_DIR/${PROJECT_NAME}.xcarchive"

    xcodebuild archive \
        -scheme "$SCHEME_NAME" \
        -configuration "$XCODE_CONFIGURATION" \
        -destination "$DESTINATION" \
        -archivePath "$ARCHIVE_PATH" \
        -derivedDataPath "$DERIVED_DATA" \
        | xcpretty || exit 1

    print_success "Archive created: $ARCHIVE_PATH"

    # Export IPA (requires export options)
    # export_ipa "$ARCHIVE_PATH"
}

export_ipa() {
    local archive_path="$1"
    print_info "Exporting IPA..."

    EXPORT_PATH="$BUILD_DIR/export"
    EXPORT_OPTIONS="ExportOptions.plist"

    if [ ! -f "$EXPORT_OPTIONS" ]; then
        print_warning "Export options not found. Creating default..."
        create_export_options
    fi

    xcodebuild -exportArchive \
        -archivePath "$archive_path" \
        -exportPath "$EXPORT_PATH" \
        -exportOptionsPlist "$EXPORT_OPTIONS" \
        | xcpretty || exit 1

    print_success "IPA exported to: $EXPORT_PATH"
}

create_export_options() {
    cat > ExportOptions.plist <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>app-store</string>
    <key>teamID</key>
    <string>YOUR_TEAM_ID</string>
    <key>uploadBitcode</key>
    <false/>
    <key>uploadSymbols</key>
    <true/>
    <key>compileBitcode</key>
    <false/>
</dict>
</plist>
EOF
}

# Check prerequisites
check_prerequisites() {
    print_info "Checking prerequisites..."

    # Check if Xcode is installed
    if ! command -v xcodebuild >/dev/null 2>&1; then
        print_error "xcodebuild not found. Please install Xcode."
        exit 1
    fi

    # Check if xcpretty is installed (optional but recommended)
    if ! command -v xcpretty >/dev/null 2>&1; then
        print_warning "xcpretty not installed. Output will be verbose."
        print_info "Install with: gem install xcpretty"
    fi

    print_success "Prerequisites check passed"
}

# Run prerequisite checks
check_prerequisites

# Run main build
main

exit 0
