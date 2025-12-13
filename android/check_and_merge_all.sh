#!/bin/bash
# Script to check for Claude branches and attempt merges on all pending repositories
# Shows conflicts without aborting so they can be reviewed

set +e  # Don't exit on error - we want to see all conflicts

BASE_DIR="/Users/aakashnigam/Axion/AxionApps/android"
CONFLICT_LOG="$BASE_DIR/MERGE_CONFLICTS_FOUND.md"

# Pending repositories by category
PENDING_REPOS=(
  # Government & Services (4)
  "android_sarkar-seva"
  "android_ayushman-card-manager"
  "android_MeraShahar"
  "android_village-job-board"

  # Tools & Collections (7)
  "android_analysis"
  "android_shared"
  "android_tools"
  "android_CodexAndroid"
  "android_India1_Apps"
  "android_India2_Apps"
  "android_India3_apps"

  # E-commerce & Retail (3)
  "Android_DailyNeedsDelivery"
  "Android_RasodaManager"
  "Android_ApexLifeStyle"

  # Family & Social (3)
  "Android_FamilyHub"
  "android_ShadiConnect"
  "android_FanConnect"

  # Finance & Payment (3)
  "android_bachat-sahayak"
  "android_KisanPay"
  "android_SafeCalc"

  # Lifestyle & AI Apps (3)
  "android_GlowAI"
  "android_JyotishAI"
  "android_QuotelyAI"

  # Transportation & Travel (2)
  "android_TrainSathi"
  "android_RentRamp"

  # Other (3)
  "android_Canada"
  "Android_Pinnacle"
  "android_PhoneGuardian"
)

# Initialize conflict log
echo "# Merge Conflict Report - Pending Repositories" > "$CONFLICT_LOG"
echo "" >> "$CONFLICT_LOG"
echo "**Date:** $(date '+%B %d, %Y')" >> "$CONFLICT_LOG"
echo "**Total Repositories Checked:** ${#PENDING_REPOS[@]}" >> "$CONFLICT_LOG"
echo "" >> "$CONFLICT_LOG"
echo "---" >> "$CONFLICT_LOG"
echo "" >> "$CONFLICT_LOG"

total_repos=0
repos_with_branches=0
successful_merges=0
failed_merges=0
no_branches=0

echo "========================================"
echo "MERGE CHECK FOR PENDING REPOSITORIES"
echo "Total Repositories: ${#PENDING_REPOS[@]}"
echo "========================================"
echo ""

