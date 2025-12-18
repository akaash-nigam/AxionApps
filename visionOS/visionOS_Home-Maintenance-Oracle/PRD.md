# Product Requirements Document: Home Maintenance Oracle

## Executive Summary

Home Maintenance Oracle transforms home ownership and maintenance through Apple Vision Pro's spatial computing capabilities. By recognizing appliances and equipment through the device's cameras, the app instantly displays manuals, maintenance schedules, troubleshooting guides, video tutorials overlaid on actual equipment, and enables quick part ordering through visual recognition.

## Product Vision

Empower homeowners and property managers to maintain their homes confidently by providing instant access to equipment information, proactive maintenance reminders, visual repair guidance, and seamless part procurement—all through spatial computing that understands their physical environment.

## Target Users

### Primary Users
- Homeowners (especially first-time homeowners learning maintenance)
- DIY enthusiasts tackling home repairs
- Property managers overseeing multiple units
- Landlords managing rental properties
- Home inspectors conducting assessments

### Secondary Users
- Real estate agents showing property features
- Handymen and contractors needing quick reference
- Appliance repair technicians
- Home stagers and designers

## Market Opportunity

- US homeownership: 65% of households (86M homes)
- Home maintenance market: $400B+ annually
- DIY home improvement: $450B market
- Average homeowner spends: $3,000-$6,000/year on maintenance
- Appliance repair market: $16B annually
- Smart home market: $80B by 2028 (growing 25% CAGR)

## Core Features

### 1. Visual Appliance Recognition

**Description**: Point Vision Pro at any appliance or equipment to automatically identify it and retrieve relevant information

**User Stories**:
- As a homeowner, I want to look at my HVAC system and instantly see its manual
- As a DIY enthusiast, I want to identify my water heater model without crawling to read the label
- As a property manager, I want to quickly catalog all appliances in a unit

**Acceptance Criteria**:
- Recognizes 500+ common appliances and equipment types
- Identification accuracy > 90% for major brands
- Displays model number, year, manufacturer
- Works in various lighting conditions
- Fallback: Manual entry if recognition fails
- Supports: HVAC, water heaters, washers, dryers, refrigerators, dishwashers, ovens, furnaces, garage doors, etc.

**Technical Requirements**:
- Core ML object detection model
- OCR for reading model plates/labels
- Cloud database of appliance specifications
- On-device processing for privacy
- Image classification with 95% confidence threshold
- Response time < 2 seconds

**Recognition Categories**:
```
Major Appliances:
- Kitchen: Refrigerator, oven, dishwasher, microwave, range
- Laundry: Washer, dryer
- Climate: HVAC, furnace, water heater, thermostat
- Garage: Garage door opener, water softener, sump pump

Home Systems:
- Electrical: Circuit breaker panels, outlets, switches
- Plumbing: Shut-off valves, water meters, fixtures
- Security: Alarm systems, cameras, locks
- Comfort: Ceiling fans, humidifiers, dehumidifiers

Outdoor Equipment:
- Lawn: Mower, trimmer, leaf blower
- Pool: Pump, filter, heater
- HVAC: Outdoor condenser units
```

### 2. Floating Manuals and Documentation

**Description**: Equipment manuals, spec sheets, and warranty information appear as floating windows near the recognized device

**User Stories**:
- As a homeowner, I want to see my dishwasher manual without searching through a drawer of paperwork
- As a property manager, I want to access warranty information for all appliances
- As a DIY enthusiast, I want to reference the wiring diagram while working on an appliance

**Acceptance Criteria**:
- Displays PDF manuals in readable floating window
- Manuals positioned near the appliance in 3D space
- Search functionality within manuals
- Bookmark frequently accessed sections
- Offline access to downloaded manuals
- Multi-language support (manufacturer languages)
- Links to manufacturer support websites

**Technical Requirements**:
- Database of 100,000+ appliance manuals
- Partnership with manufacturers for official docs
- Web scraping for older/discontinued models
- PDF rendering optimized for Vision Pro
- Local caching for offline access
- CloudKit for user's manual library

