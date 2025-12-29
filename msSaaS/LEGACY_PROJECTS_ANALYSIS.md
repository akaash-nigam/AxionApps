# Legacy Projects Analysis

## Overview
These are non-msSaaS prefixed projects that should be tagged/categorized differently from active SaaS products.

## Legacy/Standalone Projects (13 total)

### 1. **AISpendTracker** 
- Type: Node.js/Web App
- Last Modified: 2025-12-12
- Status: Appears to be an older SaaS project
- **Recommendation**: Could be rebranded as `msSaaS_aispendtracker.com` OR moved to legacy

### 2. **BusinessBrands**
- Type: Resource/Asset folder
- Last Modified: 2025-12-19
- **Recommendation**: Move to `/infrastructure/branding/` or `/assets/`

### 3. **CanadainTech**
- Type: Resource/Category folder
- Last Modified: 2025-12-19
- **Recommendation**: Merge with Canadian-focused msSaaS apps or move to `/categories/canadian/`

### 4. **LinkHub**
- Type: Development/Testing
- Last Modified: 2025-12-18
- Has CLAUDE.md and SESSION_SUMMARY.md
- **Recommendation**: Archive or integrate into `msSAAS_LinkHub`

### 5. **LoonieNavigator**
- Type: Node.js/Web App (Canadian focus)
- Last Modified: 2025-12-22
- Has full stack setup (client/server)
- **Recommendation**: Rebrand as `msSaaS_loonienavigator.ca` OR consolidate with `msSAAS_LoonieCopilot.com`

### 6. **MandirLocator**
- Type: Node.js/Web App (Indian religious app)
- Last Modified: 2025-12-17
- **Recommendation**: Rebrand as `msSaaS_mandirlocator.in`

### 7. **PropVideoAI**
- Type: Node.js/Web App (Real estate video AI)
- Last Modified: 2025-10-12 (OLDEST - likely inactive)
- **Recommendation**: Archive or rebrand as `msSaaS_propvideoai.com`

### 8. **SmartCondo-1**
- Type: Node.js/Web App (Real estate/property management)
- Last Modified: 2025-12-15
- **Recommendation**: Rebrand as `msSaaS_smartcondo.ca`

### 9. **pdfvarta.in**
- Type: PDF-related app (Indian market)
- Last Modified: 2025-11-04
- **Note**: Already has `msSAAS_pdfvarta.in` - appears to be DUPLICATE
- **Recommendation**: **DELETE** this one, keep the msSAAS_ version

### 10. **personal_aakashnigam**
- Type: Personal Website (aakashnigam.com)
- Last Modified: 2025-12-13
- **Recommendation**: Move to `/personal/` or keep separate - NOT a SaaS product

### 11. **gaming-apps**
- Type: Gaming projects folder
- Last Modified: 2025-10-05 (OLD)
- **Recommendation**: Move to `/categories/gaming/` or `/legacy/gaming-apps/`

### 12. **webapp_backlog**
- Type: Ideas/Planning folder
- Last Modified: 2025-12-22
- **Recommendation**: Move to `/planning/webapp-backlog/` or `/ideas/`

### 13. **ai-funding-tracker**
- Type: Tracking/Resource app
- Last Modified: 2025-12-21
- **Note**: Already has `msSaaS_ai-funding-tracker` - appears to be DUPLICATE
- **Recommendation**: **DELETE** this one, keep the msSaaS_ version

---

## Action Items Summary

### DELETE (Duplicates) - 2 items
- `pdfvarta.in` → Keep `msSAAS_pdfvarta.in`
- `ai-funding-tracker` → Keep `msSaaS_ai-funding-tracker`

### REBRAND to msSaaS_ - 5 items
- `AISpendTracker` → `msSaaS_aispendtracker.com`
- `LoonieNavigator` → `msSaaS_loonienavigator.ca` (or merge with LoonieCopilot)
- `MandirLocator` → `msSaaS_mandirlocator.in`
- `PropVideoAI` → `msSaaS_propvideoai.com` (or archive)
- `SmartCondo-1` → `msSaaS_smartcondo.ca`

### MOVE to Infrastructure - 4 items
- `BusinessBrands` → `/infrastructure/branding/`
- `CanadainTech` → `/categories/canadian/` or merge
- `gaming-apps` → `/legacy/gaming-apps/`
- `webapp_backlog` → `/planning/webapp-backlog/`

### KEEP SEPARATE - 2 items
- `personal_aakashnigam` → `/personal/` (not a SaaS)
- `LinkHub` → Needs review (has active session docs)

---

## Tagged Structure Proposal

```
msSaaS/
├── active-saas/              # 61 standardized msSaaS_ projects
├── legacy-saas/              # Archived/inactive SaaS
│   └── PropVideoAI/          # If not rebranded
├── personal/
│   └── personal_aakashnigam/
├── infrastructure/
│   ├── branding/
│   │   └── BusinessBrands/
│   ├── stripe/
│   ├── terraform/
│   └── templates/
├── planning/
│   ├── webapp-backlog/
│   └── ideas/
└── categories/
    ├── canadian/
    │   └── CanadainTech/
    └── gaming/
        └── gaming-apps/
```
