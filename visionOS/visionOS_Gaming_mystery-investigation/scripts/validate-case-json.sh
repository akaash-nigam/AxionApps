#!/bin/bash

# Mystery Investigation - Case JSON Validator
# Validates case JSON files against the schema

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "🔍 Mystery Investigation - Case JSON Validator"
echo "=============================================="
echo ""

# Check if jq is installed
if ! command -v jq &> /dev/null; then
    echo -e "${YELLOW}Warning: jq is not installed. Installing jq is recommended for JSON validation.${NC}"
    echo "Install with: brew install jq"
    echo ""
fi

# Find all case JSON files
CASES_DIR="cases"

if [ ! -d "$CASES_DIR" ]; then
    echo -e "${RED}Error: cases/ directory not found${NC}"
    exit 1
fi

# Count files
TOTAL_CASES=$(find "$CASES_DIR" -name "*.json" -type f | wc -l | tr -d ' ')

if [ "$TOTAL_CASES" -eq 0 ]; then
    echo -e "${YELLOW}No case JSON files found in $CASES_DIR${NC}"
    exit 0
fi

echo "Found $TOTAL_CASES case file(s) to validate"
echo ""

VALID_COUNT=0
INVALID_COUNT=0

# Validate each case file
for case_file in "$CASES_DIR"/*.json; do
    if [ -f "$case_file" ]; then
        filename=$(basename "$case_file")
        echo "Validating: $filename"

        # Check if file is valid JSON
        if jq empty "$case_file" 2>/dev/null; then
            echo -e "  ${GREEN}✓${NC} Valid JSON syntax"

            # Check required fields
            has_id=$(jq -e '.id' "$case_file" > /dev/null 2>&1 && echo "yes" || echo "no")
            has_title=$(jq -e '.title' "$case_file" > /dev/null 2>&1 && echo "yes" || echo "no")
            has_difficulty=$(jq -e '.difficulty' "$case_file" > /dev/null 2>&1 && echo "yes" || echo "no")
            has_suspects=$(jq -e '.suspects' "$case_file" > /dev/null 2>&1 && echo "yes" || echo "no")
            has_evidence=$(jq -e '.evidence' "$case_file" > /dev/null 2>&1 && echo "yes" || echo "no")
            has_solution=$(jq -e '.solution' "$case_file" > /dev/null 2>&1 && echo "yes" || echo "no")

            if [ "$has_id" == "yes" ] && [ "$has_title" == "yes" ] && \
               [ "$has_difficulty" == "yes" ] && [ "$has_suspects" == "yes" ] && \
               [ "$has_evidence" == "yes" ] && [ "$has_solution" == "yes" ]; then
                echo -e "  ${GREEN}✓${NC} All required fields present"

                # Get counts
                suspect_count=$(jq '.suspects | length' "$case_file")
                evidence_count=$(jq '.evidence | length' "$case_file")

                echo -e "  ${GREEN}✓${NC} Suspects: $suspect_count"
                echo -e "  ${GREEN}✓${NC} Evidence: $evidence_count"

                VALID_COUNT=$((VALID_COUNT + 1))
            else
                echo -e "  ${RED}✗${NC} Missing required fields:"
                [ "$has_id" == "no" ] && echo "    - id"
                [ "$has_title" == "no" ] && echo "    - title"
                [ "$has_difficulty" == "no" ] && echo "    - difficulty"
                [ "$has_suspects" == "no" ] && echo "    - suspects"
                [ "$has_evidence" == "no" ] && echo "    - evidence"
                [ "$has_solution" == "no" ] && echo "    - solution"
                INVALID_COUNT=$((INVALID_COUNT + 1))
            fi
        else
            echo -e "  ${RED}✗${NC} Invalid JSON syntax"
            INVALID_COUNT=$((INVALID_COUNT + 1))
        fi
        echo ""
    fi
done

# Summary
echo "=============================================="
echo "Validation Summary:"
echo -e "  ${GREEN}Valid:${NC}   $VALID_COUNT"
echo -e "  ${RED}Invalid:${NC} $INVALID_COUNT"
echo -e "  Total:   $TOTAL_CASES"
echo ""

if [ "$INVALID_COUNT" -gt 0 ]; then
    echo -e "${RED}❌ Validation failed${NC}"
    exit 1
else
    echo -e "${GREEN}✅ All case files valid!${NC}"
    exit 0
fi
