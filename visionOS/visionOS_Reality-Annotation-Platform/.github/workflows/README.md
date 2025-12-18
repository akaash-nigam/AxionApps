# GitHub Actions Workflows

This directory contains CI/CD workflows for Reality Annotations.

---

## 📋 Available Workflows

### 1. Deploy Landing Page (`deploy-landing-page.yml`)

**Status:** ✅ **Ready to use now**

**Triggers:**
- Push to `main` branch (when landing-page/ changes)
- Manual workflow dispatch

**What it does:**
- Deploys landing page to GitHub Pages
- Validates HTML and CSS
- Checks for broken links and placeholder content
- Reports file sizes

**Setup Required:**
1. Enable GitHub Pages in repository settings
2. Set source to `gh-pages` branch
3. Optionally add custom domain

**URL after deployment:**
- https://[username].github.io/[repo-name]
- Or custom domain if configured

---

### 2. Swift Lint (`swift-lint.yml`)

**Status:** ⏳ **Will work when Xcode project exists**

**Triggers:**
- Push to `main` or `develop` branches (when Swift files change)
- Pull requests (when Swift files change)

**What it does:**
- Installs and runs SwiftLint
- Checks code quality and style
- Counts force unwraps, print statements, TODOs
- Reports code statistics

**Setup Required:**
- None (runs automatically when Swift files exist)
- Optional: Customize `.swiftlint.yml` config

**Code Quality Checks:**
- ✅ Swift style guidelines
- ✅ Code complexity
- ✅ Type/function length
- ✅ Naming conventions
- ✅ Best practices

---

### 3. Test (`test.yml`)

**Status:** ⏳ **Will work when Xcode project exists**

**Triggers:**
- Push to `main` or `develop` branches
- Pull requests to `main` or `develop`
- Manual workflow dispatch

**What it does:**
- Runs unit tests (122 tests)
- Runs integration tests (15 tests)
- Runs UI tests (25 tests)
- Runs performance tests (10+ tests)
- Generates code coverage report
- Uploads test results and screenshots

**Jobs:**
1. `test-unit` - Unit tests
2. `test-integration` - Integration tests
3. `test-ui` - UI tests with screenshots
4. `test-performance` - Performance benchmarks
5. `test-summary` - Combined summary

**Setup Required:**
1. Create Xcode project (see `docs/Xcode_Setup_Guide.md`)
2. Add all source and test files
3. Workflow runs automatically

**Artifacts:**
- Test results (`.xcresult` bundles)
- Code coverage report (JSON)
- UI test screenshots (on failure)

**Retention:** 30 days (screenshots: 7 days)

---

### 4. Build (`build.yml`)

**Status:** ⏳ **Will work when Xcode project exists**

**Triggers:**
- Push to `main` or `develop` branches
- Pull requests to `main`
- Manual workflow dispatch

**What it does:**
- Builds for visionOS Simulator
- Builds for visionOS Device
- Archives app (on `main` branch)
- Exports IPA (if signing configured)
- Validates build status

**Jobs:**
1. `build-simulator` - Simulator build
2. `build-device` - Device build (unsigned)
3. `archive` - Archive and export (main branch only)
4. `validate` - Validate all builds
5. `notify` - Create issue on failure

**Setup Required:**
1. Create Xcode project
2. For archiving: Configure code signing secrets
   - `CERTIFICATES_P12` - Base64 encoded .p12 certificate
   - `CERTIFICATE_PASSWORD` - Certificate password
   - `EXPORT_OPTIONS_PLIST` - Export options

**Artifacts:**
- Xcode Archive (`.xcarchive`)
- IPA file (if signing configured)

---

## 🔐 Required Secrets

For full CI/CD functionality, add these secrets in GitHub repository settings:

### For Code Signing (Optional)

| Secret | Description |
|--------|-------------|
| `CERTIFICATES_P12` | Base64-encoded signing certificate (.p12 file) |
| `CERTIFICATE_PASSWORD` | Password for the certificate |
| `EXPORT_OPTIONS_PLIST` | Export options for IPA generation |

**How to create secrets:**

1. **Export certificate:**
   ```bash
   # Export from Keychain
   # Then convert to base64:
   base64 -i certificate.p12 | pbcopy
   ```

2. **Create EXPORT_OPTIONS_PLIST:**
   ```xml
   <?xml version="1.0" encoding="UTF-8"?>
   <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
   <plist version="1.0">
   <dict>
       <key>method</key>
       <string>app-store</string>
       <key>teamID</key>
       <string>YOUR_TEAM_ID</string>
   </dict>
   </plist>
   ```

3. **Add to GitHub:**
   - Settings → Secrets and variables → Actions
   - Click "New repository secret"
   - Paste values

---

## 🚀 Workflow Status

