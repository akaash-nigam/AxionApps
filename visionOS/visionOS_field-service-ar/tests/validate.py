#!/usr/bin/env python3
"""
Field Service AR - Validation Test Suite
Validates project structure, HTML, CSS, documentation, and more.
"""

import os
import sys
import json
import re
from pathlib import Path
from typing import List, Tuple, Dict

# ANSI color codes
GREEN = '\033[92m'
RED = '\033[91m'
YELLOW = '\033[93m'
BLUE = '\033[94m'
RESET = '\033[0m'
BOLD = '\033[1m'

class TestResult:
    def __init__(self):
        self.passed = []
        self.failed = []
        self.warnings = []

    def add_pass(self, test_name: str):
        self.passed.append(test_name)

    def add_fail(self, test_name: str, message: str = ""):
        self.failed.append((test_name, message))

    def add_warning(self, test_name: str, message: str):
        self.warnings.append((test_name, message))

    def print_summary(self):
        total = len(self.passed) + len(self.failed)
        print(f"\n{BOLD}{'='*60}{RESET}")
        print(f"{BOLD}Test Summary{RESET}")
        print(f"{'='*60}")
        print(f"{GREEN}✓ Passed:{RESET} {len(self.passed)}/{total}")
        print(f"{RED}✗ Failed:{RESET} {len(self.failed)}/{total}")
        print(f"{YELLOW}⚠ Warnings:{RESET} {len(self.warnings)}")

        if self.failed:
            print(f"\n{RED}{BOLD}Failed Tests:{RESET}")
            for test, msg in self.failed:
                print(f"  {RED}✗{RESET} {test}")
                if msg:
                    print(f"    → {msg}")

        if self.warnings:
            print(f"\n{YELLOW}{BOLD}Warnings:{RESET}")
            for test, msg in self.warnings:
                print(f"  {YELLOW}⚠{RESET} {test}: {msg}")

        coverage = (len(self.passed) / total * 100) if total > 0 else 0
        print(f"\n{BOLD}Test Coverage:{RESET} {coverage:.1f}%")

        return len(self.failed) == 0


def test_project_structure(results: TestResult):
    """Validate project directory structure"""
    print(f"\n{BLUE}Testing Project Structure...{RESET}")

    required_dirs = [
        "FieldServiceAR/App",
        "FieldServiceAR/Models",
        "FieldServiceAR/Views",
        "FieldServiceAR/ViewModels",
        "FieldServiceAR/Services",
        "FieldServiceAR/Repositories",
        "FieldServiceAR/Tests",
        "landing-page",
        "landing-page/css",
        "landing-page/js",
    ]

    for dir_path in required_dirs:
        if os.path.isdir(dir_path):
            results.add_pass(f"Directory exists: {dir_path}")
            print(f"  {GREEN}✓{RESET} {dir_path}")
        else:
            results.add_fail(f"Directory missing: {dir_path}")
            print(f"  {RED}✗{RESET} {dir_path}")


def test_documentation(results: TestResult):
    """Validate documentation files"""
    print(f"\n{BLUE}Testing Documentation...{RESET}")

    docs = {
        "README.md": 100,  # Minimum lines
        "ARCHITECTURE.md": 500,
        "TECHNICAL_SPEC.md": 500,
        "DESIGN.md": 500,
        "IMPLEMENTATION_PLAN.md": 500,
        "TESTING.md": 200,
        "PROJECT_SUMMARY.md": 200,
    }

    for doc, min_lines in docs.items():
        if os.path.exists(doc):
            with open(doc, 'r') as f:
                lines = len(f.readlines())
            if lines >= min_lines:
                results.add_pass(f"{doc} ({lines} lines)")
                print(f"  {GREEN}✓{RESET} {doc} ({lines} lines)")
            else:
                results.add_warning(f"{doc}", f"Only {lines} lines (expected {min_lines}+)")
                print(f"  {YELLOW}⚠{RESET} {doc} ({lines}/{min_lines} lines)")
        else:
            results.add_fail(f"Missing: {doc}")
            print(f"  {RED}✗{RESET} {doc}")


