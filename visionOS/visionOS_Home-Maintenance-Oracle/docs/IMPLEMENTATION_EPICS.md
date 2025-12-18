# Implementation Epics - MVP
## Home Maintenance Oracle

**Version**: 1.0
**Last Updated**: 2025-11-24
**Status**: Ready for Development

---

## Epic Overview

| Epic | Description | Priority | Estimated Weeks | Dependencies |
|------|-------------|----------|-----------------|--------------|
| **Epic 0** | Project Foundation & Setup | P0 | 2 weeks | None |
| **Epic 1** | Appliance Recognition | P0 | 3 weeks | Epic 0 |
| **Epic 2** | Manual System | P0 | 3 weeks | Epic 0 |
| **Epic 3** | Inventory Management | P0 | 2 weeks | Epic 0, Epic 1 |
| **Epic 4** | Maintenance System | P1 | 2 weeks | Epic 0, Epic 3 |
| **Epic 5** | Integration & Polish | P1 | 2 weeks | All previous |
| **Epic 6** | Testing & Launch Prep | P1 | 2 weeks | Epic 5 |

**Total Timeline**: 16 weeks (4 months)

---

## Epic 0: Project Foundation & Setup
**Duration**: 2 weeks (Weeks 1-2)
**Team**: All developers
**Goal**: Establish project infrastructure and development environment

### User Stories

#### Story 0.1: Project Initialization
```
As a developer,
I want the project properly configured,
So that I can start building features immediately.
```

**Tasks**:
- [ ] Create Xcode project for visionOS
- [ ] Set up Git repository and branching strategy
- [ ] Configure SwiftLint and SwiftFormat
- [ ] Set up project folder structure (per TECHNICAL_ARCHITECTURE.md)
- [ ] Configure build configurations (Debug, Beta, Release)
- [ ] Add .gitignore for Xcode/Swift projects

**Acceptance Criteria**:
- ✅ Project builds successfully
- ✅ SwiftLint runs without errors
- ✅ All team members can clone and run project
- ✅ Folder structure matches architecture document

**Estimate**: 2 days

---

#### Story 0.2: Core Data Setup
```
As a developer,
I want Core Data configured with CloudKit,
So that we can persist and sync user data.
```

**Tasks**:
- [ ] Create Core Data model (.xcdatamodeld)
- [ ] Implement all entities from DATA_MODEL.md:
  - [ ] HomeEntity
  - [ ] ApplianceEntity
  - [ ] MaintenanceTaskEntity
  - [ ] ServiceHistoryEntity
  - [ ] ManualEntity
  - [ ] PhotoEntity
- [ ] Configure relationships and delete rules
- [ ] Set up NSPersistentCloudKitContainer
- [ ] Configure CloudKit container
- [ ] Implement PersistenceController
- [ ] Add sample data seeding for development

**Acceptance Criteria**:
- ✅ All entities created with correct attributes
- ✅ CloudKit sync enabled
- ✅ Can save and fetch data locally
- ✅ Sample data loads on first launch (debug only)

**Estimate**: 3 days

---

#### Story 0.3: Service Layer Foundation
```
As a developer,
I want a clean service architecture,
So that business logic is separated from UI.
```

**Tasks**:
- [ ] Create protocol definitions for all services:
  - [ ] RecognitionServiceProtocol
  - [ ] ManualServiceProtocol
  - [ ] MaintenanceServiceProtocol
  - [ ] InventoryServiceProtocol
- [ ] Implement dependency injection container (AppDependencies)
- [ ] Create mock implementations for testing
- [ ] Set up error handling hierarchy
- [ ] Implement logging utility

**Acceptance Criteria**:
- ✅ All service protocols defined
- ✅ AppDependencies provides service instances
- ✅ Mock services work for UI development
- ✅ Error types defined per TECHNICAL_ARCHITECTURE.md

**Estimate**: 2 days

---