for repo_name in "${PENDING_REPOS[@]}"; do
  total_repos=$((total_repos + 1))

  echo "========================================="
  echo "[$total_repos/${#PENDING_REPOS[@]}] Checking: $repo_name"
  echo "========================================="

  cd "$BASE_DIR"

  # Check if repo exists
  if [ ! -d "$repo_name" ]; then
    echo "⚠️  Repository not found locally - skipping"
    echo "" >> "$CONFLICT_LOG"
    echo "## $repo_name" >> "$CONFLICT_LOG"
    echo "**Status:** ⚠️ Not cloned locally" >> "$CONFLICT_LOG"
    echo "" >> "$CONFLICT_LOG"
    no_branches=$((no_branches + 1))
    echo ""
    continue
  fi

  cd "$repo_name"

  # Get current branch
  current_branch=$(git branch --show-current)
  if [ -z "$current_branch" ]; then
    current_branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")
  fi

  echo "Current branch: $current_branch"

  # Checkout main/master
  git checkout master 2>/dev/null || git checkout main 2>/dev/null || echo "Using current branch"

  # Find Claude branches
  claude_branches=$(git branch -r | grep "claude/" | sed 's/^[[:space:]]*//' || true)

  if [ -z "$claude_branches" ]; then
    echo "✅ No Claude branches found - nothing to merge"
    echo "" >> "$CONFLICT_LOG"
    echo "## $repo_name" >> "$CONFLICT_LOG"
    echo "**Status:** ✅ No Claude branches" >> "$CONFLICT_LOG"
    echo "" >> "$CONFLICT_LOG"
    no_branches=$((no_branches + 1))
    echo ""
    continue
  fi

  repos_with_branches=$((repos_with_branches + 1))

  echo "Found Claude branches:"
  echo "$claude_branches"
  echo ""

  # Find branch with most commits
  best_branch=""
  max_commits=0

  while IFS= read -r branch; do
    if [ -n "$branch" ]; then
      branch_clean=$(echo "$branch" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
      commit_count=$(git log --oneline "$branch_clean" 2>/dev/null | wc -l | tr -d ' ')
      echo "  $branch_clean: $commit_count commits"

      if [ "$commit_count" -gt "$max_commits" ]; then
        max_commits=$commit_count
        best_branch="$branch_clean"
      fi
    fi
  done <<< "$claude_branches"

  if [ -z "$best_branch" ]; then
    echo "⚠️  Could not determine best branch - skipping"
    echo "" >> "$CONFLICT_LOG"
    echo "## $repo_name" >> "$CONFLICT_LOG"
    echo "**Status:** ⚠️ Could not determine best branch" >> "$CONFLICT_LOG"
    echo "" >> "$CONFLICT_LOG"
    no_branches=$((no_branches + 1))
    echo ""
    continue
  fi

  echo ""
  echo "Selected branch: $best_branch ($max_commits commits)"
  echo "Attempting merge..."
  echo ""

  # Attempt merge
  merge_output=$(git merge "$best_branch" --no-edit 2>&1)
  merge_status=$?

  if [ $merge_status -eq 0 ]; then
    echo "✅ MERGE SUCCESSFUL - No conflicts"
    successful_merges=$((successful_merges + 1))

    echo "" >> "$CONFLICT_LOG"
    echo "## ✅ $repo_name" >> "$CONFLICT_LOG"
    echo "**Status:** SUCCESS" >> "$CONFLICT_LOG"
    echo "**Branch Merged:** \`$best_branch\`" >> "$CONFLICT_LOG"
    echo "**Commits:** $max_commits" >> "$CONFLICT_LOG"
    echo "" >> "$CONFLICT_LOG"
  else
    echo "⚠️  MERGE FAILED - Checking for conflicts..."
    echo ""

    # Check if there are conflicts
    conflicts=$(git diff --name-only --diff-filter=U 2>/dev/null)

    if [ -n "$conflicts" ]; then
      echo "🔴 CONFLICTS DETECTED in the following files:"
      echo "$conflicts"
      echo ""

      failed_merges=$((failed_merges + 1))

      # Log to conflict report
      echo "" >> "$CONFLICT_LOG"
      echo "## 🔴 $repo_name - CONFLICTS FOUND" >> "$CONFLICT_LOG"
      echo "**Status:** MERGE CONFLICT" >> "$CONFLICT_LOG"
      echo "**Branch:** \`$best_branch\`" >> "$CONFLICT_LOG"
      echo "**Commits:** $max_commits" >> "$CONFLICT_LOG"
      echo "" >> "$CONFLICT_LOG"
      echo "### Conflicting Files:" >> "$CONFLICT_LOG"
      echo "\`\`\`" >> "$CONFLICT_LOG"
      echo "$conflicts" >> "$CONFLICT_LOG"
      echo "\`\`\`" >> "$CONFLICT_LOG"
      echo "" >> "$CONFLICT_LOG"

      # Show conflict details for each file
      echo "### Conflict Details:" >> "$CONFLICT_LOG"
      echo "" >> "$CONFLICT_LOG"

      while IFS= read -r conflict_file; do
        if [ -n "$conflict_file" ]; then
          echo "📄 Conflict in: $conflict_file"
          echo "#### File: \`$conflict_file\`" >> "$CONFLICT_LOG"
          echo "\`\`\`diff" >> "$CONFLICT_LOG"
          git diff "$conflict_file" 2>/dev/null | head -100 >> "$CONFLICT_LOG" || echo "Could not show diff" >> "$CONFLICT_LOG"
          echo "\`\`\`" >> "$CONFLICT_LOG"
          echo "" >> "$CONFLICT_LOG"
        fi
      done <<< "$conflicts"

      echo ""
      echo "⚠️  MERGE LEFT IN CONFLICTED STATE FOR REVIEW"
      echo "   To abort: git merge --abort"
      echo "   To continue after fixing: git commit"
      echo ""

    else
      echo "⚠️  Merge failed but no conflicts detected"
      echo "   Error output:"
      echo "$merge_output"

      echo "" >> "$CONFLICT_LOG"
      echo "## ⚠️ $repo_name - MERGE FAILED" >> "$CONFLICT_LOG"
      echo "**Status:** FAILED (no conflicts detected)" >> "$CONFLICT_LOG"
      echo "**Branch:** \`$best_branch\`" >> "$CONFLICT_LOG"
      echo "" >> "$CONFLICT_LOG"
      echo "### Error Output:" >> "$CONFLICT_LOG"
      echo "\`\`\`" >> "$CONFLICT_LOG"
      echo "$merge_output" >> "$CONFLICT_LOG"
      echo "\`\`\`" >> "$CONFLICT_LOG"
      echo "" >> "$CONFLICT_LOG"
    fi
  fi

  echo ""
done

# Summary
echo "========================================="
echo "MERGE CHECK SUMMARY"
echo "========================================="
echo "Total Repositories: $total_repos"
echo "Repositories with Claude branches: $repos_with_branches"
echo "Successful merges: $successful_merges"
echo "Failed merges (conflicts): $failed_merges"
echo "No branches to merge: $no_branches"
echo ""
echo "Conflict report saved to: $CONFLICT_LOG"
echo "========================================="

# Add summary to log
echo "" >> "$CONFLICT_LOG"
echo "---" >> "$CONFLICT_LOG"
echo "" >> "$CONFLICT_LOG"
echo "## Summary" >> "$CONFLICT_LOG"
echo "" >> "$CONFLICT_LOG"
echo "- **Total Repositories Checked:** $total_repos" >> "$CONFLICT_LOG"
echo "- **Repositories with Claude Branches:** $repos_with_branches" >> "$CONFLICT_LOG"
echo "- **Successful Merges:** $successful_merges" >> "$CONFLICT_LOG"
echo "- **Failed Merges (Conflicts):** $failed_merges" >> "$CONFLICT_LOG"
echo "- **No Branches to Merge:** $no_branches" >> "$CONFLICT_LOG"
echo "" >> "$CONFLICT_LOG"

if [ $failed_merges -gt 0 ]; then
  echo "" >> "$CONFLICT_LOG"
  echo "## ⚠️ Action Required" >> "$CONFLICT_LOG"
  echo "" >> "$CONFLICT_LOG"
  echo "$failed_merges repositories have merge conflicts that need to be resolved manually." >> "$CONFLICT_LOG"
  echo "" >> "$CONFLICT_LOG"
  exit 1
else
  echo "" >> "$CONFLICT_LOG"
  echo "## ✅ All Clear" >> "$CONFLICT_LOG"
  echo "" >> "$CONFLICT_LOG"
  echo "All merges completed successfully. No conflicts detected." >> "$CONFLICT_LOG"
  echo "" >> "$CONFLICT_LOG"
  exit 0
fi
