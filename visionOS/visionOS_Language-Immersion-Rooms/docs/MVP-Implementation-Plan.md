# MVP Implementation Plan (8 Weeks)

## MVP Goal
Build a working prototype that demonstrates core value: **Natural vocabulary learning through spatial object labeling + AI conversation practice**

**Target Launch**: Beta test with 50 users after Week 8

---

## Week 1: Foundation & Setup

### Sprint Goal
Set up project infrastructure and core services

### Tasks

#### Project Setup (Day 1)
- [ ] Create Xcode project for visionOS
- [ ] Configure Git repository
- [ ] Set up .gitignore for Swift/Xcode
- [ ] Create development branch structure
- [ ] Configure Swift Package Manager
- [ ] Add dependencies (none external for MVP)

#### App Structure (Day 1-2)
- [ ] Create app entry point (`LanguageImmersionApp.swift`)
- [ ] Set up WindowGroup for main menu
- [ ] Set up ImmersiveSpace for learning
- [ ] Create basic navigation structure
- [ ] Implement app lifecycle management

#### Data Layer (Day 2-3)
- [ ] Create CoreData model file
- [ ] Define entities: User, VocabularyWord, Conversation, ConversationMessage
- [ ] Implement PersistenceController
- [ ] Create data repository pattern
- [ ] Write unit tests for data layer

#### Authentication (Day 3-4)
- [ ] Implement Sign in with Apple
- [ ] Create UserProfile model
- [ ] Build simple onboarding flow (3 screens)
- [ ] Save user session to Keychain
- [ ] Create welcome screen

#### State Management (Day 4-5)
- [ ] Create AppState class (Observation)
- [ ] Create SceneManager class
- [ ] Implement state persistence
- [ ] Add UserDefaults for preferences
- [ ] Test state restoration

**Deliverable**: Running app with authentication and data persistence

---

## Week 2: Object Detection & Labeling

### Sprint Goal
Detect objects and display Spanish labels

### Tasks

#### Object Detection Setup (Day 1-2)
- [ ] Configure ARKit scene understanding
- [ ] Implement object detection (Vision framework)
- [ ] Create ObjectDetector service
- [ ] Build vocabulary database (100 common objects)
- [ ] Map detected objects to Spanish translations

#### Label Entity System (Day 2-3)
- [ ] Create ObjectLabelEntity (RealityKit)
- [ ] Generate 3D text meshes
- [ ] Implement world anchor system
- [ ] Position labels relative to objects
- [ ] Add label visibility toggle

#### Label Interaction (Day 3-4)
- [ ] Implement tap gesture on labels
- [ ] Add pronunciation audio playback
- [ ] Generate/download pronunciation audio (100 words)
- [ ] Add audio caching
- [ ] Test spatial audio positioning

#### Label UI (Day 4-5)
- [ ] Create room scanning UI
- [ ] Build object list view
- [ ] Add label customization (size, color)
- [ ] Implement label enable/disable
- [ ] Create simple settings panel

**Deliverable**: Working object labeling with audio pronunciation

---

## Week 3: AI Conversation Foundation

### Sprint Goal
Integrate OpenAI and enable basic conversation

### Tasks

#### OpenAI Integration (Day 1-2)
- [ ] Set up OpenAI API client
- [ ] Store API key in Keychain
- [ ] Implement chat completion request
- [ ] Add error handling and retries
- [ ] Test with various prompts

#### Speech Recognition (Day 2-3)
- [ ] Implement Apple Speech Framework
- [ ] Request microphone permissions
- [ ] Create SpeechRecognizer service
- [ ] Add real-time transcription
- [ ] Test recognition accuracy (Spanish)

#### Conversation Logic (Day 3-4)
- [ ] Create ConversationController
- [ ] Implement message history
- [ ] Build AI prompt for "Maria" character
- [ ] Add context management (last 10 messages)
- [ ] Implement conversation state machine

#### Text-to-Speech (Day 4-5)
- [ ] Integrate ElevenLabs API (or AVSpeechSynthesizer for MVP)
- [ ] Select Spanish voice
- [ ] Implement audio playback
- [ ] Add speech queue management
- [ ] Cache generated audio

**Deliverable**: Working text conversation with AI

---

## Week 4: AI Character & Conversation UI

### Sprint Goal
Add 3D character and polished conversation interface