#### Story 0.4: Basic UI Shell
```
As a developer,
I want the main navigation structure,
So that we can add features incrementally.
```

**Tasks**:
- [ ] Create main app structure (WindowGroup)
- [ ] Implement tab/navigation structure:
  - [ ] Home (Recognition)
  - [ ] Inventory
  - [ ] Maintenance
  - [ ] Settings
- [ ] Create placeholder views for each section
- [ ] Implement basic navigation flow
- [ ] Add app icon and launch screen
- [ ] Set up SF Symbols icons

**Acceptance Criteria**:
- ✅ App launches with navigation
- ✅ Can navigate between main sections
- ✅ UI follows visionOS design guidelines
- ✅ Placeholder content visible

**Estimate**: 2 days

---

#### Story 0.5: Development Tools Setup
```
As a developer,
I want development and debugging tools,
So that development is efficient.
```

**Tasks**:
- [ ] Set up unit testing target
- [ ] Set up UI testing target
- [ ] Configure test schemes
- [ ] Add XCTest helpers and utilities
- [ ] Set up code coverage tracking
- [ ] Create README with setup instructions
- [ ] Document architecture decisions

**Acceptance Criteria**:
- ✅ Can run unit tests (Cmd+U)
- ✅ Can run UI tests
- ✅ Code coverage reports generated
- ✅ README complete with setup steps

**Estimate**: 1 day

---

**Epic 0 Total**: 10 days (2 weeks)

---

## Epic 1: Appliance Recognition
**Duration**: 3 weeks (Weeks 3-5)
**Dependencies**: Epic 0
**Goal**: Users can point at appliances and identify them

### User Stories

#### Story 1.1: Core ML Model Integration
```
As a developer,
I want to integrate the appliance classifier model,
So that we can recognize appliances from camera feed.
```

**Tasks**:
- [ ] Obtain or train ApplianceClassifier model
  - [ ] Option A: Use pre-trained MobileNetV3 + fine-tune
  - [ ] Option B: Create ML with Create ML (faster MVP approach)
- [ ] Add .mlmodel to project
- [ ] Create ApplianceClassificationService
- [ ] Implement image preprocessing
- [ ] Add confidence threshold logic (85% minimum)
- [ ] Implement result caching
- [ ] Write unit tests for classifier

**Acceptance Criteria**:
- ✅ Model integrated and loads successfully
- ✅ Can classify test images
- ✅ Returns confidence scores
- ✅ Low confidence returns alternatives
- ✅ Unit tests pass with >80% accuracy on test set

**Estimate**: 5 days

---

#### Story 1.2: Camera Integration
```
As a user,
I want to use my Vision Pro camera,
So that I can capture appliance images.
```

**Tasks**:
- [ ] Request camera permissions
- [ ] Implement ARKit scene setup
- [ ] Create camera view with live feed
- [ ] Add capture button
- [ ] Implement image capture from ARKit
- [ ] Handle camera authorization states
- [ ] Add camera usage description to Info.plist

**Acceptance Criteria**:
- ✅ Camera feed displays in app
- ✅ Can capture still images
- ✅ Permission prompt appears on first use
- ✅ Handles permission denied gracefully

**Estimate**: 2 days

---

#### Story 1.3: Recognition UI
```
As a user,
I want to see recognition results overlaid in space,
So that I know what appliance was detected.
```

**Tasks**:
- [ ] Create RecognitionView (SwiftUI)
- [ ] Implement floating result card
- [ ] Show appliance category, brand (if detected)
- [ ] Display confidence score
- [ ] Add "Try Again" and "Manual Entry" buttons
- [ ] Implement loading state during recognition
- [ ] Add error states (no appliance detected, low confidence)
- [ ] Position card near appliance in 3D space

**Acceptance Criteria**:
- ✅ Recognition results display in floating card
- ✅ Card positioned spatially near target
- ✅ All states handled (loading, success, error)
- ✅ UI matches SPATIAL_UX_DESIGN.md

