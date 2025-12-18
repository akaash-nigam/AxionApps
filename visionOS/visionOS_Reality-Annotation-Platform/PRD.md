# Product Requirements Document: Reality Annotation Platform

## Executive Summary

Reality Annotation Platform enables users to leave virtual notes in physical space that persist over time, appear at specific times or conditions, and have different visibility for different people—creating a layer of digital information overlaid on the physical world through Apple Vision Pro.

## Product Vision

Transform how we interact with physical spaces by enabling persistent, contextual digital annotations that blend seamlessly with reality, creating new possibilities for communication, memory, productivity, and creativity.

## Target Users

### Primary Users
- Families leaving notes for each other at home
- Property managers annotating maintenance issues
- Event planners marking setup locations
- Teachers creating educational overlays in classrooms
- Museums curating exhibition experiences

### Secondary Users
- Realtors showcasing property features
- Contractors documenting work progress
- Filmmakers marking camera positions
- Urban explorers documenting discoveries

## Market Opportunity

- AR/VR content market: $300B by 2028
- Spatial computing is enabling new use cases
- No established platform for persistent AR annotations
- First-mover advantage in emerging category

## Core Features

### 1. Spatial Notes & Annotations

**Description**: Leave virtual sticky notes, text, drawings, photos, or voice memos anchored to specific locations in physical space

**User Stories**:
- As a parent, I want to leave a note on the fridge for my kids
- As a property manager, I want to mark maintenance issues
- As a student, I want to add study notes to my textbooks

**Acceptance Criteria**:
- Multiple annotation types: Text, drawing, photo, voice, video, 3D object
- Precise spatial anchoring (stays in exact position)
- Persistent across sessions (saved to cloud)
- Edit and delete annotations
- Rich formatting (fonts, colors, sizes)
- Attach files (PDFs, images, videos)
- Ownership and permissions

**Technical Requirements**:
- ARKit World Tracking for spatial anchors
- CloudKit for cloud storage and sync
- RealityKit for rendering annotations
- Persistent AR anchors (ARWorldMap)
- On-device and cloud storage

**Annotation Types**:
```
1. Text Note
   ┌────────────────┐
   │ 📝 Remember to │
   │ buy milk!      │
   │ - Mom          │
   └────────────────┘

2. Drawing
   [Freehand arrow pointing to light switch]
   "This switch controls outdoor lights"

3. Photo
   [Image of paint swatch attached to wall]
   "Chosen color for living room"

4. Voice Memo
   🎤 [2:30] "Installation instructions for new TV mount"

5. Video
   📹 [1:45] "How to operate the thermostat"

6. 3D Object
   [3D model of furniture] "Proposed sofa placement"

Placement:
- Surface anchor: Attached to wall, floor, table
- Floating: Hovers in mid-air
- Object anchor: Attached to specific object (e.g., appliance)

Properties:
- Position: XYZ coordinates in room
- Orientation: Facing direction
- Scale: Size (adjustable)
- Color: Customizable
- Icon: Visual identifier
- Content: The actual note/media
- Metadata: Creator, created date, modified date
```

### 2. Time-Based Visibility

**Description**: Annotations appear or disappear based on time, date, or conditions

**User Stories**:
- As a parent, I want a bedtime reminder to appear at 8 PM
- As a planner, I want setup instructions to only show on event day
- As a teacher, I want lesson notes to appear during class time only

**Acceptance Criteria**:
- Time triggers: Specific time, time range, recurring schedule
- Date triggers: Specific date, date range, recurring (weekly, monthly)
- Condition triggers: Location (GPS), weather, device state
- Expiration: Auto-delete after certain time
- Countdown timers visible on annotations
- Preview mode: See future/past annotations

