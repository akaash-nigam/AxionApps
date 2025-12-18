# MVP & Epic Breakdown

## MVP (Minimum Viable Product) - 8 Weeks

### MVP Goal
Prove the core value proposition: **Users can learn vocabulary naturally by seeing their environment labeled in their target language and practicing with an AI conversation partner.**

### MVP Scope

#### What's IN the MVP ✅
1. **Object Labeling** (Basic)
   - Detect and label 100 common household objects
   - Single label mode (word + pronunciation)
   - Tap to hear pronunciation
   - One language (Spanish)

2. **AI Conversation** (Basic)
   - One AI character (Maria - Spanish tutor)
   - Free-form conversation (no scenarios)
   - Speech recognition and response
   - Basic error correction

3. **Core Infrastructure**
   - User account (Sign in with Apple)
   - Basic onboarding flow
   - Language selection (Spanish only for MVP)
   - Simple settings

4. **Minimal Progress Tracking**
   - Words encountered counter
   - Conversation time tracker
   - Simple streak counter

#### What's OUT of MVP ❌
- Multiple languages
- Themed environments
- Structured scenarios
- Advanced grammar analysis
- Pronunciation coach with waveforms
- Gamification/achievements
- Social features
- Offline mode
- Advanced analytics
- Multiple characters

### MVP Success Metrics
- **Technical**: 60fps, <5s scene load, <2s AI response
- **User**: 70% complete onboarding, 40% return next day
- **Learning**: Users encounter 20+ new words per session

---

## Epic Breakdown (Post-MVP)

### Epic 1: Multi-Language Support
**Goal**: Expand to 5 core languages
**Timeline**: 2 weeks after MVP
**Effort**: Medium

#### Features
- French language pack
- Japanese language pack
- German language pack
- Mandarin language pack
- Language switching in-app
- Per-language progress tracking

#### User Stories
- As a polyglot, I want to switch between languages so I can practice multiple languages
- As a French learner, I want the same features as Spanish learners

#### Acceptance Criteria
- All 5 languages have complete vocabulary databases (5K+ words each)
- All languages have TTS voices
- All languages have AI conversation support
- Users can switch languages without losing progress

#### Dependencies
- Translation databases for all languages
- TTS voice IDs for each language
- Grammar rule sets per language

---

### Epic 2: Immersive Environments
**Goal**: Transform user's space into cultural locations
**Timeline**: 3 weeks
**Effort**: High

#### Features
- 3 themed environments:
  - Parisian Café (French)
  - Madrid Tapas Bar (Spanish)
  - Tokyo Ramen Shop (Japanese)
- Environment download system
- Progressive loading
- Ambient audio (background chatter, music)
- Interactive objects in environments

#### User Stories
- As a language learner, I want to feel like I'm in a French café so learning feels more immersive
- As a visual learner, I want culturally authentic environments to understand context

#### Acceptance Criteria
- Environments load in <10 seconds
- Ambient audio plays spatially
- At least 10 interactive objects per environment
- Environment persists between sessions
- Download size <200MB per environment

#### Technical Requirements
- 3D environment models (USDZ)
- Spatial audio system
- Asset streaming
- Storage management (600MB total)

---

### Epic 3: Structured Scenarios
**Goal**: Guided conversation practice for specific situations
**Timeline**: 3 weeks
**Effort**: High

#### Features
- 15 conversation scenarios across categories:
  - Daily Life (5): Café, restaurant, shopping, directions, small talk
  - Travel (5): Hotel, airport, taxi, tourist info, emergency
  - Professional (5): Job interview, meeting, phone call, presentation, networking
- Scenario objectives and completion tracking
- Context-aware AI responses
- Scenario-specific vocabulary lists
- Difficulty levels per scenario

#### User Stories
- As a traveler, I want to practice ordering food so I'm prepared for my trip
- As a job seeker, I want to practice interview questions in my target language
- As a beginner, I want structured guidance instead of free-form conversation

#### Acceptance Criteria
- 15 scenarios implemented with objectives
- AI stays in character and context
- Users can see progress through scenario objectives
- Scenarios unlock based on proficiency level
- Vocabulary from scenarios saved to user's list

---

### Epic 4: Advanced Grammar System
**Goal**: Real-time grammar analysis and teaching
**Timeline**: 2 weeks
**Effort**: Medium

#### Features
- Real-time grammar error detection
- Floating grammar cards with explanations
- Grammar rule library (100+ rules per language)
- Correction timing options (immediate, after sentence, end of session)
- Grammar practice exercises
- Common mistakes tracking
- Grammar progress dashboard

#### User Stories
- As an intermediate learner, I want to know when I make grammar mistakes
- As a student, I want to understand why something is wrong, not just what's wrong
- As an advanced learner, I want to track my common mistakes