**Document Types**:
```
Available Documentation:
- Owner's Manual: Operation instructions
- Installation Guide: Setup procedures
- Parts Diagram: Exploded views, part numbers
- Service Manual: Detailed repair procedures (where available)
- Warranty Information: Terms, duration, coverage
- Quick Reference Guide: Common operations
- Troubleshooting Guide: Diagnostic flowcharts
- Energy Guide: Efficiency ratings, costs

Additional Resources:
- Product reviews and ratings
- Recall notices and safety alerts
- Firmware updates (smart appliances)
- Accessory compatibility
```

### 3. Proactive Maintenance Schedules

**Description**: Personalized maintenance calendar that tracks service intervals and sends reminders

**User Stories**:
- As a homeowner, I want to know when to change my HVAC filter without trying to remember
- As a property manager, I want maintenance schedules for all properties in one place
- As a homeowner, I want seasonal maintenance checklists

**Acceptance Criteria**:
- Automatic schedule generation based on identified equipment
- Customizable reminder frequency
- Calendar integration (iOS Calendar)
- Completion tracking with photo documentation
- Seasonal maintenance checklists
- Service history logging
- Estimated costs for professional service
- Notifications 1 week and 1 day before due

**Technical Requirements**:
- Local notifications via APNs
- Calendar API integration
- Core Data for maintenance history
- Machine learning for personalized scheduling based on usage patterns

**Maintenance Types**:
```
Recurring Maintenance:
- HVAC filter replacement (monthly/quarterly)
- Furnace annual inspection
- Water heater flushing (annually)
- Dryer vent cleaning (annually)
- Gutters cleaning (spring/fall)
- Smoke detector battery replacement (annually)
- AC coil cleaning (annually)
- Garage door lubrication (quarterly)

Seasonal Checklists:
- Spring: AC startup, gutter cleaning, outdoor equipment prep
- Summer: Pool maintenance, lawn care, AC filter checks
- Fall: Furnace startup, winterization, gutter cleaning
- Winter: Pipe freeze prevention, snow equipment check

Appliance-Specific:
- Refrigerator coil cleaning (6 months)
- Dishwasher filter cleaning (monthly)
- Washing machine drum cleaning (3 months)
- Range hood filter replacement (6 months)
```

### 4. AR Video Tutorial Overlays

**Description**: Step-by-step video repair tutorials overlaid directly on the equipment being repaired

**User Stories**:
- As a DIY enthusiast, I want to watch a repair video aligned with my actual dishwasher
- As a homeowner, I want to see exactly which screw to remove highlighted in my view
- As a property manager, I want to guide a tenant through a simple fix remotely

**Acceptance Criteria**:
- 3D spatial anchoring of video to equipment
- Pause/play video with hand gestures
- Highlight components referenced in video
- Step-by-step mode with progress tracking
- Rewind/skip gestures
- Tutorial library: 10,000+ how-to videos
- Difficulty ratings and estimated time
- Tools/parts list before starting

**Technical Requirements**:
- ARKit for spatial anchoring
- Video playback optimized for Vision Pro
- Gesture recognition for video controls
- Integration with YouTube API (DIY channels)
- Partnership with iFixit, RepairClinic, AppliancePartsPros
- On-device video processing

**Tutorial Categories**:
```
Repair Tutorials:
- Appliance: Replace dishwasher pump, fix ice maker, clean dryer vent
- Plumbing: Fix leaky faucet, unclog drain, replace toilet flapper
- Electrical: Replace outlet, install dimmer, reset breaker
- HVAC: Change filter, clear drain line, reset thermostat

Maintenance Tutorials:
- Cleaning: Refrigerator coils, range hood, dishwasher filter
- Inspection: Check water heater anode rod, inspect furnace flame
- Adjustment: Level refrigerator, adjust door hinges, calibrate oven

Installation Tutorials:
- Smart home devices: Thermostat, doorbell, locks
- Appliances: Dishwasher hookup, garbage disposal
- Fixtures: Faucets, light fixtures, ceiling fans

Difficulty Levels:
- Easy (5-15 min): Filter changes, basic cleaning
- Medium (30-60 min): Part replacements, adjustments
- Hard (1-3 hours): Major component replacement
- Expert (3+ hours): Complex repairs, recommend professional
```

### 5. Visual Part Identification and Ordering

**Description**: Point at a broken part to identify it, see pricing, and order replacement instantly

**User Stories**:
- As a homeowner, I want to point at my broken refrigerator shelf and order a replacement
- As a DIY enthusiast, I want to identify which belt in my dryer needs replacement
- As a property manager, I want to quickly order multiple parts across different properties

