#!/bin/bash

# Comprehensive Test Runner for Spatial CRM
# Tests all aspects that can be validated in a Linux environment

# Don't exit on error - we want to see all test results
set +e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

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
WARNINGS=0

echo "╔════════════════════════════════════════════════════════╗"
echo "║     Spatial CRM - Comprehensive Test Suite            ║"
echo "║     Linux Environment - Static Analysis                ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""

# Helper functions
pass() {
    echo -e "${GREEN}✓${NC} $1"
    ((PASSED_TESTS++))
    ((TOTAL_TESTS++))
}

fail() {
    echo -e "${RED}✗${NC} $1"
    ((FAILED_TESTS++))
    ((TOTAL_TESTS++))
}

warn() {
    echo -e "${YELLOW}⚠${NC} $1"
    ((WARNINGS++))
}

info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

section() {
    echo ""
    echo -e "${BLUE}━━━ $1 ━━━${NC}"
    echo ""
}

# 1. FILE STRUCTURE VALIDATION
section "1. File Structure Validation"

# Check Swift source files
SWIFT_FILES=(
    "SpatialCRM/App/SpatialCRMApp.swift"
    "SpatialCRM/App/AppState.swift"
    "SpatialCRM/App/NavigationState.swift"
    "SpatialCRM/Models/Account.swift"
    "SpatialCRM/Models/Contact.swift"
    "SpatialCRM/Models/Opportunity.swift"
    "SpatialCRM/Models/Activity.swift"
    "SpatialCRM/Models/Territory.swift"
    "SpatialCRM/Models/SalesRep.swift"
    "SpatialCRM/Models/CollaborationSession.swift"
    "SpatialCRM/Services/CRMService.swift"
    "SpatialCRM/Services/AIService.swift"
    "SpatialCRM/Services/SpatialService.swift"
    "SpatialCRM/Views/ContentView.swift"
    "SpatialCRM/Views/Dashboard/DashboardView.swift"
    "SpatialCRM/Views/Dashboard/MetricCardView.swift"
    "SpatialCRM/Views/Pipeline/PipelineView.swift"
    "SpatialCRM/Views/Pipeline/DealCardView.swift"
    "SpatialCRM/Views/Accounts/AccountListView.swift"
    "SpatialCRM/Views/Accounts/AccountRowView.swift"
    "SpatialCRM/Views/Analytics/AnalyticsView.swift"
    "SpatialCRM/Views/Customer/CustomerDetailView.swift"
    "SpatialCRM/Views/Shared/QuickActionsMenu.swift"
    "SpatialCRM/Views/Spatial/PipelineVolumeView.swift"
    "SpatialCRM/Views/Spatial/CustomerGalaxyView.swift"
    "SpatialCRM/Views/Spatial/TerritoryMapView.swift"
    "SpatialCRM/Views/Spatial/CollaborationSpaceView.swift"
    "SpatialCRM/Utilities/SampleDataGenerator.swift"
)

for file in "${SWIFT_FILES[@]}"; do
    if [ -f "$file" ]; then
        pass "Found: $file"
    else
        fail "Missing: $file"
    fi
done

# Check test files
TEST_FILES=(
    "SpatialCRM/Tests/UnitTests/OpportunityTests.swift"
    "SpatialCRM/Tests/UnitTests/ContactTests.swift"
    "SpatialCRM/Tests/UnitTests/AccountTests.swift"
    "SpatialCRM/Tests/UnitTests/AIServiceTests.swift"
    "SpatialCRM/Tests/UnitTests/CRMServiceTests.swift"
)

for file in "${TEST_FILES[@]}"; do
    if [ -f "$file" ]; then
        pass "Found test: $file"
    else
        fail "Missing test: $file"
    fi
done

# Check configuration files
CONFIG_FILES=(
    "Package.swift"
    "SpatialCRM/Resources/Info.plist"
    "SpatialCRM/Resources/SpatialCRM.entitlements"
)

for file in "${CONFIG_FILES[@]}"; do
    if [ -f "$file" ]; then
        pass "Found config: $file"
    else
        fail "Missing config: $file"
    fi
done

