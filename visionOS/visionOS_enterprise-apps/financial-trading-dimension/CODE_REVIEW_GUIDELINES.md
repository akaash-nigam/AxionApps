# Code Review Guidelines

## Purpose

Code reviews ensure code quality, share knowledge, and maintain consistency across the Financial Trading Dimension codebase.

---

## Review Checklist

### Before Requesting Review

**Author Responsibilities:**

- [ ] Code compiles without errors or warnings
- [ ] All tests pass locally
- [ ] SwiftLint violations resolved
- [ ] Self-review completed
- [ ] PR description is clear and complete
- [ ] Related issues linked
- [ ] Documentation updated
- [ ] Screenshots/videos included (for UI changes)

### During Review

**Reviewer Responsibilities:**

- [ ] Respond within 24 hours (business days)
- [ ] Be constructive and respectful
- [ ] Test the changes locally (when possible)
- [ ] Check for security issues
- [ ] Verify accessibility considerations
- [ ] Review test coverage

---

## What to Review

### 1. Functionality

**Does the code work?**
- [ ] Implements requirements correctly
- [ ] Handles edge cases
- [ ] No obvious bugs
- [ ] Error handling is appropriate

### 2. Code Quality

**Is the code clean and maintainable?**
- [ ] Follows Swift style guide
- [ ] Names are clear and descriptive
- [ ] Functions are focused and small
- [ ] No duplicated code
- [ ] Appropriate comments
- [ ] No TODO/FIXME without tickets

### 3. Architecture

**Does it fit the design?**
- [ ] Follows MVVM pattern
- [ ] Proper separation of concerns
- [ ] No circular dependencies
- [ ] Appropriate abstraction level
- [ ] Consistent with existing patterns

### 4. Testing

**Is it well tested?**
- [ ] New functionality has tests
- [ ] Tests are meaningful
- [ ] Edge cases covered
- [ ] Test names are descriptive
- [ ] No flaky tests introduced

### 5. Security

**Is it secure?**
- [ ] No hardcoded secrets
- [ ] Input validation present
- [ ] No SQL injection risks
- [ ] Authentication checked
- [ ] Authorization verified
- [ ] Sensitive data protected

### 6. Performance

**Is it efficient?**
- [ ] No obvious performance issues
- [ ] Async operations used appropriately
- [ ] No memory leaks
- [ ] Efficient algorithms
- [ ] Database queries optimized

### 7. Accessibility

**Is it accessible?**
- [ ] VoiceOver labels present
- [ ] Dynamic Type supported
- [ ] Color contrast sufficient
- [ ] Gestures have alternatives
- [ ] Reduce Motion respected

---

## Review Process

### 1. Initial Review (First Pass)

**Quick scan (5-10 minutes):**
- Read PR description
- Check diff size (if >500 lines, suggest splitting)
- Verify tests pass
- Look for obvious issues

### 2. Detailed Review (Deep Dive)

**Thorough examination:**
- Review code file by file
- Check logic and edge cases
- Verify test coverage
- Look for security issues
- Consider maintainability

### 3. Testing (If Applicable)

**Hands-on verification:**
- Pull branch locally
- Build and run
- Test functionality
- Try edge cases
- Verify on device (if available)

### 4. Feedback

**Provide clear, actionable feedback:**
- Be specific
- Explain reasoning
- Suggest alternatives
- Separate blocking vs. non-blocking
- Praise good work

---

## Feedback Guidelines

### Types of Comments

**🔴 Blocking (Must Fix)**
```
🔴 Security issue: API key is hardcoded
This exposes credentials. Move to environment variables.
```

**🟡 Non-Blocking (Should Fix)**
```
🟡 Suggestion: Extract this into a separate function
This would improve readability and testability.
```

**💡 Nitpick (Optional)**
```
💡 Nitpick: Consider using guard instead of if-return
Either way works, but guard is more conventional here.
```