### Tasks

#### 3D Character (Day 1-2)
- [ ] Find/create simple 3D character model (or use placeholder)
- [ ] Create AICharacterEntity
- [ ] Position character in scene (4 feet from user)
- [ ] Add idle animation
- [ ] Add basic lip-sync or speaking animation

#### Conversation UI (Day 2-3)
- [ ] Create ConversationBottomBar view
- [ ] Add microphone button with visual feedback
- [ ] Display conversation history (last 3 messages)
- [ ] Show character avatar
- [ ] Add loading indicators

#### Speech Integration (Day 3-4)
- [ ] Connect speech recognition to UI
- [ ] Add transcription display (real-time)
- [ ] Connect TTS to character
- [ ] Sync character animation with speech
- [ ] Add conversation controls (start/stop)

#### Basic Error Correction (Day 4-5)
- [ ] Implement simple grammar checking
- [ ] Create basic GrammarCard view
- [ ] Display corrections after user speaks
- [ ] Add "dismiss" action
- [ ] Log errors for tracking

**Deliverable**: Full conversation experience with 3D character

---

## Week 5: Progress Tracking & Polish

### Sprint Goal
Add progress tracking and improve UX

### Tasks

#### Progress System (Day 1-2)
- [ ] Track words encountered
- [ ] Track conversation time
- [ ] Implement simple streak counter
- [ ] Save progress to CoreData
- [ ] Create ProgressTracker service

#### Progress UI (Day 2-3)
- [ ] Build simple progress view
- [ ] Show today's statistics
- [ ] Display streak
- [ ] Show vocabulary count
- [ ] Add celebration for milestones

#### Main Menu (Day 3-4)
- [ ] Create polished main menu UI
- [ ] Add "Start Session" button
- [ ] Show daily progress card
- [ ] Add quick stats overview
- [ ] Implement settings navigation

#### Onboarding Flow (Day 4-5)
- [ ] Create welcome screens (3 pages)
- [ ] Add language selection (Spanish only for now)
- [ ] Build proficiency assessment (simple)
- [ ] Create room scanning tutorial
- [ ] Add skip option

**Deliverable**: Complete user flow from onboarding to session

---

## Week 6: Testing & Bug Fixes

### Sprint Goal
Ensure stability and fix critical bugs

### Tasks

#### Unit Testing (Day 1-2)
- [ ] Write tests for VocabularyService
- [ ] Write tests for ConversationController
- [ ] Write tests for ObjectDetector
- [ ] Write tests for data models
- [ ] Achieve 60% code coverage

#### Integration Testing (Day 2-3)
- [ ] Test object detection → label flow
- [ ] Test conversation → correction flow
- [ ] Test progress tracking end-to-end
- [ ] Test authentication flow
- [ ] Test data persistence

#### UI Testing (Day 3-4)
- [ ] Write XCUITests for onboarding
- [ ] Test main menu navigation
- [ ] Test conversation UI interactions
- [ ] Test settings changes
- [ ] Verify accessibility

#### Bug Fixes (Day 4-5)
- [ ] Fix all critical bugs
- [ ] Fix high-priority bugs
- [ ] Improve error messages
- [ ] Add loading states where missing
- [ ] Polish animations and transitions

**Deliverable**: Stable, tested MVP

---

## Week 7: Performance & Optimization

### Sprint Goal
Meet performance targets

### Tasks

#### Performance Profiling (Day 1-2)
- [ ] Profile app launch time (target: <5s)
- [ ] Profile scene loading (target: <10s)
- [ ] Profile memory usage (target: <1GB)
- [ ] Profile frame rate (target: >60fps)
- [ ] Identify bottlenecks

#### Optimization (Day 2-4)
- [ ] Optimize object detection speed
- [ ] Reduce label creation time
- [ ] Optimize texture loading
- [ ] Implement asset caching
- [ ] Reduce API call latency
- [ ] Optimize database queries

#### Polish (Day 4-5)
- [ ] Add smooth transitions
- [ ] Improve animation timing
- [ ] Add haptic feedback
- [ ] Polish visual design
- [ ] Test on actual Vision Pro hardware (if available)

**Deliverable**: Performant, polished MVP

---

## Week 8: Beta Preparation & Launch

### Sprint Goal
Prepare for beta testing

### Tasks

