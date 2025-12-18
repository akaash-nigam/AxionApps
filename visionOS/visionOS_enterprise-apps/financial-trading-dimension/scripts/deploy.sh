#!/bin/bash

# =============================================================================
# Financial Trading Dimension - Deployment Script
# =============================================================================
# Automates deployment to TestFlight and App Store
# Usage: ./scripts/deploy.sh [testflight|appstore] [version]
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
BUILD_DIR="build"
ARCHIVE_PATH="$BUILD_DIR/${PROJECT_NAME}.xcarchive"
EXPORT_PATH="$BUILD_DIR/export"
IPA_PATH="$EXPORT_PATH/${PROJECT_NAME}.ipa"

# Parse arguments
DEPLOY_TARGET="${1:-testflight}"  # testflight or appstore
VERSION="${2:-}"

# Validate target
if [ "$DEPLOY_TARGET" != "testflight" ] && [ "$DEPLOY_TARGET" != "appstore" ]; then
    echo -e "${RED}Error: Invalid target '$DEPLOY_TARGET'. Use 'testflight' or 'appstore'${NC}"
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

# Main deployment process
main() {
    print_header "Financial Trading Dimension Deployment"

    print_info "Target: $DEPLOY_TARGET"
    if [ -n "$VERSION" ]; then
        print_info "Version: $VERSION"
    fi

    # Step 1: Prerequisites
    print_header "Step 1: Checking Prerequisites"
    check_prerequisites

    # Step 2: Version Management
    if [ -n "$VERSION" ]; then
        print_header "Step 2: Updating Version"
        update_version "$VERSION"
    else
        print_header "Step 2: Version Check"
        print_current_version
    fi

    # Step 3: Build
    print_header "Step 3: Building Release Version"
    build_release

    # Step 4: Run Tests
    print_header "Step 4: Running Tests"
    run_tests

    # Step 5: Create Archive
    print_header "Step 5: Creating Archive"
    create_archive

    # Step 6: Export IPA
    print_header "Step 6: Exporting IPA"
    export_ipa

    # Step 7: Validate
    print_header "Step 7: Validating Build"
    validate_build

    # Step 8: Upload
    print_header "Step 8: Uploading to $DEPLOY_TARGET"
    upload_build

    # Step 9: Tag Release
    if [ "$DEPLOY_TARGET" = "appstore" ]; then
        print_header "Step 9: Tagging Release"
        tag_release
    fi

    print_header "Deployment Completed Successfully!"
    print_success "Build uploaded to $DEPLOY_TARGET"

    # Post-deployment actions
    post_deployment_actions
}

check_prerequisites() {
    # Check xcodebuild
    if ! command -v xcodebuild >/dev/null 2>&1; then
        print_error "xcodebuild not found. Please install Xcode."
        exit 1
    fi

    # Check altool (for uploads) or xcrun
    if ! command -v xcrun >/dev/null 2>&1; then
        print_error "xcrun not found. Please install Xcode Command Line Tools."
        exit 1
    fi

    # Check git
    if ! command -v git >/dev/null 2>&1; then
        print_error "git not found. Please install git."
        exit 1
    fi

    # Check if we're on main branch for App Store
    if [ "$DEPLOY_TARGET" = "appstore" ]; then
        CURRENT_BRANCH=$(git branch --show-current)
        if [ "$CURRENT_BRANCH" != "main" ]; then
            print_error "Must be on main branch for App Store deployment. Currently on: $CURRENT_BRANCH"
            exit 1
        fi
    fi

    # Check for uncommitted changes
    if [ -n "$(git status --porcelain)" ]; then
        print_warning "You have uncommitted changes."
        read -p "Continue anyway? (y/n) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi

    # Check for .env file with credentials
    if [ ! -f ".env" ]; then
        print_warning ".env file not found. Will use environment variables."
    else
        source .env
    fi

    # Verify required environment variables
    if [ -z "${APPLE_ID:-}" ]; then
        print_error "APPLE_ID environment variable not set"
        exit 1
    fi

    if [ -z "${APP_SPECIFIC_PASSWORD:-}" ]; then
        print_error "APP_SPECIFIC_PASSWORD environment variable not set"
        exit 1
    fi

    if [ -z "${TEAM_ID:-}" ]; then
        print_error "TEAM_ID environment variable not set"
        exit 1
    fi

    print_success "Prerequisites check passed"
}

