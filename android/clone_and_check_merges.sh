#!/bin/bash
# Clone pending repositories and check for merge conflicts
# Only performs cloning and merge checking - no configuration yet

set +e

BASE_DIR="/Users/aakashnigam/Axion/AxionApps/android"
CONFLICT_LOG="$BASE_DIR/MERGE_CONFLICTS_FOUND.md"

# Repository configurations: repo_name|repo_url
REPOS=(
  # Government & Services (4)
  "android_sarkar-seva|https://github.com/akaash-nigam/android_sarkar-seva.git"
  "android_ayushman-card-manager|https://github.com/akaash-nigam/android_ayushman-card-manager.git"
  "android_MeraShahar|https://github.com/akaash-nigam/android_MeraShahar.git"
  "android_village-job-board|https://github.com/akaash-nigam/android_village-job-board.git"

  # Tools & Collections (7)
  "android_analysis|https://github.com/akaash-nigam/android_analysis.git"
  "android_shared|https://github.com/akaash-nigam/android_shared.git"
  "android_tools|https://github.com/akaash-nigam/android_tools.git"
  "android_CodexAndroid|https://github.com/akaash-nigam/android_CodexAndroid.git"
  "android_India1_Apps|https://github.com/akaash-nigam/android_India1_Apps.git"
  "android_India2_Apps|https://github.com/akaash-nigam/android_India2_Apps.git"
  "android_India3_apps|https://github.com/akaash-nigam/android_India3_apps.git"

  # E-commerce & Retail (3)
  "Android_DailyNeedsDelivery|https://github.com/akaash-nigam/Android_DailyNeedsDelivery.git"
  "Android_RasodaManager|https://github.com/akaash-nigam/Android_RasodaManager.git"
  "Android_ApexLifeStyle|https://github.com/akaash-nigam/Android_ApexLifeStyle.git"

  # Family & Social (3)
  "Android_FamilyHub|https://github.com/akaash-nigam/Android_FamilyHub.git"
  "android_ShadiConnect|https://github.com/akaash-nigam/android_ShadiConnect.git"
  "android_FanConnect|https://github.com/akaash-nigam/android_FanConnect.git"

  # Finance & Payment (3)
  "android_bachat-sahayak|https://github.com/akaash-nigam/android_bachat-sahayak.git"
  "android_KisanPay|https://github.com/akaash-nigam/android_KisanPay.git"
  "android_SafeCalc|https://github.com/akaash-nigam/android_SafeCalc.git"

  # Lifestyle & AI Apps (3)
  "android_GlowAI|https://github.com/akaash-nigam/android_GlowAI.git"
  "android_JyotishAI|https://github.com/akaash-nigam/android_JyotishAI.git"
  "android_QuotelyAI|https://github.com/akaash-nigam/android_QuotelyAI.git"

  # Transportation & Travel (2)
  "android_TrainSathi|https://github.com/akaash-nigam/android_TrainSathi.git"
  "android_RentRamp|https://github.com/akaash-nigam/android_RentRamp.git"

  # Other (3)
  "android_Canada|https://github.com/akaash-nigam/android_Canada.git"
  "Android_Pinnacle|https://github.com/akaash-nigam/Android_Pinnacle.git"
  "android_PhoneGuardian|https://github.com/akaash-nigam/android_PhoneGuardian.git"
)

# Initialize conflict log
echo "# Merge Conflict Report - Pending Repositories" > "$CONFLICT_LOG"
echo "" >> "$CONFLICT_LOG"
echo "**Date:** $(date '+%B %d, %Y')" >> "$CONFLICT_LOG"
echo "**Total Repositories:** ${#REPOS[@]}" >> "$CONFLICT_LOG"
echo "" >> "$CONFLICT_LOG"
echo "---" >> "$CONFLICT_LOG"
echo "" >> "$CONFLICT_LOG"

total_repos=0
repos_with_branches=0
successful_merges=0
failed_merges=0
no_branches=0
clone_failures=0

echo "========================================"
echo "CLONE AND MERGE CHECK"
echo "Total Repositories: ${#REPOS[@]}"
echo "========================================"
echo ""

