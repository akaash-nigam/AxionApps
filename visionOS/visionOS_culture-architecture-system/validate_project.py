#!/usr/bin/env python3
"""
Project Structure Validation Script
Validates the Culture Architecture System project structure
"""

import os
import sys
from pathlib import Path
from typing import List, Tuple

# ANSI color codes
GREEN = '\033[92m'
RED = '\033[91m'
YELLOW = '\033[93m'
BLUE = '\033[94m'
RESET = '\033[0m'

def check_file_exists(filepath: str) -> bool:
    """Check if a file exists"""
    return Path(filepath).exists()

def check_directory_structure():
    """Validate project directory structure"""
    print(f"\n{BLUE}=== Checking Directory Structure ==={RESET}\n")

    required_dirs = [
        "CultureArchitectureSystem/App",
        "CultureArchitectureSystem/Models",
        "CultureArchitectureSystem/Views/Windows",
        "CultureArchitectureSystem/Views/Volumes",
        "CultureArchitectureSystem/Views/Immersive",
        "CultureArchitectureSystem/ViewModels",
        "CultureArchitectureSystem/Services",
        "CultureArchitectureSystem/Networking",
        "CultureArchitectureSystem/Utilities",
        "CultureArchitectureSystem/Resources",
        "CultureArchitectureSystem/Tests/UnitTests",
    ]

    passed = 0
    failed = 0

    for dir_path in required_dirs:
        if Path(dir_path).is_dir():
            print(f"{GREEN}✓{RESET} {dir_path}")
            passed += 1
        else:
            print(f"{RED}✗{RESET} {dir_path} - Missing")
            failed += 1

    return passed, failed

def check_core_files():
    """Validate core application files exist"""
    print(f"\n{BLUE}=== Checking Core Files ==={RESET}\n")

    core_files = [
        # App
        ("CultureArchitectureSystem/App/CultureArchitectureSystemApp.swift", "App Entry Point"),
        ("CultureArchitectureSystem/App/AppModel.swift", "App Model"),
        ("CultureArchitectureSystem/App/ContentView.swift", "Content View"),

        # Models
        ("CultureArchitectureSystem/Models/Organization.swift", "Organization Model"),
        ("CultureArchitectureSystem/Models/CulturalValue.swift", "Cultural Value Model"),
        ("CultureArchitectureSystem/Models/Employee.swift", "Employee Model"),
        ("CultureArchitectureSystem/Models/Recognition.swift", "Recognition Model"),
        ("CultureArchitectureSystem/Models/BehaviorEvent.swift", "Behavior Event Model"),
        ("CultureArchitectureSystem/Models/CulturalLandscape.swift", "Cultural Landscape Model"),
        ("CultureArchitectureSystem/Models/Department.swift", "Department Model"),

        # Views
        ("CultureArchitectureSystem/Views/Windows/DashboardView.swift", "Dashboard View"),
        ("CultureArchitectureSystem/Views/Windows/AnalyticsView.swift", "Analytics View"),
        ("CultureArchitectureSystem/Views/Windows/RecognitionView.swift", "Recognition View"),
        ("CultureArchitectureSystem/Views/Volumes/TeamCultureVolume.swift", "Team Culture Volume"),
        ("CultureArchitectureSystem/Views/Volumes/ValueExplorerVolume.swift", "Value Explorer Volume"),
        ("CultureArchitectureSystem/Views/Immersive/CultureCampusView.swift", "Culture Campus View"),
        ("CultureArchitectureSystem/Views/Immersive/OnboardingImmersiveView.swift", "Onboarding View"),

        # ViewModels
        ("CultureArchitectureSystem/ViewModels/DashboardViewModel.swift", "Dashboard ViewModel"),
        ("CultureArchitectureSystem/ViewModels/AnalyticsViewModel.swift", "Analytics ViewModel"),
        ("CultureArchitectureSystem/ViewModels/RecognitionViewModel.swift", "Recognition ViewModel"),

        # Services
        ("CultureArchitectureSystem/Services/CultureService.swift", "Culture Service"),
        ("CultureArchitectureSystem/Services/AnalyticsService.swift", "Analytics Service"),
        ("CultureArchitectureSystem/Services/RecognitionService.swift", "Recognition Service"),
        ("CultureArchitectureSystem/Services/VisualizationService.swift", "Visualization Service"),

        # Networking
        ("CultureArchitectureSystem/Networking/APIClient.swift", "API Client"),
        ("CultureArchitectureSystem/Networking/AuthenticationManager.swift", "Authentication Manager"),

        # Utilities
        ("CultureArchitectureSystem/Utilities/Constants.swift", "Constants"),
        ("CultureArchitectureSystem/Utilities/DataAnonymizer.swift", "Data Anonymizer"),
    ]

    passed = 0
    failed = 0

    for filepath, description in core_files:
        if check_file_exists(filepath):
            print(f"{GREEN}✓{RESET} {description:40} ({filepath})")
            passed += 1
        else:
            print(f"{RED}✗{RESET} {description:40} ({filepath}) - Missing")
            failed += 1

    return passed, failed

