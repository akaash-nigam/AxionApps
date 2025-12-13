#!/bin/bash

# Script to systematically fix Android build failures
# Generated: 2025-12-07

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo "==========================================="
echo "ANDROID BUILD FIX SCRIPT"
echo "==========================================="
echo ""

# Android projects with build failures
PROJECTS=(
    "android_ayushman-card-manager"
    "android_bachat-sahayak"
    "android_bhasha-buddy"
    "android_BimaShield"
    "android_dukaan-sahayak"
    "android_GlowAI"
    "android_karz-mukti"
    "android_kisan-sahayak"
    "android_majdoor-mitra"
    "android_poshan-tracker"
    "android_safar-saathi"
    "android_SafeCalc"
    "android_sarkar-seva"
    "android_seekho-kamao"
    "android_swasthya-sahayak"
    "android_TrainSathi"
    "android_village-job-board"
)

SUCCESS=0
FAILED=0
DEBUG_SUCCESS=0
RELEASE_FAILED=0

for PROJECT in "${PROJECTS[@]}"; do
    PROJECT_PATH="/Users/aakashnigam/Axion/AxionApps/android/$PROJECT"

    echo "==========================================="
    echo "[$((SUCCESS + FAILED + 1))/${#PROJECTS[@]}] Testing: $PROJECT"
    echo "==========================================="

    if [ ! -d "$PROJECT_PATH" ]; then
        echo -e "${YELLOW}⏭️  Skipped: Project directory not found${NC}"
        echo ""
        continue
    fi

    cd "$PROJECT_PATH"

    # Check if gradlew exists
    if [ ! -f "./gradlew" ]; then
        echo -e "${RED}❌ No gradlew script found${NC}"
        FAILED=$((FAILED + 1))
        echo ""
        continue
    fi

    # Try debug build
    echo -e "${BLUE}Building debug APK...${NC}"
    if ./gradlew assembleDebug --stacktrace 2>&1 | tee /tmp/gradle_debug_${PROJECT}.log | grep -q "BUILD SUCCESSFUL"; then
        echo -e "${GREEN}✅ DEBUG BUILD SUCCESSFUL${NC}"
        DEBUG_SUCCESS=$((DEBUG_SUCCESS + 1))

        # Try release build
        echo -e "${BLUE}Building release APK...${NC}"
        if ./gradlew assembleRelease --stacktrace 2>&1 | tee /tmp/gradle_release_${PROJECT}.log | grep -q "BUILD SUCCESSFUL"; then
            echo -e "${GREEN}✅ RELEASE BUILD SUCCESSFUL${NC}"
            SUCCESS=$((SUCCESS + 1))
        else
            echo -e "${YELLOW}⚠️  DEBUG OK, RELEASE FAILED${NC}"
            # Extract error from log
            echo -e "${YELLOW}Release error:${NC}"
            grep -A 3 "FAILURE:" /tmp/gradle_release_${PROJECT}.log | head -10
            RELEASE_FAILED=$((RELEASE_FAILED + 1))
        fi
    else
        echo -e "${RED}❌ DEBUG BUILD FAILED${NC}"
        # Extract error from log
        echo -e "${RED}Debug error:${NC}"
        grep -A 3 "FAILURE:" /tmp/gradle_debug_${PROJECT}.log | head -10
        FAILED=$((FAILED + 1))
    fi

    echo ""
done

echo "==========================================="
echo "ANDROID BUILD FIX SUMMARY"
echo "==========================================="
echo "Total Projects: ${#PROJECTS[@]}"
echo -e "${GREEN}✅ Full Success (Debug + Release): $SUCCESS${NC}"
echo -e "${YELLOW}⚠️  Debug OK, Release Failed: $RELEASE_FAILED${NC}"
echo -e "${BLUE}ℹ️  Debug Only Success: $DEBUG_SUCCESS${NC}"
echo -e "${RED}❌ Failed: $FAILED${NC}"
echo ""
echo "Build logs saved to /tmp/gradle_debug_* and /tmp/gradle_release_*"
echo ""
