#!/bin/bash
# Systematic Android Build Testing Script
# Tests all Android projects and categorizes results

RESULTS_FILE="android_build_test_results.csv"
SUMMARY_FILE="android_build_test_summary.md"

# Initialize results file
echo "Project,Status,BuildTime,ErrorType,ErrorCount,Notes" > "$RESULTS_FILE"

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "======================================="
echo "Android Systematic Build Testing"
echo "======================================="
echo ""

total=0
success=0
failed=0
skipped=0

# Get list of all directories
for dir in */; do
    project=$(basename "$dir")

    # Skip non-project directories
    if [[ "$project" == "android_analysis" || "$project" == "android_shared" || "$project" == "android_tools" || "$project" == "android_CodexAndroid" || "$project" == "android_India"* || "$project" == "android_Canada" ]]; then
        echo "⏭️  Skipping: $project (empty/tool directory)"
        echo "$project,SKIPPED,0,EMPTY_DIR,0,Empty or tool directory" >> "$RESULTS_FILE"
        ((skipped++))
        ((total++))
        continue
    fi

    # Check if it has build.gradle.kts
    if [[ ! -f "$dir/build.gradle.kts" && ! -f "$dir/app/build.gradle.kts" ]]; then
        echo "⏭️  Skipping: $project (no Gradle build file)"
        echo "$project,SKIPPED,0,NO_GRADLE,0,No Gradle build files found" >> "$RESULTS_FILE"
        ((skipped++))
        ((total++))
        continue
    fi

    ((total++))
    echo ""
    echo "[$total] Testing: $project"
    echo "-----------------------------------"

    cd "$dir"
    start_time=$(date +%s)

    # Try building (with timeout)
    build_output=$(timeout 120 gradle assembleDebug 2>&1)
    build_exit_code=$?

    end_time=$(date +%s)
    build_time=$((end_time - start_time))

    # Check result
    if echo "$build_output" | grep -q "BUILD SUCCESSFUL"; then
        status="SUCCESS"
        error_type="NONE"
        error_count=0
        echo -e "${GREEN}✅ SUCCESS${NC} (${build_time}s)"
        ((success++))

    elif [[ $build_exit_code -eq 124 ]]; then
        status="TIMEOUT"
        error_type="TIMEOUT"
        error_count=0
        echo -e "${YELLOW}⏱️  TIMEOUT${NC} (>120s)"
        ((failed++))

    else
        status="FAILED"
        ((failed++))

        # Categorize error type
        if echo "$build_output" | grep -q "Could not find"; then
            error_type="MISSING_DEPENDENCY"
            error_count=$(echo "$build_output" | grep -c "Could not find")
            echo -e "${RED}❌ FAILED${NC}: Missing dependencies ($error_count)"

        elif echo "$build_output" | grep -q "Compilation error\|compileDebugKotlin FAILED"; then
            error_type="KOTLIN_COMPILE"
            error_count=$(echo "$build_output" | grep -c "^e: ")
            echo -e "${RED}❌ FAILED${NC}: Kotlin compilation errors ($error_count)"

        elif echo "$build_output" | grep -q "deprecated"; then
            error_type="DEPRECATED_CONFIG"
            error_count=$(echo "$build_output" | grep -c "deprecated")
            echo -e "${RED}❌ FAILED${NC}: Deprecated configuration ($error_count)"

        elif echo "$build_output" | grep -q "resource.*not found\|linking failed"; then
            error_type="RESOURCE_LINKING"
            error_count=$(echo "$build_output" | grep -c "error:")
            echo -e "${RED}❌ FAILED${NC}: Resource linking errors ($error_count)"

        elif echo "$build_output" | grep -q "FAIL_ON_PROJECT_REPOS"; then
            error_type="REPOSITORY_CONFIG"
            error_count=1
            echo -e "${RED}❌ FAILED${NC}: Repository configuration issue"

        else
            error_type="OTHER"
            error_count=$(echo "$build_output" | grep -c "error:")
            echo -e "${RED}❌ FAILED${NC}: Other errors ($error_count)"
        fi
    fi

    # Write to results
    echo "$project,$status,$build_time,$error_type,$error_count,Build time: ${build_time}s" >> "$RESULTS_FILE"

    cd ..
done

echo ""
echo "======================================="
echo "Build Testing Complete"
echo "======================================="
echo ""
echo "Results:"
echo "  Total Projects: $total"
echo "  Success: $success ($(( success * 100 / total ))%)"
echo "  Failed: $failed ($(( failed * 100 / total ))%)"
echo "  Skipped: $skipped ($(( skipped * 100 / total ))%)"
echo ""
echo "Results saved to: $RESULTS_FILE"

# Generate summary report
cat > "$SUMMARY_FILE" << EOF
# Android Build Test Results

**Date**: $(date)
**Total Projects**: $total
**Success**: $success ($(( success * 100 / total ))%)
**Failed**: $failed ($(( failed * 100 / total ))%)
**Skipped**: $skipped ($(( skipped * 100 / total ))%)

---

## Results by Status

### Successful Builds ($success projects)
$(grep ",SUCCESS," "$RESULTS_FILE" | cut -d',' -f1 | sed 's/^/- /')

### Failed Builds by Error Type

#### Missing Dependencies
$(grep ",MISSING_DEPENDENCY," "$RESULTS_FILE" | cut -d',' -f1 | sed 's/^/- /')

#### Kotlin Compilation Errors
$(grep ",KOTLIN_COMPILE," "$RESULTS_FILE" | cut -d',' -f1 | sed 's/^/- /')

#### Resource Linking Errors
$(grep ",RESOURCE_LINKING," "$RESULTS_FILE" | cut -d',' -f1 | sed 's/^/- /')

#### Deprecated Configuration
$(grep ",DEPRECATED_CONFIG," "$RESULTS_FILE" | cut -d',' -f1 | sed 's/^/- /')

#### Repository Configuration
$(grep ",REPOSITORY_CONFIG," "$RESULTS_FILE" | cut -d',' -f1 | sed 's/^/- /')

#### Timeout
$(grep ",TIMEOUT," "$RESULTS_FILE" | cut -d',' -f1 | sed 's/^/- /')

#### Other Errors
$(grep ",OTHER," "$RESULTS_FILE" | cut -d',' -f1 | sed 's/^/- /')

---

## Detailed Results

\`\`\`csv
$(cat "$RESULTS_FILE")
\`\`\`

---

## Next Steps

Based on error types:
1. **Missing Dependencies**: Add JitPack or other repositories to settings.gradle.kts
2. **Kotlin Compilation**: Fix code-level type mismatches and missing parameters
3. **Resource Linking**: Fix theme/resource references in XML
4. **Deprecated Config**: Remove deprecated Gradle properties
5. **Repository Config**: Update settings.gradle.kts repository mode

---

**Report Generated**: $(date)
EOF

echo "Summary report saved to: $SUMMARY_FILE"
echo ""
echo "To view results:"
echo "  cat $RESULTS_FILE"
echo "  cat $SUMMARY_FILE"
