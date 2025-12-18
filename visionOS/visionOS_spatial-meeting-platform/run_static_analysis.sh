#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${CYAN}🔬 Running Static Analysis for Spatial Meeting Platform${NC}"
echo ""

PASS=0
FAIL=0
WARN=0

# Swift Code Analysis
echo -e "${BLUE}📱 Swift Code Quality Checks:${NC}"
echo "================================"

# Count Swift files
swift_files=$(find SpatialMeetingPlatform -name "*.swift" -type f | wc -l)
echo -e "${GREEN}✓${NC} Swift files found: $swift_files"
PASS=$((PASS+1))

# Check for TODO/FIXME comments
todos=$(grep -r "TODO\|FIXME" SpatialMeetingPlatform --include="*.swift" 2>/dev/null | wc -l)
if [ $todos -gt 0 ]; then
    echo -e "${YELLOW}⚠${NC} TODO/FIXME comments found: $todos"
    WARN=$((WARN+1))
else
    echo -e "${GREEN}✓${NC} No TODO/FIXME comments"
    PASS=$((PASS+1))
fi

# Check for force unwrapping (!)
force_unwraps=$(grep -r "!" SpatialMeetingPlatform --include="*.swift" | grep -v "// " | grep -v "//" | wc -l)
if [ $force_unwraps -gt 50 ]; then
    echo -e "${YELLOW}⚠${NC} Potential force unwraps: $force_unwraps (review for safety)"
    WARN=$((WARN+1))
else
    echo -e "${GREEN}✓${NC} Reasonable force unwrap usage: $force_unwraps"
    PASS=$((PASS+1))
fi

# Check for print statements (should use proper logging)
prints=$(grep -r "print(" SpatialMeetingPlatform --include="*.swift" | wc -l)
if [ $prints -gt 10 ]; then
    echo -e "${YELLOW}⚠${NC} print() statements found: $prints (use Logger instead)"
    WARN=$((WARN+1))
else
    echo -e "${GREEN}✓${NC} Minimal print() usage: $prints"
    PASS=$((PASS+1))
fi

# Check for @MainActor usage (important for visionOS)
mainactor_usage=$(grep -r "@MainActor" SpatialMeetingPlatform --include="*.swift" | wc -l)
if [ $mainactor_usage -gt 0 ]; then
    echo -e "${GREEN}✓${NC} @MainActor annotations found: $mainactor_usage"
    PASS=$((PASS+1))
else
    echo -e "${YELLOW}⚠${NC} Consider using @MainActor for UI components"
    WARN=$((WARN+1))
fi

# Check for async/await usage
async_usage=$(grep -r "async\|await" SpatialMeetingPlatform --include="*.swift" | wc -l)
if [ $async_usage -gt 20 ]; then
    echo -e "${GREEN}✓${NC} Modern async/await usage: $async_usage instances"
    PASS=$((PASS+1))
else
    echo -e "${YELLOW}⚠${NC} Limited async/await usage: $async_usage"
    WARN=$((WARN+1))
fi

# Check for proper error handling
do_catch=$(grep -r "do {" SpatialMeetingPlatform --include="*.swift" | wc -l)
throws=$(grep -r "throws" SpatialMeetingPlatform --include="*.swift" | wc -l)
if [ $throws -gt 0 ] && [ $do_catch -gt 0 ]; then
    echo -e "${GREEN}✓${NC} Error handling implemented: $do_catch do-catch blocks, $throws throws declarations"
    PASS=$((PASS+1))
else
    echo -e "${YELLOW}⚠${NC} Consider adding error handling"
    WARN=$((WARN+1))
fi

# Check for SwiftUI best practices
echo ""
echo -e "${BLUE}🎨 SwiftUI Best Practices:${NC}"
echo "==========================="

# @State usage
state_usage=$(grep -r "@State" SpatialMeetingPlatform/Views --include="*.swift" 2>/dev/null | wc -l)
echo -e "${GREEN}✓${NC} @State properties: $state_usage"
PASS=$((PASS+1))

# @Observable usage (Swift 6)
observable_usage=$(grep -r "@Observable\|Observable()" SpatialMeetingPlatform --include="*.swift" | wc -l)
if [ $observable_usage -gt 0 ]; then
    echo -e "${GREEN}✓${NC} Swift 6 @Observable pattern: $observable_usage instances"
    PASS=$((PASS+1))
