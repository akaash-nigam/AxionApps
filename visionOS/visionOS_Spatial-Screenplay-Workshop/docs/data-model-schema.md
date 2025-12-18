# Data Model & Schema Design

## Overview

This document defines the complete data model for Spatial Screenplay Workshop, including core entities, relationships, persistence strategies, and file formats.

## Core Data Models

### 1. Project

The top-level container for a screenplay.

```swift
struct Project: Identifiable, Codable {
    let id: UUID
    var title: String
    var logline: String
    var type: ProjectType
    var createdAt: Date
    var modifiedAt: Date
    var author: String
    var metadata: ProjectMetadata
    var settings: ProjectSettings
    var scenes: [Scene]
    var characters: [Character]
    var locations: [Location]
    var storyboards: [Storyboard]
    var collaborators: [Collaborator]
    var versionHistory: [Version]
}

enum ProjectType: String, Codable {
    case featureFilm        // 90-120 pages
    case tvPilotOneHour     // 50-65 pages
    case tvPilotHalfHour    // 25-35 pages
    case shortFilm          // 5-15 pages
    case tvEpisode
}

struct ProjectMetadata: Codable {
    var genre: String?
    var targetPageCount: Int?
    var currentPageCount: Int
    var wordCount: Int
    var sceneCount: Int
    var characterCount: Int
    var status: ProjectStatus
    var tags: [String]
}

enum ProjectStatus: String, Codable {
    case outline
    case firstDraft
    case revision
    case locked
    case production
}

struct ProjectSettings: Codable {
    var defaultFont: String = "Courier"
    var fontSize: Int = 12
    var pageSize: PageSize = .letter
    var colorCodingMode: ColorCodingMode = .location
    var autoSaveInterval: TimeInterval = 300 // 5 minutes
    var revisionColor: RevisionColor = .white
}

enum PageSize: String, Codable {
    case letter  // US standard
    case a4      // International
}

enum ColorCodingMode: String, Codable {
    case location
    case timeOfDay
    case character
    case storyThread
    case status
}

enum RevisionColor: String, Codable {
    case white, blue, pink, yellow, green, goldenrod, buff, salmon, cherry
}
```

### 2. Scene

Individual scenes that form the screenplay.

```swift
struct Scene: Identifiable, Codable {
    let id: UUID
    var sceneNumber: Int
    var slugLine: SlugLine
    var content: SceneContent
    var characters: [UUID] // Character IDs
    var locationId: UUID?
    var pageLength: Double
    var status: SceneStatus
    var position: ScenePosition
    var metadata: SceneMetadata
    var notes: [Note]
    var revisions: [Revision]
    var createdAt: Date
    var modifiedAt: Date
}

struct SlugLine: Codable {
    var setting: Setting  // INT or EXT
    var location: String  // COFFEE SHOP
    var timeOfDay: TimeOfDay  // DAY, NIGHT, etc.

    var formatted: String {
        "\(setting.rawValue). \(location.uppercased()) - \(timeOfDay.rawValue)"
    }
}

enum Setting: String, Codable {
    case INT = "INT"
    case EXT = "EXT"
    case INT_EXT = "INT./EXT"
    case EXT_INT = "EXT./INT"
}

enum TimeOfDay: String, Codable {
    case day = "DAY"
    case night = "NIGHT"
    case morning = "MORNING"
    case afternoon = "AFTERNOON"
    case evening = "EVENING"
    case dawn = "DAWN"
    case dusk = "DUSK"
    case later = "LATER"
    case continuous = "CONTINUOUS"
    case moments_later = "MOMENTS LATER"
}

struct SceneContent: Codable {
    var elements: [ScriptElement]
}

enum ScriptElement: Codable {
    case action(ActionElement)
    case dialogue(DialogueElement)
    case transition(TransitionElement)
    case shot(ShotElement)

    struct ActionElement: Codable {
        var text: String
        var isCharacterIntro: Bool = false
    }

    struct DialogueElement: Codable {
        var characterId: UUID
        var characterName: String
        var parenthetical: String?
        var lines: [String]
        var isDualDialogue: Bool = false
    }

    struct TransitionElement: Codable {
        var type: TransitionType
        var customText: String?
    }

    struct ShotElement: Codable {
        var text: String
    }
}

enum TransitionType: String, Codable {
    case cutTo = "CUT TO:"
    case fadeTo = "FADE TO:"
    case dissolve = "DISSOLVE TO:"
    case fadeIn = "FADE IN:"
    case fadeOut = "FADE OUT:"
    case smashCut = "SMASH CUT TO:"
    case jumpCut = "JUMP CUT TO:"
    case custom
}

enum SceneStatus: String, Codable {
    case draft
    case revised
    case locked
    case needsWork
    case approved
}

struct ScenePosition: Codable {
    var act: Int
    var sequence: Int?
    var spatialPosition: SpatialCoordinates?
}

struct SpatialCoordinates: Codable {
    var x: Float
    var y: Float
    var z: Float
    var rotation: Float
}

struct SceneMetadata: Codable {
    var summary: String?
    var mood: String?
    var storyThread: String?
    var importance: SceneImportance
    var estimatedDuration: TimeInterval?
    var shotCount: Int?
}

enum SceneImportance: String, Codable {
    case critical
    case important
    case supporting
    case optional
}
```

