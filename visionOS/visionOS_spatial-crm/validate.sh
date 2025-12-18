#!/bin/bash

# Spatial CRM Validation Script
# Validates project structure and code organization

set -e

echo "🔍 Spatial CRM - Project Validation"
echo "===================================="
echo ""

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Validation counters
PASSED=0
FAILED=0
WARNINGS=0

# Function to check if file exists
check_file() {
    if [ -f "$1" ]; then
        echo -e "${GREEN}✓${NC} Found: $1"
        ((PASSED++))
        return 0
    else
        echo -e "${RED}✗${NC} Missing: $1"
        ((FAILED++))
        return 1
    fi
}

# Function to check if directory exists
check_directory() {
    if [ -d "$1" ]; then
        echo -e "${GREEN}✓${NC} Found directory: $1"
        ((PASSED++))
        return 0
    else
        echo -e "${RED}✗${NC} Missing directory: $1"
        ((FAILED++))
        return 1
    fi
}

# Function to check file contains text
check_content() {
    if grep -q "$2" "$1" 2>/dev/null; then
        echo -e "${GREEN}✓${NC} $3"
        ((PASSED++))
        return 0
    else
        echo -e "${YELLOW}⚠${NC} $3"
        ((WARNINGS++))
        return 1
    fi
}

echo "📋 Checking Documentation..."
echo "----------------------------"
check_file "README.md"
check_file "ARCHITECTURE.md"
check_file "TECHNICAL_SPEC.md"
check_file "DESIGN.md"
check_file "IMPLEMENTATION_PLAN.md"
check_file "BUILD.md"
check_file "PRD-Spatial-CRM.md"
echo ""

echo "⚙️  Checking Configuration Files..."
echo "-----------------------------------"
check_file "Package.swift"
check_file "SpatialCRM/Resources/Info.plist"
check_file "SpatialCRM/Resources/SpatialCRM.entitlements"
check_file ".gitignore"
echo ""

echo "📱 Checking App Structure..."
echo "---------------------------"
check_directory "SpatialCRM/App"
check_file "SpatialCRM/App/SpatialCRMApp.swift"
check_file "SpatialCRM/App/ContentView.swift"
echo ""

echo "🗃️  Checking Data Models..."
echo "-------------------------"
check_directory "SpatialCRM/Models"
check_file "SpatialCRM/Models/Account.swift"
check_file "SpatialCRM/Models/Contact.swift"
check_file "SpatialCRM/Models/Opportunity.swift"
check_file "SpatialCRM/Models/Activity.swift"
check_file "SpatialCRM/Models/Territory.swift"
check_file "SpatialCRM/Models/CollaborationSession.swift"
echo ""

echo "🔧 Checking Services..."
echo "----------------------"
check_directory "SpatialCRM/Services"
check_file "SpatialCRM/Services/CRMService.swift"
check_file "SpatialCRM/Services/AIService.swift"
check_file "SpatialCRM/Services/SpatialService.swift"
echo ""

echo "🎨 Checking Views..."
echo "-------------------"
check_directory "SpatialCRM/Views"
check_directory "SpatialCRM/Views/Dashboard"
check_directory "SpatialCRM/Views/Pipeline"
check_directory "SpatialCRM/Views/Accounts"
check_directory "SpatialCRM/Views/Spatial"
check_directory "SpatialCRM/Views/Components"

check_file "SpatialCRM/Views/Dashboard/DashboardView.swift"
check_file "SpatialCRM/Views/Dashboard/AnalyticsView.swift"
check_file "SpatialCRM/Views/Pipeline/PipelineView.swift"
check_file "SpatialCRM/Views/Accounts/AccountsView.swift"
check_file "SpatialCRM/Views/Accounts/CustomerDetailView.swift"
check_file "SpatialCRM/Views/Spatial/CustomerGalaxyView.swift"
check_file "SpatialCRM/Views/Spatial/PipelineVolumeView.swift"
check_file "SpatialCRM/Views/Spatial/NetworkGraphView.swift"
check_file "SpatialCRM/Views/Spatial/TerritoryExplorerView.swift"
check_file "SpatialCRM/Views/Components/QuickActionsView.swift"
echo ""