def test_html_validity(results: TestResult):
    """Validate HTML structure"""
    print(f"\n{BLUE}Testing HTML Validity...{RESET}")

    html_file = "landing-page/index.html"
    if not os.path.exists(html_file):
        results.add_fail("HTML file missing")
        return

    with open(html_file, 'r') as f:
        content = f.read()

    # Check for essential HTML elements
    checks = [
        (r'<!DOCTYPE html>', "DOCTYPE declaration"),
        (r'<html[^>]*lang=', "Language attribute"),
        (r'<meta[^>]*charset=', "Charset meta tag"),
        (r'<meta[^>]*viewport', "Viewport meta tag"),
        (r'<title>', "Title tag"),
        (r'<meta[^>]*description', "Meta description"),
        (r'<nav', "Navigation element"),
        (r'<header|<section|<footer', "Semantic HTML5 tags"),
        (r'<h1>', "H1 heading"),
        (r'</html>', "Closing html tag"),
    ]

    for pattern, check_name in checks:
        if re.search(pattern, content, re.IGNORECASE):
            results.add_pass(f"HTML: {check_name}")
            print(f"  {GREEN}✓{RESET} {check_name}")
        else:
            results.add_fail(f"HTML: Missing {check_name}")
            print(f"  {RED}✗{RESET} {check_name}")

    # Check for no broken internal links
    internal_links = re.findall(r'href=["\'](#[^"\']+)["\']', content)
    for link in internal_links:
        section_id = link[1:]  # Remove #
        if re.search(rf'id=["\']' + section_id, content):
            results.add_pass(f"Internal link valid: {link}")
        else:
            results.add_warning("Internal link", f"Target missing: {link}")


def test_css_validity(results: TestResult):
    """Validate CSS structure"""
    print(f"\n{BLUE}Testing CSS Validity...{RESET}")

    css_file = "landing-page/css/styles.css"
    if not os.path.exists(css_file):
        results.add_fail("CSS file missing")
        return

    with open(css_file, 'r') as f:
        content = f.read()

    # Check for essential CSS features
    checks = [
        (r':root\s*{', "CSS variables defined"),
        (r'@media', "Responsive design (media queries)"),
        (r'@keyframes', "CSS animations"),
        (r'\.container', "Container class"),
        (r'\.btn', "Button classes"),
        (r'transition:', "Transitions defined"),
        (r'grid-template', "CSS Grid layout"),
        (r'flex', "Flexbox layout"),
    ]

    for pattern, check_name in checks:
        if re.search(pattern, content):
            results.add_pass(f"CSS: {check_name}")
            print(f"  {GREEN}✓{RESET} {check_name}")
        else:
            results.add_warning("CSS", f"Missing: {check_name}")

    # Check for balanced braces
    open_braces = content.count('{')
    close_braces = content.count('}')
    if open_braces == close_braces:
        results.add_pass("CSS: Balanced braces")
        print(f"  {GREEN}✓{RESET} Balanced braces ({open_braces})")
    else:
        results.add_fail(f"CSS: Unbalanced braces ({{ {open_braces}, }} {close_braces})")
        print(f"  {RED}✗{RESET} Unbalanced braces")


def test_javascript_validity(results: TestResult):
    """Validate JavaScript structure"""
    print(f"\n{BLUE}Testing JavaScript Validity...{RESET}")

    js_file = "landing-page/js/script.js"
    if not os.path.exists(js_file):
        results.add_fail("JavaScript file missing")
        return

    with open(js_file, 'r') as f:
        content = f.read()

    # Check for essential JS features
    checks = [
        (r'addEventListener', "Event listeners"),
        (r'querySelector|getElementById', "DOM manipulation"),
        (r'function\s+\w+|const\s+\w+\s*=\s*\(', "Functions defined"),
        (r'async|await', "Async/await usage"),
        (r'try\s*{', "Error handling (try/catch)"),
        (r'IntersectionObserver', "Intersection Observer API"),
        (r'\.forEach|\.map|\.filter', "Array methods"),
    ]

    for pattern, check_name in checks:
        if re.search(pattern, content):
            results.add_pass(f"JavaScript: {check_name}")
            print(f"  {GREEN}✓{RESET} {check_name}")
        else:
            results.add_warning("JavaScript", f"Not found: {check_name}")

    # Check for no console.log (except in dev mode)
    console_logs = re.findall(r'console\.log', content)
    if len(console_logs) > 5:
        results.add_warning("JavaScript", f"{len(console_logs)} console.log statements found")


def test_swift_files(results: TestResult):
    """Validate Swift file structure"""
    print(f"\n{BLUE}Testing Swift Files...{RESET}")

    swift_files = list(Path("FieldServiceAR").rglob("*.swift"))

    if len(swift_files) == 0:
        results.add_fail("No Swift files found")
        return

    results.add_pass(f"Found {len(swift_files)} Swift files")
    print(f"  {GREEN}✓{RESET} Found {len(swift_files)} Swift files")

    # Check key files exist
    key_files = [
        "FieldServiceARApp.swift",
        "AppState.swift",
        "DependencyContainer.swift",
        "Equipment.swift",
        "ServiceJob.swift",
        "DashboardView.swift",
    ]

    for key_file in key_files:
        found = any(key_file in str(f) for f in swift_files)
        if found:
            results.add_pass(f"Key file exists: {key_file}")
            print(f"  {GREEN}✓{RESET} {key_file}")
        else:
            results.add_fail(f"Key file missing: {key_file}")
            print(f"  {RED}✗{RESET} {key_file}")


