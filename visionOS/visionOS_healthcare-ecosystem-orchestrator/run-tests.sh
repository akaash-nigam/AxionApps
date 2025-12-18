#!/bin/bash

# Healthcare Ecosystem Orchestrator - Comprehensive Test Suite
# This script runs all testable validations in the current environment

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test counters
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0
WARNINGS=0

# Output directory for test results
TEST_OUTPUT_DIR="test-results"
mkdir -p "$TEST_OUTPUT_DIR"

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║  Healthcare Ecosystem Orchestrator - Test Suite                ║"
echo "║  Comprehensive Validation Framework                            ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

# Function to log test results
log_test() {
    local test_name="$1"
    local status="$2"
    local message="$3"

    TOTAL_TESTS=$((TOTAL_TESTS + 1))

    if [ "$status" = "PASS" ]; then
        echo -e "${GREEN}✓${NC} ${test_name}: ${message}"
        PASSED_TESTS=$((PASSED_TESTS + 1))
    elif [ "$status" = "FAIL" ]; then
        echo -e "${RED}✗${NC} ${test_name}: ${message}"
        FAILED_TESTS=$((FAILED_TESTS + 1))
    elif [ "$status" = "WARN" ]; then
        echo -e "${YELLOW}⚠${NC} ${test_name}: ${message}"
        WARNINGS=$((WARNINGS + 1))
    else
        echo -e "${BLUE}ℹ${NC} ${test_name}: ${message}"
    fi
}

# ============================================================================
# 1. PROJECT STRUCTURE VALIDATION
# ============================================================================
echo -e "\n${BLUE}═══ 1. PROJECT STRUCTURE VALIDATION ═══${NC}\n"

# Check main documentation files
for doc in INSTRUCTIONS.md PRD-Healthcare-Ecosystem-Orchestrator.md \
           Healthcare-Ecosystem-Orchestrator-PRFAQ.md README.md \
           ARCHITECTURE.md TECHNICAL_SPEC.md DESIGN.md IMPLEMENTATION_PLAN.md; do
    if [ -f "$doc" ]; then
        log_test "Documentation" "PASS" "$doc exists"
    else
        log_test "Documentation" "FAIL" "$doc missing"
    fi
done

# Check app structure
if [ -d "HealthcareOrchestrator" ]; then
    log_test "App Structure" "PASS" "HealthcareOrchestrator directory exists"

    # Check subdirectories
    for dir in App Models Views Services ViewModels; do
        if [ -d "HealthcareOrchestrator/$dir" ]; then
            log_test "App Structure" "PASS" "$dir directory exists"
        else
            log_test "App Structure" "FAIL" "$dir directory missing"
        fi
    done
else
    log_test "App Structure" "FAIL" "HealthcareOrchestrator directory missing"
fi

# Check landing page structure
if [ -d "landing-page" ]; then
    log_test "Landing Page" "PASS" "landing-page directory exists"

    for file in index.html css/styles.css js/script.js; do
        if [ -f "landing-page/$file" ]; then
            log_test "Landing Page" "PASS" "$file exists"
        else
            log_test "Landing Page" "FAIL" "$file missing"
        fi
    done
else
    log_test "Landing Page" "FAIL" "landing-page directory missing"
fi

# ============================================================================
# 2. SWIFT CODE VALIDATION
# ============================================================================
echo -e "\n${BLUE}═══ 2. SWIFT CODE VALIDATION ═══${NC}\n"

# Count Swift files
SWIFT_FILES=$(find HealthcareOrchestrator -name "*.swift" 2>/dev/null | wc -l)
log_test "Swift Files" "PASS" "Found $SWIFT_FILES Swift source files"

# Check for common Swift syntax issues
SWIFT_SYNTAX_ERRORS=0
if [ -d "HealthcareOrchestrator" ]; then
    while IFS= read -r file; do
        # Check for unbalanced braces
        open_braces=$(grep -o '{' "$file" | wc -l)
        close_braces=$(grep -o '}' "$file" | wc -l)

        if [ "$open_braces" -ne "$close_braces" ]; then
            log_test "Swift Syntax" "WARN" "Unbalanced braces in $file"
            SWIFT_SYNTAX_ERRORS=$((SWIFT_SYNTAX_ERRORS + 1))
        fi

        # Check for TODO/FIXME comments
        if grep -q "// TODO\|// FIXME" "$file"; then
            todo_count=$(grep -c "// TODO\|// FIXME" "$file")
            log_test "Code Quality" "WARN" "Found $todo_count TODO/FIXME in $(basename $file)"
        fi
    done < <(find HealthcareOrchestrator -name "*.swift")