**✅ Praise (Always Appreciated)**
```
✅ Nice solution! This is much cleaner than the previous approach.
```

### Writing Good Comments

**❌ Bad:**
```
This is wrong.
```

**✅ Good:**
```
🔴 This could cause a crash if marketData is nil.
Consider using optional binding:
if let data = marketData { ... }
```

**❌ Bad:**
```
Why did you do it this way?
```

**✅ Good:**
```
🟡 Have you considered using a computed property instead?
It might be cleaner:
var totalValue: Decimal { positions.reduce(0) { $0 + $1.value } }
```

---

## Common Issues to Look For

### Security

```swift
// ❌ Bad: Hardcoded API key
let apiKey = "sk_live_abc123"

// ✅ Good: Use environment
let apiKey = ProcessInfo.processInfo.environment["API_KEY"]

// ❌ Bad: Force unwrap
let price = quote.price!

// ✅ Good: Safe unwrap
guard let price = quote.price else { return }

// ❌ Bad: SQL concatenation
let query = "SELECT * FROM orders WHERE id = \(orderId)"

// ✅ Good: Parameterized
let query = "SELECT * FROM orders WHERE id = ?"
```

### Performance

```swift
// ❌ Bad: Synchronous on main thread
let data = loadLargeDataset()

// ✅ Good: Async off main thread
Task {
    let data = await loadLargeDataset()
    await MainActor.run {
        updateUI(with: data)
    }
}

// ❌ Bad: N+1 query
for order in orders {
    let price = fetchPrice(for: order.symbol)
}

// ✅ Good: Batch fetch
let symbols = orders.map { $0.symbol }
let prices = fetchPrices(for: symbols)
```

### Code Quality

```swift
// ❌ Bad: Unclear naming
func calc(a: Decimal, b: Decimal) -> Decimal

// ✅ Good: Descriptive naming
func calculateUnrealizedPnL(
    currentPrice: Decimal,
    averageCost: Decimal
) -> Decimal

// ❌ Bad: Magic numbers
if quantity > 10000 { ... }

// ✅ Good: Named constants
private let maximumOrderQuantity = 10_000
if quantity > maximumOrderQuantity { ... }
```

---

## Review Etiquette

### As a Reviewer

**Do:**
- ✅ Be kind and constructive
- ✅ Ask questions instead of demanding
- ✅ Explain your reasoning
- ✅ Acknowledge good work
- ✅ Suggest improvements
- ✅ Link to documentation
- ✅ Respond promptly

**Don't:**
- ❌ Be dismissive or rude
- ❌ Nitpick excessively
- ❌ Demand your exact solution
- ❌ Ignore the PR
- ❌ Approve without reviewing
- ❌ Block on personal preference
- ❌ Make it personal

### As an Author

**Do:**
- ✅ Respond to all comments
- ✅ Ask for clarification
- ✅ Accept feedback gracefully
- ✅ Explain your decisions
- ✅ Thank reviewers
- ✅ Make requested changes
- ✅ Re-request review after changes

**Don't:**
- ❌ Take feedback personally
- ❌ Argue defensively
- ❌ Ignore feedback
- ❌ Merge without approval
- ❌ Mark as resolved without fixing
- ❌ Push back on everything

---

## Review Priorities

### Critical Issues (Must Fix)

1. **Security vulnerabilities**
2. **Data corruption risks**
3. **Crash-causing bugs**
4. **Breaking changes**
5. **Privacy violations**

### High Priority (Should Fix)

1. **Incorrect functionality**
2. **Poor error handling**
3. **Missing tests**
4. **Performance issues**
5. **Accessibility problems**

### Medium Priority (Nice to Fix)

1. **Code duplication**
2. **Unclear naming**
3. **Missing documentation**
4. **Style inconsistencies**
5. **Minor optimizations**

### Low Priority (Optional)

1. **Personal preferences**
2. **Alternative approaches**
3. **Future improvements**
4. **Cosmetic changes**

---

## Special Considerations

### Financial Trading Code

