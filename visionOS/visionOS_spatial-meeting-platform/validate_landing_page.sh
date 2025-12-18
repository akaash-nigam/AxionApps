#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Counters
PASS=0
FAIL=0
WARN=0

echo "🌐 Validating Landing Page..."
echo ""

# Check if files exist
echo "📁 File Existence Checks:"
echo "========================="

check_file() {
    if [ -f "$1" ]; then
        echo -e "${GREEN}✓${NC} $1"
        PASS=$((PASS+1))
        return 0
    else
        echo -e "${RED}✗${NC} $1 (missing)"
        FAIL=$((FAIL+1))
        return 1
    fi
}

check_file "website/index.html"
check_file "website/css/styles.css"
check_file "website/js/main.js"

echo ""
echo "📏 File Size Checks:"
echo "===================="

check_size() {
    if [ -f "$1" ]; then
        size=$(wc -c < "$1")
        lines=$(wc -l < "$1")
        echo -e "${GREEN}✓${NC} $1"
        echo -e "${YELLOW}  ⟶${NC} $lines lines, $size bytes"
        PASS=$((PASS+1))
    fi
}

check_size "website/index.html"
check_size "website/css/styles.css"
check_size "website/js/main.js"

echo ""
echo "🔍 HTML Structure Validation:"
echo "=============================="

# Check for required HTML elements
check_html_element() {
    element=$1
    description=$2
    if grep -q "$element" website/index.html; then
        echo -e "${GREEN}✓${NC} $description"
        PASS=$((PASS+1))
    else
        echo -e "${RED}✗${NC} $description (missing)"
        FAIL=$((FAIL+1))
    fi
}

check_html_element "<!DOCTYPE html>" "DOCTYPE declaration"
check_html_element "<html" "HTML root element"
check_html_element "<head>" "Head section"
check_html_element "<meta charset=" "Character encoding"
check_html_element "<meta name=\"viewport\"" "Viewport meta tag"
check_html_element "<title>" "Page title"
check_html_element "<body>" "Body element"

# Check for main sections
echo ""
echo "📑 Content Sections:"
echo "===================="

check_html_element "<nav>" "Navigation bar"
check_html_element "class=\"hero\"" "Hero section"
check_html_element "class=\"features\"" "Features section"
check_html_element "class=\"benefits\"" "Benefits section"
check_html_element "class=\"use-cases\"" "Use cases section"
check_html_element "class=\"pricing\"" "Pricing section"
check_html_element "class=\"testimonials\"" "Testimonials section"
check_html_element "<footer>" "Footer"

# Check for CTAs
echo ""
echo "🎯 Call-to-Action Elements:"
echo "==========================="

cta_count=$(grep -o "Start Free Trial\|Watch Demo\|Get Started" website/index.html | wc -l)
if [ $cta_count -ge 3 ]; then
    echo -e "${GREEN}✓${NC} Multiple CTAs found ($cta_count instances)"
    PASS=$((PASS+1))
else
    echo -e "${YELLOW}⚠${NC} Few CTAs found ($cta_count instances)"
    WARN=$((WARN+1))
fi

# Check for form elements
form_count=$(grep -o "<form>" website/index.html | wc -l)
if [ $form_count -ge 1 ]; then
    echo -e "${GREEN}✓${NC} Form elements found ($form_count forms)"
    PASS=$((PASS+1))
else
    echo -e "${YELLOW}⚠${NC} No forms found"
    WARN=$((WARN+1))
fi

# Check CSS
echo ""
echo "🎨 CSS Validation:"
echo "=================="

check_css_feature() {
    feature=$1
    description=$2
    if grep -q "$feature" website/css/styles.css; then
        echo -e "${GREEN}✓${NC} $description"
        PASS=$((PASS+1))
    else
        echo -e "${YELLOW}⚠${NC} $description (not found)"
        WARN=$((WARN+1))
    fi
}

