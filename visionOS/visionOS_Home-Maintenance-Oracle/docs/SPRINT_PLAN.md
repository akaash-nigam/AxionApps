# Sprint Plan - MVP Implementation
## Home Maintenance Oracle

**Version**: 1.0
**Last Updated**: 2025-11-24

---

## Sprint Overview

**Sprint Duration**: 2 weeks
**Total Sprints**: 8 sprints (16 weeks)
**Team Velocity**: Estimate after Sprint 1

---

## Sprint 1: Foundation Setup
**Dates**: Weeks 1-2
**Goal**: Project foundation and infrastructure ready
**Epic**: Epic 0 (Project Foundation & Setup)

### Sprint Backlog

| Task ID | Story | Priority | Estimate | Assignee |
|---------|-------|----------|----------|----------|
| E0-S1-T1 | Create Xcode project for visionOS | P0 | 0.5 days | Dev 1 |
| E0-S1-T2 | Set up Git repository and CI/CD | P0 | 0.5 days | Dev 1 |
| E0-S1-T3 | Configure SwiftLint and SwiftFormat | P0 | 0.5 days | Dev 1 |
| E0-S1-T4 | Set up project folder structure | P0 | 0.5 days | Dev 1 |
| E0-S2-T1 | Create Core Data model | P0 | 1 day | Dev 2 |
| E0-S2-T2 | Implement all entities | P0 | 2 days | Dev 2 |
| E0-S2-T3 | Configure CloudKit container | P0 | 0.5 days | Dev 2 |
| E0-S2-T4 | Add sample data seeding | P1 | 0.5 days | Dev 2 |
| E0-S3-T1 | Create service protocol definitions | P0 | 1 day | Dev 1 |
| E0-S3-T2 | Implement dependency injection | P0 | 0.5 days | Dev 1 |
| E0-S3-T3 | Create mock service implementations | P1 | 1 day | Dev 1 |
| E0-S4-T1 | Create main app navigation structure | P0 | 1 day | Dev 3 |
| E0-S4-T2 | Implement placeholder views | P0 | 1 day | Dev 3 |
| E0-S5-T1 | Set up testing targets | P0 | 0.5 days | Dev 1 |
| E0-S5-T2 | Create README and documentation | P1 | 0.5 days | Dev 1 |

**Sprint Goal Achievement**: ✅ Project builds, Core Data working, navigation in place

---

## Sprint 2: Recognition Foundation
**Dates**: Weeks 3-4
**Goal**: ML model integrated and basic recognition working
**Epic**: Epic 1 (Appliance Recognition) - Part 1

### Sprint Backlog

| Task ID | Story | Priority | Estimate | Assignee |
|---------|-------|----------|----------|----------|
| E1-S1-T1 | Train/obtain ApplianceClassifier model | P0 | 3 days | ML Engineer |
| E1-S1-T2 | Add .mlmodel to project | P0 | 0.5 days | Dev 1 |
| E1-S1-T3 | Create ApplianceClassificationService | P0 | 1 day | Dev 1 |
| E1-S1-T4 | Implement image preprocessing | P0 | 0.5 days | Dev 1 |
| E1-S1-T5 | Add confidence threshold logic | P0 | 0.5 days | Dev 1 |
| E1-S1-T6 | Write unit tests for classifier | P0 | 1 day | Dev 1 |
| E1-S2-T1 | Request camera permissions | P0 | 0.5 days | Dev 2 |
| E1-S2-T2 | Implement ARKit scene setup | P0 | 1 day | Dev 2 |
| E1-S2-T3 | Create camera view with live feed | P0 | 1 day | Dev 2 |
| E1-S2-T4 | Implement image capture | P0 | 0.5 days | Dev 2 |

**Sprint Goal Achievement**: ✅ Can capture images and run ML classification

---

## Sprint 3: Recognition UI Complete
**Dates**: Weeks 5-6
**Goal**: Full recognition flow with UI and fallback
**Epic**: Epic 1 (Appliance Recognition) - Part 2

### Sprint Backlog