**Estimate**: 3 days

---

#### Story 1.4: Manual Entry Fallback
```
As a user,
I want to manually enter appliance details,
So that I can add appliances even if recognition fails.
```

**Tasks**:
- [ ] Create manual entry form
- [ ] Fields: Category picker, Brand, Model, Serial Number
- [ ] Add photo picker (optional)
- [ ] Implement form validation
- [ ] Save to Core Data
- [ ] Link back to recognition flow

**Acceptance Criteria**:
- ✅ Form displays with all required fields
- ✅ Validation prevents empty submissions
- ✅ Can add appliance manually
- ✅ Photo can be attached
- ✅ Returns to main flow after save

**Estimate**: 2 days

---

#### Story 1.5: Brand Detection (Nice-to-Have)
```
As a user,
I want the app to detect the brand,
So that I get more accurate results.
```

**Tasks**:
- [ ] Research logo detection approach
  - [ ] Option A: Separate logo detection model
  - [ ] Option B: OCR on brand labels
- [ ] Implement chosen approach
- [ ] Integrate with main recognition flow
- [ ] Test with common brands (GE, Whirlpool, Samsung, LG)

**Acceptance Criteria**:
- ✅ Detects at least 5 major brands
- ✅ Brand detection >70% accurate
- ✅ Falls back gracefully if brand not detected

**Estimate**: 3 days (Optional - can defer to post-MVP)

---

**Epic 1 Total**: 15 days (3 weeks)

---

## Epic 2: Manual System
**Duration**: 3 weeks (Weeks 6-8)
**Dependencies**: Epic 0
**Goal**: Users can view appliance manuals

### User Stories

#### Story 2.1: Manual Database Setup
```
As a developer,
I want a backend API for manuals,
So that we can retrieve manuals by model.
```

**Tasks**:
- [ ] Choose backend approach:
  - [ ] Option A: Simple Flask/FastAPI service
  - [ ] Option B: Firebase/Supabase (no-code backend)
  - [ ] Option C: Static JSON + S3 (MVP approach)
- [ ] Design manual metadata schema
- [ ] Collect 1,000 PDF manuals
  - [ ] Top 100 appliance models
  - [ ] Web scraping script
  - [ ] Manual uploads
- [ ] Store manuals in S3 or cloud storage
- [ ] Create search/lookup endpoint
- [ ] Deploy backend
- [ ] Document API endpoints

**Acceptance Criteria**:
- ✅ 1,000+ manuals in database
- ✅ API returns manual by brand/model
- ✅ PDF URLs accessible
- ✅ API documented

**Estimate**: 5 days

---

#### Story 2.2: Manual API Client
```
As a developer,
I want an API client for manual service,
So that the app can fetch manuals.
```

**Tasks**:
- [ ] Create ManualAPIClient
- [ ] Implement searchManuals(brand:model:)
- [ ] Implement getManual(id:)
- [ ] Add request retry logic
- [ ] Implement response caching (1 hour)
- [ ] Handle network errors
- [ ] Write integration tests
- [ ] Mock client for UI development

**Acceptance Criteria**:
- ✅ Can search manuals by brand/model
- ✅ Can fetch manual metadata
- ✅ Retries on network failure
- ✅ Caches responses appropriately
- ✅ Integration tests pass

**Estimate**: 2 days

---

#### Story 2.3: PDF Viewer
```
As a user,
I want to view appliance manuals,
So that I can learn how to use my appliances.
```

**Tasks**:
- [ ] Create PDFViewerView (SwiftUI + PDFKit)
- [ ] Implement page navigation
- [ ] Add zoom controls
- [ ] Implement swipe gestures (next/prev page)
- [ ] Show page indicator (Page X of Y)
- [ ] Add share button
- [ ] Optimize for visionOS viewing distance
- [ ] Handle large PDFs (lazy loading)

