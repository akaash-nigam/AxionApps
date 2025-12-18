#!/bin/bash

# Deploy to App Store
# Usage: ./scripts/deploy-appstore.sh

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

cd "$PROJECT_DIR"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo "╔═══════════════════════════════════════╗"
echo "║  Spatial CRM - App Store Deployment  ║"
echo "╚═══════════════════════════════════════╝"
echo ""

# Confirmation
echo -e "${RED}⚠ WARNING: This will submit to App Store${NC}"
echo -e "${YELLOW}Are you sure you want to continue? (yes/no)${NC}"
read -r CONFIRM

if [ "$CONFIRM" != "yes" ]; then
    echo "Deployment cancelled"
    exit 0
fi

# 1. Check for clean git state
echo -e "${YELLOW}→${NC} Checking git state..."
if [[ -n $(git status -s) ]]; then
    echo -e "${RED}✗${NC} Git working directory is not clean"
    echo "Commit or stash changes before deploying"
    exit 1
fi
echo -e "${GREEN}✓${NC} Git working directory is clean"

# 2. Ensure on main branch
BRANCH=$(git rev-parse --abbrev-ref HEAD)
if [ "$BRANCH" != "main" ]; then
    echo -e "${RED}✗${NC} Not on main branch (currently on: $BRANCH)"
    echo "Switch to main branch before deploying to App Store"
    exit 1
fi
echo -e "${GREEN}✓${NC} On main branch"

# 3. Pull latest
echo -e "${YELLOW}→${NC} Pulling latest changes..."
git pull origin main
echo -e "${GREEN}✓${NC} Repository up to date"

# 4. Run all tests
echo -e "${YELLOW}→${NC} Running tests..."
swift test || {
    echo -e "${RED}✗${NC} Tests failed"
    exit 1
}
echo -e "${GREEN}✓${NC} All tests passed"

# 5. Get version info
VERSION=$(/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" SpatialCRM/Resources/Info.plist)
BUILD_NUMBER=$(/usr/libexec/PlistBuddy -c "Print CFBundleVersion" SpatialCRM/Resources/Info.plist)

echo ""
echo "Ready to deploy version $VERSION (build $BUILD_NUMBER)"
echo ""

# 6. Create git tag
TAG="v$VERSION-$BUILD_NUMBER"
echo -e "${YELLOW}→${NC} Creating git tag: $TAG"
git tag -a "$TAG" -m "Release $VERSION (build $BUILD_NUMBER)"
git push origin "$TAG"
echo -e "${GREEN}✓${NC} Git tag created and pushed"

# 7. Build and upload (using TestFlight script)
echo -e "${YELLOW}→${NC} Building and uploading..."
"$SCRIPT_DIR/deploy-testflight.sh" --skip-tests

echo ""
echo -e "${GREEN}✓✓✓ Successfully deployed to App Store Connect!${NC}"
echo ""
echo "Version: $VERSION ($BUILD_NUMBER)"
echo "Tag: $TAG"
echo ""
echo "Next steps:"
echo "1. Go to App Store Connect"
echo "2. Complete app information"
echo "3. Add screenshots and metadata"
echo "4. Submit for App Store review"
echo ""