### 3. Character

Character profiles with voice and appearance settings.

```swift
struct Character: Identifiable, Codable {
    let id: UUID
    var name: String
    var age: Int?
    var gender: String?
    var description: String?
    var voice: VoiceSettings
    var appearance: AppearanceSettings
    var metadata: CharacterMetadata
    var sceneAppearances: [UUID] // Scene IDs
    var createdAt: Date
    var modifiedAt: Date
}

struct VoiceSettings: Codable {
    var voiceId: String  // System voice or API voice ID
    var provider: VoiceProvider
    var pitch: Float = 1.0  // 0.5 to 2.0
    var rate: Float = 1.0   // 0.5 to 2.0
    var volume: Float = 1.0  // 0.0 to 1.0
    var accent: String?
    var style: String?  // e.g., "warm", "authoritative", "nervous"
}

enum VoiceProvider: String, Codable {
    case appleNeuralVoices
    case elevenLabs
    case custom
}

struct AppearanceSettings: Codable {
    var height: Float?  // in meters
    var build: String?
    var avatarId: String?  // Reference to 3D avatar asset
    var customModelURL: URL?
    var defaultPosition: SpatialCoordinates?
}

struct CharacterMetadata: Codable {
    var role: CharacterRole
    var lineCount: Int
    var sceneCount: Int
    var firstAppearance: Int?  // Scene number
    var relationships: [UUID: String]  // Character ID to relationship description
}

enum CharacterRole: String, Codable {
    case protagonist
    case antagonist
    case supporting
    case minor
    case extra
}
```

### 4. Location

Virtual and physical location settings.

