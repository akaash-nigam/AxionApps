#!/bin/bash
#
# validate.sh
# Validation script for Supply Chain Control Tower
#

echo "🔍 Validating Supply Chain Control Tower Project..."
echo ""

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Counters
PASSED=0
FAILED=0
WARNINGS=0

# Function to check file existence
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

# Function to check directory existence
check_dir() {
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

# Function to count lines in Swift files
count_swift_lines() {
    find "$1" -name "*.swift" -type f -exec wc -l {} + | tail -1 | awk '{print $1}'
}

echo "📋 Checking Documentation..."
check_file "ARCHITECTURE.md"
check_file "TECHNICAL_SPEC.md"
check_file "DESIGN.md"
check_file "IMPLEMENTATION_PLAN.md"
check_file "PRD-Supply-Chain-Control-Tower.md"
check_file "README.md"
echo ""

echo "📁 Checking Project Structure..."
check_dir "SupplyChainControlTower"
check_dir "SupplyChainControlTower/App"
check_dir "SupplyChainControlTower/Models"
check_dir "SupplyChainControlTower/Views"
check_dir "SupplyChainControlTower/Views/Windows"
check_dir "SupplyChainControlTower/Views/Volumes"
check_dir "SupplyChainControlTower/Views/ImmersiveViews"
check_dir "SupplyChainControlTower/ViewModels"
check_dir "SupplyChainControlTower/Services"
check_dir "SupplyChainControlTower/Utilities"
check_dir "SupplyChainControlTower/Tests"
echo ""

echo "📄 Checking Core Files..."
check_file "SupplyChainControlTower/App/SupplyChainControlTowerApp.swift"
check_file "SupplyChainControlTower/Models/DataModels.swift"
check_file "SupplyChainControlTower/Info.plist"
check_file "SupplyChainControlTower/README.md"
echo ""

echo "🪟 Checking Window Views..."
check_file "SupplyChainControlTower/Views/Windows/DashboardView.swift"
check_file "SupplyChainControlTower/Views/Windows/AlertsView.swift"
check_file "SupplyChainControlTower/Views/Windows/ControlPanelView.swift"
echo ""

echo "📦 Checking Volume Views..."
check_file "SupplyChainControlTower/Views/Volumes/NetworkVolumeView.swift"
check_file "SupplyChainControlTower/Views/Volumes/InventoryLandscapeView.swift"
check_file "SupplyChainControlTower/Views/Volumes/FlowRiverView.swift"
echo ""

echo "🌐 Checking Immersive Views..."
check_file "SupplyChainControlTower/Views/ImmersiveViews/GlobalCommandCenterView.swift"
echo ""

echo "🧠 Checking ViewModels..."
check_file "SupplyChainControlTower/ViewModels/DashboardViewModel.swift"
check_file "SupplyChainControlTower/ViewModels/NetworkVisualizationViewModel.swift"
echo ""

echo "🔧 Checking Services..."
check_file "SupplyChainControlTower/Services/NetworkService.swift"
echo ""

echo "🛠️ Checking Utilities..."
check_file "SupplyChainControlTower/Utilities/GeometryExtensions.swift"
check_file "SupplyChainControlTower/Utilities/PerformanceMonitor.swift"
echo ""

echo "🧪 Checking Tests..."
check_file "SupplyChainControlTower/Tests/DataModelsTests.swift"
check_file "SupplyChainControlTower/Tests/NetworkServiceTests.swift"
echo ""

echo "📊 Project Statistics..."
SWIFT_LINES=$(count_swift_lines "SupplyChainControlTower")
SWIFT_FILES=$(find SupplyChainControlTower -name "*.swift" -type f | wc -l)
MD_FILES=$(find . -maxdepth 1 -name "*.md" -type f | wc -l)

echo "  Swift Files: $SWIFT_FILES"
echo "  Swift Lines: $SWIFT_LINES"
echo "  Documentation Files: $MD_FILES"
echo ""

echo "🔍 Checking for common Swift issues..."

# Check for print statements (should use logger)
PRINTS=$(grep -r "print(" SupplyChainControlTower --include="*.swift" | grep -v "// " | grep -v "printStatistics" | wc -l)
if [ $PRINTS -gt 0 ]; then
    echo -e "${YELLOW}⚠${NC} Found $PRINTS print() statements (consider using Logger)"
    ((WARNINGS++))
fi

# Check for force unwraps
FORCE_UNWRAPS=$(grep -r "!" SupplyChainControlTower --include="*.swift" | grep -v "//" | grep -v "!=" | wc -l)
if [ $FORCE_UNWRAPS -gt 10 ]; then
    echo -e "${YELLOW}⚠${NC} Found many ! force unwraps (use optional binding when possible)"
    ((WARNINGS++))
fi

echo ""
echo "📈 Validation Summary"
echo "===================="
echo -e "${GREEN}Passed: $PASSED${NC}"
if [ $WARNINGS -gt 0 ]; then
    echo -e "${YELLOW}Warnings: $WARNINGS${NC}"
fi
if [ $FAILED -gt 0 ]; then
    echo -e "${RED}Failed: $FAILED${NC}"
fi
echo ""

# Overall result
if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}✅ Validation PASSED!${NC}"
    echo ""
    echo "Next steps:"
    echo "1. Open the project in Xcode 16+"
    echo "2. Create a new visionOS app project"
    echo "3. Copy these files into the new project"
    echo "4. Build and run on visionOS simulator or device"
    echo ""
    exit 0
else
    echo -e "${RED}❌ Validation FAILED${NC}"
    echo "Please fix the missing files/directories above."
    echo ""
    exit 1
fi