**Time-Based Rules**:
```
Time Triggers:
- Specific Time: "Show at 6:00 PM"
- Time Range: "Visible 9 AM - 5 PM"
- Recurring: "Every weekday at 7 AM"
- Sunset/Sunrise: "Appears at sunset"

Date Triggers:
- Specific Date: "Show on Dec 25, 2024"
- Date Range: "Visible Nov 1 - Nov 30"
- Recurring: "Every Monday"
- Seasonal: "Spring months only"

Condition Triggers:
- Location: "Show when within 50 feet"
- Weather: "Appears when raining"
- Device: "Show when iPhone connected to home WiFi"
- Event: "Visible during calendar event"

Expiration:
- Duration: "Delete after 7 days"
- Read count: "Delete after viewed 3 times"
- Event-based: "Delete after event ends"
- Manual: "Never expire"

Examples:
┌───────────────────────────┐
│ ⏰ Bedtime Reminder       │
│ "Brush teeth and read!"   │
│                           │
│ Appears: 8:00 PM daily    │
│ Expires: 8:30 PM          │
│ For: Kids (age < 12)      │
└───────────────────────────┘

┌───────────────────────────┐
│ 🎉 Party Setup            │
│ "Place DJ booth here"     │
│                           │
│ Visible: Dec 31, 4 PM     │
│ Expires: Jan 1, 2 AM      │
│ For: Event staff only     │
└───────────────────────────┘

┌───────────────────────────┐
│ 📚 Lesson Plan            │
│ "Topic: Photosynthesis"   │
│                           │
│ Visible: Mon 10-11 AM     │
│ Recurring: Weekly         │
│ For: Biology class only   │
└───────────────────────────┘
```

### 3. Multi-User Visibility & Permissions

**Description**: Control who can see, edit, or delete annotations

**User Stories**:
- As a parent, I want to leave notes only my spouse can see
- As a property manager, I want tenants to see some notes but not internal ones
- As a team lead, I want to share project notes with the team

**Acceptance Criteria**:
- Visibility levels: Public, private, shared (specific users)
- Permissions: View, comment, edit, delete
- User groups: Family, team, public, custom
- Inheritance: Child annotations inherit parent permissions
- Share link: Invite others to view/collaborate
- Anonymous viewing option

**Permission System**:
```
Visibility Levels:
1. Private (Only Me)
   - Only creator can see
   - Useful for personal reminders

2. Shared (Specific Users)
   - Invite by email/username
   - Set individual permissions per user
   - Useful for family, teams

3. Group (Predefined Groups)
   - Family group
   - Work team
   - Custom groups
   - Useful for recurring collaborators

4. Public (Anyone with App)
   - Visible to all app users in that space
   - Useful for public information, events

5. Link Sharing
   - Generate shareable link
   - Optional password protection
   - Expiration date on link

Permissions Matrix:
┌──────────┬──────┬─────────┬──────┬────────┐
│ User     │ View │ Comment │ Edit │ Delete │
├──────────┼──────┼─────────┼──────┼────────┤
│ Owner    │  ✓   │    ✓    │  ✓   │   ✓    │
│ Editor   │  ✓   │    ✓    │  ✓   │   ✗    │
│ Commenter│  ✓   │    ✓    │  ✗   │   ✗    │
│ Viewer   │  ✓   │    ✗    │  ✗   │   ✗    │
└──────────┴──────┴─────────┴──────┴────────┘

Examples:
┌───────────────────────────┐
│ 💑 Date Night Plans       │
│ "Surprise dinner at 7 PM" │
│                           │
│ Visible to: Spouse only   │
│ Permissions: View only    │
└───────────────────────────┘

┌───────────────────────────┐
│ 🔧 Maintenance Issue      │
│ "Leaky faucet in apt 3B"  │
│                           │
│ Visible to:               │
│ • Maintenance team (Edit) │
│ • Property manager (All)  │
│ Hidden from: Tenants      │
└───────────────────────────┘

┌───────────────────────────┐
│ 📍 Public Art Installation│
│ "Sculpture: 'Unity' 2024" │
│                           │
│ Visible to: Public        │
│ Comments: Enabled         │
│ Edits: Creator only       │
└───────────────────────────┘
```

### 4. Spatial Layers & Channels

**Description**: Organize annotations into thematic layers that can be toggled on/off

**User Stories**:
- As a teacher, I want separate layers for each subject
- As a homeowner, I want to separate maintenance notes from family messages
- As an event planner, I want to organize by event stages (setup, during, teardown)

**Acceptance Criteria**:
- Create custom layers/channels
- Toggle layers on/off individually
- Layer-specific permissions
- Color-coded layers
- Filter by layer
- Layer templates (home, work, education, events)
- Import/export layers

