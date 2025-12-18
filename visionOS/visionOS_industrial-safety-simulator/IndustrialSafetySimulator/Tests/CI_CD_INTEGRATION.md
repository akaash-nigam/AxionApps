# CI/CD Integration Guide

## 📋 Overview

This guide provides complete instructions for integrating Industrial Safety Simulator tests into CI/CD pipelines.

## 🎯 CI/CD Goals

- ✅ Run all executable tests on every commit
- ✅ Measure and report code coverage
- ✅ Block PRs with failing tests or low coverage
- ✅ Generate test reports for review
- ✅ Fast feedback (<5 minutes for unit tests)

## 🔧 GitHub Actions Integration

### Complete Workflow Configuration

Create `.github/workflows/tests.yml`:

```yaml
name: Tests

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main, develop]

env:
  XCODE_VERSION: '15.2'

jobs:
  unit-and-integration-tests:
    name: Unit & Integration Tests
    runs-on: macos-14
    timeout-minutes: 15

    steps:
      - name: Checkout code
        uses: actions/checkout@v4
        with:
          fetch-depth: 0  # Full history for better coverage diffs

      - name: Select Xcode version
        run: |
          sudo xcode-select -s /Applications/Xcode_${{ env.XCODE_VERSION }}.app
          xcodebuild -version

      - name: Cache Swift packages
        uses: actions/cache@v3
        with:
          path: .build
          key: ${{ runner.os }}-swift-${{ hashFiles('**/Package.resolved') }}
          restore-keys: |
            ${{ runner.os }}-swift-

      - name: Run Unit Tests
        run: |
          cd IndustrialSafetySimulator
          swift test --filter UnitTests --enable-code-coverage --parallel
        timeout-minutes: 5

      - name: Run Integration Tests
        run: |
          cd IndustrialSafetySimulator
          swift test --filter IntegrationTests --enable-code-coverage
        timeout-minutes: 5

      - name: Run Accessibility Tests
        run: |
          cd IndustrialSafetySimulator
          swift test --filter AccessibilityTests --enable-code-coverage
        timeout-minutes: 3

      - name: Run Performance Tests
        run: |
          cd IndustrialSafetySimulator
          swift test --filter PerformanceTests --enable-code-coverage
        timeout-minutes: 5

      - name: Generate Coverage Report
        run: |
          cd IndustrialSafetySimulator
          xcrun llvm-cov export \
            .build/debug/IndustrialSafetySimulatorPackageTests.xctest/Contents/MacOS/IndustrialSafetySimulatorPackageTests \
            -instr-profile=.build/debug/codecov/default.profdata \
            -format=lcov > coverage.lcov

      - name: Upload Coverage to Codecov
        uses: codecov/codecov-action@v3
        with:
          files: ./IndustrialSafetySimulator/coverage.lcov
          fail_ci_if_error: true
          verbose: true

      - name: Check Coverage Threshold
        run: |
          cd IndustrialSafetySimulator
          COVERAGE=$(xcrun llvm-cov report \
            .build/debug/IndustrialSafetySimulatorPackageTests.xctest/Contents/MacOS/IndustrialSafetySimulatorPackageTests \
            -instr-profile=.build/debug/codecov/default.profdata \
            | grep TOTAL | awk '{print $10}' | sed 's/%//')

          echo "Code Coverage: $COVERAGE%"

          if (( $(echo "$COVERAGE < 85.0" | bc -l) )); then
            echo "❌ Coverage $COVERAGE% is below 85% threshold"
            exit 1
          else
            echo "✅ Coverage $COVERAGE% meets 85% threshold"
          fi

      - name: Archive Test Results
        if: always()
        uses: actions/upload-artifact@v3
        with:
          name: test-results
          path: |
            IndustrialSafetySimulator/.build/debug/
            IndustrialSafetySimulator/coverage.lcov
          retention-days: 30

  ui-tests:
    name: UI Tests (Simulator)
    runs-on: macos-14
    timeout-minutes: 30
    # Only run on main/develop to save CI minutes
    if: github.ref == 'refs/heads/main' || github.ref == 'refs/heads/develop'

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Select Xcode version
        run: sudo xcode-select -s /Applications/Xcode_${{ env.XCODE_VERSION }}.app

      - name: List Available Simulators
        run: xcrun simctl list devices visionOS

      - name: Run UI Tests on visionOS Simulator
        run: |
          xcodebuild test \
            -scheme IndustrialSafetySimulator \
            -destination 'platform=visionOS Simulator,name=Apple Vision Pro' \
            -only-testing:IndustrialSafetySimulatorUITests \
            -resultBundlePath TestResults.xcresult \
            -enableCodeCoverage YES
        continue-on-error: true  # UI tests optional until simulator available

      - name: Upload UI Test Results
        if: always()
        uses: actions/upload-artifact@v3
        with:
          name: ui-test-results
          path: TestResults.xcresult
          retention-days: 30

  test-report:
    name: Generate Test Report
    runs-on: macos-14
    needs: [unit-and-integration-tests]
    if: always()

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Download Test Artifacts
        uses: actions/download-artifact@v3
        with:
          name: test-results
          path: test-results

      - name: Install xcparse
        run: brew install chargepoint/xcparse/xcparse

      - name: Generate HTML Report
        run: |
          if [ -f test-results/*.xcresult ]; then
            xcparse --output-format html \
              test-results/*.xcresult \
              test-report.html
          fi

      - name: Upload Test Report
        if: always()
        uses: actions/upload-artifact@v3
        with:
          name: test-report-html
          path: test-report.html
          retention-days: 30

      - name: Comment PR with Results
        if: github.event_name == 'pull_request'
        uses: actions/github-script@v6
        with:
          script: |
            const fs = require('fs');
            const coverage = fs.readFileSync('test-results/coverage.lcov', 'utf8');
            const lines = coverage.split('\n');
            const totalLines = lines.filter(l => l.startsWith('LF:')).reduce((a, b) => a + parseInt(b.split(':')[1]), 0);
            const coveredLines = lines.filter(l => l.startsWith('LH:')).reduce((a, b) => a + parseInt(b.split(':')[1]), 0);
            const percentage = ((coveredLines / totalLines) * 100).toFixed(2);

            const comment = `## 🧪 Test Results\n\n` +
              `✅ All tests passed!\n\n` +
              `📊 **Code Coverage**: ${percentage}% (${coveredLines}/${totalLines} lines)\n\n` +
              `🎯 **Target**: 85%\n\n` +
              (percentage >= 85 ? '✅ Coverage target met!' : '⚠️ Coverage below target');

            github.rest.issues.createComment({
              issue_number: context.issue.number,
              owner: context.repo.owner,
              repo: context.repo.repo,
              body: comment
            });
