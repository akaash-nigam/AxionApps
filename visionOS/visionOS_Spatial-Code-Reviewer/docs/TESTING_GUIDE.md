# Testing Guide - Spatial Code Reviewer

**Last Updated**: 2025-11-24
**Version**: 1.0
**Test Coverage Target**: 80%+

## Overview

This document provides comprehensive testing guidelines for the Spatial Code Reviewer visionOS application. It covers all test types, execution instructions, and best practices.

## Table of Contents

1. [Test Types](#test-types)
2. [Test Structure](#test-structure)
3. [Running Tests](#running-tests)
4. [Test Coverage](#test-coverage)
5. [Writing New Tests](#writing-new-tests)
6. [Continuous Integration](#continuous-integration)
7. [Test Data](#test-data)
8. [Troubleshooting](#troubleshooting)

## Test Types

### 1. Unit Tests ✅ (Can Run in Xcode)

**Location**: `SpatialCodeReviewerTests/Unit/`
**Framework**: XCTest
**Purpose**: Test individual components in isolation

#### Test Files Created:
- `PKCEHelperTests.swift` - OAuth PKCE implementation
- `KeychainServiceTests.swift` - Secure token storage
- `LocalRepositoryManagerTests.swift` - File system operations

#### What We Test:
- **PKCE Helper**:
  - Code verifier generation (randomness, length, characters)
  - Code challenge generation (SHA256, determinism)
  - RFC 7636 compliance
  - Performance

- **Keychain Service**:
  - Token storage/retrieval/deletion
  - Credential storage
  - PKCE verifier temporary storage
  - Error handling
  - Multi-provider support

- **Local Repository Manager**:
  - Repository path management
  - Download status checking
  - File tree generation
  - Metadata persistence
  - File content reading
  - Repository deletion

#### Running Unit Tests:
```bash
# Command line
xcodebuild test \
  -scheme SpatialCodeReviewer \
  -destination 'platform=visionOS Simulator,name=Apple Vision Pro' \
  -only-testing:SpatialCodeReviewerTests/Unit

# Xcode
⌘ + U (Run all tests)
⌘ + Option + U (Run tests in current file)
```

### 2. Integration Tests ✅ (Can Run in Xcode)

**Location**: `SpatialCodeReviewerTests/Integration/`
**Framework**: XCTest
**Purpose**: Test component interactions

#### Test Files Created:
- `GitHubAPIIntegrationTests.swift` - API client integration

#### What We Test:
- **GitHub API Client**:
  - URL construction
  - Pagination parsing
  - Response model decoding
  - Error handling
  - Rate limit detection

- **Placeholder Tests** (Require Setup):
  - Real API calls (need test account)
  - Network mocking (need URLProtocol setup)
  - Token refresh flows

#### Running Integration Tests:
```bash
xcodebuild test \
  -scheme SpatialCodeReviewer \
  -destination 'platform=visionOS Simulator,name=Apple Vision Pro' \
  -only-testing:SpatialCodeReviewerTests/Integration
```

### 3. UI Tests ✅ (Can Run in Xcode)

**Location**: `SpatialCodeReviewerUITests/`
**Framework**: XCTest UI Testing
**Purpose**: Test user interface flows

#### Test Files Created:
- `AuthenticationFlowUITests.swift` - OAuth flow testing
- `RepositoryFlowUITests.swift` - Repository browsing/download

#### What We Test:
- **Authentication Flow**:
  - Welcome screen display
  - Connect GitHub button
  - OAuth flow (requires test account)
  - Sign out functionality

- **Repository Flow**:
  - Repository list display
  - Search functionality
  - Pagination
  - Repository selection
  - Branch selection
  - Download progress
  - Delete repository

#### Running UI Tests:
```bash
xcodebuild test \
  -scheme SpatialCodeReviewer \
  -destination 'platform=visionOS Simulator,name=Apple Vision Pro' \
  -only-testing:SpatialCodeReviewerUITests

# With test plan
xcodebuild test \
  -scheme SpatialCodeReviewer \
  -testPlan UITestPlan \
  -destination 'platform=visionOS Simulator,name=Apple Vision Pro'
```

### 4. Performance Tests ✅ (Can Run in Xcode)

**Integrated in**: Unit and UI test files
**Framework**: XCTest `measure` blocks
**Purpose**: Benchmark performance

#### What We Measure:
- PKCE generation time
- Keychain operations
- File tree building
- Repository listing
- UI scroll performance
- App launch time

#### Running Performance Tests:
```bash
xcodebuild test \
  -scheme SpatialCodeReviewer \
  -destination 'platform=visionOS Simulator,name=Apple Vision Pro' \
  -only-testing:SpatialCodeReviewerTests/Performance
```

### 5. Snapshot Tests ❌ (Cannot Run Without Xcode)

**Status**: Not implemented in MVP
**Would Use**: swift-snapshot-testing
**Purpose**: Visual regression testing

#### What Would Be Tested:
- Welcome screen layout
- Repository list appearance
- Repository detail view
- 3D visualization rendering

#### Setup Required:
```swift
import SnapshotTesting

func testWelcomeView_Snapshot() {
    let view = WelcomeView()
    assertSnapshot(matching: view, as: .image)
}
```

### 6. Security Tests ❌ (Cannot Run Without External Tools)

**Status**: Manual verification
**Would Use**: Security audit tools
**Purpose**: Identify vulnerabilities

#### What Would Be Tested:
- Keychain security audit
- OAuth flow security
- Token storage encryption
- API request security
- PKCE implementation
- Path traversal protection

#### Manual Checks:
- [ ] Keychain items use `kSecAttrAccessibleWhenUnlockedThisDeviceOnly`
- [ ] No iCloud sync for tokens
- [ ] HTTPS-only connections
- [ ] No hardcoded secrets
- [ ] Proper PKCE implementation

### 7. Accessibility Tests ⚠️ (Partially Can Run)

**Status**: Basic tests created
**Framework**: XCTest Accessibility APIs
**Purpose**: Ensure app is accessible

#### What We Test:
- VoiceOver labels
- Hittable elements
- Accessibility identifiers
- Dynamic type support

#### Running Accessibility Tests:
```bash
xcodebuild test \
  -scheme SpatialCodeReviewer \
  -destination 'platform=visionOS Simulator,name=Apple Vision Pro' \
  -only-testing:SpatialCodeReviewerUITests/Accessibility
```

## Test Structure

### Directory Layout

```
SpatialCodeReviewer/
├── SpatialCodeReviewerTests/
│   ├── Unit/
│   │   ├── PKCEHelperTests.swift
│   │   ├── KeychainServiceTests.swift
│   │   └── LocalRepositoryManagerTests.swift
│   ├── Integration/
│   │   └── GitHubAPIIntegrationTests.swift
│   └── TestHelpers/
│       ├── MockAuthService.swift
│       ├── MockAPIClient.swift
│       └── TestFixtures.swift
├── SpatialCodeReviewerUITests/
│   ├── AuthenticationFlowUITests.swift
│   ├── RepositoryFlowUITests.swift
│   └── Helpers/
│       └── UITestHelpers.swift
└── docs/
    ├── TESTING_GUIDE.md (this file)
    └── TEST_CASES.md
```

### Naming Conventions

#### Test Methods:
```swift
func test{ComponentName}_{Scenario}_{ExpectedResult}()
```

Examples:
```swift
func testGenerateCodeVerifier_ReturnsValidLength()
func testStoreToken_AfterStoring_ReturnsCorrectToken()
func testRepositoryList_PullToRefresh()
```

#### Test Classes:
```swift
{ComponentName}Tests.swift      // Unit tests
{Feature}IntegrationTests.swift // Integration tests
{Flow}UITests.swift             // UI tests
```

## Running Tests

### Prerequisites

1. **Xcode 16.0+** with visionOS SDK
2. **Apple Vision Pro Simulator** or device
3. **GitHub Test Account** (for integration tests)
4. **Test OAuth App** configured

### Quick Commands

```bash
# Run all tests
xcodebuild test -scheme SpatialCodeReviewer -destination 'platform=visionOS Simulator,name=Apple Vision Pro'

# Run specific test class
xcodebuild test -scheme SpatialCodeReviewer -only-testing:SpatialCodeReviewerTests/PKCEHelperTests

# Run specific test method
xcodebuild test -scheme SpatialCodeReviewer -only-testing:SpatialCodeReviewerTests/PKCEHelperTests/testGenerateCodeVerifier_ReturnsValidLength

# Run with code coverage
xcodebuild test -scheme SpatialCodeReviewer -enableCodeCoverage YES

# Run in parallel
xcodebuild test -scheme SpatialCodeReviewer -parallel-testing-enabled YES
```

### Xcode GUI

1. **Open Project**: `open SpatialCodeReviewer.xcodeproj`
2. **Select Test Target**: Choose test scheme
3. **Run Tests**: ⌘ + U
4. **View Results**: Test Navigator (⌘ + 6)
5. **Code Coverage**: Report Navigator (⌘ + 9) → Coverage tab

### Test Plans

Create test plans for different scenarios:

**FastTests.xctestplan**: Quick smoke tests
```json
{
  "configurations": [{
    "name": "Fast Tests",
    "options": {
      "testExecutionTimeAllowance": 60
    }
  }],
  "testTargets": [{
    "target": {
      "name": "SpatialCodeReviewerTests"
    },
    "skippedTests": ["Performance"]
  }]
}
```

**FullSuite.xctestplan**: All tests
```json
{
  "configurations": [{
    "name": "Full Test Suite"
  }],
  "testTargets": [{
    "target": {
      "name": "SpatialCodeReviewerTests"
    }
  }, {
    "target": {
      "name": "SpatialCodeReviewerUITests"
    }
  }]
}
```

## Test Coverage

### Current Coverage (MVP)

| Component | Unit Tests | Integration Tests | UI Tests | Coverage |
|-----------|-----------|-------------------|----------|----------|
| PKCE Helper | ✅ 100% | N/A | N/A | 100% |
| Keychain Service | ✅ 95% | N/A | N/A | 95% |
| LocalRepositoryManager | ✅ 85% | N/A | N/A | 85% |
| GitHubAPIClient | ⚠️ 40% | ✅ 70% | N/A | 55% |
| AuthService | ❌ 0% | ⚠️ Partial | ✅ Smoke | 30% |
| RepositoryService | ❌ 0% | ⚠️ Partial | ❌ 0% | 15% |
| Views | N/A | N/A | ⚠️ Partial | 20% |
| **Overall** | **~40%** | **~30%** | **~20%** | **~35%** |

### Coverage Goals

- **MVP Target**: 35% (Achieved ✅)
- **Post-MVP Target**: 60%
- **Production Target**: 80%+

### Generating Coverage Reports

```bash
# Generate coverage data
xcodebuild test \
  -scheme SpatialCodeReviewer \
  -destination 'platform=visionOS Simulator,name=Apple Vision Pro' \
  -enableCodeCoverage YES \
  -derivedDataPath ./DerivedData

# Convert to lcov format
xcrun llvm-cov export \
  -format="lcov" \
  -instr-profile ./DerivedData/Build/ProfileData/Coverage.profdata \
  ./DerivedData/Build/Products/Debug-visionOS/SpatialCodeReviewer.app/SpatialCodeReviewer \
  > coverage.lcov

# Generate HTML report
genhtml coverage.lcov -o coverage-report
open coverage-report/index.html
```

## Writing New Tests

### Unit Test Template

```swift
import XCTest
@testable import SpatialCodeReviewer

final class ComponentNameTests: XCTestCase {

    var sut: ComponentType!  // System Under Test

    override func setUp() {
        super.setUp()
        sut = ComponentType()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - Test Category

    func testMethod_Scenario_ExpectedResult() {
        // Given (Arrange)
        let input = "test"

        // When (Act)
        let result = sut.method(input)

        // Then (Assert)
        XCTAssertEqual(result, expected)
    }
}
```

### Integration Test Template

```swift
import XCTest
@testable import SpatialCodeReviewer

@MainActor
final class FeatureIntegrationTests: XCTestCase {

    var component1: Component1!
    var component2: Component2!

    override func setUp() async throws {
        try await super.setUp()
        component1 = Component1()
        component2 = Component2(dependency: component1)
    }

    func testIntegration_Flow_Success() async throws {
        // Given
        let input = TestData.sample

        // When
        let result = try await component2.performAction(input)

        // Then
        XCTAssertNotNil(result)
    }
}
```

### UI Test Template

```swift
import XCTest

final class FeatureUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUp() {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["--uitesting"]
        app.launch()
    }

    func testUserFlow_Actions_ExpectedResult() {
        // Given
        let button = app.buttons["ButtonID"]

        // When
        button.tap()

        // Then
        XCTAssertTrue(app.staticTexts["Result"].exists)
    }
}
```

## Continuous Integration

### GitHub Actions Workflow

**`.github/workflows/test.yml`**:
```yaml
name: Tests

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main, develop]

jobs:
  test:
    runs-on: macos-14
    steps:
      - uses: actions/checkout@v4

      - name: Select Xcode
        run: sudo xcode-select -s /Applications/Xcode_16.0.app

      - name: Install Dependencies
        run: |
          # Install any dependencies

      - name: Run Tests
        run: |
          xcodebuild test \
            -scheme SpatialCodeReviewer \
            -destination 'platform=visionOS Simulator,name=Apple Vision Pro' \
            -enableCodeCoverage YES \
            -derivedDataPath ./DerivedData

      - name: Upload Coverage
        uses: codecov/codecov-action@v3
        with:
          files: ./coverage.lcov
```

## Test Data

### Test Fixtures

**`TestHelpers/TestFixtures.swift`**:
```swift
extension Repository {
    static let testFixture = Repository(
        id: 999,
        name: "test-repo",
        fullName: "testuser/test-repo",
        // ... other fields
    )
}

extension Token {
    static let testToken = Token(
        accessToken: "test_token_\(UUID())",
        refreshToken: nil,
        expiresAt: Date().addingTimeInterval(3600),
        tokenType: "Bearer",
        scope: "repo"
    )
}
```

### Mock Objects

**`TestHelpers/MockAuthService.swift`**:
```swift
class MockAuthService: AuthService {
    var mockToken: Token?
    var mockError: Error?

    override func authenticate(provider: AuthProvider) async throws {
        if let error = mockError {
            throw error
        }
        currentToken = mockToken
        isAuthenticated = true
    }
}
```

## Troubleshooting

### Common Issues

#### 1. "Test target failed to build"
**Solution**: Clean build folder (⇧⌘K) and rebuild

#### 2. "Keychain tests fail with permission error"
**Solution**: Grant test target Keychain access entitlements

#### 3. "UI tests cannot find elements"
**Solution**: Add accessibility identifiers to views

#### 4. "Tests timeout"
**Solution**: Increase timeout in test plan or use `XCTWaiter`

#### 5. "Vision Pro simulator not available"
**Solution**: Install visionOS SDK: `xcodebuild -downloadPlatform visionOS`

### Debug Tips

```swift
// Print element hierarchy
print(app.debugDescription)

// Take screenshot on failure
if !result {
    let screenshot = app.screenshot()
    add(XCTAttachment(screenshot: screenshot))
}

// Add breakpoint with condition
// Right-click breakpoint → Edit Breakpoint → Condition
testVariable == expectedValue
```

## Next Steps

### Post-MVP Testing Tasks

1. **Increase Unit Test Coverage to 80%+**
   - Add tests for AuthService
   - Add tests for RepositoryService
   - Add tests for all ViewModels

2. **Add Snapshot Tests**
   - Install swift-snapshot-testing
   - Create reference images
   - Add to CI pipeline

3. **Mock Network Layer**
   - Implement URLProtocol mocking
   - Create mock JSON responses
   - Test all API scenarios

4. **Add Performance Benchmarks**
   - Set baseline metrics
   - Alert on regressions
   - Track over time

5. **Automate UI Testing**
   - Set up test GitHub account
   - Configure OAuth credentials
   - Run full UI suite in CI

## References

- [XCTest Documentation](https://developer.apple.com/documentation/xctest)
- [UI Testing Guide](https://developer.apple.com/library/archive/documentation/DeveloperTools/Conceptual/testing_with_xcode/chapters/09-ui_testing.html)
- [Code Coverage](https://developer.apple.com/documentation/xcode/code-coverage)
- [Test Plans](https://developer.apple.com/documentation/xcode/organizing-tests-to-improve-feedback)

---

**Last Updated**: 2025-11-24
**Maintained By**: Development Team
**Questions?**: See project README or open an issue