def check_test_files():
    """Validate test files exist"""
    print(f"\n{BLUE}=== Checking Test Files ==={RESET}\n")

    test_files = [
        ("CultureArchitectureSystem/Tests/UnitTests/OrganizationTests.swift", "Organization Tests"),
        ("CultureArchitectureSystem/Tests/UnitTests/CulturalValueTests.swift", "Cultural Value Tests"),
        ("CultureArchitectureSystem/Tests/UnitTests/EmployeeTests.swift", "Employee Tests"),
        ("CultureArchitectureSystem/Tests/UnitTests/DataAnonymizerTests.swift", "Data Anonymizer Tests"),
        ("CultureArchitectureSystem/Tests/UnitTests/RecognitionTests.swift", "Recognition Tests"),
        ("CultureArchitectureSystem/Tests/UnitTests/BehaviorEventTests.swift", "Behavior Event Tests"),
        ("CultureArchitectureSystem/Tests/UnitTests/CultureServiceTests.swift", "Culture Service Tests"),
        ("CultureArchitectureSystem/Tests/UnitTests/AnalyticsServiceTests.swift", "Analytics Service Tests"),
        ("CultureArchitectureSystem/Tests/UnitTests/VisualizationServiceTests.swift", "Visualization Service Tests"),
    ]

    passed = 0
    failed = 0

    for filepath, description in test_files:
        if check_file_exists(filepath):
            print(f"{GREEN}✓{RESET} {description:40} ({filepath})")
            passed += 1
        else:
            print(f"{RED}✗{RESET} {description:40} ({filepath}) - Missing")
            failed += 1

    return passed, failed

def check_documentation():
    """Validate documentation files exist"""
    print(f"\n{BLUE}=== Checking Documentation ==={RESET}\n")

    doc_files = [
        ("ARCHITECTURE.md", "Architecture Documentation"),
        ("TECHNICAL_SPEC.md", "Technical Specifications"),
        ("DESIGN.md", "Design Specifications"),
        ("IMPLEMENTATION_PLAN.md", "Implementation Plan"),
        ("CultureArchitectureSystem/README.md", "Project README"),
        ("README.md", "Root README"),
        ("PRD-Culture-Architecture-System.md", "Product Requirements"),
        ("Culture-Architecture-System-PRFAQ.md", "PR/FAQ Document"),
    ]

    passed = 0
    failed = 0

    for filepath, description in doc_files:
        if check_file_exists(filepath):
            size = Path(filepath).stat().st_size
            size_kb = size / 1024
            print(f"{GREEN}✓{RESET} {description:40} ({size_kb:.1f} KB)")
            passed += 1
        else:
            print(f"{RED}✗{RESET} {description:40} - Missing")
            failed += 1

    return passed, failed

def count_lines_of_code():
    """Count total lines of code"""
    print(f"\n{BLUE}=== Code Statistics ==={RESET}\n")

    swift_files = list(Path("CultureArchitectureSystem").rglob("*.swift"))
    total_lines = 0
    total_files = len(swift_files)

    for filepath in swift_files:
        with open(filepath, 'r', encoding='utf-8') as f:
            lines = len(f.readlines())
            total_lines += lines

    print(f"Total Swift files: {total_files}")
    print(f"Total lines of code: {total_lines:,}")
    print(f"Average lines per file: {total_lines // total_files if total_files > 0 else 0}")

    return total_files, total_lines

