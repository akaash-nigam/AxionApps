#!/bin/bash

echo "=========================================="
echo "Enabling GitHub Pages for Android Repos"
echo "=========================================="
echo ""

# All Android app repos (excluding utilities/collections)
# 19 already have landing pages + 16 we just created = 35 total
repos=(
  "android_ayushman-card-manager"
  "android_baal-siksha"
  "android_bachat-sahayak"
  "android_BattlegroundIndia"
  "android_bhasha-buddy"
  "android_BimaShield"
  "android_BoloCare"
  "android_dukaan-sahayak"
  "android_ExamSahayak"
  "android_FanConnect"
  "android_FluentProAI"
  "android_GharSeva"
  "android_GlowAI"
  "android_HerCycle"
  "android_JyotishAI"
  "android_karz-mukti"
  "android_kisan-sahayak"
  "android_KisanPay"
  "android_majdoor-mitra"
  "android_MedNow"
  "android_MeraShahar"
  "android_PhoneGuardian"
  "android_poshan-tracker"
  "android_QuotelyAI"
  "android_RainbowMind"
  "android_RentCred"
  "android_RentRamp"
  "android_safar-saathi"
  "android_SafeCalc"
  "android_sarkar-seva"
  "android_seekho-kamao"
  "android_ShadiConnect"
  "android_swasthya-sahayak"
  "android_TrainSathi"
  "android_village-job-board"
)

count=1
total=${#repos[@]}
success=0
failed=0
already_enabled=0

for repo in "${repos[@]}"; do
  echo "[$count/$total] Configuring Pages for $repo..."

  # Try main branch first
  result=$(echo '{"source":{"branch":"main","path":"/docs"}}' | gh api -X POST repos/akaash-nigam/$repo/pages -H "Accept: application/vnd.github+json" --input - 2>&1)

  if echo "$result" | grep -q "html_url"; then
    url=$(echo "$result" | grep -o 'https://akaash-nigam.github.io/[^"]*')
    echo "  ✓ Success: $url"
    success=$((success + 1))
  elif echo "$result" | grep -q "already enabled"; then
    echo "  ℹ Already enabled"
    already_enabled=$((already_enabled + 1))
  else
    # Try master branch if main fails
    result2=$(echo '{"source":{"branch":"master","path":"/docs"}}' | gh api -X POST repos/akaash-nigam/$repo/pages -H "Accept: application/vnd.github+json" --input - 2>&1)
    if echo "$result2" | grep -q "html_url"; then
      url=$(echo "$result2" | grep -o 'https://akaash-nigam.github.io/[^"]*')
      echo "  ✓ Success (master): $url"
      success=$((success + 1))
    else
      echo "  ✗ Failed"
      failed=$((failed + 1))
    fi
  fi

  count=$((count + 1))
  sleep 1
done

echo ""
echo "=========================================="
echo "GitHub Pages Configuration Complete!"
echo "  Newly enabled: $success"
echo "  Already enabled: $already_enabled"
echo "  Failed: $failed"
echo "  Total configured: $((success + already_enabled))"
echo "=========================================="
echo ""
echo "All landing pages will be available at:"
echo "  https://akaash-nigam.github.io/[REPO_NAME]/"
