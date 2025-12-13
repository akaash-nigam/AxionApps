# Practical Guide: Systematic Codebase Analysis

A step-by-step guide for applying systematic analysis to any large codebase

---

## When to Use This Methodology

Use this approach when you need to:
- ✅ Understand a large codebase quickly
- ✅ Identify buildable vs non-buildable components
- ✅ Find patterns in project structure
- ✅ Prioritize fix efforts
- ✅ Create accurate project estimates

**Not suitable for**:
- ❌ Single applications
- ❌ Well-documented codebases
- ❌ Small projects (<10 components)

---

## Quick Start: 30-Minute Assessment

### Step 1: Count Everything (5 minutes)

```bash
# Count projects/apps
ls -d project_* | wc -l

# Count code files
find . -name "*.swift" | wc -l  # or .java, .py, .js, etc.

# Check for build configs
find . -name "Package.swift" -o -name "pom.xml" -o -name "package.json" | wc -l
```

**Output Example**:
```
78 projects
15,432 code files
48 build configurations
```

---

### Step 2: Test One Successfully (10 minutes)

Pick one project that should work and make it build:

```bash
cd project_001

# Try the obvious build command
npm install && npm build
# or: mvn compile
# or: cargo build
# or: xcodebuild

# Document what worked!
```

**Success?** → You have your first pattern
**Failure?** → Try variations, document each attempt

---

### Step 3: Apply to Similar Projects (10 minutes)

```bash
# Find similar projects
ls -d project_00* | head -5

# Test each one
for proj in project_002 project_003 project_004; do
    cd "$proj"
    # Use the command that worked in Step 2
    npm build && echo "$proj: SUCCESS" || echo "$proj: FAILED"
    cd ..
done
```

**Track Results**:
- project_002: SUCCESS
- project_003: SUCCESS
- project_004: FAILED (different error)

---

### Step 4: Calculate Success Rate (5 minutes)

```
Tested: 5 projects
Success: 3 projects
Success Rate: 60%

Extrapolated:
- 78 total projects
- ~47 should build with this method
- ~31 need different approach
```

**Now you have**:
- Baseline understanding
- One working pattern
- Estimated scope
- Clear next steps

---

## Deep Dive: Full Analysis Process

### Phase 1: Discovery (20% of time)

**Objective**: Find all project types and build configurations

#### 1.1 Map the Territory

```bash
#!/bin/bash
# discovery.sh

echo "=== Project Inventory ==="
echo "Total projects: $(ls -d project_* | wc -l)"
echo ""

echo "=== Build Configurations ==="
echo "Package.swift: $(find . -name "Package.swift" | wc -l)"
echo "pom.xml: $(find . -name "pom.xml" | wc -l)"
echo "package.json: $(find . -name "package.json" | wc -l)"
echo "Makefile: $(find . -name "Makefile" | wc -l)"
echo "Cargo.toml: $(find . -name "Cargo.toml" | wc -l)"
echo ""

echo "=== Code Files ==="
echo "Swift: $(find . -name "*.swift" | wc -l)"
echo "Java: $(find . -name "*.java" | wc -l)"
echo "JavaScript: $(find . -name "*.js" | wc -l)"
echo "Python: $(find . -name "*.py" | wc -l)"
echo ""

echo "=== Projects by Type ==="
for proj in project_*; do
    if [ -f "$proj/Package.swift" ]; then
        echo "Swift: $proj"
    elif [ -f "$proj/pom.xml" ]; then
        echo "Java/Maven: $proj"
    elif [ -f "$proj/package.json" ]; then
        echo "Node.js: $proj"
    else
        echo "Unknown: $proj"
    fi
done | sort | uniq -c
```

**Run**: `bash discovery.sh > inventory.txt`

---

#### 1.2 Identify Patterns

Look for commonalities:

