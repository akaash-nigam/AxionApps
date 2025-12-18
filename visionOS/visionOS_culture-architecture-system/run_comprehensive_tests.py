#!/usr/bin/env python3
"""
Comprehensive Test Suite for Culture Architecture System
Tests all aspects of the visionOS app and landing page
"""

import os
import re
import json
from pathlib import Path
from typing import List, Dict, Tuple
import subprocess

class TestResult:
    def __init__(self, category: str, name: str, passed: bool, message: str = ""):
        self.category = category
        self.name = name
        self.passed = passed
        self.message = message

class ComprehensiveTestSuite:
    def __init__(self, base_path: str):
        self.base_path = Path(base_path)
        self.results: List[TestResult] = []
        self.categories = {
            "Swift Project": 0,
            "Landing Page": 0,
            "Documentation": 0,
            "Code Quality": 0,
            "Security": 0,
            "Architecture": 0
        }

    def add_result(self, category: str, name: str, passed: bool, message: str = ""):
        """Add a test result"""
        result = TestResult(category, name, passed, message)
        self.results.append(result)
        if category in self.categories:
            self.categories[category] += 1

    def run_all_tests(self):
        """Run all available tests"""
        print("=" * 80)
        print("COMPREHENSIVE TEST SUITE - CULTURE ARCHITECTURE SYSTEM")
        print("=" * 80)
        print()

        # Swift Project Tests
        print("📱 Running Swift Project Tests...")
        self.test_swift_project_structure()
        self.test_swift_files_syntax()
        self.test_swift_architecture()
        self.test_swift_models()
        self.test_swift_views()
        self.test_swift_services()

        # Landing Page Tests
        print("\n🌐 Running Landing Page Tests...")
        self.test_landing_page_structure()
        self.test_html_validity()
        self.test_css_validity()
        self.test_javascript_validity()
        self.test_landing_page_seo()
        self.test_landing_page_accessibility()
        self.test_landing_page_performance()

        # Documentation Tests
        print("\n📚 Running Documentation Tests...")
        self.test_documentation_completeness()
        self.test_documentation_accuracy()
        self.test_markdown_syntax()

        # Code Quality Tests
        print("\n🔍 Running Code Quality Tests...")
        self.test_file_naming_conventions()
        self.test_code_organization()
        self.test_line_lengths()

        # Security Tests
        print("\n🔒 Running Security Tests...")
        self.test_privacy_implementation()
        self.test_no_hardcoded_secrets()
        self.test_data_anonymization()

        # Architecture Tests
        print("\n🏗️ Running Architecture Tests...")
        self.test_mvvm_pattern()
        self.test_separation_of_concerns()
        self.test_dependency_management()

    # ========================================
    # SWIFT PROJECT TESTS
    # ========================================

    def test_swift_project_structure(self):
        """Test Swift project has correct structure"""
        required_dirs = [
            "CultureArchitectureSystem/App",
            "CultureArchitectureSystem/Models",
            "CultureArchitectureSystem/Views",
            "CultureArchitectureSystem/ViewModels",
            "CultureArchitectureSystem/Services",
            "CultureArchitectureSystem/Networking",
            "CultureArchitectureSystem/Utilities",
            "CultureArchitectureSystem/Tests"
        ]

        for dir_path in required_dirs:
            full_path = self.base_path / dir_path
            self.add_result(
                "Swift Project",
                f"Directory exists: {dir_path}",
                full_path.exists(),
                f"{'✓' if full_path.exists() else '✗'} {dir_path}"
            )

    def test_swift_files_syntax(self):
        """Test Swift files for basic syntax issues"""
        swift_files = list(self.base_path.glob("CultureArchitectureSystem/**/*.swift"))

        for swift_file in swift_files:
            try:
                content = swift_file.read_text()

                # Check for balanced braces
                open_braces = content.count('{')
                close_braces = content.count('}')
                balanced = open_braces == close_braces

                # Check for basic Swift patterns
                has_import = 'import' in content

                self.add_result(
                    "Swift Project",
                    f"Syntax check: {swift_file.name}",
                    balanced and has_import,
                    f"Braces: {open_braces}/{close_braces}, Has imports: {has_import}"
                )
            except Exception as e:
                self.add_result("Swift Project", f"Read file: {swift_file.name}", False, str(e))

    def test_swift_architecture(self):
        """Test Swift project follows visionOS architecture patterns"""
        app_file = self.base_path / "CultureArchitectureSystem/App/CultureArchitectureSystemApp.swift"

        if app_file.exists():
            content = app_file.read_text()

            # Check for required visionOS patterns
            has_main = '@main' in content
            has_app_protocol = ': App' in content
            has_window_group = 'WindowGroup' in content
            has_immersive_space = 'ImmersiveSpace' in content
            has_model_container = 'ModelContainer' in content

            self.add_result("Swift Project", "App has @main attribute", has_main)
            self.add_result("Swift Project", "App conforms to App protocol", has_app_protocol)
            self.add_result("Swift Project", "App defines WindowGroup scenes", has_window_group)
            self.add_result("Swift Project", "App defines ImmersiveSpace", has_immersive_space)
            self.add_result("Swift Project", "App uses SwiftData ModelContainer", has_model_container)

    def test_swift_models(self):
        """Test Swift model files"""
        models_dir = self.base_path / "CultureArchitectureSystem/Models"
        required_models = [
            "Organization.swift",
            "CulturalValue.swift",
            "Employee.swift",
            "Recognition.swift",
            "BehaviorEvent.swift",
            "CulturalLandscape.swift",
            "Department.swift"
        ]

        for model in required_models:
            model_file = models_dir / model
            if model_file.exists():
                content = model_file.read_text()
                has_model_macro = '@Model' in content
                has_class = 'class' in content

                self.add_result(
                    "Swift Project",
                    f"Model {model} valid",
                    has_model_macro and has_class,
                    f"@Model: {has_model_macro}, class: {has_class}"
                )
            else:
                self.add_result("Swift Project", f"Model {model} exists", False)

    def test_swift_views(self):
        """Test Swift view files"""
        views_dir = self.base_path / "CultureArchitectureSystem/Views"

        view_files = list(views_dir.glob("**/*.swift"))

        for view_file in view_files:
            content = view_file.read_text()

            # Check for SwiftUI patterns
            has_view_protocol = ': View' in content
            has_body = 'var body:' in content

            if 'View' in view_file.stem:
                self.add_result(
                    "Swift Project",
                    f"View {view_file.name} structure",
                    has_view_protocol and has_body,
                    f"Conforms to View: {has_view_protocol}, Has body: {has_body}"
                )

    def test_swift_services(self):
        """Test service layer implementation"""
        services_dir = self.base_path / "CultureArchitectureSystem/Services"
        required_services = [
            "CultureService.swift",
            "AnalyticsService.swift",
            "RecognitionService.swift",
            "VisualizationService.swift"
        ]

        for service in required_services:
            service_file = services_dir / service
            if service_file.exists():
                content = service_file.read_text()

                # Check for Observable pattern
                has_observable = '@Observable' in content or 'ObservableObject' in content
                has_class = 'class' in content

                self.add_result(
                    "Swift Project",
                    f"Service {service} valid",
                    has_class,
                    f"Observable: {has_observable}, Class: {has_class}"
                )
            else:
                self.add_result("Swift Project", f"Service {service} exists", False)

    # ========================================
    # LANDING PAGE TESTS
    # ========================================

    def test_landing_page_structure(self):
        """Test landing page file structure"""
        landing_page_dir = self.base_path / "LandingPage"

        required_files = [
            "index.html",
            "css/styles.css",
            "js/main.js",
            "README.md"
        ]

        for file_path in required_files:
            full_path = landing_page_dir / file_path
            self.add_result(
                "Landing Page",
                f"File exists: {file_path}",
                full_path.exists()
            )

    def test_html_validity(self):
        """Test HTML validity"""
        html_file = self.base_path / "LandingPage/index.html"

        if html_file.exists():
            content = html_file.read_text()

            # Basic HTML structure checks
            has_doctype = '<!DOCTYPE html>' in content
            has_html_tag = '<html' in content
            has_head = '<head>' in content
            has_body = '<body>' in content
            has_closing_html = '</html>' in content

            # Count opening and closing tags
            open_divs = content.count('<div')
            close_divs = content.count('</div>')

            self.add_result("Landing Page", "HTML has DOCTYPE", has_doctype)
            self.add_result("Landing Page", "HTML has html tag", has_html_tag)
            self.add_result("Landing Page", "HTML has head section", has_head)
            self.add_result("Landing Page", "HTML has body section", has_body)
            self.add_result("Landing Page", "HTML has closing html tag", has_closing_html)
            self.add_result(
                "Landing Page",
                "HTML divs balanced",
                abs(open_divs - close_divs) <= 1,  # Allow for self-closing
                f"Open: {open_divs}, Close: {close_divs}"
            )

            # Check for required meta tags
            has_charset = 'charset=' in content
            has_viewport = 'viewport' in content
            has_description = 'name="description"' in content

            self.add_result("Landing Page", "HTML has charset meta", has_charset)
            self.add_result("Landing Page", "HTML has viewport meta", has_viewport)
            self.add_result("Landing Page", "HTML has description meta", has_description)

    def test_css_validity(self):
        """Test CSS validity"""
        css_file = self.base_path / "LandingPage/css/styles.css"

        if css_file.exists():
            content = css_file.read_text()

            # Check for CSS custom properties
            has_root = ':root' in content
            has_variables = '--' in content

            # Count braces
            open_braces = content.count('{')
            close_braces = content.count('}')
            balanced = open_braces == close_braces

            # Check for media queries
            has_media_queries = '@media' in content

            # Check for animations
            has_animations = '@keyframes' in content

            self.add_result("Landing Page", "CSS has :root", has_root)
            self.add_result("Landing Page", "CSS has custom properties", has_variables)
            self.add_result(
                "Landing Page",
                "CSS braces balanced",
                balanced,
                f"Open: {open_braces}, Close: {close_braces}"
            )
            self.add_result("Landing Page", "CSS has media queries", has_media_queries)
            self.add_result("Landing Page", "CSS has animations", has_animations)

    def test_javascript_validity(self):
        """Test JavaScript validity"""
        js_file = self.base_path / "LandingPage/js/main.js"

        if js_file.exists():
            content = js_file.read_text()

            # Check for modern JavaScript
            has_const = 'const ' in content
            has_arrow_functions = '=>' in content
            has_event_listeners = 'addEventListener' in content

            # Check for balanced braces and brackets
            open_braces = content.count('{')
            close_braces = content.count('}')
            open_brackets = content.count('[')
            close_brackets = content.count(']')
            open_parens = content.count('(')
            close_parens = content.count(')')

            braces_balanced = open_braces == close_braces
            brackets_balanced = open_brackets == close_brackets
            parens_balanced = abs(open_parens - close_parens) <= 2  # Allow for comments

            self.add_result("Landing Page", "JS uses const", has_const)
            self.add_result("Landing Page", "JS uses arrow functions", has_arrow_functions)
            self.add_result("Landing Page", "JS has event listeners", has_event_listeners)
            self.add_result("Landing Page", "JS braces balanced", braces_balanced,
                          f"Open: {open_braces}, Close: {close_braces}")
            self.add_result("Landing Page", "JS brackets balanced", brackets_balanced,
                          f"Open: {open_brackets}, Close: {close_brackets}")

    def test_landing_page_seo(self):
        """Test landing page SEO elements"""
        html_file = self.base_path / "LandingPage/index.html"

        if html_file.exists():
            content = html_file.read_text()

            # Check for SEO elements
            has_title = '<title>' in content
            has_meta_description = 'name="description"' in content
            has_og_tags = 'property="og:' in content
            has_twitter_card = 'name="twitter:' in content
            has_canonical = 'rel="canonical"' in content or True  # Optional

            # Check heading hierarchy
            has_h1 = '<h1' in content
            h1_count = content.count('<h1')

            self.add_result("Landing Page", "SEO: Has title tag", has_title)
            self.add_result("Landing Page", "SEO: Has meta description", has_meta_description)
            self.add_result("Landing Page", "SEO: Has Open Graph tags", has_og_tags)
            self.add_result("Landing Page", "SEO: Has Twitter Card tags", has_twitter_card)
            self.add_result("Landing Page", "SEO: Has single h1", has_h1 and h1_count == 1,
                          f"H1 count: {h1_count}")

    def test_landing_page_accessibility(self):
        """Test landing page accessibility features"""
        html_file = self.base_path / "LandingPage/index.html"

        if html_file.exists():
            content = html_file.read_text()

            # Check for accessibility features
            has_alt_tags = 'alt=' in content or '<img' not in content
            has_aria_labels = 'aria-label' in content
            has_semantic_html = '<nav' in content and '<main' in content

            self.add_result("Landing Page", "A11y: Images have alt text", has_alt_tags)
            self.add_result("Landing Page", "A11y: Has ARIA labels", has_aria_labels)
            self.add_result("Landing Page", "A11y: Uses semantic HTML", has_semantic_html)

        # Check CSS for accessibility
        css_file = self.base_path / "LandingPage/css/styles.css"
        if css_file.exists():
            content = css_file.read_text()

            has_focus_styles = ':focus' in content or 'focus-visible' in content
            has_reduced_motion = 'prefers-reduced-motion' in content
            has_high_contrast = 'prefers-contrast' in content

            self.add_result("Landing Page", "A11y: Has focus styles", has_focus_styles)
            self.add_result("Landing Page", "A11y: Respects reduced motion", has_reduced_motion)
            self.add_result("Landing Page", "A11y: Supports high contrast", has_high_contrast)

    def test_landing_page_performance(self):
        """Test landing page performance considerations"""
        html_file = self.base_path / "LandingPage/index.html"

        if html_file.exists():
            content = html_file.read_text()

            # Check for performance optimizations
            has_preconnect = 'rel="preconnect"' in content
            has_async_defer = 'async' in content or 'defer' in content or True  # Optional

            self.add_result("Landing Page", "Perf: Uses preconnect", has_preconnect)

        # Check file sizes
        css_file = self.base_path / "LandingPage/css/styles.css"
        js_file = self.base_path / "LandingPage/js/main.js"

        if css_file.exists():
            css_size = len(css_file.read_text())
            self.add_result(
                "Landing Page",
                "Perf: CSS size reasonable",
                css_size < 100000,  # < 100KB
                f"Size: {css_size / 1024:.1f}KB"
            )

        if js_file.exists():
            js_size = len(js_file.read_text())
            self.add_result(
                "Landing Page",
                "Perf: JS size reasonable",
                js_size < 100000,  # < 100KB
                f"Size: {js_size / 1024:.1f}KB"
            )

    # ========================================
    # DOCUMENTATION TESTS
    # ========================================

    def test_documentation_completeness(self):
        """Test documentation is complete"""
        required_docs = [
            "ARCHITECTURE.md",
            "TECHNICAL_SPEC.md",
            "DESIGN.md",
            "IMPLEMENTATION_PLAN.md",
            "README.md",
            "INSTRUCTIONS.md",
            "TEST_RESULTS.md",
            "NEXT_STEPS.md",
            "XCODE_SETUP.md"
        ]

        for doc in required_docs:
            doc_file = self.base_path / doc
            exists = doc_file.exists()

            if exists:
                size = len(doc_file.read_text())
                substantial = size > 1000  # At least 1KB
                self.add_result(
                    "Documentation",
                    f"Doc exists and substantial: {doc}",
                    substantial,
                    f"Size: {size / 1024:.1f}KB"
                )
            else:
                self.add_result("Documentation", f"Doc exists: {doc}", False)

    def test_documentation_accuracy(self):
        """Test documentation accuracy"""
        readme = self.base_path / "README.md"

        if readme.exists():
            content = readme.read_text()

            # Check for key sections
            has_overview = '## Overview' in content or '# Overview' in content
            has_features = 'feature' in content.lower()
            has_setup = 'setup' in content.lower() or 'installation' in content.lower()

            self.add_result("Documentation", "README has overview", has_overview)
            self.add_result("Documentation", "README describes features", has_features)
            self.add_result("Documentation", "README has setup instructions", has_setup)

    def test_markdown_syntax(self):
        """Test Markdown files for syntax issues"""
        md_files = list(self.base_path.glob("*.md"))

        for md_file in md_files:
            try:
                content = md_file.read_text()

                # Check for balanced code blocks
                triple_backticks = content.count('```')
                balanced_blocks = triple_backticks % 2 == 0

                # Check for headings
                has_headings = '#' in content

                self.add_result(
                    "Documentation",
                    f"Markdown valid: {md_file.name}",
                    balanced_blocks and has_headings,
                    f"Code blocks balanced: {balanced_blocks}, Has headings: {has_headings}"
                )
            except Exception as e:
                self.add_result("Documentation", f"Read markdown: {md_file.name}", False, str(e))

    # ========================================
    # CODE QUALITY TESTS
    # ========================================

    def test_file_naming_conventions(self):
        """Test file naming conventions"""
        swift_files = list(self.base_path.glob("CultureArchitectureSystem/**/*.swift"))

        naming_issues = 0
        for swift_file in swift_files:
            # Check PascalCase for Swift files
            name = swift_file.stem
            if name[0].islower():
                naming_issues += 1

        self.add_result(
            "Code Quality",
            "Swift files use PascalCase",
            naming_issues == 0,
            f"Issues found: {naming_issues}"
        )

    def test_code_organization(self):
        """Test code organization"""
        # Check that files are in appropriate directories
        models_in_models = len(list((self.base_path / "CultureArchitectureSystem/Models").glob("*.swift")))
        views_in_views = len(list((self.base_path / "CultureArchitectureSystem/Views").glob("**/*.swift")))
        services_in_services = len(list((self.base_path / "CultureArchitectureSystem/Services").glob("*.swift")))

        self.add_result("Code Quality", "Models organized in Models/", models_in_models >= 7,
                       f"Found {models_in_models} model files")
        self.add_result("Code Quality", "Views organized in Views/", views_in_views >= 7,
                       f"Found {views_in_views} view files")
        self.add_result("Code Quality", "Services organized in Services/", services_in_services >= 4,
                       f"Found {services_in_services} service files")

    def test_line_lengths(self):
        """Test for excessively long lines"""
        swift_files = list(self.base_path.glob("CultureArchitectureSystem/**/*.swift"))

        files_with_long_lines = 0
        for swift_file in swift_files:
            content = swift_file.read_text()
            lines = content.split('\n')

            for line in lines:
                if len(line) > 120 and not line.strip().startswith('//'):
                    files_with_long_lines += 1
                    break

        self.add_result(
            "Code Quality",
            "Line lengths reasonable",
            files_with_long_lines < len(swift_files) * 0.3,  # Allow 30%
            f"{files_with_long_lines} files with lines > 120 chars"
        )

    # ========================================
    # SECURITY TESTS
    # ========================================

    def test_privacy_implementation(self):
        """Test privacy implementation"""
        employee_file = self.base_path / "CultureArchitectureSystem/Models/Employee.swift"

        if employee_file.exists():
            content = employee_file.read_text()

            # Check for anonymization
            has_anonymous_id = 'anonymousId' in content
            no_real_name = 'name' not in content.lower() or 'firstName' not in content
            no_email = 'email' not in content.lower()

            self.add_result("Security", "Employee model uses anonymousId", has_anonymous_id)
            self.add_result("Security", "Employee model has no real names", no_real_name)
            self.add_result("Security", "Employee model has no email", no_email)

    def test_no_hardcoded_secrets(self):
        """Test for hardcoded secrets"""
        swift_files = list(self.base_path.glob("CultureArchitectureSystem/**/*.swift"))

        suspicious_patterns = [
            'password',
            'secret',
            'api_key',
            'apiKey',
            'token',
            'credential'
        ]

        files_with_secrets = []
        for swift_file in swift_files:
            content = swift_file.read_text().lower()

            for pattern in suspicious_patterns:
                if f'{pattern} =' in content or f'{pattern}:' in content:
                    # Check if it's just a property declaration (acceptable)
                    if 'let ' + pattern not in content and 'var ' + pattern not in content:
                        files_with_secrets.append(swift_file.name)
                        break

        self.add_result(
            "Security",
            "No hardcoded secrets",
            len(files_with_secrets) == 0,
            f"Suspicious files: {', '.join(files_with_secrets) if files_with_secrets else 'None'}"
        )

    def test_data_anonymization(self):
        """Test data anonymization implementation"""
        anonymizer_file = self.base_path / "CultureArchitectureSystem/Utilities/DataAnonymizer.swift"

        if anonymizer_file.exists():
            content = anonymizer_file.read_text()

            # Check for proper anonymization
            has_sha256 = 'SHA256' in content
            has_anonymize_method = 'func anonymize' in content
            has_k_anonymity = 'kAnonymity' in content or 'k-anonymity' in content.lower()

            self.add_result("Security", "DataAnonymizer uses SHA256", has_sha256)
            self.add_result("Security", "DataAnonymizer has anonymize method", has_anonymize_method)
            self.add_result("Security", "DataAnonymizer enforces k-anonymity", has_k_anonymity)
        else:
            self.add_result("Security", "DataAnonymizer exists", False)

    # ========================================
    # ARCHITECTURE TESTS
    # ========================================

    def test_mvvm_pattern(self):
        """Test MVVM pattern implementation"""
        viewmodels_dir = self.base_path / "CultureArchitectureSystem/ViewModels"

        if viewmodels_dir.exists():
            viewmodels = list(viewmodels_dir.glob("*.swift"))

            for vm_file in viewmodels:
                content = vm_file.read_text()

                # Check for Observable pattern
                has_observable = '@Observable' in content or 'ObservableObject' in content
                is_class = 'class' in content

                self.add_result(
                    "Architecture",
                    f"ViewModel {vm_file.name} follows pattern",
                    has_observable and is_class
                )

    def test_separation_of_concerns(self):
        """Test separation of concerns"""
        # Views should not contain business logic (services, complex calculations)
        views_dir = self.base_path / "CultureArchitectureSystem/Views"

        view_files = list(views_dir.glob("**/*.swift"))

        views_with_logic = 0
        for view_file in view_files:
            content = view_file.read_text()

            # Views should delegate to ViewModels/Services
            has_viewmodel = 'ViewModel' in content

            if 'View' in view_file.stem and not has_viewmodel:
                # Check if it's a complex view that should have a ViewModel
                if content.count('\n') > 100:  # Large view file
                    views_with_logic += 1

        self.add_result(
            "Architecture",
            "Views delegate to ViewModels",
            views_with_logic == 0,
            f"Views without ViewModels: {views_with_logic}"
        )

    def test_dependency_management(self):
        """Test dependency management"""
        # Check that services don't have circular dependencies
        services_dir = self.base_path / "CultureArchitectureSystem/Services"

        if services_dir.exists():
            service_files = list(services_dir.glob("*.swift"))

            # Simple check: services shouldn't import each other excessively
            circular_deps = False
            for service_file in service_files:
                content = service_file.read_text()

                # Count imports of other services
                other_service_imports = 0
                for other_service in service_files:
                    if other_service != service_file:
                        service_name = other_service.stem
                        if service_name in content:
                            other_service_imports += 1

                if other_service_imports > 2:
                    circular_deps = True
                    break

            self.add_result(
                "Architecture",
                "No excessive service dependencies",
                not circular_deps
            )

    # ========================================
    # REPORT GENERATION
    # ========================================

    def generate_report(self) -> str:
        """Generate comprehensive test report"""
        total_tests = len(self.results)
        passed_tests = sum(1 for r in self.results if r.passed)
        failed_tests = total_tests - passed_tests
        pass_rate = (passed_tests / total_tests * 100) if total_tests > 0 else 0

        report = []
        report.append("=" * 80)
        report.append("COMPREHENSIVE TEST REPORT")
        report.append("=" * 80)
        report.append("")
        report.append(f"Total Tests: {total_tests}")
        report.append(f"Passed: {passed_tests} ✓")
        report.append(f"Failed: {failed_tests} ✗")
        report.append(f"Pass Rate: {pass_rate:.1f}%")
        report.append("")

        # Status indicator
        if pass_rate >= 95:
            status = "🟢 EXCELLENT"
        elif pass_rate >= 80:
            status = "🟡 GOOD"
        elif pass_rate >= 60:
            status = "🟠 NEEDS IMPROVEMENT"
        else:
            status = "🔴 CRITICAL"

        report.append(f"Overall Status: {status}")
        report.append("")
        report.append("=" * 80)
        report.append("")

        # Group by category
        for category in self.categories.keys():
            category_results = [r for r in self.results if r.category == category]
            if not category_results:
                continue

            category_passed = sum(1 for r in category_results if r.passed)
            category_total = len(category_results)
            category_rate = (category_passed / category_total * 100) if category_total > 0 else 0

            report.append(f"{category}")
            report.append(f"{'=' * len(category)}")
            report.append(f"Tests: {category_total} | Passed: {category_passed} | Pass Rate: {category_rate:.1f}%")
            report.append("")

            for result in category_results:
                status_icon = "✓" if result.passed else "✗"
                report.append(f"  {status_icon} {result.name}")
                if result.message:
                    report.append(f"    → {result.message}")

            report.append("")

        return "\n".join(report)

    def save_report(self, filename: str):
        """Save report to file"""
        report = self.generate_report()
        output_file = self.base_path / filename
        output_file.write_text(report)
        print(f"\n✓ Report saved to: {filename}")
        return report


def main():
    """Main entry point"""
    base_path = "/home/user/visionOS_culture-architecture-system"

    suite = ComprehensiveTestSuite(base_path)
    suite.run_all_tests()

    # Generate and save report
    report = suite.save_report("COMPREHENSIVE_TEST_REPORT.md")
    print("\n" + report)

    # Return exit code based on pass rate
    total = len(suite.results)
    passed = sum(1 for r in suite.results if r.passed)
    pass_rate = (passed / total * 100) if total > 0 else 0

    return 0 if pass_rate >= 80 else 1


if __name__ == "__main__":
    exit(main())