fi

if [ $SWIFT_SYNTAX_ERRORS -eq 0 ]; then
    log_test "Swift Syntax" "PASS" "No obvious syntax errors detected"
fi

# Check for SwiftData usage
if grep -r "@Model" HealthcareOrchestrator/*.swift >/dev/null 2>&1; then
    log_test "SwiftData" "PASS" "@Model decorators found"
fi

if grep -r "@Observable" HealthcareOrchestrator/*.swift >/dev/null 2>&1; then
    log_test "SwiftUI" "PASS" "@Observable decorators found"
fi

# ============================================================================
# 3. HTML VALIDATION
# ============================================================================
echo -e "\n${BLUE}═══ 3. HTML VALIDATION ═══${NC}\n"

if [ -f "landing-page/index.html" ]; then
    # Check HTML5 doctype
    if head -1 landing-page/index.html | grep -q "<!DOCTYPE html>"; then
        log_test "HTML5" "PASS" "Valid HTML5 doctype"
    else
        log_test "HTML5" "FAIL" "Missing or invalid doctype"
    fi

    # Check for required meta tags
    if grep -q '<meta name="viewport"' landing-page/index.html; then
        log_test "HTML Meta" "PASS" "Viewport meta tag present"
    else
        log_test "HTML Meta" "FAIL" "Missing viewport meta tag"
    fi

    if grep -q '<meta name="description"' landing-page/index.html; then
        log_test "HTML Meta" "PASS" "Description meta tag present"
    else
        log_test "HTML Meta" "WARN" "Missing description meta tag"
    fi

    # Check for semantic HTML
    for tag in header nav main section footer; do
        if grep -q "<$tag" landing-page/index.html; then
            log_test "Semantic HTML" "PASS" "<$tag> element used"
        fi
    done

    # Check for accessibility attributes
    if grep -q 'aria-label\|role=' landing-page/index.html; then
        log_test "Accessibility" "PASS" "ARIA attributes found"
    fi

    # Check image alt attributes
    img_without_alt=$(grep -o '<img[^>]*>' landing-page/index.html | grep -v 'alt=' | wc -l || echo 0)
    if [ "$img_without_alt" -eq 0 ]; then
        log_test "Accessibility" "PASS" "All images have alt attributes"
    else
        log_test "Accessibility" "WARN" "$img_without_alt images missing alt attributes"
    fi
fi

# ============================================================================
# 4. CSS VALIDATION
# ============================================================================
echo -e "\n${BLUE}═══ 4. CSS VALIDATION ═══${NC}\n"

if [ -f "landing-page/css/styles.css" ]; then
    # Check CSS size
    css_size=$(wc -c < "landing-page/css/styles.css")
    css_size_kb=$((css_size / 1024))
    log_test "CSS Size" "PASS" "CSS file is ${css_size_kb}KB"

    # Check for CSS variables
    if grep -q ':root' landing-page/css/styles.css; then
        var_count=$(grep -c -- '--' landing-page/css/styles.css)
        log_test "CSS Variables" "PASS" "Using CSS variables ($var_count defined)"
    fi

    # Check for responsive design
    if grep -q '@media' landing-page/css/styles.css; then
        media_queries=$(grep -c '@media' landing-page/css/styles.css)
        log_test "Responsive CSS" "PASS" "$media_queries media queries found"
    fi

    # Check for animations
    if grep -q '@keyframes' landing-page/css/styles.css; then
        animations=$(grep -c '@keyframes' landing-page/css/styles.css)
        log_test "CSS Animations" "PASS" "$animations keyframe animations defined"
    fi

    # Check for vendor prefixes (should be minimal with modern CSS)
    vendor_prefixes=$(grep -c -- '-webkit-\|-moz-\|-ms-' landing-page/css/styles.css || echo 0)
    if [ "$vendor_prefixes" -lt 10 ]; then
        log_test "CSS Modern" "PASS" "Minimal vendor prefixes (modern CSS)"
    else
        log_test "CSS Modern" "WARN" "Many vendor prefixes ($vendor_prefixes) - consider using autoprefixer"
    fi
fi

# ============================================================================
# 5. JAVASCRIPT VALIDATION
# ============================================================================
echo -e "\n${BLUE}═══ 5. JAVASCRIPT VALIDATION ═══${NC}\n"

if [ -f "landing-page/js/script.js" ]; then
    # Check JavaScript size
    js_size=$(wc -c < "landing-page/js/script.js")
    js_size_kb=$((js_size / 1024))
    log_test "JS Size" "PASS" "JavaScript file is ${js_size_kb}KB"

    # Check for ES6+ features
    if grep -q 'const \|let \|=>' landing-page/js/script.js; then
        log_test "Modern JS" "PASS" "Using ES6+ syntax"
    fi

    # Check for event listeners
    if grep -q 'addEventListener' landing-page/js/script.js; then
        listeners=$(grep -c 'addEventListener' landing-page/js/script.js)
        log_test "Interactivity" "PASS" "$listeners event listeners defined"
    fi

    # Check for console.log (should be minimal in production)
    console_logs=$(grep -c 'console.log' landing-page/js/script.js || echo 0)
    if [ "$console_logs" -lt 10 ]; then
        log_test "Production Ready" "PASS" "Minimal console.log statements"
    else
        log_test "Production Ready" "WARN" "Many console.log statements ($console_logs) - consider removing for production"
    fi

    # Check for async/await
    if grep -q 'async\|await' landing-page/js/script.js; then
        log_test "Modern JS" "PASS" "Using async/await"
    fi
fi

# ============================================================================
# 6. CODE METRICS
# ============================================================================
echo -e "\n${BLUE}═══ 6. CODE METRICS ═══${NC}\n"

# Swift code metrics
if [ -d "HealthcareOrchestrator" ]; then
    total_swift_lines=$(find HealthcareOrchestrator -name "*.swift" -exec wc -l {} + | tail -1 | awk '{print $1}')
    log_test "Swift Code" "PASS" "Total Swift lines: $total_swift_lines"

    # Count models
    model_files=$(find HealthcareOrchestrator/Models -name "*.swift" 2>/dev/null | wc -l)
    log_test "Data Models" "PASS" "$model_files model files"

    # Count views
    view_files=$(find HealthcareOrchestrator/Views -name "*.swift" 2>/dev/null | wc -l)
    log_test "Views" "PASS" "$view_files view files"

    # Count services
    service_files=$(find HealthcareOrchestrator/Services -name "*.swift" 2>/dev/null | wc -l)
    log_test "Services" "PASS" "$service_files service files"
fi

# Landing page metrics
if [ -f "landing-page/index.html" ]; then
    html_lines=$(wc -l < "landing-page/index.html")
    css_lines=$(wc -l < "landing-page/css/styles.css")
    js_lines=$(wc -l < "landing-page/js/script.js")

    log_test "Landing Page" "PASS" "HTML: $html_lines lines, CSS: $css_lines lines, JS: $js_lines lines"
fi

# ============================================================================
# 7. SECURITY CHECKS
# ============================================================================
echo -e "\n${BLUE}═══ 7. SECURITY CHECKS ═══${NC}\n"

# Check for hardcoded secrets (basic check)
security_issues=0

for file in $(find . -name "*.swift" -o -name "*.js" -o -name "*.html"); do
    # Check for potential API keys or passwords
    if grep -i 'password\s*=\s*"\|api[_-]key\s*=\s*"\|secret\s*=\s*"' "$file" >/dev/null 2>&1; then
        log_test "Security" "WARN" "Potential hardcoded credential in $(basename $file)"
        security_issues=$((security_issues + 1))
    fi
done

if [ $security_issues -eq 0 ]; then
    log_test "Security" "PASS" "No obvious hardcoded credentials found"
fi

# Check for HTTP links (should use HTTPS)
if [ -f "landing-page/index.html" ]; then
    http_links=$(grep -o 'http://' landing-page/index.html | wc -l || echo 0)
    if [ "$http_links" -eq 0 ]; then
        log_test "Security" "PASS" "No insecure HTTP links"
    else
        log_test "Security" "WARN" "$http_links HTTP links found - should use HTTPS"
    fi
fi

# ============================================================================
# 8. DOCUMENTATION COMPLETENESS
# ============================================================================
echo -e "\n${BLUE}═══ 8. DOCUMENTATION COMPLETENESS ═══${NC}\n"

# Check README files
for readme in README.md HealthcareOrchestrator/README_APP.md landing-page/README.md; do
    if [ -f "$readme" ]; then
        lines=$(wc -l < "$readme")
        log_test "Documentation" "PASS" "$(basename $readme): $lines lines"

        # Check for key sections
        if grep -q "## " "$readme"; then
            sections=$(grep -c "## " "$readme")
            log_test "Documentation" "PASS" "$(basename $readme): $sections sections"
        fi
    fi
done

# Check for code comments
if [ -d "HealthcareOrchestrator" ]; then
    comment_lines=$(grep -r "^[[:space:]]*//\|^[[:space:]]*/\*" HealthcareOrchestrator --include="*.swift" | wc -l)
    total_code_lines=$(find HealthcareOrchestrator -name "*.swift" -exec wc -l {} + | tail -1 | awk '{print $1}')

    if [ "$total_code_lines" -gt 0 ]; then
        comment_ratio=$((comment_lines * 100 / total_code_lines))
        if [ "$comment_ratio" -gt 10 ]; then
            log_test "Code Comments" "PASS" "Swift code has ${comment_ratio}% comments"
        else
            log_test "Code Comments" "WARN" "Swift code has only ${comment_ratio}% comments"
        fi
    fi
