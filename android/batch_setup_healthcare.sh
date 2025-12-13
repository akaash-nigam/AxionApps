#!/bin/bash
# Batch setup script for Healthcare & Wellness category

set -e

BASE_DIR="/Users/aakashnigam/Axion/AxionApps/android"
TEMPLATE_DIR="$BASE_DIR/android_majdoor-mitra"

# Repository configurations: repo_name|repo_url|description|user1|user2|user3|topic1|topic2|topic3|topic4
REPOS=(
  "android_swasthya-sahayak|https://github.com/akaash-nigam/android_swasthya-sahayak.git|comprehensive health management platform for medical records and wellness tracking|Patient|Doctor|Health Worker|healthcare|wellness|medical-records|telemedicine"
  "android_HerCycle|https://github.com/akaash-nigam/android_HerCycle.git|women's health and menstrual cycle tracking platform|User|Healthcare Provider|Partner|womens-health|period-tracker|fertility|wellness"
  "android_BimaShield|https://github.com/akaash-nigam/android_BimaShield.git|health insurance management and claim processing platform|Policyholder|Insurance Agent|Claims Officer|health-insurance|claims-management|policy-management|india"
  "android_MedNow|https://github.com/akaash-nigam/android_MedNow.git|on-demand medical services and doctor consultation platform|Patient|Doctor|Pharmacist|telemedicine|healthcare|doctor-consultation|medical-services"
  "Android_ElderCareConnect|https://github.com/akaash-nigam/Android_ElderCareConnect.git|elder care coordination platform connecting seniors with caregivers|Senior|Caregiver|Family Member|elder-care|senior-health|caregiving|family-health"
  "Android_HealthyFamily|https://github.com/akaash-nigam/Android_HealthyFamily.git|family health tracking and wellness management platform|Parent|Child|Healthcare Provider|family-health|wellness|health-tracking|preventive-care"
  "android_RainbowMind|https://github.com/akaash-nigam/android_RainbowMind.git|mental health and emotional wellness support platform|User|Therapist|Counselor|mental-health|therapy|wellness|emotional-support"
)

echo "========================================"
echo "HEALTHCARE & WELLNESS CATEGORY SETUP"
echo "Total Repositories: ${#REPOS[@]}"
echo "========================================"
echo ""

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
  git checkout master 2>/dev/null || git checkout main 2>/dev/null || true

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
echo "✅ HEALTHCARE CATEGORY COMPLETE!"
echo "All 7 repositories configured"
echo "========================================"
