# Code Review Checklist

Use this checklist when reviewing pull requests for Tactical Team Shooters.

## General

- [ ] **Purpose**: Understand what the PR aims to achieve
- [ ] **Scope**: Changes are focused and don't mix unrelated updates
- [ ] **Breaking Changes**: Breaking changes are documented and necessary
- [ ] **Dependencies**: New dependencies are justified and approved

## Code Quality

- [ ] **Readability**: Code is clear and self-documenting
- [ ] **Naming**: Variables, functions, and types have descriptive names
- [ ] **Complexity**: Functions are not overly complex (cyclomatic complexity < 15)
- [ ] **DRY**: No unnecessary code duplication
- [ ] **Comments**: Complex logic is explained with comments
- [ ] **Documentation**: Public APIs have DocC documentation
- [ ] **TODO/FIXME**: TODOs are tracked in issues

## Swift Best Practices

- [ ] **Optionals**: Safe unwrapping (no force unwrapping without justification)
- [ ] **Error Handling**: Proper use of throws/try/catch
- [ ] **Access Control**: Appropriate access levels (public/internal/private)
- [ ] **Value Types**: Structs used where appropriate
- [ ] **Immutability**: Prefer `let` over `var`
- [ ] **Type Inference**: Leveraged where appropriate
- [ ] **Concurrency**: Proper use of async/await and actors
- [ ] **Memory Management**: No retain cycles

## Performance

- [ ] **Algorithms**: Efficient algorithms used (O(n) vs O(n²))
- [ ] **Allocations**: Minimal allocations in hot paths
- [ ] **Collections**: Appropriate collection types
- [ ] **Lazy Evaluation**: Used where beneficial
- [ ] **Caching**: Expensive computations cached if repeated
- [ ] **Profiling**: Performance-critical code has been profiled

## Testing

- [ ] **Coverage**: New code has unit tests
- [ ] **Edge Cases**: Tests cover edge cases
- [ ] **Test Quality**: Tests are clear and maintainable
- [ ] **Test Naming**: Descriptive test names
- [ ] **Assertions**: Proper use of XCTest assertions
- [ ] **Mocking**: Dependencies mocked where appropriate
- [ ] **All Tests Pass**: CI tests pass

## Game-Specific

### Gameplay

- [ ] **Balance**: Changes don't break game balance
- [ ] **Feel**: Game feel/responsiveness maintained
- [ ] **Fairness**: No unfair advantages introduced

### Performance (Vision Pro)

- [ ] **Frame Rate**: Maintains 120 FPS target
- [ ] **Memory**: No memory leaks or excessive usage
- [ ] **Battery**: No excessive battery drain

### Networking

- [ ] **Latency**: Network changes don't increase latency
- [ ] **Bandwidth**: Bandwidth usage is reasonable
- [ ] **Synchronization**: Multiplayer state stays synced
- [ ] **Security**: No security vulnerabilities

### visionOS Specific

- [ ] **Hand Tracking**: Hand gestures work reliably
- [ ] **Eye Tracking**: Eye tracking accurate if used
- [ ] **Spatial Audio**: Audio positioning correct
- [ ] **Room Mapping**: ARKit integration stable

## Security

- [ ] **Input Validation**: User input is validated
- [ ] **Secrets**: No hardcoded secrets or API keys
- [ ] **Authentication**: Authentication/authorization correct
- [ ] **Data Privacy**: User data handled appropriately

## UI/UX (if applicable)

- [ ] **Consistency**: Follows existing UI patterns
- [ ] **Accessibility**: Accessible to all users
- [ ] **Responsiveness**: UI responds quickly to input
- [ ] **Error States**: Errors handled gracefully
- [ ] **Loading States**: Loading indicators where appropriate

## Documentation

- [ ] **README**: Updated if necessary
- [ ] **CHANGELOG**: Updated with changes
- [ ] **API Docs**: Public APIs documented
- [ ] **Comments**: Code comments updated
- [ ] **Migration Guide**: Breaking changes documented

