#!/bin/bash

# Deploy to TestFlight
# Usage: ./scripts/deploy-testflight.sh [--skip-tests]

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

cd "$PROJECT_DIR"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo "╔════════════════════════════════════════╗"
echo "║  Spatial CRM - TestFlight Deployment  ║"
echo "╚════════════════════════════════════════╝"
echo ""

# Parse arguments
SKIP_TESTS=false
for arg in "$@"; do
  case $arg in
    --skip-tests)
      SKIP_TESTS=true
      shift
      ;;
  esac
done

# 1. Check environment
echo -e "${YELLOW}→${NC} Checking environment..."
if ! command -v xcodebuild &> /dev/null; then
    echo -e "${RED}✗${NC} Xcode not found"
    exit 1
fi
echo -e "${GREEN}✓${NC} Xcode found"

# 2. Run tests (unless skipped)
if [ "$SKIP_TESTS" = false ]; then
    echo -e "${YELLOW}→${NC} Running tests..."
    swift test || {
        echo -e "${RED}✗${NC} Tests failed"
        exit 1
    }
    echo -e "${GREEN}✓${NC} All tests passed"
else
    echo -e "${YELLOW}⚠${NC} Skipping tests"
fi

# 3. Increment build number
echo -e "${YELLOW}→${NC} Incrementing build number..."
BUILD_NUMBER=$(($(date +%Y%m%d)$(git rev-list --count HEAD)))
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $BUILD_NUMBER" SpatialCRM/Resources/Info.plist
echo -e "${GREEN}✓${NC} Build number: $BUILD_NUMBER"

# 4. Get version number
VERSION=$(/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" SpatialCRM/Resources/Info.plist)
echo -e "${GREEN}✓${NC} Version: $VERSION"

# 5. Build archive
echo -e "${YELLOW}→${NC} Building archive..."
ARCHIVE_PATH="$PROJECT_DIR/build/SpatialCRM.xcarchive"
xcodebuild \
  -scheme SpatialCRM \
  -sdk visionos \
  -configuration Release \
  -archivePath "$ARCHIVE_PATH" \
  archive \
  || {
    echo -e "${RED}✗${NC} Archive failed"
    exit 1
  }
echo -e "${GREEN}✓${NC} Archive created"

# 6. Export IPA
echo -e "${YELLOW}→${NC} Exporting IPA..."
EXPORT_PATH="$PROJECT_DIR/build/export"
xcodebuild \
  -exportArchive \
  -archivePath "$ARCHIVE_PATH" \
  -exportOptionsPlist exportOptions.plist \
  -exportPath "$EXPORT_PATH" \
  || {
    echo -e "${RED}✗${NC} Export failed"
    exit 1
  }
echo -e "${GREEN}✓${NC} IPA exported"

# 7. Validate app
echo -e "${YELLOW}→${NC} Validating app..."
xcrun altool \
  --validate-app \
  -f "$EXPORT_PATH/SpatialCRM.ipa" \
  -t ios \
  --apiKey "$APP_STORE_CONNECT_API_KEY_ID" \
  --apiIssuer "$APP_STORE_CONNECT_ISSUER_ID" \
  || {
    echo -e "${RED}✗${NC} Validation failed"
    exit 1
  }
echo -e "${GREEN}✓${NC} App validated"

# 8. Upload to TestFlight
echo -e "${YELLOW}→${NC} Uploading to TestFlight..."
xcrun altool \
  --upload-app \
  -f "$EXPORT_PATH/SpatialCRM.ipa" \
  -t ios \
  --apiKey "$APP_STORE_CONNECT_API_KEY_ID" \
  --apiIssuer "$APP_STORE_CONNECT_ISSUER_ID" \
  || {
    echo -e "${RED}✗${NC} Upload failed"
    exit 1
  }

echo ""
echo -e "${GREEN}✓✓✓ Successfully deployed to TestFlight!${NC}"
echo ""
echo "Version: $VERSION ($BUILD_NUMBER)"
echo ""
echo "Next steps:"
echo "1. Go to App Store Connect"
echo "2. Add release notes"
echo "3. Submit for review or select testers"
echo ""

# Cleanup
rm -rf "$ARCHIVE_PATH"
rm -rf "$EXPORT_PATH"

echo "Build artifacts cleaned up"
