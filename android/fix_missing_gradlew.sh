#!/bin/bash

# Script to copy Gradle wrapper to Android projects missing gradlew
# Generated: 2025-12-07

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "========================================="
echo "ANDROID GRADLE WRAPPER FIX"
echo "========================================="
echo ""

# Source project with working gradlew (using sarkar-seva since we tested it)
SOURCE_PROJECT="/Users/aakashnigam/Axion/AxionApps/android/android_sarkar-seva"

# Projects missing gradlew
PROJECTS=(
    "android_BimaShield"
    "android_GlowAI"
    "android_SafeCalc"
    "android_TrainSathi"
)

# Check if source project has gradlew
if [ ! -f "$SOURCE_PROJECT/gradlew" ]; then
    echo -e "${RED}❌ Source project $SOURCE_PROJECT does not have gradlew${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Source project found: $SOURCE_PROJECT${NC}"
echo ""

FIXED=0
FAILED=0

for PROJECT in "${PROJECTS[@]}"; do
    PROJECT_PATH="/Users/aakashnigam/Axion/AxionApps/android/$PROJECT"

    echo "========================================="
    echo "Fixing: $PROJECT"
    echo "========================================="

    if [ ! -d "$PROJECT_PATH" ]; then
        echo -e "${YELLOW}⏭️  Skipped: Project directory not found${NC}"
        echo ""
        continue
    fi

    # Copy gradlew files
    echo "Copying Gradle wrapper files..."

    # Copy gradlew script
    if cp "$SOURCE_PROJECT/gradlew" "$PROJECT_PATH/gradlew"; then
        chmod +x "$PROJECT_PATH/gradlew"
        echo -e "${GREEN}✓${NC} Copied gradlew"
    else
        echo -e "${RED}✗${NC} Failed to copy gradlew"
        FAILED=$((FAILED + 1))
        echo ""
        continue
    fi

    # Copy gradlew.bat (for Windows compatibility)
    if [ -f "$SOURCE_PROJECT/gradlew.bat" ]; then
        if cp "$SOURCE_PROJECT/gradlew.bat" "$PROJECT_PATH/gradlew.bat"; then
            echo -e "${GREEN}✓${NC} Copied gradlew.bat"
        fi
    fi

    # Copy gradle wrapper directory
    if [ -d "$SOURCE_PROJECT/gradle/wrapper" ]; then
        mkdir -p "$PROJECT_PATH/gradle"
        if cp -r "$SOURCE_PROJECT/gradle/wrapper" "$PROJECT_PATH/gradle/"; then
            echo -e "${GREEN}✓${NC} Copied gradle/wrapper directory"
        else
            echo -e "${RED}✗${NC} Failed to copy gradle wrapper directory"
            FAILED=$((FAILED + 1))
            echo ""
            continue
        fi
    fi

    echo -e "${GREEN}✅ Fixed: $PROJECT${NC}"
    FIXED=$((FIXED + 1))
    echo ""
done

echo "========================================="
echo "GRADLE WRAPPER FIX COMPLETE"
echo "========================================="
echo "Total Projects: ${#PROJECTS[@]}"
echo -e "${GREEN}✅ Fixed: $FIXED${NC}"
echo -e "${RED}❌ Failed: $FAILED${NC}"
echo ""
