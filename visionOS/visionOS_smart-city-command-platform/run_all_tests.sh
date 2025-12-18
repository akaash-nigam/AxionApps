#!/bin/bash

# Comprehensive Test Suite for Smart City Command Platform
# Tests everything possible without Swift compiler

# Don't exit on error - we want to collect all test results
# set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Counters
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0
WARNING_TESTS=0

# Test result tracking
declare -a FAILED_TEST_NAMES
declare -a WARNING_TEST_NAMES

print_header() {
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

pass() {
    echo -e "  ${GREEN}✓${NC} $1"
    ((PASSED_TESTS++))
    ((TOTAL_TESTS++))
}

fail() {
    echo -e "  ${RED}✗${NC} $1"
    FAILED_TEST_NAMES+=("$1")
    ((FAILED_TESTS++))
    ((TOTAL_TESTS++))
}

warn() {
    echo -e "  ${YELLOW}⚠${NC} $1"
    WARNING_TEST_NAMES+=("$1")
    ((WARNING_TESTS++))
    ((TOTAL_TESTS++))
}

test_file_exists() {
    if [ -f "$1" ]; then
        pass "File exists: $1"
    else
        fail "File missing: $1"
    fi
}

test_file_not_empty() {
    if [ -s "$1" ]; then
        pass "File not empty: $1"
    else
        fail "File is empty: $1"
    fi
}

test_pattern_exists() {
    if grep -q "$2" "$1" 2>/dev/null; then
        pass "Pattern '$2' found in $1"
    else
        fail "Pattern '$2' NOT found in $1"
    fi
}

test_pattern_count() {
    local count=$(grep -c "$2" "$1" 2>/dev/null || echo "0")
    if [ "$count" -ge "$3" ]; then
        pass "Pattern '$2' found $count times (expected >= $3) in $1"
    else
        fail "Pattern '$2' found only $count times (expected >= $3) in $1"
    fi
}

test_no_pattern() {
    if ! grep -q "$2" "$1" 2>/dev/null; then
        pass "Pattern '$2' NOT found in $1 (as expected)"
    else
        warn "Pattern '$2' found in $1 (may need review)"
    fi
}

# ============================================================================
# TEST SUITE START
# ============================================================================

echo ""
echo -e "${BLUE}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║           SMART CITY COMMAND PLATFORM - COMPREHENSIVE TEST SUITE            ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
echo ""

# ============================================================================
print_header "1. PROJECT STRUCTURE TESTS"
# ============================================================================

test_file_exists "README.md"
test_file_exists "INSTRUCTIONS.md"
test_file_exists "PRD-Smart-City-Command-Platform.md"
test_file_exists "ARCHITECTURE.md"
test_file_exists "TECHNICAL_SPEC.md"
test_file_exists "DESIGN.md"
test_file_exists "IMPLEMENTATION_PLAN.md"
test_file_exists "IMPLEMENTATION_STATUS.md"

# Check Swift project structure
test_file_exists "SmartCityCommandPlatform/SmartCityCommandPlatformApp.swift"
test_file_exists "SmartCityCommandPlatform/ContentView.swift"

# Check landing page
test_file_exists "landing-page/index.html"
test_file_exists "landing-page/css/styles.css"
test_file_exists "landing-page/js/main.js"
test_file_exists "landing-page/README.md"

# ============================================================================
print_header "2. SWIFT CODE VALIDATION TESTS"
# ============================================================================

# Test Swift syntax patterns
test_pattern_exists "SmartCityCommandPlatform/SmartCityCommandPlatformApp.swift" "@main"
test_pattern_exists "SmartCityCommandPlatform/SmartCityCommandPlatformApp.swift" "struct.*App.*:.*App"
test_pattern_exists "SmartCityCommandPlatform/SmartCityCommandPlatformApp.swift" "WindowGroup"
test_pattern_exists "SmartCityCommandPlatform/SmartCityCommandPlatformApp.swift" "ImmersiveSpace"

# Count Swift files
SWIFT_FILE_COUNT=$(find SmartCityCommandPlatform -name "*.swift" 2>/dev/null | wc -l)
if [ "$SWIFT_FILE_COUNT" -ge 15 ]; then
    pass "Swift files: $SWIFT_FILE_COUNT (expected >= 15)"
else
    fail "Swift files: $SWIFT_FILE_COUNT (expected >= 15)"
fi

# Test for SwiftData models
MODEL_COUNT=$(find SmartCityCommandPlatform -name "*.swift" -exec grep -l "@Model" {} \; 2>/dev/null | wc -l)
if [ "$MODEL_COUNT" -ge 5 ]; then
    pass "SwiftData @Model files: $MODEL_COUNT (expected >= 5)"
else
    fail "SwiftData @Model files: $MODEL_COUNT (expected >= 5)"
fi

# Test for SwiftUI views
VIEW_COUNT=$(find SmartCityCommandPlatform -name "*.swift" -exec grep -l "View" {} \; 2>/dev/null | wc -l)
if [ "$VIEW_COUNT" -ge 5 ]; then
    pass "SwiftUI View files: $VIEW_COUNT (expected >= 5)"
else
    fail "SwiftUI View files: $VIEW_COUNT (expected >= 5)"
fi

# Test for async/await usage
ASYNC_COUNT=$(find SmartCityCommandPlatform -name "*.swift" -exec grep -c "async" {} \; 2>/dev/null | awk '{s+=$1} END {print s}')
if [ "$ASYNC_COUNT" -ge 30 ]; then
    pass "Async/await usage: $ASYNC_COUNT occurrences (expected >= 30)"
else
    warn "Async/await usage: $ASYNC_COUNT occurrences (expected >= 30)"
fi

# Test for Observable macro
if find SmartCityCommandPlatform -name "*.swift" -exec grep -l "@Observable" {} \; 2>/dev/null | grep -q .; then
    pass "@Observable macro used in ViewModels"
else
    fail "@Observable macro NOT found in any files"
fi

# ============================================================================
print_header "3. CODE QUALITY TESTS"
# ============================================================================

# Check for TODO/FIXME comments
TODO_COUNT=$(find SmartCityCommandPlatform -name "*.swift" -exec grep -i "// TODO\|// FIXME" {} \; 2>/dev/null | wc -l)
if [ "$TODO_COUNT" -eq 0 ]; then
    pass "No TODO/FIXME comments found"
else
    warn "Found $TODO_COUNT TODO/FIXME comments (review needed)"
fi

# Check for print statements (should use proper logging)
PRINT_COUNT=$(find SmartCityCommandPlatform -name "*.swift" -exec grep -c "^[[:space:]]*print(" {} \; 2>/dev/null | awk '{s+=$1} END {print s}')
if [ "$PRINT_COUNT" -eq 0 ]; then
    pass "No print statements found (good)"
elif [ "$PRINT_COUNT" -le 5 ]; then
    warn "Found $PRINT_COUNT print statements (consider using proper logging)"
else
    fail "Found $PRINT_COUNT print statements (should use proper logging)"
fi

# Check file naming conventions
if find SmartCityCommandPlatform -name "*.swift" | grep -q "[a-z_]"; then
    warn "Some Swift files may not follow UpperCamelCase naming"
else
    pass "Swift file naming conventions correct"
fi

# Check for force unwrapping (!)
FORCE_UNWRAP=$(find SmartCityCommandPlatform -name "*.swift" -exec grep -o "!" {} \; 2>/dev/null | wc -l)
if [ "$FORCE_UNWRAP" -le 10 ]; then
    pass "Force unwrapping usage: $FORCE_UNWRAP (acceptable)"
else
    warn "Force unwrapping usage: $FORCE_UNWRAP (consider reducing)"
fi

# Check line length (should be <= 120 characters)
LONG_LINES=$(find SmartCityCommandPlatform -name "*.swift" -exec awk 'length>120 {count++} END {print count+0}' {} \; 2>/dev/null | awk '{s+=$1} END {print s+0}')
if [ "$LONG_LINES" -le 20 ]; then
    pass "Long lines (>120 chars): $LONG_LINES (acceptable)"
else
    warn "Long lines (>120 chars): $LONG_LINES (consider refactoring)"
fi

# ============================================================================
print_header "4. DOCUMENTATION TESTS"
# ============================================================================

# Check documentation file sizes
for doc in ARCHITECTURE.md TECHNICAL_SPEC.md DESIGN.md IMPLEMENTATION_PLAN.md; do
    if [ -f "$doc" ]; then
        size=$(wc -c < "$doc")
        if [ "$size" -ge 10000 ]; then
            pass "$doc is comprehensive (${size} bytes)"
        else
            fail "$doc is too short (${size} bytes, expected >= 10000)"
        fi
    fi
done

# Check for key sections in ARCHITECTURE.md
test_pattern_exists "ARCHITECTURE.md" "# Architecture"
test_pattern_exists "ARCHITECTURE.md" "SwiftData"
test_pattern_exists "ARCHITECTURE.md" "RealityKit"

# Check for key sections in TECHNICAL_SPEC.md
test_pattern_exists "TECHNICAL_SPEC.md" "# Technical"
test_pattern_exists "TECHNICAL_SPEC.md" "visionOS"
test_pattern_exists "TECHNICAL_SPEC.md" "SwiftUI"

# Check for key sections in DESIGN.md
test_pattern_exists "DESIGN.md" "# Design"
test_pattern_exists "DESIGN.md" "Spatial"
test_pattern_exists "DESIGN.md" "Window"

# Check for key sections in IMPLEMENTATION_PLAN.md
test_pattern_exists "IMPLEMENTATION_PLAN.md" "# Implementation"
test_pattern_exists "IMPLEMENTATION_PLAN.md" "Phase"
test_pattern_exists "IMPLEMENTATION_PLAN.md" "Timeline"

# ============================================================================
print_header "5. LANDING PAGE TESTS"
# ============================================================================

# HTML validation
test_file_not_empty "landing-page/index.html"
test_pattern_exists "landing-page/index.html" "<!DOCTYPE html>"
test_pattern_exists "landing-page/index.html" "<html"
test_pattern_exists "landing-page/index.html" "</html>"
test_pattern_exists "landing-page/index.html" "<head>"
test_pattern_exists "landing-page/index.html" "<body>"

# Check for key sections
test_pattern_exists "landing-page/index.html" "class=\"hero"
test_pattern_exists "landing-page/index.html" "class=\".*features"
test_pattern_exists "landing-page/index.html" "class=\".*pricing"

# Check for meta tags
test_pattern_exists "landing-page/index.html" "<meta.*viewport"
test_pattern_exists "landing-page/index.html" "<title>"

# Check CSS
test_file_not_empty "landing-page/css/styles.css"
test_pattern_exists "landing-page/css/styles.css" ":root"
test_pattern_exists "landing-page/css/styles.css" "@media"

# Count CSS rules
CSS_RULES=$(grep -c "^[.#]" landing-page/css/styles.css 2>/dev/null || echo "0")
if [ "$CSS_RULES" -ge 100 ]; then
    pass "CSS selectors: $CSS_RULES (comprehensive)"
else
    warn "CSS selectors: $CSS_RULES (may need more styling)"
fi

# Check JavaScript
test_file_not_empty "landing-page/js/main.js"
test_pattern_exists "landing-page/js/main.js" "addEventListener"
test_pattern_exists "landing-page/js/main.js" "querySelector"

# Check for form validation
test_pattern_exists "landing-page/js/main.js" "submit"

# ============================================================================
print_header "6. SECURITY & BEST PRACTICES TESTS"
# ============================================================================

# Check for hardcoded credentials (should not exist)
test_no_pattern "SmartCityCommandPlatform/*.swift" "password.*=.*['\"]"
test_no_pattern "SmartCityCommandPlatform/*.swift" "apiKey.*=.*['\"]"
test_no_pattern "SmartCityCommandPlatform/*.swift" "secret.*=.*['\"]"

# Check for proper error handling
ERROR_HANDLING=$(find SmartCityCommandPlatform -name "*.swift" -exec grep -c "try\|catch\|throw" {} \; 2>/dev/null | awk '{s+=$1} END {print s}')
if [ "$ERROR_HANDLING" -ge 10 ]; then
    pass "Error handling usage: $ERROR_HANDLING occurrences"
else
    warn "Error handling usage: $ERROR_HANDLING occurrences (may need more)"
fi

# Check for data validation
if find SmartCityCommandPlatform -name "*.swift" -exec grep -l "guard\|if let" {} \; 2>/dev/null | grep -q .; then
    pass "Data validation patterns found (guard/if let)"
else
    warn "Limited data validation patterns found"
fi

# ============================================================================
print_header "7. GIT REPOSITORY TESTS"
# ============================================================================

# Check git status
if git rev-parse --git-dir > /dev/null 2>&1; then
    pass "Git repository initialized"
else
    fail "Not a git repository"
fi

# Check for uncommitted changes
if [ -z "$(git status --porcelain)" ]; then
    pass "No uncommitted changes"
else
    warn "Uncommitted changes detected"
fi

# Check branch name
BRANCH=$(git branch --show-current)
if [[ "$BRANCH" == *"claude"* ]]; then
    pass "On correct branch: $BRANCH"
else
    warn "Branch name: $BRANCH (verify if correct)"
fi

# Check commit count
COMMIT_COUNT=$(git rev-list --count HEAD 2>/dev/null || echo "0")
if [ "$COMMIT_COUNT" -ge 5 ]; then
    pass "Git commits: $COMMIT_COUNT"
else
    warn "Git commits: $COMMIT_COUNT (may need more frequent commits)"
fi

# Check for remote
if git remote -v | grep -q "origin"; then
    pass "Git remote 'origin' configured"
else
    fail "Git remote 'origin' not configured"
fi

# ============================================================================
print_header "8. PROJECT METRICS TESTS"
# ============================================================================

# Count total lines of Swift code
SWIFT_LINES=$(find SmartCityCommandPlatform -name "*.swift" -exec wc -l {} \; 2>/dev/null | awk '{s+=$1} END {print s}')
if [ "$SWIFT_LINES" -ge 1500 ]; then
    pass "Swift code lines: $SWIFT_LINES (substantial implementation)"
else
    warn "Swift code lines: $SWIFT_LINES (may need more implementation)"
fi

# Count documentation size
DOC_SIZE=$(cat ARCHITECTURE.md TECHNICAL_SPEC.md DESIGN.md IMPLEMENTATION_PLAN.md 2>/dev/null | wc -c)
if [ "$DOC_SIZE" -ge 100000 ]; then
    pass "Documentation size: $DOC_SIZE bytes (comprehensive)"
else
    warn "Documentation size: $DOC_SIZE bytes (may need more detail)"
fi

# Count total files
TOTAL_FILES=$(find . -type f -not -path "./.git/*" 2>/dev/null | wc -l)
if [ "$TOTAL_FILES" -ge 30 ]; then
    pass "Total project files: $TOTAL_FILES"
else
    warn "Total project files: $TOTAL_FILES (expected more for complete project)"
fi

# ============================================================================
print_header "9. ARCHITECTURE PATTERN TESTS"
# ============================================================================

# Check for MVVM pattern
if find SmartCityCommandPlatform -name "*ViewModel.swift" 2>/dev/null | grep -q .; then
    pass "MVVM pattern: ViewModel files found"
else
    fail "MVVM pattern: No ViewModel files found"
fi

# Check for Service layer
if find SmartCityCommandPlatform -name "*Service.swift" 2>/dev/null | grep -q .; then
    pass "Service layer: Service files found"
else
    fail "Service layer: No Service files found"
fi

# Check for protocol usage
PROTOCOL_COUNT=$(find SmartCityCommandPlatform -name "*.swift" -exec grep -c "^protocol " {} \; 2>/dev/null | awk '{s+=$1} END {print s}')
if [ "$PROTOCOL_COUNT" -ge 3 ]; then
    pass "Protocol-oriented design: $PROTOCOL_COUNT protocols"
else
    warn "Protocol-oriented design: $PROTOCOL_COUNT protocols (consider more)"
fi

# Check for dependency injection patterns
if find SmartCityCommandPlatform -name "*.swift" -exec grep -l "init.*:.*{" {} \; 2>/dev/null | grep -q .; then
    pass "Dependency injection patterns found"
else
    warn "Limited dependency injection patterns"
fi

# ============================================================================
print_header "10. VISIONOS SPECIFIC TESTS"
# ============================================================================

# Check for RealityKit usage
if find SmartCityCommandPlatform -name "*.swift" -exec grep -l "RealityKit\|RealityView" {} \; 2>/dev/null | grep -q .; then
    pass "RealityKit integration found"
else
    fail "RealityKit integration NOT found"
fi

# Check for volumetric window style
test_pattern_exists "SmartCityCommandPlatform/SmartCityCommandPlatformApp.swift" "volumetric"

# Check for ImmersiveSpace
test_pattern_exists "SmartCityCommandPlatform/SmartCityCommandPlatformApp.swift" "ImmersiveSpace"

# Check for spatial gestures
if find SmartCityCommandPlatform -name "*.swift" -exec grep -l "gesture\|DragGesture\|MagnifyGesture" {} \; 2>/dev/null | grep -q .; then
    pass "Spatial gesture handling found"
else
    warn "Limited spatial gesture handling"
fi

# ============================================================================
# TEST SUMMARY
# ============================================================================

echo ""
echo -e "${BLUE}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║                              TEST SUMMARY                                    ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "Total Tests:    ${BLUE}$TOTAL_TESTS${NC}"
echo -e "Passed:         ${GREEN}$PASSED_TESTS${NC}"
echo -e "Failed:         ${RED}$FAILED_TESTS${NC}"
echo -e "Warnings:       ${YELLOW}$WARNING_TESTS${NC}"
echo ""

if [ $FAILED_TESTS -gt 0 ]; then
    echo -e "${RED}Failed Tests:${NC}"
    for test in "${FAILED_TEST_NAMES[@]}"; do
        echo -e "  ${RED}✗${NC} $test"
    done
    echo ""
fi

if [ $WARNING_TESTS -gt 0 ]; then
    echo -e "${YELLOW}Warnings:${NC}"
    for test in "${WARNING_TEST_NAMES[@]}"; do
        echo -e "  ${YELLOW}⚠${NC} $test"
    done
    echo ""
fi

# Calculate success percentage
SUCCESS_RATE=$((PASSED_TESTS * 100 / TOTAL_TESTS))

echo -e "Success Rate:   ${BLUE}${SUCCESS_RATE}%${NC}"
echo ""

if [ $FAILED_TESTS -eq 0 ]; then
    echo -e "${GREEN}✓ All critical tests passed!${NC}"
    exit 0
else
    echo -e "${RED}✗ Some tests failed. Please review.${NC}"
    exit 1
fi