for repo_config in "${REPOS[@]}"; do
  IFS='|' read -r repo_name repo_url <<< "$repo_config"
  total_repos=$((total_repos + 1))

  echo "========================================="
  echo "[$total_repos/${#REPOS[@]}] Processing: $repo_name"
  echo "========================================="

  cd "$BASE_DIR"

  # Clone if doesn't exist
  if [ ! -d "$repo_name" ]; then
    echo "Cloning repository..."
    if git clone "$repo_url" 2>&1; then
      echo "✅ Clone successful"
    else
      echo "❌ Clone failed - skipping"
      clone_failures=$((clone_failures + 1))
      echo "" >> "$CONFLICT_LOG"
      echo "## ❌ $repo_name - CLONE FAILED" >> "$CONFLICT_LOG"
      echo "**Status:** Could not clone repository" >> "$CONFLICT_LOG"
      echo "**URL:** \`$repo_url\`" >> "$CONFLICT_LOG"
      echo "" >> "$CONFLICT_LOG"
      echo ""
      continue
    fi
  else
    echo "Repository already exists locally"
  fi

  cd "$repo_name"

  # Get current branch
  current_branch=$(git branch --show-current 2>/dev/null || git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")
  echo "Current branch: $current_branch"

  # Checkout main/master
  git checkout master 2>/dev/null || git checkout main 2>/dev/null || echo "Using current branch"

  # Fetch latest
  echo "Fetching latest..."
  git fetch --all 2>&1 | grep -v "^From" || true

  # Find Claude branches
  claude_branches=$(git branch -r | grep "claude/" | sed 's/^[[:space:]]*//' || true)

  if [ -z "$claude_branches" ]; then
    echo "✅ No Claude branches found - nothing to merge"
    echo "" >> "$CONFLICT_LOG"
    echo "## ✅ $repo_name" >> "$CONFLICT_LOG"
    echo "**Status:** No Claude branches to merge" >> "$CONFLICT_LOG"
    echo "" >> "$CONFLICT_LOG"
    no_branches=$((no_branches + 1))
    echo ""
    continue
  fi

  repos_with_branches=$((repos_with_branches + 1))

  echo ""
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
    echo "## ⚠️ $repo_name" >> "$CONFLICT_LOG"
    echo "**Status:** Could not determine best branch" >> "$CONFLICT_LOG"
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

    # Show what was merged
    files_changed=$(git diff --name-only HEAD~1 HEAD 2>/dev/null | wc -l | tr -d ' ')

    echo "" >> "$CONFLICT_LOG"
    echo "## ✅ $repo_name - SUCCESS" >> "$CONFLICT_LOG"
    echo "**Status:** Merged successfully" >> "$CONFLICT_LOG"
    echo "**Branch:** \`$best_branch\`" >> "$CONFLICT_LOG"
    echo "**Commits:** $max_commits" >> "$CONFLICT_LOG"
    echo "**Files Changed:** $files_changed" >> "$CONFLICT_LOG"
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

      # Count conflicts
      conflict_count=$(echo "$conflicts" | wc -l | tr -d ' ')

      # Log to conflict report
      echo "" >> "$CONFLICT_LOG"
      echo "## 🔴 $repo_name - CONFLICTS FOUND" >> "$CONFLICT_LOG"
      echo "**Status:** MERGE CONFLICT" >> "$CONFLICT_LOG"
      echo "**Branch:** \`$best_branch\`" >> "$CONFLICT_LOG"
      echo "**Commits in Branch:** $max_commits" >> "$CONFLICT_LOG"
      echo "**Conflicting Files:** $conflict_count" >> "$CONFLICT_LOG"
      echo "" >> "$CONFLICT_LOG"
      echo "### Conflicting Files:" >> "$CONFLICT_LOG"
      echo "\`\`\`" >> "$CONFLICT_LOG"
      echo "$conflicts" >> "$CONFLICT_LOG"
      echo "\`\`\`" >> "$CONFLICT_LOG"
      echo "" >> "$CONFLICT_LOG"

      # Show conflict details for each file (first 50 lines)
      echo "### Conflict Details:" >> "$CONFLICT_LOG"
      echo "" >> "$CONFLICT_LOG"

      conflict_num=0
      while IFS= read -r conflict_file; do
        if [ -n "$conflict_file" ]; then
          conflict_num=$((conflict_num + 1))
          echo "📄 [$conflict_num/$conflict_count] Conflict in: $conflict_file"
          echo "#### $conflict_num. \`$conflict_file\`" >> "$CONFLICT_LOG"
          echo "" >> "$CONFLICT_LOG"
          echo "\`\`\`diff" >> "$CONFLICT_LOG"
          git diff "$conflict_file" 2>/dev/null | head -50 >> "$CONFLICT_LOG" || echo "Could not show diff" >> "$CONFLICT_LOG"
          echo "\`\`\`" >> "$CONFLICT_LOG"
          echo "" >> "$CONFLICT_LOG"

          # Show actual conflict markers from file
          if [ -f "$conflict_file" ]; then
            echo "**Conflict markers in file:**" >> "$CONFLICT_LOG"
            echo "\`\`\`" >> "$CONFLICT_LOG"
            grep -A 5 -B 5 "^<<<<<<< HEAD" "$conflict_file" 2>/dev/null | head -30 >> "$CONFLICT_LOG" || echo "Could not extract conflict markers" >> "$CONFLICT_LOG"
            echo "\`\`\`" >> "$CONFLICT_LOG"
            echo "" >> "$CONFLICT_LOG"
          fi
        fi
      done <<< "$conflicts"

      echo ""
      echo "⚠️  MERGE LEFT IN CONFLICTED STATE"
      echo "   Repository: $repo_name"
      echo "   Conflicts in $conflict_count files"
      echo ""

    else
      echo "⚠️  Merge failed but no conflicts detected"
      echo "   Error output:"
      echo "$merge_output"

      failed_merges=$((failed_merges + 1))

      echo "" >> "$CONFLICT_LOG"
      echo "## ⚠️ $repo_name - MERGE FAILED" >> "$CONFLICT_LOG"
      echo "**Status:** Failed (no conflicts detected)" >> "$CONFLICT_LOG"
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
echo "MERGE CHECK COMPLETE"
echo "========================================="
echo "Total Repositories: $total_repos"
echo "Clone Failures: $clone_failures"
echo "Repositories with Claude branches: $repos_with_branches"
echo "Successful merges: $successful_merges"
echo "Failed merges (conflicts): $failed_merges"
echo "No branches to merge: $no_branches"
echo ""
if [ $failed_merges -gt 0 ]; then
  echo "⚠️  $failed_merges repositories have CONFLICTS"
  echo "   Review: $CONFLICT_LOG"
else
  echo "✅ All merges successful - no conflicts"
fi
echo "========================================="

# Add summary to log
echo "" >> "$CONFLICT_LOG"
echo "---" >> "$CONFLICT_LOG"
echo "" >> "$CONFLICT_LOG"
echo "## Summary" >> "$CONFLICT_LOG"
echo "" >> "$CONFLICT_LOG"
echo "| Metric | Count |" >> "$CONFLICT_LOG"
echo "|--------|-------|" >> "$CONFLICT_LOG"
echo "| Total Repositories | $total_repos |" >> "$CONFLICT_LOG"
echo "| Clone Failures | $clone_failures |" >> "$CONFLICT_LOG"
echo "| Repos with Claude Branches | $repos_with_branches |" >> "$CONFLICT_LOG"
echo "| Successful Merges | $successful_merges |" >> "$CONFLICT_LOG"
echo "| Failed Merges (Conflicts) | $failed_merges |" >> "$CONFLICT_LOG"
echo "| No Branches to Merge | $no_branches |" >> "$CONFLICT_LOG"
echo "" >> "$CONFLICT_LOG"

if [ $failed_merges -gt 0 ]; then
  echo "" >> "$CONFLICT_LOG"
  echo "## ⚠️ Action Required" >> "$CONFLICT_LOG"
  echo "" >> "$CONFLICT_LOG"
  echo "**$failed_merges repositories have merge conflicts** that need to be resolved before configuration." >> "$CONFLICT_LOG"
  echo "" >> "$CONFLICT_LOG"
  echo "### Next Steps:" >> "$CONFLICT_LOG"
  echo "" >> "$CONFLICT_LOG"
  echo "1. Review conflict details above" >> "$CONFLICT_LOG"
  echo "2. For each conflicted repository, decide on resolution strategy" >> "$CONFLICT_LOG"
  echo "3. Resolve conflicts manually or abort merge" >> "$CONFLICT_LOG"
  echo "4. Once resolved, run configuration script" >> "$CONFLICT_LOG"
  echo "" >> "$CONFLICT_LOG"
  exit 1
else
  echo "" >> "$CONFLICT_LOG"
  echo "## ✅ All Clear" >> "$CONFLICT_LOG"
  echo "" >> "$CONFLICT_LOG"
  echo "All merges completed successfully. Ready to proceed with configuration." >> "$CONFLICT_LOG"
  echo "" >> "$CONFLICT_LOG"
  exit 0
fi
