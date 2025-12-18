# MVP Definition & Phased Roadmap
## Home Maintenance Oracle

**Version**: 1.0
**Last Updated**: 2025-11-24
**Status**: Draft

---

## MVP Scope (Version 1.0)

### Core Features Only

**Goal**: Prove the concept with minimal viable features

**Timeline**: 3-4 months

**Team Size**: 2-3 developers + 1 designer

---

## MVP Feature Set

### ✅ INCLUDED in MVP

#### 1. Appliance Recognition (Basic)
- **Categories**: Top 10 only (refrigerator, oven, dishwasher, washer, dryer, HVAC, water heater, microwave, thermostat, garage door)
- **Accuracy Target**: 85%+ (lower than PRD's 90%)
- **Fallback**: Manual entry when recognition fails
- **Brands**: Top 5 (GE, Whirlpool, Samsung, LG, Bosch)

#### 2. Manual Viewer (Simple)
- **Database**: 1,000 most common models
- **Format**: PDF viewer only (no advanced features)
- **Search**: Basic keyword search within document
- **Offline**: Downloaded manuals cached locally

#### 3. Maintenance Schedule (Basic)
- **Tasks**: Predefined templates only
- **Reminders**: Local notifications (no calendar integration)
- **Frequency**: Fixed intervals (no smart scheduling)
- **Tracking**: Simple completion checkmarks

#### 4. Home Inventory (Essential)
- **Storage**: Core Data + iCloud sync
- **Fields**: Brand, model, install date, photo
- **Views**: List view only (no 3D room view)
- **Export**: JSON export

### ❌ EXCLUDED from MVP (Phase 2+)

- AR video tutorials (too complex for MVP)
- Part recognition and ordering (requires extensive database)
- Voice commands (nice-to-have)
- Multi-property support
- Advanced analytics
- Contractor referrals
- Smart maintenance scheduling (ML-based)
- Social features (sharing, reviews)

---

## MVP User Stories

### Priority 1 (Must Have)

```
As a homeowner,
I want to point my Vision Pro at my dishwasher,
So that I can see its manual without searching.

Acceptance:
- Recognition works for top 10 appliances
- Manual displays within 5 seconds
- Manual is readable and searchable
```

```
As a homeowner,
I want to see when my HVAC filter needs changing,
So that I don't forget maintenance.

Acceptance:
- Maintenance tasks auto-generated for appliances
- Notifications sent 1 week before due date
- Can mark tasks as complete
```

```
As a homeowner,
I want to track all my appliances,
So that I have a record for insurance.

Acceptance:
- Can add/edit/delete appliances
- Can take photos of appliances
- Data syncs across devices
```

### Priority 2 (Should Have)

```
As a homeowner,
I want to search my manual,
So that I can find specific information quickly.

Acceptance:
- Full-text search works
- Results highlighted
- Can bookmark pages
```

```
As a homeowner,
I want to see my maintenance history,
So that I know when I last serviced equipment.

Acceptance:
- History shows completed tasks
- Can add photos to history entries
- Can filter by appliance
```

---

## Technical Scope

### MVP Architecture (Simplified)

```
┌─────────────────────────────────┐
│     visionOS App (SwiftUI)      │
│  - Recognition View             │
│  - Manual Viewer                │
│  - Inventory List               │
│  - Settings                     │
└─────────────────────────────────┘
           │
           ▼
┌─────────────────────────────────┐
│       Local Services            │
│  - Core ML Recognition          │
│  - Core Data Storage            │
│  - PDF Rendering                │
│  - Notification Manager         │
└─────────────────────────────────┘
           │
           ▼
┌─────────────────────────────────┐
│       External Services         │
│  - Manual API (simple REST)     │
│  - CloudKit (iCloud sync)       │
└─────────────────────────────────┘
```

**Simplified from Full Architecture**:
- No microservices (monolithic is fine)
- No CDN (direct API calls)
- No complex caching (simple file cache)
- No advanced ML pipeline (use pre-trained models)

### MVP Tech Stack

| Component | Technology | Rationale |
|-----------|-----------|-----------|
| UI Framework | SwiftUI | Native, rapid development |
| 3D/Spatial | RealityKit (basic) | Minimal 3D, focus on 2D windows |
| ML | Core ML + Vision | Apple's frameworks, no custom training |
| Database | Core Data | Built-in, proven |
| Sync | CloudKit | Free, easy setup |
| Backend | Simple REST API | Python Flask or Node.js |
| Hosting | Heroku or Render | Quick deployment |

---

## Development Phases

## Phase 0: Setup & Research (Weeks 1-2)

### Week 1: Project Setup
- [ ] Create Xcode project
- [ ] Set up Git repository
- [ ] Configure Core Data model
- [ ] Set up CloudKit container
- [ ] Create basic app structure

### Week 2: Research & Prototyping
- [ ] Test Core ML with sample images
- [ ] Prototype PDF viewer
- [ ] Design basic UI screens
- [ ] Gather 100 test images for recognition
- [ ] Find 100 sample manuals

**Deliverable**: Working prototype with mock data

---

## Phase 1: Core Recognition (Weeks 3-5)

### Week 3: ML Model
- [ ] Train appliance classifier (10 categories)
- [ ] Convert to Core ML
- [ ] Test on device
- [ ] Achieve 80%+ accuracy on test set

### Week 4: Recognition UI
- [ ] Implement camera view
- [ ] Add recognition overlay
- [ ] Show confidence scores
- [ ] Add manual entry fallback

### Week 5: Polish & Testing
- [ ] Handle edge cases (low light, partial view)
- [ ] Add loading states
- [ ] Write unit tests
- [ ] User testing with 5 people

**Deliverable**: Working appliance recognition

**Success Metrics**:
- Recognition accuracy > 80%
- Response time < 3 seconds
- User can identify appliance in < 1 minute

---

## Phase 2: Manual System (Weeks 6-8)

### Week 6: Manual Database
- [ ] Build REST API for manuals
- [ ] Scrape/collect 1,000 manuals
- [ ] Create database schema
- [ ] Implement search endpoint

### Week 7: Manual Viewer
- [ ] Implement PDF viewer
- [ ] Add zoom/pan
- [ ] Add search functionality
- [ ] Implement offline caching

### Week 8: Integration
- [ ] Connect recognition to manual fetch
- [ ] Handle missing manuals gracefully
- [ ] Add manual metadata display
- [ ] Performance optimization

**Deliverable**: End-to-end recognition → manual flow

**Success Metrics**:
- Manual found rate > 60%
- Load time < 5 seconds
- PDF readable and searchable

---

## Phase 3: Inventory & Persistence (Weeks 9-10)

### Week 9: Core Data Implementation
- [ ] Implement ApplianceEntity CRUD
- [ ] Add photo storage
- [ ] Set up CloudKit sync
- [ ] Implement list view

### Week 10: Inventory UI
- [ ] Build appliance list screen
- [ ] Add appliance detail view
- [ ] Implement add/edit forms
- [ ] Add photo capture

**Deliverable**: Full inventory management

**Success Metrics**:
- Can add appliance in < 30 seconds
- Photos saved and synced
- No data loss

---

## Phase 4: Maintenance System (Weeks 11-12)

### Week 11: Maintenance Logic
- [ ] Define maintenance templates
- [ ] Implement schedule generation
- [ ] Set up local notifications
- [ ] Create MaintenanceTask entities

### Week 12: Maintenance UI
- [ ] Build maintenance schedule view
- [ ] Add task completion flow
- [ ] Show upcoming/overdue tasks
- [ ] Add history view

**Deliverable**: Basic maintenance tracking

**Success Metrics**:
- Notifications sent on time
- Users can complete tasks
- History persists

---

## Phase 5: Polish & Testing (Weeks 13-14)

### Week 13: Bug Fixes & Optimization
- [ ] Fix all P0/P1 bugs
- [ ] Optimize performance
- [ ] Improve error handling
- [ ] Add analytics (Crashlytics)

### Week 14: User Testing
- [ ] Internal testing (team)
- [ ] External beta (20 users)
- [ ] Gather feedback
- [ ] Final bug fixes

**Deliverable**: Beta-ready app

---

## Phase 6: Launch Prep (Weeks 15-16)

### Week 15: App Store Prep
- [ ] Create App Store listing
- [ ] Record demo video
- [ ] Design screenshots
- [ ] Write app description
- [ ] Prepare privacy policy

### Week 16: Final Testing & Submission
- [ ] Final QA pass
- [ ] App Store submission
- [ ] TestFlight beta
- [ ] Prepare launch materials

**Deliverable**: MVP v1.0 on App Store

---

## Success Criteria for MVP

### Must Achieve:
- ✅ 100 active beta users
- ✅ 80%+ recognition accuracy
- ✅ 60%+ manual found rate
- ✅ <5% crash rate
- ✅ 4.0+ star rating (beta)
- ✅ 50%+ user retention (week 1)

### Nice to Have:
- 500 beta signups
- Media coverage (1 article)
- 10+ positive App Store reviews

---

## Post-MVP Roadmap (Phases 2-4)

## Phase 2: Enhanced Features (Months 5-6)

### New Features:
- **Video Tutorials** (non-AR initially)
  - YouTube integration
  - Curated tutorial library
  - 1,000+ videos

- **Basic Part Search**
  - Amazon API integration
  - Simple part search by model
  - Price comparison

- **Enhanced Recognition**
  - 20 appliance categories (full list)
  - 90%+ accuracy
  - Brand/model detection

**Timeline**: 2 months
**Team**: +1 developer (3-4 total)

---

## Phase 3: AR & Advanced Features (Months 7-9)

### New Features:
- **AR Video Overlays**
  - Spatial video playback
  - 3D annotations
  - Step-by-step mode

- **Part Recognition**
  - Visual part identification
  - Part compatibility checker

- **Voice Commands**
  - Natural language processing
  - Hands-free operation

- **3D Room View**
  - Spatial inventory map
  - AR appliance locations

**Timeline**: 3 months
**Team**: +1 designer, +1 ML engineer (5-6 total)

---

## Phase 4: Business Features (Months 10-12)

### New Features:
- **Property Manager Tier**
  - Multi-property support
  - Team collaboration
  - Vendor management

- **Contractor Network**
  - Pro referrals
  - Quote requests
  - Booking integration

- **Smart Scheduling**
  - ML-based predictions
  - Usage pattern analysis
  - Seasonal adjustments

- **Analytics Dashboard**
  - Cost tracking
  - Equipment insights
  - Replacement planning

**Timeline**: 3 months
**Team**: +2 developers (7-8 total)

---

## Resource Requirements

### MVP Phase (Months 1-4)

**Team**:
- 2 iOS/visionOS developers
- 1 UI/UX designer
- 1 PM/Product (part-time)

**Budget**:
- Developer salaries: $80K (4 months)
- Apple Developer: $99/year
- Cloud hosting: $50/month
- API costs: $100/month
- **Total**: ~$85K

### Post-MVP (Months 5-12)

**Team**:
- 4-6 developers
- 2 designers
- 1 PM
- 1 ML engineer

**Budget**:
- Salaries: $500K/year
- Cloud infrastructure: $500/month
- API costs: $1,000/month
- Marketing: $10K/month
- **Total**: ~$630K

---

## Risk Mitigation

### High-Risk Items

| Risk | Impact | Mitigation |
|------|--------|-----------|
| Vision Pro adoption low | High | Build iOS companion app |
| ML accuracy insufficient | High | Manual entry fallback + user feedback loop |
| Manual database incomplete | Medium | Crowdsource + partnerships |
| Performance issues | Medium | Aggressive optimization + profiling |
| App Store rejection | Medium | Follow guidelines strictly, pre-review |

---

## Launch Strategy

### Soft Launch (Week 16)
- TestFlight beta (500 invites)
- Product Hunt post
- Reddit communities (r/homeowners, r/visionPro)
- Tech blogger outreach

### Public Launch (Month 5)
- App Store release
- Press release
- Demo video viral attempt
- Partnership announcements

### Growth (Months 6-12)
- Content marketing (blog)
- SEO optimization
- Referral program
- Paid ads (if budget allows)

---

**Document Status**: Ready for Review
**Next Steps**: Validate assumptions with user interviews, refine scope, commit to timeline