def test_file_naming_conventions(results: TestResult):
    """Validate file naming conventions"""
    print(f"\n{BLUE}Testing File Naming Conventions...{RESET}")

    swift_files = list(Path("FieldServiceAR").rglob("*.swift"))

    violations = []
    for file_path in swift_files:
        filename = file_path.name
        # Swift files should be PascalCase
        if not re.match(r'^[A-Z][a-zA-Z0-9]*\.swift$', filename):
            violations.append(filename)

    if violations:
        results.add_warning("File naming", f"{len(violations)} files don't follow PascalCase convention")
        for v in violations[:5]:  # Show first 5
            print(f"  {YELLOW}⚠{RESET} {v}")
    else:
        results.add_pass("All Swift files follow naming convention")
        print(f"  {GREEN}✓{RESET} All Swift files use PascalCase")


def test_code_metrics(results: TestResult):
    """Calculate code metrics"""
    print(f"\n{BLUE}Code Metrics...{RESET}")

    swift_files = list(Path("FieldServiceAR").rglob("*.swift"))
    md_files = list(Path(".").glob("*.md"))

    swift_lines = sum(len(open(f).readlines()) for f in swift_files)
    doc_lines = sum(len(open(f).readlines()) for f in md_files)

    print(f"  {BLUE}📊{RESET} Swift Files: {len(swift_files)} files, {swift_lines} lines")
    print(f"  {BLUE}📊{RESET} Documentation: {len(md_files)} files, {doc_lines} lines")

    results.add_pass(f"Code metrics calculated ({swift_lines} Swift lines)")

    # Check documentation-to-code ratio
    if doc_lines > swift_lines * 0.5:
        results.add_pass("Good documentation coverage")
        print(f"  {GREEN}✓{RESET} Documentation coverage: {(doc_lines/swift_lines*100):.0f}%")
    else:
        results.add_warning("Documentation", f"Low doc coverage: {(doc_lines/swift_lines*100):.0f}%")


def test_landing_page_performance(results: TestResult):
    """Test landing page performance metrics"""
    print(f"\n{BLUE}Testing Landing Page Performance...{RESET}")

    # Check file sizes
    html_size = os.path.getsize("landing-page/index.html") / 1024  # KB
    css_size = os.path.getsize("landing-page/css/styles.css") / 1024
    js_size = os.path.getsize("landing-page/js/script.js") / 1024

    total_size = html_size + css_size + js_size

    print(f"  {BLUE}📦{RESET} HTML: {html_size:.1f} KB")
    print(f"  {BLUE}📦{RESET} CSS: {css_size:.1f} KB")
    print(f"  {BLUE}📦{RESET} JavaScript: {js_size:.1f} KB")
    print(f"  {BLUE}📦{RESET} Total: {total_size:.1f} KB")

    # Performance checks
    if total_size < 200:  # 200 KB target
        results.add_pass(f"Page size optimal: {total_size:.1f} KB")
        print(f"  {GREEN}✓{RESET} Page size optimal")
    else:
        results.add_warning("Performance", f"Page size: {total_size:.1f} KB (target: <200 KB)")

    # Check for minification opportunities
    with open("landing-page/css/styles.css") as f:
        css = f.read()
        if len(re.findall(r'\n\s*\n', css)) > 50:
            results.add_warning("Optimization", "CSS could be minified")
        else:
            results.add_pass("CSS is reasonably compact")


def main():
    print(f"{BOLD}{BLUE}")
    print("=" * 60)
    print("  Field Service AR - Validation Test Suite")
    print("=" * 60)
    print(f"{RESET}\n")

    results = TestResult()

    # Run all test suites
    test_project_structure(results)
    test_documentation(results)
    test_html_validity(results)
    test_css_validity(results)
    test_javascript_validity(results)
    test_swift_files(results)
    test_file_naming_conventions(results)
    test_code_metrics(results)
    test_landing_page_performance(results)

    # Print summary
    success = results.print_summary()

    print(f"\n{BOLD}{'='*60}{RESET}\n")

    sys.exit(0 if success else 1)


if __name__ == "__main__":
    main()
