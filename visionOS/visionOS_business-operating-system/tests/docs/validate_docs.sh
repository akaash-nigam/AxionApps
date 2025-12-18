#!/bin/bash
set -e

echo "=== Documentation Validation ==="

# Required documentation files
required_docs=(
    "README.md"
    "IMPLEMENTATION_PLAN.md"
    "FEATURE_COMPLETION_ANALYSIS.md"
    "ADDITIONAL_DELIVERABLES_GUIDE.md"
    "api-specification.yaml"
    "database-schema.sql"
    "DATABASE_ERD.md"
    "WEBSOCKET_PROTOCOL.md"
    "TODO_VISIONOS_ENV.md"
    "TESTING_IN_CURRENT_ENV.md"
)

echo "Checking for required documentation files..."
echo ""

missing_count=0
for doc in "${required_docs[@]}"; do
    if [ -f "$doc" ]; then
        # Get file size
        size=$(wc -c < "$doc")
        lines=$(wc -l < "$doc")
        echo "✓ $doc ($(($size / 1024))KB, $lines lines)"
    else
        echo "✗ Missing: $doc"
        ((missing_count++))
    fi
done

echo ""
echo "=================================================="
echo "Documentation files: $((${#required_docs[@]} - $missing_count))/${#required_docs[@]}"

if [ $missing_count -eq 0 ]; then
    echo "✅ All documentation present!"
    exit 0
else
    echo "⚠️  $missing_count files missing"
    exit 1
fi
