#!/bin/bash

################################################################################
# Test Runner Script for Wardrobe Consultant
#
# This script runs various test suites for the visionOS Wardrobe Consultant app.
#
# Usage:
#   ./scripts/run_tests.sh [test_type] [options]
#
# Test Types:
#   all             - Run all tests (unit, integration, ui)
#   unit            - Run unit tests only
#   integration     - Run integration tests only
#   ui              - Run UI tests only
#   performance     - Run performance tests only
#   accessibility   - Run accessibility tests only
#   quick           - Run unit and integration tests only (fast)
#
# Options:
#   --coverage      - Enable code coverage collection
#   --device NAME   - Specify device/simulator name (default: iPhone 15 Pro)
#   --parallel      - Enable parallel test execution
#   --verbose       - Enable verbose output
#   --clean         - Clean build before testing
#
# Examples:
#   ./scripts/run_tests.sh unit
#   ./scripts/run_tests.sh all --coverage
#   ./scripts/run_tests.sh ui --device "iPad Pro (12.9-inch)"
#   ./scripts/run_tests.sh quick --parallel --verbose
################################################################################

set -e  # Exit on error
set -o pipefail  # Catch errors in pipes

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default configuration
SCHEME="WardrobeConsultant"
DEFAULT_DEVICE="iPhone 15 Pro"
DEVICE="${DEFAULT_DEVICE}"
PLATFORM="iOS Simulator"
ENABLE_COVERAGE=false
PARALLEL=false
VERBOSE=false
CLEAN_BUILD=false

# Test type (default: all)
TEST_TYPE="${1:-all}"

# Parse command line arguments
shift || true
while [[ $# -gt 0 ]]; do
    case $1 in
        --coverage)
            ENABLE_COVERAGE=true
            shift
            ;;
        --device)
            DEVICE="$2"
            shift 2
            ;;
        --parallel)
            PARALLEL=true
            shift
            ;;
        --verbose)
            VERBOSE=true
            shift
            ;;
        --clean)
            CLEAN_BUILD=true
            shift
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            exit 1
            ;;
    esac
done

