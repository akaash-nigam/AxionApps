#!/bin/bash

echo "=========================================="
echo "Pushing Android Landing Pages to GitHub"
echo "=========================================="
echo ""

# 16 Android apps (15 new + 1 already done)
apps=(
  "android_bachat-sahayak"
  "android_BattlegroundIndia"
  "android_bhasha-buddy"
  "android_BimaShield"
  "android_dukaan-sahayak"
  "android_GharSeva"
  "android_GlowAI"
  "android_HerCycle"
  "android_JyotishAI"
  "android_MedNow"
  "android_MeraShahar"
  "android_RentCred"
  "android_SafeCalc"
  "android_sarkar-seva"
  "android_swasthya-sahayak"
  "android_TrainSathi"
)

count=1
total=${#apps[@]}
success=0
failed=0

for app in "${apps[@]}"; do
  echo "[$count/$total] Processing $app..."

  if [ ! -d "$app" ]; then
    echo "  ✗ Directory not found"
    failed=$((failed + 1))
    count=$((count + 1))
    continue
  fi

  cd "$app" || continue

  # Check if docs folder exists
  if [ ! -d "docs" ]; then
    echo "  ✗ No docs folder found"
    cd ..
    failed=$((failed + 1))
    count=$((count + 1))
    continue
  fi

  # Get current branch name
  current_branch=$(git branch --show-current 2>/dev/null)

  if [ -z "$current_branch" ]; then
    echo "  → Fetching remote branches..."
    git fetch origin 2>/dev/null
    if git show-ref --verify --quiet refs/remotes/origin/main; then
      git checkout main
      current_branch="main"
    elif git show-ref --verify --quiet refs/remotes/origin/master; then
      git checkout master
      current_branch="master"
    else
      git checkout -b main
      current_branch="main"
    fi
  fi

  echo "  → Current branch: $current_branch"

  # Add and commit docs
  echo "  → Committing landing pages..."
  git add docs/
  if git commit -m "Add professional landing pages for GitHub Pages

- Add index.html with features, testimonials, and screenshots
- Add privacy.html with comprehensive privacy policy
- Add terms.html with terms of service
- Add support.html with FAQ and support contact

🤖 Generated with Claude Code" 2>&1 | grep -qE "nothing to commit|no changes"; then
    echo "  ℹ Already committed"
  else
    echo "  ✓ Committed"
  fi

  # Push to GitHub
  echo "  → Pushing to GitHub..."
  if git push -u origin "$current_branch" 2>&1 | grep -qE "Everything up-to-date|-> main|-> master|branch '$current_branch' set up"; then
    echo "  ✓ Successfully pushed"
    success=$((success + 1))
  else
    echo "  ✗ Push failed"
    failed=$((failed + 1))
  fi

  cd ..
  count=$((count + 1))
  sleep 1
done

echo ""
echo "=========================================="
echo "Push Complete!"
echo "  Success: $success"
echo "  Failed: $failed"
echo "=========================================="