check_css_feature ":root" "CSS custom properties"
check_css_feature "@media" "Responsive media queries"
check_css_feature "transition:" "CSS transitions"
check_css_feature "animation:" "CSS animations"
check_css_feature "@keyframes" "Keyframe animations"
check_css_feature "grid-template-columns:" "CSS Grid layout"
check_css_feature "flex" "Flexbox layout"
check_css_feature "linear-gradient" "Gradient effects"

# Check for responsive breakpoints
breakpoint_count=$(grep -o "@media.*max-width" website/css/styles.css | wc -l)
if [ $breakpoint_count -ge 3 ]; then
    echo -e "${GREEN}✓${NC} Multiple responsive breakpoints ($breakpoint_count found)"
    PASS=$((PASS+1))
else
    echo -e "${YELLOW}⚠${NC} Few responsive breakpoints ($breakpoint_count found)"
    WARN=$((WARN+1))
fi

# Check JavaScript
echo ""
echo "⚡ JavaScript Validation:"
echo "========================"

check_js_feature() {
    feature=$1
    description=$2
    if grep -q "$feature" website/js/main.js; then
        echo -e "${GREEN}✓${NC} $description"
        PASS=$((PASS+1))
    else
        echo -e "${YELLOW}⚠${NC} $description (not found)"
        WARN=$((WARN+1))
    fi
}

check_js_feature "class Navigation" "Navigation class"
check_js_feature "class ScrollAnimations" "Scroll animations"
check_js_feature "class CounterAnimation" "Counter animations"
check_js_feature "class FormHandler" "Form handling"
check_js_feature "IntersectionObserver" "Intersection Observer API"
check_js_feature "addEventListener" "Event listeners"
check_js_feature "DOMContentLoaded" "DOM ready handler"

# Check for accessibility
echo ""
echo "♿ Accessibility Features:"
echo "========================="

# HTML accessibility
check_html_element "alt=" "Image alt attributes"
check_html_element "aria-" "ARIA attributes"

# CSS accessibility
if grep -q "prefers-reduced-motion" website/css/styles.css; then
    echo -e "${GREEN}✓${NC} Reduced motion support"
    PASS=$((PASS+1))
else
    echo -e "${YELLOW}⚠${NC} Reduced motion not implemented"
    WARN=$((WARN+1))
fi

if grep -q "focus-visible" website/css/styles.css; then
    echo -e "${GREEN}✓${NC} Keyboard focus indicators"
    PASS=$((PASS+1))
else
    echo -e "${YELLOW}⚠${NC} Focus indicators not found"
    WARN=$((WARN+1))
fi

# Check for SEO
echo ""
echo "🔎 SEO Elements:"
echo "================"

check_html_element "<meta name=\"description\"" "Meta description"
check_html_element "<meta property=\"og:" "Open Graph tags"
check_html_element "<h1>" "H1 heading"
check_html_element "<h2>" "H2 headings"

# Link structure
internal_links=$(grep -o "<a href=\"#" website/index.html | wc -l)
if [ $internal_links -ge 5 ]; then
    echo -e "${GREEN}✓${NC} Internal navigation links ($internal_links found)"
    PASS=$((PASS+1))
else
    echo -e "${YELLOW}⚠${NC} Few internal links ($internal_links found)"
    WARN=$((WARN+1))
fi

# Check for performance optimizations
echo ""
echo "⚡ Performance Features:"
echo "======================="

if grep -q "defer\|async" website/index.html; then
    echo -e "${GREEN}✓${NC} Async/defer script loading"
    PASS=$((PASS+1))
else
    echo -e "${YELLOW}⚠${NC} No async script loading"
    WARN=$((WARN+1))
fi

if grep -q "lazy" website/js/main.js; then
    echo -e "${GREEN}✓${NC} Lazy loading implementation"
    PASS=$((PASS+1))
