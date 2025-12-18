# Product Requirements Document: Personal Finance Navigator

## Executive Summary

Personal Finance Navigator transforms personal finance management on Apple Vision Pro by visualizing money flows as physical streams through 3D space, budget boundaries as actual walls that prevent overspending, investment growth as growing structures, and upcoming bills as floating reminders in calendar space—making abstract financial concepts tangible and intuitive.

## Product Vision

Empower individuals to achieve financial wellness by making money management visual, spatial, and intuitive. Transform confusing spreadsheets and charts into immersive 3D experiences where users can literally see where their money goes, feel budget constraints, and watch their wealth grow.

## Target Users

### Primary Users
- Young professionals (25-40) managing finances for first time
- Families budgeting household expenses
- Individuals working to pay off debt
- People saving for specific goals (house, car, vacation, retirement)
- Freelancers and gig workers with variable income

### Secondary Users
- Financial advisors (client visualization tool)
- Parents teaching children about money
- Retirees managing fixed incomes
- Small business owners (personal finances separate from business)

## Market Opportunity

- Personal finance software market: $1.5B+ by 2028
- 78% of Americans live paycheck-to-paycheck
- Average household carries $145K in debt
- Only 39% of Americans use budgeting tools
- Financial wellness apps: Growing 25% CAGR
- Younger generations prefer visual/interactive tools

## Core Features

### 1. Money Flow Visualization

**Description**: Income and expenses rendered as flowing streams of liquid through 3D space

**User Stories**:
- As a user, I want to see where my paycheck goes each month
- As someone trying to save, I want to identify my biggest expense leaks
- As a family, I want to understand our combined cash flow

