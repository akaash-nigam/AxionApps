# Android Apps Portfolio - Session Context

**Last Updated:** 2025-12-11
**Status:** All apps building and deployed successfully

---

## Project Overview

Android application portfolio with 17 fully functional apps targeting Indian market segments (rural services, government schemes, financial literacy, etc.).

**Working Directory:** `/Users/aakashnigam/Axion/AxionApps/android`

---

## Current Status Summary

### Build Status: 100% SUCCESS (17/17 apps)

All apps successfully building and installed on Pixel 7 device.

**Working Apps:**
1. android_ayushman-card-manager
2. android_bachat-sahayak
3. android_bhasha-buddy
4. android_BimaShield
5. android_dukaan-sahayak
6. android_GlowAI
7. android_karz-mukti
8. android_kisan-sahayak
9. android_majdoor-mitra
10. android_poshan-tracker
11. android_safar-saathi
12. android_SafeCalc
13. android_sarkar-seva
14. android_seekho-kamao
15. android_swasthya-sahayak
16. android_TrainSathi
17. android_village-job-board

### Device Deployment

**Device:** Google Pixel 7 (192.168.2.159)
**Installed Apps:** 17/17 (all working apps installed)
**Connection:** USB debugging authorized and working

---

## Recent Major Fixes (This Session)

### 1. BimaShield - JDK 21 Compatibility
**Error:** jlink process failure with JDK 21
**Fix:** Updated build tool versions
- AGP: 8.2.0 → 8.2.2
- Kotlin: 1.9.20 → 1.9.22
- KSP: 1.9.20-1.0.14 → 1.9.22-1.0.17
- Hilt: 2.48 → 2.50
- Compose Compiler: 1.5.4 → 1.5.8

**Files Modified:**
- `/Users/aakashnigam/Axion/AxionApps/android/android_BimaShield/build.gradle.kts`
- `/Users/aakashnigam/Axion/AxionApps/android/android_BimaShield/app/build.gradle.kts`

### 2. GlowAI - Type Mismatch
**Error:** ML Kit Rect vs RectF type incompatibility
**Fix:** Wrapped with RectF constructor: `RectF(mlFace.boundingBox)`

**File Modified:**
- `/Users/aakashnigam/Axion/AxionApps/android/android_GlowAI/app/src/main/java/com/glowai/app/data/ml/MLServiceImpl.kt:115`

### 3. SafeCalc - Missing Dependencies
**Error:** Unresolved references to Timber and BuildConfig
**Fix:**
- Added Timber dependency: `implementation("com.jakewharton.timber:timber:5.0.1")`
- Enabled buildConfig feature flag
- Fixed WorkManager Configuration.Provider API (function → property)

**Files Modified:**
- `/Users/aakashnigam/Axion/AxionApps/android/android_SafeCalc/app/build.gradle.kts`
- `/Users/aakashnigam/Axion/AxionApps/android/android_SafeCalc/app/src/main/java/com/safecalc/vault/SafeCalcApplication.kt`

### 4. majdoor-mitra - 91 Errors Fixed
**Major Issues:**
- Resource.Error pattern change (message → exception): 28+ occurrences
- PaymentStatus enum references (COMPLETED→PAID, FAILED→REJECTED)
- Duplicate WorkerProfile definitions
- Field name mismatches (dailyWage→wageOffered, requiredWorkers→maxWorkers)
- Navigation parameter mismatches: 20 errors

**Key Pattern Change:**
```kotlin
// Old:
Resource.Error(message = "error text")

// New:
Resource.Error(exception = AppException.UnknownError("error text", cause))
```

**Files Modified (major):**
- All UseCase files in `/Users/aakashnigam/Axion/AxionApps/android/android_majdoor-mitra/app/src/main/java/com/majdoor/mitra/domain/usecase/`
- `/Users/aakashnigam/Axion/AxionApps/android/android_majdoor-mitra/app/src/main/java/com/majdoor/mitra/ui/screens/WorkDetailScreen.kt`
- `/Users/aakashnigam/Axion/AxionApps/android/android_majdoor-mitra/app/src/main/java/com/majdoor/mitra/ui/navigation/MajdoorMitraNavigation.kt`

### 5. seekho-kamao - Compose Compiler
**Error:** Compose Compiler 1.5.8 incompatible with Kotlin 2.0.21
**Fix:** Added Kotlin Compose plugin, removed manual kotlinCompilerExtensionVersion

**File Modified:**
- `/Users/aakashnigam/Axion/AxionApps/android/android_seekho-kamao/app/build.gradle.kts`

### 6. TrainSathi - JDK 21 Compatibility
**Fix:** Same version updates as BimaShield

**Files Modified:**
- `/Users/aakashnigam/Axion/AxionApps/android/android_TrainSathi/build.gradle.kts`
- `/Users/aakashnigam/Axion/AxionApps/android/android_TrainSathi/app/build.gradle.kts`

---

## Codebase Organization

### Active Folders (20 total)

**Apps (17):** All listed above
**Utility Folders (3):**
- android_shared (shared libraries/code)
- android_tools (build tools)
- android_analysis (analysis scripts)