**Layer System**:
```
Layer Categories:
1. Personal
   - Family Messages
   - Personal Reminders
   - Private Notes

2. Home
   - Maintenance
   - Renovations
   - Smart Home Controls

3. Work
   - Projects
   - Meetings
   - Tasks

4. Events
   - Setup
   - During Event
   - Teardown

5. Education
   - Lesson Plans
   - Student Notes
   - Resources

6. Public
   - Community Info
   - Local History
   - Art Installations

Layer Controls:
┌────────────────────────────┐
│ Active Layers              │
├────────────────────────────┤
│ ✓ 👨‍👩‍👧 Family (12 notes)  │
│ ✓ 🔧 Maintenance (3)       │
│ ✗ 🎨 Renovation Ideas (8)  │
│ ✗ 🎉 Party Planning (0)    │
│                            │
│ [+ Create Layer]           │
└────────────────────────────┘

Layer Properties:
Name: Maintenance
Color: 🟠 Orange
Icon: 🔧
Visibility: Family members only
Permissions: All can add, only owner can delete
Expiration: Notes expire after 30 days

Layer Filtering:
- Show only: Maintenance layer
- Hide: Family messages
- Show multiple: Maintenance + Renovation

Templates:
"Home Management" Template:
- 🏠 General Notes
- 🔧 Maintenance & Repairs
- 🛒 Shopping Lists
- 📅 Events & Reminders
- 💡 Ideas & Inspirations
```

### 5. Search & Discovery

**Description**: Find annotations by location, content, time, or creator

**User Stories**:
- As a user, I want to find all notes I created last month
- As a property manager, I want to see all maintenance annotations
- As a teacher, I want to search notes by topic

**Acceptance Criteria**:
- Text search across all notes
- Filter by: Date, creator, type, layer, location
- Spatial search: "Find notes within 10 feet"
- Map view: See all annotations on floor plan
- Timeline view: See annotations chronologically
- Tag system for categorization
- Recently viewed notes

**Search Features**:
```
Search Interface:
┌────────────────────────────┐
│ 🔍 Search Annotations      │
├────────────────────────────┤
│ [Search text...]           │
│                            │
│ Filters:                   │
│ • Type: [All] ▼            │
│ • Layer: [All] ▼           │
│ • Creator: [All] ▼         │
│ • Date: [Any time] ▼       │
│ • Location: [Anywhere] ▼   │
│                            │
│ Results: 23 found          │
└────────────────────────────┘

Advanced Search:
- Text: "leaky faucet"
- Type: Maintenance annotations only
- Creator: Property manager
- Date range: Last 30 days
- Location: Bathroom areas only
- Has attachment: Yes
- Status: Unresolved

Spatial Search:
"Find all notes within 10 feet of current location"
Results displayed as glowing beacons in space

Map View:
[Top-down floor plan]
- Dots represent annotation locations
- Color-coded by layer
- Size indicates importance or recency
- Tap dot to view annotation

Timeline View:
┌────────────────────────────┐
│ November 2024              │
├────────────────────────────┤
│ Nov 25 • Bedtime reminder  │
│ Nov 24 • Fix light switch  │
│ Nov 22 • Party planning    │
│ Nov 20 • Grocery list      │
│ ...                        │
│                            │
│ [Load More]                │
└────────────────────────────┘

Tags:
#urgent #maintenance #family #work
#event #reminder #idea #question

Smart Collections:
- Recent (Last 7 days)
- Unread
- Starred/Favorited
- Expiring Soon
- Needs Action
- Created by Me
- Shared with Me
```

### 6. Collaboration & Comments

**Description**: Enable conversations around annotations

**User Stories**:
- As a team member, I want to discuss a project note
- As a family member, I want to confirm I saw a message
- As a teacher, I want students to respond to questions

**Acceptance Criteria**:
- Comment threads on annotations
- Reactions (like, heart, thumbs up)
- @mentions to notify specific users
- Mark as resolved
- Read receipts (who has seen)
- Activity notifications
- Collaborative editing (multiple users edit same note)

**Collaboration Features**:
```
Comment Thread:
┌────────────────────────────┐
│ 📝 Original Note           │
│ "Should we repaint the     │
│  living room?"             │
│ - Sarah, Nov 20            │
│                            │
│ 💬 Comments (3):           │
│                            │
│ John: "Yes! I'm thinking   │
│ light gray"                │
│ Nov 21, 10:30 AM           │
│                            │
│ Sarah: "@John sounds good! │
│ Let's get samples"         │
│ Nov 21, 2:15 PM            │
│                            │
│ Emma: ❤️ reacted           │
│                            │
│ [Add Comment]              │
└────────────────────────────┘

Reactions:
👍 3  ❤️ 2  😂 1  🎉 1

Status:
- ⏳ Open
- ✅ Resolved
- 🚫 Won't Fix
- 🔄 In Progress

Notifications:
- "John commented on 'Repaint living room?'"
- "Sarah mentioned you in a note"
- "New note added in Maintenance layer"

Read Receipts:
Seen by:
- ✓ John (2 hours ago)
- ✓ Sarah (1 hour ago)
- Emma (not yet)

Activity Feed:
┌────────────────────────────┐
│ 📊 Recent Activity         │
├────────────────────────────┤
│ 5 min ago                  │
│ John added "Party setup"   │
│                            │
│ 1 hour ago                 │
│ Sarah commented on note    │
│                            │
│ 3 hours ago                │
│ You created "Grocery list" │
│                            │
│ Yesterday                  │
│ Emma marked note resolved  │
└────────────────────────────┘
```

