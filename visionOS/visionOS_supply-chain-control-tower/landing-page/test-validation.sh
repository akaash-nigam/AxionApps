#!/bin/bash

echo "🧪 Landing Page Validation Report"
echo "=================================="
echo ""

# Check if files exist
echo "📁 File Structure Check:"
[ -f "index.html" ] && echo "✓ index.html exists" || echo "✗ index.html missing"
[ -f "css/styles.css" ] && echo "✓ styles.css exists" || echo "✗ styles.css missing"
[ -f "js/main.js" ] && echo "✓ main.js exists" || echo "✗ main.js missing"
[ -d "images" ] && echo "✓ images directory exists" || echo "✗ images directory missing"
echo ""

# Count sections
echo "📊 Content Analysis:"
SECTIONS=$(grep -c "<section" index.html)
echo "  Sections: $SECTIONS"

BUTTONS=$(grep -c "btn-" index.html)
echo "  CTA Buttons: $BUTTONS"

FEATURES=$(grep -c "feature-card" index.html)
echo "  Feature Cards: $FEATURES"

TESTIMONIALS=$(grep -c "testimonial-card" index.html)
echo "  Testimonials: $TESTIMONIALS"

echo ""

# File sizes
echo "📦 File Sizes:"
HTML_SIZE=$(wc -c < index.html)
CSS_SIZE=$(wc -c < css/styles.css)
JS_SIZE=$(wc -c < js/main.js)

echo "  HTML: $(echo "scale=2; $HTML_SIZE/1024" | bc) KB"
echo "  CSS:  $(echo "scale=2; $CSS_SIZE/1024" | bc) KB"
echo "  JS:   $(echo "scale=2; $JS_SIZE/1024" | bc) KB"
echo "  Total: $(echo "scale=2; ($HTML_SIZE+$CSS_SIZE+$JS_SIZE)/1024" | bc) KB"

echo ""

# Check for common issues
echo "🔍 Quality Checks:"
HAS_TITLE=$(grep -c "<title>" index.html)
[ $HAS_TITLE -gt 0 ] && echo "✓ Page title present" || echo "✗ Missing page title"

HAS_META=$(grep -c 'meta name="description"' index.html)
[ $HAS_META -gt 0 ] && echo "✓ Meta description present" || echo "✗ Missing meta description"

HAS_VIEWPORT=$(grep -c 'meta name="viewport"' index.html)
[ $HAS_VIEWPORT -gt 0 ] && echo "✓ Viewport meta present" || echo "✗ Missing viewport meta"

HAS_FONTS=$(grep -c "fonts.googleapis.com" index.html)
[ $HAS_FONTS -gt 0 ] && echo "✓ Google Fonts loaded" || echo "✗ No Google Fonts"

echo ""

# CSS checks
echo "🎨 CSS Analysis:"
CSS_LINES=$(wc -l < css/styles.css)
echo "  Total lines: $CSS_LINES"

MEDIA_QUERIES=$(grep -c "@media" css/styles.css)
echo "  Media queries: $MEDIA_QUERIES (responsive)"

ANIMATIONS=$(grep -c "@keyframes" css/styles.css)
echo "  Animations: $ANIMATIONS"

echo ""

# JS checks
echo "⚡ JavaScript Analysis:"
JS_LINES=$(wc -l < js/main.js)
echo "  Total lines: $JS_LINES"

CLASSES=$(grep -c "^class " js/main.js)
echo "  Classes: $CLASSES"

EVENT_LISTENERS=$(grep -c "addEventListener" js/main.js)
echo "  Event listeners: $EVENT_LISTENERS"

echo ""

echo "✅ Validation Complete!"
echo ""
echo "🌐 Server running at: http://localhost:8080"
echo "   Open in browser to test interactivity"