# Check documentation files
DOC_FILES=(
    "README.md"
    "ARCHITECTURE.md"
    "TECHNICAL_SPEC.md"
    "DESIGN.md"
    "IMPLEMENTATION_PLAN.md"
    "BUILD.md"
    "TESTING.md"
    "TESTING_PLAN.md"
)

for file in "${DOC_FILES[@]}"; do
    if [ -f "$file" ]; then
        pass "Found doc: $file"
    else
        fail "Missing doc: $file"
    fi
done

# Check landing page files
LANDING_FILES=(
    "landing-page/index.html"
    "landing-page/assets/css/styles.css"
    "landing-page/assets/js/script.js"
    "landing-page/README.md"
)

for file in "${LANDING_FILES[@]}"; do
    if [ -f "$file" ]; then
        pass "Found landing page: $file"
    else
        fail "Missing landing page: $file"
    fi
done

# 2. SWIFT SYNTAX PATTERN VALIDATION
section "2. Swift Syntax Pattern Validation"

# Check for proper Swift file headers
info "Checking Swift file structure..."
for file in "${SWIFT_FILES[@]}"; do
    if [ -f "$file" ]; then
        # Check for import statements
        if grep -q "^import " "$file"; then
            pass "Has imports: $(basename $file)"
        else
            fail "Missing imports: $(basename $file)"
        fi

        # Check for balanced braces (simple check)
        OPEN_BRACES=$(grep -o "{" "$file" | wc -l)
        CLOSE_BRACES=$(grep -o "}" "$file" | wc -l)
        if [ "$OPEN_BRACES" -eq "$CLOSE_BRACES" ]; then
            pass "Balanced braces: $(basename $file)"
        else
            fail "Unbalanced braces: $(basename $file) (open: $OPEN_BRACES, close: $CLOSE_BRACES)"
        fi
    fi
done

# Check for Model declarations
info "Checking for @Model declarations..."
MODEL_FILES=(
    "SpatialCRM/Models/Account.swift"
    "SpatialCRM/Models/Contact.swift"
    "SpatialCRM/Models/Opportunity.swift"
    "SpatialCRM/Models/Activity.swift"
    "SpatialCRM/Models/Territory.swift"
    "SpatialCRM/Models/SalesRep.swift"
    "SpatialCRM/Models/CollaborationSession.swift"
)

for file in "${MODEL_FILES[@]}"; do
    if [ -f "$file" ]; then
        if grep -q "@Model" "$file"; then
            pass "@Model found: $(basename $file)"
        else
            fail "@Model missing: $(basename $file)"
        fi
    fi
done

# Check for Observable in services
info "Checking for @Observable in services..."
if grep -q "@Observable" "SpatialCRM/Services/AIService.swift"; then
    pass "@Observable found in AIService"
else
    warn "@Observable missing in AIService"
fi

if grep -q "@Observable" "SpatialCRM/Services/CRMService.swift"; then
    pass "@Observable found in CRMService"
else
    warn "@Observable missing in CRMService"
fi

# 3. CONFIGURATION FILE VALIDATION
section "3. Configuration File Validation"

# Validate Package.swift
info "Validating Package.swift..."
if [ -f "Package.swift" ]; then
    if grep -q "name: \"SpatialCRM\"" "Package.swift"; then
        pass "Package name correct"
    else
        fail "Package name incorrect"
    fi

    if grep -q "platforms:" "Package.swift"; then
        pass "Platform specified"
    else
        fail "Platform not specified"
    fi

    if grep -q ".visionOS" "Package.swift"; then
        pass "visionOS platform found"
    else
        fail "visionOS platform missing"
    fi
fi

# Validate Info.plist
info "Validating Info.plist..."
if [ -f "SpatialCRM/Resources/Info.plist" ]; then
    if grep -q "NSHandsTrackingUsageDescription" "SpatialCRM/Resources/Info.plist"; then
        pass "Hand tracking privacy description found"
    else
        fail "Hand tracking privacy description missing"
    fi

    if grep -q "NSEyeTrackingUsageDescription" "SpatialCRM/Resources/Info.plist"; then
        pass "Eye tracking privacy description found"
    else
        fail "Eye tracking privacy description missing"
    fi

    if grep -q "NSCameraUsageDescription" "SpatialCRM/Resources/Info.plist"; then
        pass "Camera usage description found"
    else
        fail "Camera usage description missing"
    fi

    # Check for valid XML
    if grep -q "<?xml" "SpatialCRM/Resources/Info.plist" && grep -q "</plist>" "SpatialCRM/Resources/Info.plist"; then
        pass "Info.plist has valid XML structure"
    else
        fail "Info.plist XML structure invalid"
    fi
