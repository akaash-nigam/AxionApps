#!/bin/bash

################################################################################
# CI Test Script for Wardrobe Consultant
#
# This script is optimized for CI/CD environments (GitHub Actions, Jenkins, etc.)
# It runs tests suitable for automated environments and generates reports.
#
# Usage:
#   ./scripts/ci_test.sh
#
# Environment Variables:
#   CI                  - Set to true in CI environment
#   CODECOV_TOKEN       - Token for Codecov upload (optional)
#   TEST_DEVICE         - Device name (default: iPhone 15 Pro)
#   SKIP_UI_TESTS       - Set to true to skip UI tests
################################################################################

set -e
set -o pipefail

# Colors (only if not in CI)
if [ -z "$CI" ]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    NC='\033[0m'
else
    RED=''
    GREEN=''
    YELLOW=''
    BLUE=''
    NC=''
fi

# Configuration
SCHEME="WardrobeConsultant"
DEVICE="${TEST_DEVICE:-iPhone 15 Pro}"
SKIP_UI="${SKIP_UI_TESTS:-false}"

print_header() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "$1"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
}

print_info() {
    echo "ℹ️  $1"
}

print_success() {
    echo "✅ $1"
}

print_error() {
    echo "❌ $1"
}

# Start
print_header "CI Test Run - Wardrobe Consultant"
print_info "Device: $DEVICE"
print_info "Skip UI Tests: $SKIP_UI"
echo ""

# Create results directory
mkdir -p TestResults
mkdir -p CoverageReports

# Clean build
print_header "Cleaning Build"
xcodebuild clean -scheme "$SCHEME" -quiet
print_success "Build cleaned"

# Build for testing
print_header "Building for Testing"
xcodebuild build-for-testing \
    -scheme "$SCHEME" \
    -destination "platform=iOS Simulator,name=$DEVICE" \
    -quiet

print_success "Build completed"

# Run unit tests
print_header "Running Unit Tests"
xcodebuild test-without-building \
    -scheme "$SCHEME" \
    -destination "platform=iOS Simulator,name=$DEVICE" \
    -only-testing:WardrobeConsultantTests \
    -enableCodeCoverage YES \
    -resultBundlePath TestResults/unit.xcresult \
    -parallel-testing-enabled YES \
    | tee TestResults/unit_tests.log

UNIT_EXIT_CODE=$?

if [ $UNIT_EXIT_CODE -eq 0 ]; then
    print_success "Unit tests passed"
else
    print_error "Unit tests failed"
    exit $UNIT_EXIT_CODE
fi

# Run integration tests
print_header "Running Integration Tests"
xcodebuild test-without-building \
    -scheme "$SCHEME" \
    -destination "platform=iOS Simulator,name=$DEVICE" \
    -only-testing:WardrobeConsultantIntegrationTests \
    -enableCodeCoverage YES \
    -resultBundlePath TestResults/integration.xcresult \
    -parallel-testing-enabled YES \
    | tee TestResults/integration_tests.log

INTEGRATION_EXIT_CODE=$?

if [ $INTEGRATION_EXIT_CODE -eq 0 ]; then
    print_success "Integration tests passed"
else
    print_error "Integration tests failed"
    exit $INTEGRATION_EXIT_CODE
fi

# Run UI tests (if not skipped)
if [ "$SKIP_UI" = false ]; then
    print_header "Running UI Tests"
    xcodebuild test-without-building \
        -scheme "$SCHEME" \
        -destination "platform=iOS Simulator,name=$DEVICE" \
        -only-testing:WardrobeConsultantUITests \
        -resultBundlePath TestResults/ui.xcresult \
        | tee TestResults/ui_tests.log

    UI_EXIT_CODE=$?

    if [ $UI_EXIT_CODE -eq 0 ]; then
        print_success "UI tests passed"
    else
        print_error "UI tests failed"
        exit $UI_EXIT_CODE
    fi
else
    print_info "Skipping UI tests (SKIP_UI_TESTS=true)"
fi

# Generate coverage report
print_header "Generating Coverage Report"

# Find most recent xcresult
XCRESULT=$(find TestResults -name "*.xcresult" -type d | head -n 1)

if [ -n "$XCRESULT" ]; then
    # Generate text report
    xcrun xccov view --report "$XCRESULT" > CoverageReports/coverage.txt

    # Generate JSON report
    xcrun xccov view --report --json "$XCRESULT" > CoverageReports/coverage.json

    # Extract coverage percentage
    COVERAGE=$(xcrun xccov view --report "$XCRESULT" | grep -E "^\s+$SCHEME" | awk '{print $2}')

    if [ -n "$COVERAGE" ]; then
        print_success "Total Coverage: $COVERAGE"
        echo "$COVERAGE" > CoverageReports/coverage_percentage.txt
    fi

    # Display summary
    echo ""
    echo "Coverage Summary:"
    xcrun xccov view --report "$XCRESULT" | grep -E "^\s+[0-9]" | head -10
    echo ""
else
    print_error "No coverage data found"
fi

# Upload to Codecov (if token provided)
if [ -n "$CODECOV_TOKEN" ]; then
    print_header "Uploading Coverage to Codecov"

    if command -v codecov &> /dev/null; then
        codecov -t "$CODECOV_TOKEN" -X gcov -X xcode
        print_success "Coverage uploaded"
    else
        print_info "codecov CLI not found, skipping upload"
    fi
fi

# Generate test summary
print_header "Test Summary"

echo "Test Results:"
echo "  Unit Tests:        $([ $UNIT_EXIT_CODE -eq 0 ] && echo "✅ PASSED" || echo "❌ FAILED")"
echo "  Integration Tests: $([ $INTEGRATION_EXIT_CODE -eq 0 ] && echo "✅ PASSED" || echo "❌ FAILED")"
if [ "$SKIP_UI" = false ]; then
    echo "  UI Tests:          $([ $UI_EXIT_CODE -eq 0 ] && echo "✅ PASSED" || echo "❌ FAILED")"
fi
echo ""

if [ -n "$COVERAGE" ]; then
    echo "Code Coverage: $COVERAGE"
    echo ""
fi

# Create artifacts directory for CI
mkdir -p artifacts
cp -R TestResults artifacts/
cp -R CoverageReports artifacts/

print_success "All CI tests completed successfully!"
print_info "Artifacts saved to: artifacts/"

exit 0