**Acceptance Criteria**:
- Income flows in from top (paycheck source)
- Expenses flow out as streams with width proportional to amount
- Categories color-coded (housing, food, transport, etc.)
- Real-time updates when transactions occur
- Historical playback (watch last month's flows)
- Savings/investments shown as accumulated pools
- Interactive: Tap stream to see transactions
- Sankey diagram in 3D spatial form

**Technical Requirements**:
- Bank account integration (Plaid API)
- Real-time transaction categorization
- Fluid simulation rendering (particle systems)
- RealityKit for 3D visualization
- Smooth animations at 60fps

**Flow Visualization Details**:
```
Income Sources (flowing IN):
- Salary: Steady stream (biweekly or monthly)
- Freelance: Variable bursts
- Investments: Dividend trickle
- Other: Gifts, tax refunds, etc.

Expense Categories (flowing OUT):
- Housing: 25-35% (thick stream) - Orange
- Transportation: 15-20% - Blue
- Food: 10-15% - Green
- Utilities: 5-10% - Yellow
- Entertainment: 5-10% - Purple
- Healthcare: 5-10% - Red
- Savings: 10-20% (flows to reservoir) - Gold
- Debt Payments: Varies - Dark Red

Visual Effects:
- Stream thickness: Proportional to $ amount
- Flow speed: Frequency of transactions
- Color saturation: Necessity (needs vs wants)
- Turbulence: Variability (fixed vs variable expenses)
- Leaks: Money wasted (overdraft fees, unused subscriptions)

Modes:
- Monthly View: Current month flows
- Annual View: Year-long patterns
- Comparison: This month vs last month
- Forecast: Projected next month based on patterns
```

### 2. Budget Walls and Boundaries

**Description**: Budget limits visualized as physical walls that constrain spending space

**User Stories**:
- As a budgeter, I want to see how close I am to my dining out limit
- As someone avoiding overspending, I want a visual warning before I exceed my budget
- As a family, I want shared awareness of category budgets

**Acceptance Criteria**:
- Set budget limits for each expense category
- Walls appear as semi-transparent barriers
- Color changes as budget depletes: Green → Yellow → Red
- When over budget, wall is "broken through" with cracks
- Physical resistance (haptic feedback) when approaching limit
- Notifications when 80% and 100% of budget reached
- Flexible budgets (adjust throughout month)
- Zero-based budgeting support (every dollar assigned)

**Technical Requirements**:
- Budget management engine
- Real-time budget tracking
- Haptic feedback integration
- Collision detection for "budget wall" interactions
- Notification system

**Budget Mechanics**:
```
Budget Setup:
- 50/30/20 Rule: 50% needs, 30% wants, 20% savings
- Envelope Method: Fixed amounts per category
- Zero-Based: Income - expenses - savings = $0
- Custom: User-defined percentages

Visual Representation:
- Ceiling: Total income (can't spend more without debt)
- Walls: Category budgets (dining, shopping, etc.)
- Floor: Minimum savings target
- Zones: Safe (green), Warning (yellow), Danger (red)

Budget Status:
┌─────────────────────┐
│ Groceries: $450/$500│
│ [████████░░] 90%    │
│ ⚠️ $50 remaining    │
└─────────────────────┘

Overspending Alerts:
- Visual: Wall cracks, turns red
- Haptic: Vibration when breaching
- Audio: Optional alert sound
- Notification: "You're $20 over your dining budget"

Smart Suggestions:
- "You're on track to exceed your shopping budget. Consider postponing non-essential purchases."
- "You've saved $100 in groceries this month. Reallocate to savings?"
```

### 3. Investment Growth Structures

**Description**: Investments and savings visualized as growing 3D structures (trees, buildings, mountains)

**User Stories**:
- As an investor, I want to see my portfolio grow over time
- As a saver, I want motivation from watching my emergency fund build
- As a retirement planner, I want to visualize my nest egg growth

**Acceptance Criteria**:
- Different growth visualizations: Tree (organic growth), building (structured), mountain (accumulation)
- Height represents total value
- Growth rings/floors show time periods
- Color represents performance (green gains, red losses)
- Tap to see details (current value, % gain, asset allocation)
- Projected growth with assumed returns
- Comparison to benchmarks (S&P 500)
- Retirement calculator integration

**Technical Requirements**:
- Investment account integration (brokerages via Plaid)
- Portfolio tracking and analytics
- Compound interest calculators
- 3D procedural generation for growth structures
- Historical data visualization

**Growth Visualization**:
```
Visualization Styles:
1. Tree of Wealth
   - Trunk: Principal amount
   - Branches: Different investments (stocks, bonds, 401k)
   - Leaves: Dividends and gains
   - Roots: Contributions
   - Growth rings: Years invested

2. Wealth Tower
   - Foundation: Initial investment
   - Floors: Each year of growth
   - Windows: Individual holdings
   - Height: Total portfolio value
   - Penthouse: Financial freedom goal

3. Savings Mountain
   - Base: Emergency fund (6 months expenses)
   - Slopes: Medium-term goals (car, house down payment)
   - Peak: Retirement summit
   - Snow cap: Surplus wealth

Portfolio Breakdown:
- Stocks: Green sections
- Bonds: Blue sections
- Cash: Gray sections
- Real Estate: Brown sections
- Crypto: Orange sections (if applicable)

Interactive Features:
- Tap section: View holdings details
- Pinch to see different time periods
- Rotate to see growth from different angles
- Compare: Your tree vs. average investor tree

Retirement Projection:
- Current age marker
- Retirement age goal marker
- Projected height at retirement
- Adjustable contribution scenarios
```

### 4. Bill Calendar Space

**Description**: Upcoming bills float in 3D calendar space with spatial organization by due date

**User Stories**:
- As a user, I want to see all upcoming bills at a glance
- As someone avoiding late fees, I want advance warnings
- As a planner, I want to see bill timing relative to paycheck dates

**Acceptance Criteria**:
- Bills appear as floating 3D cards in calendar grid
- Size represents bill amount
- Color represents category
- Distance represents time until due (closer = sooner)
- Recurring bills shown across future months
- Autopay bills dimmed/less prominent
- Payment confirmation updates in real-time
- Integration with paycheck schedule (show available cash flow)

**Technical Requirements**:
- Bill tracking system
- Calendar API integration
- Bank integration for auto-detection of recurring bills
- Payment scheduling and reminders
- RealityKit for spatial calendar rendering

**Calendar Features**:
```
Calendar Layout:
- Today: Center position
- This Week: Close proximity
- This Month: Visible grid
- Next 3 Months: Distant but visible
- Beyond: Faded/compressed

Bill Card Information:
┌──────────────────┐
│ 🏠 RENT          │
│ $1,500           │
│ Due: Aug 1       │
│ [Pay Now]        │
└──────────────────┘

Bill Categories:
- Housing: Rent, mortgage (orange)
- Utilities: Electric, water, gas, internet (yellow)
- Subscriptions: Netflix, Spotify, gym (purple)
- Insurance: Health, car, home (blue)
- Loans: Student, car, personal (red)
- Other: Varies (gray)

Payment Status:
- Unpaid: Solid, bright
- Scheduled: Outlined, dimmed
- Paid: Checked, faded
- Overdue: Pulsing red, urgent

Smart Bill Detection:
- Auto-detect recurring charges from bank
- Suggest bill schedules based on patterns
- Alert to unusual bills (potential fraud)
- Track bill changes (price increases)

Paycheck Alignment:
- Show paycheck dates in calendar
- Highlight bills due between paychecks
- Cash flow forecast (will you have enough?)
- Suggest payment timing optimization
```

### 5. Debt Snowball/Avalanche Visualization

**Description**: Debt payoff strategies shown as melting snowballs or crumbling mountains

**User Stories**:
- As someone in debt, I want to see my payoff progress
- As a planner, I want to compare debt strategies
- As someone motivated by visuals, I want to celebrate debt milestones

**Acceptance Criteria**:
- Each debt as separate 3D object (size = total owed)
- Snowball method: Smallest debt melts fastest
- Avalanche method: Highest interest debt prioritized
- Payments chip away at debt structures
- Progress animations (satisfying destruction)
- Payoff timeline projected
- Interest saved calculation
- Debt-free celebration when all melted

**Technical Requirements**:
- Debt tracking system
- Payment strategy calculator
- Amortization schedule generator
- Animation system for debt reduction
- Milestone notification system

**Debt Visualization**:
```
Debt Objects:
1. Credit Cards: Ice cubes (high interest, melt fast if focused)
2. Student Loans: Snowballs (medium, steady melting)
3. Auto Loans: Boulders (secured, structured payoff)
4. Mortgage: Mountain (large, long-term, stable melting)

Snowball Method (Smallest First):
- Order debts by balance (smallest to largest)
- Focus payments on smallest
- Visual: Smallest ice cube melts fastest
- Psychological wins as debts eliminated

Avalanche Method (Highest Interest First):
- Order by interest rate (highest to largest)
- Focus payments on highest interest
- Visual: Hottest debt melts fastest
- Saves most money long-term

Debt Dashboard:
Total Debt: $45,000
┌─────────────────────────┐
│ Credit Card 1: $5,000   │
│ [████████░░] 80% paid   │
│ 18% APR | $150/mo       │
└─────────────────────────┘

Payoff Projections:
- Current pace: Debt-free in 4.5 years
- +$100/mo: Debt-free in 3.2 years ($4,200 interest saved)
- +$200/mo: Debt-free in 2.5 years ($7,800 interest saved)

Milestones:
- First debt paid: 🎉 Trophy
- 25% total debt paid: 🥉 Bronze medal
- 50%: 🥈 Silver medal
- 75%: 🥇 Gold medal
- Debt-free: 💎 Diamond celebration animation
```

### 6. Financial Goals & Progress

**Description**: Savings goals visualized as containers filling up or progress bars in space

**User Stories**:
- As a saver, I want to see progress toward my vacation fund
- As a future homeowner, I want to track my down payment savings
- As a parent, I want to visualize college savings growth

**Acceptance Criteria**:
- Multiple concurrent goals supported
- Goal containers (jars, thermometers, progress rings)
- Auto-contributions tracked
- One-time contributions easily added
- Timeline projections (when will goal be reached?)
- Goal prioritization (focus on one vs. spread across all)
- Celebration animations when goal reached
- Linked to bank savings accounts (auto-sync)

**Technical Requirements**:
- Goal management system
- Savings account integration
- Contribution tracking
- Timeline calculator
- 3D container rendering

**Goal Visualizations**:
```
Goal Types:
- Emergency Fund: Glass jar (see liquid level rise)
- Vacation: Suitcase (fills with travel items)
- House Down Payment: Piggy bank (grows larger)
- Car: Garage (car materializes as you save)
- Retirement: Hourglass (sand accumulates)
- Education: Book stack (grows taller)

Goal Card:
┌──────────────────────────┐
│ 🏖️ Hawaii Vacation       │
│ $3,200 / $5,000          │
│ [████████████░░░░] 64%   │
│ Projected: 4 months      │
│ [Add $] [Adjust Goal]    │
└──────────────────────────┘

Contribution Methods:
- Recurring: Auto-transfer $200/month
- Round-ups: Spare change from purchases
- Windfalls: Tax refunds, bonuses
- Manual: One-time deposits

Progress Insights:
- "At this rate, you'll reach your goal by December 2024"
- "Add $50/month to reach 2 months sooner"
- "You're 15% ahead of schedule! 🎉"
- "Consider pausing this goal to focus on high-interest debt"

Goal Prioritization:
- Waterfall: Fill first goal, then next
- Balanced: Contribute evenly to all
- Weighted: Assign % to each goal
- Dynamic: Adjust based on priority changes
```

## User Experience

### Onboarding Flow
1. Welcome to Personal Finance Navigator
2. Connect bank accounts (Plaid secure link)
3. Import transactions (last 90 days)
4. Auto-categorize expenses
5. Set up budget (template or custom)
6. Add debts and goals
7. Take immersive tour of money flow visualization
8. First insights generated

### Daily User Flow

1. Morning check-in: Open app with coffee
2. See today's bill reminders
3. Review yesterday's spending (new transactions)
4. Check budget status (dining budget at 85%)
5. Tap money flow to investigate
6. Identify large expense (dinner out $120)
7. Adjust weekend plans to stay on budget
8. Add $50 to vacation fund
9. Watch savings jar fill up
10. Feel motivated and in control

### Monthly Review Flow

1. Month-end: App prompts for review
2. Playback month's money flow as time-lapse
3. See budget performance by category
4. Identify overspending (dining 120% of budget)
5. Review under-spending (utilities 75%)
6. Reallocate unused budget to savings
7. Check investment growth (portfolio up 2.3%)
8. Adjust next month's budget
9. Set new goals or update existing
10. Export report for records

### Gesture & Voice Controls

```
Gestures:
- Pinch stream: Pause flow, inspect transactions
- Tap budget wall: See category details
- Rotate investment tree: View from all angles
- Drag bill card: Reschedule payment
- Spread fingers: Zoom out to see full financial picture

Voice Commands:
- "How much have I spent on dining this month?"
- "Add $100 to vacation fund"
- "When is my rent due?"
- "Show me last month's cash flow"
- "How much do I owe on my credit card?"
- "When will I be debt-free?"
```

## Design Specifications

### Visual Design

**Color Palette**:
- Income: Gold #FFD700
- Savings: Green #34C759
- Expenses: Varies by category
- Debt: Red #FF3B30
- Investments: Blue #007AFF
- Budget Safe: Green #A8D8B9
- Budget Warning: Yellow #FFC400
- Budget Exceeded: Red #FF1744

**Typography**:
- Primary: SF Pro Rounded (friendly, approachable)
- Monospace: SF Mono (for dollar amounts)
- Sizes: 20-32pt for money amounts, 14-18pt for labels

### Spatial Layout

**Default View (Financial Command Center)**:
- Center: Money flow visualization
- Left: Budget walls and status
- Right: Investment growth structures
- Top: Calendar with bills
- Bottom: Goals progress containers

**Focus Modes**:
- Cash Flow: Maximize flow visualization
- Budget: Emphasize spending vs. limits
- Investments: Portfolio details and projections
- Debt: Payoff strategies and progress
- Goals: Savings targets and timelines

## Technical Architecture

### Platform
- Apple Vision Pro (visionOS 2.0+)
- Swift 6.0+
- SwiftUI + RealityKit

### System Requirements
- visionOS 2.0 or later
- Internet connection for bank sync
- 50GB storage for transaction history

### Key Technologies
- **Plaid**: Bank account integration
- **RealityKit**: 3D visualization
- **Core Data**: Local transaction storage
- **CloudKit**: Cross-device sync
- **Charts**: Historical data visualization
- **Encryption**: AES-256 for financial data

### Performance Targets
- Transaction sync: < 10 seconds
- Visualization render: < 3 seconds
- Frame rate: 60fps
- Data encryption: Zero-knowledge architecture

## Monetization Strategy

**Freemium**:
- **Free**: 1 bank account, basic budgeting, manual transactions
- **Premium**: $9.99/month or $99/year
  - Unlimited accounts
  - Investment tracking
  - Debt payoff planning
  - Goal management
  - Bill tracking
  - Export reports
  - No ads

**Family Plan**: $14.99/month (up to 5 users, shared budgets)

**Revenue Streams**:
1. Subscriptions (primary)
2. Affiliate: Credit card recommendations, HYSA referrals
3. B2B: Financial advisor dashboards

### Target Revenue
- Year 1: $2M (20,000 users @ $100 ARPU)
- Year 2: $12M (100,000 users)
- Year 3: $40M (350,000 users)

## Success Metrics

### Primary KPIs
- MAU: 100,000 in Year 1
- Premium conversion: 15%
- Daily active: 40% (check finances daily)
- NPS: > 60

### Financial Wellness Impact
- Users save 20%+ more
- 30% reduction in overspending
- Debt payoff 25% faster
- User-reported financial stress -40%

## Launch Strategy

**Phase 1**: Beta (Months 1-2) - Core features, 500 users
**Phase 2**: Launch (Month 3) - Public release
**Phase 3**: Growth (Months 4-12) - Marketing, partnerships

## Risks & Mitigations

| Risk | Impact | Probability | Mitigation |
|------|--------|-------------|------------|
| Bank integration issues | High | Medium | Use established Plaid API, extensive testing |
| Financial data security breach | Critical | Low | Military-grade encryption, security audits |
| Categorization accuracy low | Medium | Medium | Machine learning improvements, user corrections |
| Complexity overwhelming users | Medium | Medium | Progressive disclosure, excellent onboarding |

## Success Criteria
- 200,000 users in 12 months
- 30,000 paying subscribers
- $8M revenue in 18 months
- 4.6+ App Store rating
- Featured by Apple

## Appendix

### Security & Privacy
- All data encrypted at rest and in transit
- Plaid handles bank credentials (never stored in app)
- Optional biometric lock
- Auto-logout after inactivity
- No data sold to third parties
- GDPR and CCPA compliant