fi

# Validate entitlements
info "Validating SpatialCRM.entitlements..."
if [ -f "SpatialCRM/Resources/SpatialCRM.entitlements" ]; then
    if grep -q "com.apple.developer.arkit.hand-tracking" "SpatialCRM/Resources/SpatialCRM.entitlements"; then
        pass "Hand tracking entitlement found"
    else
        fail "Hand tracking entitlement missing"
    fi

    if grep -q "com.apple.developer.arkit.eye-tracking" "SpatialCRM/Resources/SpatialCRM.entitlements"; then
        pass "Eye tracking entitlement found"
    else
        fail "Eye tracking entitlement missing"
    fi

    if grep -q "com.apple.developer.icloud-container-identifiers" "SpatialCRM/Resources/SpatialCRM.entitlements"; then
        pass "CloudKit entitlement found"
    else
        warn "CloudKit entitlement not configured"
    fi
fi

# 4. IMPORT STATEMENT VALIDATION
section "4. Import Statement Validation"

info "Checking critical framework imports..."

# Check for SwiftUI imports
SWIFTUI_COUNT=$(grep -r "import SwiftUI" SpatialCRM/ --include="*.swift" | wc -l)
if [ "$SWIFTUI_COUNT" -gt 0 ]; then
    pass "SwiftUI imported in $SWIFTUI_COUNT files"
else
    fail "SwiftUI not imported anywhere"
fi

# Check for SwiftData imports
SWIFTDATA_COUNT=$(grep -r "import SwiftData" SpatialCRM/ --include="*.swift" | wc -l)
if [ "$SWIFTDATA_COUNT" -gt 0 ]; then
    pass "SwiftData imported in $SWIFTDATA_COUNT files"
else
    fail "SwiftData not imported anywhere"
fi

# Check for RealityKit imports
REALITYKIT_COUNT=$(grep -r "import RealityKit" SpatialCRM/ --include="*.swift" | wc -l)
if [ "$REALITYKIT_COUNT" -gt 0 ]; then
    pass "RealityKit imported in $REALITYKIT_COUNT files"
else
    warn "RealityKit not imported (needed for spatial views)"
fi

# Check for ARKit imports (for hand/eye tracking)
ARKIT_COUNT=$(grep -r "import ARKit" SpatialCRM/ --include="*.swift" | wc -l)
if [ "$ARKIT_COUNT" -gt 0 ]; then
    pass "ARKit imported in $ARKIT_COUNT files"
else
    warn "ARKit not imported (may be needed for tracking)"
fi

# Check for deprecated imports
if grep -r "import UIKit" SpatialCRM/ --include="*.swift" >/dev/null 2>&1; then
    warn "UIKit imported (should use SwiftUI for visionOS)"
fi

if grep -r "import CoreData" SpatialCRM/ --include="*.swift" >/dev/null 2>&1; then
    warn "CoreData imported (should use SwiftData for new projects)"
fi

# 5. LANDING PAGE VALIDATION
section "5. Landing Page Validation"

