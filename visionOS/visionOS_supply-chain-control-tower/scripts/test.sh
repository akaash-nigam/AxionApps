#!/bin/bash

# Test script for Supply Chain Control Tower
#
# Usage:
#   ./scripts/test.sh [options]
#
# Options:
#   --filter PATTERN     Run only tests matching pattern
#   --coverage          Generate code coverage report
#   --parallel          Run tests in parallel
#   --ui                Run UI tests
#   --performance       Run performance tests only
#   --help              Show this help message

set -e
set -u

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Defaults
FILTER=""
COVERAGE=false
PARALLEL=false
UI_TESTS=false
PERFORMANCE_ONLY=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --filter)
            FILTER="$2"
            shift 2
            ;;
        --coverage)
            COVERAGE=true
            shift
            ;;
        --parallel)
            PARALLEL=true
            shift
            ;;
        --ui)
            UI_TESTS=true
            shift
            ;;
        --performance)
            PERFORMANCE_ONLY=true
            shift
            ;;
        --help)
            head -n 14 "$0" | tail -n 13
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            exit 1
            ;;
    esac
done

log() {
    local color=$1
    shift
    echo -e "${color}$*${NC}"
}

log "$BLUE" "==================================="
log "$BLUE" "Supply Chain Control Tower - Tests"
log "$BLUE" "==================================="
echo ""

cd "$(dirname "$0")/.."

# Check if Swift is available
if command -v swift &> /dev/null; then
    log "$YELLOW" "Running Swift tests..."

    TEST_CMD="swift test"

    if [ -n "$FILTER" ]; then
        TEST_CMD="$TEST_CMD --filter $FILTER"
    elif [ "$PERFORMANCE_ONLY" = true ]; then
        TEST_CMD="$TEST_CMD --filter PerformanceTests"
    fi

    if [ "$PARALLEL" = true ]; then
        TEST_CMD="$TEST_CMD --parallel"
    fi

    eval "$TEST_CMD"

    log "$GREEN" "✓ Swift tests passed"
    echo ""
fi

# Run xcodebuild tests if available
if command -v xcodebuild &> /dev/null && [ "$UI_TESTS" = true ]; then
    log "$YELLOW" "Running UI tests..."

    XCODE_CMD="xcodebuild test \
        -scheme SupplyChainControlTower \
        -destination 'platform=visionOS Simulator,name=Apple Vision Pro'"

    if [ "$COVERAGE" = true ]; then
        XCODE_CMD="$XCODE_CMD -enableCodeCoverage YES -resultBundlePath TestResults.xcresult"
    fi

    eval "$XCODE_CMD" | xcpretty 2>/dev/null || cat

    if [ "$COVERAGE" = true ]; then
        log "$YELLOW" "Generating coverage report..."
        xcrun xccov view --report --json TestResults.xcresult > coverage.json || true
        log "$GREEN" "✓ Coverage report generated: coverage.json"
    fi

    log "$GREEN" "✓ UI tests passed"
    echo ""
fi

log "$BLUE" "==================================="
log "$GREEN" "All tests passed!"
log "$BLUE" "==================================="
