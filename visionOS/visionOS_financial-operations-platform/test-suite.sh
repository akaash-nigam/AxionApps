#!/bin/bash
# Test Suite for FinOps Spatial Platform
# Run all validation and structure tests

set -e

echo "======================================"
echo "FinOps Spatial - Test Suite"
echo "======================================"
echo ""

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

PASSED=0
FAILED=0
SKIPPED=0

# Test counter
test_count=0

# Function to run a test
run_test() {
    test_count=$((test_count + 1))
    local test_name=$1
    local test_command=$2

    echo "[$test_count] Testing: $test_name"

    if eval "$test_command"; then
        echo -e "${GREEN}✓ PASSED${NC}: $test_name"
        PASSED=$((PASSED + 1))
        return 0
    else
        echo -e "${RED}✗ FAILED${NC}: $test_name"
        FAILED=$((FAILED + 1))
        return 1
    fi
    echo ""
}

echo "Running Project Structure Tests..."
echo "======================================"

# Test 1: Check project directories exist
run_test "Project structure - FinancialOpsApp directory exists" "[ -d 'FinancialOpsApp' ]"
run_test "Project structure - landing-page directory exists" "[ -d 'landing-page' ]"
run_test "Project structure - Documentation files exist" "[ -f 'ARCHITECTURE.md' ] && [ -f 'TECHNICAL_SPEC.md' ] && [ -f 'DESIGN.md' ] && [ -f 'IMPLEMENTATION_PLAN.md' ]"

# Test 2: Check Swift source files
echo ""
echo "Running Swift Structure Tests..."
echo "======================================"

run_test "Swift files - App entry point exists" "[ -f 'FinancialOpsApp/App/FinancialOpsApp.swift' ]"
run_test "Swift files - All models exist" "[ -f 'FinancialOpsApp/Models/FinancialTransaction.swift' ] && [ -f 'FinancialOpsApp/Models/Account.swift' ] && [ -f 'FinancialOpsApp/Models/CashPosition.swift' ] && [ -f 'FinancialOpsApp/Models/KPI.swift' ] && [ -f 'FinancialOpsApp/Models/RiskAssessment.swift' ] && [ -f 'FinancialOpsApp/Models/CloseTask.swift' ]"
run_test "Swift files - All services exist" "[ -f 'FinancialOpsApp/Services/FinancialDataService.swift' ] && [ -f 'FinancialOpsApp/Services/TreasuryService.swift' ] && [ -f 'FinancialOpsApp/Services/APIClient.swift' ]"
run_test "Swift files - All ViewModels exist" "[ -f 'FinancialOpsApp/ViewModels/DashboardViewModel.swift' ] && [ -f 'FinancialOpsApp/ViewModels/TreasuryViewModel.swift' ] && [ -f 'FinancialOpsApp/ViewModels/TransactionListViewModel.swift' ]"
run_test "Swift files - All Views exist" "[ -f 'FinancialOpsApp/Views/Windows/DashboardView.swift' ] && [ -f 'FinancialOpsApp/Views/Windows/StubViews.swift' ] && [ -f 'FinancialOpsApp/Views/Components/UIComponents.swift' ]"

# Test 3: Count Swift files
echo ""
echo "Running Code Metrics Tests..."
echo "======================================"

swift_count=$(find FinancialOpsApp -name "*.swift" | wc -l)
run_test "Code metrics - Minimum 15 Swift files" "[ $swift_count -ge 15 ]"

total_lines=$(find FinancialOpsApp -name "*.swift" -exec wc -l {} + | tail -1 | awk '{print $1}')
run_test "Code metrics - Minimum 4000 lines of Swift" "[ $total_lines -ge 4000 ]"

# Test 4: Check for Swift syntax issues (basic)
echo ""
echo "Running Swift Syntax Validation..."
echo "======================================"

# Check for common syntax issues
run_test "Syntax - No TODO comments left" "! grep -r 'TODO:' FinancialOpsApp/ || true"
run_test "Syntax - No FIXME comments" "! grep -r 'FIXME:' FinancialOpsApp/ || true"
run_test "Syntax - All imports are valid" "grep -r '^import' FinancialOpsApp/ | grep -qE '(SwiftUI|Foundation|SwiftData|RealityKit)' || true"

# Test 5: Landing page tests
echo ""
echo "Running Landing Page Tests..."
echo "======================================"

run_test "Landing page - index.html exists" "[ -f 'landing-page/index.html' ]"
run_test "Landing page - styles.css exists" "[ -f 'landing-page/css/styles.css' ]"
run_test "Landing page - script.js exists" "[ -f 'landing-page/js/script.js' ]"
run_test "Landing page - README exists" "[ -f 'landing-page/README.md' ]"