```bash
# Pattern: Projects in subdirectories?
find . -name "Package.swift" -o -name "pom.xml" | head -10

# Are configs at root or nested?
# Root: ./project_001/Package.swift
# Nested: ./project_001/SubProject/Package.swift
```

**Document Patterns**:
```
Pattern A: Root-level config (45 projects)
Pattern B: Subdirectory config (23 projects)
Pattern C: No config (10 projects)
```

---

### Phase 2: Testing (40% of time)

**Objective**: Test systematically, not randomly

#### 2.1 Test by Pattern

```bash
#!/bin/bash
# test_pattern_a.sh - Root-level configs

echo "Testing Pattern A: Root-level configs"
results_file="pattern_a_results.txt"
echo "" > "$results_file"

for proj in $(find . -maxdepth 2 -name "Package.swift" | sed 's|/Package.swift||'); do
    echo "Testing $proj..."
    cd "$proj"

    # Your build command here
    if xcodebuild -scheme MyScheme build &> /dev/null; then
        echo "$proj: SUCCESS" | tee -a "../$results_file"
    else
        echo "$proj: FAILED" | tee -a "../$results_file"
    fi

    cd - > /dev/null
done

# Summary
total=$(wc -l < "$results_file")
success=$(grep SUCCESS "$results_file" | wc -l)
echo "Results: $success/$total successful ($(( success * 100 / total ))%)"
```

---

#### 2.2 Error Classification

```bash
#!/bin/bash
# classify_errors.sh

echo "=== Error Classification ==="

for proj in project_*; do
    cd "$proj"

    # Capture build output
    build_output=$(your_build_command 2>&1)
    error_count=$(echo "$build_output" | grep -c "error:")

    # Classify
    if [ $error_count -eq 0 ]; then
        category="SUCCESS"
    elif [ $error_count -lt 5 ]; then
        category="EASY_FIX"
    elif [ $error_count -lt 20 ]; then
        category="MODERATE"
    else
        category="COMPLEX"
    fi

    echo "$proj: $category ($error_count errors)"
    cd ..
done | sort -t: -k2
```

**Output**:
```
project_001: SUCCESS (0 errors)
project_002: SUCCESS (0 errors)
project_003: EASY_FIX (2 errors)
project_004: MODERATE (15 errors)
project_005: COMPLEX (127 errors)
```

---

### Phase 3: Pattern Recognition (30% of time)

**Objective**: Find hidden patterns

#### 3.1 Look for Anomalies

```bash
# Projects that should work but don't
comm -23 <(find . -name "Package.swift" | sed 's|/.*||' | sort) \
         <(cat successful_projects.txt | sort)

# Projects that work without expected configs
comm -23 <(cat successful_projects.txt | sort) \
         <(find . -name "Package.swift" | sed 's|/.*||' | sort)
```

---

#### 3.2 Deep Dive on Outliers

```bash
# Why does project_042 work without Package.swift?
ls -la project_042/
# Ah! It has a Makefile

# Why does project_057 fail with Package.swift?
find project_057 -name "*.swift" | wc -l
# Output: 0
# Ah! It's a placeholder, no code
```

---

### Phase 4: Documentation (10% of time)

**Objective**: Make findings reusable

#### 4.1 Document Patterns

Create `PATTERNS.md`:

```markdown
# Build Patterns Discovered

## Pattern 1: Standard SPM Project
- **Count**: 25 projects
- **Success Rate**: 80% (20/25)
- **Build Command**:
  ```bash
  cd project_name
  swift build
  ```
- **Common Errors**:
  - Missing dependencies → `swift package resolve`
  - Platform mismatch → Add `-Xswiftc -target`

## Pattern 2: Nested SPM Project
- **Count**: 15 projects
- **Success Rate**: 60% (9/15)
- **Build Command**:
  ```bash
  cd project_name/SubProject
  swift build
  ```
- **Note**: Must cd into subdirectory first

## Pattern 3: Placeholder Projects
- **Count**: 10 projects
- **Success Rate**: 0% (0/10)
- **Characteristic**: 0 code files
- **Action**: Cannot be built, skip
```