**Acceptance Criteria**:
- Visual recognition of common replacement parts
- Exact part number identification (when visible)
- Price comparison across 3+ suppliers
- Amazon, eBay, manufacturer direct integration
- One-tap ordering with shipping options
- Part compatibility verification
- OEM vs. aftermarket options
- Estimated delivery dates

**Technical Requirements**:
- Computer vision for part recognition
- OCR for part number extraction
- APIs: Amazon Product API, eBay API, PartSelect API
- Affiliate partnerships for revenue share
- Inventory checking (real-time availability)
- Price scraping/comparison engine

**Part Categories**:
```
Common Replacement Parts:
- HVAC: Filters, thermostats, capacitors, contactors
- Appliances: Belts, pumps, hoses, seals, heating elements
- Plumbing: Faucet cartridges, flappers, aerators, washers
- Electrical: Outlets, switches, breakers, light bulbs
- Garage: Springs, rollers, cables, openers

Part Information Displayed:
- Part number (OEM)
- Compatible models
- Price range: $X.XX - $Y.YY
- Availability: In stock / ships in 2-5 days
- Reviews and ratings
- Installation difficulty
- Return policy

Shopping Options:
- Amazon (Prime eligible)
- eBay (new and used)
- Manufacturer direct
- Local supply stores (Home Depot, Lowe's)
- Specialty suppliers (AppliancePartsPros, RepairClinic)
```

### 6. Home Equipment Inventory

**Description**: Automatically catalog all appliances and systems in the home with purchase dates, warranties, and service history

**User Stories**:
- As a homeowner, I want a complete inventory of my appliances for insurance purposes
- As a property manager, I want to track equipment across multiple properties
- As a home seller, I want to provide buyers with a complete equipment list

**Acceptance Criteria**:
- Auto-detection during initial home scan
- Manual addition of unrecognized equipment
- Photo documentation of each item
- Purchase date and price tracking
- Warranty expiration alerts
- Service history attached to each item
- Export to PDF for insurance/real estate
- QR code labels for quick access

**Technical Requirements**:
- Room scanning with persistent anchors
- Core Data database for inventory
- CloudKit sync across devices
- PDF generation
- QR code generation and scanning

**Inventory Features**:
```
Equipment Profile:
- Make, model, serial number
- Installation date
- Purchase price
- Expected lifespan
- Warranty: Duration, expires, coverage
- Energy rating (Energy Star)
- Recall status
- Estimated replacement cost

Organization:
- By room: Kitchen, laundry, basement, garage
- By category: Appliances, HVAC, plumbing, electrical
- By age: < 5 years, 5-10 years, > 10 years (needs attention)
- By warranty status: Active, expired

Reports:
- Total home equipment value
- Upcoming warranty expirations
- Maintenance due this month
- Energy efficiency summary
- Replacement planning (aging equipment)
```

## User Experience

### Onboarding Flow
1. User downloads Home Maintenance Oracle
2. Welcome tutorial: Point at appliances to identify
3. Home scan mode: Walk through home to catalog equipment
4. System auto-detects appliances and creates inventory
5. User reviews and confirms detected items
6. App generates maintenance schedule
7. User sets notification preferences
8. Ready to use

### Primary User Flow: Appliance Troubleshooting

1. Dishwasher stops working
2. User puts on Vision Pro, opens Home Maintenance Oracle
3. Looks at dishwasher, app recognizes it
4. User says "Dishwasher won't start"
5. App displays troubleshooting flowchart
6. User follows steps: Check power, check door latch
7. Identifies broken door latch switch
8. App shows part replacement tutorial overlaid on dishwasher
9. User identifies exact part number
10. App finds part: $12.99 on Amazon, 2-day shipping
11. User orders part with one tap
12. Part arrives, user follows video tutorial to install
13. Logs repair in service history
14. Dishwasher fixed

### Primary User Flow: Routine Maintenance

1. User receives notification: "HVAC filter change due"
2. Opens app, filter location highlighted in home map
3. Looks at HVAC system
4. App displays: Current filter size (16x25x1), recommended replacement (MERV 11)
5. User: "Order filter"
6. App shows 6-pack for $45, Subscribe & Save for 10% off
7. User orders, marks task complete
8. Takes photo of new filter for documentation
9. Next reminder scheduled for 3 months
10. Task logged in maintenance history

