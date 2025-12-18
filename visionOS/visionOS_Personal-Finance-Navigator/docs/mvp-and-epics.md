# MVP & Epic Breakdown
# Personal Finance Navigator

**Version**: 1.0
**Last Updated**: 2025-11-24
**Status**: Implementation Ready

## Table of Contents
1. [MVP Definition](#mvp-definition)
2. [MVP User Flow](#mvp-user-flow)
3. [Epic Breakdown](#epic-breakdown)
4. [Post-MVP Features](#post-mvp-features)
5. [Release Planning](#release-planning)

## MVP Definition

### What is the MVP?

The **Minimum Viable Product** is the smallest version of Personal Finance Navigator that delivers core value: helping users visualize their money flow and stay within budget.

### MVP Success Criteria

- Users can connect 1 bank account
- Users can view their transactions
- Users can categorize expenses
- Users can create and track a monthly budget
- Users see a basic 3D money flow visualization
- Users receive budget alerts
- App is secure (biometric auth, encryption)

### What's NOT in MVP

❌ Investment tracking
❌ Debt payoff planning
❌ Savings goals
❌ Bill calendar
❌ Advanced 3D visualizations (trees, snowballs)
❌ Multiple accounts
❌ Family sharing
❌ Reports/exports
❌ Voice commands

### MVP Features (Must Have for v1.0)

#### ✅ Core Features

1. **User Onboarding**
   - Welcome screens
   - Bank account connection (Plaid)
   - Initial data sync
   - Biometric authentication setup

2. **Transaction Management**
   - View transaction list
   - Transaction details
   - Manual categorization
   - Transaction search/filter

3. **Budget Management**
   - Create monthly budget (50/30/20 rule)
   - View budget status per category
   - Budget progress visualization
   - Budget alerts (75%, 90%, 100%)

4. **Dashboard**
   - Total balance
   - This month's spending
   - Budget status overview
   - Recent transactions

5. **Money Flow Visualization (Basic)**
   - Simple particle flow showing expenses by category
   - Color-coded streams
   - Basic 3D view (not complex)

6. **Security**
   - Biometric authentication
   - Data encryption
   - Secure token storage

### MVP User Stories

```
As a user, I want to connect my bank account so I can see my transactions.
As a user, I want to categorize my transactions so I can understand my spending.
As a user, I want to create a budget so I can control my spending.
As a user, I want to see my budget status so I know if I'm overspending.
As a user, I want to receive alerts when approaching my budget limits.
As a user, I want to see my money flow visually so I understand where my money goes.
As a user, I want the app to be secure so my financial data is protected.
```

### MVP Out of Scope

These features are valuable but NOT required for initial launch:

- Multiple bank accounts
- Investment accounts
- Debt tracking
- Savings goals
- Bill reminders
- Advanced analytics
- Recurring transaction detection
- Export/reports
- Sharing/collaboration

---

## MVP User Flow

### First-Time User Journey

```
1. App Launch
   ↓
2. Welcome Screen
   "Visualize your finances in 3D"
   [Get Started]
   ↓
3. Bank Connection
   "Connect your bank account"
   [Connect with Plaid]
   ↓
4. Plaid Link UI
   - Select bank
   - Enter credentials
   - Select account
   ↓
5. Syncing Screen
   "Importing your transactions..."
   ↓
6. Budget Setup
   "Create your first budget"
   - Enter monthly income: $_____
   - Select strategy: [50/30/20 Rule]
   [Create Budget]
   ↓
7. Biometric Setup
   "Secure your financial data"
   [Enable Face ID]
   ↓
8. Dashboard
   ✓ Connected to Chase Checking
   ✓ 127 transactions imported
   ✓ Budget created: $5,000/month
```

### Returning User Journey

```
1. App Launch
   ↓
2. Biometric Auth
   "Unlock your financial data"
   [Face ID prompt]
   ↓
3. Dashboard
   - Balance: $5,432.10
   - Spent this month: $3,245 / $5,000 (65%)
   - Recent transactions (5)

   Tabs:
   [Dashboard] [Transactions] [Budget] [Flow]
```

---

## Epic Breakdown

### Epic 1: Foundation & Project Setup
**Priority**: P0 (Critical)
**Timeline**: Week 1
**Dependencies**: None

#### User Stories
- As a developer, I need an Xcode project structure so I can organize code
- As a developer, I need Core Data models so I can store data
- As a developer, I need a dependency injection system so I can manage dependencies
- As a developer, I need basic ViewModels and Views so I can build UI

#### Tasks
- [ ] Create Xcode visionOS project
- [ ] Set up folder structure (per technical-architecture.md)
- [ ] Configure Swift packages (RealityKit, etc.)
- [ ] Create Core Data model file (.xcdatamodeld)
- [ ] Define all entities (Transaction, Account, Budget, etc.)
- [ ] Create DependencyContainer
- [ ] Set up basic navigation (AppCoordinator)
- [ ] Create app icon and assets

#### Acceptance Criteria
- ✓ Project compiles without errors
- ✓ Core Data stack initializes
- ✓ Basic app navigation works
- ✓ Dependency injection configured

---

### Epic 2: Authentication & Security
**Priority**: P0 (Critical)
**Timeline**: Week 1
**Dependencies**: Epic 1

#### User Stories
- As a user, I want to use Face ID so my data is secure
- As a user, I want my data encrypted so it's protected
- As a user, I want to auto-lock after inactivity for security

#### Tasks
- [ ] Implement BiometricAuthManager
- [ ] Implement EncryptionManager (AES-256)
- [ ] Implement KeychainManager for secure storage
- [ ] Create AuthenticationView
- [ ] Implement auto-lock timer
- [ ] Add secure app backgrounding (blur overlay)

#### Acceptance Criteria
- ✓ Biometric auth works on app launch
- ✓ Sensitive data is encrypted
- ✓ Tokens stored in keychain
- ✓ App locks after 5 minutes inactivity
- ✓ App blurs when backgrounded

---

### Epic 3: Plaid Integration
**Priority**: P0 (Critical)
**Timeline**: Week 2
**Dependencies**: Epic 2

#### User Stories
- As a user, I want to connect my bank account so I can import transactions
- As a user, I want my transactions to sync automatically
- As a user, I want to reconnect if my bank link expires

#### Tasks
- [ ] Set up Plaid account (sandbox mode)
- [ ] Implement PlaidAPIClient
- [ ] Implement PlaidLinkManager
- [ ] Create link token endpoint/service
- [ ] Implement token exchange
- [ ] Implement account fetching
- [ ] Implement transaction syncing
- [ ] Create PlaidLinkView (SwiftUI wrapper)
- [ ] Handle error cases (expired token, etc.)

#### Acceptance Criteria
- ✓ Can create link token
- ✓ Plaid Link UI appears
- ✓ Can connect sandbox account
- ✓ Transactions import successfully
- ✓ Tokens stored securely
- ✓ Sync works in background

---

### Epic 4: Transaction Management
**Priority**: P0 (Critical)
**Timeline**: Week 2-3
**Dependencies**: Epic 3

#### User Stories
- As a user, I want to view my transactions so I can see my spending
- As a user, I want to see transaction details
- As a user, I want to categorize transactions so I can organize spending
- As a user, I want to search transactions so I can find specific purchases

#### Tasks
- [ ] Create TransactionRepository
- [ ] Create TransactionViewModel
- [ ] Create TransactionsListView
- [ ] Create TransactionDetailView
- [ ] Create TransactionRow component
- [ ] Implement transaction categorization
- [ ] Create CategoryPicker
- [ ] Implement search/filter
- [ ] Add pull-to-refresh
- [ ] Handle pending transactions

#### Acceptance Criteria
- ✓ Transactions display in list
- ✓ Can tap transaction to see details
- ✓ Can change transaction category
- ✓ Can search by merchant name
- ✓ Can filter by category
- ✓ Pull to refresh syncs transactions
- ✓ Pending transactions marked clearly

---

### Epic 5: Budget Management
**Priority**: P0 (Critical)
**Timeline**: Week 3-4
**Dependencies**: Epic 4

#### User Stories
- As a user, I want to create a monthly budget so I can control spending
- As a user, I want to see my budget status so I know how I'm doing
- As a user, I want budget alerts so I don't overspend
- As a user, I want to adjust budget categories

#### Tasks
- [ ] Create BudgetRepository
- [ ] Create BudgetViewModel
- [ ] Create CreateBudgetView
- [ ] Create BudgetOverviewView
- [ ] Create BudgetCategoryCard component
- [ ] Implement CalculateBudgetStatusUseCase
- [ ] Implement budget strategies (50/30/20, envelope, etc.)
- [ ] Create budget progress indicators
- [ ] Implement budget alerts (75%, 90%, 100%)
- [ ] Add haptic feedback for alerts

#### Acceptance Criteria
- ✓ Can create budget with income amount
- ✓ Can select budget strategy
- ✓ Budget categories auto-allocated
- ✓ Budget status calculates correctly
- ✓ Progress bars show spending %
- ✓ Alerts trigger at thresholds
- ✓ Can adjust category allocations

---

### Epic 6: Dashboard
**Priority**: P0 (Critical)
**Timeline**: Week 4
**Dependencies**: Epic 4, Epic 5

#### User Stories
- As a user, I want to see my financial overview at a glance
- As a user, I want to see my total balance
- As a user, I want to see this month's spending
- As a user, I want quick access to recent transactions

#### Tasks
- [ ] Create DashboardViewModel
- [ ] Create DashboardView
- [ ] Create BalanceCard component
- [ ] Create SpendingSummaryCard
- [ ] Create BudgetStatusCard
- [ ] Create RecentTransactionsList
- [ ] Implement data aggregation
- [ ] Add refresh functionality

#### Acceptance Criteria
- ✓ Shows total balance across accounts
- ✓ Shows month-to-date spending
- ✓ Shows budget status summary
- ✓ Shows 5 most recent transactions
- ✓ Can tap cards to drill into details
- ✓ Data refreshes on pull

---

### Epic 7: Money Flow Visualization (Basic)
**Priority**: P1 (High)
**Timeline**: Week 5
**Dependencies**: Epic 4

#### User Stories
- As a user, I want to see my money flow visually so I understand my spending
- As a user, I want expenses colored by category for easy identification
- As a user, I want to interact with the visualization

#### Tasks
- [ ] Create MoneyFlowRealityView
- [ ] Implement basic particle system
- [ ] Create ParticleEntity
- [ ] Implement particle pooling
- [ ] Create FlowStream for each category
- [ ] Color code particles by category
- [ ] Add basic gestures (pinch, rotate)
- [ ] Optimize for 60fps

#### Acceptance Criteria
- ✓ Particles flow from top to bottom
- ✓ Stream width reflects spending amount
- ✓ Colors match category colors
- ✓ Runs at 60fps
- ✓ Can pinch to zoom
- ✓ Can rotate view

---

### Epic 8: Onboarding Flow
**Priority**: P1 (High)
**Timeline**: Week 5
**Dependencies**: Epic 3, Epic 5

#### User Stories
- As a new user, I want a guided setup so I can get started quickly
- As a new user, I want to understand the app's value proposition
- As a new user, I want step-by-step bank connection

#### Tasks
- [ ] Create OnboardingCoordinator
- [ ] Create WelcomeView (3-4 screens)
- [ ] Create BankConnectionView
- [ ] Create BudgetSetupView
- [ ] Create OnboardingCompletionView
- [ ] Implement progress indicator
- [ ] Add skip option (with warning)
- [ ] Track onboarding funnel

#### Acceptance Criteria
- ✓ Welcome screens explain features
- ✓ Bank connection integrated
- ✓ Budget setup is simple
- ✓ Progress shown throughout
- ✓ Can skip (stored in preferences)
- ✓ Analytics track completion

---

### Epic 9: Settings & Account Management
**Priority**: P2 (Medium)
**Timeline**: Week 6
**Dependencies**: Epic 2, Epic 3

#### User Stories
- As a user, I want to manage my settings
- As a user, I want to disconnect my bank account
- As a user, I want to enable/disable notifications
- As a user, I want to control privacy settings

#### Tasks
- [ ] Create SettingsViewModel
- [ ] Create SettingsView
- [ ] Create AccountManagementView
- [ ] Create PrivacySettingsView
- [ ] Create NotificationSettingsView
- [ ] Implement disconnect account
- [ ] Implement data export (GDPR)
- [ ] Implement delete all data

#### Acceptance Criteria
- ✓ Can view connected accounts
- ✓ Can disconnect account
- ✓ Can toggle privacy mode
- ✓ Can toggle biometric auth
- ✓ Can export data
- ✓ Can delete all data

---

### Epic 10: Testing & Quality Assurance
**Priority**: P1 (High)
**Timeline**: Weeks 6-7
**Dependencies**: All epics

#### Tasks
- [ ] Write unit tests for ViewModels (80% coverage)
- [ ] Write unit tests for UseCases
- [ ] Write unit tests for Repositories
- [ ] Write integration tests (Plaid, Core Data)
- [ ] Write UI tests for critical flows
- [ ] Test biometric auth edge cases
- [ ] Test offline mode
- [ ] Test error scenarios
- [ ] Performance testing (Instruments)
- [ ] Memory leak detection

#### Acceptance Criteria
- ✓ 80%+ code coverage
- ✓ All critical paths tested
- ✓ No memory leaks
- ✓ App performs well (meets targets)
- ✓ Error handling works

---

### Epic 11: Polish & Launch Prep
**Priority**: P1 (High)
**Timeline**: Week 7-8
**Dependencies**: Epic 10

#### Tasks
- [ ] App Store assets (screenshots, video)
- [ ] App Store description
- [ ] Privacy policy
- [ ] Terms of service
- [ ] App icon (all sizes)
- [ ] Splash screen
- [ ] Error messages review
- [ ] Loading states polish
- [ ] Animations polish
- [ ] Haptic feedback review
- [ ] Beta testing (TestFlight)
- [ ] Bug fixes from beta
- [ ] Performance optimization

#### Acceptance Criteria
- ✓ All App Store assets ready
- ✓ Legal docs complete
- ✓ Beta tested with 50+ users
- ✓ Critical bugs fixed
- ✓ Performance targets met

---

## Post-MVP Features

### v1.1 - Enhanced Visualization (Week 9-10)

**Epic 12: Budget Walls Visualization**
- 3D budget walls that change color based on status
- Wall "breaks" when budget exceeded
- Haptic feedback when approaching wall

**Epic 13: Advanced Money Flow**
- Historical playback (watch last month)
- Comparison mode (this month vs last month)
- Forecast mode (projected spending)

### v1.2 - Investment Tracking (Week 11-12)

**Epic 14: Investment Accounts**
- Connect investment accounts via Plaid
- View portfolio holdings
- Track performance
- 3D tree growth visualization

**Epic 15: Investment Analytics**
- Asset allocation breakdown
- Portfolio performance over time
- Benchmark comparison (S&P 500)
- Retirement calculator

### v1.3 - Debt Management (Week 13-14)

**Epic 16: Debt Tracking**
- Add debts manually or via Plaid
- Track balances and interest rates
- Calculate minimum payments

**Epic 17: Debt Payoff Strategies**
- Snowball method visualization
- Avalanche method visualization
- Debt-free date projection
- Interest saved calculator

### v1.4 - Goals & Bills (Week 15-16)

**Epic 18: Savings Goals**
- Create savings goals
- Track contributions
- Goal progress visualization (filling jars)
- Projected completion date

**Epic 19: Bill Calendar**
- Add bills manually or auto-detect
- 3D calendar view
- Bill reminders
- Payment scheduling

### v1.5 - Advanced Features (Week 17-18)

**Epic 20: Multiple Accounts**
- Support unlimited bank accounts
- Account aggregation
- Net worth calculation

**Epic 21: Recurring Transactions**
- Auto-detect recurring transactions
- Subscription tracking
- Recurring expense management

**Epic 22: Reports & Exports**
- Monthly spending reports
- Category trends
- PDF export
- CSV export

### v2.0 - Collaboration (Week 19-20)

**Epic 23: Family Sharing**
- Shared budgets
- Joint account tracking
- Household spending view

**Epic 24: Voice Commands**
- Voice-activated queries
- Hands-free navigation
- Siri shortcuts

---

## Release Planning

### MVP Release Timeline (8 Weeks)

```
Week 1: Foundation & Security
├── Epic 1: Foundation & Project Setup
└── Epic 2: Authentication & Security

Week 2-3: Core Data Integration
├── Epic 3: Plaid Integration
├── Epic 4: Transaction Management
└── Epic 5: Budget Management (start)

Week 4: Features Complete
├── Epic 5: Budget Management (complete)
├── Epic 6: Dashboard
└── Epic 7: Money Flow Visualization (start)

Week 5: Polish Core Features
├── Epic 7: Money Flow Visualization (complete)
└── Epic 8: Onboarding Flow

Week 6: Settings & Testing
├── Epic 9: Settings & Account Management
└── Epic 10: Testing & QA (start)

Week 7-8: Launch Preparation
├── Epic 10: Testing & QA (complete)
└── Epic 11: Polish & Launch Prep
```

### Post-MVP Releases

```
v1.1 (2 weeks after MVP) - Enhanced Visualization
v1.2 (1 month after v1.1) - Investment Tracking
v1.3 (1 month after v1.2) - Debt Management
v1.4 (1 month after v1.3) - Goals & Bills
v1.5 (1 month after v1.4) - Advanced Features
v2.0 (2 months after v1.5) - Collaboration
```

---

## Epic Dependencies Diagram

```
Epic 1 (Foundation)
    ↓
Epic 2 (Security)
    ↓
Epic 3 (Plaid) ────────┐
    ↓                   ↓
Epic 4 (Transactions)  Epic 8 (Onboarding)
    ↓         ↓         ↓
Epic 5 (Budget)   Epic 7 (Viz)
    ↓
Epic 6 (Dashboard)
    ↓
Epic 9 (Settings)
    ↓
Epic 10 (Testing)
    ↓
Epic 11 (Polish)
    ↓
   MVP LAUNCH
```

---

## Success Metrics

### MVP Launch Goals

**Adoption**:
- 1,000 downloads in first month
- 500 active users
- 200 paying subscribers (Premium)

**Engagement**:
- 70% onboarding completion rate
- 60% Day 7 retention
- 40% Day 30 retention
- Average 3x/week usage

**Quality**:
- <1% crash rate
- <3% error rate
- >4.5 App Store rating
- <2s app launch time

**Business**:
- 15% free-to-premium conversion
- $5,000 MRR (Monthly Recurring Revenue)
- 50% gross margin

### Post-MVP Goals (6 months)

- 10,000 active users
- 2,000 paying subscribers
- $20,000 MRR
- 4.7+ App Store rating
- Featured by Apple

---

## Risk Mitigation

| Risk | Mitigation |
|------|------------|
| Plaid integration complexity | Start in sandbox, test thoroughly, have backup manual entry |
| visionOS adoption slow | Prepare iOS port in parallel |
| Performance issues | Profile early, optimize aggressively, reduce complexity if needed |
| Security breach | Follow security best practices, external audit, insurance |
| Scope creep | Stick to MVP, defer features ruthlessly, regular priority review |

---

## Decision Log

### Why This MVP Scope?

**Included**:
- Transactions: Core to understanding spending ✅
- Budget: Core value proposition ✅
- Basic 3D viz: Differentiator, but kept simple ✅
- Security: Non-negotiable for finance app ✅

**Excluded**:
- Investments: Complex, niche audience ❌
- Debt: Important but not core to budget ❌
- Goals: Nice-to-have, can add later ❌
- Multiple accounts: Complexity outweighs benefit for MVP ❌

---

**Document Status**: Ready for Implementation
**Next Step**: Begin Epic 1 - Foundation & Project Setup