```swift
struct Location: Identifiable, Codable {
    let id: UUID
    var name: String
    var type: LocationType
    var setting: Setting  // INT or EXT
    var assetId: String?  // Reference to 3D environment asset
    var customization: LocationCustomization
    var cameraSetups: [CameraSetup]
    var sceneReferences: [UUID]  // Scene IDs
    var metadata: LocationMetadata
}

enum LocationType: String, Codable {
    // Interior
    case residential
    case commercial
    case office
    case institutional
    case retail
    case entertainment

    // Exterior
    case nature
    case urban
    case suburban
    case vehicle

    case custom
}

struct LocationCustomization: Codable {
    var furnitureItems: [FurnitureItem]
    var lighting: LightingSettings
    var weather: WeatherSettings?
    var timeOfDay: TimeOfDay
    var wallColor: String?
    var floorTexture: String?
    var props: [PropItem]
}

struct FurnitureItem: Identifiable, Codable {
    let id: UUID
    var type: String
    var assetId: String
    var position: SpatialCoordinates
    var scale: Float
}

struct PropItem: Identifiable, Codable {
    let id: UUID
    var name: String
    var assetId: String
    var position: SpatialCoordinates
    var scale: Float
}

struct LightingSettings: Codable {
    var preset: LightingPreset
    var intensity: Float = 1.0
    var temperature: Float = 5500  // Kelvin
    var customLights: [LightSource]
}

enum LightingPreset: String, Codable {
    case natural
    case warm
    case cool
    case dramatic
    case soft
    case bright
    case custom
}

struct LightSource: Identifiable, Codable {
    let id: UUID
    var type: LightType
    var position: SpatialCoordinates
    var intensity: Float
    var color: String  // Hex color
}

enum LightType: String, Codable {
    case directional
    case point
    case spot
    case ambient
}

struct WeatherSettings: Codable {
    var condition: WeatherCondition
    var intensity: Float = 1.0
}

enum WeatherCondition: String, Codable {
    case clear
    case rainy
    case snowy
    case foggy
    case overcast
    case stormy
}

struct CameraSetup: Identifiable, Codable {
    let id: UUID
    var name: String
    var shotType: ShotType
    var position: SpatialCoordinates
    var focalLength: Float  // in mm
    var notes: String?
}

struct LocationMetadata: Codable {
    var sceneCount: Int
    var category: String?
    var tags: [String]
    var referenceImages: [URL]
}
```

### 5. Storyboard

Visual pre-visualization of scenes.

```swift
struct Storyboard: Identifiable, Codable {
    let id: UUID
    var sceneId: UUID
    var frames: [StoryboardFrame]
    var duration: TimeInterval
    var metadata: StoryboardMetadata
    var createdAt: Date
    var modifiedAt: Date
}

struct StoryboardFrame: Identifiable, Codable {
    let id: UUID
    var sequenceNumber: Int
    var shotType: ShotType
    var cameraMovement: CameraMovement
    var duration: TimeInterval
    var imageData: Data?  // Sketch or generated image
    var imageURL: URL?  // Reference to stored image
    var dialogue: String?
    var notes: String?
    var transition: TransitionType?
}

enum ShotType: String, Codable {
    case extremeWideShot = "EWS"
    case wideShot = "WS"
    case fullShot = "FS"
    case mediumShot = "MS"
    case closeUp = "CU"
    case extremeCloseUp = "ECU"
    case overTheShoulder = "OTS"
    case pointOfView = "POV"
    case insert = "INSERT"
    case twoShot = "TWO SHOT"
    case threeShot = "THREE SHOT"
    case groupShot = "GROUP SHOT"
}

enum CameraMovement: String, Codable {
    case static
    case pan
    case tilt
    case dollyIn
    case dollyOut
    case tracking
    case crane
    case handheld
    case steadicam
    case zoom
    case custom
}

struct StoryboardMetadata: Codable {
    var frameCount: Int
    var totalDuration: TimeInterval
    var exportedAt: Date?
    var exportFormat: String?
}
```

### 6. Collaboration

Multi-user collaboration support.

```swift
struct Collaborator: Identifiable, Codable {
    let id: UUID
    var userId: String  // CloudKit user ID
    var name: String
    var email: String?
    var role: CollaboratorRole
    var permissions: CollaboratorPermissions
    var presence: PresenceInfo?
    var invitedAt: Date
    var joinedAt: Date?
}

enum CollaboratorRole: String, Codable {
    case owner
    case coWriter
    case editor
    case viewer
}

struct CollaboratorPermissions: Codable {
    var canEdit: Bool
    var canAddScenes: Bool
    var canDeleteScenes: Bool
    var canInviteOthers: Bool
    var canExport: Bool
    var canManageSettings: Bool
}

struct PresenceInfo: Codable {
    var isOnline: Bool
    var lastSeen: Date
    var currentSceneId: UUID?
    var currentActivity: String?
    var spatialPosition: SpatialCoordinates?
}

struct Comment: Identifiable, Codable {
    let id: UUID
    var sceneId: UUID
    var authorId: UUID
    var text: String
    var isResolved: Bool
    var replies: [CommentReply]
    var createdAt: Date
    var modifiedAt: Date
}

struct CommentReply: Identifiable, Codable {
    let id: UUID
    var authorId: UUID
    var text: String
    var createdAt: Date
}
```

