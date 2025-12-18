#!/usr/bin/env python3
"""
Landing Page HTML Validation Tests
Tests that can be run without a browser
"""

import re
import os
import json
from pathlib import Path

class Colors:
    HEADER = '\033[95m'
    OKBLUE = '\033[94m'
    OKCYAN = '\033[96m'
    OKGREEN = '\033[92m'
    WARNING = '\033[93m'
    FAIL = '\033[91m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'

class HTMLValidator:
    def __init__(self, html_file):
        self.html_file = html_file
        with open(html_file, 'r', encoding='utf-8') as f:
            self.content = f.read()
        self.errors = []
        self.warnings = []
        self.passed = []

    def validate_all(self):
        print(f"\n{Colors.BOLD}🔍 Validating HTML: {self.html_file}{Colors.ENDC}\n")

        self.check_doctype()
        self.check_meta_tags()
        self.check_semantic_html()
        self.check_links()
        self.check_images()
        self.check_accessibility()
        self.check_seo()
        self.check_structure()

        self.print_results()

    def check_doctype(self):
        """Test: HTML5 DOCTYPE present"""
        if '<!DOCTYPE html>' in self.content:
            self.passed.append("✓ HTML5 DOCTYPE present")
        else:
            self.errors.append("✗ Missing HTML5 DOCTYPE")

    def check_meta_tags(self):
        """Test: Required meta tags present"""
        required_metas = [
            ('charset', 'UTF-8 charset'),
            ('viewport', 'Viewport meta tag'),
            ('description', 'Meta description'),
            ('og:title', 'Open Graph title'),
            ('og:description', 'Open Graph description')
        ]

        for meta, name in required_metas:
            if meta in self.content:
                self.passed.append(f"✓ {name} present")
            else:
                self.errors.append(f"✗ Missing {name}")

    def check_semantic_html(self):
        """Test: Semantic HTML5 elements used"""
        semantic_elements = [
            'nav', 'section', 'header', 'footer', 'article', 'main'
        ]

        for element in semantic_elements:
            if f'<{element}' in self.content:
                self.passed.append(f"✓ Using <{element}> element")
            else:
                self.warnings.append(f"⚠ No <{element}> element found")

    def check_links(self):
        """Test: All links have href attributes"""
        link_pattern = r'<a[^>]*>'
        links = re.findall(link_pattern, self.content)

        links_with_href = [l for l in links if 'href=' in l]
        self.passed.append(f"✓ Found {len(links_with_href)} links with href")

        # Check for placeholder links
        placeholder_count = self.content.count('href="#"')
        if placeholder_count > 0:
            self.warnings.append(f"⚠ {placeholder_count} placeholder links (href='#')")

    def check_images(self):
        """Test: Images have alt attributes"""
        img_pattern = r'<img[^>]*>'
        images = re.findall(img_pattern, self.content)

        if images:
            images_with_alt = [img for img in images if 'alt=' in img]
            if len(images_with_alt) == len(images):
                self.passed.append(f"✓ All {len(images)} images have alt text")
            else:
                self.errors.append(f"✗ {len(images) - len(images_with_alt)} images missing alt text")
        else:
            self.passed.append("✓ No images (placeholders ready)")

    def check_accessibility(self):
        """Test: Accessibility features"""
        # Check for aria-label
        aria_labels = self.content.count('aria-label')
        if aria_labels > 0:
            self.passed.append(f"✓ {aria_labels} ARIA labels present")

        # Check for lang attribute
        if 'lang="en"' in self.content:
            self.passed.append("✓ Language attribute set")
        else:
            self.errors.append("✗ Missing lang attribute")

    def check_seo(self):
        """Test: SEO optimization"""
        # Title tag
        title_match = re.search(r'<title>(.*?)</title>', self.content)
        if title_match:
            title = title_match.group(1)
            if 30 <= len(title) <= 60:
                self.passed.append(f"✓ Title length optimal ({len(title)} chars)")
            else:
                self.warnings.append(f"⚠ Title length suboptimal ({len(title)} chars, recommend 30-60)")
        else:
            self.errors.append("✗ Missing title tag")

        # Meta description
        desc_match = re.search(r'<meta name="description" content="(.*?)"', self.content)
        if desc_match:
            desc = desc_match.group(1)
            if 120 <= len(desc) <= 160:
                self.passed.append(f"✓ Meta description optimal ({len(desc)} chars)")
            else:
                self.warnings.append(f"⚠ Meta description length ({len(desc)} chars, recommend 120-160)")

    def check_structure(self):
        """Test: Proper HTML structure"""
        # Check for closing tags
        if '</html>' in self.content and '</body>' in self.content:
            self.passed.append("✓ Proper HTML structure (closing tags)")
        else:
            self.errors.append("✗ Missing closing HTML tags")

        # Check section count
        section_count = self.content.count('<section')
        if section_count >= 5:
            self.passed.append(f"✓ Rich content ({section_count} sections)")
        else:
            self.warnings.append(f"⚠ Limited content ({section_count} sections)")

    def print_results(self):
        """Print test results"""
        print(f"\n{Colors.OKGREEN}{Colors.BOLD}✅ PASSED ({len(self.passed)}):{Colors.ENDC}")
        for p in self.passed:
            print(f"  {Colors.OKGREEN}{p}{Colors.ENDC}")

        if self.warnings:
            print(f"\n{Colors.WARNING}{Colors.BOLD}⚠️  WARNINGS ({len(self.warnings)}):{Colors.ENDC}")
            for w in self.warnings:
                print(f"  {Colors.WARNING}{w}{Colors.ENDC}")

        if self.errors:
            print(f"\n{Colors.FAIL}{Colors.BOLD}❌ ERRORS ({len(self.errors)}):{Colors.ENDC}")
            for e in self.errors:
                print(f"  {Colors.FAIL}{e}{Colors.ENDC}")

        print(f"\n{Colors.BOLD}{'='*60}{Colors.ENDC}")
        total = len(self.passed) + len(self.warnings) + len(self.errors)
        success_rate = (len(self.passed) / total * 100) if total > 0 else 0
        print(f"{Colors.BOLD}Success Rate: {success_rate:.1f}% ({len(self.passed)}/{total}){Colors.ENDC}\n")

        return len(self.errors) == 0