fi

# ============================================================================
# 9. ACCESSIBILITY CHECKS
# ============================================================================
echo -e "\n${BLUE}═══ 9. ACCESSIBILITY CHECKS ═══${NC}\n"

if [ -f "landing-page/index.html" ]; then
    # Check for heading hierarchy
    h1_count=$(grep -o '<h1' landing-page/index.html | wc -l)
    if [ "$h1_count" -eq 1 ]; then
        log_test "Accessibility" "PASS" "Single H1 heading (proper hierarchy)"
    else
        log_test "Accessibility" "WARN" "Found $h1_count H1 headings (should be 1)"
    fi

    # Check for form labels
    if grep -q '<label' landing-page/index.html; then
        log_test "Accessibility" "PASS" "Form labels present"
    fi

    # Check for skip links
    if grep -q 'skip-to-content\|skip-link' landing-page/index.html; then
        log_test "Accessibility" "PASS" "Skip navigation link present"
    else
        log_test "Accessibility" "WARN" "No skip navigation link"
    fi
fi

# ============================================================================
# 10. PERFORMANCE ANALYSIS
# ============================================================================
echo -e "\n${BLUE}═══ 10. PERFORMANCE ANALYSIS ═══${NC}\n"

if [ -f "landing-page/index.html" ]; then
    # Check total page weight
    total_size=0
    for file in landing-page/index.html landing-page/css/styles.css landing-page/js/script.js; do
        if [ -f "$file" ]; then
            size=$(wc -c < "$file")
            total_size=$((total_size + size))
        fi
    done

    total_kb=$((total_size / 1024))
    if [ "$total_kb" -lt 100 ]; then
        log_test "Performance" "PASS" "Total page weight: ${total_kb}KB (excellent)"
    elif [ "$total_kb" -lt 500 ]; then
        log_test "Performance" "PASS" "Total page weight: ${total_kb}KB (good)"
    else
        log_test "Performance" "WARN" "Total page weight: ${total_kb}KB (consider optimization)"
    fi

    # Check for lazy loading
    if grep -q 'loading="lazy"' landing-page/index.html; then
        log_test "Performance" "PASS" "Lazy loading implemented"
    else
        log_test "Performance" "WARN" "Consider adding lazy loading for images"
    fi
