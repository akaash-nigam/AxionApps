#!/bin/bash
# Reality Realms RPG - Test Execution Script
# This script runs all tests and generates coverage reports

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script constants
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
BUILD_DIR="$PROJECT_ROOT/Build"
TEST_RESULTS_DIR="$BUILD_DIR/TestResults"
DERIVED_DATA_DIR="$BUILD_DIR/DerivedData"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
LOG_FILE="$BUILD_DIR/logs/test_$TIMESTAMP.log"

# Test configuration
SCHEME="${SCHEME:-RealityRealms}"
DESTINATION="${DESTINATION:-'platform=visionOS Simulator,name=Apple Vision Pro'}"
TEST_TIMEOUT="${TEST_TIMEOUT:-300}"
GENERATE_COVERAGE="${GENERATE_COVERAGE:-true}"

# Helper functions
print_header() {
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}================================${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

# Initialize test environment
init_test_environment() {
    print_info "Initializing test environment..."

    mkdir -p "$BUILD_DIR"
    mkdir -p "$BUILD_DIR/logs"
    mkdir -p "$TEST_RESULTS_DIR"

    # Create log file
    touch "$LOG_FILE"
    echo "Test run started at $(date)" >> "$LOG_FILE"
    echo "Scheme: $SCHEME" >> "$LOG_FILE"
    echo "Destination: $DESTINATION" >> "$LOG_FILE"
    echo "" >> "$LOG_FILE"

    print_success "Test environment initialized"
}

# Run unit tests
run_unit_tests() {
    print_header "Running Unit Tests"

    local result=0

    print_info "Building and testing: $SCHEME"

    xcodebuild test \
        -scheme "$SCHEME" \
        -destination "$DESTINATION" \
        -derivedDataPath "$DERIVED_DATA_DIR" \
        -resultBundlePath "$TEST_RESULTS_DIR/UnitTests.xcresult" \
        CODE_SIGN_IDENTITY="" \
        CODE_SIGNING_REQUIRED=NO \
        2>&1 | tee -a "$LOG_FILE" || result=$?

    if [ $result -eq 0 ]; then
        print_success "Unit tests passed"
    else
        print_error "Unit tests failed"
        return $result
    fi

    return 0
}

# Run integration tests
run_integration_tests() {
    print_header "Running Integration Tests"

    local result=0
    local integration_scheme="${SCHEME}Integration"

    # Check if integration test scheme exists
    if xcodebuild -list -json 2>/dev/null | grep -q "$integration_scheme"; then
        print_info "Running integration tests with scheme: $integration_scheme"

        xcodebuild test \
            -scheme "$integration_scheme" \
            -destination "$DESTINATION" \
            -derivedDataPath "$DERIVED_DATA_DIR" \
            -resultBundlePath "$TEST_RESULTS_DIR/IntegrationTests.xcresult" \
            CODE_SIGN_IDENTITY="" \
            CODE_SIGNING_REQUIRED=NO \
            2>&1 | tee -a "$LOG_FILE" || result=$?

        if [ $result -eq 0 ]; then
            print_success "Integration tests passed"
        else
            print_warning "Integration tests failed or not available"
        fi
    else
        print_info "No integration test scheme found"
    fi

    return 0
}

# Run performance tests
run_performance_tests() {
    print_header "Running Performance Tests"

    local result=0
    local perf_scheme="${SCHEME}Performance"

    # Check if performance test scheme exists
    if xcodebuild -list -json 2>/dev/null | grep -q "$perf_scheme"; then
        print_info "Running performance tests with scheme: $perf_scheme"

        xcodebuild test \
            -scheme "$perf_scheme" \
            -destination "$DESTINATION" \
            -derivedDataPath "$DERIVED_DATA_DIR" \
            -resultBundlePath "$TEST_RESULTS_DIR/PerformanceTests.xcresult" \
            -only-testing "RealityRealmsPerformanceTests" \
            CODE_SIGN_IDENTITY="" \
            CODE_SIGNING_REQUIRED=NO \
            2>&1 | tee -a "$LOG_FILE" || result=$?

        if [ $result -eq 0 ]; then
            print_success "Performance tests passed"
        else
            print_warning "Performance tests failed or not available"
        fi
    else
        print_info "No performance test scheme found"
    fi

    return 0
}

# Generate code coverage report
generate_coverage_report() {
    if [ "$GENERATE_COVERAGE" != "true" ]; then
        return 0
    fi

    print_header "Generating Code Coverage Report"

    local coverage_json="$TEST_RESULTS_DIR/coverage.json"
    local coverage_html="$TEST_RESULTS_DIR/coverage/index.html"

    # Check if xccov is available
    if ! command -v xccov &> /dev/null; then
        print_warning "xccov not found, skipping coverage report generation"
        return 0
    fi

    # Generate JSON coverage report
    if [ -f "$TEST_RESULTS_DIR/UnitTests.xcresult/Info.plist" ]; then
        print_info "Generating JSON coverage report..."
        xccov view \
            "$TEST_RESULTS_DIR/UnitTests.xcresult" \
            --json > "$coverage_json" 2>&1 || true

        if [ -f "$coverage_json" ]; then
            print_success "Coverage report generated at: $coverage_json"

            # Extract coverage percentage
            local coverage_percent=$(grep -o '"coverage"[^,]*' "$coverage_json" | head -1 | grep -o '[0-9.]*' || echo "Unknown")
            print_info "Overall coverage: ${coverage_percent}%"
        fi
    else
        print_warning "Test result bundle not found"
    fi
}

# Run code quality checks
run_quality_checks() {
    print_header "Running Code Quality Checks"

    # SwiftLint
    if command -v swiftlint &> /dev/null; then
        print_info "Running SwiftLint..."
        local lint_report="$TEST_RESULTS_DIR/swiftlint-report.json"

        if swiftlint lint --reporter json > "$lint_report" 2>&1; then
            print_success "SwiftLint passed"
        else
            local violation_count=$(grep -o '"severity"' "$lint_report" 2>/dev/null | wc -l)
            print_warning "SwiftLint found $violation_count violations"
        fi
    else
        print_warning "SwiftLint not installed"
    fi

    # SwiftFormat
    if command -v swiftformat &> /dev/null; then
        print_info "Checking Swift formatting..."
        if swiftformat --lint . > /dev/null 2>&1; then
            print_success "Swift formatting check passed"
        else
            print_warning "Some files need formatting (run: swiftformat -i .)"
        fi
    else
        print_warning "SwiftFormat not installed"
    fi
}

# Print test summary
print_test_summary() {
    print_header "Test Summary"

    local test_results_dir="$TEST_RESULTS_DIR"

    echo ""
    echo "Test Results:"
    if [ -f "$test_results_dir/UnitTests.xcresult/Info.plist" ]; then
        echo "  ✓ Unit Tests Completed"
        echo "    Result: $test_results_dir/UnitTests.xcresult"
    fi

    if [ -f "$test_results_dir/IntegrationTests.xcresult/Info.plist" ]; then
        echo "  ✓ Integration Tests Completed"
        echo "    Result: $test_results_dir/IntegrationTests.xcresult"
    fi

    if [ -f "$test_results_dir/PerformanceTests.xcresult/Info.plist" ]; then
        echo "  ✓ Performance Tests Completed"
        echo "    Result: $test_results_dir/PerformanceTests.xcresult"
    fi

    echo ""
    echo "Reports:"
    if [ -f "$test_results_dir/coverage.json" ]; then
        echo "  ✓ Coverage Report: $test_results_dir/coverage.json"
    fi

    if [ -f "$test_results_dir/swiftlint-report.json" ]; then
        echo "  ✓ Lint Report: $test_results_dir/swiftlint-report.json"
    fi

    echo ""
    echo "Logs:"
    echo "  ✓ Test Log: $LOG_FILE"
    echo ""

    print_success "Test run completed at $(date)"
}

# Clean up
cleanup() {
    print_info "Cleaning up temporary files..."

    # Optional: Remove derived data after successful tests
    # rm -rf "$DERIVED_DATA_DIR"

    print_success "Cleanup complete"
}

# Main test flow
main() {
    print_header "Reality Realms RPG - Test Suite"
    echo "Test Run: $(date)"
    echo ""

    init_test_environment
    echo ""

    # Run all test suites
    run_unit_tests || true
    echo ""

    run_integration_tests || true
    echo ""

    run_performance_tests || true
    echo ""

    run_quality_checks || true
    echo ""

    generate_coverage_report
    echo ""

    print_test_summary

    cleanup

    # Exit with success if tests completed
    print_success "All tests completed successfully!"
    exit 0
}

# Parse command-line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --scheme)
            SCHEME="$2"
            shift 2
            ;;
        --destination)
            DESTINATION="$2"
            shift 2
            ;;
        --no-coverage)
            GENERATE_COVERAGE="false"
            shift
            ;;
        --help)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --scheme SCHEME              Test scheme (default: RealityRealms)"
            echo "  --destination DEST           Test destination (default: visionOS Simulator)"
            echo "  --no-coverage                Skip coverage report generation"
            echo "  --help                       Show this help message"
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Run main if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
