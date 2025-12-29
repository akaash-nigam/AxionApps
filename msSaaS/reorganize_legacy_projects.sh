#!/bin/bash

# msSaaS Portfolio Reorganization Script
# This script reorganizes legacy projects into proper structure

set -e  # Exit on error

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

echo "=========================================="
echo "msSaaS Portfolio Reorganization"
echo "=========================================="
echo ""

# Function to create backup
create_backup() {
    BACKUP_DIR="backup_$(date +%Y%m%d_%H%M%S)"
    echo "Creating backup: $BACKUP_DIR"
    mkdir -p "../$BACKUP_DIR"
    echo "Backup directory created at: ../$BACKUP_DIR"
    echo ""
}

# Function to safely delete duplicates
delete_duplicates() {
    echo "=========================================="
    echo "Step 1: Deleting Duplicate Projects"
    echo "=========================================="

    # Check if duplicates exist and have msSaaS versions
    if [ -d "pdfvarta.in" ] && [ -d "msSAAS_pdfvarta.in" ]; then
        echo "✓ Found duplicate: pdfvarta.in (keeping msSAAS_pdfvarta.in)"
        mv pdfvarta.in "../$BACKUP_DIR/"
        echo "  → Moved to backup"
    else
        echo "⚠ pdfvarta.in not found or msSAAS version missing"
    fi

    if [ -d "ai-funding-tracker" ] && [ -d "msSaaS_ai-funding-tracker" ]; then
        echo "✓ Found duplicate: ai-funding-tracker (keeping msSaaS_ai-funding-tracker)"
        mv ai-funding-tracker "../$BACKUP_DIR/"
        echo "  → Moved to backup"
    else
        echo "⚠ ai-funding-tracker not found or msSaaS version missing"
    fi

    echo "✅ Duplicates handled"
    echo ""
}

# Function to rebrand projects to msSaaS_ naming
rebrand_projects() {
    echo "=========================================="
    echo "Step 2: Rebranding Projects to msSaaS_"
    echo "=========================================="

    # Rebrand each project individually
    if [ -d "AISpendTracker" ]; then
        echo "✓ Renaming: AISpendTracker → msSaaS_aispendtracker.com"
        mv "AISpendTracker" "msSaaS_aispendtracker.com"
    else
        echo "⚠ AISpendTracker not found, skipping"
    fi

    if [ -d "LoonieNavigator" ]; then
        echo "✓ Renaming: LoonieNavigator → msSaaS_loonienavigator.ca"
        mv "LoonieNavigator" "msSaaS_loonienavigator.ca"
    else
        echo "⚠ LoonieNavigator not found, skipping"
    fi

    if [ -d "MandirLocator" ]; then
        echo "✓ Renaming: MandirLocator → msSaaS_mandirlocator.in"
        mv "MandirLocator" "msSaaS_mandirlocator.in"
    else
        echo "⚠ MandirLocator not found, skipping"
    fi

    if [ -d "PropVideoAI" ]; then
        echo "✓ Renaming: PropVideoAI → msSaaS_propvideoai.com"
        mv "PropVideoAI" "msSaaS_propvideoai.com"
    else
        echo "⚠ PropVideoAI not found, skipping"
    fi

    if [ -d "SmartCondo-1" ]; then
        echo "✓ Renaming: SmartCondo-1 → msSaaS_smartcondo.ca"
        mv "SmartCondo-1" "msSaaS_smartcondo.ca"
    else
        echo "⚠ SmartCondo-1 not found, skipping"
    fi

    echo "✅ Rebranding complete"
    echo ""
}

# Function to create infrastructure directories
create_infrastructure() {
    echo "=========================================="
    echo "Step 3: Creating Infrastructure Folders"
    echo "=========================================="

    mkdir -p infrastructure/branding
    mkdir -p infrastructure/stripe
    mkdir -p infrastructure/terraform
    mkdir -p infrastructure/templates
    mkdir -p planning
    mkdir -p personal
    mkdir -p categories/canadian
    mkdir -p categories/gaming

    echo "✅ Infrastructure directories created"
    echo ""
}

# Function to move infrastructure projects
move_infrastructure() {
    echo "=========================================="
    echo "Step 4: Moving Infrastructure Projects"
    echo "=========================================="

    # Move branding
    if [ -d "BusinessBrands" ]; then
        echo "✓ Moving BusinessBrands → infrastructure/branding/"
        mv BusinessBrands infrastructure/branding/
    fi

    # Move Canadian resources
    if [ -d "CanadainTech" ]; then
        echo "✓ Moving CanadainTech → categories/canadian/"
        mv CanadainTech categories/canadian/
    fi

    # Move gaming apps
    if [ -d "gaming-apps" ]; then
        echo "✓ Moving gaming-apps → categories/gaming/"
        mv gaming-apps categories/gaming/
    fi

    # Move planning
    if [ -d "webapp_backlog" ]; then
        echo "✓ Moving webapp_backlog → planning/"
        mv webapp_backlog planning/
    fi

    echo "✅ Infrastructure moves complete"
    echo ""
}