### 7. Version Control

Version history and revision tracking.

```swift
struct Version: Identifiable, Codable {
    let id: UUID
    var versionNumber: Int
    var revisionColor: RevisionColor
    var snapshot: ProjectSnapshot
    var changeDescription: String
    var author: String
    var createdAt: Date
    var isAutoSave: Bool
}

struct ProjectSnapshot: Codable {
    var scenesData: Data  // Encoded scenes array
    var checksum: String  // SHA-256 hash
}

struct Revision: Identifiable, Codable {
    let id: UUID
    var versionId: UUID
    var changes: [Change]
    var author: String
    var timestamp: Date
}

struct Change: Codable {
    var type: ChangeType
    var elementId: UUID?
    var oldValue: String?
    var newValue: String?
    var path: String  // JSON path to changed property
}

enum ChangeType: String, Codable {
    case addition
    case deletion
    case modification
    case reorder
}
```

### 8. Notes and Annotations

```swift
struct Note: Identifiable, Codable {
    let id: UUID
    var text: String
    var type: NoteType
    var authorId: UUID
    var isPrivate: Bool
    var color: String?
    var createdAt: Date
    var modifiedAt: Date
}

enum NoteType: String, Codable {
    case general
    case production
    case creative
    case technical
    case reminder
}
```

## Relationships Diagram

```
Project
├── scenes: [Scene]
│   ├── characters: [Character] (by ID)
│   ├── locationId: Location (by ID)
│   ├── notes: [Note]
│   └── revisions: [Revision]
├── characters: [Character]
├── locations: [Location]
│   └── cameraSetups: [CameraSetup]
├── storyboards: [Storyboard]
│   ├── sceneId: Scene (by ID)
│   └── frames: [StoryboardFrame]
├── collaborators: [Collaborator]
└── versionHistory: [Version]
    └── snapshot: ProjectSnapshot
```

## Persistence Strategy

### Local Storage (Primary)

**Technology**: SwiftData (recommended for visionOS 2.0+)

**Rationale**:
- Native SwiftUI integration
- Modern declarative API
- Automatic CloudKit sync support
- Query system with @Query property wrapper
- Migration support

**Alternative**: Core Data if more control needed

### Cloud Storage (Sync & Collaboration)

**Technology**: CloudKit

**Schema**:
- **Private Database**: User's personal projects
- **Shared Database**: Collaborative projects
- **Public Database**: Shared assets (location library, avatars)

**Record Types**:
```
CKRecord Types:
- Project (private/shared)
- Scene (private/shared)
- Character (private/shared)
- Location (public for library, private for custom)
- Storyboard (private/shared)
- Collaborator (shared)
- Version (private/shared)
- Comment (shared)
- Asset (public)
```

**Sync Strategy**:
- Auto-save every 5 minutes to local storage
- Background sync to CloudKit every 30 seconds when online
- Conflict resolution: Last-write-wins with version timestamps
- Optimistic UI updates with rollback on conflict

### File Storage (Assets)

**Location**: Local file system + iCloud Drive

**Structure**:
```
~/Library/Application Support/SpatialScreenplayWorkshop/
  projects/
    {project-id}/
      project.json           # Main project file
      scenes/
        {scene-id}.json      # Individual scene data
      storyboards/
        {storyboard-id}/
          frames/
            frame-001.png
            frame-002.png
      assets/
        custom-models/
        reference-images/
      versions/
        v001.snapshot
        v002.snapshot
      exports/
        script.pdf
        script.fdx
```