## Git

- [ ] **Commits**: Commits are logical and well-described
- [ ] **Commit Messages**: Follow conventional commits format
- [ ] **Branch**: Based on correct branch (develop/main)
- [ ] **Conflicts**: No merge conflicts
- [ ] **History**: Clean git history (squashed if appropriate)

## CI/CD

- [ ] **Build**: Builds successfully
- [ ] **Tests**: All tests pass
- [ ] **Linting**: SwiftLint passes
- [ ] **Coverage**: Code coverage maintained or improved

## Review Process

### For Reviewers

1. **Read Description**: Understand what the PR does
2. **Check Tests**: Run tests locally if needed
3. **Review Code**: Check for issues above
4. **Test Manually**: Test on Vision Pro if applicable
5. **Provide Feedback**: Clear, constructive comments
6. **Approve or Request Changes**: Make decision

### For Authors

1. **Self-Review**: Review your own PR first
2. **Address Feedback**: Respond to all comments
3. **Update Tests**: Add tests for edge cases found
4. **Clean History**: Squash commits if needed
5. **Request Re-Review**: After addressing feedback

## Common Issues

### ❌ Anti-Patterns to Watch For

```swift
// Force unwrapping without safety check
let player = players[id]!

// Force casting
let view = subview as! CustomView

// Print statements (use proper logging)
print("Debug info")

// Magic numbers
if player.health < 37.5 { }

// Nested if statements (use guard)
if let a = optionalA {
    if let b = optionalB {
        // Use guard instead
    }
}

// Retain cycles
class Manager {
    var closure: (() -> Void)?

    func setup() {
        closure = {
            self.doSomething()  // Retain cycle!
        }
    }
}
```

### ✅ Preferred Patterns

```swift
// Safe unwrapping
guard let player = players[id] else {
    return
}

// Safe casting
guard let view = subview as? CustomView else {
    return
}

// Proper logging
logger.debug("Debug info")

// Named constants
private let healthThreshold = 37.5
if player.health < healthThreshold { }

// Guard for early return
guard let a = optionalA,
      let b = optionalB else {
    return
}

// Weak self in closures
class Manager {
    var closure: (() -> Void)?

    func setup() {
        closure = { [weak self] in
            self?.doSomething()
        }
    }
}
```

## Approval Criteria

### Minimum Requirements

- ✅ Builds without errors or warnings
- ✅ All tests pass
- ✅ SwiftLint passes
- ✅ Code coverage maintained (≥80%)
- ✅ No force unwrapping without safety checks
- ✅ No obvious security issues
- ✅ Documentation updated

### Quality Bar

- ✅ Follows coding standards
- ✅ Well-tested with edge cases
- ✅ Performance considered
- ✅ Clear and maintainable
- ✅ Proper error handling

## Feedback Guidelines

### Effective Feedback

```markdown
**Good**:
"This could cause a retain cycle. Consider using [weak self] in the closure."

**Better**:
"This could cause a retain cycle because the closure captures self strongly.
Consider using [weak self]:

```swift
closure = { [weak self] in
    self?.doSomething()
}
```

See: [Memory Management Guide](link)"
```

### Types of Comments

- **Blocking**: Must be addressed before merge
- **Non-Blocking**: Suggestions for improvement
- **Nitpick**: Minor style issues
- **Question**: Asking for clarification

Tag comments appropriately:
- `[BLOCKING]` Must fix
- `[SUGGESTION]` Nice to have
- `[NITPICK]` Minor issue
- `[QUESTION]` Need clarification

## Resources

- [CODING_STANDARDS.md](CODING_STANDARDS.md)
- [CONTRIBUTING.md](CONTRIBUTING.md)
- [Swift API Guidelines](https://www.swift.org/documentation/api-design-guidelines/)

## Questions?

If unsure about something, ask in the PR comments or reach out to maintainers.
