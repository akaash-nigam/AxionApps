#!/usr/bin/env python3
"""
Landing Page Test Suite - Validates HTML, CSS, JS structure and content
"""

import re
import json
from pathlib import Path

# ANSI color codes
GREEN = '\033[92m'
RED = '\033[91m'
CYAN = '\033[96m'
RESET = '\033[0m'
BOLD = '\033[1m'

class TestResult:
    def __init__(self):
        self.passed = 0
        self.failed = 0
        self.tests = []

    def add_pass(self, test_name: str):
        self.passed += 1
        self.tests.append((test_name, True))
        print(f"{GREEN}✓{RESET} {test_name}")

    def add_fail(self, test_name: str, error: str):
        self.failed += 1
        self.tests.append((test_name, False, error))
        print(f"{RED}✗{RESET} {test_name}")
        print(f"  {RED}Error: {error}{RESET}")

results = TestResult()

print(f"\n{BOLD}{CYAN}{'=' * 80}{RESET}")
print(f"{BOLD}{CYAN}🌐 Landing Page Test Suite{RESET}")
print(f"{BOLD}{CYAN}{'=' * 80}{RESET}\n")

# ==============================================================================
# Test Suite 1: File Structure
# ==============================================================================

print(f"{BOLD}{CYAN}📋 Test Suite 1: File Structure{RESET}")
print(f"{CYAN}{'-' * 80}{RESET}\n")

landing_page_dir = Path("/home/user/visionOS_spatial-meeting-platform/landing-page")

# Check required files exist
required_files = [
    "index.html",
    "css/styles.css",
    "js/main.js",
    "README.md",
    "DEPLOYMENT.md"
]

for file in required_files:
    file_path = landing_page_dir / file
    if file_path.exists():
        results.add_pass(f"File exists: {file}")
    else:
        results.add_fail(f"File exists: {file}", f"File not found at {file_path}")

print()

# ==============================================================================
# Test Suite 2: HTML Structure & Content
# ==============================================================================

print(f"{BOLD}{CYAN}📋 Test Suite 2: HTML Structure & Content{RESET}")
print(f"{CYAN}{'-' * 80}{RESET}\n")

html_path = landing_page_dir / "index.html"
html_content = html_path.read_text()

# Check HTML5 doctype
if html_content.startswith("<!DOCTYPE html>"):
    results.add_pass("HTML5 doctype present")
else:
    results.add_fail("HTML5 doctype present", "Missing or incorrect doctype")

# Check meta tags
meta_checks = [
    (r'<meta charset="UTF-8">', "UTF-8 charset meta tag"),
    (r'<meta name="viewport"', "Viewport meta tag"),
    (r'<meta name="description"', "Description meta tag"),
]

for pattern, test_name in meta_checks:
    if re.search(pattern, html_content):
        results.add_pass(test_name)
    else:
        results.add_fail(test_name, "Meta tag not found")

# Check title
if re.search(r'<title>.*Spatial Meeting Platform.*</title>', html_content):
    results.add_pass("Page title present")
else:
    results.add_fail("Page title present", "Title missing or incorrect")

# Check CSS link
if re.search(r'<link rel="stylesheet" href="css/styles\.css">', html_content):
    results.add_pass("CSS stylesheet linked")
else:
    results.add_fail("CSS stylesheet linked", "CSS link not found")

# Check JavaScript file
if re.search(r'<script src="js/main\.js"', html_content):
    results.add_pass("JavaScript file linked")
else:
    results.add_fail("JavaScript file linked", "JS link not found")

# Check sections
sections = [
    ("hero", "Hero section"),
    ("problem-section", "Problem section"),
    ("solution-section", "Solution section"),
    ("features-section", "Features section"),
    ("benefits-section", "Benefits section"),
    ("pricing-section", "Pricing section"),
    ("testimonials-section", "Testimonials section"),
    ("cta-section", "CTA section"),
]

