#!/bin/bash

echo "=========================================="
echo "Pushing All Documentation to GitHub"
echo "=========================================="
echo ""

total=0
success=0
failed=0

# iOS Apps
echo "=== iOS Apps ==="
cd /Users/aakashnigam/Axion/AxionApps/ios
for app in iOS_*; do
  if [ -d "$app/docs" ]; then
    echo "Processing $app..."
    cd "$app"
    git add docs/*.md 2>/dev/null
    if git commit -m "Add comprehensive documentation

- Add README.md with overview and features
- Add USER_GUIDE.md with step-by-step instructions
- Add API_DOCUMENTATION.md with API references
- Add CHANGELOG.md with version history
- Add CONTRIBUTING.md with contribution guidelines
- Add FAQ.md with frequently asked questions

🤖 Generated with Claude Code" 2>&1 | grep -qE "nothing to commit|no changes"; then
      echo "  ℹ Already committed"
    else
      echo "  ✓ Committed"
    fi

    if git push 2>&1 | grep -qE "Everything up-to-date|-> main|-> master"; then
      echo "  ✓ Pushed"
      success=$((success + 1))
    else
      echo "  ✗ Push failed"
      failed=$((failed + 1))
    fi
    cd ..
    total=$((total + 1))
  fi
done

# VisionOS Apps
echo ""
echo "=== VisionOS Apps ==="
cd /Users/aakashnigam/Axion/AxionApps/visionOS
for app in visionOS_*; do
  if [ -d "$app/docs" ]; then
    echo "Processing $app..."
    cd "$app"
    git add docs/*.md 2>/dev/null
    if git commit -m "Add comprehensive documentation

- Add README.md with overview and features
- Add USER_GUIDE.md with step-by-step instructions
- Add API_DOCUMENTATION.md with API references
- Add CHANGELOG.md with version history
- Add CONTRIBUTING.md with contribution guidelines
- Add FAQ.md with frequently asked questions

🤖 Generated with Claude Code" 2>&1 | grep -qE "nothing to commit|no changes"; then
      echo "  ℹ Already committed"
    else
      echo "  ✓ Committed"
    fi

    if git push 2>&1 | grep -qE "Everything up-to-date|-> main|-> master"; then
      echo "  ✓ Pushed"
      success=$((success + 1))
    else
      echo "  ✗ Push failed"
      failed=$((failed + 1))
    fi
    cd ..
    total=$((total + 1))
  fi
done

# Android Apps
echo ""
echo "=== Android Apps ==="
cd /Users/aakashnigam/Axion/AxionApps/android
for app in android_*; do
  if [ -d "$app/docs" ]; then
    echo "Processing $app..."
    cd "$app"
    git add docs/*.md 2>/dev/null
    if git commit -m "Add comprehensive documentation

- Add README.md with overview and features
- Add USER_GUIDE.md with step-by-step instructions
- Add API_DOCUMENTATION.md with API references
- Add CHANGELOG.md with version history
- Add CONTRIBUTING.md with contribution guidelines
- Add FAQ.md with frequently asked questions

🤖 Generated with Claude Code" 2>&1 | grep -qE "nothing to commit|no changes"; then
      echo "  ℹ Already committed"
    else
      echo "  ✓ Committed"
    fi

    if git push 2>&1 | grep -qE "Everything up-to-date|-> main|-> master"; then
      echo "  ✓ Pushed"
      success=$((success + 1))
    else
      echo "  ✗ Push failed"
      failed=$((failed + 1))
    fi
    cd ..
    total=$((total + 1))
  fi
done

echo ""
echo "=========================================="
echo "Documentation Push Complete!"
echo "  Total apps: $total"
echo "  Success: $success"
echo "  Failed: $failed"
echo "=========================================="