| Task ID | Story | Priority | Estimate | Assignee |
|---------|-------|----------|----------|----------|
| E1-S3-T1 | Create RecognitionView UI | P0 | 1 day | Dev 3 |
| E1-S3-T2 | Implement floating result card | P0 | 1 day | Dev 3 |
| E1-S3-T3 | Position card spatially | P0 | 1 day | Dev 3 |
| E1-S3-T4 | Add loading and error states | P0 | 0.5 days | Dev 3 |
| E1-S4-T1 | Create manual entry form | P0 | 1.5 days | Dev 2 |
| E1-S4-T2 | Implement form validation | P0 | 0.5 days | Dev 2 |
| E1-S4-T3 | Save to Core Data | P0 | 0.5 days | Dev 2 |
| E1-S4-T4 | Add photo picker | P1 | 1 day | Dev 2 |
| E1-TEST | Integration testing recognition flow | P0 | 1 day | All |
| E1-POLISH | Bug fixes and polish | P1 | 1 day | All |

**Sprint Goal Achievement**: ✅ Users can recognize appliances or enter manually

---

## Sprint 4: Manual System Backend
**Dates**: Weeks 7-8
**Goal**: Manual database and API working
**Epic**: Epic 2 (Manual System) - Part 1

### Sprint Backlog

| Task ID | Story | Priority | Estimate | Assignee |
|---------|-------|----------|----------|----------|
| E2-S1-T1 | Set up backend (Flask/Firebase) | P0 | 1 day | Backend Dev |
| E2-S1-T2 | Design manual metadata schema | P0 | 0.5 days | Backend Dev |
| E2-S1-T3 | Collect/scrape 1000 manuals | P0 | 3 days | Backend Dev + Help |
| E2-S1-T4 | Upload manuals to S3 | P0 | 0.5 days | Backend Dev |
| E2-S1-T5 | Create search/lookup API | P0 | 1 day | Backend Dev |
| E2-S1-T6 | Deploy backend and document | P0 | 0.5 days | Backend Dev |
| E2-S2-T1 | Create ManualAPIClient | P0 | 1 day | Dev 1 |
| E2-S2-T2 | Implement retry and caching | P0 | 1 day | Dev 1 |
| E2-S2-T3 | Write integration tests | P0 | 1 day | Dev 1 |
| E2-S2-T4 | Create mock client | P1 | 0.5 days | Dev 1 |

**Sprint Goal Achievement**: ✅ Can fetch manuals by brand/model from API

---

## Sprint 5: Manual Viewer Complete
**Dates**: Weeks 9-10
**Goal**: PDF viewer with search and offline support
**Epic**: Epic 2 (Manual System) - Part 2 & Epic 3 Start

### Sprint Backlog

| Task ID | Story | Priority | Estimate | Assignee |
|---------|-------|----------|----------|----------|
| E2-S3-T1 | Create PDFViewerView | P0 | 2 days | Dev 2 |
| E2-S3-T2 | Implement page navigation | P0 | 0.5 days | Dev 2 |
| E2-S3-T3 | Add zoom and gestures | P0 | 1 day | Dev 2 |
| E2-S3-T4 | Optimize for visionOS | P0 | 0.5 days | Dev 2 |
| E2-S4-T1 | Implement PDF search | P1 | 1.5 days | Dev 1 |
| E2-S4-T2 | Highlight search results | P1 | 0.5 days | Dev 1 |
| E2-S5-T1 | Implement PDF download manager | P0 | 2 days | Dev 1 |
| E2-S5-T2 | Implement cache management | P0 | 1 day | Dev 1 |
| E3-S1-T1 | START: Create InventoryListView | P0 | 1 day | Dev 3 |

**Sprint Goal Achievement**: ✅ Manual system fully functional with offline support

---

## Sprint 6: Inventory Management
**Dates**: Weeks 11-12
**Goal**: Complete inventory CRUD and CloudKit sync
**Epic**: Epic 3 (Inventory Management)

### Sprint Backlog