#### Acceptance Criteria
- Detect 20+ common grammar error types
- Display corrections within 500ms
- Grammar cards don't interrupt conversation flow
- Users can review mistakes after session
- Grammar rules link to relevant exercises

#### Technical Requirements
- Natural Language Framework integration
- Grammar rule database per language
- Real-time text analysis pipeline

---

### Epic 5: Pronunciation Coach
**Goal**: Help users perfect their accent
**Timeline**: 3 weeks
**Effort**: High

#### Features
- Phoneme-level analysis
- Visual waveform comparison (user vs. native)
- 3D mouth position guide
- Pronunciation scoring (0-100)
- Difficult sound identification
- Targeted pronunciation drills
- Progress tracking over time
- Record and playback

#### User Stories
- As a Spanish learner, I want to master the rolled "r" sound
- As someone working on accent, I want to see exactly where my pronunciation differs
- As a perfectionist, I want to track pronunciation improvement over time

#### Acceptance Criteria
- Analyze pronunciation within 1 second
- Visual feedback shows exact differences
- Score accuracy correlates with native speaker judgement
- Drill exercises for 10+ difficult sounds per language
- Users can review pronunciation history

#### Technical Requirements
- Phoneme extraction from speech
- Audio waveform analysis (FFT)
- ARKit face tracking for mouth position
- Visual feedback rendering

---

### Epic 6: Progress & Analytics Dashboard
**Goal**: Comprehensive learning analytics
**Timeline**: 2 weeks
**Effort**: Medium

#### Features
- Detailed statistics dashboard:
  - Study time (daily, weekly, monthly)
  - Words learned (new, reviewing, mastered)
  - Conversation metrics (count, duration, score)
  - Grammar accuracy trends
  - Pronunciation improvement
  - Skill breakdown (listening, speaking, reading, writing)
- Streak tracking with reminders
- Learning goals and milestones
- Exportable progress reports
- Comparison to other learners (anonymous)

#### User Stories
- As a data-driven learner, I want to see detailed statistics on my progress
- As someone with goals, I want to track if I'm on pace to reach fluency
- As a motivated user, I want to see my improvement over time

#### Acceptance Criteria
- Dashboard loads in <2 seconds
- All metrics update in real-time
- Export progress as PDF or CSV
- Charts show trends over time (7d, 30d, 90d, all-time)
- Goals are customizable

---

### Epic 7: Spaced Repetition System (SRS)
**Goal**: Optimize vocabulary retention
**Timeline**: 2 weeks
**Effort**: Medium

#### Features
- SM-2 algorithm implementation
- Daily vocabulary review sessions
- Review queue management
- Difficulty adjustment based on performance
- Review reminders
- Statistics (retention rate, ease factor)

#### User Stories
- As a language learner, I want to review words before I forget them
- As someone who forgets vocabulary, I want an optimized review schedule
- As a busy person, I want to know exactly what to review each day

#### Acceptance Criteria
- Words scheduled according to SM-2 algorithm
- Review queue shows due cards
- Performance affects next review interval
- Users can review anywhere (not just in immersive mode)
- Review sessions are 5-15 minutes

---

### Epic 8: Multiple AI Characters
**Goal**: Variety in conversation partners
**Timeline**: 2 weeks
**Effort**: Medium

#### Features
- 10 AI characters across languages:
  - Spanish: Maria (tutor), Carlos (friend), Ana (businesswoman)
  - French: Jean-Luc (professor), Sophie (artist)
  - Japanese: Yuki (student), Hiroshi (salaryman)
  - German: Hans (engineer), Greta (doctor)
  - Mandarin: Wei (entrepreneur)
- Unique personalities and conversation styles
- Character-specific vocabulary and topics
- Character selection UI
- Character favorites

#### User Stories
- As a learner, I want variety in conversation partners to stay engaged
- As someone learning for business, I want to practice with a business professional
- As a casual learner, I want a friendly character who speaks slowly

#### Acceptance Criteria
- 10 characters with unique 3D models
- Each character has distinct personality
- Characters use appropriate vocabulary for their role
- Users can switch characters mid-session
- Character bios explain background and speaking style

---

### Epic 9: Cultural Education
**Goal**: Teach culture alongside language
**Timeline**: 2 weeks
**Effort**: Medium

#### Features
- Cultural notes integrated into conversations
- Etiquette lessons (greetings, dining, business)
- Gesture recognition and feedback
- Holiday and tradition explanations
- Regional variations (Spain Spanish vs. Mexican)
- Cultural quizzes
- Country/region information

#### User Stories
- As a traveler, I want to understand cultural norms to avoid mistakes
- As a language learner, I want to know when to use formal vs. informal language
- As someone interested in culture, I want to learn beyond just vocabulary