for class_name, test_name in sections:
    if re.search(rf'<section[^>]*class="[^"]*{class_name}[^"]*"', html_content):
        results.add_pass(test_name)
    else:
        results.add_fail(test_name, f"Section with class '{class_name}' not found")

# Check CTAs
cta_count = html_content.count("Start Free Trial")
if cta_count >= 3:
    results.add_pass(f"Multiple CTAs present ({cta_count} found)")
else:
    results.add_fail("Multiple CTAs present", f"Only {cta_count} CTAs found")

# Check navigation
if re.search(r'<nav[^>]*class="[^"]*nav[^"]*"', html_content):
    results.add_pass("Navigation element present")
else:
    results.add_fail("Navigation element present", "Nav element not found")

# Check key value propositions
value_props = ["40%", "5x", "60%"]
for prop in value_props:
    if prop in html_content:
        results.add_pass(f"Value proposition '{prop}' present")
    else:
        results.add_fail(f"Value proposition '{prop}' present", f"'{prop}' not found in HTML")

# Check pricing tiers
pricing_tiers = ["Team", "Business", "Enterprise"]
for tier in pricing_tiers:
    if tier in html_content:
        results.add_pass(f"Pricing tier '{tier}' present")
    else:
        results.add_fail(f"Pricing tier '{tier}' present", f"'{tier}' not found in HTML")

print()

# ==============================================================================
# Test Suite 3: CSS Structure & Quality
# ==============================================================================

print(f"{BOLD}{CYAN}📋 Test Suite 3: CSS Structure & Quality{RESET}")
print(f"{CYAN}{'-' * 80}{RESET}\n")

css_path = landing_page_dir / "css/styles.css"
css_content = css_path.read_text()

# Check CSS variables
if re.search(r':root\s*\{', css_content):
    results.add_pass("CSS custom properties (variables) defined")
else:
    results.add_fail("CSS custom properties defined", "No :root selector found")

# Check responsive design
media_queries = re.findall(r'@media[^{]+\{', css_content)
if len(media_queries) >= 2:
    results.add_pass(f"Responsive media queries present ({len(media_queries)} found)")
else:
    results.add_fail("Responsive media queries", f"Only {len(media_queries)} found")

# Check animations
keyframes = re.findall(r'@keyframes\s+(\w+)', css_content)
if len(keyframes) >= 1:
    results.add_pass(f"CSS animations defined ({', '.join(keyframes)})")
else:
    results.add_fail("CSS animations defined", "No @keyframes found")

# Check modern CSS features
modern_features = [
    (r'display:\s*grid', "CSS Grid"),
    (r'display:\s*flex', "Flexbox"),
    (r'backdrop-filter:', "Backdrop filter (glassmorphism)"),
    (r'transition:', "CSS transitions"),
]

for pattern, feature_name in modern_features:
    if re.search(pattern, css_content):
        results.add_pass(f"{feature_name} used")
    else:
        results.add_fail(f"{feature_name} used", f"{feature_name} not found")

# Check file size
css_size = len(css_content)
if css_size < 30000:  # Less than 30KB
    results.add_pass(f"CSS file size reasonable ({css_size} bytes)")
else:
    results.add_fail("CSS file size", f"File too large: {css_size} bytes")

print()

# ==============================================================================
# Test Suite 4: JavaScript Functionality
# ==============================================================================

print(f"{BOLD}{CYAN}📋 Test Suite 4: JavaScript Functionality{RESET}")
print(f"{CYAN}{'-' * 80}{RESET}\n")

js_path = landing_page_dir / "js/main.js"
js_content = js_path.read_text()

# Check event listeners
event_listeners = [
    ("addEventListener", "Event listeners"),
    ("querySelector", "DOM queries"),
]

for pattern, feature_name in event_listeners:
    if pattern in js_content:
        results.add_pass(f"{feature_name} implemented")
    else:
        results.add_fail(f"{feature_name} implemented", f"{pattern} not found")

# Check modern JS features
js_features = [
    (r'IntersectionObserver', "Intersection Observer API"),
    (r'window\.scroll', "Scroll handling"),
]

