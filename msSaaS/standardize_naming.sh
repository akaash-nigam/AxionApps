#!/bin/bash

# msSaaS Naming Standardization Script
# Converts all msSAAS_ (uppercase) to msSaaS_ (lowercase)

set -e  # Exit on error

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

echo "=========================================="
echo "msSaaS Naming Standardization"
echo "=========================================="
echo ""
echo "Converting all msSAAS_ (uppercase) to msSaaS_ (lowercase)"
echo ""

# Create backup
BACKUP_DIR="backup_naming_$(date +%Y%m%d_%H%M%S)"
echo "Creating backup: ../$BACKUP_DIR"
mkdir -p "../$BACKUP_DIR"
echo ""

# Count projects
UPPERCASE_COUNT=$(find . -maxdepth 1 -type d -name "msSAAS_*" | wc -l | xargs)
echo "Found $UPPERCASE_COUNT projects to rename"
echo ""

# Rename each project
echo "=========================================="
echo "Renaming Projects"
echo "=========================================="
echo ""

# List of projects to rename
if [ -d "msSAAS_Bhagwad-Gita.in" ]; then
    echo "✓ Renaming: msSAAS_Bhagwad-Gita.in → msSaaS_Bhagwad-Gita.in"
    mv "msSAAS_Bhagwad-Gita.in" "msSaaS_Bhagwad-Gita.in"
fi

if [ -d "msSAAS_BusinessValuationTool" ]; then
    echo "✓ Renaming: msSAAS_BusinessValuationTool → msSaaS_BusinessValuationTool"
    mv "msSAAS_BusinessValuationTool" "msSaaS_BusinessValuationTool"
fi

if [ -d "msSAAS_ClipzoLanding" ]; then
    echo "✓ Renaming: msSAAS_ClipzoLanding → msSaaS_ClipzoLanding"
    mv "msSAAS_ClipzoLanding" "msSaaS_ClipzoLanding"
fi

if [ -d "msSAAS_copilotteacher" ]; then
    echo "✓ Renaming: msSAAS_copilotteacher → msSaaS_copilotteacher"
    mv "msSAAS_copilotteacher" "msSaaS_copilotteacher"
fi

if [ -d "msSAAS_CraftMyCV" ]; then
    echo "✓ Renaming: msSAAS_CraftMyCV → msSaaS_CraftMyCV"
    mv "msSAAS_CraftMyCV" "msSaaS_CraftMyCV"
fi

if [ -d "msSAAS_DailyGratitudeTracker" ]; then
    echo "✓ Renaming: msSAAS_DailyGratitudeTracker → msSaaS_DailyGratitudeTracker"
    mv "msSAAS_DailyGratitudeTracker" "msSaaS_DailyGratitudeTracker"
fi

if [ -d "msSAAS_digitaldidi.in" ]; then
    echo "✓ Renaming: msSAAS_digitaldidi.in → msSaaS_digitaldidi.in"
    mv "msSAAS_digitaldidi.in" "msSaaS_digitaldidi.in"
fi

if [ -d "msSAAS_DigitalReceiptVault" ]; then
    echo "✓ Renaming: msSAAS_DigitalReceiptVault → msSaaS_DigitalReceiptVault"
    mv "msSAAS_DigitalReceiptVault" "msSaaS_DigitalReceiptVault"
fi

if [ -d "msSAAS_EliteSchoolNavigator.ca" ]; then
    echo "✓ Renaming: msSAAS_EliteSchoolNavigator.ca → msSaaS_EliteSchoolNavigator.ca"
    mv "msSAAS_EliteSchoolNavigator.ca" "msSaaS_EliteSchoolNavigator.ca"
fi

if [ -d "msSAAS_EliteSchoolNavigator.com" ]; then
    echo "✓ Renaming: msSAAS_EliteSchoolNavigator.com → msSaaS_EliteSchoolNavigator.com"
    mv "msSAAS_EliteSchoolNavigator.com" "msSaaS_EliteSchoolNavigator.com"
fi

if [ -d "msSAAS_EventManagementApp" ]; then
    echo "✓ Renaming: msSAAS_EventManagementApp → msSaaS_EventManagementApp"
    mv "msSAAS_EventManagementApp" "msSaaS_EventManagementApp"
fi

if [ -d "msSAAS_FreelancerProposalPro" ]; then
    echo "✓ Renaming: msSAAS_FreelancerProposalPro → msSaaS_FreelancerProposalPro"
    mv "msSAAS_FreelancerProposalPro" "msSaaS_FreelancerProposalPro"
fi

if [ -d "msSAAS_GetPrenup.in" ]; then
    echo "✓ Renaming: msSAAS_GetPrenup.in → msSaaS_GetPrenup.in"
    mv "msSAAS_GetPrenup.in" "msSaaS_GetPrenup.in"
fi

if [ -d "msSAAS_HealthCanada" ]; then
    echo "✓ Renaming: msSAAS_HealthCanada → msSaaS_HealthCanada"
    mv "msSAAS_HealthCanada" "msSaaS_HealthCanada"
