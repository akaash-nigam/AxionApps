# Quick Reference: Systematic Codebase Analysis

One-page cheat sheet for analyzing large codebases

---

## The 4-Phase Method

```
1. DISCOVER (20%) → Find patterns
2. TEST (40%)     → Verify systematically
3. RECOGNIZE (30%) → Find hidden patterns
4. DOCUMENT (10%) → Make reusable
```

---

## Phase 1: Discover (1-2 hours)

### Count Everything
```bash
ls -d project_* | wc -l                    # Total projects
find . -name "*.swift" | wc -l             # Code files
find . -name "Package.swift" | wc -l       # Build configs
```

### Find Patterns
```bash
# Where are build configs?
find . -name "Package.swift" | head -10

# Root level?    ./project_001/Package.swift
# Subdirectory?  ./project_001/SubApp/Package.swift
```

### Quick Win: Test One
```bash
cd project_001
your_build_command
# Document what worked!
```

---

## Phase 2: Test (2-4 hours)

### Test by Pattern
```bash
# Pattern A: Root-level configs
for proj in project_*; do
    [ -f "$proj/Package.swift" ] && \
    cd "$proj" && \
    your_build_command && \
    echo "$proj: SUCCESS" || echo "$proj: FAILED"
done
```

### Count Errors
```bash
your_build_command 2>&1 | grep "error:" | wc -l
```

### Categorize
- **0 errors** → Building ✅
- **1-5 errors** → Easy fix ⚠️
- **6-20 errors** → Moderate ⚠️
- **>20 errors** → Complex ❌

---

## Phase 3: Recognize (2-3 hours)

### Check for Code
```bash
find project_name -name "*.swift" | wc -l
# 0 = Placeholder
# >0 = Has code
```

### Find Outliers
```bash
# Works but no expected config?
# Has config but doesn't work?
# Look closer at these!
```

### Common Patterns
```
Pattern 1: Root config        → Standard build
Pattern 2: Subdirectory config → CD first
Pattern 3: No code            → Placeholder
Pattern 4: Has errors         → Fixable
```

---

## Phase 4: Document (1 hour)

### Create Pattern Doc
```markdown
## Pattern 1: Root Config (25 projects)
Success: 20/25 (80%)
Command: `cd project && swift build`
Errors: Missing deps, platform mismatch
```

### Track Progress
```bash
echo "$(date),$(success_count),$(total)" >> progress.csv
```

---

## Quick Commands

### Discovery
```bash
# Find all build configs
find . -name "Package.swift" -o -name "pom.xml" -o -name "package.json"

# Find nested configs
find . -path "*/*/Package.swift"

# Count by type
find . -name "*.swift" | wc -l
find . -name "*.java" | wc -l
```

### Testing
```bash
# Test and log
your_build_command &> build.log

# Check result
grep "SUCCESS" build.log && echo "✅" || echo "❌"

# Count errors
grep -c "error:" build.log
```

### Analysis
```bash
# Projects without code
find project_* -name "*.swift" -exec dirname {} \; | sort -u | wc -l

# Success rate
success=$(grep -l SUCCESS build_*.log | wc -l)
total=$(ls -d project_* | wc -l)
echo "$(( success * 100 / total ))%"
```

---

## Decision Tree

```
Has build config?
├─ YES → At root level?
│        ├─ YES → Build normally
│        └─ NO → CD to subdirectory first
│
└─ NO → Has code files?
         ├─ YES → Need to add config
         └─ NO → Placeholder, skip
```

---

## Error Quick Reference

| Error Count | Category | Time to Fix | Action |
|-------------|----------|-------------|--------|
| 0 | Building | 0 | ✅ Done |
| 1-5 | Easy | 1-2 hrs | Fix now |
| 6-20 | Moderate | 2-4 hrs | Plan fix |
| 21-50 | Complex | 8+ hrs | Defer |
| >50 | Incomplete | N/A | Skip |

---

## Common Patterns by Language

### Swift/iOS
```bash
xcodebuild -scheme Name -sdk iphoneos build
```

### Java/Maven
```bash
mvn clean install
```

### JavaScript/Node
```bash
npm install && npm build
```

### Python
```bash
pip install -r requirements.txt && pytest
```

### Rust
```bash
cargo build && cargo test
```

---

## Automation Scripts

### Parallel Test
```bash
for proj in project_*; do
    (cd "$proj" && your_build_command) &
done
wait
```

### Progress Tracker
```bash
success=$(find . -name "build.log" -exec grep -l SUCCESS {} \; | wc -l)
echo "Progress: $success/78 ($(( success * 100 / 78 ))%)"
```

### Report Generator
```bash
echo "# Build Report" > report.md
echo "Success: $(grep -l SUCCESS build_*.log | wc -l)" >> report.md
echo "Failed: $(grep -l FAILED build_*.log | wc -l)" >> report.md
```

---

## Success Metrics

### After 1 Hour:
- ✅ Inventory complete
- ✅ 1+ pattern found
- ✅ 5-10 projects tested

### After 4 Hours:
- ✅ All patterns documented
- ✅ 50%+ projects tested
- ✅ Categories defined

### After 8 Hours:
- ✅ 100% tested
- ✅ Automation in place
- ✅ Clear roadmap

---

## Key Principles

1. **Start Small** → One success builds confidence
2. **Pattern First** → Don't test randomly
3. **Document Immediately** → Memory fades fast
4. **Measure Progress** → Track success rate
5. **Automate Repetition** → Scripts save time
6. **Share Knowledge** → Team benefits

---

## Red Flags

🚩 Testing randomly instead of systematically
🚩 Not documenting patterns
🚩 Trying to fix everything at once
🚩 Ignoring outliers
🚩 No progress tracking
🚩 Working in isolation

---

## When It's Working

✅ Success rate increasing
✅ Patterns emerging
✅ Time per project decreasing
✅ Team understanding growing
✅ Estimates becoming accurate
✅ Automation reducing effort

---

## Quick Win Checklist

- [ ] Count all projects
- [ ] Find one working example
- [ ] Document the command
- [ ] Test 5 similar projects
- [ ] Calculate success rate
- [ ] Extrapolate to full set
- [ ] Create first script
- [ ] Share findings

---

## Resources

**Full Guides**:
- `PROJECT_METHODOLOGY.md` - Complete methodology
- `PRACTICAL_GUIDE.md` - Step-by-step guide
- `QUICK_REFERENCE.md` - This document

**Results**:
- `final_status_report.txt` - Final results
- `final_comprehensive_report.txt` - Technical details

---

## One-Liner Summaries

**Discovery**: `find . -name "build_config" | wc -l`
**Testing**: `for p in *; do cd $p && build; done`
**Analysis**: `grep -c "error:" build.log`
**Progress**: `echo "$success/$total ($(( success*100/total ))%)"`

---

**Keep This Handy**: Bookmark this page for quick reference during analysis

**Version**: 1.0 | **Date**: 2025-12-10 | **Status**: Field-tested ✅