for pattern, feature_name in js_features:
    if re.search(pattern, js_content):
        results.add_pass(f"{feature_name} used")
    else:
        results.add_fail(f"{feature_name} used", f"{feature_name} not found")

# Check file size
js_size = len(js_content)
if js_size < 20000:  # Less than 20KB
    results.add_pass(f"JavaScript file size reasonable ({js_size} bytes)")
else:
    results.add_fail("JavaScript file size", f"File too large: {js_size} bytes")

# Check for console.log (should be removed in production)
console_logs = len(re.findall(r'console\.log', js_content))
if console_logs == 0:
    results.add_pass("No console.log statements (production ready)")
else:
    results.add_fail("No console.log statements", f"Found {console_logs} console.log statements")

print()

# ==============================================================================
# Test Suite 5: SEO & Accessibility
# ==============================================================================

print(f"{BOLD}{CYAN}📋 Test Suite 5: SEO & Accessibility{RESET}")
print(f"{CYAN}{'-' * 80}{RESET}\n")

# Check semantic HTML
semantic_tags = [
    (r'<header', "Semantic header tag"),
    (r'<nav', "Semantic nav tag"),
    (r'<main', "Semantic main tag"),
    (r'<section', "Semantic section tag"),
    (r'<footer', "Semantic footer tag"),
]

for pattern, test_name in semantic_tags:
    if re.search(pattern, html_content):
        results.add_pass(test_name)
    else:
        results.add_fail(test_name, f"{pattern} not found")

# Check heading hierarchy
h1_count = len(re.findall(r'<h1[^>]*>', html_content))
if h1_count == 1:
    results.add_pass("Single H1 tag (SEO best practice)")
elif h1_count == 0:
    results.add_fail("Single H1 tag", "No H1 tag found")
else:
    results.add_fail("Single H1 tag", f"Multiple H1 tags found ({h1_count})")

# Check for headings
for i in range(2, 5):
    if re.search(rf'<h{i}[^>]*>', html_content):
        results.add_pass(f"H{i} headings present")
    else:
        results.add_fail(f"H{i} headings present", f"No H{i} tags found")

# Check description length
desc_match = re.search(r'<meta name="description" content="([^"]+)"', html_content)
if desc_match:
    desc_length = len(desc_match.group(1))
    if 120 <= desc_length <= 160:
        results.add_pass(f"Meta description optimal length ({desc_length} chars)")
    else:
        results.add_fail("Meta description optimal length", f"Length {desc_length} chars (should be 120-160)")
else:
    results.add_fail("Meta description optimal length", "No description meta tag found")

print()

# ==============================================================================
# Test Suite 6: Content Quality
# ==============================================================================

print(f"{BOLD}{CYAN}📋 Test Suite 6: Content Quality{RESET}")
print(f"{CYAN}{'-' * 80}{RESET}\n")

# Check for key features mentioned
features = [
    ("Spatial", "Spatial technology mentioned"),
    ("visionOS", "visionOS mentioned"),
    ("3D", "3D mentioned"),
    ("immersive", "Immersive experience mentioned"),
]

for keyword, test_name in features:
    if re.search(keyword, html_content, re.IGNORECASE):
        results.add_pass(test_name)
    else:
        results.add_fail(test_name, f"Keyword '{keyword}' not found")

# Check for social proof
social_proof = [
    ("testimonial", "Testimonials present"),
]

for keyword, test_name in social_proof:
    if re.search(keyword, html_content, re.IGNORECASE):
        results.add_pass(test_name)
    else:
        results.add_fail(test_name, f"'{keyword}' section not found")

# Check total content length (should be substantial)
html_length = len(html_content)
if html_length > 15000:
    results.add_pass(f"Substantial content ({html_length} characters)")
else:
    results.add_fail("Substantial content", f"Only {html_length} characters")

print()

# ==============================================================================
# Test Suite 7: Performance
# ==============================================================================