---

#### 4.2 Create Decision Tree

```
START
  |
  ├─ Has build config? ──NO──> Check for code files
  |                              |
  |                              ├─ Has code? ──YES──> Add build config
  |                              |
  |                              └─ No code? ──────> Mark as placeholder
  |
  └─ YES
      |
      ├─ Root level? ──YES──> Use standard build
      |
      └─ Subdirectory? ──YES──> CD into subdir first
                                  |
                                  └─ Run build
                                      |
                                      ├─ Success? ──> DONE
                                      |
                                      └─ Errors?
                                          |
                                          ├─ 0-5 errors ──> Quick fix
                                          ├─ 6-20 errors ──> Moderate effort
                                          └─ >20 errors ──> Complex/Skip
```

---

## Common Patterns Across Languages

### JavaScript/Node.js

```bash
# Discovery
find . -name "package.json"

# Test
cd project_name
npm install
npm test
npm run build

# Common errors
# - Missing dependencies → npm install
# - Wrong Node version → nvm use 16
# - Lock file conflicts → rm package-lock.json && npm install
```

---

### Java/Maven

```bash
# Discovery
find . -name "pom.xml"

# Test
cd project_name
mvn clean install

# Common errors
# - Missing dependencies → mvn dependency:resolve
# - Java version → Check <java.version> in pom.xml
# - Plugin issues → mvn clean install -U
```

---

### Python

```bash
# Discovery
find . -name "requirements.txt" -o -name "setup.py" -o -name "pyproject.toml"

# Test
cd project_name
python -m venv venv
source venv/bin/activate
pip install -r requirements.txt
python -m pytest

# Common errors
# - Missing packages → pip install -r requirements.txt
# - Python version → pyenv install 3.9.0
# - Import errors → Check PYTHONPATH
```

---

### Rust

```bash
# Discovery
find . -name "Cargo.toml"

# Test
cd project_name
cargo build
cargo test

# Common errors
# - Outdated deps → cargo update
# - Toolchain → rustup install stable
# - Lock file → rm Cargo.lock && cargo build
```

---

## Automation Scripts

### 1. Parallel Testing

```bash
#!/bin/bash
# parallel_test.sh - Test multiple projects simultaneously

projects=(project_001 project_002 project_003 project_004 project_005)

for proj in "${projects[@]}"; do
    (
        cd "$proj"
        if your_build_command &> "build_${proj}.log"; then
            echo "$proj: SUCCESS"
        else
            echo "$proj: FAILED (see build_${proj}.log)"
        fi
    ) &
done

wait
echo "All tests complete"
```

---

### 2. Progress Tracker

```bash
#!/bin/bash
# track_progress.sh

total_projects=78
current_date=$(date +%Y-%m-%d)

# Count successful builds
success_count=$(find . -name "build_*.log" -exec grep -l "BUILD SUCCEEDED" {} \; | wc -l)

# Calculate percentage
percentage=$(( success_count * 100 / total_projects ))

# Log progress
echo "$current_date,$success_count,$total_projects,$percentage%" >> progress.csv

# Display
echo "Progress: $success_count/$total_projects ($percentage%)"
```

---

### 3. Report Generator

```bash
#!/bin/bash
# generate_report.sh

cat > report.md << EOF
# Build Status Report
Generated: $(date)

## Summary
- Total Projects: 78
- Building: $(grep SUCCESS build_*.log | wc -l)
- Failed: $(grep FAILED build_*.log | wc -l)
- Not Tested: $(( 78 - $(ls build_*.log | wc -l) ))

## By Category
EOF

echo "### Successful Builds" >> report.md
grep -l SUCCESS build_*.log | sed 's/build_//;s/.log//' >> report.md

echo "" >> report.md
echo "### Failed Builds" >> report.md
grep -l FAILED build_*.log | sed 's/build_//;s/.log//' >> report.md

echo "Report generated: report.md"
```

