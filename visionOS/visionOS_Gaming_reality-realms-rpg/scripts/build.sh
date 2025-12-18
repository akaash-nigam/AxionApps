#!/bin/bash
# Reality Realms RPG - Build Automation Script
# This script handles building the project for various targets

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script constants
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
BUILD_DIR="$PROJECT_ROOT/Build"
DERIVED_DATA_DIR="$BUILD_DIR/DerivedData"
ARCHIVES_DIR="$BUILD_DIR/Archives"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
LOG_FILE="$BUILD_DIR/logs/build_$TIMESTAMP.log"

# Build configuration
SCHEME="${SCHEME:-RealityRealms}"
CONFIGURATION="${CONFIGURATION:-Debug}"
BUILD_TARGET="${BUILD_TARGET:-simulator}"
CODE_SIGN_IDENTITY="${CODE_SIGN_IDENTITY:-}"
CODE_SIGNING_REQUIRED="${CODE_SIGNING_REQUIRED:-NO}"

# Helper functions
print_header() {
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}================================${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

# Initialize build environment
init_build_environment() {
    print_info "Initializing build environment..."

    mkdir -p "$BUILD_DIR"
    mkdir -p "$BUILD_DIR/logs"
    mkdir -p "$ARCHIVES_DIR"

    # Create log file
    touch "$LOG_FILE"
    echo "Build started at $(date)" >> "$LOG_FILE"
    echo "Scheme: $SCHEME" >> "$LOG_FILE"
    echo "Configuration: $CONFIGURATION" >> "$LOG_FILE"
    echo "Build Target: $BUILD_TARGET" >> "$LOG_FILE"
    echo "" >> "$LOG_FILE"

    print_success "Build environment initialized"
}

# Clean build artifacts
clean_build() {
    print_header "Cleaning Build Artifacts"

    print_info "Removing previous build artifacts..."

    rm -rf "$DERIVED_DATA_DIR"
    rm -rf "$BUILD_DIR/Build"
    rm -f "$LOG_FILE"

    xcodebuild clean \
        -scheme "$SCHEME" \
        -configuration "$CONFIGURATION" \
        -derivedDataPath "$DERIVED_DATA_DIR" \
        2>&1 | tee -a "$LOG_FILE" || true

    print_success "Clean build complete"
}

# Validate Xcode project
validate_project() {
    print_header "Validating Xcode Project"

    print_info "Validating project structure..."

    # Check project file exists
    if [ ! -d "$PROJECT_ROOT/RealityRealms.xcodeproj" ] && [ ! -f "$PROJECT_ROOT/Package.swift" ]; then
        print_error "Xcode project or Swift package not found"
        exit 1
    fi

    # List available schemes
    print_info "Available schemes:"
    xcodebuild -list -json 2>/dev/null | grep '"schemes"' || true

    print_success "Project validation complete"
}

# Build for visionOS Simulator
build_for_simulator() {
    print_header "Building for visionOS Simulator"

    local destination="platform=visionOS Simulator,name=Apple Vision Pro"

    print_info "Configuration: $CONFIGURATION"
    print_info "Destination: $destination"

    xcodebuild build \
        -scheme "$SCHEME" \
        -configuration "$CONFIGURATION" \
        -destination "$destination" \
        -derivedDataPath "$DERIVED_DATA_DIR" \
        CODE_SIGN_IDENTITY="$CODE_SIGN_IDENTITY" \
        CODE_SIGNING_REQUIRED="$CODE_SIGNING_REQUIRED" \
        2>&1 | tee -a "$LOG_FILE"

    if [ $? -eq 0 ]; then
        print_success "Simulator build completed successfully"

        # Archive build
        if [ "$CONFIGURATION" == "Release" ]; then
            archive_build "Simulator"
        fi
    else
        print_error "Simulator build failed"
        return 1
    fi
}

# Build for visionOS Device
build_for_device() {
    print_header "Building for visionOS Device"

    local destination="platform=visionOS,name=Apple Vision Pro"

    print_info "Configuration: $CONFIGURATION"
    print_info "Destination: $destination"

    xcodebuild build \
        -scheme "$SCHEME" \
        -configuration "$CONFIGURATION" \
        -destination "$destination" \
        -derivedDataPath "$DERIVED_DATA_DIR" \
        CODE_SIGN_IDENTITY="$CODE_SIGN_IDENTITY" \
        CODE_SIGNING_REQUIRED="$CODE_SIGNING_REQUIRED" \
        2>&1 | tee -a "$LOG_FILE" || true

    if [ $? -eq 0 ]; then
        print_success "Device build completed successfully"

        # Archive build
        if [ "$CONFIGURATION" == "Release" ]; then
            archive_build "Device"
        fi
    else
        print_warning "Device build failed (may require signing certificates)"
    fi
}

# Create app archive
create_archive() {
    print_header "Creating App Archive"

    local archive_path="$ARCHIVES_DIR/${SCHEME}-${CONFIGURATION}-$TIMESTAMP.xcarchive"

    print_info "Creating archive at: $archive_path"

    xcodebuild archive \
        -scheme "$SCHEME" \
        -configuration "$CONFIGURATION" \
        -archivePath "$archive_path" \
        -derivedDataPath "$DERIVED_DATA_DIR" \
        CODE_SIGN_IDENTITY="$CODE_SIGN_IDENTITY" \
        CODE_SIGNING_REQUIRED="$CODE_SIGNING_REQUIRED" \
        2>&1 | tee -a "$LOG_FILE"

    if [ $? -eq 0 ]; then
        print_success "Archive created successfully"
        print_info "Archive location: $archive_path"

        # Compress archive
        zip_archive "$archive_path"
    else
        print_error "Archive creation failed"
        return 1
    fi
}

# Archive build artifacts
archive_build() {
    local target="$1"
    local build_products="$DERIVED_DATA_DIR/Build/Products/${CONFIGURATION}-xros"

    if [ -d "$build_products" ]; then
        local archive_name="$ARCHIVES_DIR/RealityRealms-${target}-${CONFIGURATION}-$TIMESTAMP.zip"

        print_info "Archiving $target build..."
        cd "$DERIVED_DATA_DIR/Build/Products"
        zip -r "$archive_name" "${CONFIGURATION}-xros" > /dev/null

        if [ -f "$archive_name" ]; then
            local size=$(du -h "$archive_name" | awk '{print $1}')
            print_success "Archive created: ${archive_name##*/} (Size: $size)"
        fi
    fi
}

# Compress archive
zip_archive() {
    local archive_path="$1"
    local zip_file="${archive_path}.zip"

    print_info "Compressing archive..."
    zip -r "$zip_file" "$archive_path" > /dev/null 2>&1

    if [ -f "$zip_file" ]; then
        local size=$(du -h "$zip_file" | awk '{print $1}')
        print_success "Compressed archive created (Size: $size)"
    fi
}

# Analyze build
analyze_build() {
    print_header "Analyzing Build"

    print_info "Running static analysis..."

    xcodebuild analyze \
        -scheme "$SCHEME" \
        -configuration "$CONFIGURATION" \
        -destination "platform=visionOS Simulator,name=Apple Vision Pro" \
        -derivedDataPath "$DERIVED_DATA_DIR" \
        CODE_SIGN_IDENTITY="$CODE_SIGN_IDENTITY" \
        CODE_SIGNING_REQUIRED="$CODE_SIGNING_REQUIRED" \
        2>&1 | tee -a "$LOG_FILE" || true

    print_success "Analysis complete"
}

# Generate build report
generate_build_report() {
    print_header "Build Report"

    echo ""
    echo "Build Summary:"
    echo "  Scheme: $SCHEME"
    echo "  Configuration: $CONFIGURATION"
    echo "  Target: $BUILD_TARGET"
    echo "  Timestamp: $TIMESTAMP"
    echo ""

    echo "Output Locations:"
    echo "  Derived Data: $DERIVED_DATA_DIR"
    echo "  Archives: $ARCHIVES_DIR"
    echo "  Logs: $LOG_FILE"
    echo ""

    if [ -d "$ARCHIVES_DIR" ]; then
        echo "Generated Artifacts:"
        find "$ARCHIVES_DIR" -type f -newer "$BUILD_DIR" -exec ls -lh {} \; | awk '{print "  " $9 " (" $5 ")"}'
    fi

    echo ""
    echo "Build Performance:"
    if [ -f "$LOG_FILE" ]; then
        local duration=$(tail -20 "$LOG_FILE" | grep -o "[0-9]* seconds" | head -1 || echo "Unknown")
        echo "  Duration: $duration"
    fi

    print_success "Build completed at $(date)"
}

# Main build flow
main() {
    print_header "Reality Realms RPG - Build System"
    echo "Build Start: $(date)"
    echo ""

    init_build_environment
    echo ""

    validate_project
    echo ""

    # Perform clean build if requested
    if [ "$CLEAN_BUILD" == "true" ]; then
        clean_build
        echo ""
    fi

    # Run analysis if requested
    if [ "$ANALYZE" == "true" ]; then
        analyze_build
        echo ""
    fi

    # Build based on target
    case "$BUILD_TARGET" in
        simulator)
            build_for_simulator
            ;;
        device)
            build_for_device
            ;;
        all)
            build_for_simulator
            echo ""
            build_for_device
            ;;
        archive)
            create_archive
            ;;
        *)
            print_error "Unknown build target: $BUILD_TARGET"
            exit 1
            ;;
    esac

    echo ""

    generate_build_report

    print_success "Build system execution complete!"
}

# Parse command-line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --scheme)
            SCHEME="$2"
            shift 2
            ;;
        --configuration)
            CONFIGURATION="$2"
            shift 2
            ;;
        --target)
            BUILD_TARGET="$2"
            shift 2
            ;;
        --clean)
            CLEAN_BUILD="true"
            shift
            ;;
        --analyze)
            ANALYZE="true"
            shift
            ;;
        --help)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --scheme SCHEME              Build scheme (default: RealityRealms)"
            echo "  --configuration CONFIG       Debug or Release (default: Debug)"
            echo "  --target TARGET              Build target: simulator, device, all, archive (default: simulator)"
            echo "  --clean                      Perform clean build"
            echo "  --analyze                    Run static analysis"
            echo "  --help                       Show this help message"
            echo ""
            echo "Examples:"
            echo "  $0 --target simulator          # Build for simulator"
            echo "  $0 --target device             # Build for device"
            echo "  $0 --target archive --configuration Release  # Create release archive"
            echo "  $0 --clean --target all        # Clean and build for all targets"
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Run main if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