| Task ID | Story | Priority | Estimate | Assignee |
|---------|-------|----------|----------|----------|
| E3-S1-T2 | Implement search and filter | P0 | 1 day | Dev 3 |
| E3-S1-T3 | Add sort options | P1 | 0.5 days | Dev 3 |
| E3-S2-T1 | Create ApplianceDetailView | P0 | 1.5 days | Dev 3 |
| E3-S2-T2 | Link to manual and maintenance | P0 | 0.5 days | Dev 3 |
| E3-S3-T1 | Create ApplianceFormView | P0 | 2 days | Dev 2 |
| E3-S3-T2 | Implement validation | P0 | 0.5 days | Dev 2 |
| E3-S4-T1 | Implement photo picker | P0 | 1 day | Dev 1 |
| E3-S4-T2 | Implement photo storage | P0 | 1 day | Dev 1 |
| E3-S5-T1 | Test CloudKit sync | P0 | 1 day | All |
| E3-TEST | End-to-end inventory testing | P0 | 1 day | All |

**Sprint Goal Achievement**: ✅ Full inventory management with sync

---

## Sprint 7: Maintenance System
**Dates**: Weeks 13-14
**Goal**: Maintenance scheduling and notifications working
**Epic**: Epic 4 (Maintenance System)

### Sprint Backlog

| Task ID | Story | Priority | Estimate | Assignee |
|---------|-------|----------|----------|----------|
| E4-S1-T1 | Define maintenance templates | P0 | 1 day | Dev 1 |
| E4-S1-T2 | Implement template matching | P0 | 1 day | Dev 1 |
| E4-S1-T3 | Generate tasks from templates | P0 | 1 day | Dev 1 |
| E4-S2-T1 | Create MaintenanceScheduleView | P0 | 1.5 days | Dev 3 |
| E4-S2-T2 | Implement grouping and filtering | P0 | 0.5 days | Dev 3 |
| E4-S3-T1 | Create task completion modal | P0 | 1 day | Dev 2 |
| E4-S3-T2 | Implement photo and notes | P0 | 1 day | Dev 2 |
| E4-S3-T3 | Create service history entry | P0 | 0.5 days | Dev 2 |
| E4-S4-T1 | Implement NotificationManager | P0 | 1.5 days | Dev 1 |
| E4-S4-T2 | Schedule notifications | P0 | 1 day | Dev 1 |
| E4-S5-T1 | Create ServiceHistoryView | P1 | 1 day | Dev 3 |

**Sprint Goal Achievement**: ✅ Maintenance reminders and tracking complete

---

## Sprint 8: Polish & Testing
**Dates**: Weeks 15-16
**Goal**: Bug-free, polished app ready for App Store
**Epic**: Epic 5 & Epic 6 (Integration, Polish, Testing)

### Sprint Backlog

| Task ID | Story | Priority | Estimate | Assignee |
|---------|-------|----------|----------|----------|
| E5-S1-T1 | Connect all flows end-to-end | P0 | 2 days | All |
| E5-S1-T2 | Implement deep linking | P1 | 1 day | Dev 1 |
| E5-S2-T1 | Create SettingsView | P0 | 1 day | Dev 3 |
| E5-S2-T2 | Implement all preferences | P0 | 1 day | Dev 3 |
| E5-S3-T1 | Add error handling everywhere | P0 | 1 day | All |
| E5-S3-T2 | Add loading states | P0 | 0.5 days | All |
| E5-S4-T1 | Performance profiling | P0 | 1 day | Dev 1 |
| E5-S4-T2 | Optimize hot paths | P0 | 1 day | Dev 1 |
| E5-S5-T1 | Accessibility audit | P0 | 1 day | Dev 3 |
| E6-S1-T1 | Write all unit tests | P0 | 2 days | All |
| E6-S1-T2 | Write UI tests | P0 | 1 day | All |
| E6-S2-T1 | Bug triage and fixes | P0 | 2 days | All |
| E6-S3-T1 | Create App Store assets | P0 | 1 day | Designer |
| E6-S4-T1 | Write legal docs | P0 | 1 day | PM |
| E6-S5-T1 | Submit to App Store | P0 | 1 day | PM |

**Sprint Goal Achievement**: ✅ App submitted to App Store

---

## Daily Standup Format

**Time**: 9:00 AM daily (15 minutes max)

**Each team member answers**:
1. What did I complete yesterday?
2. What am I working on today?
3. Any blockers?

