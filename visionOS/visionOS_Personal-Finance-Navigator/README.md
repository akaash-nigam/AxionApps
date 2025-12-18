# Personal Finance Navigator

> Visual personal finance management for Apple Vision Pro — Experience your money in spatial computing

[![Platform](https://img.shields.io/badge/Platform-visionOS%202.0%2B-blue)](https://developer.apple.com/visionos/)
[![Swift](https://img.shields.io/badge/Swift-6.0-orange)](https://swift.org)
[![License](https://img.shields.io/badge/License-MIT-green)](LICENSE)

## 🌟 Overview

Personal Finance Navigator transforms money management by visualizing income and expenses as flowing streams through 3D space, budget boundaries as actual walls, investment growth as growing structures, and upcoming bills as floating reminders in calendar space. Built specifically for Apple Vision Pro, it leverages spatial computing to make financial data intuitive and engaging.

## ✨ Key Features

### 💰 Core Financial Management
- **Smart Budgeting** - Create budgets using proven strategies (50/30/20, Zero-Based, Envelope Method)
- **Transaction Tracking** - Automatic categorization and manual transaction management
- **Account Management** - Track multiple accounts with real-time balance updates
- **Category Management** - Flexible categorization with customizable categories

### 📊 Visualization & Analytics
- **3D Money Flow** - Watch your spending flow through categories in immersive 3D
- **Dashboard Overview** - Comprehensive financial snapshot with net worth tracking
- **Budget Progress** - Real-time progress tracking with smart alerts at 75%, 90%, and 100%
- **Transaction Analytics** - Search, filter, and analyze spending patterns

### 🔐 Security & Privacy
- **Biometric Authentication** - Face ID / Optic ID protection
- **AES-256-GCM Encryption** - Bank-level data encryption
- **Auto-Lock** - Configurable timeout (1-15 minutes)
- **Privacy First** - No tracking, no data selling, iCloud-only sync

### 🎨 User Experience
- **Guided Onboarding** - Step-by-step setup for first-time users
- **Spatial UI** - Native visionOS interface with depth and materials
- **Dark Mode** - Full support for light and dark appearance
- **Haptic Feedback** - Tactile responses for important actions

## 🚀 Getting Started

### Requirements

- **Hardware**: Apple Vision Pro
- **OS**: visionOS 2.0 or later
- **Xcode**: 16.0 or later
- **Swift**: 6.0 or later

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/visionOS_Personal-Finance-Navigator.git
   cd visionOS_Personal-Finance-Navigator
   ```

2. **Open in Xcode**
   ```bash
   open PersonalFinanceNavigator.xcodeproj
   ```

3. **Configure Dependencies**
   - Swift packages will be automatically resolved
   - No additional setup required for Core Data or RealityKit

4. **Set up Plaid (Optional)**
   - Create account at [Plaid Dashboard](https://dashboard.plaid.com)
   - Add your Plaid client ID and secret to `Config.swift`
   - For sandbox testing, use provided test credentials

5. **Build and Run**
   - Select Vision Pro Simulator or Device
   - Press ⌘R to build and run
   - Grant necessary permissions (biometric, notifications)

## 📱 Usage

### First Launch

1. **Onboarding** - Complete the guided setup:
   - Welcome screens introducing features
   - Privacy and security information
   - Optional bank account connection
   - Budget creation with income entry
   - Biometric authentication setup

2. **Dashboard** - Your financial hub:
   - Net worth overview with assets and liabilities
   - Budget status with circular progress
   - Current month spending vs. income
   - Recent transactions list
   - Quick action buttons

### Managing Accounts

- **Add Account**: Tap "Add Account" → Enter details (name, type, balance)
- **View Accounts**: Navigate to Accounts tab → See grouped accounts
- **Edit Account**: Swipe left → Edit → Update information
- **Delete Account**: Swipe left → Delete → Confirm

### Tracking Transactions

- **Manual Entry**: Dashboard → "Add Transaction" → Fill details
- **View All**: Transactions tab → See chronological list
- **Search**: Use search bar for merchant/amount
- **Filter**: Filter by category, date range, or account
- **Edit/Delete**: Swipe left on transaction

### Creating Budgets

- **New Budget**: Budgets tab → "+" button
- **Step 1**: Enter name, select strategy, set dates and income
- **Step 2**: Choose categories to budget
- **Step 3**: Allocate amounts (manual or auto-suggest)
- **Monitor**: View real-time progress and category breakdowns

### 3D Visualization

- **Access**: Navigate to "Flow" tab
- **Interact**:
  - Drag to rotate view
  - Pinch to zoom in/out
  - Tap info button for category breakdown
- **Refresh**: Pull to refresh with latest data

## 🏗️ Architecture

### Design Pattern: MVVM + Repository

```
┌─────────────────────────────────────────────────────┐
│                   Presentation Layer                 │
│  ┌──────────┐  ┌──────────┐  ┌─────────────────┐   │
│  │  Views   │←─│ViewModels│←─│ Coordinators    │   │
│  └──────────┘  └──────────┘  └─────────────────┘   │
└─────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────┐
│                   Domain Layer                       │
│  ┌──────────┐  ┌──────────┐  ┌─────────────────┐   │
│  │  Models  │  │ Use Cases│  │  Repositories   │   │
│  └──────────┘  └──────────┘  └─────────────────┘   │
└─────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────┐
│                     Data Layer                       │
│  ┌──────────┐  ┌──────────┐  ┌─────────────────┐   │
│  │Core Data │  │  Plaid   │  │    Keychain     │   │
│  └──────────┘  └──────────┘  └─────────────────┘   │
└─────────────────────────────────────────────────────┘
```

### Project Structure

```
src/
├── App/
│   ├── PersonalFinanceNavigatorApp.swift
│   └── DependencyContainer.swift
├── Presentation/
│   ├── ViewModels/
│   │   ├── DashboardViewModel.swift
│   │   ├── AccountViewModel.swift
│   │   ├── TransactionViewModel.swift
│   │   ├── BudgetViewModel.swift
│   │   └── MoneyFlowViewModel.swift
│   └── Views/
│       ├── Dashboard/
│       ├── Accounts/
│       ├── Transactions/
│       ├── Budgets/
│       ├── Visualization/
│       ├── Onboarding/
│       ├── Settings/
│       └── Authentication/
├── Domain/
│   ├── Models/
│   ├── Repositories/ (Protocols)
│   └── UseCases/
├── Data/
│   ├── CoreData/
│   │   ├── Entities/
│   │   └── Repositories/ (Implementations)
│   └── PlaidAPI/
├── Services/
│   ├── Security/
│   └── Authentication/
└── Utilities/
    ├── Security/
    └── Extensions/
```

### Key Technologies

- **SwiftUI** - Declarative UI framework
- **RealityKit** - 3D visualization and particle systems
- **Core Data** - Local persistence with CloudKit sync
- **Combine** - Reactive programming (minimal usage)
- **@Observable** - Swift's modern observation system
- **Actors** - Thread-safe security managers
- **async/await** - Modern concurrency

## 🧪 Testing

### Running Tests

```bash
# Run all tests
swift test

# Run specific test file
swift test --filter AccountViewModelTests

# Run with coverage
swift test --enable-code-coverage
```

### Test Coverage

- **Unit Tests**: 68 tests across ViewModels and Domain Models
- **Integration Tests**: Documented in TEST_GUIDE.md (requires Xcode)
- **UI Tests**: Documented in TEST_GUIDE.md (requires Xcode)

See [TEST_GUIDE.md](Tests/TEST_GUIDE.md) for comprehensive testing documentation.

## 📚 Documentation

- **[PRD.md](PRD.md)** - Complete Product Requirements Document
- **[ARCHITECTURE.md](docs/ARCHITECTURE.md)** - Detailed architecture guide
- **[API_DOCUMENTATION.md](docs/API_DOCUMENTATION.md)** - API reference
- **[CONTRIBUTING.md](CONTRIBUTING.md)** - Contribution guidelines
- **[CHANGELOG.md](CHANGELOG.md)** - Version history
- **[TEST_GUIDE.md](Tests/TEST_GUIDE.md)** - Testing guide

### Design Documents (in `docs/`)

- **technical-architecture.md** - System architecture
- **data-model-schema.md** - Database schema
- **api-integration.md** - Plaid and external API integration
- **security-privacy.md** - Security implementation
- **ui-ux-design-system.md** - Design system and guidelines
- **3d-visualization-spec.md** - RealityKit visualization specs
- **testing-strategy.md** - Testing approach
- **performance-optimization.md** - Performance guidelines

## 🎯 Roadmap

### ✅ MVP Complete (v1.0)
- [x] Core Data models and repositories
- [x] Account management
- [x] Transaction tracking
- [x] Budget creation and tracking
- [x] Dashboard overview
- [x] 3D money flow visualization
- [x] Onboarding flow
- [x] Security (biometric auth, encryption)
- [x] Comprehensive test suite

### 🚧 In Progress
- [ ] Plaid integration for bank connections
- [ ] CloudKit sync implementation
- [ ] Advanced 3D visualizations
- [ ] Category management UI

### 📋 Planned Features (v1.1+)
- [ ] Investment tracking
- [ ] Debt payoff planning
- [ ] Savings goals
- [ ] Bill calendar and reminders
- [ ] Financial reports and exports
- [ ] Multiple budget support
- [ ] Recurring transaction detection
- [ ] Voice commands (Siri integration)
- [ ] Widgets for Quick Look
- [ ] Apple Watch companion app

## 🤝 Contributing

We welcome contributions! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

### Quick Start for Contributors

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/amazing-feature`
3. Make your changes
4. Write/update tests
5. Run tests: `swift test`
6. Commit: `git commit -m "Add amazing feature"`
7. Push: `git push origin feature/amazing-feature`
8. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **Apple** - visionOS, SwiftUI, RealityKit
- **Plaid** - Banking integration API
- **Swift Community** - Open source packages and support

## 📞 Support

- **Issues**: [GitHub Issues](https://github.com/yourusername/visionOS_Personal-Finance-Navigator/issues)
- **Discussions**: [GitHub Discussions](https://github.com/yourusername/visionOS_Personal-Finance-Navigator/discussions)
- **Email**: support@pfnavigator.app

## 📊 Project Stats

- **Language**: Swift 6.0
- **Lines of Code**: ~15,000+
- **Files**: 50+ Swift files
- **Tests**: 68 unit tests
- **Documentation**: 14 design documents

## 🌐 Links

- **Landing Page**: [View Demo](landing-page/index.html)
- **Product Demo**: Coming Soon
- **App Store**: Coming Soon

---

**Built with ❤️ for Apple Vision Pro**

*Transform your financial future in spatial computing*

---

## Tags

`visionOS` `spatial-computing` `personal-finance` `budgeting` `fintech` `vision-pro` `swiftui` `realitykit` `core-data` `swift6`