## Data Size Estimates

| Entity | Avg Size | Max Count per Project | Total |
|--------|----------|----------------------|-------|
| Project | 10 KB | 1 | 10 KB |
| Scene | 5 KB | 200 | 1 MB |
| Character | 2 KB | 50 | 100 KB |
| Location | 3 KB | 100 | 300 KB |
| Storyboard Frame | 500 KB (with image) | 500 | 250 MB |
| Version Snapshot | 1 MB | 50 | 50 MB |
| **Total per Project** | | | **~300 MB** |

## Data Migration Strategy

### Version Migration

```swift
enum SchemaVersion: Int, Codable {
    case v1 = 1
    case v2 = 2
    // Future versions...

    static var current: SchemaVersion { .v2 }
}

protocol MigrationProtocol {
    func migrate(from: SchemaVersion, to: SchemaVersion) throws
}
```

### Migration Path
- V1 → V2: Add collaboration features
- V2 → V3: Add storyboard features
- Include migration code for at least 2 versions back

## Data Validation

### Constraints

```swift
// Scene
- sceneNumber: 1...9999
- pageLength: 0.125...50.0 (1/8 page to 50 pages)

// Character
- name: 1...100 characters, uppercase for script formatting
- voice.pitch: 0.5...2.0
- voice.rate: 0.5...2.0

// SlugLine
- location: 1...100 characters

// Project
- title: 1...200 characters
- scenes: 1...1000 scenes (practical limit)
```

### Business Rules

1. Scene numbers must be sequential within project
2. Character names must be unique within project
3. Location names should be unique (warning if duplicate)
4. At least one scene required in project
5. Project must have title before export
6. Slugline must follow format: INT/EXT. LOCATION - TIME

## Performance Considerations

### Indexing

```swift
// SwiftData Indexes
@Model class Scene {
    @Attribute(.unique) var id: UUID
    @Index var sceneNumber: Int
    @Index var modifiedAt: Date
    // ... other properties
}

@Model class Character {
    @Attribute(.unique) var id: UUID
    @Index var name: String
    // ... other properties
}
```

### Lazy Loading

- Load only visible scenes in timeline view
- Lazy load storyboard images (thumbnails first)
- Paginate version history (load 10 at a time)

### Caching

- Cache parsed script elements
- Cache character voice synthesis results (5 min TTL)
- Cache location 3D assets in memory

## Data Security

### Encryption
- CloudKit encryption at rest (automatic)
- Local database encryption using Data Protection API
- Sensitive notes can be marked private and encrypted

### Access Control
- User authentication via Sign in with Apple
- Role-based permissions for collaborators
- API keys (TTS, image generation) stored in Keychain

## Export Formats

### Project Export (.screenplay)

```json
{
  "version": "1.0",
  "schema_version": 2,
  "project": {
    "id": "uuid",
    "title": "Project Title",
    "type": "featureFilm",
    // ... full project data
  }
}
```

### Compressed Archive

```
MyScript.screenplay (ZIP)
├── manifest.json
├── project.json
├── scenes/
├── characters.json
├── locations.json
├── storyboards/
└── assets/
```

## Backup & Recovery

### Auto-Backup
- Daily local backup to Time Machine
- CloudKit automatic backup
- Manual export to .screenplay file

### Recovery
- Restore from version history
- Import from .screenplay file
- CloudKit conflict resolution UI

## Future Considerations

### Scalability
- Support for multi-season TV series (linked projects)
- Production database export (scene scheduling data)
- Analytics data collection (feature usage, performance metrics)

### Extensions
- Plugin system for custom script elements
- Third-party asset marketplace integration
- AI assistant integration (script analysis, suggestions)

---

**Document Version**: 1.0
**Last Updated**: 2025-11-24
**Author**: Technical Design Team