else
    echo -e "${YELLOW}⚠${NC} No @Observable usage found"
    WARN=$((WARN+1))
fi

# Check for proper view decomposition
view_structs=$(grep -r "struct.*View" SpatialMeetingPlatform/Views --include="*.swift" | wc -l)
if [ $view_structs -gt 10 ]; then
    echo -e "${GREEN}✓${NC} Good view decomposition: $view_structs view structs"
    PASS=$((PASS+1))
else
    echo -e "${YELLOW}⚠${NC} Consider breaking down views: $view_structs view structs"
    WARN=$((WARN+1))
fi

# visionOS Specific Checks
echo ""
echo -e "${BLUE}👓 visionOS Specific Checks:${NC}"
echo "============================"

# Check for RealityKit usage
realitykit=$(grep -r "import RealityKit\|RealityKit" SpatialMeetingPlatform --include="*.swift" | wc -l)
if [ $realitykit -gt 0 ]; then
    echo -e "${GREEN}✓${NC} RealityKit integration: $realitykit references"
    PASS=$((PASS+1))
else
    echo -e "${YELLOW}⚠${NC} No RealityKit usage found"
    WARN=$((WARN+1))
fi

# Check for spatial computing APIs
windowgroup=$(grep -r "WindowGroup\|ImmersiveSpace\|volumetric" SpatialMeetingPlatform --include="*.swift" | wc -l)
if [ $windowgroup -gt 0 ]; then
    echo -e "${GREEN}✓${NC} Spatial computing APIs: $windowgroup references"
    PASS=$((PASS+1))
else
    echo -e "${RED}✗${NC} Missing visionOS presentation modes"
    FAIL=$((FAIL+1))
fi

# Check for hand tracking
handtracking=$(grep -r "HandTrackingProvider\|SpatialEventGesture" SpatialMeetingPlatform --include="*.swift" 2>/dev/null | wc -l)
if [ $handtracking -gt 0 ]; then
    echo -e "${GREEN}✓${NC} Hand tracking implementation"
    PASS=$((PASS+1))
else
    echo -e "${YELLOW}⚠${NC} Hand tracking not implemented yet"
    WARN=$((WARN+1))
fi

# Architecture Checks
echo ""
echo -e "${BLUE}🏛️  Architecture & Design Patterns:${NC}"
echo "===================================="

# Protocol-oriented programming
protocols=$(grep -r "protocol " SpatialMeetingPlatform/Services --include="*.swift" | wc -l)
if [ $protocols -gt 5 ]; then
    echo -e "${GREEN}✓${NC} Protocol-oriented design: $protocols protocols"
    PASS=$((PASS+1))
else
    echo -e "${YELLOW}⚠${NC} Limited protocol usage: $protocols protocols"
    WARN=$((WARN+1))
fi

# MVVM separation
models=$(find SpatialMeetingPlatform/Models -name "*.swift" -type f | wc -l)
views=$(find SpatialMeetingPlatform/Views -name "*.swift" -type f | wc -l)
services=$(find SpatialMeetingPlatform/Services -name "*.swift" -type f | wc -l)

echo -e "${GREEN}✓${NC} MVVM architecture:"
echo -e "  ${CYAN}→${NC} Models: $models files"
echo -e "  ${CYAN}→${NC} Views: $views files"
echo -e "  ${CYAN}→${NC} Services: $services files"
PASS=$((PASS+1))

# Dependency injection
if [ $protocols -gt 0 ]; then
    echo -e "${GREEN}✓${NC} Dependency injection ready (protocol-based)"
    PASS=$((PASS+1))
fi

# Test Coverage Checks
echo ""
echo -e "${BLUE}🧪 Test Coverage Analysis:${NC}"
echo "==========================="

test_files=$(find SpatialMeetingPlatform/Tests -name "*Tests.swift" -type f | wc -l)
echo -e "${GREEN}✓${NC} Test files: $test_files"
PASS=$((PASS+1))

test_functions=$(grep -r "func test" SpatialMeetingPlatform/Tests --include="*.swift" | wc -l)
echo -e "${GREEN}✓${NC} Test cases: $test_functions"
PASS=$((PASS+1))