### Archived Folders

**Location:** `/Users/aakashnigam/Axion/AxionApps/android/TobeDeletedLater`
**Count:** 23 folders (non-buildable apps moved for manual review)

**List:**
- android_baal-siksha
- android_BattlegroundIndia
- android_BoloCare
- android_Canada
- android_CodexAndroid
- android_ExamSahayak
- android_FanConnect
- android_FluentProAI
- android_GharSeva
- android_HerCycle
- android_India1_Apps
- android_India2_Apps
- android_India3_apps
- android_JyotishAI
- android_KisanPay
- android_MedNow
- android_MeraShahar
- android_PhoneGuardian
- android_QuotelyAI
- android_RainbowMind
- android_RentCred
- android_RentRamp
- android_ShadiConnect

---

## MCP Server Configuration

### Android Device MCP Server

**Status:** Configured and tested (requires Claude Code restart to activate)

**Server Details:**
- URL: http://192.168.2.159:8080
- Transport: JSON-RPC over HTTP
- Location: Running on Pixel 7 device

**Configuration File:**
`~/.config/claude-code/claude_desktop_config.json`

**MCP Server Name:** `android-device-mcp`

**Available Tools (5):**
1. `ai_analyze_screen` - Analyze screenshots using on-device AI (ML Kit)
2. `debug_system_info` - Get comprehensive system and device debugging information
3. `debug_logcat` - Get recent logcat entries for debugging (filtered by package or tag)
4. `debug_performance` - Get detailed performance metrics and profiling data
5. `debug_network` - Get network connectivity info, data usage, and active connections

**Test Status:** JSON-RPC endpoint tested and responding correctly

**Next Step:** Restart Claude Code to activate MCP tools. After restart, tools will be available with prefix `mcp__android-device-mcp__`

---

## Key Technical Patterns

### JDK 21 Compatibility Requirements
```kotlin
// Root build.gradle.kts
plugins {
    id("com.android.application") version "8.2.2" apply false
    id("org.jetbrains.kotlin.android") version "1.9.22" apply false
    id("com.google.devtools.ksp") version "1.9.22-1.0.17" apply false
    id("com.google.dagger.hilt.android") version "2.50" apply false
}

// app/build.gradle.kts
composeOptions {
    kotlinCompilerExtensionVersion = "1.5.8"
}
dependencies {
    implementation("com.google.dagger:hilt-android:2.50")
    ksp("com.google.dagger:hilt-android-compiler:2.50")
}
```

### Kotlin 2.0+ Compose Integration
```kotlin
plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("org.jetbrains.kotlin.plugin.compose")  // Add this
}

// Remove manual composeOptions block
```

### Resource.Error Pattern (majdoor-mitra)
```kotlin
// Correct pattern:
Resource.Error(exception = AppException.UnknownError("message", cause))
Resource.Error(exception = AppException.NetworkError("message"))
```

---

## Build Scripts

### Location: `/tmp/`

**build_test.sh** - Test build all apps with gradle
**install_all.sh** - Install all 17 apps to connected device
**move_non_buildable.sh** - Move non-buildable folders to TobeDeletedLater

---

## Device Information

**Model:** Google Pixel 7
**IP Address:** 192.168.2.159
**USB Debugging:** Enabled and authorized
**ADB Status:** Connected
**MCP Server:** Running on port 8080

---

## Next Steps

1. **Restart Claude Code** - Activate MCP server tools for Android device interaction
2. **Test MCP Tools** - Verify all 5 Android debugging tools work correctly
3. **Review TobeDeletedLater** - Manually review 23 archived folders for deletion
4. **App Testing** - Test installed apps on Pixel 7 device
5. **Consider Firebase Setup** - Many apps have Firebase dependencies commented out

---

## Important Notes

- All apps use Jetpack Compose with Material3
- All apps use Hilt for dependency injection
- Most apps have offline-first architecture with Room database
- Firebase dependencies commented out (require google-services.json)
- All apps target Android 7.0+ (minSdk 24) for 95% market coverage
- Apps use Hindi/English bilingual support for Indian market

---

## Quick Commands

```bash
# Check device connection
adb devices

# Build all apps
cd /Users/aakashnigam/Axion/AxionApps/android
/tmp/build_test.sh

# Install all apps
/tmp/install_all.sh

# List installed apps
adb shell pm list packages | grep -E "trainsaathi|safecalc|glowai|bimashield|majdoor|seekho|bhasha|ayushman|bachat|dukaan|karz|kisan|poshan|safar|sarkar|swasthya|village"

# Test MCP server
curl -X POST http://192.168.2.159:8080/ -H "Content-Type: application/json" -d '{"jsonrpc":"2.0","method":"tools/list","id":1}'
```

---

## Session Continuity

To restore context in a new session, simply read this file:
```
Read /Users/aakashnigam/Axion/AxionApps/SESSION_CONTEXT.md
```

This document contains all critical information about the current state of the Android apps portfolio, recent fixes, configuration changes, and next steps.
