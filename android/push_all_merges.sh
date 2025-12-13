#!/bin/bash
# Push all merged changes to GitHub and delete Claude branches

set -e

BASE_DIR="/Users/aakashnigam/Axion/AxionApps/android"

# All 28 pending repositories
REPOS=(
  "android_sarkar-seva"
  "android_ayushman-card-manager"
  "android_MeraShahar"
  "android_village-job-board"
  "android_analysis"
  "android_shared"
  "android_tools"
  "android_CodexAndroid"
  "android_India1_Apps"
  "android_India2_Apps"
  "android_India3_apps"
  "Android_DailyNeedsDelivery"
  "Android_RasodaManager"
  "Android_ApexLifeStyle"
  "Android_FamilyHub"
  "android_ShadiConnect"
  "android_FanConnect"
  "android_bachat-sahayak"
  "android_KisanPay"
  "android_SafeCalc"
  "android_GlowAI"
  "android_JyotishAI"
  "android_QuotelyAI"
  "android_TrainSathi"
  "android_RentRamp"
  "android_Canada"
  "Android_Pinnacle"
  "android_PhoneGuardian"
)

total_repos=0
pushed=0
skipped=0
failed=0

echo "========================================"
echo "PUSHING ALL MERGED CHANGES TO GITHUB"
echo "Total Repositories: ${#REPOS[@]}"
echo "========================================"
echo ""

for repo_name in "${REPOS[@]}"; do
  total_repos=$((total_repos + 1))

  echo "========================================="
  echo "[$total_repos/${#REPOS[@]}] Processing: $repo_name"
  echo "========================================="

  cd "$BASE_DIR/$repo_name"

  # Get current branch
  current_branch=$(git branch --show-current 2>/dev/null || git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")
  echo "Current branch: $current_branch"

  # Check if there are changes to push
  git_status=$(git status -sb 2>/dev/null)
  echo "$git_status"

  # Check if ahead of remote
  if echo "$git_status" | grep -q "ahead"; then
    echo "Changes to push detected. Pushing to GitHub..."

    if git push origin "$current_branch" 2>&1; then
      echo "✅ Push successful"
      pushed=$((pushed + 1))
    else
      echo "❌ Push failed"
      failed=$((failed + 1))
      echo ""
      continue
    fi
  else
    echo "✅ Already synced - nothing to push"
    skipped=$((skipped + 1))
  fi

  # Delete Claude branches from remote
  echo "Checking for Claude branches to delete..."
  claude_branches=$(git branch -r | grep "origin/claude/" | sed 's|origin/||' || true)

  if [ -n "$claude_branches" ]; then
    echo "Deleting Claude branches from remote:"
    while IFS= read -r branch; do
      if [ -n "$branch" ]; then
        branch_clean=$(echo "$branch" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
        echo "  Deleting: $branch_clean"
        git push origin --delete "$branch_clean" 2>/dev/null || echo "    (already deleted or error)"
      fi
    done <<< "$claude_branches"
    echo "✅ Claude branches deleted"
  else
    echo "✅ No Claude branches to delete"
  fi

  echo ""
done

echo "========================================="
echo "PUSH SUMMARY"
echo "========================================="
echo "Total Repositories: $total_repos"
echo "Pushed to GitHub: $pushed"
echo "Already Synced: $skipped"
echo "Failed: $failed"
echo "========================================="

if [ $failed -gt 0 ]; then
  exit 1
else
  exit 0
fi