# Functions
print_header() {
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

print_info() {
    echo -e "${BLUE}ℹ ${NC}$1"
}

print_success() {
    echo -e "${GREEN}✓ ${NC}$1"
}

print_warning() {
    echo -e "${YELLOW}⚠ ${NC}$1"
}

print_error() {
    echo -e "${RED}✗ ${NC}$1"
}

# Build xcodebuild command
build_xcodebuild_command() {
    local test_target=$1
    local cmd="xcodebuild test"
    cmd="$cmd -scheme $SCHEME"
    cmd="$cmd -destination 'platform=$PLATFORM,name=$DEVICE'"
    cmd="$cmd -only-testing:$test_target"

    if [ "$ENABLE_COVERAGE" = true ]; then
        cmd="$cmd -enableCodeCoverage YES"
        cmd="$cmd -resultBundlePath TestResults/$test_target.xcresult"
    fi

    if [ "$PARALLEL" = true ]; then
        cmd="$cmd -parallel-testing-enabled YES"
        cmd="$cmd -maximum-parallel-testing-workers 4"
    fi

    if [ "$VERBOSE" = false ]; then
        cmd="$cmd -quiet"
    fi

    echo "$cmd"
}

# Clean build if requested
if [ "$CLEAN_BUILD" = true ]; then
    print_header "Cleaning Build Folder"
    xcodebuild clean -scheme "$SCHEME" -quiet
    print_success "Build folder cleaned"
fi

# Create TestResults directory if coverage is enabled
if [ "$ENABLE_COVERAGE" = true ]; then
    mkdir -p TestResults
fi

# Run tests based on type
case $TEST_TYPE in
    all)
        print_header "Running All Tests"
        print_info "Device: $DEVICE"
        print_info "Coverage: $ENABLE_COVERAGE"
        print_info "Parallel: $PARALLEL"
        echo ""

        # Run unit tests
        print_header "Unit Tests"
        CMD=$(build_xcodebuild_command "WardrobeConsultantTests")
        eval $CMD && print_success "Unit tests passed" || { print_error "Unit tests failed"; exit 1; }

        # Run integration tests
        print_header "Integration Tests"
        CMD=$(build_xcodebuild_command "WardrobeConsultantIntegrationTests")
        eval $CMD && print_success "Integration tests passed" || { print_error "Integration tests failed"; exit 1; }

        # Run UI tests
        print_header "UI Tests"
        CMD=$(build_xcodebuild_command "WardrobeConsultantUITests")
        eval $CMD && print_success "UI tests passed" || { print_error "UI tests failed"; exit 1; }

        print_success "All tests passed!"
        ;;

    unit)
        print_header "Running Unit Tests"
        print_info "Device: $DEVICE"
        CMD=$(build_xcodebuild_command "WardrobeConsultantTests")
        eval $CMD && print_success "Unit tests passed" || { print_error "Unit tests failed"; exit 1; }
        ;;

    integration)
        print_header "Running Integration Tests"
        print_info "Device: $DEVICE"
        CMD=$(build_xcodebuild_command "WardrobeConsultantIntegrationTests")
        eval $CMD && print_success "Integration tests passed" || { print_error "Integration tests failed"; exit 1; }
        ;;

    ui)
        print_header "Running UI Tests"
        print_info "Device: $DEVICE"
        print_warning "UI tests may take 5-10 minutes to complete"
        CMD=$(build_xcodebuild_command "WardrobeConsultantUITests")
        eval $CMD && print_success "UI tests passed" || { print_error "UI tests failed"; exit 1; }
        ;;

    performance)
        print_header "Running Performance Tests"
        print_info "Device: $DEVICE"
        print_warning "Performance tests require baseline establishment"
        CMD=$(build_xcodebuild_command "WardrobeConsultantPerformanceTests")
        eval $CMD && print_success "Performance tests passed" || { print_error "Performance tests failed"; exit 1; }
        ;;

    accessibility)
        print_header "Running Accessibility Tests"
        print_info "Device: $DEVICE"
        print_warning "Some accessibility tests require manual verification"
        CMD=$(build_xcodebuild_command "WardrobeConsultantAccessibilityTests")
        eval $CMD && print_success "Accessibility tests passed" || { print_error "Accessibility tests failed"; exit 1; }
        ;;

    quick)
        print_header "Running Quick Tests (Unit + Integration)"
        print_info "Device: $DEVICE"

        # Run unit tests
        print_header "Unit Tests"
        CMD=$(build_xcodebuild_command "WardrobeConsultantTests")
        eval $CMD && print_success "Unit tests passed" || { print_error "Unit tests failed"; exit 1; }

        # Run integration tests
        print_header "Integration Tests"
        CMD=$(build_xcodebuild_command "WardrobeConsultantIntegrationTests")
        eval $CMD && print_success "Integration tests passed" || { print_error "Integration tests failed"; exit 1; }

        print_success "Quick tests passed!"
        ;;

    *)
        print_error "Unknown test type: $TEST_TYPE"
        echo ""
        echo "Usage: $0 [test_type] [options]"
        echo ""
        echo "Test Types:"
        echo "  all             - Run all tests (unit, integration, ui)"
        echo "  unit            - Run unit tests only"
        echo "  integration     - Run integration tests only"
        echo "  ui              - Run UI tests only"
        echo "  performance     - Run performance tests only"
        echo "  accessibility   - Run accessibility tests only"
        echo "  quick           - Run unit and integration tests only (fast)"
        echo ""
        echo "Options:"
        echo "  --coverage      - Enable code coverage collection"
        echo "  --device NAME   - Specify device/simulator name"
        echo "  --parallel      - Enable parallel test execution"
        echo "  --verbose       - Enable verbose output"
        echo "  --clean         - Clean build before testing"
        exit 1
        ;;
esac

# Generate coverage report if enabled
if [ "$ENABLE_COVERAGE" = true ]; then
    print_header "Generating Coverage Report"
    ./scripts/generate_coverage.sh
fi

echo ""
print_success "Test run complete!"
echo ""