#### Acceptance Criteria
- 100+ cultural tips per language
- Tips appear contextually during conversations
- Gesture recognition for common gestures (bowing, handshakes)
- Culture quiz with 50+ questions per language
- Regional variations explained clearly

---

### Epic 10: Offline Mode
**Goal**: Learn without internet connection
**Timeline**: 2 weeks
**Effort**: Medium

#### Features
- Download language packs for offline use
- Offline object labeling (full support)
- Pre-generated conversation paths (limited)
- Offline pronunciation analysis
- Offline grammar checking (basic rules)
- Queue sync when back online

#### User Stories
- As a traveler, I want to practice on the plane without WiFi
- As someone with limited data, I want to download everything at home
- As a user in poor coverage areas, I want reliable functionality

#### Acceptance Criteria
- Full language pack downloadable (<300MB)
- Object labeling works 100% offline
- At least 20 pre-scripted conversation paths offline
- Pronunciation and grammar work with reduced functionality
- Data syncs automatically when connection restored

---

### Epic 11: Social & Gamification
**Goal**: Increase engagement through social and game elements
**Timeline**: 3 weeks
**Effort**: High

#### Features
- Achievement system (50+ badges)
- Leaderboards (friends, global)
- Challenges (daily, weekly)
- XP and leveling system
- Friend system (add friends, compare progress)
- Shareable milestones
- In-app celebrations (streaks, milestones)

#### User Stories
- As a competitive person, I want to compare my progress with friends
- As someone who needs motivation, I want achievements and rewards
- As a social learner, I want to share my progress

#### Acceptance Criteria
- 50 unique achievements
- Leaderboards update in real-time
- Daily challenges refresh at midnight
- Users can add friends via username or QR code
- Privacy controls for leaderboard visibility

---

### Epic 12: Premium Features & Monetization
**Goal**: Sustainable business model
**Timeline**: 2 weeks
**Effort**: Medium

#### Features
- Subscription tiers (Free, Premium, Family)
- In-app purchase flow
- Premium features:
  - All languages (Free: 1 language)
  - Unlimited conversations (Free: 10/week)
  - All environments (Free: 1)
  - Advanced analytics
  - Offline mode
  - Priority support
- Family sharing (up to 6 members)
- Restore purchases

#### User Stories
- As a serious learner, I'm willing to pay for unlimited access
- As a family, we want to share a subscription
- As a free user, I want to try before buying

#### Acceptance Criteria
- StoreKit 2 integration
- Clear feature comparison chart
- Free tier has meaningful functionality
- Upgrade prompts are non-intrusive
- Family sharing works across devices

---

## Implementation Priority

### Phase 1: MVP (Weeks 1-8)
**Goal**: Prove core value proposition

### Phase 2: Core Enhancement (Weeks 9-14)
1. **Epic 1**: Multi-Language Support
2. **Epic 4**: Advanced Grammar System
3. **Epic 7**: Spaced Repetition System

### Phase 3: Immersion & Structure (Weeks 15-20)
4. **Epic 2**: Immersive Environments
5. **Epic 3**: Structured Scenarios

### Phase 4: Quality & Depth (Weeks 21-28)
6. **Epic 5**: Pronunciation Coach
7. **Epic 6**: Progress & Analytics
8. **Epic 8**: Multiple Characters

### Phase 5: Engagement (Post-Launch Month 1-2)
9. **Epic 9**: Cultural Education
10. **Epic 11**: Social & Gamification

### Phase 6: Sustainability (Post-Launch Month 2-3)
11. **Epic 10**: Offline Mode
12. **Epic 12**: Premium Features

---

## MVP vs. Full Product Comparison

| Feature | MVP | Full Product |
|---------|-----|--------------|
| **Languages** | 1 (Spanish) | 50+ |
| **Objects Detected** | 100 | 5,000+ |
| **AI Characters** | 1 | 20+ |
| **Environments** | 0 (user's room only) | 30+ |
| **Scenarios** | 0 (free-form only) | 100+ |
| **Grammar System** | Basic corrections | Advanced with practice |
| **Pronunciation** | Basic playback | Detailed coach with visuals |
| **Progress Tracking** | Simple counters | Comprehensive analytics |
| **Social Features** | None | Friends, leaderboards |
| **Offline Mode** | No | Yes |
| **Subscription** | Free only | Free + Premium tiers |

---

## Next Steps

1. **Review MVP scope** - Ensure team alignment on what's in/out
2. **Set up development environment** - Xcode project, dependencies
3. **Create Jira/Linear epics** - Break down into stories and tasks
4. **Assign sprint 1 work** - Start with foundation (auth, data layer)
5. **Begin MVP development** - Follow 8-week plan

Ready to start Sprint 1? 🚀
