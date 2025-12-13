#!/bin/bash

# Test remaining Android projects
cd /Users/aakashnigam/Axion/AxionApps/android

projects=(
  "android_poshan-tracker"
  "android_safar-saathi"
  "android_sarkar-seva"
  "android_seekho-kamao"
  "android_swasthya-sahayak"
  "android_village-job-board"
)

echo "=== Android Build Test Report ===" > test_results.txt
echo "" >> test_results.txt

for project in "${projects[@]}"; do
  echo "Testing $project..."
  echo "=== $project ===" >> test_results.txt

  if [ -d "$project" ]; then
    cd "$project"
    ./gradlew assembleDebug --no-daemon > /tmp/build_output.txt 2>&1

    if [ $? -eq 0 ]; then
      echo "✅ BUILD SUCCESSFUL" >> ../test_results.txt
    else
      echo "❌ BUILD FAILED" >> ../test_results.txt
      echo "Error summary:" >> ../test_results.txt
      grep -E "^e:|error:|FAILURE:" /tmp/build_output.txt | head -10 >> ../test_results.txt
    fi
    echo "" >> ../test_results.txt
    cd ..
  else
    echo "❌ Directory not found" >> test_results.txt
    echo "" >> test_results.txt
  fi
done

echo "Test complete. Results saved to test_results.txt"
cat test_results.txt
