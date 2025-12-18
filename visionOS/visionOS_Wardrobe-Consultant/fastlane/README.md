# Fastlane Configuration
## Wardrobe Consultant

This directory contains Fastlane configuration for automated builds, tests, and deployment.

## Setup

### 1. Install Fastlane

```bash
# Using RubyGems
sudo gem install fastlane -NV

# Or using Homebrew
brew install fastlane
```

### 2. Configure Environment Variables

Create a `.env` file in the `fastlane` directory:

```bash
# fastlane/.env
FASTLANE_APPLE_ID="your@email.com"
FASTLANE_TEAM_ID="YOUR_TEAM_ID"
FASTLANE_ITC_TEAM_ID="YOUR_ITC_TEAM_ID"

# Optional: For Slack notifications
SLACK_URL="https://hooks.slack.com/services/YOUR/SLACK/WEBHOOK"

# Optional: For GitHub releases
GITHUB_TOKEN="your_github_token"

# Optional: Skip git status checks in development
# SKIP_GIT_CHECK=true
```

**Note**: Never commit `.env` to git. It's already in `.gitignore`.

### 3. Configure Match (Code Signing)

If using Fastlane Match for code signing:

```bash
fastlane match init
```

Follow the prompts to set up your certificates repository.

### 4. Update Appfile

Edit `fastlane/Appfile` with your actual values:

```ruby
apple_id "your@email.com"
app_identifier "com.yourcompany.wardrobeconsultant"
team_id "YOUR_TEAM_ID"
```

## Available Lanes

### Testing

```bash
# Run unit tests only
fastlane test_unit

# Run integration tests
fastlane test_integration

# Run UI tests
fastlane test_ui

# Run all tests (unit + integration)
fastlane test
```

### Building

```bash
# Build for development
fastlane build_dev

# Build for TestFlight
fastlane build_testflight
```

### Deployment

```bash
# Upload to TestFlight
fastlane beta

# Submit to App Store
fastlane release
```

### Screenshots

```bash
# Capture App Store screenshots
fastlane screenshots
```

### Version Management

```bash
# Bump major version (1.0.0 -> 2.0.0)
fastlane bump_major

# Bump minor version (1.0.0 -> 1.1.0)
fastlane bump_minor

# Bump patch version (1.0.0 -> 1.0.1)
fastlane bump_patch
```

### Maintenance

```bash
# Run SwiftLint
fastlane lint

# Auto-fix linting issues
fastlane lint_fix

# Clean build artifacts
fastlane clean

# Setup development environment
fastlane setup

# Sync code signing certificates
fastlane sync_signing
```

### visionOS

```bash
# Run tests on visionOS
fastlane visionos test

# Build for visionOS
fastlane visionos build
```

## Workflows

### Development Workflow

1. **Before committing:**
   ```bash
   fastlane lint        # Check code style
   fastlane test        # Run tests
   ```

2. **Creating a build:**
   ```bash
   fastlane build_dev   # Development build
   ```

### Release Workflow

1. **Prepare for release:**
   ```bash
   # Bump version
   fastlane bump_minor  # or bump_major/bump_patch

   # Update CHANGELOG.md manually
   ```

2. **Deploy to TestFlight:**
   ```bash
   fastlane beta
   ```

3. **After testing, release to App Store:**
   ```bash
   fastlane release
   ```

## CI/CD Integration

### GitHub Actions

Fastlane is already integrated with GitHub Actions in `.github/workflows/test.yml` and `.github/workflows/release.yml`.

### Manual CI/CD Setup

If setting up manually:

```yaml
# .github/workflows/test.yml
- name: Run tests via Fastlane
  run: fastlane test

# .github/workflows/release.yml
- name: Deploy to TestFlight
  run: fastlane beta
  env:
    FASTLANE_APPLE_ID: ${{ secrets.APPLE_ID }}
    FASTLANE_TEAM_ID: ${{ secrets.TEAM_ID }}
```

## Troubleshooting

### "Could not find action, lane or variable"

**Solution**: Ensure you're in the project root directory or specify the path:
```bash
cd /path/to/project
fastlane test
```

### Code signing issues

**Solution**: Use Match to sync certificates:
```bash
fastlane sync_signing
```

### TestFlight upload fails

**Problem**: Two-factor authentication required

**Solution**: Generate an app-specific password:
1. Go to appleid.apple.com
2. Security → App-Specific Passwords
3. Generate new password
4. Add to environment:
   ```bash
   export FASTLANE_APPLE_APPLICATION_SPECIFIC_PASSWORD="xxxx-xxxx-xxxx-xxxx"
   ```

### Screenshots not generating

**Problem**: Simulator issues

**Solution**:
```bash
# Reset simulators
fastlane snapshot reset_simulators

# Then retry
fastlane screenshots
```

### Build number conflicts

**Problem**: Build number already exists on TestFlight

**Solution**: Fastlane auto-increments, but if manual fix needed:
```bash
# Get latest build number
fastlane latest_testflight_build_number

# Increment manually
xcrun agvtool next-version -all
```

## Customization

### Adding New Lanes

Edit `Fastfile` and add new lanes:

```ruby
lane :my_custom_lane do
  # Your actions here
  UI.success "Custom lane complete!"
end
```

### Adding Plugins

```bash
# Search for plugins
fastlane search_plugins

# Install a plugin
fastlane add_plugin [plugin_name]
```

### Common Plugins

- **fastlane-plugin-versioning** - Advanced version management
- **fastlane-plugin-changelog** - Changelog generation
- **fastlane-plugin-firebase_app_distribution** - Firebase distribution
- **fastlane-plugin-browserstack** - BrowserStack integration

## Best Practices

### 1. Always Test Before Deploy
```bash
fastlane test && fastlane beta
```

### 2. Use Environment Variables
Never hardcode credentials in Fastfile.

### 3. Automate Version Bumps
```bash
fastlane bump_patch && git push
```

### 4. Keep Lanes Focused
Each lane should do one thing well.

### 5. Use Before/After Hooks
Already configured in Fastfile for cleanup and notifications.

## Security

### Sensitive Files

Never commit these files:
- `.env` - Environment variables
- `*.mobileprovision` - Provisioning profiles
- `*.p12` - Certificates
- `*.cer` - Certificates

All are in `.gitignore`.

### App Store Connect API Key

For automation without 2FA prompts:

1. Create API key in App Store Connect
2. Download and save securely
3. Reference in Fastfile:

```ruby
app_store_connect_api_key(
  key_id: ENV["APP_STORE_CONNECT_KEY_ID"],
  issuer_id: ENV["APP_STORE_CONNECT_ISSUER_ID"],
  key_filepath: "./AuthKey.p8"
)
```

## Resources

- [Fastlane Documentation](https://docs.fastlane.tools)
- [Available Actions](https://docs.fastlane.tools/actions)
- [Fastlane Plugins](https://docs.fastlane.tools/plugins/available-plugins/)
- [Match Code Signing](https://docs.fastlane.tools/actions/match/)
- [Snapshot Screenshots](https://docs.fastlane.tools/actions/snapshot/)

## Support

For Fastlane issues:
- [Fastlane GitHub](https://github.com/fastlane/fastlane)
- [Fastlane Slack](https://fastlane-slackin.herokuapp.com/)

For project-specific issues:
- See [CONTRIBUTING.md](../CONTRIBUTING.md)
- Email: dev@wardrobeconsultant.app

---

**Last Updated**: 2025-11-24
**Fastlane Version**: 2.217.0 (or later)
