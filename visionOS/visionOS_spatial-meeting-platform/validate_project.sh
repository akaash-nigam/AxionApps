#!/bin/bash

# Project Validation Script
# Verifies the Spatial Meeting Platform project structure

set -e

echo "🔍 Validating Spatial Meeting Platform Project Structure..."
echo ""

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

PASSED=0
FAILED=0
WARNINGS=0

# Function to check if file exists
check_file() {
    if [ -f "$1" ]; then
        echo -e "${GREEN}✓${NC} $1"
        ((PASSED++))
        return 0
    else
        echo -e "${RED}✗${NC} $1 - MISSING"
        ((FAILED++))
        return 1
    fi
}

# Function to check if directory exists
check_dir() {
    if [ -d "$1" ]; then
        echo -e "${GREEN}✓${NC} $1/"
        ((PASSED++))
        return 0
    else
        echo -e "${RED}✗${NC} $1/ - MISSING"
        ((FAILED++))
        return 1
    fi
}

# Function to count lines in file
count_lines() {
    if [ -f "$1" ]; then
        local lines=$(wc -l < "$1")
        echo -e "${YELLOW}  ⟶${NC} $lines lines"
    fi
}

echo "📋 Documentation Files:"
echo "======================="
check_file "ARCHITECTURE.md" && count_lines "ARCHITECTURE.md"
check_file "TECHNICAL_SPEC.md" && count_lines "TECHNICAL_SPEC.md"
check_file "DESIGN.md" && count_lines "DESIGN.md"
check_file "IMPLEMENTATION_PLAN.md" && count_lines "IMPLEMENTATION_PLAN.md"
check_file "BUILD_GUIDE.md" && count_lines "BUILD_GUIDE.md"
check_file "README.md" && count_lines "README.md"
check_file "PRD-Spatial-Meeting-Platform.md"
check_file "INSTRUCTIONS.md"
echo ""

echo "📱 Project Structure:"
echo "====================="
check_dir "SpatialMeetingPlatform"
check_dir "SpatialMeetingPlatform/App"
check_dir "SpatialMeetingPlatform/Models"
check_dir "SpatialMeetingPlatform/Views"
check_dir "SpatialMeetingPlatform/Views/Windows"
check_dir "SpatialMeetingPlatform/Views/Volumes"
check_dir "SpatialMeetingPlatform/Views/ImmersiveViews"
check_dir "SpatialMeetingPlatform/Services"
check_dir "SpatialMeetingPlatform/Tests"
check_dir "SpatialMeetingPlatform/Tests/TestHelpers"
check_dir "SpatialMeetingPlatform/Tests/ServiceTests"
check_dir "SpatialMeetingPlatform/Tests/ModelTests"
echo ""

echo "🏗️  App Files:"
echo "=============="
check_file "SpatialMeetingPlatform/App/SpatialMeetingPlatformApp.swift" && count_lines "SpatialMeetingPlatform/App/SpatialMeetingPlatformApp.swift"
check_file "SpatialMeetingPlatform/App/AppModel.swift" && count_lines "SpatialMeetingPlatform/App/AppModel.swift"
echo ""

echo "📦 Models:"
echo "=========="
check_file "SpatialMeetingPlatform/Models/DataModels.swift" && count_lines "SpatialMeetingPlatform/Models/DataModels.swift"
echo ""

echo "🔧 Services:"
echo "============"
check_file "SpatialMeetingPlatform/Services/ServiceProtocols.swift" && count_lines "SpatialMeetingPlatform/Services/ServiceProtocols.swift"
check_file "SpatialMeetingPlatform/Services/MeetingService.swift" && count_lines "SpatialMeetingPlatform/Services/MeetingService.swift"
check_file "SpatialMeetingPlatform/Services/SpatialService.swift" && count_lines "SpatialMeetingPlatform/Services/SpatialService.swift"
check_file "SpatialMeetingPlatform/Services/AIService.swift" && count_lines "SpatialMeetingPlatform/Services/AIService.swift"
check_file "SpatialMeetingPlatform/Services/WebSocketService.swift" && count_lines "SpatialMeetingPlatform/Services/WebSocketService.swift"
check_file "SpatialMeetingPlatform/Services/APIClient.swift" && count_lines "SpatialMeetingPlatform/Services/APIClient.swift"
check_file "SpatialMeetingPlatform/Services/AuthService.swift" && count_lines "SpatialMeetingPlatform/Services/AuthService.swift"
check_file "SpatialMeetingPlatform/Services/DataStore.swift" && count_lines "SpatialMeetingPlatform/Services/DataStore.swift"
echo ""