# Function to move personal projects
move_personal() {
    echo "=========================================="
    echo "Step 5: Moving Personal Projects"
    echo "=========================================="

    if [ -d "personal_aakashnigam" ]; then
        echo "✓ Moving personal_aakashnigam → personal/"
        mv personal_aakashnigam personal/
    fi

    # Keep LinkHub for review
    if [ -d "LinkHub" ]; then
        echo "ℹ LinkHub kept in root for manual review"
    fi

    echo "✅ Personal projects moved"
    echo ""
}

# Function to consolidate stripe files
consolidate_stripe() {
    echo "=========================================="
    echo "Step 6: Consolidating Stripe Files"
    echo "=========================================="

    mkdir -p infrastructure/stripe/scripts
    mkdir -p infrastructure/stripe/price-ids
    mkdir -p infrastructure/stripe/documentation

    # Move scripts
    [ -f "create-adcreatorpro-products.sh" ] && mv create-adcreatorpro-products.sh infrastructure/stripe/scripts/
    [ -f "create-all-saas-products.sh" ] && mv create-all-saas-products.sh infrastructure/stripe/scripts/
    [ -f "create-remaining-products.sh" ] && mv create-remaining-products.sh infrastructure/stripe/scripts/
    [ -f "create-stripe-products.py" ] && mv create-stripe-products.py infrastructure/stripe/scripts/
    [ -f "stripe-products-setup.sh" ] && mv stripe-products-setup.sh infrastructure/stripe/scripts/

    # Move price IDs
    [ -f "adcreatorpro-price-ids.txt" ] && mv adcreatorpro-price-ids.txt infrastructure/stripe/price-ids/
    [ -f "all-saas-price-ids.txt" ] && mv all-saas-price-ids.txt infrastructure/stripe/price-ids/

    # Move documentation
    [ -f "STRIPE_IMPLEMENTATION_COMPLETE.md" ] && mv STRIPE_IMPLEMENTATION_COMPLETE.md infrastructure/stripe/documentation/
    [ -f "STRIPE_IMPLEMENTATION_STATUS.md" ] && mv STRIPE_IMPLEMENTATION_STATUS.md infrastructure/stripe/documentation/
    [ -f "STRIPE_INTEGRATION_GUIDE.md" ] && mv STRIPE_INTEGRATION_GUIDE.md infrastructure/stripe/documentation/
    [ -f "STRIPE_PRODUCTS_MASTER_LIST.md" ] && mv STRIPE_PRODUCTS_MASTER_LIST.md infrastructure/stripe/documentation/
    [ -f "STRIPE_SETUP_INSTRUCTIONS.md" ] && mv STRIPE_SETUP_INSTRUCTIONS.md infrastructure/stripe/documentation/
    [ -f "STRIPE_TESTING_GUIDE.md" ] && mv STRIPE_TESTING_GUIDE.md infrastructure/stripe/documentation/

    echo "✅ Stripe files consolidated"
    echo ""
}

# Function to move templates and terraform
move_templates_terraform() {
    echo "=========================================="
    echo "Step 7: Moving Templates and Terraform"
    echo "=========================================="

    if [ -d "TEMPLATES" ]; then
        echo "✓ Moving TEMPLATES → infrastructure/templates/"
        mv TEMPLATES infrastructure/templates/source
    fi

    if [ -d "terraform" ]; then
        echo "✓ Moving terraform → infrastructure/terraform/"
        mv terraform infrastructure/terraform/configs
    fi

    echo "✅ Templates and terraform moved"
    echo ""
}

# Function to create documentation index
create_documentation() {
    echo "=========================================="
    echo "Step 8: Creating Documentation"
    echo "=========================================="

    mkdir -p documentation

    # Move status reports to documentation
    [ -f "DEPLOYMENT_STATUS_REPORT.md" ] && mv DEPLOYMENT_STATUS_REPORT.md documentation/
    [ -f "ENV_FILES_UPDATED.md" ] && mv ENV_FILES_UPDATED.md documentation/
    [ -f "PROGRESS_SO_FAR.txt" ] && mv PROGRESS_SO_FAR.txt documentation/

    # Keep LEGACY_PROJECTS_ANALYSIS.md in root for now
    echo "ℹ LEGACY_PROJECTS_ANALYSIS.md kept in root"

    echo "✅ Documentation organized"
    echo ""
}

# Main execution
main() {
    echo "Starting reorganization at: $(date)"
    echo ""

    # Create backup first
    create_backup

    # Execute reorganization steps
    delete_duplicates
    rebrand_projects
    create_infrastructure
    move_infrastructure
    move_personal
    consolidate_stripe
    move_templates_terraform
    create_documentation

    echo "=========================================="
    echo "✅ REORGANIZATION COMPLETE"
    echo "=========================================="
    echo ""
    echo "Summary:"
    echo "- Backup created at: ../$BACKUP_DIR"
    echo "- Duplicates moved to backup"
    echo "- 5 projects rebranded to msSaaS_ naming"
    echo "- Infrastructure organized"
    echo "- Stripe files consolidated"
    echo "- Documentation organized"
    echo ""
    echo "Next steps:"
    echo "1. Review LinkHub (kept in root)"
    echo "2. Standardize msSaaS vs msSAAS naming"
    echo "3. Update .gitignore if needed"
    echo ""
}

# Run main function
main