**Example**:
```
Dev 1:
- Yesterday: Completed Core Data setup (E0-S2-T2)
- Today: Starting service protocols (E0-S3-T1)
- Blockers: None

Dev 2:
- Yesterday: Set up CloudKit container (E0-S2-T3)
- Today: Adding sample data seeding (E0-S2-T4)
- Blockers: Need CloudKit credentials
```

---

## Sprint Ceremonies

### Sprint Planning (First day of sprint)
- **Duration**: 2 hours
- **Attendees**: Full team
- **Agenda**:
  1. Review sprint goal
  2. Review backlog items
  3. Estimate tasks (story points or days)
  4. Assign tasks to developers
  5. Identify risks

### Daily Standup
- **Duration**: 15 minutes
- **Attendees**: Full team
- **Format**: See above

### Sprint Review (Last day of sprint)
- **Duration**: 1 hour
- **Attendees**: Team + stakeholders
- **Agenda**:
  1. Demo completed features
  2. Review sprint metrics
  3. Discuss what worked/didn't work

### Sprint Retrospective (Last day of sprint)
- **Duration**: 1 hour
- **Attendees**: Team only
- **Agenda**:
  1. What went well?
  2. What could be improved?
  3. Action items for next sprint

---

## Sprint Metrics to Track

### Velocity
- **Story points completed per sprint**
- Track over time to predict capacity

### Burndown Chart
- **Tasks remaining vs. days left**
- Updated daily

### Bug Metrics
- **Bugs found per sprint**
- **Bugs fixed per sprint**
- **Open bug count by priority**

### Quality Metrics
- **Code coverage %**
- **Test pass rate**
- **Crash rate (post-launch)**

---

## Risk Management

### Sprint 1 Risks
- **Risk**: Team unfamiliar with visionOS
- **Mitigation**: Allocate extra time for learning, pair programming

### Sprint 2-3 Risks
- **Risk**: ML model accuracy insufficient
- **Mitigation**: Have fallback to manual entry, collect training data early

### Sprint 4 Risks
- **Risk**: Manual collection takes longer than expected
- **Mitigation**: Start scraping early, consider buying manual database

### Sprint 8 Risks
- **Risk**: App Store rejection
- **Mitigation**: Review guidelines early, submit beta for pre-review

---

## Communication Plan

### Slack Channels
- `#hmo-dev` - Development discussions
- `#hmo-standup` - Daily standup notes
- `#hmo-bugs` - Bug reports
- `#hmo-general` - General project chat

### Weekly Team Meeting
- **When**: Fridays 2:00 PM
- **Duration**: 30 minutes
- **Agenda**: Week recap, next week preview, blockers

### Monthly All-Hands
- **When**: Last Friday of month
- **Duration**: 1 hour
- **Agenda**: Roadmap updates, demos, Q&A

---

## Definition of Done

A task is "Done" when:
- ✅ Code written and reviewed
- ✅ Unit tests written and passing
- ✅ Integrated with main branch
- ✅ Manually tested on device
- ✅ No known bugs
- ✅ Documented (if needed)
- ✅ Accepted by Product Owner

---

## Sprint Success Criteria

### Sprint 1
- ✅ App builds and runs
- ✅ Core Data saves/loads data
- ✅ Navigation works
- ✅ Tests run

### Sprint 2
- ✅ ML model runs inference
- ✅ Camera captures images
- ✅ Can classify test images >80% accuracy

### Sprint 3
- ✅ Recognition UI complete
- ✅ Manual entry works
- ✅ Can save appliances to inventory

### Sprint 4
- ✅ Manual API deployed
- ✅ Can fetch manuals by model
- ✅ API client working

### Sprint 5
- ✅ Can view PDFs
- ✅ Search works
- ✅ Offline caching works

### Sprint 6
- ✅ Full inventory CRUD
- ✅ CloudKit sync working
- ✅ Photos persist

### Sprint 7
- ✅ Maintenance tasks generate automatically
- ✅ Notifications send on time
- ✅ Can complete tasks

### Sprint 8
- ✅ All features integrated
- ✅ All tests passing
- ✅ Submitted to App Store

---

**Document Status**: Ready to Start
**Next Action**: Schedule Sprint 1 Planning Meeting
