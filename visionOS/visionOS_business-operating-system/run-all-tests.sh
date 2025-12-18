#!/bin/bash

echo "╔════════════════════════════════════════════════════════════╗"
echo "║   Business Operating System - Current Environment Tests   ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

# Track results
total_tests=0
passed_tests=0
failed_tests=0

run_test() {
    local test_name=$1
    local test_command=$2

    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Running: $test_name"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    ((total_tests++))

    if $test_command; then
        echo "✅ PASSED: $test_name"
        ((passed_tests++))
    else
        echo "❌ FAILED: $test_name"
        ((failed_tests++))
    fi

    echo ""
}

# Run tests
run_test "Documentation Validation" "bash tests/docs/validate_docs.sh"
run_test "Database Schema Validation" "python3 tests/database/validate_schema.py"

# Print summary
echo "╔════════════════════════════════════════════════════════════╗"
echo "║                      TEST SUMMARY                          ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""
echo "Total Tests:  $total_tests"
echo "Passed:       $passed_tests ✅"
echo "Failed:       $failed_tests ❌"
echo ""

if [ $failed_tests -eq 0 ]; then
    echo "🎉 All tests passed!"
    exit 0
else
    echo "⚠️  Some tests failed. Please review the output above."
    exit 1
fi