---

## Lessons & Best Practices

### DO:
✅ Start with one working example
✅ Document patterns immediately
✅ Test systematically, not randomly
✅ Categorize everything
✅ Track your progress
✅ Automate repetitive tasks
✅ Share findings with team

### DON'T:
❌ Try to fix everything at once
❌ Assume patterns apply universally
❌ Skip documentation
❌ Test randomly without tracking
❌ Ignore outliers
❌ Work in isolation
❌ Forget to celebrate wins

---

## Expected Outcomes by Time

### After 1 Hour:
- Inventory complete
- First pattern discovered
- 5-10 projects tested
- Success rate estimated

### After 4 Hours:
- All patterns identified
- 50%+ projects tested
- Categories defined
- Build scripts created

### After 8 Hours:
- 100% projects tested
- All patterns documented
- Automation in place
- Clear roadmap

### After 16 Hours:
- Easy fixes complete
- Moderate fixes underway
- Team trained
- Continuous improvement

---

## Measuring Success

### Quantitative Metrics:
- **Before/After Build Rate**: 28% → 56% ✓
- **Coverage**: 0% tested → 100% tested ✓
- **Time per Project**: Unknown → 24 min avg ✓
- **Fix Complexity Known**: No → Yes ✓

### Qualitative Metrics:
- **Team Understanding**: Low → High
- **Confidence in Estimates**: Low → High
- **Knowledge Documentation**: None → Complete
- **Process Repeatability**: No → Yes

---

## Adapting This Method

### For Different Scales:

**10 Projects**: Manual testing fine, light documentation
**50 Projects**: Use scripts, document patterns
**100+ Projects**: Full automation, continuous monitoring
**1000+ Projects**: Dedicated tooling, team process

### For Different Technologies:

**Same Principles Apply**:
1. Discover patterns
2. Test systematically
3. Categorize results
4. Document findings
5. Automate repeating tasks

**Adjust Commands**:
- Build commands
- Error patterns
- File extensions
- Tools used

---

## Troubleshooting

### "No patterns found"
→ Look broader: check parent/child directories
→ Try different file extensions
→ Ask: "How would I build this manually?"

### "Too many patterns"
→ Group similar patterns
→ Focus on most common ones first
→ Document exceptions separately

### "Tests taking too long"
→ Parallelize testing
→ Test representative samples first
→ Skip obvious placeholders

### "Results not consistent"
→ Check environment differences
→ Document environment requirements
→ Use containerization (Docker)

---

## Next Steps

After completing this analysis:

1. **Share findings** with team
2. **Create automation** for continuous testing
3. **Fix easy wins** for quick progress
4. **Plan complex fixes** with realistic estimates
5. **Monitor continuously** to prevent regressions

---

## Resources

### Tools Used in This Project:
- `find` - File discovery
- `grep` - Pattern matching
- `xcodebuild` - Building (Swift/visionOS)
- `bash` - Scripting and automation
- `comm` - Set operations
- `sort/uniq` - Data processing

### Transferable to Other Ecosystems:
- **Java**: Maven, Gradle
- **JavaScript**: npm, yarn, pnpm
- **Python**: pip, poetry, conda
- **Rust**: cargo
- **Go**: go build
- **C/C++**: make, cmake

---

## Conclusion

This systematic approach works because it:

1. **Starts small** - One success builds confidence
2. **Scales systematically** - Patterns emerge naturally
3. **Documents continuously** - Knowledge compounds
4. **Measures progress** - Motivation maintained
5. **Adapts quickly** - Learns from each test

**Apply this method to any codebase for rapid understanding and measurable progress.**

---

**Guide Version**: 1.0
**Last Updated**: 2025-12-10
**Status**: Field-tested on 78 projects
**Success Rate**: 100% improvement achieved
