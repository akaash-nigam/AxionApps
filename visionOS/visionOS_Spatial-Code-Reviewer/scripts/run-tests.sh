#!/bin/bash

#
# run-tests.sh
# Comprehensive test execution script for Spatial Code Reviewer
#
# Usage:
#   ./scripts/run-tests.sh [options]
#
# Options:
#   --unit           Run unit tests only
#   --integration    Run integration tests only
#   --ui             Run UI tests only
#   --all            Run all tests (default)
#   --coverage       Generate code coverage report
#   --parallel       Run tests in parallel
#   --device NAME    Specify device name (default: Apple Vision Pro)
#   --help           Show this help message
#

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
RUN_UNIT=false
RUN_INTEGRATION=false
RUN_UI=false
RUN_ALL=true
COVERAGE=false
PARALLEL=false
DEVICE="Apple Vision Pro"
SCHEME="SpatialCodeReviewer"
PLATFORM="visionOS Simulator"

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --unit)
            RUN_UNIT=true
            RUN_ALL=false
            shift
            ;;
        --integration)
            RUN_INTEGRATION=true
            RUN_ALL=false
            shift
            ;;
        --ui)
            RUN_UI=true
            RUN_ALL=false
            shift
            ;;
        --all)
            RUN_ALL=true
            shift
            ;;
        --coverage)
            COVERAGE=true
            shift
            ;;
        --parallel)
            PARALLEL=true
            shift
            ;;
        --device)
            DEVICE="$2"
            shift 2
            ;;
        --help)
            echo "Usage: $0 [options]"
            echo ""
            echo "Options:"
            echo "  --unit           Run unit tests only"
            echo "  --integration    Run integration tests only"
            echo "  --ui             Run UI tests only"
            echo "  --all            Run all tests (default)"
            echo "  --coverage       Generate code coverage report"
            echo "  --parallel       Run tests in parallel"
            echo "  --device NAME    Specify device name (default: Apple Vision Pro)"
            echo "  --help           Show this help message"
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            exit 1
            ;;
    esac
done

# Banner
echo -e "${BLUE}╔═══════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  Spatial Code Reviewer - Test Suite      ║${NC}"
echo -e "${BLUE}╚═══════════════════════════════════════════╝${NC}"
echo ""

# Configuration
DESTINATION="platform=$PLATFORM,name=$DEVICE"
DERIVED_DATA="./DerivedData"

# Build common arguments
COMMON_ARGS="-scheme $SCHEME -destination '$DESTINATION'"
if [ "$COVERAGE" = true ]; then
    COMMON_ARGS="$COMMON_ARGS -enableCodeCoverage YES -derivedDataPath $DERIVED_DATA"
fi
if [ "$PARALLEL" = true ]; then
    COMMON_ARGS="$COMMON_ARGS -parallel-testing-enabled YES"
fi

echo -e "${YELLOW}Configuration:${NC}"
echo "  Scheme: $SCHEME"
echo "  Device: $DEVICE"
echo "  Platform: $PLATFORM"
echo "  Coverage: $COVERAGE"
echo "  Parallel: $PARALLEL"
echo ""

# Function to run tests
run_test() {
    local test_name=$1
    local test_target=$2

    echo -e "${BLUE}▶ Running $test_name...${NC}"

    if eval "xcodebuild test $COMMON_ARGS -only-testing:$test_target"; then
        echo -e "${GREEN}✓ $test_name passed${NC}"
        return 0
    else
        echo -e "${RED}✗ $test_name failed${NC}"
        return 1
    fi
}

# Track results
FAILED_TESTS=()

# Run Unit Tests
if [ "$RUN_ALL" = true ] || [ "$RUN_UNIT" = true ]; then
    echo -e "\n${YELLOW}═══ Unit Tests ═══${NC}\n"

    run_test "PKCE Helper Tests" "SpatialCodeReviewerTests/PKCEHelperTests" || FAILED_TESTS+=("PKCEHelperTests")
    run_test "Keychain Service Tests" "SpatialCodeReviewerTests/KeychainServiceTests" || FAILED_TESTS+=("KeychainServiceTests")
    run_test "Local Repository Manager Tests" "SpatialCodeReviewerTests/LocalRepositoryManagerTests" || FAILED_TESTS+=("LocalRepositoryManagerTests")
fi

# Run Integration Tests
if [ "$RUN_ALL" = true ] || [ "$RUN_INTEGRATION" = true ]; then
    echo -e "\n${YELLOW}═══ Integration Tests ═══${NC}\n"

    run_test "GitHub API Integration Tests" "SpatialCodeReviewerTests/GitHubAPIIntegrationTests" || FAILED_TESTS+=("GitHubAPIIntegrationTests")
fi

# Run UI Tests
if [ "$RUN_ALL" = true ] || [ "$RUN_UI" = true ]; then
    echo -e "\n${YELLOW}═══ UI Tests ═══${NC}\n"

    run_test "Authentication Flow UI Tests" "SpatialCodeReviewerUITests/AuthenticationFlowUITests" || FAILED_TESTS+=("AuthenticationFlowUITests")
    run_test "Repository Flow UI Tests" "SpatialCodeReviewerUITests/RepositoryFlowUITests" || FAILED_TESTS+=("RepositoryFlowUITests")
fi

# Generate Coverage Report
if [ "$COVERAGE" = true ]; then
    echo -e "\n${YELLOW}═══ Generating Coverage Report ═══${NC}\n"

    PROFDATA="$DERIVED_DATA/Build/ProfileData/Coverage.profdata"
    APP_PATH="$DERIVED_DATA/Build/Products/Debug-visionOS/$SCHEME.app/$SCHEME"

    if [ -f "$PROFDATA" ] && [ -f "$APP_PATH" ]; then
        echo "Exporting coverage data..."
        xcrun llvm-cov export \
            -format="lcov" \
            -instr-profile "$PROFDATA" \
            "$APP_PATH" \
            > coverage.lcov

        echo "Generating HTML report..."
        if command -v genhtml &> /dev/null; then
            genhtml coverage.lcov -o coverage-report
            echo -e "${GREEN}✓ Coverage report generated at: coverage-report/index.html${NC}"

            # Open report if on macOS
            if [[ "$OSTYPE" == "darwin"* ]]; then
                open coverage-report/index.html
            fi
        else
            echo -e "${YELLOW}⚠ genhtml not found. Install lcov to generate HTML reports:${NC}"
            echo "  brew install lcov"
        fi
    else
        echo -e "${RED}✗ Coverage data not found${NC}"
    fi
fi

# Summary
echo -e "\n${BLUE}╔═══════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  Test Summary                             ║${NC}"
echo -e "${BLUE}╚═══════════════════════════════════════════╝${NC}"

if [ ${#FAILED_TESTS[@]} -eq 0 ]; then
    echo -e "${GREEN}✓ All tests passed!${NC}"
    exit 0
else
    echo -e "${RED}✗ ${#FAILED_TESTS[@]} test suite(s) failed:${NC}"
    for test in "${FAILED_TESTS[@]}"; do
        echo -e "  ${RED}• $test${NC}"
    done
    exit 1
fi
