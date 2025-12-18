# Contributing to Rhythm Flow

Thank you for your interest in contributing to Rhythm Flow! This document provides guidelines and instructions for contributing to the project.

---

## 📋 Table of Contents

1. [Code of Conduct](#code-of-conduct)
2. [How Can I Contribute?](#how-can-i-contribute)
3. [Development Setup](#development-setup)
4. [Coding Standards](#coding-standards)
5. [Commit Guidelines](#commit-guidelines)
6. [Pull Request Process](#pull-request-process)
7. [Testing Requirements](#testing-requirements)
8. [Documentation](#documentation)
9. [Community](#community)

---

## 📜 Code of Conduct

This project adheres to a Code of Conduct that all contributors are expected to follow. Please read [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md) before contributing.

**TL;DR**: Be respectful, inclusive, and professional.

---

## 🤝 How Can I Contribute?

### Reporting Bugs 🐛

Found a bug? Help us fix it!

1. **Check existing issues** - Search [existing issues](https://github.com/akaash-nigam/visionOS_Gaming_rhythm-flow/issues) first
2. **Create a new issue** - Use the [Bug Report template](.github/ISSUE_TEMPLATE/bug_report.md)
3. **Provide details**:
   - Clear description of the bug
   - Steps to reproduce
   - Expected vs actual behavior
   - Screenshots/videos if applicable
   - Device info (Vision Pro model, visionOS version)
   - Crash logs if available

### Suggesting Features 💡

Have an idea for a new feature?

1. **Check roadmap** - Review [IMPLEMENTATION_PLAN.md](IMPLEMENTATION_PLAN.md)
2. **Create a feature request** - Use the [Feature Request template](.github/ISSUE_TEMPLATE/feature_request.md)
3. **Describe the feature**:
   - What problem does it solve?
   - How would it work?
   - Why is it valuable?
   - Any implementation ideas?

### Reporting Performance Issues ⚡

Game running slowly?

1. **Create a performance issue** - Use the [Performance Issue template](.github/ISSUE_TEMPLATE/performance_issue.md)
2. **Include metrics**:
   - Frame rate (should be 90 FPS)
   - Memory usage
   - Device model
   - Specific scenario causing lag

### Improving Documentation 📚

Documentation improvements are always welcome!

- Fix typos or unclear explanations
- Add examples or clarifications
- Improve code comments
- Translate documentation

### Contributing Code 💻

Ready to write some code? Great!

**Good First Issues**: Look for issues labeled [`good first issue`](https://github.com/akaash-nigam/visionOS_Gaming_rhythm-flow/labels/good%20first%20issue)

**Priority Areas**:
- Bug fixes
- Performance optimizations
- Accessibility improvements
- Test coverage
- Documentation

---

## 🛠 Development Setup

### Prerequisites

- **macOS 14.0+** (Sonoma or later)
- **Xcode 16.0+**
- **visionOS SDK 2.0+**
- **Git**
- **Apple Developer Account** (for device testing)

### Clone Repository

```bash
# Clone the repo
git clone https://github.com/akaash-nigam/visionOS_Gaming_rhythm-flow.git
cd visionOS_Gaming_rhythm-flow

# Create a feature branch
git checkout -b feature/your-feature-name
```

### Open in Xcode

```bash
open RhythmFlow/RhythmFlow.xcodeproj
```

### Build the Project

1. Select target: **RhythmFlow**
2. Select destination: **Apple Vision Pro Simulator** or your device
3. Press ⌘R to build and run

### Run Tests

```bash
# Run all tests
xcodebuild test \
  -project RhythmFlow/RhythmFlow.xcodeproj \
  -scheme RhythmFlow \
  -sdk xros \
  -destination 'platform=visionOS Simulator,name=Apple Vision Pro'

# Or in Xcode: Press ⌘U
```

### Project Structure

```
visionOS_Gaming_rhythm-flow/
├── RhythmFlow/              # Main Xcode project
│   └── RhythmFlow/          # Source code
│       ├── App/             # App entry point
│       ├── Models/          # Data models
│       ├── Core/            # Core systems (engine, audio, input)
│       ├── Systems/         # Game systems (scoring, etc.)
│       └── Views/           # UI views
├── Tests/                   # Test suite
├── website/                 # Landing page
├── docs/                    # Documentation
└── [documentation files]    # README, guides, specs
```

---

## 📐 Coding Standards

### Swift Style Guide

Follow the [Swift Style Guide](STYLE_GUIDE.md). Key points:

**Naming**:
```swift
// ✅ Good
class ScoreManager { }
func calculateCombo() -> Int { }
var playerProfile: PlayerProfile

// ❌ Bad
class score_manager { }
func calc_combo() -> Int { }
var pp: PlayerProfile
```

**Formatting**:
```swift
// ✅ Good - Clear and readable
func registerHit(_ quality: HitQuality, noteValue: Int) {
    guard quality != .miss else {
        resetCombo()
        return
    }

    currentCombo += 1
    updateMultiplier()
}

// ❌ Bad - Unclear and cramped
func registerHit(_ quality:HitQuality,noteValue:Int){
    if quality != .miss{currentCombo+=1;updateMultiplier()}
    else{resetCombo()}
}
```

**Documentation**:
```swift
// ✅ Good - Well documented
/// Calculates the player's grade based on accuracy
/// - Parameter accuracy: Accuracy percentage (0.0 to 1.0)
/// - Returns: Grade from S (best) to F (worst)
func calculateGrade(accuracy: Double) -> Grade {
    switch accuracy {
    case 0.95...: return .S
    case 0.90..<0.95: return .A
    default: return .F
    }
}
```

### Architecture Patterns

- **ECS (Entity-Component-System)** - For game objects
- **MVVM** - For UI views
- **Observable** - For state management
- **Dependency Injection** - For testability

### Performance Guidelines

- **90 FPS minimum** - Profile code with Instruments
- **Object pooling** - For frequently created/destroyed objects
- **Async/await** - For non-blocking operations
- **@MainActor** - For UI updates
- **Memory budget** - Keep peak memory < 2GB

### Accessibility Requirements

All UI changes must:
- ✅ Support VoiceOver
- ✅ Have accessibility labels
- ✅ Support Dynamic Type
- ✅ Work with high contrast mode
- ✅ Respect reduce motion settings

---

## 📝 Commit Guidelines

### Commit Message Format

```
<type>(<scope>): <subject>

<body>

<footer>
```

**Types**:
- `feat`: New feature
- `fix`: Bug fix
- `perf`: Performance improvement
- `refactor`: Code refactoring
- `test`: Adding/updating tests
- `docs`: Documentation changes
- `style`: Code style changes (formatting)
- `chore`: Maintenance tasks

**Examples**:

```
feat(scoring): Add combo multiplier system

Implement combo multipliers at 10, 25, 50, 100, and 200 hit milestones.
Multipliers range from 1.1x to 2.5x for sustained combos.

Closes #42
```

```
fix(audio): Resolve spatial audio sync issue

Fixed audio-visual desync by implementing buffer compensation.
Audio now stays within ±2ms of visual events.

Fixes #89
```

```
perf(rendering): Optimize note entity pooling

Reduced memory allocations by 85% using object pool.
Frame time improved from 12.3ms to 9.8ms under heavy load.

Related to #67
```

### Commit Best Practices

- ✅ One logical change per commit
- ✅ Write clear, descriptive messages
- ✅ Reference related issues
- ✅ Keep commits atomic and focused
- ❌ Don't commit unrelated changes together
- ❌ Don't commit commented-out code
- ❌ Don't commit debug logging

---

## 🔀 Pull Request Process

### Before Submitting

1. **Update from main**
   ```bash
   git fetch origin
   git rebase origin/main
   ```

2. **Run all tests**
   ```bash
   xcodebuild test -scheme RhythmFlow
   ```

3. **Check code coverage**
   - Aim for 80%+ coverage
   - 100% for critical paths

4. **Run performance tests**
   - Verify 90 FPS maintained
   - Check memory usage

5. **Test accessibility**
   - Enable VoiceOver and test
   - Try high contrast mode
   - Test with Dynamic Type

6. **Update documentation**
   - Update relevant .md files
   - Add code comments
   - Update API_REFERENCE.md if needed

### Creating Pull Request

1. **Push your branch**
   ```bash
   git push origin feature/your-feature-name
   ```

2. **Open PR on GitHub**
   - Use the [PR template](.github/PULL_REQUEST_TEMPLATE.md)
   - Link related issues
   - Add screenshots/videos for UI changes

3. **Fill out PR template**
   - Clear description of changes
   - Testing checklist completed
   - Screenshots for visual changes
   - Performance impact noted

### PR Template Checklist

```markdown
## Description
[Clear description of what this PR does]

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Performance improvement
- [ ] Refactoring
- [ ] Documentation update

## Testing
- [ ] All unit tests pass
- [ ] Integration tests pass
- [ ] UI tests pass (if applicable)
- [ ] Performance tests pass
- [ ] Tested on device (if applicable)

## Accessibility
- [ ] VoiceOver tested
- [ ] High contrast mode tested
- [ ] Dynamic Type tested

## Screenshots
[If applicable, add screenshots or videos]

## Performance Impact
[Describe any performance impact]

## Related Issues
Closes #[issue number]
```

### Review Process

1. **Automated checks** - CI/CD runs tests
2. **Code review** - At least one maintainer reviews
3. **Feedback** - Address review comments
4. **Approval** - Maintainer approves PR
5. **Merge** - Squash and merge to main

### Review Criteria

Reviewers check for:
- ✅ Code quality and style
- ✅ Test coverage
- ✅ Performance impact
- ✅ Accessibility compliance
- ✅ Documentation updates
- ✅ No breaking changes (unless justified)

---

## 🧪 Testing Requirements

### Required Tests

All code changes must include appropriate tests:

**New Features**:
- Unit tests for new classes/methods
- Integration tests for multi-system features
- UI tests for new screens/flows
- Performance tests for performance-critical code

**Bug Fixes**:
- Regression test that fails before fix
- Test that passes after fix

**Refactoring**:
- Existing tests still pass
- Coverage maintained or improved

### Test Categories

1. **Unit Tests** (`Tests/Unit/`)
   - Test individual classes/methods
   - Fast execution (< 5 seconds total)
   - No external dependencies

2. **Integration Tests** (`Tests/Integration/`)
   - Test system interactions
   - End-to-end flows
   - Multi-system coordination

3. **UI Tests** (`Tests/UI/`)
   - Test user interactions
   - Navigation flows
   - Accessibility

4. **Performance Tests** (`Tests/Performance/`)
   - Frame rate benchmarks
   - Memory usage tests
   - Stress tests

### Running Tests

```bash
# All tests
xcodebuild test -scheme RhythmFlow

# Specific suite
xcodebuild test -only-testing:RhythmFlowTests/ScoreManagerTests

# With coverage
xcodebuild test -enableCodeCoverage YES
```

See [Tests/TEST_GUIDE.md](Tests/TEST_GUIDE.md) for detailed testing instructions.

---

## 📚 Documentation

### Code Documentation

**Public APIs** - Require full documentation:
```swift
/// Manages scoring, combos, and grade calculation during gameplay.
///
/// The ScoreManager tracks hit quality, maintains combo streaks, and applies
/// multipliers based on combo milestones. It calculates final scores and grades
/// according to the game's scoring system.
///
/// Example usage:
/// ```swift
/// let scoreManager = ScoreManager()
/// scoreManager.registerHit(.perfect, noteValue: 100)
/// let grade = scoreManager.calculateGrade()
/// ```
public class ScoreManager {
    /// Current combo count. Resets to 0 on any miss.
    public private(set) var currentCombo: Int = 0

    /// Registers a hit and updates score accordingly
    /// - Parameters:
    ///   - quality: The hit quality (Perfect, Great, Good, Okay, Miss)
    ///   - noteValue: Base point value of the note
    public func registerHit(_ quality: HitQuality, noteValue: Int) {
        // Implementation
    }
}
```

**Internal Methods** - Brief documentation:
```swift
/// Updates the combo multiplier based on current combo count
private func updateMultiplier() {
    // Implementation
}
```

### Markdown Documentation

When updating .md files:
- Use clear headings
- Include code examples
- Add links to related docs
- Keep table of contents updated
- Use proper markdown formatting

### Documentation Files to Update

- **README.md** - For user-facing changes
- **API_REFERENCE.md** - For API changes
- **ARCHITECTURE.md** - For architectural changes
- **TECHNICAL_SPEC.md** - For spec changes
- **Tests/TEST_GUIDE.md** - For test changes

---

## 🌟 Recognition

Contributors are recognized in several ways:

- Listed in **RECOGNITION.md**
- Mentioned in release notes
- Featured in changelog for significant contributions
- Invited to contributor Discord channel

---

## 💬 Community

### Getting Help

- **Documentation**: Start with README.md and docs/
- **GitHub Issues**: Search existing issues or create new one
- **Discussions**: Use GitHub Discussions for questions
- **Discord**: Join our contributor Discord (link in README)

### Communication Guidelines

- **Be respectful** - Treat everyone with respect
- **Be patient** - Maintainers are often volunteers
- **Be constructive** - Focus on solutions, not problems
- **Be inclusive** - Welcome newcomers
- **Be professional** - This is a professional environment

### Response Times

- **Critical bugs**: 24-48 hours
- **Regular issues**: 3-5 days
- **Feature requests**: 1-2 weeks
- **Pull requests**: 3-7 days

---

## 📋 Contribution Checklist

Before submitting your contribution:

- [ ] Code follows [STYLE_GUIDE.md](STYLE_GUIDE.md)
- [ ] All tests pass locally
- [ ] New tests added for new features
- [ ] Code coverage meets requirements (80%+)
- [ ] Documentation updated
- [ ] Commit messages follow guidelines
- [ ] PR template filled out completely
- [ ] Accessibility tested
- [ ] Performance impact assessed
- [ ] No compiler warnings
- [ ] Code reviewed by yourself first

---

## 🎯 Priority Areas

We especially welcome contributions in these areas:

### High Priority
- 🐛 **Bug fixes** - Especially critical/crash bugs
- ⚡ **Performance optimizations** - Maintaining 90 FPS
- ♿ **Accessibility improvements** - WCAG compliance
- 🧪 **Test coverage** - Increasing to 80%+

### Medium Priority
- ✨ **New features** - From the roadmap
- 🎨 **UI/UX improvements** - Enhanced user experience
- 🎵 **Content** - New songs, beat maps
- 📚 **Documentation** - Clarity and completeness

### Nice to Have
- 🌍 **Localization** - Additional languages
- 🎮 **New game modes** - Creative gameplay
- 🏆 **Achievements** - Additional challenges
- 🎨 **Visual effects** - Enhanced graphics

---

## ❓ FAQ

### Can I contribute if I don't have a Vision Pro?

Yes! Many contributions don't require hardware:
- Documentation improvements
- Code reviews
- Bug triage
- Landing page development
- Test writing (can run in simulator)

### How do I get my PR merged faster?

- Keep changes focused and small
- Include comprehensive tests
- Write clear descriptions
- Respond quickly to feedback
- Follow all guidelines

### What if my PR is rejected?

- Don't take it personally
- Read the feedback carefully
- Ask questions if unclear
- Learn and improve
- Try again!

### Can I work on multiple issues?

Yes, but:
- Finish one before starting another
- Separate PRs for separate issues
- Don't hoard issues you're not actively working on

### How do I become a maintainer?

- Consistent, high-quality contributions
- Help review other PRs
- Active community participation
- Demonstrate expertise and leadership

---

## 📞 Contact

- **Issues**: [GitHub Issues](https://github.com/akaash-nigam/visionOS_Gaming_rhythm-flow/issues)
- **Discussions**: [GitHub Discussions](https://github.com/akaash-nigam/visionOS_Gaming_rhythm-flow/discussions)
- **Security**: See [SECURITY.md](SECURITY.md)
- **Email**: [maintainer email if applicable]

---

## 📄 License

By contributing to Rhythm Flow, you agree that your contributions will be licensed under the same license as the project.

---

**Thank you for contributing to Rhythm Flow! Your efforts help make spatial rhythm gaming amazing for everyone.** 🎵🥽✨