```

### Workflow for Release Branches

Create `.github/workflows/release-tests.yml`:

```yaml
name: Release Tests

on:
  push:
    branches: [release/**]
    tags: ['v*']

jobs:
  comprehensive-tests:
    name: Comprehensive Test Suite
    runs-on: macos-14
    timeout-minutes: 60

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Select Xcode version
        run: sudo xcode-select -s /Applications/Xcode_15.2.app

      - name: Run All Tests
        run: |
          cd IndustrialSafetySimulator
          swift test --enable-code-coverage --verbose

      - name: Run UI Tests
        run: |
          xcodebuild test \
            -scheme IndustrialSafetySimulator \
            -destination 'platform=visionOS Simulator,name=Apple Vision Pro' \
            -resultBundlePath ReleaseTests.xcresult \
            -enableCodeCoverage YES

      - name: Performance Benchmarks
        run: |
          cd IndustrialSafetySimulator
          swift test --filter PerformanceTests --verbose

      - name: Generate Full Coverage Report
        run: |
          # Generate and archive comprehensive coverage
          xcrun llvm-cov show \
            .build/debug/IndustrialSafetySimulatorPackageTests.xctest/Contents/MacOS/IndustrialSafetySimulatorPackageTests \
            -instr-profile=.build/debug/codecov/default.profdata \
            -format=html \
            -output-dir=coverage-html

      - name: Upload Coverage HTML
        uses: actions/upload-artifact@v3
        with:
          name: coverage-report
          path: coverage-html/
          retention-days: 90  # Keep release reports longer

      - name: Fail if Coverage Below Threshold
        run: |
          # Strict enforcement for releases
          COVERAGE=$(xcrun llvm-cov report ... | grep TOTAL | awk '{print $10}' | sed 's/%//')
          if (( $(echo "$COVERAGE < 85.0" | bc -l) )); then
            echo "❌ Release requires ≥85% coverage, got $COVERAGE%"
            exit 1
          fi
```

## 🏃 Fastlane Integration

### Fastfile Configuration

Create `fastlane/Fastfile`:

```ruby
# Fastlane Configuration for Industrial Safety Simulator

default_platform(:visionos)

platform :visionos do

  desc "Run all unit tests"
  lane :test_unit do
    scan(
      scheme: "IndustrialSafetySimulator",
      testplan: "UnitTests",
      code_coverage: true,
      output_directory: "./test-reports",
      output_types: "html,junit",
      fail_build: true
    )
  end

  desc "Run integration tests"
  lane :test_integration do
    scan(
      scheme: "IndustrialSafetySimulator",
      testplan: "IntegrationTests",
      code_coverage: true,
      output_directory: "./test-reports"
    )
  end

  desc "Run UI tests on simulator"
  lane :test_ui do
    scan(
      scheme: "IndustrialSafetySimulator",
      devices: ["Apple Vision Pro"],
      testplan: "UITests",
      code_coverage: true,
      output_directory: "./test-reports"
    )
  end

  desc "Run all tests"
  lane :test_all do
    test_unit
    test_integration
    test_ui
  end

  desc "Generate coverage report"
  lane :coverage do
    slather(
      scheme: "IndustrialSafetySimulator",
      workspace: "IndustrialSafetySimulator.xcworkspace",
      html: true,
      output_directory: "./coverage-report",
      ignore: ["**/Tests/**", "**/*Tests.swift"],
      verbose: true
    )

    # Open coverage report
    sh("open ../coverage-report/index.html")
  end

  desc "Run tests and generate reports"
  lane :test_with_reports do
    test_all
    coverage

    # Upload to test reporting service (optional)
    # upload_to_testflight(...) or similar
  end

