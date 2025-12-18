#!/bin/bash

################################################################################
# Coverage Report Generator for Wardrobe Consultant
#
# This script generates code coverage reports from test results.
#
# Usage:
#   ./scripts/generate_coverage.sh [options]
#
# Options:
#   --html          - Generate HTML report (requires xcov gem)
#   --text          - Generate text report (default)
#   --json          - Generate JSON report
#   --upload        - Upload to Codecov (requires CODECOV_TOKEN)
#
# Prerequisites:
#   - Run tests with coverage enabled first
#   - For HTML: gem install xcov
#   - For upload: export CODECOV_TOKEN=your_token
#
# Examples:
#   ./scripts/generate_coverage.sh
#   ./scripts/generate_coverage.sh --html
#   ./scripts/generate_coverage.sh --text --json
################################################################################

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
SCHEME="WardrobeConsultant"
RESULTS_DIR="TestResults"
COVERAGE_DIR="CoverageReports"

# Default options
GENERATE_HTML=false
GENERATE_TEXT=true
GENERATE_JSON=false
UPLOAD_CODECOV=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --html)
            GENERATE_HTML=true
            shift
            ;;
        --text)
            GENERATE_TEXT=true
            shift
            ;;
        --json)
            GENERATE_JSON=true
            shift
            ;;
        --upload)
            UPLOAD_CODECOV=true
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

print_error() {
    echo -e "${RED}✗ ${NC}$1"
}

print_warning() {
    echo -e "${YELLOW}⚠ ${NC}$1"
}

# Check if test results exist
if [ ! -d "$RESULTS_DIR" ]; then
    print_error "Test results not found. Run tests with --coverage first."
    echo ""
    echo "Example: ./scripts/run_tests.sh unit --coverage"
    exit 1
fi

# Create coverage directory
mkdir -p "$COVERAGE_DIR"

print_header "Generating Coverage Reports"

# Find the most recent .xcresult bundle
XCRESULT=$(find "$RESULTS_DIR" -name "*.xcresult" -type d | head -n 1)

if [ -z "$XCRESULT" ]; then
    print_error "No .xcresult bundle found in $RESULTS_DIR"
    exit 1
fi

print_info "Using result bundle: $(basename "$XCRESULT")"

# Generate text report
if [ "$GENERATE_TEXT" = true ]; then
    print_info "Generating text report..."

    TEXT_REPORT="$COVERAGE_DIR/coverage.txt"
    xcrun xccov view --report "$XCRESULT" > "$TEXT_REPORT"

    print_success "Text report saved to: $TEXT_REPORT"

    # Display summary
    echo ""
    echo -e "${BLUE}Coverage Summary:${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    # Extract and display coverage percentage
    COVERAGE=$(xcrun xccov view --report "$XCRESULT" | grep -E "^\s+WardrobeConsultant" | awk '{print $2}')
    if [ -n "$COVERAGE" ]; then
        echo -e "Total Coverage: ${GREEN}${COVERAGE}${NC}"
    fi

    # Show top-level file coverage
    xcrun xccov view --report "$XCRESULT" | grep -E "^\s+[0-9]" | head -20

    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
fi

# Generate JSON report
if [ "$GENERATE_JSON" = true ]; then
    print_info "Generating JSON report..."

    JSON_REPORT="$COVERAGE_DIR/coverage.json"
    xcrun xccov view --report --json "$XCRESULT" > "$JSON_REPORT"

    print_success "JSON report saved to: $JSON_REPORT"
fi

# Generate HTML report (requires xcov gem)
if [ "$GENERATE_HTML" = true ]; then
    print_info "Generating HTML report..."

    # Check if xcov is installed
    if ! command -v xcov &> /dev/null; then
        print_warning "xcov gem not found. Installing..."
        gem install xcov || {
            print_error "Failed to install xcov. Install manually: gem install xcov"
            exit 1
        }
    fi

    # Generate HTML report
    xcov --scheme "$SCHEME" \
         --output_directory "$COVERAGE_DIR/html" \
         --exclude_targets "WardrobeConsultantTests.*,WardrobeConsultantUITests.*" \
         --minimum_coverage_percentage 75 \
         --json_report

    print_success "HTML report saved to: $COVERAGE_DIR/html/index.html"
    print_info "Open in browser: open $COVERAGE_DIR/html/index.html"
fi

# Upload to Codecov
if [ "$UPLOAD_CODECOV" = true ]; then
    print_info "Uploading to Codecov..."

    if [ -z "$CODECOV_TOKEN" ]; then
        print_warning "CODECOV_TOKEN not set. Skipping upload."
    else
        # Convert xccov to codecov format
        if command -v codecov &> /dev/null; then
            codecov -t "$CODECOV_TOKEN" -X gcov -X xcode
            print_success "Coverage uploaded to Codecov"
        else
            print_warning "codecov CLI not found. Install: brew install codecov"
        fi
    fi
fi

# Coverage thresholds
print_header "Coverage Analysis"

# Extract coverage percentages by component
analyze_coverage() {
    local component=$1
    local coverage=$(xcrun xccov view --report "$XCRESULT" | grep "$component" | awk '{print $2}' | sed 's/%//')

    if [ -n "$coverage" ]; then
        echo -e "  $component: $coverage%"
        # Check against threshold
        local threshold=75
        if (( $(echo "$coverage < $threshold" | bc -l) )); then
            print_warning "$component coverage is below $threshold%"
        fi
    fi
}

echo ""
echo "Component Coverage:"
analyze_coverage "Domain"
analyze_coverage "Infrastructure"
analyze_coverage "Presentation"
echo ""

print_success "Coverage report generation complete!"
echo ""
echo -e "${BLUE}Next steps:${NC}"
echo "  1. Review coverage reports in: $COVERAGE_DIR"
echo "  2. Identify untested code paths"
echo "  3. Add tests for critical business logic"
echo "  4. Aim for 80%+ coverage on repositories and services"
echo ""