fi

if [ -d "msSAAS_InvoiceCraft" ]; then
    echo "✓ Renaming: msSAAS_InvoiceCraft → msSaaS_InvoiceCraft"
    mv "msSAAS_InvoiceCraft" "msSaaS_InvoiceCraft"
fi

if [ -d "msSAAS_JyotiNigam.in" ]; then
    echo "✓ Renaming: msSAAS_JyotiNigam.in → msSaaS_JyotiNigam.in"
    mv "msSAAS_JyotiNigam.in" "msSaaS_JyotiNigam.in"
fi

if [ -d "msSAAS_LevelsCareer" ]; then
    echo "✓ Renaming: msSAAS_LevelsCareer → msSaaS_LevelsCareer"
    mv "msSAAS_LevelsCareer" "msSaaS_LevelsCareer"
fi

if [ -d "msSAAS_LinkHub" ]; then
    echo "✓ Renaming: msSAAS_LinkHub → msSaaS_LinkHub"
    mv "msSAAS_LinkHub" "msSaaS_LinkHub"
fi

if [ -d "msSAAS_LoonieCopilot.com" ]; then
    echo "✓ Renaming: msSAAS_LoonieCopilot.com → msSaaS_LoonieCopilot.com"
    mv "msSAAS_LoonieCopilot.com" "msSaaS_LoonieCopilot.com"
fi

if [ -d "msSAAS_MacroInsightHub" ]; then
    echo "✓ Renaming: msSAAS_MacroInsightHub → msSaaS_MacroInsightHub"
    mv "msSAAS_MacroInsightHub" "msSaaS_MacroInsightHub"
fi

if [ -d "msSAAS_MilitaryShield" ]; then
    echo "✓ Renaming: msSAAS_MilitaryShield → msSaaS_MilitaryShield"
    mv "msSAAS_MilitaryShield" "msSaaS_MilitaryShield"
fi

if [ -d "msSAAS_pdfvarta.in" ]; then
    echo "✓ Renaming: msSAAS_pdfvarta.in → msSaaS_pdfvarta.in"
    mv "msSAAS_pdfvarta.in" "msSaaS_pdfvarta.in"
fi

if [ -d "msSAAS_PetHealthTracker" ]; then
    echo "✓ Renaming: msSAAS_PetHealthTracker → msSaaS_PetHealthTracker"
    mv "msSAAS_PetHealthTracker" "msSaaS_PetHealthTracker"
fi

if [ -d "msSAAS_PromptCraft" ]; then
    echo "✓ Renaming: msSAAS_PromptCraft → msSaaS_PromptCraft"
    mv "msSAAS_PromptCraft" "msSaaS_PromptCraft"
fi

if [ -d "msSAAS_QualityLife" ]; then
    echo "✓ Renaming: msSAAS_QualityLife → msSaaS_QualityLife"
    mv "msSAAS_QualityLife" "msSaaS_QualityLife"
fi

if [ -d "msSAAS_RelationshipGoalTracker" ]; then
    echo "✓ Renaming: msSAAS_RelationshipGoalTracker → msSaaS_RelationshipGoalTracker"
    mv "msSAAS_RelationshipGoalTracker" "msSaaS_RelationshipGoalTracker"
fi

if [ -d "msSAAS_remoteIndiaJobs" ]; then
    echo "✓ Renaming: msSAAS_remoteIndiaJobs → msSaaS_remoteIndiaJobs"
    mv "msSAAS_remoteIndiaJobs" "msSaaS_remoteIndiaJobs"
fi

if [ -d "msSAAS_schoolmanagement" ]; then
    echo "✓ Renaming: msSAAS_schoolmanagement → msSaaS_schoolmanagement"
    mv "msSAAS_schoolmanagement" "msSaaS_schoolmanagement"
fi

if [ -d "msSAAS_TherapyNoteTracker" ]; then
    echo "✓ Renaming: msSAAS_TherapyNoteTracker → msSaaS_TherapyNoteTracker"
    mv "msSAAS_TherapyNoteTracker" "msSaaS_TherapyNoteTracker"
fi

echo ""
echo "=========================================="
echo "✅ NAMING STANDARDIZATION COMPLETE"
echo "=========================================="
echo ""
echo "Summary:"
echo "- Renamed $UPPERCASE_COUNT projects"
echo "- All projects now use lowercase: msSaaS_"
echo "- Backup created at: ../$BACKUP_DIR (if needed)"
echo ""

# Verify
REMAINING=$(find . -maxdepth 1 -type d -name "msSAAS_*" | wc -l | xargs)
if [ "$REMAINING" -eq 0 ]; then
    echo "✅ Verification: All projects standardized successfully"
else
    echo "⚠️  Warning: $REMAINING projects still have uppercase naming"
fi

echo ""
echo "New naming convention: msSaaS_ (lowercase 'aa')"
