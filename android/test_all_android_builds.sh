#!/bin/bash
# Test build status for all Android repositories

BASE_DIR="/Users/aakashnigam/Axion/AxionApps/android"
REPORT_FILE="$BASE_DIR/BUILD_STATUS_REPORT.md"

echo "========================================="
echo "ANDROID BUILD TEST"
echo "========================================="
echo ""

# Initialize report
cat > "$REPORT_FILE" << 'EOF'
# Android Build Status Report

Generated: $(date)

## Build Results

EOF

success_count=0
fail_count=0
skip_count=0

for dir in "$BASE_DIR"/android_*; do
  if [ ! -d "$dir" ]; then
    continue
  fi

  repo_name=$(basename "$dir")
  echo "========================================="
  echo "Testing: $repo_name"
  echo "========================================="

  cd "$dir"

  # Check if it's an Android project
  if [ ! -f "build.gradle.kts" ] && [ ! -f "build.gradle" ]; then
    echo "⏭️  Skipped: Not an Android project"
    echo "- ⏭️  **$repo_name**: Not an Android project" >> "$REPORT_FILE"
    skip_count=$((skip_count + 1))
    echo ""
    continue
  fi

  # Check if gradlew exists
  if [ ! -f "gradlew" ]; then
    echo "❌ Failed: No gradlew script"
    echo "- ❌ **$repo_name**: No gradlew script" >> "$REPORT_FILE"
    fail_count=$((fail_count + 1))
    echo ""
    continue
  fi

  # Try to build (skip code quality checks)
  echo "Building..."
  if ./gradlew assembleDebug -x detekt -x ktlintCheck -x lintVitalRelease --no-daemon > /dev/null 2>&1; then
    echo "✅ BUILD SUCCESSFUL"
    echo "- ✅ **$repo_name**: Build successful" >> "$REPORT_FILE"
    success_count=$((success_count + 1))
  else
    echo "❌ BUILD FAILED"
    # Try to get error info
    error_msg=$(./gradlew assembleDebug -x detekt -x ktlintCheck -x lintVitalRelease --no-daemon 2>&1 | grep -E "(error|Error|ERROR|failed|Failed|What went wrong)" | head -3 | tr '\n' ' ')
    echo "- ❌ **$repo_name**: Build failed - ${error_msg:0:100}..." >> "$REPORT_FILE"
    fail_count=$((fail_count + 1))
  fi

  echo ""
done

# Add summary to report
cat >> "$REPORT_FILE" << EOF

## Summary

- **Total Repositories**: $((success_count + fail_count + skip_count))
- **✅ Successful Builds**: $success_count
- **❌ Failed Builds**: $fail_count
- **⏭️  Skipped (Not Android)**: $skip_count

---
*Report generated: $(date)*
EOF

echo "========================================="
echo "BUILD TEST COMPLETE"
echo "========================================="
echo "Total: $((success_count + fail_count + skip_count))"
echo "✅ Success: $success_count"
echo "❌ Failed: $fail_count"
echo "⏭️  Skipped: $skip_count"
echo ""
echo "Report saved to: $REPORT_FILE"