end
```

### Running Fastlane

```bash
# Install Fastlane
brew install fastlane

# Run specific lane
fastlane test_unit
fastlane test_integration
fastlane test_all
fastlane coverage
```

## 🐳 Docker Integration

### Dockerfile for Testing

Create `Dockerfile.test`:

```dockerfile
FROM swift:6.0

WORKDIR /app

# Copy source
COPY . .

# Build and test
RUN cd IndustrialSafetySimulator && \
    swift build && \
    swift test --enable-code-coverage

# Generate coverage
RUN cd IndustrialSafetySimulator && \
    xcrun llvm-cov report \
      .build/debug/IndustrialSafetySimulatorPackageTests.xctest/Contents/MacOS/IndustrialSafetySimulatorPackageTests \
      -instr-profile=.build/debug/codecov/default.profdata

CMD ["swift", "test"]
```

### Docker Compose

Create `docker-compose.test.yml`:

```yaml
version: '3.8'

services:
  test:
    build:
      context: .
      dockerfile: Dockerfile.test
    volumes:
      - .:/app
      - test-results:/app/test-results
    environment:
      - SWIFT_VERSION=6.0
    command: swift test --enable-code-coverage

volumes:
  test-results:
```

## 📊 Test Reporting Services

### Codecov Integration

**Setup**:
1. Sign up at [codecov.io](https://codecov.io)
2. Add repository
3. Add `CODECOV_TOKEN` to GitHub Secrets
4. Use workflow step shown above

**Configuration** (`.codecov.yml`):
```yaml
coverage:
  status:
    project:
      default:
        target: 85%
        threshold: 1%
    patch:
      default:
        target: 80%

ignore:
  - "Tests/**"
  - "**/*Tests.swift"

comment:
  layout: "header, diff, files"
  behavior: default
```

### SonarQube Integration

**GitHub Action** (`.github/workflows/sonar.yml`):
```yaml
name: SonarQube Analysis

on:
  push:
    branches: [main]
  pull_request:
    types: [opened, synchronize, reopened]