#### Documentation (Day 1)
- [ ] Write user guide
- [ ] Create FAQ
- [ ] Document known issues
- [ ] Write beta tester instructions
- [ ] Create feedback form

#### App Store Assets (Day 2)
- [ ] Take screenshots (5+ images)
- [ ] Record demo video (30-60 seconds)
- [ ] Write App Store description
- [ ] Create app icon
- [ ] Prepare privacy policy

#### Beta Setup (Day 3)
- [ ] Create TestFlight build
- [ ] Set up beta testing group (50 users)
- [ ] Configure crash reporting
- [ ] Set up analytics (basic)
- [ ] Create feedback collection system

#### Final Testing (Day 4)
- [ ] Full regression test
- [ ] Test on multiple scenarios
- [ ] Verify all flows work
- [ ] Check performance metrics
- [ ] Get team approval

#### Beta Launch (Day 5)
- [ ] Upload to TestFlight
- [ ] Invite beta testers
- [ ] Send welcome email with instructions
- [ ] Monitor initial feedback
- [ ] Prepare for iteration

**Deliverable**: MVP in beta testing with 50 users

---

## MVP Feature Checklist

### Must-Have (P0) ✅
- [x] Sign in with Apple
- [x] Detect 100 common objects
- [x] Display Spanish labels
- [x] Tap label to hear pronunciation
- [x] AI conversation with Maria
- [x] Speech recognition (Spanish)
- [x] Basic grammar corrections
- [x] Track words encountered
- [x] Track conversation time
- [x] Simple streak counter
- [x] Onboarding flow
- [x] Main menu
- [x] Progress view
- [x] Settings panel

### Nice-to-Have (P1) 🔶
- [ ] Label animations
- [ ] Character emotions
- [ ] Better error messages
- [ ] Haptic feedback
- [ ] Dark mode support

### Future (P2) 📋
- [ ] Multiple label modes
- [ ] Conversation scenarios
- [ ] Advanced grammar
- [ ] Pronunciation coach
- [ ] Multiple characters

---

## Success Criteria

### Technical
- ✅ App launches in <5 seconds
- ✅ Frame rate >60fps
- ✅ Object detection <2 seconds for room
- ✅ AI response <2 seconds
- ✅ Memory usage <1GB
- ✅ Zero crashes in 10 test sessions

### User Experience
- ✅ 80% complete onboarding
- ✅ 60% try conversation feature
- ✅ Average session >10 minutes
- ✅ 40% return next day
- ✅ 4+ star satisfaction rating

### Learning
- ✅ Users encounter 20+ words per session
- ✅ Users complete 1+ conversations
- ✅ 50% of users maintain 3+ day streak

---

## Team Roles (Suggested)

### Week 1-2
- **Developer 1**: Foundation, Auth, Data Layer
- **Developer 2**: Object Detection, Labels
- **Designer**: UI mockups, onboarding flow

### Week 3-4
- **Developer 1**: AI Integration, Speech
- **Developer 2**: Character, Conversation UI
- **Designer**: Polish UI, animations

### Week 5-6
- **Developer 1**: Progress tracking, Main menu
- **Developer 2**: Testing, Bug fixes
- **QA**: Test plan execution

### Week 7-8
- **Developer 1**: Optimization, Polish
- **Developer 2**: Beta prep, Documentation
- **PM**: TestFlight setup, Beta coordination

---

## Daily Standup Format

**What did you complete yesterday?**
**What will you work on today?**
**Any blockers?**

---

## Risk Management

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| OpenAI API too expensive | Medium | High | Set usage limits, cache responses |
| Object detection inaccurate | Medium | High | Use Vision framework, manual fallback |
| Speech recognition poor | Low | High | Use Apple's framework, test extensively |
| Performance issues | Medium | Medium | Profile early, optimize continuously |
| Beta users don't engage | Medium | Medium | Clear instructions, active support |

---

## Post-MVP Priorities

After successful beta (50 users, 4+ stars):
1. **Epic 1**: Add French and Japanese (2 weeks)
2. **Epic 4**: Advanced Grammar System (2 weeks)
3. **Epic 7**: Spaced Repetition (2 weeks)
4. Expand beta to 500 users
5. Prepare for App Store launch

---

Ready to begin Week 1? 🚀

Next Step: Create Xcode project and set up Git repository
