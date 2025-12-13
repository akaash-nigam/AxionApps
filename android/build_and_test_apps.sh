#!/bin/bash

# Script to build and test all Android apps on connected device
# Created: 2025-12-07

set -e  # Exit on error

APPS_DIR="/Users/aakashnigam/Axion/AxionApps/android"
LOG_FILE="$APPS_DIR/build_test_results.log"
SCREENSHOTS_DIR="$APPS_DIR/device_testing_screenshots"

# Create screenshots directory if it doesn't exist
mkdir -p "$SCREENSHOTS_DIR"

# Clear log file
echo "=== Android Apps Build & Test Report ===" > "$LOG_FILE"
echo "Date: $(date)" >> "$LOG_FILE"
echo "" >> "$LOG_FILE"

# Check device connection
echo "Checking device connection..."
if ! adb devices | grep -q "device$"; then
    echo "ERROR: No authorized device connected!"
    echo "Please ensure USB debugging is enabled and authorized."
    exit 1
fi

echo "Device connected: $(adb devices | grep device$ | cut -f1)"
echo ""

# List of apps to build and test (excluding already tested ones and non-app directories)
APPS=(
    # Healthcare Apps
    "baal-siksha"
    "BimaShield"
    "BoloCare"
    "HerCycle"
    "MedNow"
    "swasthya-sahayak"

    # Utility/Services Apps
    "GharSeva"
    "KisanPay"
    "MeraShahar"
    "PhoneGuardian"
    "RentCred"
    "RentRamp"
    "SafeCalc"
    "TrainSathi"

    # Entertainment/Lifestyle Apps
    "BattlegroundIndia"
    "FanConnect"
    "FluentProAI"
    "GlowAI"
    "JyotishAI"
    "QuotelyAI"
    "RainbowMind"
    "ShadiConnect"

    # Other Apps
    "Canada"
    "CodexAndroid"
)

SUCCESS_COUNT=0
FAIL_COUNT=0
SKIPPED_COUNT=0

for APP in "${APPS[@]}"; do
    APP_DIR="$APPS_DIR/android_$APP"

    echo "========================================" | tee -a "$LOG_FILE"
    echo "Processing: $APP" | tee -a "$LOG_FILE"
    echo "========================================" | tee -a "$LOG_FILE"

    if [ ! -d "$APP_DIR" ]; then
        echo "SKIPPED: Directory not found" | tee -a "$LOG_FILE"
        SKIPPED_COUNT=$((SKIPPED_COUNT + 1))
        continue
    fi

    # Check if app has build.gradle
    if [ ! -f "$APP_DIR/app/build.gradle" ] && [ ! -f "$APP_DIR/app/build.gradle.kts" ]; then
        echo "SKIPPED: No build.gradle found (not an Android project)" | tee -a "$LOG_FILE"
        SKIPPED_COUNT=$((SKIPPED_COUNT + 1))
        continue
    fi

    cd "$APP_DIR"

    # Clean and build
    echo "Building $APP..." | tee -a "$LOG_FILE"
    if ./gradlew clean assembleDebug 2>&1 | tee -a "$LOG_FILE"; then
        echo "BUILD SUCCESS: $APP" | tee -a "$LOG_FILE"

        # Find the APK
        APK=$(find app/build/outputs/apk/debug -name "*.apk" | head -n 1)

        if [ -f "$APK" ]; then
            echo "Installing $APP..." | tee -a "$LOG_FILE"

            if adb install -r "$APK" 2>&1 | tee -a "$LOG_FILE"; then
                echo "INSTALL SUCCESS: $APP" | tee -a "$LOG_FILE"

                # Try to find package name
                PACKAGE=$(aapt dump badging "$APK" | grep package:\ name | awk '{print $2}' | sed s/name=//g | tr -d "'")

                if [ -n "$PACKAGE" ]; then
                    echo "Package: $PACKAGE" | tee -a "$LOG_FILE"

                    # Launch app
                    echo "Launching $APP..." | tee -a "$LOG_FILE"
                    adb shell monkey -p "$PACKAGE" -c android.intent.category.LAUNCHER 1 2>&1 | tee -a "$LOG_FILE"

                    # Wait for app to launch
                    sleep 3

                    # Take screenshot
                    SCREENSHOT="$SCREENSHOTS_DIR/${APP}.png"
                    adb exec-out screencap -p > "$SCREENSHOT"
                    echo "Screenshot saved: $SCREENSHOT" | tee -a "$LOG_FILE"

                    # Check for crashes
                    echo "Checking for crashes..." | tee -a "$LOG_FILE"
                    if adb logcat -d | grep -i "FATAL.*$PACKAGE" | tail -20; then
                        echo "WARNING: Possible crash detected for $APP" | tee -a "$LOG_FILE"
                    fi

                    SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
                else
                    echo "WARNING: Could not determine package name" | tee -a "$LOG_FILE"
                    SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
                fi
            else
                echo "INSTALL FAILED: $APP" | tee -a "$LOG_FILE"
                FAIL_COUNT=$((FAIL_COUNT + 1))
            fi
        else
            echo "ERROR: APK not found after build" | tee -a "$LOG_FILE"
            FAIL_COUNT=$((FAIL_COUNT + 1))
        fi
    else
        echo "BUILD FAILED: $APP" | tee -a "$LOG_FILE"
        FAIL_COUNT=$((FAIL_COUNT + 1))
    fi

    echo "" | tee -a "$LOG_FILE"
done

# Summary
echo "========================================" | tee -a "$LOG_FILE"
echo "SUMMARY" | tee -a "$LOG_FILE"
echo "========================================" | tee -a "$LOG_FILE"
echo "Total apps processed: ${#APPS[@]}" | tee -a "$LOG_FILE"
echo "Success: $SUCCESS_COUNT" | tee -a "$LOG_FILE"
echo "Failed: $FAIL_COUNT" | tee -a "$LOG_FILE"
echo "Skipped: $SKIPPED_COUNT" | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"
echo "Results saved to: $LOG_FILE" | tee -a "$LOG_FILE"
echo "Screenshots saved to: $SCREENSHOTS_DIR" | tee -a "$LOG_FILE"