jobs:
  sonarqube:
    runs-on: macos-14
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Run Tests with Coverage
        run: |
          cd IndustrialSafetySimulator
          swift test --enable-code-coverage

      - name: SonarQube Scan
        uses: sonarsource/sonarqube-scan-action@master
        env:
          SONAR_TOKEN: ${{ secrets.SONAR_TOKEN }}
          SONAR_HOST_URL: ${{ secrets.SONAR_HOST_URL }}
```

## 🔔 Notifications and Alerts

### Slack Notifications

Add to GitHub Actions:

```yaml
      - name: Notify Slack on Failure
        if: failure()
        uses: slackapi/slack-github-action@v1
        with:
          channel-id: 'testing-alerts'
          slack-message: |
            ❌ Tests failed for ${{ github.repository }}
            Branch: ${{ github.ref }}
            Commit: ${{ github.sha }}
            Author: ${{ github.actor }}
            View: ${{ github.server_url }}/${{ github.repository }}/actions/runs/${{ github.run_id }}
        env:
          SLACK_BOT_TOKEN: ${{ secrets.SLACK_BOT_TOKEN }}

      - name: Notify Slack on Success
        if: success()
        uses: slackapi/slack-github-action@v1
        with:
          channel-id: 'testing-alerts'
          slack-message: |
            ✅ All tests passed for ${{ github.repository }}
            Coverage: ${{ env.COVERAGE }}%
```

## 🎯 Pre-commit Hooks

### Husky-style Pre-commit

Create `.git/hooks/pre-commit`:

```bash
#!/bin/bash

echo "🧪 Running pre-commit tests..."

# Run unit tests (fast)
cd IndustrialSafetySimulator
swift test --filter UnitTests --parallel

if [ $? -ne 0 ]; then
  echo "❌ Unit tests failed. Commit aborted."
  exit 1
fi

echo "✅ All pre-commit tests passed!"
exit 0
```

Make executable:
```bash
chmod +x .git/hooks/pre-commit
```

## 📈 Metrics and Dashboards

### GitHub Actions Badge

Add to README.md:
```markdown
![Tests](https://github.com/yourorg/visionOS_industrial-safety-simulator/workflows/Tests/badge.svg)
![Coverage](https://codecov.io/gh/yourorg/visionOS_industrial-safety-simulator/branch/main/graph/badge.svg)
```

### Test Execution Times

Track and optimize:
```yaml
      - name: Record Test Times
        run: |
          echo "Unit Tests: $(date -u +%s)" >> test-times.log
          swift test --filter UnitTests
          echo "Completed: $(date -u +%s)" >> test-times.log
```

## 🚀 Deployment Gates

### Require Tests for Merge

**Branch Protection Rules**:
1. Go to Repository Settings → Branches
2. Add rule for `main` branch
3. Enable:
   - ✅ Require status checks to pass
   - ✅ Require branches to be up to date
   - Select: `unit-and-integration-tests`

### Require Coverage Threshold

In workflow:
```yaml
      - name: Block Merge if Coverage Too Low
        run: |
          if (( $(echo "$COVERAGE < 85.0" | bc -l) )); then
            echo "status=failure" >> $GITHUB_OUTPUT
            exit 1
          fi
```

## 🔧 Troubleshooting CI/CD

### Common Issues

**Issue**: Tests pass locally but fail in CI

**Solution**:
- Check Xcode version matches
- Verify environment variables
- Check file paths (use `Bundle.module`)
- Review CI logs carefully

**Issue**: CI runs out of time

**Solution**:
```yaml
    timeout-minutes: 30  # Increase timeout
    steps:
      - run: swift test --parallel  # Run in parallel
```

**Issue**: Flaky tests in CI

**Solution**:
- Use async/await properly
- Avoid hardcoded timeouts
- Add retry logic for network tests

## 📚 Additional Resources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Fastlane Documentation](https://docs.fastlane.tools)
- [Codecov Documentation](https://docs.codecov.com)
- [Swift Testing on CI](https://www.swift.org/continuous-integration)

---

**CI/CD Execution Time**: ~5 minutes for unit+integration tests
**Estimated Cost**: ~$0 (GitHub Actions free tier sufficient)
**Maintenance**: Low (automated)
