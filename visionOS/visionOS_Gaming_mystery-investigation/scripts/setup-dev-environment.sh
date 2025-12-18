#!/bin/bash

# Mystery Investigation - Development Environment Setup
# Sets up the development environment for new contributors

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🔍 Mystery Investigation - Dev Environment Setup${NC}"
echo "=================================================="
echo ""

# Check OS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo -e "${RED}Error: This script requires macOS${NC}"
    echo "Mystery Investigation requires Xcode and visionOS SDK which are macOS-only"
    exit 1
fi

echo -e "${GREEN}✓${NC} Running on macOS"

# Check macOS version
MACOS_VERSION=$(sw_vers -productVersion)
MACOS_MAJOR=$(echo "$MACOS_VERSION" | cut -d. -f1)

if [ "$MACOS_MAJOR" -lt 14 ]; then
    echo -e "${RED}Error: macOS 14.0+ (Sonoma) required${NC}"
    echo "Current version: $MACOS_VERSION"
    exit 1
fi

echo -e "${GREEN}✓${NC} macOS version: $MACOS_VERSION"

# Check for Xcode
if ! command -v xcodebuild &> /dev/null; then
    echo -e "${RED}✗${NC} Xcode not found"
    echo ""
    echo "Please install Xcode 16.0+ from the App Store:"
    echo "https://apps.apple.com/us/app/xcode/id497799835"
    exit 1
fi

XCODE_VERSION=$(xcodebuild -version | head -n 1 | awk '{print $2}')
echo -e "${GREEN}✓${NC} Xcode version: $XCODE_VERSION"

# Check for Git
if ! command -v git &> /dev/null; then
    echo -e "${RED}✗${NC} Git not found"
    echo "Installing Xcode Command Line Tools..."
    xcode-select --install
else
    echo -e "${GREEN}✓${NC} Git installed"
fi

# Check Git configuration
GIT_NAME=$(git config --global user.name || echo "")
GIT_EMAIL=$(git config --global user.email || echo "")

if [ -z "$GIT_NAME" ] || [ -z "$GIT_EMAIL" ]; then
    echo -e "${YELLOW}!${NC} Git not fully configured"
    echo ""
    read -p "Enter your name: " name
    read -p "Enter your email: " email
    git config --global user.name "$name"
    git config --global user.email "$email"
    echo -e "${GREEN}✓${NC} Git configured"
else
    echo -e "${GREEN}✓${NC} Git configured as: $GIT_NAME <$GIT_EMAIL>"
fi

# Check for recommended tools
echo ""
echo "Checking for recommended tools..."

# jq for JSON validation
if command -v jq &> /dev/null; then
    echo -e "${GREEN}✓${NC} jq installed"
else
    echo -e "${YELLOW}!${NC} jq not installed (recommended for JSON validation)"
    echo "  Install with: brew install jq"
fi

# Node.js for web development
if command -v node &> /dev/null; then
    NODE_VERSION=$(node --version)
    echo -e "${GREEN}✓${NC} Node.js installed ($NODE_VERSION)"
else
    echo -e "${YELLOW}!${NC} Node.js not installed (optional, for website development)"
    echo "  Install with: brew install node"
fi

# Python for scripts
if command -v python3 &> /dev/null; then
    PYTHON_VERSION=$(python3 --version | awk '{print $2}')
    echo -e "${GREEN}✓${NC} Python installed ($PYTHON_VERSION)"
else
    echo -e "${YELLOW}!${NC} Python not installed (optional, for utility scripts)"
fi

# Create necessary directories
echo ""
echo "Setting up project structure..."

mkdir -p MysteryInvestigation/Sources/App
mkdir -p MysteryInvestigation/Sources/Coordinators
mkdir -p MysteryInvestigation/Sources/Models
mkdir -p MysteryInvestigation/Sources/Managers
mkdir -p MysteryInvestigation/Sources/Components
mkdir -p MysteryInvestigation/Sources/Views
mkdir -p MysteryInvestigation/Tests/UnitTests
mkdir -p MysteryInvestigation/Tests/IntegrationTests
mkdir -p MysteryInvestigation/Resources/Assets.xcassets
mkdir -p MysteryInvestigation/Resources/RealityKitContent
mkdir -p MysteryInvestigation/Resources/Audio
mkdir -p cases
mkdir -p docs
mkdir -p marketing
mkdir -p scripts
mkdir -p website/images
mkdir -p website/css
mkdir -p website/js

echo -e "${GREEN}✓${NC} Project directories created"

# Make scripts executable
if [ -d "scripts" ]; then
    chmod +x scripts/*.sh 2>/dev/null || true
    echo -e "${GREEN}✓${NC} Scripts made executable"
fi

# Check for Xcode project
if [ ! -f "MysteryInvestigation/MysteryInvestigation.xcodeproj/project.pbxproj" ]; then
    echo -e "${YELLOW}!${NC} Xcode project not found"
    echo "  You'll need to create the Xcode project manually"
else
    echo -e "${GREEN}✓${NC} Xcode project found"
fi

# Summary
echo ""
echo "=================================================="
echo -e "${GREEN}✅ Development environment setup complete!${NC}"
echo ""
echo "Next steps:"
echo "1. Read DEVELOPER_ONBOARDING.md for detailed onboarding"
echo "2. Open MysteryInvestigation.xcodeproj in Xcode"
echo "3. Build the project (Cmd+B)"
echo "4. Run tests (Cmd+U)"
echo "5. Start contributing!"
echo ""
echo "Resources:"
echo "- Documentation: docs/"
echo "- Contributing Guide: CONTRIBUTING.md"
echo "- Code of Conduct: CODE_OF_CONDUCT.md"
echo ""
echo -e "${BLUE}Happy coding! 🔍✨${NC}"