### Gesture Controls

```
Navigation:
- Look + Tap: Select appliance
- Pinch + Drag: Move manual window
- Two-hand Spread: Enlarge documentation

Voice Commands:
- "Show manual"
- "What maintenance is due?"
- "How do I fix [problem]?"
- "Order replacement [part]"
- "Add to inventory"
- "Set reminder for [task]"

Video Controls:
- Single Tap: Pause/play
- Swipe Right: Next step
- Swipe Left: Previous step
- Pinch: Zoom video
```

## Design Specifications

### Visual Design

**Color Palette**:
- Primary: Blue #007AFF (trustworthy, helpful)
- Secondary: Green #34C759 (maintenance complete, healthy)
- Warning: Orange #FF9500 (maintenance due soon)
- Alert: Red #FF3B30 (overdue, critical issue)
- Background: Adaptive (light/dark mode)

**Typography**:
- Primary: SF Pro (clear, readable)
- Monospace: SF Mono (part numbers, model numbers)
- Sizes: 16-24pt for primary text, 14pt for details

### Spatial Layout

**Default View**:
- Center: Recognized appliance with floating info card
- Left: Manual/documentation panel
- Right: Maintenance schedule and history
- Top: Home inventory overview
- Bottom: Action buttons (manual, tutorials, order parts)

**Room Overview Mode**:
- 3D map of home with appliance locations
- Color-coded by maintenance status
- Tap appliance to zoom in

### Information Hierarchy
1. Appliance identification and status (largest)
2. Current issue or maintenance due
3. Quick actions (manual, tutorial, order)
4. Detailed specifications and history
5. Related equipment and recommendations

## Technical Architecture

### Platform
- Apple Vision Pro (visionOS 2.0+)
- Swift 6.0+
- SwiftUI + RealityKit + ARKit

### System Requirements
- visionOS 2.0 or later
- 8GB RAM minimum
- 50GB storage for manual library and cached data
- Internet connection for initial setup and part ordering

### Key Technologies
- **RealityKit**: 3D rendering and spatial anchoring
- **ARKit**: Object detection and scene understanding
- **Core ML**: Appliance and part recognition models
- **Vision Framework**: OCR for model number extraction
- **AVFoundation**: Video playback for tutorials
- **Core Data**: Local inventory and history storage
- **CloudKit**: Sync across user's devices

### Data Architecture

```
Local Storage:
- Inventory: Core Data (appliances, maintenance history)
- Manuals: PDF files cached locally (up to 10GB)
- Spatial Anchors: ARKit world map persistence
- User Preferences: UserDefaults

Cloud Storage:
- User inventory sync: CloudKit
- Manual library: CDN (CloudFront or similar)
- Part database: REST API + local cache

APIs:
- Manual Retrieval: Custom API + manufacturer partnerships
- Part Search: Amazon Product API, eBay API
- Tutorial Videos: YouTube Data API, Vimeo API
- Product Data: Best Buy API, Home Depot API
```

### Performance Targets
- Appliance recognition: < 2 seconds
- Manual loading: < 3 seconds
- Tutorial video start: < 2 seconds (cached)
- Home scan: 5-10 minutes for average 2,000 sq ft home
- Frame rate: 60fps minimum
- Memory usage: < 2GB typical

### AI/ML Models

```
Computer Vision Models:
1. Appliance Classifier
   - Input: Camera feed
   - Output: Appliance category (20 classes)
   - Accuracy: 95%+
   - Inference time: < 500ms

2. Brand/Model Detector
   - Input: Close-up image
   - Output: Brand, model, year
   - Accuracy: 90%+ for major brands
   - Inference time: < 1 second

3. Part Recognition
   - Input: Part image
   - Output: Part type, compatible models
   - Accuracy: 85%+
   - Inference time: < 1 second

4. OCR for Model Plates
   - Input: Image of label/plate
   - Output: Model #, serial #, year
   - Accuracy: 95%+
   - Inference time: < 500ms

Model Updates:
- Quarterly retraining with new appliance releases
- Federated learning: Improve from user corrections
- On-device adaptation for user's specific home
```

## Partnerships & Integrations

### Manufacturer Partnerships
- Whirlpool, GE, Samsung, LG, Bosch (manuals, specs)
- Lennox, Carrier, Trane (HVAC documentation)
- Rheem, AO Smith (water heater support)