**Acceptance Criteria**:
- ✅ PDF displays correctly
- ✅ Can navigate pages
- ✅ Zoom in/out works
- ✅ Readable at 1-2 meter distance
- ✅ Performance good for 50+ page manuals

**Estimate**: 3 days

---

#### Story 2.4: Manual Search
```
As a user,
I want to search within a manual,
So that I can find specific information quickly.
```

**Tasks**:
- [ ] Implement full-text search using PDFKit
- [ ] Create search UI (search bar)
- [ ] Highlight search results on page
- [ ] Show search result count
- [ ] Navigate between results
- [ ] Clear search functionality

**Acceptance Criteria**:
- ✅ Search finds text in PDF
- ✅ Results highlighted
- ✅ Can navigate between matches
- ✅ Search is reasonably fast (<2s)

**Estimate**: 2 days

---

#### Story 2.5: Manual Caching
```
As a user,
I want manuals saved for offline access,
So that I can view them without internet.
```

**Tasks**:
- [ ] Implement PDF download manager
- [ ] Store PDFs in app documents directory
- [ ] Track downloaded manuals in Core Data (ManualEntity)
- [ ] Show download progress
- [ ] Implement cache eviction (LRU, 10GB limit)
- [ ] Add "Delete Download" option
- [ ] Show offline indicator

**Acceptance Criteria**:
- ✅ Can download manuals
- ✅ Downloads persist across app restarts
- ✅ Can view manuals offline
- ✅ Cache size limited to 10GB
- ✅ Progress indicator during download

**Estimate**: 3 days

---

**Epic 2 Total**: 15 days (3 weeks)

---

## Epic 3: Inventory Management
**Duration**: 2 weeks (Weeks 9-10)
**Dependencies**: Epic 0, Epic 1
**Goal**: Users can maintain a list of all their appliances

### User Stories

#### Story 3.1: Appliance List View
```
As a user,
I want to see all my appliances,
So that I can manage my home inventory.
```

**Tasks**:
- [ ] Create InventoryListView
- [ ] Fetch appliances from Core Data
- [ ] Display in List with:
  - [ ] Photo thumbnail
  - [ ] Brand + Model
  - [ ] Category icon
  - [ ] Status indicator
- [ ] Implement pull-to-refresh
- [ ] Add search/filter by category
- [ ] Sort options (date added, category, brand)
- [ ] Empty state (no appliances yet)

**Acceptance Criteria**:
- ✅ All appliances displayed
- ✅ List updates reactively
- ✅ Search works
- ✅ Empty state shows helpful message

**Estimate**: 2 days

---

#### Story 3.2: Appliance Detail View
```
As a user,
I want to view appliance details,
So that I can see all information about it.
```

**Tasks**:
- [ ] Create ApplianceDetailView
- [ ] Display all fields:
  - [ ] Photo (full size)
  - [ ] Brand, Model, Serial Number
  - [ ] Category
  - [ ] Install Date, Purchase Date, Price
  - [ ] Warranty info
  - [ ] Notes
- [ ] Link to manual (if available)
- [ ] Link to maintenance tasks
- [ ] Link to service history
- [ ] Add Edit and Delete buttons

**Acceptance Criteria**:
- ✅ All appliance data displayed
- ✅ Links work to related data
- ✅ Layout optimized for visionOS

**Estimate**: 2 days

---

#### Story 3.3: Add/Edit Appliance
```
As a user,
I want to add or edit appliance details,
So that I can keep my inventory accurate.
```

**Tasks**:
- [ ] Create ApplianceFormView
- [ ] Implement all form fields
- [ ] Add photo picker
- [ ] Date pickers for install/purchase dates
- [ ] Category picker
- [ ] Form validation
- [ ] Save to Core Data
- [ ] Update existing appliance
- [ ] Handle errors (save failures)