| Workflow | Status | Ready to Run |
|----------|--------|--------------|
| Deploy Landing Page | ✅ Active | Now |
| Swift Lint | ⏳ Pending | After Xcode project created |
| Test | ⏳ Pending | After Xcode project created |
| Build | ⏳ Pending | After Xcode project created |

---

## 📊 What Happens When

### On Every Push to `main`

1. **Landing page changes** → Deploys to GitHub Pages
2. **Swift files change** → Runs linting
3. **Any code change** → Runs tests and builds

### On Pull Request

1. Runs all tests
2. Runs linting
3. Builds for validation
4. Reports results in PR

### On Manual Trigger

- Any workflow can be manually triggered via Actions tab
- Useful for testing or re-running failed workflows

---

## 🔧 Customization

### Modify SwiftLint Rules

Edit the `.swiftlint.yml` configuration in the `swift-lint.yml` workflow:

```yaml
disabled_rules:
  - line_length  # Disable specific rules

opt_in_rules:
  - force_unwrapping  # Enable opt-in rules

type_body_length:
  warning: 300  # Customize thresholds
```

### Change Test Timeout

In `test.yml`, adjust `timeout-minutes`:

```yaml
jobs:
  test-unit:
    timeout-minutes: 30  # Increase if tests take longer
```

### Add More Platforms

To test on multiple visionOS versions:

```yaml
strategy:
  matrix:
    visionos: ['1.0', '1.1', '2.0']
```

### Slack/Discord Notifications

Add notification steps to workflows:

```yaml
- name: Notify Slack
  if: failure()
  uses: 8398a7/action-slack@v3
  with:
    status: ${{ job.status }}
    webhook_url: ${{ secrets.SLACK_WEBHOOK }}
```

---

## 🐛 Troubleshooting

### Workflow not running

**Problem:** Workflow doesn't trigger

**Solutions:**
- Check file is in `.github/workflows/` directory
- Check YAML syntax is valid
- Check trigger conditions match your branch/path
- Check Actions are enabled in repository settings

### Xcode version issues

**Problem:** "Xcode version not found"

**Solutions:**
- Update `xcode-version` in workflow
- Use `latest-stable` for most recent version
- Check available versions: https://github.com/actions/runner-images

### Test failures in CI but pass locally

**Problem:** Tests fail in CI but work on your machine

**Solutions:**
- Check for timing issues (increase timeouts)
- Check for hardcoded paths or assumptions
- Review CI environment differences
- Run with same Xcode version locally

### Code signing errors

**Problem:** "Code signing failed" during archive

**Solutions:**
- Verify secrets are correctly set
- Check certificate hasn't expired
- Verify bundle identifier matches provisioning profile
- Test signing locally first

### Out of disk space

**Problem:** "No space left on device"

**Solutions:**
- Add cleanup steps to workflow
- Reduce artifact retention
- Use `actions/cache` for dependencies

---

## 📈 Monitoring

### View Workflow Status

1. Go to **Actions** tab in GitHub
2. Click on workflow name
3. View run history and logs

### View Artifacts

1. Click on completed workflow run
2. Scroll to **Artifacts** section
3. Download test results, coverage, or IPA

### View Test Results

1. Download test results artifact (`.xcresult`)
2. Open in Xcode: File → Open → Select `.xcresult`
3. View detailed test reports and screenshots

### Check Code Coverage

1. Download coverage report artifact
2. Parse JSON for coverage percentages
3. Or view in Xcode test results

---

## 🎯 Best Practices

### 1. Run Tests Before Pushing

```bash
# Locally run what CI will run
xcodebuild test -scheme RealityAnnotation
swiftlint lint
```

### 2. Keep Workflows Fast

- Use caching for dependencies
- Run expensive jobs only on main branch
- Parallelize independent jobs

### 3. Fail Fast

- Run linting before tests
- Run unit tests before UI tests
- Stop on first failure when appropriate

### 4. Meaningful Commit Messages

CI runs are easier to debug with clear commit messages:

```bash
# Good
git commit -m "Fix: Resolve crash in AnnotationService"

# Bad
git commit -m "fix stuff"
```

### 5. Review Logs

Always review CI logs for warnings even if tests pass.

---

## 📚 Resources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Xcode Cloud vs GitHub Actions](https://developer.apple.com/xcode-cloud/)
- [SwiftLint Rules](https://realm.github.io/SwiftLint/rule-directory.html)
- [Fastlane for iOS CI/CD](https://fastlane.tools)

---

## 🤝 Contributing

When adding new workflows:

1. Test locally using [act](https://github.com/nektos/act)
2. Start with `workflow_dispatch` trigger for testing
3. Add clear documentation
4. Include error handling
5. Update this README

---

## 📞 Support

If workflows aren't working:

1. Check this README for troubleshooting
2. Review workflow logs in Actions tab
3. Open an issue with workflow run URL
4. Tag as `ci-cd` label

---

**CI/CD Documentation Version:** 1.0
**Last Updated:** 2024-11-24