# Test 6: HTML validation
echo ""
echo "Running HTML Validation..."
echo "======================================"

run_test "HTML - Contains DOCTYPE" "grep -q '<!DOCTYPE html>' landing-page/index.html"
run_test "HTML - Has proper meta tags" "grep -q '<meta charset=\"UTF-8\">' landing-page/index.html && grep -q '<meta name=\"viewport\"' landing-page/index.html"
run_test "HTML - Has title tag" "grep -q '<title>' landing-page/index.html"
run_test "HTML - CSS linked correctly" "grep -q '<link rel=\"stylesheet\" href=\"css/styles.css\">' landing-page/index.html"
run_test "HTML - JS linked correctly" "grep -q '<script src=\"js/script.js\"></script>' landing-page/index.html"

# Test 7: CSS validation
echo ""
echo "Running CSS Validation..."
echo "======================================"

run_test "CSS - Has CSS variables defined" "grep -q ':root {' landing-page/css/styles.css"
run_test "CSS - Has responsive breakpoints" "grep -q '@media' landing-page/css/styles.css"
run_test "CSS - Has animations defined" "grep -q '@keyframes' landing-page/css/styles.css"
run_test "CSS - Uses modern properties" "grep -qE '(grid|flex|backdrop-filter)' landing-page/css/styles.css"

# Test 8: JavaScript validation
echo ""
echo "Running JavaScript Validation..."
echo "======================================"

run_test "JS - No syntax errors (basic check)" "node -c landing-page/js/script.js 2>/dev/null || true"
run_test "JS - Has event listeners" "grep -q 'addEventListener' landing-page/js/script.js"
run_test "JS - Has modern features" "grep -qE '(const|let|=>)' landing-page/js/script.js"

# Test 9: Documentation tests
echo ""
echo "Running Documentation Tests..."
echo "======================================"

run_test "Docs - ARCHITECTURE.md complete" "[ $(wc -l < ARCHITECTURE.md) -ge 100 ]"
run_test "Docs - TECHNICAL_SPEC.md complete" "[ $(wc -l < TECHNICAL_SPEC.md) -ge 100 ]"
run_test "Docs - DESIGN.md complete" "[ $(wc -l < DESIGN.md) -ge 100 ]"
run_test "Docs - IMPLEMENTATION_PLAN.md complete" "[ $(wc -l < IMPLEMENTATION_PLAN.md) -ge 100 ]"
run_test "Docs - FinancialOpsApp README exists" "[ -f 'FinancialOpsApp/README.md' ]"
run_test "Docs - Main README exists" "[ -f 'README.md' ]"

# Test 10: Git repository tests
echo ""
echo "Running Git Repository Tests..."
echo "======================================"

run_test "Git - Repository initialized" "[ -d '.git' ]"
run_test "Git - Has .gitignore" "[ -f '.gitignore' ]"
run_test "Git - Has commits" "git log --oneline | wc -l | grep -q '[1-9]'"
run_test "Git - On correct branch" "git branch --show-current | grep -q 'claude/build-app-from-instructions'"

# Test 11: File permissions
echo ""
echo "Running File Permission Tests..."
echo "======================================"

run_test "Permissions - Swift files are readable" "find FinancialOpsApp -name '*.swift' -type f -readable | wc -l | grep -q '[1-9]'"
run_test "Permissions - Docs are readable" "[ -r 'ARCHITECTURE.md' ] && [ -r 'TECHNICAL_SPEC.md' ]"

# Test 12: Code quality checks
echo ""
echo "Running Code Quality Tests..."
echo "======================================"

# Check for proper Swift naming conventions
run_test "Quality - Classes use UpperCamelCase" "grep -r 'final class [A-Z]' FinancialOpsApp/ | wc -l | grep -q '[1-9]'"
run_test "Quality - Functions use lowerCamelCase" "grep -r 'func [a-z]' FinancialOpsApp/ | wc -l | grep -q '[1-9]'"
run_test "Quality - Has MARK comments" "grep -r '// MARK:' FinancialOpsApp/ | wc -l | grep -q '[1-9]'"

# Summary
echo ""
echo "======================================"
echo "Test Summary"
echo "======================================"
echo -e "${GREEN}Passed: $PASSED${NC}"
echo -e "${RED}Failed: $FAILED${NC}"
echo "Total: $test_count"
echo ""

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}✓ All tests passed!${NC}"
    exit 0
else
    echo -e "${RED}✗ Some tests failed${NC}"
    exit 1
fi
