# Contributing to Home Maintenance Oracle

Thank you for your interest in contributing! This document provides guidelines for contributing to the project.

## Code of Conduct

Be respectful, inclusive, and professional. We're all here to build great software.

## How to Contribute

### Reporting Bugs

1. Check existing issues first
2. Use the bug report template
3. Include steps to reproduce
4. Provide environment details

### Suggesting Features

1. Check the roadmap and existing issues
2. Use the feature request template
3. Explain the problem it solves
4. Describe your proposed solution

### Submitting Code

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Write/update tests
5. Ensure all tests pass
6. Commit with clear messages
7. Push to your fork
8. Open a Pull Request

## Development Setup

### Requirements
- macOS with Xcode 15.2+
- visionOS SDK 2.0+
- Swift 6.0+

### Setup Steps
1. Clone the repository
2. Open `HomeMaintenanceOracle.xcodeproj`
3. Build and run (`Cmd+R`)

### Running Tests
```bash
# All tests
xcodebuild test -scheme HomeMaintenanceOracle \
  -destination 'platform=visionOS Simulator,name=Apple Vision Pro'

# Specific test
xcodebuild test -scheme HomeMaintenanceOracle \
  -only-testing:HomeMaintenanceOracleTests/RecognitionViewModelTests
```

## Code Style

### Swift Style Guide
- Follow Swift API Design Guidelines
- Use SwiftLint (configuration in `.swiftlint.yml`)
- Meaningful variable names
- Document public APIs

### Commit Messages
Format: `<type>: <description>`

Types:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation
- `test`: Tests
- `refactor`: Code refactoring
- `perf`: Performance improvement
- `chore`: Maintenance

Examples:
- `feat: Add iCloud sync support`
- `fix: Correct recognition accuracy for old appliances`
- `docs: Update user guide with new features`

## Testing Requirements

- All new features must have tests
- Maintain 80%+ code coverage
- Tests must pass before PR merge

## Pull Request Process

1. Update documentation
2. Add tests for new features
3. Ensure all tests pass
4. Update CHANGELOG.md
5. Request review from maintainers
6. Address feedback
7. Squash commits if requested

## Questions?

- Email: dev@homemaintenanceoracle.com
- Documentation: Check docs/

Thank you for contributing! 🎉