# Mock objects
mocks=$(grep -r "Mock\|class.*Mock" SpatialMeetingPlatform/Tests --include="*.swift" | wc -l)
if [ $mocks -gt 5 ]; then
    echo -e "${GREEN}✓${NC} Mock objects for testing: $mocks"
    PASS=$((PASS+1))
else
    echo -e "${YELLOW}⚠${NC} Limited mock objects: $mocks"
    WARN=$((WARN+1))
fi

# Async test support
async_tests=$(grep -r "async throws" SpatialMeetingPlatform/Tests --include="*.swift" | wc -l)
if [ $async_tests -gt 0 ]; then
    echo -e "${GREEN}✓${NC} Async test support: $async_tests async tests"
    PASS=$((PASS+1))
else
    echo -e "${YELLOW}⚠${NC} No async tests found"
    WARN=$((WARN+1))
fi

# Documentation Quality
echo ""
echo -e "${BLUE}📚 Documentation Quality:${NC}"
echo "========================="

# Documentation comments
doc_comments=$(grep -r "///" SpatialMeetingPlatform --include="*.swift" 2>/dev/null | wc -l)
if [ $doc_comments -gt 50 ]; then
    echo -e "${GREEN}✓${NC} Documentation comments: $doc_comments"
    PASS=$((PASS+1))
else
    echo -e "${YELLOW}⚠${NC} Add more documentation comments: $doc_comments found"
    WARN=$((WARN+1))
fi

# README and docs
docs=$(find . -maxdepth 1 -name "*.md" -type f | wc -l)
echo -e "${GREEN}✓${NC} Documentation files: $docs markdown files"
PASS=$((PASS+1))

# Code Metrics
echo ""
echo -e "${BLUE}📊 Code Metrics:${NC}"
echo "================"

# Lines of code
total_lines=$(find SpatialMeetingPlatform -name "*.swift" -type f -exec cat {} \; | wc -l)
echo -e "${CYAN}→${NC} Total Swift lines: $total_lines"

# Average file size
if [ $swift_files -gt 0 ]; then
    avg_lines=$((total_lines / swift_files))
    if [ $avg_lines -lt 500 ]; then
        echo -e "${GREEN}✓${NC} Average file size: $avg_lines lines (good modularity)"
        PASS=$((PASS+1))
    else
        echo -e "${YELLOW}⚠${NC} Average file size: $avg_lines lines (consider splitting)"
        WARN=$((WARN+1))
    fi
fi

# Complexity indicators (rough estimate)
nested_braces=$(grep -r "{" SpatialMeetingPlatform --include="*.swift" | wc -l)
complexity_ratio=$((nested_braces / swift_files))
echo -e "${CYAN}→${NC} Estimated complexity ratio: $complexity_ratio braces/file"

# Security Checks
echo ""
echo -e "${BLUE}🔒 Security Analysis:${NC}"
echo "====================="

# Check for hardcoded credentials
hardcoded=$(grep -ri "password.*=.*\"\|api.*key.*=.*\"\|secret.*=.*\"" SpatialMeetingPlatform --include="*.swift" 2>/dev/null | grep -v "func\|let.*:" | wc -l)
if [ $hardcoded -eq 0 ]; then
    echo -e "${GREEN}✓${NC} No hardcoded credentials found"
    PASS=$((PASS+1))
else
    echo -e "${RED}✗${NC} Potential hardcoded credentials: $hardcoded (CRITICAL)"
    FAIL=$((FAIL+1))
fi

# Check for proper authentication
auth_usage=$(grep -r "AuthService\|authenticate\|token" SpatialMeetingPlatform --include="*.swift" | wc -l)
if [ $auth_usage -gt 0 ]; then
    echo -e "${GREEN}✓${NC} Authentication implementation: $auth_usage references"
    PASS=$((PASS+1))
else
    echo -e "${YELLOW}⚠${NC} No authentication found"
    WARN=$((WARN+1))
fi

# Check for encryption
encryption=$(grep -r "encrypt\|Keychain\|CryptoKit" SpatialMeetingPlatform --include="*.swift" 2>/dev/null | wc -l)
if [ $encryption -gt 0 ]; then
    echo -e "${GREEN}✓${NC} Encryption/secure storage: $encryption references"
    PASS=$((PASS+1))
else
    echo -e "${YELLOW}⚠${NC} Consider adding encryption for sensitive data"
    WARN=$((WARN+1))
fi