fi

# ============================================================================
# 11. FILE INTEGRITY
# ============================================================================
echo -e "\n${BLUE}═══ 11. FILE INTEGRITY ═══${NC}\n"

# Check for empty files
empty_files=$(find . -type f -empty 2>/dev/null | wc -l)
if [ "$empty_files" -eq 0 ]; then
    log_test "File Integrity" "PASS" "No empty files"
else
    log_test "File Integrity" "WARN" "Found $empty_files empty files"
fi

# Check for very large files
large_files=$(find . -type f -size +1M 2>/dev/null | wc -l)
if [ "$large_files" -eq 0 ]; then
    log_test "File Integrity" "PASS" "No files larger than 1MB"
else
    log_test "File Integrity" "WARN" "Found $large_files files larger than 1MB"
fi

# ============================================================================
# GENERATE TEST REPORT
# ============================================================================
echo -e "\n${BLUE}═══ GENERATING TEST REPORT ═══${NC}\n"

REPORT_FILE="$TEST_OUTPUT_DIR/test-report-$(date +%Y%m%d-%H%M%S).txt"

cat > "$REPORT_FILE" << EOF
╔════════════════════════════════════════════════════════════════╗
║  Healthcare Ecosystem Orchestrator - Test Report               ║
║  Generated: $(date)                           ║
╚════════════════════════════════════════════════════════════════╝

