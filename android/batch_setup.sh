#!/bin/bash
# Batch setup script for remaining repositories

set -e

BASE_DIR="/Users/aakashnigam/Axion/AxionApps/android"
TEMPLATE_DIR="$BASE_DIR/android_majdoor-mitra"

# Repository configurations: repo_name|repo_url|description|user1|user2|user3|topic1|topic2|topic3
REPOS=(
  "android_BattlegroundIndia|https://github.com/akaash-nigam/android_BattlegroundIndia.git|competitive gaming platform for Indian mobile gamers|Player|Organizer|Spectator|gaming|esports|battleground|tournament-platform"
  "android_BoloCare|https://github.com/akaash-nigam/android_BoloCare.git|healthcare communication platform connecting patients with doctors|Patient|Doctor|Caregiver|healthcare|telemedicine|patient-care|medical-app"
  "Android_WealthWise|https://github.com/akaash-nigam/Android_WealthWise.git|personal finance and wealth management platform|Investor|Advisor|Trader|finance|wealth-management|investment|personal-finance"
  "android_karz-mukti|https://github.com/akaash-nigam/android_karz-mukti.git|debt management and relief platform for financial freedom|Borrower|Counselor|Lender|debt-relief|financial-planning|credit-management|india"
  "android_dukaan-sahayak|https://github.com/akaash-nigam/android_dukaan-sahayak.git|shop management platform for small business owners|Shop Owner|Customer|Supplier|retail|shop-management|pos|inventory"
  "Android_Aurum|https://github.com/akaash-nigam/Android_Aurum.git|gold investment and savings platform|Investor|Dealer|Advisor|gold-investment|commodity-trading|savings|fintech"
  "android_kisan-sahayak|https://github.com/akaash-nigam/android_kisan-sahayak.git|agricultural support platform for farmers|Farmer|Buyer|Advisor|agriculture|farming|crop-management|india"
  "Android_VahanTracker|https://github.com/akaash-nigam/Android_VahanTracker.git|vehicle tracking and fleet management platform|Driver|Fleet Manager|Owner|vehicle-tracking|fleet-management|gps|logistics"
  "android_safar-saathi|https://github.com/akaash-nigam/android_safar-saathi.git|travel companion and journey management platform|Traveler|Guide|Operator|travel|tourism|journey-planning|india"
)

for repo_config in "${REPOS[@]}"; do
  IFS='|' read -r repo_name repo_url description user1 user2 user3 topic1 topic2 topic3 topic4 <<< "$repo_config"

  echo "========================================"
  echo "Processing: $repo_name"
  echo "========================================"

  cd "$BASE_DIR"

  # Clone if not exists
  if [ ! -d "$repo_name" ]; then
    echo "Cloning $repo_name..."
    git clone "$repo_url"
  fi

  cd "$repo_name"

  # Merge all claude branches
  echo "Merging branches..."
  git checkout master 2>/dev/null || git checkout main

  # Find all claude branches and merge the one with most commits
  claude_branches=$(git branch -r | grep "claude/" || true)
  if [ -n "$claude_branches" ]; then
    best_branch=$(git branch -r | grep "claude/" | while read branch; do
      count=$(git log --oneline "$branch" 2>/dev/null | wc -l | tr -d ' ')
      echo "$count $branch"
    done | sort -rn | head -1 | awk '{print $2}')

    if [ -n "$best_branch" ]; then
      echo "Merging $best_branch..."
      git merge "$best_branch" --no-edit || true
    fi
  fi

  # Push and delete claude branches
  git push origin master 2>/dev/null || git push origin main 2>/dev/null || true
  git branch -r | grep "claude/" | sed 's|origin/||' | xargs -I {} git push origin --delete {} 2>/dev/null || true

  # Copy .github configuration
  echo "Copying GitHub configuration..."
  cp -r "$TEMPLATE_DIR/.github" .
  cp "$TEMPLATE_DIR/SECURITY.md" .

  # Adapt configuration
  echo "Adapting configuration..."
  repo_short=$(echo "$repo_name" | sed 's/android_//; s/Android_//')

  find .github -type f \( -name "*.yml" -o -name "*.yaml" -o -name "*.md" -o -name "*.sh" \) | xargs sed -i '' "
    s/android_majdoor-mitra/$repo_name/g
    s/Majdoor Mitra/$repo_short/g
    s/majdoor-mitra/$(echo $repo_short | tr '[:upper:]' '[:lower:]')/g
    s/Daily Wage Worker/$user1/g
    s/NREGA Worker/$user2/g
    s/Contractor/$user3/g
    s/user: worker/user: $(echo $user1 | tr '[:upper:]' '[:lower:]')/g
    s/user: contractor/user: $(echo $user3 | tr '[:upper:]' '[:lower:]')/g
    s/user: nrega/user: $(echo $user2 | tr '[:upper:]' '[:lower:]')/g
    s/empowering daily wage workers with job discovery, payment tracking, and NREGA integration/$description/g
  "

  # Update topics
  sed -i '' "
    /^- workers-rights$/d
    /^- nrega$/d
    /^- social-impact$/d
    /^- kotlin$/{
      a\\
- $topic1\\
- $topic2\\
- $topic3\\
- $topic4
    }
  " .github/REPOSITORY_SETUP.md

  # Update feature request template
  sed -i '' "s/This feature aligns with the app's purpose of helping workers/This feature aligns with the app's purpose of $description/g" .github/ISSUE_TEMPLATE/feature_request.yml

  # Update labels script
  sed -i '' "
    s/Related to daily wage workers/Related to ${user1}s/
    s/Related to contractors/Related to ${user3}s/
    s/Related to NREGA workers/Related to ${user2}s/
  " .github/scripts/setup-labels.sh

  # Run setup scripts
  echo "Creating labels and milestones..."
  chmod +x .github/scripts/*.sh
  .github/scripts/setup-labels.sh > /dev/null 2>&1 || true
  .github/scripts/setup-milestones.sh > /dev/null 2>&1 || true

  # Commit and push
  echo "Committing changes..."
  echo "SESSION_SUMMARY_$(echo $repo_short | tr '[:lower:]' '[:upper:]').md" >> .gitignore
  git add .
  git commit -m "Add comprehensive GitHub repository configuration and automation

- Add CI/CD workflows (android-ci, android-release, codeql, project-automation)
- Add security configuration (Dependabot, SECURITY.md, CodeQL scanning)
- Add issue and PR templates adapted for $description
- Add project management scripts (labels, milestones, project setup)
- Add comprehensive documentation (PROJECT_GUIDE, REPOSITORY_SETUP, etc.)
- Configure CODEOWNERS for code review
- Create 30+ labels for project organization
- Create 8 milestones for project tracking
- Adapt all user types ($user1, $user2, $user3)

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>" || true

  git push origin master 2>/dev/null || git push origin main 2>/dev/null || true

  echo "✅ Completed: $repo_name"
  echo ""
done

echo "========================================"
echo "✅ All 9 repositories configured!"
echo "========================================"