**Acceptance Criteria**:
- ✅ Can add new appliance
- ✅ Can edit existing appliance
- ✅ Photo can be added/changed
- ✅ Validation prevents invalid data
- ✅ Changes saved to Core Data

**Estimate**: 3 days

---

#### Story 3.4: Photo Management
```
As a user,
I want to attach photos to appliances,
So that I have visual records.
```

**Tasks**:
- [ ] Implement photo picker (PhotosUI)
- [ ] Implement camera capture
- [ ] Save photos to encrypted storage
- [ ] Store photo path in Core Data
- [ ] Generate thumbnails
- [ ] Display in list and detail views
- [ ] Delete photo functionality

**Acceptance Criteria**:
- ✅ Can add photo from library or camera
- ✅ Photos persist across app restarts
- ✅ Thumbnails generated automatically
- ✅ Can delete photos

**Estimate**: 2 days

---

#### Story 3.5: CloudKit Sync
```
As a user,
I want my inventory synced across devices,
So that I can access it from iPhone or other devices.
```

**Tasks**:
- [ ] Verify NSPersistentCloudKitContainer setup
- [ ] Test sync between devices
- [ ] Handle sync conflicts (last-write-wins)
- [ ] Show sync status indicator
- [ ] Handle sync errors gracefully
- [ ] Test offline → online sync

**Acceptance Criteria**:
- ✅ Data syncs to iCloud
- ✅ Changes appear on other devices
- ✅ Conflicts resolved automatically
- ✅ Sync status visible to user

**Estimate**: 1 day

---

**Epic 3 Total**: 10 days (2 weeks)

---

## Epic 4: Maintenance System
**Duration**: 2 weeks (Weeks 11-12)
**Dependencies**: Epic 0, Epic 3
**Goal**: Users receive maintenance reminders and can track completion

### User Stories

#### Story 4.1: Maintenance Templates
```
As a developer,
I want predefined maintenance templates,
So that we can auto-generate tasks for appliances.
```

**Tasks**:
- [ ] Define maintenance templates (JSON or code)
  - [ ] HVAC: Filter change (quarterly)
  - [ ] Water heater: Flush (annually)
  - [ ] Dishwasher: Filter clean (monthly)
  - [ ] Dryer: Vent clean (annually)
  - [ ] Refrigerator: Coil clean (semi-annually)
- [ ] Create MaintenanceTemplate model
- [ ] Implement template matching by appliance category
- [ ] Generate tasks from templates
- [ ] Calculate due dates based on install date

**Acceptance Criteria**:
- ✅ Templates defined for 10 appliance categories
- ✅ Tasks auto-generated when appliance added
- ✅ Due dates calculated correctly

**Estimate**: 2 days

---

#### Story 4.2: Maintenance Schedule View
```
As a user,
I want to see upcoming maintenance tasks,
So that I know what needs to be done.
```

**Tasks**:
- [ ] Create MaintenanceScheduleView
- [ ] Fetch tasks from Core Data
- [ ] Group by time period:
  - [ ] Overdue (red)
  - [ ] Due this week (orange)
  - [ ] Due this month (yellow)
  - [ ] Future (gray)
- [ ] Show task details:
  - [ ] Appliance name
  - [ ] Task description
  - [ ] Due date
  - [ ] Estimated time/cost
- [ ] Implement task completion action
- [ ] Filter by appliance

**Acceptance Criteria**:
- ✅ All maintenance tasks displayed
- ✅ Grouped correctly by urgency
- ✅ Color coding matches priority
- ✅ Can mark tasks complete

**Estimate**: 2 days

---

#### Story 4.3: Task Completion
```
As a user,
I want to mark maintenance tasks complete,
So that I can track what I've done.
```

**Tasks**:
- [ ] Create task completion modal
- [ ] Add optional photo capture
- [ ] Add optional notes field
- [ ] Create ServiceHistoryEntity entry
- [ ] Update MaintenanceTask completion date
- [ ] Schedule next occurrence (if recurring)
- [ ] Show completion confirmation