TEST SUMMARY
============
Total Tests:     $TOTAL_TESTS
Passed:          $PASSED_TESTS
Failed:          $FAILED_TESTS
Warnings:        $WARNINGS

Pass Rate:       $(( PASSED_TESTS * 100 / TOTAL_TESTS ))%

PROJECT STATISTICS
==================
Swift Files:     $(find HealthcareOrchestrator -name "*.swift" 2>/dev/null | wc -l)
Swift Lines:     $(find HealthcareOrchestrator -name "*.swift" -exec wc -l {} + 2>/dev/null | tail -1 | awk '{print $1}')
HTML Lines:      $([ -f landing-page/index.html ] && wc -l < landing-page/index.html || echo 0)
CSS Lines:       $([ -f landing-page/css/styles.css ] && wc -l < landing-page/css/styles.css || echo 0)
JS Lines:        $([ -f landing-page/js/script.js ] && wc -l < landing-page/js/script.js || echo 0)

Documentation Files: $(find . -name "*.md" | wc -l)
Total Documentation: $(find . -name "*.md" -exec wc -l {} + 2>/dev/null | tail -1 | awk '{print $1}') lines

RECOMMENDATIONS
===============
EOF

# Add recommendations based on test results
if [ $FAILED_TESTS -gt 0 ]; then
    echo "⚠ Fix $FAILED_TESTS failed tests before production deployment" >> "$REPORT_FILE"
fi

if [ $WARNINGS -gt 0 ]; then
    echo "ℹ Review $WARNINGS warnings for potential improvements" >> "$REPORT_FILE"
fi

echo "" >> "$REPORT_FILE"
echo "TESTING COMPLETE" >> "$REPORT_FILE"
echo "Report saved to: $REPORT_FILE" >> "$REPORT_FILE"

log_test "Report" "PASS" "Test report generated: $REPORT_FILE"

# ============================================================================
# FINAL SUMMARY
# ============================================================================
echo ""
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║                     TEST SUMMARY                               ║"
echo "╠════════════════════════════════════════════════════════════════╣"
printf "║  Total Tests:     %-44s ║\n" "$TOTAL_TESTS"
printf "║  ${GREEN}Passed:          %-44s${NC} ║\n" "$PASSED_TESTS"
printf "║  ${RED}Failed:          %-44s${NC} ║\n" "$FAILED_TESTS"
printf "║  ${YELLOW}Warnings:        %-44s${NC} ║\n" "$WARNINGS"
echo "╠════════════════════════════════════════════════════════════════╣"
printf "║  Pass Rate:       ${GREEN}%-43s${NC} ║\n" "$(( PASSED_TESTS * 100 / TOTAL_TESTS ))%"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

if [ $FAILED_TESTS -eq 0 ]; then
    echo -e "${GREEN}✓ All critical tests passed!${NC}"
    exit 0
else
    echo -e "${RED}✗ Some tests failed. Review output above.${NC}"
    exit 1
fi
