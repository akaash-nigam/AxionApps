#!/bin/bash

# Setup script for Retail Space Optimizer development environment

set -e

echo "🚀 Setting up Retail Space Optimizer development environment..."

# Check macOS version
if [[ $(sw_vers -productVersion) < "14.5" ]]; then
    echo "❌ Error: macOS 14.5 or later is required"
    exit 1
fi

# Check Xcode installation
if ! command -v xcodebuild &> /dev/null; then
    echo "❌ Error: Xcode is not installed"
    echo "Please install Xcode 16.0+ from the App Store"
    exit 1
fi

# Check Xcode version
XCODE_VERSION=$(xcodebuild -version | head -n 1 | awk '{print $2}')
if [[ $(echo "$XCODE_VERSION < 16.0" | bc) -eq 1 ]]; then
    echo "❌ Error: Xcode 16.0 or later is required (found $XCODE_VERSION)"
    exit 1
fi

echo "✅ Xcode $XCODE_VERSION detected"

# Check visionOS SDK
if ! xcodebuild -showsdks | grep -q "visionOS"; then
    echo "❌ Error: visionOS SDK not found"
    echo "Please install visionOS SDK via Xcode Settings > Platforms"
    exit 1
fi

echo "✅ visionOS SDK found"

# Install command line tools if needed
if ! xcode-select -p &> /dev/null; then
    echo "Installing Command Line Tools..."
    xcode-select --install
fi

# Install SwiftLint (optional but recommended)
if ! command -v swiftlint &> /dev/null; then
    echo "📦 Installing SwiftLint..."
    if command -v brew &> /dev/null; then
        brew install swiftlint
        echo "✅ SwiftLint installed"
    else
        echo "⚠️  Homebrew not found. Skipping SwiftLint installation."
        echo "   To install SwiftLint manually, visit: https://github.com/realm/SwiftLint"
    fi
else
    echo "✅ SwiftLint already installed"
fi

# Check Git
if ! command -v git &> /dev/null; then
    echo "❌ Error: Git is not installed"
    exit 1
fi

echo "✅ Git detected"

# Configure git hooks (optional)
if [ -d ".git" ]; then
    echo "📝 Setting up git hooks..."

    # Pre-commit hook
    cat > .git/hooks/pre-commit << 'EOF'
#!/bin/bash
# Pre-commit hook for Retail Space Optimizer

# Run SwiftLint if available
if command -v swiftlint &> /dev/null; then
    swiftlint lint --quiet
    if [ $? -ne 0 ]; then
        echo "❌ SwiftLint failed. Please fix the issues before committing."
        exit 1
    fi
fi

echo "✅ Pre-commit checks passed"
EOF

    chmod +x .git/hooks/pre-commit
    echo "✅ Git hooks configured"
fi

# Create local configuration file
if [ ! -f "RetailSpaceOptimizer/RetailSpaceOptimizer/Configuration/Local.xcconfig" ]; then
    mkdir -p RetailSpaceOptimizer/RetailSpaceOptimizer/Configuration
    cat > RetailSpaceOptimizer/RetailSpaceOptimizer/Configuration/Local.xcconfig << EOF
// Local development configuration
// This file is git-ignored and safe for local settings

API_URL = http://localhost:8080/api/v1
USE_MOCK_DATA = YES
LOG_LEVEL = debug
EOF
    echo "✅ Local configuration created"
fi

# Open project in Xcode
echo ""
echo "✨ Setup complete!"
echo ""
echo "Next steps:"
echo "1. Open the project: open RetailSpaceOptimizer/RetailSpaceOptimizer.xcodeproj"
echo "2. Select visionOS Simulator or Vision Pro device"
echo "3. Press Cmd+R to build and run"
echo ""
echo "Optional:"
echo "- Run tests: ./scripts/test.sh"
echo "- Build release: ./scripts/build.sh --release"
echo ""

# Ask if user wants to open Xcode
read -p "Would you like to open the project in Xcode now? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    open RetailSpaceOptimizer/RetailSpaceOptimizer.xcodeproj
fi
