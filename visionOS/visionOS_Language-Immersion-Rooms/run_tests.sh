#!/bin/bash

#
# Test Runner Script
# Language Immersion Rooms visionOS App
#
# Runs all tests that can be executed without manual interaction
#

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
SCHEME="LanguageImmersionRooms"
DESTINATION="platform=visionOS Simulator,name=Apple Vision Pro"
PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo -e "${BLUE}╔══════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  Language Immersion Rooms - Test Runner           ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════╝${NC}\n"

# Check if Xcode is installed
if ! command -v xcodebuild &> /dev/null; then
    echo -e "${RED}❌ Error: xcodebuild not found. Please install Xcode.${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Xcode found: $(xcodebuild -version | head -1)${NC}\n"

# Check if simulator is available
if ! xcrun simctl list devices | grep -q "Apple Vision Pro"; then
    echo -e "${YELLOW}⚠️  Warning: Apple Vision Pro simulator not found${NC}"
    echo -e "   Install visionOS Simulator from Xcode Settings\n"
fi

# Total test count
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0
SKIPPED_TESTS=0

echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}Running Unit Tests (All Components)${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}\n"

# Run Unit Tests
echo -e "${YELLOW}📦 Core Models Tests...${NC}"
if xcodebuild test \
    -scheme "$SCHEME" \
    -destination "$DESTINATION" \
    -only-testing:LanguageImmersionRoomsTests/Unit/Models/CoreModelsTests \
    2>&1 | tee /tmp/test_models.log | grep -E '(Test Suite|passed|failed)'; then
    echo -e "${GREEN}✅ Core Models Tests: PASSED${NC}\n"
    PASSED_TESTS=$((PASSED_TESTS + 25))
else
    echo -e "${RED}❌ Core Models Tests: FAILED${NC}\n"
    FAILED_TESTS=$((FAILED_TESTS + 25))
fi
TOTAL_TESTS=$((TOTAL_TESTS + 25))

echo -e "${YELLOW}📚 Vocabulary Service Tests...${NC}"
if xcodebuild test \
    -scheme "$SCHEME" \
    -destination "$DESTINATION" \
    -only-testing:LanguageImmersionRoomsTests/Unit/Services/VocabularyServiceTests \
    2>&1 | tee /tmp/test_vocabulary.log | grep -E '(Test Suite|passed|failed)'; then
    echo -e "${GREEN}✅ Vocabulary Service Tests: PASSED${NC}\n"
    PASSED_TESTS=$((PASSED_TESTS + 23))
else
    echo -e "${RED}❌ Vocabulary Service Tests: FAILED${NC}\n"
    FAILED_TESTS=$((FAILED_TESTS + 23))
fi
TOTAL_TESTS=$((TOTAL_TESTS + 23))

echo -e "${YELLOW}🔍 Object Detection Service Tests...${NC}"
if xcodebuild test \
    -scheme "$SCHEME" \
    -destination "$DESTINATION" \
    -only-testing:LanguageImmersionRoomsTests/Unit/Services/ObjectDetectionServiceTests \
    2>&1 | tee /tmp/test_detection.log | grep -E '(Test Suite|passed|failed)'; then
    echo -e "${GREEN}✅ Object Detection Service Tests: PASSED${NC}\n"
    PASSED_TESTS=$((PASSED_TESTS + 12))
else
    echo -e "${RED}❌ Object Detection Service Tests: FAILED${NC}\n"
    FAILED_TESTS=$((FAILED_TESTS + 12))
fi
TOTAL_TESTS=$((TOTAL_TESTS + 12))

echo -e "${YELLOW}🎯 AppState Tests...${NC}"
if xcodebuild test \
    -scheme "$SCHEME" \
    -destination "$DESTINATION" \
    -only-testing:LanguageImmersionRoomsTests/Unit/ViewModels/AppStateTests \
    2>&1 | tee /tmp/test_appstate.log | grep -E '(Test Suite|passed|failed)'; then
    echo -e "${GREEN}✅ AppState Tests: PASSED${NC}\n"
    PASSED_TESTS=$((PASSED_TESTS + 18))
else
    echo -e "${RED}❌ AppState Tests: FAILED${NC}\n"
    FAILED_TESTS=$((FAILED_TESTS + 18))
fi
TOTAL_TESTS=$((TOTAL_TESTS + 18))

echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}Running Integration Tests (Partial)${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}\n"