### Retailer Integrations
- Amazon (parts ordering, affiliate revenue)
- Home Depot, Lowe's (local pickup options)
- AppliancePartsPros, RepairClinic (specialty parts)

### Content Partnerships
- iFixit (repair guides)
- YouTube DIY channels (tutorial content licensing)
- HomeAdvisor (professional contractor referrals for complex jobs)

### Smart Home Integration
- HomeKit: Auto-detect smart appliances
- Google Home, Alexa: Voice command support
- Samsung SmartThings: Appliance status monitoring

## Monetization Strategy

### Pricing Models

**Option 1: Freemium (Recommended)**
- **Free Tier**:
  - Recognize up to 5 appliances
  - Basic manuals
  - Simple maintenance reminders
  - 30-day maintenance history

- **Home Pro**: $4.99/month or $49/year
  - Unlimited appliances
  - Full manual library
  - Video tutorials
  - Advanced maintenance scheduling
  - Parts comparison shopping
  - Warranty tracking
  - Priority support

- **Property Manager**: $19.99/month
  - Multiple properties (up to 10)
  - Team collaboration
  - Tenant maintenance requests
  - Vendor management
  - Expense tracking
  - Reporting and analytics

**Option 2: One-Time Purchase**
- $29.99 one-time for full features

**Additional Revenue Streams**:
1. **Affiliate commissions**: 4-8% on parts ordered through app (Amazon, eBay)
2. **Contractor referrals**: $20-$50 per successful referral to HomeAdvisor, Angi
3. **Premium content**: Expert courses ($9.99 each) on advanced repairs
4. **B2B licensing**: Home warranty companies, property management firms
5. **Data insights**: Anonymized appliance failure rates sold to manufacturers

### Target Revenue
- Year 1: $500K (10,000 paying users @ $50 ARPU + affiliate revenue)
- Year 2: $3M (50,000 users + B2B deals)
- Year 3: $10M (150,000 users + mature affiliate program)

## Success Metrics

### Primary KPIs
- Monthly Active Users (MAU): 50,000 in Year 1
- Conversion to paid: 15% of free users
- User retention: > 70% month-over-month
- Appliance recognition accuracy: > 90%
- NPS (Net Promoter Score): > 50

### Secondary KPIs
- Average appliances per household: 12-15
- Maintenance tasks completed: 60% completion rate
- Parts ordered through app: 30% of users
- Video tutorial engagement: 40% watch to completion
- Home scan completion rate: 80% of onboarding users

### Business KPIs
- ARPU (Average Revenue Per User): $50-$75/year
- Customer Acquisition Cost (CAC): < $20
- Lifetime Value (LTV): > $200
- Affiliate commission: $10-$15 per user per year

## Launch Strategy

### Phase 1: Beta (Months 1-2)
- 500 beta testers (homeowners)
- Core features: Recognition, manuals, maintenance
- Focus on top 100 appliances
- Gather feedback, improve accuracy

### Phase 2: Public Launch (Month 3)
- App Store release
- Freemium model
- Marketing to homeowner communities
- Supported appliances: 500+
- Tutorial library: 1,000+ videos

### Phase 3: Growth (Months 4-6)
- Property manager tier launch
- Expand appliance database to 2,000+
- Tutorial library: 5,000+ videos
- Manufacturer partnerships announced
- Referral program for users

### Phase 4: Expansion (Months 7-12)
- B2B partnerships (home warranty companies)
- International expansion (Canada, UK)
- Smart home deeper integration
- AI predictive maintenance (failure prediction)

## Marketing Strategy

### Target Channels
- **Social Media**: Facebook homeowner groups, Reddit (r/homeowners, r/DIY, r/homeimprovement)
- **Content Marketing**: Blog with home maintenance tips, YouTube channel
- **Influencer Partnerships**: DIY YouTube creators, home improvement influencers
- **Partnerships**: Home Depot, Lowe's in-store demos
- **PR**: Tech blogs (The Verge, TechCrunch), home magazines (This Old House)

### Launch Campaign
- "Never Search for a Manual Again" tagline
- Demo video: User troubleshoots dishwasher in 5 minutes
- Free first year for early adopters
- Home maintenance challenge: Complete 10 tasks, win prizes
- Partnership with HGTV personalities

## Risks & Mitigations