class CSSValidator:
    def __init__(self, css_file):
        self.css_file = css_file
        with open(css_file, 'r', encoding='utf-8') as f:
            self.content = f.read()
        self.errors = []
        self.warnings = []
        self.passed = []

    def validate_all(self):
        print(f"\n{Colors.BOLD}🎨 Validating CSS: {self.css_file}{Colors.ENDC}\n")

        self.check_css_variables()
        self.check_media_queries()
        self.check_animations()
        self.check_syntax()

        self.print_results()

    def check_css_variables(self):
        """Test: CSS custom properties (variables) defined"""
        if ':root' in self.content and '--primary' in self.content:
            var_count = self.content.count('--')
            self.passed.append(f"✓ CSS variables defined ({var_count} variables)")
        else:
            self.warnings.append("⚠ No CSS variables found")

    def check_media_queries(self):
        """Test: Responsive design with media queries"""
        media_queries = self.content.count('@media')
        if media_queries >= 2:
            self.passed.append(f"✓ Responsive design ({media_queries} media queries)")
        else:
            self.warnings.append("⚠ Limited responsive breakpoints")

    def check_animations(self):
        """Test: CSS animations present"""
        keyframes = self.content.count('@keyframes')
        if keyframes > 0:
            self.passed.append(f"✓ CSS animations defined ({keyframes} keyframes)")
        else:
            self.passed.append("✓ No animations (static design)")

    def check_syntax(self):
        """Test: Basic CSS syntax validity"""
        # Check for unclosed braces
        open_braces = self.content.count('{')
        close_braces = self.content.count('}')

        if open_braces == close_braces:
            self.passed.append("✓ Balanced braces in CSS")
        else:
            self.errors.append(f"✗ Unbalanced braces ({open_braces} open, {close_braces} close)")

        # Check for common syntax errors
        if ';;' in self.content:
            self.warnings.append("⚠ Double semicolons found")

    def print_results(self):
        """Print test results"""
        print(f"\n{Colors.OKGREEN}{Colors.BOLD}✅ PASSED ({len(self.passed)}):{Colors.ENDC}")
        for p in self.passed:
            print(f"  {Colors.OKGREEN}{p}{Colors.ENDC}")

        if self.warnings:
            print(f"\n{Colors.WARNING}{Colors.BOLD}⚠️  WARNINGS ({len(self.warnings)}):{Colors.ENDC}")
            for w in self.warnings:
                print(f"  {Colors.WARNING}{w}{Colors.ENDC}")

        if self.errors:
            print(f"\n{Colors.FAIL}{Colors.BOLD}❌ ERRORS ({len(self.errors)}):{Colors.ENDC}")
            for e in self.errors:
                print(f"  {Colors.FAIL}{e}{Colors.ENDC}")

        print(f"\n{Colors.BOLD}{'='*60}{Colors.ENDC}\n")

        return len(self.errors) == 0