**Acceptance Criteria**:
- ✅ Can mark task complete
- ✅ Can add photo and notes
- ✅ Creates service history entry
- ✅ Recurring tasks reschedule automatically

**Estimate**: 2 days

---

#### Story 4.4: Local Notifications
```
As a user,
I want to receive reminders for maintenance,
So that I don't forget important tasks.
```

**Tasks**:
- [ ] Request notification permissions
- [ ] Create NotificationManager
- [ ] Schedule notifications 1 week before due date
- [ ] Schedule reminder 1 day before due date
- [ ] Schedule overdue notification
- [ ] Handle notification tap (deep link to task)
- [ ] Cancel notifications when task completed
- [ ] Reschedule for recurring tasks

**Acceptance Criteria**:
- ✅ Permission requested on first use
- ✅ Notifications sent at correct times
- ✅ Tapping notification opens task
- ✅ Completed tasks don't send notifications

**Estimate**: 2 days

---

#### Story 4.5: Service History
```
As a user,
I want to view my maintenance history,
So that I know when I last serviced equipment.
```

**Tasks**:
- [ ] Create ServiceHistoryView
- [ ] Display all service records for appliance
- [ ] Show chronologically (newest first)
- [ ] Display:
  - [ ] Date
  - [ ] Task description
  - [ ] Photos
  - [ ] Notes
  - [ ] Cost (if entered)
- [ ] Add manual service entry option
- [ ] Filter/search functionality

**Acceptance Criteria**:
- ✅ All history displayed
- ✅ Sorted by date
- ✅ Photos viewable
- ✅ Can add manual entries

**Estimate**: 2 days

---

**Epic 4 Total**: 10 days (2 weeks)

---

## Epic 5: Integration & Polish
**Duration**: 2 weeks (Weeks 13-14)
**Dependencies**: All previous epics
**Goal**: Connect all features and improve user experience

### User Stories

#### Story 5.1: End-to-End Flow Integration
```
As a user,
I want a seamless experience from recognition to manual,
So that the app feels cohesive.
```

**Tasks**:
- [ ] Connect recognition → inventory (save detected appliance)
- [ ] Connect recognition → manual (fetch manual after detection)
- [ ] Connect inventory → manual (view manual from inventory)
- [ ] Connect inventory → maintenance (view tasks from appliance)
- [ ] Implement proper navigation flows
- [ ] Add deep linking support
- [ ] Test all user journeys end-to-end

**Acceptance Criteria**:
- ✅ Can complete full flow: recognize → save → view manual
- ✅ Can complete: add appliance → view maintenance
- ✅ Navigation is intuitive
- ✅ Deep links work

**Estimate**: 3 days

---

#### Story 5.2: Settings & Preferences
```
As a user,
I want to configure app settings,
So that I can customize my experience.
```

**Tasks**:
- [ ] Create SettingsView
- [ ] Implement preferences:
  - [ ] Notification settings
  - [ ] Default reminder timing
  - [ ] Measurement units (imperial/metric)
  - [ ] Data & Privacy settings
- [ ] Add About section
- [ ] Add Help/FAQ
- [ ] Link to Privacy Policy and Terms
- [ ] Add version number
- [ ] Implement export data functionality

**Acceptance Criteria**:
- ✅ Settings save and persist
- ✅ Changes take effect immediately
- ✅ Can export all user data
- ✅ Links to legal docs work

**Estimate**: 2 days

---

#### Story 5.3: Error Handling & Loading States
```
As a user,
I want clear feedback when things go wrong or are loading,
So that I know what's happening.
```

**Tasks**:
- [ ] Audit all network calls for error handling
- [ ] Add loading indicators everywhere needed
- [ ] Implement error alerts with helpful messages
- [ ] Add retry buttons for failed operations
- [ ] Handle offline state gracefully
- [ ] Add empty states for all lists
- [ ] Implement pull-to-refresh where appropriate