## User Experience

### Onboarding
1. Welcome to Reality Annotation Platform
2. Tutorial: Create first note (on fridge)
3. Tutorial: Set time-based visibility (bedtime reminder)
4. Tutorial: Share with family member
5. Tutorial: Create layer (Family Messages)
6. Ready to annotate your world

### Daily Usage
1. Morning: See breakfast reminder on kitchen counter
2. Leave note for spouse on bathroom mirror
3. At work: Review project annotations in conference room
4. Evening: Kids see bedtime routine notes appear at 8 PM
5. Add maintenance note to broken light switch
6. Check tomorrow's annotations in preview mode

### Gesture & Voice Controls

```
Gestures:
- Tap in space: Create new annotation
- Look + tap annotation: View/edit
- Pinch + drag: Move annotation
- Two-hand scale: Resize annotation
- Swipe annotation: Delete

Voice:
- "Create note here"
- "Show all annotations"
- "Hide maintenance layer"
- "Find notes from last week"
- "Share this note with Sarah"
```

## Design Specifications

### Visual Design

**Color Palette**:
- Note colors: User-customizable (yellow, blue, pink, green, etc.)
- Layer colors: Distinct per layer
- UI: Minimal, transparent overlays

**Typography**:
- Handwriting: Bradley Hand, Marker Felt
- Print: SF Pro, Helvetica
- Monospace: SF Mono

### Spatial Layout
- Annotations float at comfortable viewing height (4-6 ft)
- Auto-orient to face user
- Cluster nearby annotations
- Minimize visual clutter (fade distant notes)

## Technical Architecture

### Platform
- Apple Vision Pro (visionOS 2.0+)
- Companion iOS app (create/manage annotations)

### Key Technologies
- ARKit: Spatial anchors, world tracking
- RealityKit: 3D rendering
- CloudKit: Cloud storage and sync
- SharePlay: Real-time collaboration (optional)

### Performance
- Max annotations visible: 100 simultaneously
- Anchor precision: ±5 cm
- Cloud sync: < 5 seconds
- Load time: < 2 seconds

## Monetization Strategy

**Pricing**:
- **Free**: 25 annotations, 1 layer, private only
- **Plus**: $4.99/month or $49/year
  - Unlimited annotations
  - Unlimited layers
  - Sharing and collaboration
  - Time-based visibility
  - Advanced search
- **Family**: $9.99/month (up to 6 users)
- **Pro**: $14.99/month (businesses, educators)
  - Team management
  - Analytics
  - API access

**Target Revenue**:
- Year 1: $1M (20,000 users @ $50 ARPU)
- Year 2: $6M (100,000 users)
- Year 3: $18M (300,000 users)

## Success Metrics

- MAU: 100,000 in Year 1
- Annotations created: 5M+ in Year 1
- Premium conversion: 15%
- Daily active: 40%
- NPS: > 60

## Launch Strategy

**Phase 1**: Beta - Early adopters (1,000 users)
**Phase 2**: Launch - Public release
**Phase 3**: Growth - Education/business partnerships

## Success Criteria
- 200,000 users in 12 months
- Featured by Apple
- Case studies in education, real estate, events
- API partnerships (museums, retail)

## Appendix

### Use Cases

**Home**:
- Family messages
- Chore reminders
- Home maintenance tracking
- Smart home annotations

**Education**:
- Lesson overlays in classroom
- Study notes on textbooks
- Campus wayfinding
- Lab instructions

**Work**:
- Meeting room annotations
- Project collaboration
- Facility management
- Safety notices

**Events**:
- Setup instructions
- Vendor locations
- Schedule displays
- Attendee messages

**Public Spaces**:
- Historical information (museums, monuments)
- Wayfinding (malls, airports)
- Art installations
- Community boards

### Privacy & Security
- All annotations encrypted
- Granular privacy controls
- No location tracking without permission
- GDPR compliant
- Content moderation for public annotations