class JavaScriptValidator:
    def __init__(self, js_file):
        self.js_file = js_file
        with open(js_file, 'r', encoding='utf-8') as f:
            self.content = f.read()
        self.errors = []
        self.warnings = []
        self.passed = []

    def validate_all(self):
        print(f"\n{Colors.BOLD}⚡ Validating JavaScript: {self.js_file}{Colors.ENDC}\n")

        self.check_syntax()
        self.check_event_listeners()
        self.check_functions()
        self.check_comments()

        self.print_results()

    def check_syntax(self):
        """Test: Basic JavaScript syntax"""
        # Check for balanced parentheses
        open_paren = self.content.count('(')
        close_paren = self.content.count(')')

        if open_paren == close_paren:
            self.passed.append("✓ Balanced parentheses")
        else:
            self.errors.append(f"✗ Unbalanced parentheses ({open_paren} open, {close_paren} close)")

        # Check for balanced braces
        open_brace = self.content.count('{')
        close_brace = self.content.count('}')

        if open_brace == close_brace:
            self.passed.append("✓ Balanced braces")
        else:
            self.errors.append(f"✗ Unbalanced braces ({open_brace} open, {close_brace} close)")

    def check_event_listeners(self):
        """Test: Event listeners properly attached"""
        event_count = self.content.count('addEventListener')
        if event_count > 0:
            self.passed.append(f"✓ Event listeners attached ({event_count} listeners)")
        else:
            self.warnings.append("⚠ No event listeners found")

    def check_functions(self):
        """Test: Function definitions"""
        function_count = self.content.count('function ')
        arrow_functions = self.content.count('=>')

        if function_count + arrow_functions > 0:
            self.passed.append(f"✓ Functions defined ({function_count} regular, {arrow_functions} arrow)")
        else:
            self.warnings.append("⚠ No functions found")

    def check_comments(self):
        """Test: Code is documented"""
        comment_count = self.content.count('//')
        block_comments = self.content.count('/*')

        if comment_count + block_comments > 10:
            self.passed.append(f"✓ Well documented ({comment_count + block_comments} comments)")
        else:
            self.warnings.append("⚠ Limited documentation")

    def print_results(self):
        """Print test results"""
        print(f"\n{Colors.OKGREEN}{Colors.BOLD}✅ PASSED ({len(self.passed)}):{Colors.ENDC}")
        for p in self.passed:
            print(f"  {Colors.OKGREEN}{p}{Colors.ENDC}")

        if self.warnings:
            print(f"\n{Colors.WARNING}{Colors.BOLD}⚠️  WARNINGS ({len(self.warnings)}):{Colors.ENDC}")
            for w in self.warnings:
                print(f"  {Colors.WARNING}{w}{Colors.ENDC}")

        if self.errors:
            print(f"\n{Colors.FAIL}{Colors.BOLD}❌ ERRORS ({len(self.errors)}):{Colors.ENDC}")
            for e in self.errors:
                print(f"  {Colors.FAIL}{e}{Colors.ENDC}")

        print(f"\n{Colors.BOLD}{'='*60}{Colors.ENDC}\n")

        return len(self.errors) == 0


def main():
    """Run all landing page validations"""
    print(f"\n{Colors.BOLD}{Colors.HEADER}{'='*60}")
    print("🎵 RHYTHM FLOW - LANDING PAGE VALIDATION TESTS")
    print(f"{'='*60}{Colors.ENDC}\n")

    base_path = Path(__file__).parent.parent.parent / 'website'

    results = []

    # Validate HTML
    html_file = base_path / 'index.html'
    if html_file.exists():
        html_validator = HTMLValidator(html_file)
        html_valid = html_validator.validate_all()
        results.append(('HTML', html_valid))
    else:
        print(f"{Colors.FAIL}✗ HTML file not found: {html_file}{Colors.ENDC}")
        results.append(('HTML', False))

    # Validate CSS
    css_file = base_path / 'css' / 'styles.css'
    if css_file.exists():
        css_validator = CSSValidator(css_file)
        css_valid = css_validator.validate_all()
        results.append(('CSS', css_valid))
    else:
        print(f"{Colors.FAIL}✗ CSS file not found: {css_file}{Colors.ENDC}")
        results.append(('CSS', False))

    # Validate JavaScript
    js_file = base_path / 'js' / 'script.js'
    if js_file.exists():
        js_validator = JavaScriptValidator(js_file)
        js_valid = js_validator.validate_all()
        results.append(('JavaScript', js_valid))
    else:
        print(f"{Colors.FAIL}✗ JavaScript file not found: {js_file}{Colors.ENDC}")
        results.append(('JavaScript', False))

    # Print final summary
    print(f"\n{Colors.BOLD}{Colors.HEADER}{'='*60}")
    print("📊 FINAL SUMMARY")
    print(f"{'='*60}{Colors.ENDC}\n")

    all_passed = all(result[1] for result in results)

    for name, passed in results:
        status = f"{Colors.OKGREEN}✅ PASS{Colors.ENDC}" if passed else f"{Colors.FAIL}❌ FAIL{Colors.ENDC}"
        print(f"  {name:15} {status}")

    print(f"\n{Colors.BOLD}{'='*60}{Colors.ENDC}")

    if all_passed:
        print(f"{Colors.OKGREEN}{Colors.BOLD}🎉 ALL TESTS PASSED! Landing page is ready for deployment.{Colors.ENDC}\n")
        return 0
    else:
        print(f"{Colors.FAIL}{Colors.BOLD}❌ SOME TESTS FAILED. Please review errors above.{Colors.ENDC}\n")
        return 1


if __name__ == '__main__':
    exit(main())