def check_privacy_features():
    """Check for privacy-related implementations"""
    print(f"\n{BLUE}=== Privacy Features Check ==={RESET}\n")

    checks = []

    # Check DataAnonymizer exists
    if check_file_exists("CultureArchitectureSystem/Utilities/DataAnonymizer.swift"):
        checks.append(("DataAnonymizer implemented", True))
    else:
        checks.append(("DataAnonymizer implemented", False))

    # Check Employee model for privacy (no PII fields)
    employee_file = "CultureArchitectureSystem/Models/Employee.swift"
    if check_file_exists(employee_file):
        with open(employee_file, 'r') as f:
            content = f.read()
            # Should have anonymousId, not realId or email
            has_anonymous_id = "anonymousId" in content
            no_real_id = "realId" not in content or "// Never stored" in content
            no_email = "email" not in content.lower() or "no email" in content.lower()

            checks.append(("Employee uses anonymous ID", has_anonymous_id))
            checks.append(("No real ID in Employee model", no_real_id))
            checks.append(("No email in Employee model", no_email))

    # Check Constants for k-anonymity setting
    constants_file = "CultureArchitectureSystem/Utilities/Constants.swift"
    if check_file_exists(constants_file):
        with open(constants_file, 'r') as f:
            content = f.read()
            has_k_anonymity = "minimumTeamSize" in content and "5" in content
            checks.append(("K-anonymity enforcement (min team size 5)", has_k_anonymity))

    for description, passed in checks:
        if passed:
            print(f"{GREEN}✓{RESET} {description}")
        else:
            print(f"{RED}✗{RESET} {description}")

    return sum(1 for _, p in checks if p), sum(1 for _, p in checks if not p)

def main():
    """Main validation function"""
    print(f"\n{BLUE}{'=' * 60}{RESET}")
    print(f"{BLUE}Culture Architecture System - Project Validation{RESET}")
    print(f"{BLUE}{'=' * 60}{RESET}")

    results = []

    # Run all checks
    results.append(("Directory Structure", *check_directory_structure()))
    results.append(("Core Files", *check_core_files()))
    results.append(("Test Files", *check_test_files()))
    results.append(("Documentation", *check_documentation()))
    results.append(("Privacy Features", *check_privacy_features()))

    # Count lines of code
    file_count, line_count = count_lines_of_code()

    # Summary
    print(f"\n{BLUE}=== Validation Summary ==={RESET}\n")

    total_passed = sum(r[1] for r in results)
    total_failed = sum(r[2] for r in results)
    total_checks = total_passed + total_failed

    for category, passed, failed in results:
        status = f"{GREEN}PASS{RESET}" if failed == 0 else f"{YELLOW}PARTIAL{RESET}"
        print(f"{status} {category:30} {passed}/{passed+failed} checks passed")

    print(f"\n{BLUE}Overall:{RESET}")
    print(f"  Total Checks: {total_checks}")
    print(f"  {GREEN}Passed: {total_passed}{RESET}")
    if total_failed > 0:
        print(f"  {RED}Failed: {total_failed}{RESET}")
    else:
        print(f"  Failed: 0")

    success_rate = (total_passed / total_checks * 100) if total_checks > 0 else 0
    print(f"  Success Rate: {success_rate:.1f}%")

    # Final verdict
    print(f"\n{BLUE}{'=' * 60}{RESET}")
    if total_failed == 0:
        print(f"{GREEN}✓ PROJECT VALIDATION SUCCESSFUL{RESET}")
        print(f"{GREEN}All components are in place!{RESET}")
        return 0
    else:
        print(f"{YELLOW}⚠ PROJECT VALIDATION PARTIAL{RESET}")
        print(f"{YELLOW}Some components are missing or need attention.{RESET}")
        return 1

if __name__ == "__main__":
    sys.exit(main())