**Extra scrutiny for:**
- Order execution logic
- P&L calculations
- Price handling (use Decimal!)
- Risk calculations
- Compliance checks

```swift
// ❌ NEVER use Float/Double for money
var price: Double = 189.99

// ✅ ALWAYS use Decimal
var price: Decimal = 189.99
```

### visionOS Spatial Computing

**Check for:**
- 3D performance (90 FPS target)
- Memory usage in RealityKit
- Gesture handling
- Eye tracking privacy
- Comfort considerations

### Async/Await

**Verify:**
- Proper async propagation
- @MainActor for UI updates
- Task cancellation handled
- No deadlocks
- Structured concurrency

---

## Review Time Guidelines

### By PR Size

| Lines Changed | Expected Review Time |
|---------------|---------------------|
| < 50 lines    | 10-15 minutes       |
| 50-200 lines  | 20-30 minutes       |
| 200-500 lines | 45-60 minutes       |
| 500+ lines    | 60+ minutes or split|

### Response Time

- **Initial response**: Within 24 hours
- **Follow-up**: Within 24 hours
- **Urgent PRs**: Within 4 hours
- **Hot fixes**: ASAP

---

## Approval Process

### Approval Requirements

- [ ] At least 1 approval from maintainer
- [ ] All CI checks pass
- [ ] All conversations resolved
- [ ] No merge conflicts
- [ ] Branch up to date with main

### Who Can Approve

**Levels:**
- Junior developer: Can comment, cannot approve
- Senior developer: Can approve non-critical PRs
- Tech lead: Can approve all PRs
- Architect: Required for architecture changes

### Self-Approval

**Never self-approve except:**
- Documentation-only changes
- Automated dependency updates
- Emergency hot fixes (with post-review)

---

## Common Scenarios

### Disagreement on Approach

1. Author explains their reasoning
2. Reviewer explains concerns
3. Discuss alternatives
4. Escalate to tech lead if needed
5. Document decision in ADR

### Large PR

1. Suggest splitting if possible
2. Review in multiple sessions
3. Focus on critical parts first
4. Consider pair reviewing

### Urgent Hot Fix

1. Minimal review for critical issue
2. Focus on correctness and security
3. Full review can happen post-merge
4. Create follow-up ticket for improvements

---

## Tools & Resources

### Review Tools

- **GitHub Review Interface**: Primary tool
- **Xcode**: For local testing
- **Instruments**: For performance review
- **Accessibility Inspector**: For a11y review

### Helpful Commands

```bash
# Checkout PR locally
gh pr checkout 123

# Review diff
git diff main...feature-branch

# Run tests
xcodebuild test -scheme FinancialTradingDimension

# Check coverage
xcodebuild test -enableCodeCoverage YES
```

---

## Templates

### Approval Comment

```
✅ LGTM!

Great work on implementing the correlation volume. The 3D positioning
algorithm is elegant and efficient.

Minor suggestions:
- Consider extracting magic numbers to constants
- Add doc comments for public methods

Non-blocking - feel free to merge after CI passes.
```

### Request Changes Comment

```
Requesting changes for the following issues:

🔴 Blocking:
1. Line 45: Potential null pointer crash
2. Line 78: Hardcoded API key

🟡 Non-blocking:
3. Line 102: Consider extracting to helper function
4. Line 156: Missing error handling

Please address the blocking issues. Happy to re-review once updated!
```

---

## Metrics

### Review Quality

Track:
- Time to first review
- Time to merge
- Bugs found in review
- Bugs found in production
- Review comment count
- Approval rate

### Goals

- < 24h to first review
- < 48h to merge (non-urgent)
- < 1% bug escape rate
- 3-5 comments per 100 LOC
- 90%+ approval rate

---

**Remember: Code reviews are about improving code and sharing knowledge, not finding fault. Be kind, be thorough, and always assume positive intent.**

---

**Last Updated**: 2025-11-17
**Version**: 1.0