**Acceptance Criteria**:
- ✅ No crashes on network errors
- ✅ Loading states show during operations
- ✅ Error messages are clear and actionable
- ✅ App works offline (with cached data)

**Estimate**: 2 days

---

#### Story 5.4: Performance Optimization
```
As a developer,
I want the app to be fast and responsive,
So that users have a great experience.
```

**Tasks**:
- [ ] Profile with Instruments (Time Profiler)
- [ ] Optimize image loading (thumbnails)
- [ ] Optimize Core Data queries
- [ ] Add pagination for long lists
- [ ] Reduce memory usage
- [ ] Optimize ML model inference
- [ ] Profile battery usage
- [ ] Fix any memory leaks

**Acceptance Criteria**:
- ✅ App launches in <2 seconds
- ✅ Recognition completes in <3 seconds
- ✅ No memory leaks detected
- ✅ Smooth scrolling (60fps)

**Estimate**: 2 days

---

#### Story 5.5: Accessibility
```
As a user with accessibility needs,
I want the app to support VoiceOver and other features,
So that I can use it effectively.
```

**Tasks**:
- [ ] Add accessibility labels to all interactive elements
- [ ] Test with VoiceOver enabled
- [ ] Support Dynamic Type (text sizing)
- [ ] Support Reduce Motion
- [ ] Support High Contrast mode
- [ ] Ensure minimum touch target sizes
- [ ] Test with Accessibility Inspector

**Acceptance Criteria**:
- ✅ VoiceOver works on all screens
- ✅ Text scales with Dynamic Type
- ✅ Animations respect Reduce Motion
- ✅ Passes Accessibility Inspector checks

**Estimate**: 1 day

---

**Epic 5 Total**: 10 days (2 weeks)

---

## Epic 6: Testing & Launch Prep
**Duration**: 2 weeks (Weeks 15-16)
**Dependencies**: Epic 5
**Goal**: Ensure quality and prepare for App Store submission

### User Stories

#### Story 6.1: Comprehensive Testing
```
As a QA tester,
I want to test all features thoroughly,
So that we catch bugs before release.
```

**Tasks**:
- [ ] Write unit tests for all services (target: 80% coverage)
- [ ] Write integration tests for API clients
- [ ] Write UI tests for critical paths:
  - [ ] Recognition flow
  - [ ] Add appliance
  - [ ] View manual
  - [ ] Complete maintenance task
- [ ] Manual testing on Vision Pro device
- [ ] Test all error scenarios
- [ ] Test offline functionality
- [ ] Test iCloud sync
- [ ] Performance testing
- [ ] Memory leak testing

**Acceptance Criteria**:
- ✅ Code coverage >80%
- ✅ All automated tests pass
- ✅ Manual test plan completed
- ✅ No P0 or P1 bugs

**Estimate**: 5 days

---

#### Story 6.2: Bug Fixes
```
As a developer,
I want to fix all critical bugs,
So that the app is stable for launch.
```

**Tasks**:
- [ ] Triage all reported bugs
- [ ] Fix all P0 bugs (blockers)
- [ ] Fix all P1 bugs (critical)
- [ ] Document P2 bugs for post-launch
- [ ] Regression testing after fixes
- [ ] Final QA pass

**Acceptance Criteria**:
- ✅ Zero P0 bugs
- ✅ Zero P1 bugs
- ✅ P2 bugs documented for future

**Estimate**: 3 days

---

#### Story 6.3: App Store Assets
```
As a marketer,
I want compelling App Store assets,
So that users want to download the app.
```

**Tasks**:
- [ ] Write app description (compelling copy)
- [ ] Design app icon (all required sizes)
- [ ] Record demo video (30-60 seconds)
- [ ] Capture screenshots for App Store (5-10 images)
- [ ] Write keywords for ASO
- [ ] Create promotional text
- [ ] Design banner graphics
- [ ] Write What's New text

