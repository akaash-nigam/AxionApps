# Pull Request

## Description

<!-- Provide a clear and concise description of what this PR does -->

## Type of Change

<!-- Mark the relevant option with an 'x' -->

- [ ] 🐛 Bug fix (non-breaking change that fixes an issue)
- [ ] ✨ New feature (non-breaking change that adds functionality)
- [ ] 💥 Breaking change (fix or feature that would cause existing functionality to not work as expected)
- [ ] 📝 Documentation update
- [ ] ♻️ Code refactoring (no functional changes)
- [ ] ⚡ Performance improvement
- [ ] ✅ Test addition or update
- [ ] 🎨 UI/UX improvement

## Related Issues

<!-- Link related issues -->

Closes #<!-- issue number -->
Related to #<!-- issue number -->

## Changes Made

<!-- List the key changes in this PR -->

- Change 1
- Change 2
- Change 3

## Testing

### Unit Tests

- [ ] All existing tests pass
- [ ] New tests added for new functionality
- [ ] Code coverage maintained or improved

### Manual Testing

<!-- Describe manual testing performed -->

- [ ] Tested on visionOS Simulator
- [ ] Tested on Apple Vision Pro hardware (if applicable)
- [ ] Tested edge cases

**Test Environment:**
- visionOS version:
- Device: Simulator / Vision Pro
- App version:

**Test Scenarios:**
1. Scenario 1
2. Scenario 2

## Screenshots / Videos

<!-- Add screenshots or videos demonstrating the changes (if applicable) -->

## Performance Impact

<!-- Describe any performance implications -->

- [ ] No performance impact
- [ ] Performance improved
- [ ] Performance regression (justified because...)

**Metrics:**
- Frame rate: <!-- before → after -->
- Memory usage: <!-- before → after -->
- Load time: <!-- before → after -->

## Checklist

<!-- Ensure all items are checked before submitting -->

### Code Quality

- [ ] Code compiles without errors or warnings
- [ ] SwiftLint shows zero warnings
- [ ] Follows Swift API Design Guidelines
- [ ] Code is well-documented with comments
- [ ] No TODO comments left in code

### Testing

- [ ] All unit tests pass (`xcodebuild test`)
- [ ] Code coverage ≥70% overall
- [ ] Performance tests pass (if applicable)
- [ ] Manual testing completed

### Documentation

- [ ] README updated (if needed)
- [ ] Inline code documentation added/updated
- [ ] CHANGELOG updated (if applicable)
- [ ] Migration guide provided (for breaking changes)

### Git Hygiene

- [ ] Commits follow Conventional Commits format
- [ ] Commit messages are clear and descriptive
- [ ] Branch is up to date with base branch
- [ ] No merge conflicts

### Accessibility

- [ ] VoiceOver labels added/updated (if UI changes)
- [ ] Supports Dynamic Type (if text changes)
- [ ] Tested with Reduce Motion enabled (if animations added)
- [ ] High contrast mode considered

### Security & Privacy

- [ ] No sensitive data exposed in logs
- [ ] No new third-party dependencies (or justified)
- [ ] Privacy manifest updated (if data usage changed)
- [ ] Follows App Sandbox guidelines

## Breaking Changes

<!-- If this PR includes breaking changes, describe them and provide migration path -->

**What breaks:**

**Migration path:**

## Additional Notes

<!-- Any additional information for reviewers -->

## Reviewer Checklist

<!-- For reviewers only -->

- [ ] Code reviewed for logic correctness
- [ ] Security considerations addressed
- [ ] Performance implications acceptable
- [ ] Tests adequately cover changes
- [ ] Documentation is clear and complete
- [ ] Commit history is clean

---

**By submitting this PR, I confirm that:**
- This contribution is my own work
- I have the right to submit it under the project's license
- I have tested the changes thoroughly
