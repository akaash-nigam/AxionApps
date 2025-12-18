#!/bin/bash
# Pre-commit hook for Tactical Team Shooters
# Install: cp scripts/pre-commit-hook.sh .git/hooks/pre-commit && chmod +x .git/hooks/pre-commit

set -e

echo "🚀 Running pre-commit checks..."

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if SwiftLint is installed
if ! command -v swiftlint &> /dev/null; then
    echo -e "${YELLOW}⚠️  SwiftLint not installed. Skipping lint check.${NC}"
    echo "Install with: brew install swiftlint"
else
    echo "🔍 Running SwiftLint..."
    if swiftlint lint --quiet; then
        echo -e "${GREEN}✓ SwiftLint passed${NC}"
    else
        echo -e "${RED}✗ SwiftLint failed${NC}"
        echo "Fix issues or run: swiftlint --fix"
        exit 1
    fi
fi

# Check for debugging code
echo "🔍 Checking for debugging code..."
if git diff --cached --name-only | grep "\.swift$" | xargs grep -n "print(" 2>/dev/null; then
    echo -e "${YELLOW}⚠️  Warning: Found print() statements${NC}"
    read -p "Continue anyway? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Check for TODOs in committed code
echo "🔍 Checking for TODOs..."
if git diff --cached --name-only | grep "\.swift$" | xargs grep -n "TODO\|FIXME" 2>/dev/null; then
    echo -e "${YELLOW}ℹ️  Found TODO/FIXME comments${NC}"
fi

# Check for secrets/API keys
echo "🔒 Checking for secrets..."
if git diff --cached --name-only | xargs grep -i "api_key\|password\|secret" 2>/dev/null; then
    echo -e "${RED}✗ Possible secrets detected!${NC}"
    echo "Do not commit API keys or passwords"
    exit 1
fi

# Run tests
if command -v swift &> /dev/null; then
    echo "🧪 Running tests..."
    if swift test; then
        echo -e "${GREEN}✓ Tests passed${NC}"
    else
        echo -e "${RED}✗ Tests failed${NC}"
        exit 1
    fi
else
    echo -e "${YELLOW}⚠️  Swift not available. Skipping tests.${NC}"
fi

echo -e "${GREEN}✓ All pre-commit checks passed!${NC}"
