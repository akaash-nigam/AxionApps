#!/bin/bash

# Test script for Retail Space Optimizer

set -e

echo "🧪 Running Retail Space Optimizer tests..."

cd RetailSpaceOptimizer

# Parse arguments
COVERAGE=false
SPECIFIC_TEST=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --coverage)
            COVERAGE=true
            shift
            ;;
        --test)
            SPECIFIC_TEST="$2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            echo "Usage: $0 [--coverage] [--test TestName]"
            exit 1
            ;;
    esac
done

# Build test command
TEST_CMD="xcodebuild test -scheme RetailSpaceOptimizer"

if [ "$COVERAGE" = true ]; then
    TEST_CMD="$TEST_CMD -enableCodeCoverage YES -resultBundlePath ./TestResults.xcresult"
fi

if [ -n "$SPECIFIC_TEST" ]; then
    TEST_CMD="$TEST_CMD -only-testing:$SPECIFIC_TEST"
else
    TEST_CMD="$TEST_CMD -only-testing:RetailSpaceOptimizerTests"
fi

# Run tests
echo "Running: $TEST_CMD"
eval $TEST_CMD

# Generate coverage report if requested
if [ "$COVERAGE" = true ]; then
    echo ""
    echo "📊 Generating coverage report..."
    xcrun xccov view --report ./TestResults.xcresult
    echo ""
    echo "Full coverage report saved to: ./TestResults.xcresult"
    echo "Open with: open ./TestResults.xcresult"
fi

echo ""
echo "✅ Tests completed successfully!"