print(f"{BOLD}{CYAN}📋 Test Suite 7: Performance{RESET}")
print(f"{CYAN}{'-' * 80}{RESET}\n")

# Calculate total page weight
total_size = html_length + css_size + js_size
if total_size < 100000:  # Less than 100KB
    results.add_pass(f"Total page size excellent (<100KB): {total_size} bytes")
elif total_size < 200000:  # Less than 200KB
    results.add_pass(f"Total page size good (<200KB): {total_size} bytes")
else:
    results.add_fail("Total page size", f"Too large: {total_size} bytes")

# Check for external dependencies
google_fonts = len(re.findall(r'fonts\.googleapis\.com', html_content))
external_deps = google_fonts
if external_deps <= 2:
    results.add_pass(f"Minimal external dependencies ({external_deps} found)")
else:
    results.add_fail("Minimal external dependencies", f"{external_deps} dependencies")

# Check for inline styles (should be minimal)
inline_styles = len(re.findall(r'style="[^"]+"', html_content))
if inline_styles == 0:
    results.add_pass("No inline styles (best practice)")
elif inline_styles < 5:
    results.add_pass(f"Minimal inline styles ({inline_styles} found)")
else:
    results.add_fail("Minimal inline styles", f"Too many inline styles: {inline_styles}")

print()

# ==============================================================================
# Test Results Summary
# ==============================================================================

print(f"\n{BOLD}{CYAN}{'=' * 80}{RESET}")
print(f"{BOLD}{CYAN}📊 Landing Page Test Results{RESET}")
print(f"{BOLD}{CYAN}{'=' * 80}{RESET}\n")

total = results.passed + results.failed
pass_rate = (results.passed / total * 100) if total > 0 else 0

print(f"{BOLD}Total Tests:{RESET} {total}")
print(f"{GREEN}{BOLD}✓ Passed:{RESET} {results.passed}")
print(f"{RED}{BOLD}✗ Failed:{RESET} {results.failed}")
print(f"{BOLD}Pass Rate:{RESET} {pass_rate:.1f}%\n")

if results.failed > 0:
    print(f"{RED}{BOLD}Failed Tests:{RESET}")
    for test in results.tests:
        if not test[1]:  # Failed test
            print(f"  {RED}•{RESET} {test[0]}")
            if len(test) > 2:
                print(f"    {test[2]}")
    print()

# Grade the landing page
if pass_rate == 100:
    grade = "A+"
    status = "Perfect"
elif pass_rate >= 95:
    grade = "A"
    status = "Excellent"
elif pass_rate >= 90:
    grade = "A-"
    status = "Very Good"
elif pass_rate >= 85:
    grade = "B+"
    status = "Good"
elif pass_rate >= 80:
    grade = "B"
    status = "Acceptable"
else:
    grade = "C or below"
    status = "Needs Improvement"

print(f"{BOLD}Landing Page Grade:{RESET} {grade}")
print(f"{BOLD}Status:{RESET} {status}\n")

print(f"{BOLD}Summary:{RESET}")
print(f"  • File structure: {'✓' if all('File exists' in t[0] and t[1] for t in results.tests if 'File exists' in t[0]) else '✗'}")
print(f"  • HTML quality: {'✓' if pass_rate > 90 else '✗'}")
print(f"  • CSS quality: {'✓' if pass_rate > 90 else '✗'}")
print(f"  • JavaScript: {'✓' if pass_rate > 90 else '✗'}")
print(f"  • SEO optimized: {'✓' if pass_rate > 90 else '✗'}")
print(f"  • Performance: {'✓' if total_size < 100000 else '✗'}")

print(f"\n{BOLD}{CYAN}{'=' * 80}{RESET}")
if pass_rate >= 95:
    print(f"{GREEN}{BOLD}🎉 Landing page is production-ready!{RESET}")
else:
    print(f"{RED}{BOLD}⚠️  Landing page needs improvements before deployment.{RESET}")
print(f"{BOLD}{CYAN}{'=' * 80}{RESET}\n")

exit(0 if results.failed == 0 else 1)