else
    echo -e "${YELLOW}⚠${NC} Lazy loading not found"
    WARN=$((WARN+1))
fi

if grep -q "throttle\|debounce" website/js/main.js; then
    echo -e "${GREEN}✓${NC} Event throttling/debouncing"
    PASS=$((PASS+1))
else
    echo -e "${YELLOW}⚠${NC} No throttling found"
    WARN=$((WARN+1))
fi

# Check for security
echo ""
echo "🔒 Security Features:"
echo "====================="

if ! grep -q "eval(" website/js/main.js; then
    echo -e "${GREEN}✓${NC} No eval() usage"
    PASS=$((PASS+1))
else
    echo -e "${RED}✗${NC} Dangerous eval() found"
    FAIL=$((FAIL+1))
fi

if ! grep -q "innerHTML.*=.*\+" website/js/main.js; then
    echo -e "${GREEN}✓${NC} No unsafe innerHTML concatenation"
    PASS=$((PASS+1))
else
    echo -e "${YELLOW}⚠${NC} Potentially unsafe innerHTML usage"
    WARN=$((WARN+1))
fi

# Code quality checks
echo ""
echo "📊 Code Quality:"
echo "================"

# Check for console.log (should be minimal in production)
console_count=$(grep -o "console.log" website/js/main.js | wc -l)
if [ $console_count -le 5 ]; then
    echo -e "${GREEN}✓${NC} Minimal console.log usage ($console_count found)"
    PASS=$((PASS+1))
else
    echo -e "${YELLOW}⚠${NC} Many console.log statements ($console_count found)"
    WARN=$((WARN+1))
fi

# Check for comments
js_comments=$(grep -o "//" website/js/main.js | wc -l)
css_comments=$(grep -o "/\*" website/css/styles.css | wc -l)
total_comments=$((js_comments + css_comments))

if [ $total_comments -ge 20 ]; then
    echo -e "${GREEN}✓${NC} Well-documented code ($total_comments comments)"
    PASS=$((PASS+1))
else
    echo -e "${YELLOW}⚠${NC} Could use more documentation ($total_comments comments)"
    WARN=$((WARN+1))
fi

# Check for proper CSS organization
if grep -q "UTILITY CLASSES\|COMPONENTS\|LAYOUT" website/css/styles.css; then
    echo -e "${GREEN}✓${NC} Organized CSS structure"
    PASS=$((PASS+1))
else
    echo -e "${YELLOW}⚠${NC} CSS could be better organized"
    WARN=$((WARN+1))
fi

# Summary
echo ""
echo "📊 Validation Summary:"
echo "======================"
echo -e "${GREEN}Passed:${NC} $PASS"
echo -e "${YELLOW}Warnings:${NC} $WARN"
echo -e "${RED}Failed:${NC} $FAIL"
echo ""

# Detailed metrics
echo "📈 Detailed Metrics:"
echo "===================="
html_lines=$(wc -l < website/index.html)
css_lines=$(wc -l < website/css/styles.css)
js_lines=$(wc -l < website/js/main.js)
total_lines=$((html_lines + css_lines + js_lines))

echo "HTML: $html_lines lines"
echo "CSS: $css_lines lines"
echo "JavaScript: $js_lines lines"
echo "Total: $total_lines lines"

echo ""
html_size=$(wc -c < website/index.html)
css_size=$(wc -c < website/css/styles.css)
js_size=$(wc -c < website/js/main.js)
total_size=$((html_size + css_size + js_size))
total_kb=$((total_size / 1024))

echo "Total size: $total_kb KB"

# Final status
echo ""
if [ $FAIL -eq 0 ]; then
    echo -e "${GREEN}✅ Landing page validation complete! Quality score: $(( (PASS * 100) / (PASS + WARN + FAIL) ))%${NC}"
    exit 0
else
    echo -e "${RED}❌ Landing page has $FAIL critical issues${NC}"
    exit 1
fi