echo "🧪 Checking Tests..."
echo "-------------------"
check_directory "SpatialCRM/Tests/UnitTests"
check_file "SpatialCRM/Tests/UnitTests/AccountTests.swift"
check_file "SpatialCRM/Tests/UnitTests/OpportunityTests.swift"
check_file "SpatialCRM/Tests/UnitTests/ContactTests.swift"
check_file "SpatialCRM/Tests/UnitTests/ActivityTests.swift"
check_file "SpatialCRM/Tests/UnitTests/AIServiceTests.swift"
echo ""

echo "🛠️  Checking Utilities..."
echo "------------------------"
check_directory "SpatialCRM/Utilities"
check_file "SpatialCRM/Utilities/SampleDataGenerator.swift"
echo ""

echo "📊 Checking Model Completeness..."
echo "--------------------------------"
check_content "SpatialCRM/Models/Account.swift" "@Model" "Account uses @Model macro"
check_content "SpatialCRM/Models/Contact.swift" "@Model" "Contact uses @Model macro"
check_content "SpatialCRM/Models/Opportunity.swift" "@Model" "Opportunity uses @Model macro"
check_content "SpatialCRM/Models/Activity.swift" "@Model" "Activity uses @Model macro"
echo ""

echo "🎯 Checking Service Implementation..."
echo "-------------------------------------"
check_content "SpatialCRM/Services/CRMService.swift" "@Observable" "CRMService is Observable"
check_content "SpatialCRM/Services/AIService.swift" "@Observable" "AIService is Observable"
check_content "SpatialCRM/Services/AIService.swift" "async" "AIService uses async/await"
check_content "SpatialCRM/Services/CRMService.swift" "SwiftData" "CRMService uses SwiftData"
echo ""

echo "🔒 Checking Security & Privacy..."
echo "--------------------------------"
check_content "SpatialCRM/Resources/Info.plist" "NSCameraUsageDescription" "Camera permission description"
check_content "SpatialCRM/Resources/Info.plist" "NSHandsTrackingUsageDescription" "Hand tracking permission"
check_content "SpatialCRM/Resources/SpatialCRM.entitlements" "hand-tracking" "Hand tracking capability"
check_content "SpatialCRM/Resources/SpatialCRM.entitlements" "eye-tracking" "Eye tracking capability"
echo ""

echo "📦 Checking Imports..."
echo "---------------------"
check_content "SpatialCRM/App/SpatialCRMApp.swift" "import SwiftUI" "SwiftUI imported in app"
check_content "SpatialCRM/App/SpatialCRMApp.swift" "import SwiftData" "SwiftData imported in app"
check_content "SpatialCRM/Views/Spatial/CustomerGalaxyView.swift" "import RealityKit" "RealityKit imported"
echo ""

echo "📏 Code Statistics..."
echo "--------------------"
echo -n "Total Swift files: "
find SpatialCRM -name "*.swift" 2>/dev/null | wc -l
echo -n "Lines of code: "
find SpatialCRM -name "*.swift" -exec cat {} \; 2>/dev/null | wc -l
echo -n "Test files: "
find SpatialCRM/Tests -name "*.swift" 2>/dev/null | wc -l
echo ""

echo "===================================="
echo "📈 Validation Summary"
echo "===================================="
echo -e "${GREEN}Passed:   $PASSED${NC}"
echo -e "${YELLOW}Warnings: $WARNINGS${NC}"
echo -e "${RED}Failed:   $FAILED${NC}"
echo ""

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}✅ All critical checks passed!${NC}"
    echo ""
    echo "Next Steps:"
    echo "1. Open Xcode 16+"
    echo "2. Create a new visionOS App project"
    echo "3. Import the SpatialCRM source files"
    echo "4. Configure entitlements and capabilities"
    echo "5. Build and run on Vision Pro Simulator"
    echo ""
    echo "See BUILD.md for detailed instructions."
    exit 0
else
    echo -e "${RED}❌ Some checks failed. Please review the missing files.${NC}"
    exit 1
fi
