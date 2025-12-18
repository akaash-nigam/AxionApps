# Xcode Project Setup Guide
# Personal Finance Navigator

**Version**: 1.0
**Date**: 2025-11-24
**Timeline**: Week 1, Day 1-2

## Prerequisites

Before starting, ensure you have:
- [ ] Mac with macOS 14.0+ (Sonoma or later)
- [ ] Xcode 15.2+ installed
- [ ] Apple Developer account
- [ ] visionOS SDK installed in Xcode

## Step 1: Create New Xcode Project

### 1.1 Open Xcode
```bash
# Launch Xcode from Applications or Spotlight
```

### 1.2 Create Project
1. Click "Create New Project" or File → New → Project
2. Select **visionOS** tab
3. Choose **App** template
4. Click **Next**

### 1.3 Project Configuration
Fill in the following:
- **Product Name**: `PersonalFinanceNavigator`
- **Team**: Select your Apple Developer team
- **Organization Identifier**: `com.yourcompany` (replace with your domain)
- **Bundle Identifier**: `com.yourcompany.PersonalFinanceNavigator`
- **Interface**: **SwiftUI**
- **Language**: **Swift**
- **Storage**: Check **Core Data**
- **Include Tests**: Check both boxes

### 1.4 Save Location
- Choose your workspace directory
- Ensure "Create Git repository" is **checked**
- Click **Create**

## Step 2: Initial Configuration

### 2.1 Update Project Settings

**General Tab**:
- iOS Deployment Target: Delete (visionOS only)
- visionOS Deployment Target: 2.0
- Supports: **visionOS**

**Signing & Capabilities**:
- Automatically manage signing: **Checked**
- Team: Your team
- Add Capabilities:
  - [ ] **iCloud** → CloudKit
  - [ ] **Background Modes** → Background fetch, Remote notifications
  - [ ] **Keychain Sharing**

**Build Settings**:
- Swift Language Version: **Swift 6**
- Enable Strict Concurrency Checking: **Complete**

### 2.2 Configure Swift Concurrency

Add to Build Settings:
```
SWIFT_STRICT_CONCURRENCY = complete
SWIFT_VERSION = 6.0
```

### 2.3 Update Info.plist

Add the following keys:
```xml
<key>NSFaceIDUsageDescription</key>
<string>We use Face ID to secure your financial data</string>

<key>NSUserTrackingUsageDescription</key>
<string>We use analytics to improve the app experience (no personal data collected)</string>

<key>NSPrivacyAccessedAPITypes</key>
<array>
    <dict>
        <key>NSPrivacyAccessedAPIType</key>
        <string>NSPrivacyAccessedAPICategoryUserDefaults</string>
        <key>NSPrivacyAccessedAPITypeReasons</key>
        <array>
            <string>CA92.1</string>
        </array>
    </dict>
</array>
```

## Step 3: Folder Structure