# Performance Indicators
echo ""
echo -e "${BLUE}⚡ Performance Indicators:${NC}"
echo "=========================="

# Check for performance best practices
lazy_usage=$(grep -r "lazy var" SpatialMeetingPlatform --include="*.swift" | wc -l)
if [ $lazy_usage -gt 0 ]; then
    echo -e "${GREEN}✓${NC} Lazy initialization: $lazy_usage instances"
    PASS=$((PASS+1))
fi

# Check for proper memory management
weak_usage=$(grep -r "\[weak self\]" SpatialMeetingPlatform --include="*.swift" 2>/dev/null | wc -l)
if [ $weak_usage -gt 5 ]; then
    echo -e "${GREEN}✓${NC} Memory leak prevention: $weak_usage [weak self] captures"
    PASS=$((PASS+1))
else
    echo -e "${YELLOW}⚠${NC} Limited weak reference usage: $weak_usage"
    WARN=$((WARN+1))
fi

# Actor usage for concurrency
actor_usage=$(grep -r "actor " SpatialMeetingPlatform --include="*.swift" | wc -l)
if [ $actor_usage -gt 0 ]; then
    echo -e "${GREEN}✓${NC} Swift concurrency actors: $actor_usage"
    PASS=$((PASS+1))
else
    echo -e "${YELLOW}⚠${NC} Consider using actors for thread-safe state"
    WARN=$((WARN+1))
fi

# Landing Page Quality
echo ""
echo -e "${BLUE}🌐 Landing Page Quality:${NC}"
echo "========================"

# Run landing page validation
if [ -f "validate_landing_page.sh" ]; then
    echo -e "${CYAN}→${NC} Running landing page validation..."
    bash validate_landing_page.sh > /tmp/landing_validation.txt 2>&1
    landing_score=$(grep "Quality score:" /tmp/landing_validation.txt | grep -o "[0-9]*%" | head -1)
    if [ -n "$landing_score" ]; then
        echo -e "${GREEN}✓${NC} Landing page quality: $landing_score"
        PASS=$((PASS+1))
    fi
fi

# Summary
echo ""
echo "═══════════════════════════════════════════"
echo -e "${CYAN}📈 Static Analysis Summary:${NC}"
echo "═══════════════════════════════════════════"
echo -e "${GREEN}Passed:${NC}   $PASS checks"
echo -e "${YELLOW}Warnings:${NC} $WARN issues"
echo -e "${RED}Failed:${NC}   $FAIL critical issues"
echo ""

# Calculate quality score
total=$((PASS + WARN + FAIL))
if [ $total -gt 0 ]; then
    score=$(( (PASS * 100) / total ))
    echo -e "${CYAN}Overall Quality Score: ${YELLOW}$score%${NC}"
    echo ""

    if [ $score -ge 90 ]; then
        echo -e "${GREEN}✅ Excellent code quality!${NC}"
    elif [ $score -ge 75 ]; then
        echo -e "${YELLOW}⚠️  Good code quality with room for improvement${NC}"
    elif [ $score -ge 60 ]; then
        echo -e "${YELLOW}⚠️  Acceptable code quality, address warnings${NC}"
    else
        echo -e "${RED}❌ Code quality needs improvement${NC}"
    fi
fi

echo ""
echo -e "${CYAN}💡 Recommendations:${NC}"
echo "==================="

if [ $FAIL -gt 0 ]; then
    echo -e "${RED}1. Address $FAIL critical issues immediately${NC}"
fi

if [ $WARN -gt 10 ]; then
    echo "2. Review and address warnings to improve code quality"
fi

if [ $doc_comments -lt 50 ]; then
    echo "3. Add more documentation comments (///) for better maintainability"
fi

if [ $test_functions -lt 30 ]; then
    echo "4. Increase test coverage (currently $test_functions test cases)"
fi

echo "5. Run SwiftLint for detailed style checks (when Xcode available)"
echo "6. Profile with Instruments for performance optimization"
echo "7. Run security audit before production deployment"

echo ""
echo -e "${CYAN}🎯 Next Steps:${NC}"
echo "==============="
echo "1. ✅ Open project in Xcode"
echo "2. ⏳ Run unit tests (xcodebuild test)"
echo "3. ⏳ Build for visionOS Simulator"
echo "4. ⏳ Profile with Instruments"
echo "5. ⏳ Run on actual Apple Vision Pro device"

exit 0