info "Validating HTML structure..."
if [ -f "landing-page/index.html" ]; then
    # Check for HTML5 doctype
    if head -1 "landing-page/index.html" | grep -q "<!DOCTYPE html>"; then
        pass "HTML5 doctype present"
    else
        fail "HTML5 doctype missing"
    fi

    # Check for essential meta tags
    if grep -q "<meta charset=\"UTF-8\">" "landing-page/index.html"; then
        pass "Character encoding specified"
    else
        fail "Character encoding missing"
    fi

    if grep -q "viewport" "landing-page/index.html"; then
        pass "Viewport meta tag found"
    else
        fail "Viewport meta tag missing (needed for responsive)"
    fi

    # Check for semantic HTML5 elements
    if grep -q "<header>" "landing-page/index.html"; then
        pass "Semantic header element used"
    else
        warn "No semantic header element"
    fi

    if grep -q "<nav>" "landing-page/index.html"; then
        pass "Semantic nav element used"
    else
        warn "No semantic nav element"
    fi

    if grep -q "<section>" "landing-page/index.html"; then
        pass "Semantic section elements used"
    else
        warn "No semantic section elements"
    fi

    # Check for form
    if grep -q "<form" "landing-page/index.html"; then
        pass "Contact form present"
    else
        fail "No contact form found"
    fi

    # Count CTAs
    CTA_COUNT=$(grep -c "cta-button\|btn-primary" "landing-page/index.html" || true)
    if [ "$CTA_COUNT" -gt 3 ]; then
        pass "Multiple CTAs found ($CTA_COUNT)"
    else
        warn "Few CTAs found ($CTA_COUNT)"
    fi
fi

info "Validating CSS..."
if [ -f "landing-page/assets/css/styles.css" ]; then
    # Check file size (should be substantial)
    CSS_SIZE=$(wc -l < "landing-page/assets/css/styles.css")
    if [ "$CSS_SIZE" -gt 1000 ]; then
        pass "Comprehensive CSS ($CSS_SIZE lines)"
    else
        warn "CSS file seems small ($CSS_SIZE lines)"
    fi

    # Check for CSS custom properties
    if grep -q ":root {" "landing-page/assets/css/styles.css"; then
        pass "CSS custom properties used"
    else
        warn "No CSS custom properties (harder to maintain)"
    fi

    # Check for media queries
    MEDIA_QUERY_COUNT=$(grep -c "@media" "landing-page/assets/css/styles.css" || true)
    if [ "$MEDIA_QUERY_COUNT" -gt 2 ]; then
        pass "Responsive design with $MEDIA_QUERY_COUNT breakpoints"
    else
        warn "Few media queries ($MEDIA_QUERY_COUNT)"
    fi

    # Check for animations
    if grep -q "@keyframes" "landing-page/assets/css/styles.css"; then
        pass "CSS animations defined"
    else
        warn "No CSS animations"
    fi

    # Check for balanced braces
    OPEN_BRACES=$(grep -o "{" "landing-page/assets/css/styles.css" | wc -l)
    CLOSE_BRACES=$(grep -o "}" "landing-page/assets/css/styles.css" | wc -l)
    if [ "$OPEN_BRACES" -eq "$CLOSE_BRACES" ]; then
        pass "CSS braces balanced"
    else
        fail "CSS braces unbalanced (open: $OPEN_BRACES, close: $CLOSE_BRACES)"
    fi
fi

info "Validating JavaScript..."
if [ -f "landing-page/assets/js/script.js" ]; then
    # Check for event listeners
    if grep -q "addEventListener" "landing-page/assets/js/script.js"; then
        pass "Event listeners implemented"
    else
        warn "No event listeners found"
    fi

    # Check for form handling
    if grep -q "submit" "landing-page/assets/js/script.js"; then
        pass "Form submission handling found"
    else
        warn "No form submission handling"
    fi

    # Check for smooth scrolling
    if grep -q "scrollIntoView\|smooth" "landing-page/assets/js/script.js"; then
        pass "Smooth scrolling implemented"
    else
        warn "No smooth scrolling"
    fi

    # Check for balanced braces
    OPEN_BRACES=$(grep -o "{" "landing-page/assets/js/script.js" | wc -l)
    CLOSE_BRACES=$(grep -o "}" "landing-page/assets/js/script.js" | wc -l)
    if [ "$OPEN_BRACES" -eq "$CLOSE_BRACES" ]; then
        pass "JavaScript braces balanced"
    else
        fail "JavaScript braces unbalanced (open: $OPEN_BRACES, close: $CLOSE_BRACES)"
    fi
fi

# 6. TEST FILE VALIDATION
section "6. Test File Validation"

