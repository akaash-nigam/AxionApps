#!/bin/bash
# Batch setup script for Transportation & Travel category

set -e

BASE_DIR="/Users/aakashnigam/Axion/AxionApps/android"
TEMPLATE_DIR="$BASE_DIR/android_majdoor-mitra"

# Repository configurations: repo_name|repo_url|description|user1|user2|user3|topic1|topic2|topic3|topic4
REPOS=(
  "android_TrainSathi|https://github.com/akaash-nigam/android_TrainSathi.git|train travel companion and railway information platform|Traveler|Station Master|Ticket Agent|railway|train-travel|travel-companion|india"
  "android_RentRamp|https://github.com/akaash-nigam/android_RentRamp.git|vehicle rental and ride-sharing platform|Rider|Vehicle Owner|Fleet Manager|vehicle-rental|ride-sharing|transportation|india"
)

echo "========================================"
echo "TRANSPORTATION & TRAVEL CATEGORY SETUP"
echo "Total Repositories: ${#REPOS[@]}"
echo "========================================"
echo ""

for repo_config in "${REPOS[@]}"; do
  IFS='|' read -r repo_name repo_url description user1 user2 user3 topic1 topic2 topic3 topic4 <<< "$repo_config"

  echo "========================================"
  echo "Processing: $repo_name"
  echo "========================================"

  cd "$BASE_DIR/$repo_name"

  # Copy .github configuration
  echo "Copying GitHub configuration..."
  cp -r "$TEMPLATE_DIR/.github" .
  cp "$TEMPLATE_DIR/SECURITY.md" .

  # Adapt configuration
  echo "Adapting configuration..."
  repo_short=$(echo "$repo_name" | sed 's/android_//; s/Android_//; s/android-//')

  find .github -type f \( -name "*.yml" -o -name "*.yaml" -o -name "*.md" -o -name "*.sh" \) -exec sed -i '' "
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
  " {} \;

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
echo "✅ TRANSPORTATION & TRAVEL CATEGORY COMPLETE!"
echo "All 2 repositories configured"
echo "========================================"