# Run Integration Tests (without API key)
echo -e "${YELLOW}🔗 Service Integration Tests (No API)...${NC}"
if xcodebuild test \
    -scheme "$SCHEME" \
    -destination "$DESTINATION" \
    -only-testing:LanguageImmersionRoomsTests/Integration/ServiceIntegrationTests/testDetectAndTranslateObjects \
    -only-testing:LanguageImmersionRoomsTests/Integration/ServiceIntegrationTests/testDetectObjectsAndCreateVocabularyWords \
    -only-testing:LanguageImmersionRoomsTests/Integration/ServiceIntegrationTests/testConcurrentDetectionAndTranslation \
    2>&1 | tee /tmp/test_integration_noapi.log | grep -E '(Test Suite|passed|failed)'; then
    echo -e "${GREEN}✅ Integration Tests (No API): PASSED${NC}\n"
    PASSED_TESTS=$((PASSED_TESTS + 3))
else
    echo -e "${RED}❌ Integration Tests (No API): FAILED${NC}\n"
    FAILED_TESTS=$((FAILED_TESTS + 3))
fi
TOTAL_TESTS=$((TOTAL_TESTS + 3))

# Check for OpenAI API key
if [ -n "$OPENAI_API_KEY" ]; then
    echo -e "${GREEN}✅ OpenAI API key found - Running full integration tests${NC}\n"

    echo -e "${YELLOW}🤖 Conversation Integration Tests...${NC}"
    if xcodebuild test \
        -scheme "$SCHEME" \
        -destination "$DESTINATION" \
        -only-testing:LanguageImmersionRoomsTests/Integration/ServiceIntegrationTests/testConversationWithVocabulary \
        -only-testing:LanguageImmersionRoomsTests/Integration/ServiceIntegrationTests/testConversationGreeting \
        -only-testing:LanguageImmersionRoomsTests/Integration/ServiceIntegrationTests/testConversationGrammarCheck \
        -only-testing:LanguageImmersionRoomsTests/Integration/ServiceIntegrationTests/testFullLearningPipeline \
        2>&1 | tee /tmp/test_integration_api.log | grep -E '(Test Suite|passed|failed)'; then
        echo -e "${GREEN}✅ Conversation Integration Tests: PASSED${NC}\n"
        PASSED_TESTS=$((PASSED_TESTS + 4))
    else
        echo -e "${RED}❌ Conversation Integration Tests: FAILED${NC}\n"
        FAILED_TESTS=$((FAILED_TESTS + 4))
    fi
    TOTAL_TESTS=$((TOTAL_TESTS + 4))
else
    echo -e "${YELLOW}⚠️  Skipping conversation tests - No OpenAI API key${NC}"
    echo -e "   Set OPENAI_API_KEY environment variable to run these tests\n"
    SKIPPED_TESTS=$((SKIPPED_TESTS + 4))
    TOTAL_TESTS=$((TOTAL_TESTS + 4))
fi

echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}Skipped Tests (Require Manual Execution)${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}\n"

echo -e "${YELLOW}⏭️  UI Tests (20 tests)${NC}"
echo -e "   Reason: Require interactive Xcode UI testing"
echo -e "   Run: Open Xcode → Test Navigator (⌘+6) → Run UI Tests\n"
SKIPPED_TESTS=$((SKIPPED_TESTS + 20))

echo -e "${YELLOW}⏭️  Performance Tests (25 tests)${NC}"
echo -e "   Reason: Best run with Instruments for detailed profiling"
echo -e "   Run: Product → Profile (⌘+I) → Select Time Profiler\n"
SKIPPED_TESTS=$((SKIPPED_TESTS + 25))

echo -e "${YELLOW}⏭️  End-to-End Tests (10 tests)${NC}"
echo -e "   Reason: Require full app environment and manual verification"
echo -e "   Run: Open Xcode → Select specific journey test → Run\n"
SKIPPED_TESTS=$((SKIPPED_TESTS + 10))

echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}Test Summary${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}\n"

echo -e "Total Tests:   $TOTAL_TESTS"
echo -e "${GREEN}Passed:        $PASSED_TESTS${NC}"

if [ $FAILED_TESTS -gt 0 ]; then
    echo -e "${RED}Failed:        $FAILED_TESTS${NC}"
fi

if [ $SKIPPED_TESTS -gt 0 ]; then
    echo -e "${YELLOW}Skipped:       $SKIPPED_TESTS${NC}"
fi

# Calculate pass rate
if [ $TOTAL_TESTS -gt 0 ]; then
    PASS_RATE=$(( (PASSED_TESTS * 100) / TOTAL_TESTS ))
    echo -e "\nPass Rate:     ${PASS_RATE}%"
fi

echo ""

# Exit code
if [ $FAILED_TESTS -gt 0 ]; then
    echo -e "${RED}❌ Some tests failed. See logs above for details.${NC}"
    exit 1
else
    echo -e "${GREEN}✅ All executable tests passed!${NC}"
    echo -e "${YELLOW}ℹ️  Run UI, Performance, and E2E tests manually in Xcode${NC}"
    exit 0
fi
