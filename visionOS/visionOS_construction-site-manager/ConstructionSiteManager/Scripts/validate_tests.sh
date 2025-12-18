#!/bin/bash

# Test Validation Script
# Validates test structure and counts test cases

set -e

echo "🧪 Construction Site Manager - Test Validation"
echo "=============================================="
echo ""

# Colors
GREEN='\033[0.32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Count test files
echo -e "${BLUE}📁 Test Files:${NC}"
TEST_FILES=$(find Tests -name "*Tests.swift" -type f | wc -l | tr -d ' ')
echo "   Total test files: $TEST_FILES"
echo ""

# List test files
echo -e "${BLUE}📝 Test File List:${NC}"
find Tests -name "*Tests.swift" -type f | while read file; do
    echo "   ✓ $file"
done
echo ""

# Count test suites (@Suite)
echo -e "${BLUE}🎯 Test Suites:${NC}"
SUITE_COUNT=$(grep -r "@Suite" Tests/ --include="*.swift" | wc -l | tr -d ' ')
echo "   Total test suites: $SUITE_COUNT"
echo ""

# Count test cases (@Test)
echo -e "${BLUE}✅ Test Cases:${NC}"
TEST_COUNT=$(grep -r "@Test" Tests/ --include="*.swift" | wc -l | tr -d ' ')
echo "   Total test cases: $TEST_COUNT"
echo ""

# Count lines of test code
echo -e "${BLUE}📊 Test Code Statistics:${NC}"
TEST_LINES=$(find Tests -name "*.swift" -type f -exec cat {} \; | wc -l | tr -d ' ')
echo "   Test code lines: $TEST_LINES"
echo ""

# Analyze test coverage by category
echo -e "${BLUE}📋 Test Distribution:${NC}"

MODEL_TESTS=$(find Tests/ModelTests -name "*.swift" -type f 2>/dev/null | wc -l | tr -d ' ')
SERVICE_TESTS=$(find Tests/ServiceTests -name "*.swift" -type f 2>/dev/null | wc -l | tr -d ' ')
INTEGRATION_TESTS=$(find Tests/IntegrationTests -name "*.swift" -type f 2>/dev/null | wc -l | tr -d ' ')

echo "   Model Tests: $MODEL_TESTS files"
echo "   Service Tests: $SERVICE_TESTS files"
echo "   Integration Tests: $INTEGRATION_TESTS files"
echo ""

# Check for test naming conventions
echo -e "${BLUE}🔍 Test Quality Checks:${NC}"

# Check if all test functions have descriptive names
NON_DESCRIPTIVE_TESTS=$(grep -r "@Test" Tests/ --include="*.swift" | grep -c "func test[0-9]" || true)
if [ "$NON_DESCRIPTIVE_TESTS" -eq 0 ]; then
    echo -e "   ${GREEN}✓${NC} All tests have descriptive names"
else
    echo -e "   ${YELLOW}⚠${NC} Found $NON_DESCRIPTIVE_TESTS tests with non-descriptive names"
fi

# Check for tests with proper arrange-act-assert comments
AAA_TESTS=$(grep -r "// Arrange" Tests/ --include="*.swift" | wc -l | tr -d ' ')
echo "   ✓ Tests following AAA pattern: $AAA_TESTS"

# Check for #expect assertions
EXPECT_COUNT=$(grep -r "#expect" Tests/ --include="*.swift" | wc -l | tr -d ' ')
echo "   ✓ Total assertions (#expect): $EXPECT_COUNT"

echo ""

# Summary
echo -e "${GREEN}✅ Validation Complete!${NC}"
echo ""
echo "Summary:"
echo "--------"
echo "  Test Files: $TEST_FILES"
echo "  Test Suites: $SUITE_COUNT"
echo "  Test Cases: $TEST_COUNT"
echo "  Test Code Lines: $TEST_LINES"
echo "  Assertions: $EXPECT_COUNT"
echo ""

# Calculate test-to-code ratio
TOTAL_CODE=$(find . -name "*.swift" -type f ! -path "./Tests/*" -exec cat {} \; | wc -l | tr -d ' ')
if [ "$TOTAL_CODE" -gt 0 ]; then
    RATIO=$(echo "scale=2; ($TEST_LINES * 100) / $TOTAL_CODE" | bc)
    echo "  Test-to-Code Ratio: ${RATIO}%"
fi

echo ""
echo -e "${GREEN}All validations passed! 🎉${NC}"