info "Checking test structure..."
for file in "${TEST_FILES[@]}"; do
    if [ -f "$file" ]; then
        # Check for @Test annotations
        TEST_COUNT=$(grep -c "@Test" "$file" || true)
        if [ "$TEST_COUNT" -gt 0 ]; then
            pass "$(basename $file) has $TEST_COUNT tests"
        else
            fail "$(basename $file) has no @Test annotations"
        fi

        # Check for #expect assertions
        EXPECT_COUNT=$(grep -c "#expect" "$file" || true)
        if [ "$EXPECT_COUNT" -gt 0 ]; then
            pass "$(basename $file) has $EXPECT_COUNT assertions"
        else
            warn "$(basename $file) has no #expect assertions"
        fi
    fi
done

# 7. DOCUMENTATION COMPLETENESS
section "7. Documentation Completeness"

info "Checking documentation files..."
for file in "${DOC_FILES[@]}"; do
    if [ -f "$file" ]; then
        LINE_COUNT=$(wc -l < "$file")
        if [ "$LINE_COUNT" -gt 50 ]; then
            pass "$(basename $file) is comprehensive ($LINE_COUNT lines)"
        else
            warn "$(basename $file) seems brief ($LINE_COUNT lines)"
        fi

        # Check for code examples (looking for triple backticks)
        if grep -q "\`\`\`" "$file"; then
            pass "$(basename $file) has code examples"
        else
            warn "$(basename $file) has no code examples"
        fi
    fi
done

# 8. PROJECT STATISTICS
section "8. Project Statistics"

info "Calculating project metrics..."

TOTAL_SWIFT_FILES=$(find SpatialCRM -name "*.swift" -type f | wc -l)
TOTAL_SWIFT_LINES=$(find SpatialCRM -name "*.swift" -type f -exec wc -l {} + | tail -1 | awk '{print $1}')
MODEL_FILES_COUNT=$(find SpatialCRM/Models -name "*.swift" -type f 2>/dev/null | wc -l)
VIEW_FILES_COUNT=$(find SpatialCRM/Views -name "*.swift" -type f 2>/dev/null | wc -l)
SERVICE_FILES_COUNT=$(find SpatialCRM/Services -name "*.swift" -type f 2>/dev/null | wc -l)
TEST_FILES_COUNT=$(find SpatialCRM/Tests -name "*.swift" -type f 2>/dev/null | wc -l)

echo ""
echo "Project Metrics:"
echo "  Total Swift files: $TOTAL_SWIFT_FILES"
echo "  Total Swift lines: $TOTAL_SWIFT_LINES"
echo "  Model files: $MODEL_FILES_COUNT"
echo "  View files: $VIEW_FILES_COUNT"
echo "  Service files: $SERVICE_FILES_COUNT"
echo "  Test files: $TEST_FILES_COUNT"

if [ "$TOTAL_SWIFT_LINES" -gt 3000 ]; then
    pass "Substantial codebase ($TOTAL_SWIFT_LINES lines)"
else
    warn "Codebase seems small ($TOTAL_SWIFT_LINES lines)"
fi

# 9. FINAL REPORT
section "9. Test Summary"

echo ""
echo "╔════════════════════════════════════════════════════════╗"
echo "║                  TEST RESULTS                          ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""
echo -e "  ${GREEN}Passed:${NC}   $PASSED_TESTS"
echo -e "  ${RED}Failed:${NC}   $FAILED_TESTS"
echo -e "  ${YELLOW}Warnings:${NC} $WARNINGS"
echo -e "  ${BLUE}Total:${NC}    $TOTAL_TESTS"
echo ""

PASS_RATE=$((PASSED_TESTS * 100 / TOTAL_TESTS))
echo "Pass Rate: $PASS_RATE%"
echo ""

if [ "$FAILED_TESTS" -eq 0 ]; then
    echo -e "${GREEN}✓ All tests passed!${NC}"
    echo ""
    echo "Next Steps:"
    echo "  1. Transfer to macOS with Xcode 15.2+"
    echo "  2. Run: swift test"
    echo "  3. Open in Xcode and run UI tests"
    echo "  4. Deploy to Vision Pro for spatial testing"
    exit 0
else
    echo -e "${RED}✗ Some tests failed${NC}"
    echo ""
    echo "Please fix the failed tests before proceeding."
    exit 1
fi