**Acceptance Criteria**:
- ✅ All required assets created
- ✅ Assets meet Apple guidelines
- ✅ Demo video showcases key features
- ✅ Screenshots are clear and compelling

**Estimate**: 2 days

---

#### Story 6.4: Legal & Privacy
```
As a company,
I want to comply with all legal requirements,
So that we can publish without issues.
```

**Tasks**:
- [ ] Write Privacy Policy
- [ ] Write Terms of Service
- [ ] Host legal docs on website
- [ ] Add privacy manifest to app
- [ ] Complete App Store privacy questionnaire
- [ ] Add required usage descriptions to Info.plist
- [ ] Review GDPR compliance
- [ ] Set up privacy contact email

**Acceptance Criteria**:
- ✅ Privacy policy published
- ✅ Terms of service published
- ✅ Privacy manifest complete
- ✅ App Store questionnaire filled

**Estimate**: 1 day

---

#### Story 6.5: App Store Submission
```
As a developer,
I want to submit to the App Store,
So that users can download the app.
```

**Tasks**:
- [ ] Create App Store Connect listing
- [ ] Upload all assets
- [ ] Set pricing (Free with IAP later)
- [ ] Configure availability (US only for MVP)
- [ ] Select age rating
- [ ] Configure TestFlight for beta
- [ ] Invite beta testers (100 users)
- [ ] Archive and upload build
- [ ] Submit for review
- [ ] Monitor review status

**Acceptance Criteria**:
- ✅ Build uploaded successfully
- ✅ No validation errors
- ✅ Submitted for review
- ✅ TestFlight beta active

**Estimate**: 1 day

---

#### Story 6.6: Launch Preparation
```
As a team,
I want to prepare for launch day,
So that we're ready for users.
```

**Tasks**:
- [ ] Set up analytics (Firebase or similar)
- [ ] Set up crash reporting (Crashlytics)
- [ ] Create support email
- [ ] Prepare FAQ documentation
- [ ] Write launch blog post
- [ ] Prepare social media posts
- [ ] Plan Product Hunt launch
- [ ] Set up user feedback form

**Acceptance Criteria**:
- ✅ Analytics tracking events
- ✅ Crash reports working
- ✅ Support channels ready
- ✅ Launch materials prepared

**Estimate**: 1 day

---

**Epic 6 Total**: 13 days (~2 weeks)

---

## Summary

### Total Timeline
- **Epic 0**: 2 weeks (Project Foundation)
- **Epic 1**: 3 weeks (Appliance Recognition)
- **Epic 2**: 3 weeks (Manual System)
- **Epic 3**: 2 weeks (Inventory Management)
- **Epic 4**: 2 weeks (Maintenance System)
- **Epic 5**: 2 weeks (Integration & Polish)
- **Epic 6**: 2 weeks (Testing & Launch)

**Total**: 16 weeks (4 months)

### Team Requirements
- 2-3 iOS/visionOS developers (full-time)
- 1 UI/UX designer (part-time, weeks 1-2, 13-14)
- 1 QA tester (part-time, weeks 15-16)
- 1 Product Manager (part-time throughout)

### Success Metrics (MVP Launch)
- ✅ App approved by Apple
- ✅ 100 beta testers signed up
- ✅ <5% crash rate
- ✅ 4.0+ star rating
- ✅ 50%+ week-1 retention

---

## Next Steps

1. **Set up project tracking** (GitHub Projects, Jira, or Linear)
2. **Assign epics to developers**
3. **Begin Epic 0** (Project Foundation)
4. **Daily standups** to track progress
5. **Weekly demos** to stakeholders

---

**Document Status**: Ready for Implementation
**Start Date**: [To be determined]
**Target Launch**: [Start date + 16 weeks]