### 3.1 Delete Default Files
Delete these generated files (we'll replace them):
- `ContentView.swift` (will recreate)
- Keep `PersonalFinanceNavigatorApp.swift` (will modify)
- Keep `Persistence.swift` (will enhance)

### 3.2 Create Folder Structure

In Xcode's Project Navigator, right-click on `PersonalFinanceNavigator` folder and create **New Group** for each:

```
PersonalFinanceNavigator/
├── App/
│   ├── PersonalFinanceNavigatorApp.swift (already exists)
│   ├── AppCoordinator.swift (create)
│   └── DependencyContainer.swift (create)
├── Presentation/
│   ├── Views/
│   │   ├── Dashboard/
│   │   ├── Transactions/
│   │   ├── Budget/
│   │   ├── Settings/
│   │   ├── Onboarding/
│   │   └── Authentication/
│   ├── RealityViews/
│   └── Components/
│       └── Cards/
├── Domain/
│   ├── Models/
│   ├── ViewModels/
│   └── UseCases/
│       ├── Banking/
│       ├── Budget/
│       └── Transactions/
├── Services/
│   ├── Banking/
│   ├── Authentication/
│   └── Notifications/
├── Data/
│   ├── CoreData/
│   │   └── Entities/
│   ├── Repositories/
│   └── API/
├── Utilities/
│   ├── Extensions/
│   ├── Helpers/
│   ├── Security/
│   └── Constants/
└── Resources/
    └── Assets.xcassets (already exists)
```

**Important**: In Xcode, these are **Groups** (logical), not physical folders. They organize your files in Xcode's navigator.

## Step 4: Configure Core Data

### 4.1 Rename Data Model
1. Select `PersonalFinanceNavigator.xcdatamodeld` in Project Navigator
2. Show File Inspector (⌘⌥1)
3. Click name and rename to better organization if needed
4. Keep the default for now

### 4.2 Set Model Version
1. Select the .xcdatamodeld file
2. Editor → Add Model Version
3. Name it: `PersonalFinanceNavigator v1`
4. This allows for future migrations

## Step 5: Configure CloudKit

### 5.1 Create CloudKit Container
1. Open Signing & Capabilities
2. Click **+ Capability**
3. Add **iCloud**
4. Check **CloudKit**
5. Click **+** under CloudKit Containers
6. Name: `iCloud.com.yourcompany.PersonalFinanceNavigator`

### 5.2 Configure Container in Code
We'll do this in the PersistenceController (created next)

## Step 6: Git Configuration

### 6.1 Update .gitignore
The repository already has a .gitignore. Verify it contains:

```gitignore
# Xcode
xcuserdata/
*.xcworkspace/xcuserdata/
DerivedData/
*.xccheckout
*.moved-aside
*.xcuserstate
*.DS_Store

# Security (CRITICAL - Never commit these!)
Configuration.swift
Secrets.plist
*.pem
*.p12

# Build
Build/
build/

# CocoaPods
Pods/
*.podspec

# Swift Package Manager
.swiftpm/
.build/

# Temporary
*.swp
*~
```

### 6.2 Create Configuration Template

Create a file called `Configuration.swift.template`:
```swift
// Configuration.swift
// Copy this to Configuration.swift and fill in your values
// DO NOT commit Configuration.swift to git!

enum Configuration {
    // Plaid API (get from https://dashboard.plaid.com)
    static let plaidClientId = "YOUR_CLIENT_ID_HERE"
    static let plaidSecret = "YOUR_SECRET_HERE"
    static let plaidEnvironment = "sandbox" // or "development" or "production"

    // CloudKit
    static let cloudKitContainerIdentifier = "iCloud.com.yourcompany.PersonalFinanceNavigator"
}
```

## Step 7: Verify Setup

### 7.1 Build Project
1. Select a visionOS Simulator (or device if available)
2. Press ⌘B to build
3. Ensure no errors

### 7.2 Run Project
1. Press ⌘R to run
2. App should launch (will be default UI for now)

## Step 8: Initial Commit

```bash
cd /path/to/PersonalFinanceNavigator
git add .
git commit -m "Initial Xcode project setup for visionOS"
git branch -M main
```

## Checklist

Before proceeding to implementation, verify:

- [ ] Project builds without errors
- [ ] visionOS 2.0 set as minimum deployment target
- [ ] Swift 6 and strict concurrency enabled
- [ ] Core Data added
- [ ] CloudKit capability added
- [ ] Face ID permission added
- [ ] Folder structure created in Xcode
- [ ] .gitignore configured
- [ ] Initial commit made

## Next Steps

Once this setup is complete, you're ready to:
1. Implement Core Data entities
2. Create PersistenceController
3. Build security layer
4. Create initial views

---

## Troubleshooting

**Issue**: "visionOS SDK not found"
- **Fix**: Update to Xcode 15.2+, download visionOS SDK in Xcode Preferences → Platforms

**Issue**: "Cannot find 'CloudKit' in scope"
- **Fix**: Ensure CloudKit capability is added in Signing & Capabilities

**Issue**: "Thread 1: signal SIGABRT" on launch
- **Fix**: Check Core Data model syntax, verify container name matches

**Issue**: "Provisioning profile doesn't include the iCloud entitlement"
- **Fix**: Regenerate provisioning profile in Apple Developer portal

---

**Status**: Setup guide complete
**Next**: Start implementing Core Data entities and PersistenceController