print_current_version() {
    # Get current version and build from Info.plist
    INFO_PLIST="FinancialTradingDimension/Info.plist"

    if [ -f "$INFO_PLIST" ]; then
        VERSION_NUMBER=$(/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" "$INFO_PLIST")
        BUILD_NUMBER=$(/usr/libexec/PlistBuddy -c "Print CFBundleVersion" "$INFO_PLIST")
        print_info "Current Version: $VERSION_NUMBER ($BUILD_NUMBER)"
    else
        print_warning "Info.plist not found. Cannot determine version."
    fi
}

update_version() {
    local new_version="$1"
    INFO_PLIST="FinancialTradingDimension/Info.plist"

    if [ -f "$INFO_PLIST" ]; then
        # Update version
        /usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString $new_version" "$INFO_PLIST"

        # Increment build number
        BUILD_NUMBER=$(/usr/libexec/PlistBuddy -c "Print CFBundleVersion" "$INFO_PLIST")
        NEW_BUILD_NUMBER=$((BUILD_NUMBER + 1))
        /usr/libexec/PlistBuddy -c "Set :CFBundleVersion $NEW_BUILD_NUMBER" "$INFO_PLIST"

        print_success "Updated version to $new_version ($NEW_BUILD_NUMBER)"

        # Commit version change
        git add "$INFO_PLIST"
        git commit -m "chore: bump version to $new_version ($NEW_BUILD_NUMBER)" || true
    else
        print_error "Info.plist not found"
        exit 1
    fi
}

build_release() {
    print_info "Building release configuration..."

    # Call the build script
    if [ -f "scripts/build.sh" ]; then
        ./scripts/build.sh release device
    else
        print_error "Build script not found"
        exit 1
    fi

    print_success "Build completed"
}

run_tests() {
    print_info "Running full test suite..."

    xcodebuild test \
        -scheme "$SCHEME_NAME" \
        -configuration Release \
        -destination 'platform=visionOS Simulator,name=Apple Vision Pro' \
        -enableCodeCoverage YES \
        | xcpretty || exit 1

    print_success "All tests passed"
}

create_archive() {
    print_info "Creating archive..."

    mkdir -p "$BUILD_DIR"

    xcodebuild archive \
        -scheme "$SCHEME_NAME" \
        -configuration Release \
        -archivePath "$ARCHIVE_PATH" \
        -destination 'generic/platform=visionOS' \
        CODE_SIGN_STYLE=Automatic \
        DEVELOPMENT_TEAM="$TEAM_ID" \
        | xcpretty || exit 1

    print_success "Archive created: $ARCHIVE_PATH"
}

export_ipa() {
    print_info "Exporting IPA..."

    mkdir -p "$EXPORT_PATH"

    # Create export options
    create_export_options_plist

    xcodebuild -exportArchive \
        -archivePath "$ARCHIVE_PATH" \
        -exportPath "$EXPORT_PATH" \
        -exportOptionsPlist ExportOptions.plist \
        | xcpretty || exit 1

    print_success "IPA exported to: $IPA_PATH"
}

create_export_options_plist() {
    local method="app-store"

    cat > ExportOptions.plist <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>$method</string>
    <key>teamID</key>
    <string>$TEAM_ID</string>
    <key>uploadBitcode</key>
    <false/>
    <key>uploadSymbols</key>
    <true/>
    <key>compileBitcode</key>
    <false/>
    <key>signingStyle</key>
    <string>automatic</string>
    <key>destination</key>
    <string>upload</string>
</dict>
</plist>
EOF
}

validate_build() {
    print_info "Validating build with App Store..."

    xcrun altool --validate-app \
        -f "$IPA_PATH" \
        -t visionos \
        -u "$APPLE_ID" \
        -p "$APP_SPECIFIC_PASSWORD" \
        --team-id "$TEAM_ID" \
        2>&1 | tee "$BUILD_DIR/validation.log"

    if [ ${PIPESTATUS[0]} -eq 0 ]; then
        print_success "Validation passed"
    else
        print_error "Validation failed. Check $BUILD_DIR/validation.log"
        exit 1
    fi
}

upload_build() {
    print_info "Uploading to App Store Connect..."

    xcrun altool --upload-app \
        -f "$IPA_PATH" \
        -t visionos \
        -u "$APPLE_ID" \
        -p "$APP_SPECIFIC_PASSWORD" \
        --team-id "$TEAM_ID" \
        2>&1 | tee "$BUILD_DIR/upload.log"

    if [ ${PIPESTATUS[0]} -eq 0 ]; then
        print_success "Upload completed successfully"
    else
        print_error "Upload failed. Check $BUILD_DIR/upload.log"
        exit 1
    fi
}

tag_release() {
    INFO_PLIST="FinancialTradingDimension/Info.plist"
    VERSION_NUMBER=$(/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" "$INFO_PLIST")
    BUILD_NUMBER=$(/usr/libexec/PlistBuddy -c "Print CFBundleVersion" "$INFO_PLIST")

    TAG_NAME="v$VERSION_NUMBER"

    print_info "Creating git tag: $TAG_NAME"

    # Create annotated tag
    git tag -a "$TAG_NAME" -m "Release version $VERSION_NUMBER (build $BUILD_NUMBER)"

    # Push tag to remote
    print_info "Pushing tag to remote..."
    git push origin "$TAG_NAME"

    print_success "Tag created and pushed: $TAG_NAME"
}

post_deployment_actions() {
    print_header "Post-Deployment Actions"

    # Update CHANGELOG
    print_info "Remember to update CHANGELOG.md"

    # TestFlight specific
    if [ "$DEPLOY_TARGET" = "testflight" ]; then
        print_info "Next steps:"
        print_info "1. Go to App Store Connect"
        print_info "2. Add 'What to Test' notes"
        print_info "3. Select testers or groups"
        print_info "4. Submit for review (if external testing)"
    fi

    # App Store specific
    if [ "$DEPLOY_TARGET" = "appstore" ]; then
        print_info "Next steps:"
        print_info "1. Go to App Store Connect"
        print_info "2. Select the build for this version"
        print_info "3. Fill in 'What's New' release notes"
        print_info "4. Submit for review"
        print_info "5. Monitor review status"
    fi

    # Create release notes template
    create_release_notes_template
}

create_release_notes_template() {
    INFO_PLIST="FinancialTradingDimension/Info.plist"
    VERSION_NUMBER=$(/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" "$INFO_PLIST")

    NOTES_FILE="$BUILD_DIR/release-notes-$VERSION_NUMBER.md"

    cat > "$NOTES_FILE" <<EOF
# Release Notes - Version $VERSION_NUMBER

## What's New

- [ ] Feature 1
- [ ] Feature 2
- [ ] Feature 3

## Improvements

- [ ] Improvement 1
- [ ] Improvement 2

## Bug Fixes

- [ ] Bug fix 1
- [ ] Bug fix 2

## Known Issues

- [ ] Known issue 1 (if any)

## Testing Notes (TestFlight)

What to test in this build:

1. Test scenario 1
2. Test scenario 2
3. Test scenario 3

## Localization

- [ ] English
- [ ] Spanish
- [ ] French
- [ ] German
- [ ] Japanese
- [ ] Chinese (Simplified)

## Compatibility

- visionOS 2.0 or later
- Apple Vision Pro

## Support

For issues, contact: support@financialtradingdimension.com
EOF

    print_success "Release notes template created: $NOTES_FILE"
}

# Rollback function (in case of issues)
rollback() {
    print_warning "Rolling back..."

    # Revert version changes
    git reset --hard HEAD~1

    # Remove tag if created
    if [ "$DEPLOY_TARGET" = "appstore" ]; then
        INFO_PLIST="FinancialTradingDimension/Info.plist"
        VERSION_NUMBER=$(/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" "$INFO_PLIST")
        TAG_NAME="v$VERSION_NUMBER"

        git tag -d "$TAG_NAME" 2>/dev/null || true
        git push origin ":refs/tags/$TAG_NAME" 2>/dev/null || true
    fi

    print_warning "Rollback completed"
}

# Set up trap for cleanup on error
trap 'print_error "Deployment failed! Check logs for details."; rollback' ERR

# Run main deployment
main

exit 0