| Risk | Impact | Probability | Mitigation |
|------|--------|-------------|------------|
| Appliance recognition accuracy low | High | Medium | Continuous model improvement, manual entry fallback |
| Manual database incomplete | Medium | High | Web scraping, crowdsourcing, manufacturer partnerships |
| Vision Pro adoption slow | High | Medium | Build companion iOS app (iPhone camera mode) |
| Liability for bad repair advice | High | Low | Clear disclaimers, professional referrals for complex jobs |
| Competition from manufacturers' apps | Medium | Medium | Multi-brand advantage, better UX, spatial interface |
| Parts affiliate revenue lower than expected | Low | Medium | Diversify revenue, focus on subscription model |

## Competitive Analysis

### Existing Solutions
- **Manufacturer Apps**: GE Appliances, Whirlpool
  - Single brand only, limited spatial features
- **Manuals Apps**: Manuals.co, Manual Maker
  - No recognition, manual search only
- **Home Maintenance**: BrightNest, HomeZada
  - Reminders only, no AR or recognition
- **Smart Home**: Google Home, HomeKit
  - Smart appliances only, no manuals or tutorials

**Our Advantages**:
- Only spatial computing solution
- Multi-brand recognition
- Integrated workflows (identify → manual → tutorial → order parts)
- Proactive maintenance scheduling
- AR video overlays (unique)

### Vision Pro Competitors
- None currently identified (first mover)

## Open Questions

1. Should we support commercial equipment (restaurants, offices) or focus on residential?
2. What is the ideal freemium limit (5 appliances vs. 10)?
3. Should we build contractor-facing features (estimate generation, client management)?
4. How do we handle regional differences (HVAC systems vary by climate)?
5. Should we expand to outdoor equipment (mowers, trimmers, etc.)?
6. What level of AI predictive maintenance is feasible with available data?
7. Should we partner with a home warranty company as white-label solution?

## Success Criteria

Home Maintenance Oracle will be considered successful if:
- 100,000+ total users within 12 months
- 15,000+ paying subscribers
- $3M+ revenue within 18 months
- 4.5+ star rating on App Store
- Featured by Apple in Vision Pro showcase
- Partnership with at least 2 major appliance manufacturers
- Media coverage in major home improvement publications

## Appendix

### User Research Findings
- 73% of homeowners have lost appliance manuals
- 65% attempt DIY repairs before calling professional
- 82% want maintenance reminders
- 56% don't know when to service HVAC, water heater
- 91% would use AR for repair tutorials if available
- Average time searching for manual/tutorial: 15-30 minutes

### Technical Deep Dive: Appliance Recognition

```
Recognition Pipeline:
1. Scene Understanding (ARKit)
   - Identify room type (kitchen, laundry, garage)
   - Detect large objects (appliances)

2. Object Classification (Core ML)
   - Classify object type (refrigerator, washer, etc.)
   - Confidence threshold: 85%

3. Brand Detection (Vision + ML)
   - Logo recognition from front panel
   - 50 major brands supported

4. Model Identification (OCR + Database)
   - Read model plate with OCR
   - Match against product database
   - Fallback: Crowdsourced identification

5. Verification
   - Show user: "Is this a GE Refrigerator Model ABC123?"
   - User confirms or corrects
   - Correction fed back to improve model

Accuracy Targets:
- Room type: 95%+
- Appliance category: 90%+
- Brand: 85%+
- Exact model: 75%+ (varies by visibility of model plate)
```

### Maintenance Schedule Intelligence

```
Schedule Generation:
1. Base Schedule (from manufacturer recommendations)
   - HVAC filter: Every 90 days
   - Water heater flush: Annually

2. Environmental Adjustments
   - High pollen area → HVAC filter every 60 days
   - Hard water area → Water heater flush every 6 months

3. Usage Pattern Learning
   - Heavy AC use detected → Check filter monthly
   - Large family (high laundry use) → Dryer vent quarterly

4. Appliance Age Factor
   - > 10 years old → More frequent inspections
   - Newer appliance → Extended intervals

5. Seasonal Triggers
   - Fall: Schedule furnace inspection before winter
   - Spring: Schedule AC startup before summer

Data Sources:
- Manufacturer specifications
- Industry best practices (ASHRAE for HVAC)
- Weather data (local climate)
- Smart home usage data (if connected)
- User reported issues (learn failure patterns)
```