echo "🖼️  Views - Windows:"
echo "==================="
check_file "SpatialMeetingPlatform/Views/Windows/DashboardView.swift" && count_lines "SpatialMeetingPlatform/Views/Windows/DashboardView.swift"
check_file "SpatialMeetingPlatform/Views/Windows/MeetingControlsView.swift" && count_lines "SpatialMeetingPlatform/Views/Windows/MeetingControlsView.swift"
check_file "SpatialMeetingPlatform/Views/Windows/SharedContentView.swift" && count_lines "SpatialMeetingPlatform/Views/Windows/SharedContentView.swift"
echo ""

echo "📐 Views - Volumes:"
echo "==================="
check_file "SpatialMeetingPlatform/Views/Volumes/MeetingVolumeView.swift" && count_lines "SpatialMeetingPlatform/Views/Volumes/MeetingVolumeView.swift"
check_file "SpatialMeetingPlatform/Views/Volumes/CollaborationVolumeView.swift" && count_lines "SpatialMeetingPlatform/Views/Volumes/CollaborationVolumeView.swift"
echo ""

echo "🌐 Views - Immersive:"
echo "====================="
check_file "SpatialMeetingPlatform/Views/ImmersiveViews/ImmersiveMeetingView.swift" && count_lines "SpatialMeetingPlatform/Views/ImmersiveViews/ImmersiveMeetingView.swift"
echo ""

echo "🧪 Tests:"
echo "========="
check_file "SpatialMeetingPlatform/Tests/TestHelpers/MockObjects.swift" && count_lines "SpatialMeetingPlatform/Tests/TestHelpers/MockObjects.swift"
check_file "SpatialMeetingPlatform/Tests/ServiceTests/MeetingServiceTests.swift" && count_lines "SpatialMeetingPlatform/Tests/ServiceTests/MeetingServiceTests.swift"
check_file "SpatialMeetingPlatform/Tests/ServiceTests/SpatialServiceTests.swift" && count_lines "SpatialMeetingPlatform/Tests/ServiceTests/SpatialServiceTests.swift"
check_file "SpatialMeetingPlatform/Tests/ModelTests/DataModelTests.swift" && count_lines "SpatialMeetingPlatform/Tests/ModelTests/DataModelTests.swift"
echo ""

echo "⚙️  Configuration:"
echo "=================="
check_file "SpatialMeetingPlatform/Package.swift" && count_lines "SpatialMeetingPlatform/Package.swift"
check_file "SpatialMeetingPlatform/Info.plist"
check_file ".gitignore"
echo ""

echo "📊 Summary:"
echo "==========="
echo -e "${GREEN}Passed:${NC} $PASSED"
echo -e "${RED}Failed:${NC} $FAILED"
echo ""

# Calculate total lines of code
echo "📈 Code Statistics:"
echo "==================="
TOTAL_SWIFT_LINES=$(find SpatialMeetingPlatform -name "*.swift" -type f -exec wc -l {} + | tail -1 | awk '{print $1}')
TOTAL_DOC_LINES=$(wc -l ARCHITECTURE.md TECHNICAL_SPEC.md DESIGN.md IMPLEMENTATION_PLAN.md BUILD_GUIDE.md README.md 2>/dev/null | tail -1 | awk '{print $1}')
SWIFT_FILES=$(find SpatialMeetingPlatform -name "*.swift" -type f | wc -l)

echo "Swift Files: $SWIFT_FILES"
echo "Total Swift Lines: $TOTAL_SWIFT_LINES"
echo "Total Documentation Lines: $TOTAL_DOC_LINES"
echo "Total Project Lines: $((TOTAL_SWIFT_LINES + TOTAL_DOC_LINES))"
echo ""

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}✅ All checks passed! Project structure is complete.${NC}"
    exit 0
else
    echo -e "${RED}❌ Some checks failed. Please review the output above.${NC}"
    exit 1
fi
