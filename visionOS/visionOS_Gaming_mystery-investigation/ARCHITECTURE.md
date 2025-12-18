# Mystery Investigation - Technical Architecture

## Overview
Mystery Investigation is a spatial detective experience for Apple Vision Pro that transforms physical spaces into immersive crime scenes. This document outlines the technical architecture, systems design, and implementation patterns for the visionOS gaming application.

---

## 1. Game Architecture Overview

### High-Level Architecture
```
┌─────────────────────────────────────────────────────────────┐
│                     MysteryInvestigationApp                  │
│                    (Application Entry Point)                 │
└───────────────────┬─────────────────────────────────────────┘
                    │
        ┌───────────┴───────────┐
        │   GameCoordinator     │
        │   (Main Controller)    │
        └───────────┬───────────┘
                    │
    ┌───────────────┼───────────────┐
    │               │               │
┌───▼────┐    ┌────▼─────┐   ┌────▼─────┐
│ Scene  │    │  Game    │   │  Spatial │
│Manager │    │  State   │   │  Manager │
└───┬────┘    └────┬─────┘   └────┬─────┘
    │              │              │
    │         ┌────▼─────┐        │
    │         │ Entity   │        │
    │         │Component │        │
    │         │ System   │        │
    │         └──────────┘        │
    │                             │
┌───▼─────────────────────────────▼───┐
│         RealityKit Engine            │
│  (3D Rendering & Spatial Computing)  │
└──────────────────────────────────────┘
```

### Core Design Patterns
- **Entity-Component-System (ECS)**: RealityKit's native ECS for game objects
- **State Machine**: Game state management for investigation flow
- **Observer Pattern**: Event system for game events and triggers
- **Command Pattern**: User actions and undo/redo for investigation
- **Factory Pattern**: Procedural case and evidence generation

---

## 2. Game Loop Architecture

### Main Game Loop (60-90 FPS Target)
```swift
class GameLoop {
    // Update cycle called by RealityKit
    func update(deltaTime: TimeInterval) {
        // 1. Input Processing (Hand/Eye/Voice)
        inputSystem.processInput(deltaTime)

        // 2. Game Logic Update
        investigationSystem.update(deltaTime)
        evidenceSystem.update(deltaTime)
        aiSystem.update(deltaTime)

        // 3. Physics Simulation (handled by RealityKit)
        // PhysicsWorld automatically updates

        // 4. Animation Update
        animationSystem.update(deltaTime)

        // 5. Audio Update (Spatial Audio)
        audioSystem.update(deltaTime)

        // 6. UI/HUD Update
        hudSystem.update(deltaTime)

        // 7. Render Preparation
        renderSystem.prepareFrame(deltaTime)
    }
}
```

### Game States
```swift
enum GameState {
    case mainMenu
    case caseSelection
    case caseIntroduction
    case investigating(CaseData)
    case interrogating(Suspect)
    case analysisMode(Evidence)
    case theoryBuilding
    case caseSolution
    case paused
}
```

---

## 3. VisionOS-Specific Gaming Patterns

### Window Hierarchy
```
ImmersiveSpace (Primary)
├── Crime Scene Environment
│   ├── Evidence Entities
│   ├── Suspect Holograms
│   └── Environmental Props
│
Window (Secondary - UI)
├── Investigation Dashboard
├── Evidence Log
└── Case Notes

Volume (Optional)
└── Evidence Examination Viewer
```

### Immersive Space Management
```swift
@main
struct MysteryInvestigationApp: App {
    @State private var gameCoordinator = GameCoordinator()

    var body: some Scene {
        // Primary Window - Main Menu
        WindowGroup {
            MainMenuView()
                .environment(gameCoordinator)
        }

        // Immersive Space - Crime Scene
        ImmersiveSpace(id: "CrimeScene") {
            CrimeSceneView()
                .environment(gameCoordinator)
        }
        .immersionStyle(selection: .constant(.mixed), in: .mixed, .progressive, .full)

        // Volume - Evidence Viewer
        WindowGroup(id: "EvidenceViewer") {
            EvidenceExaminationView()
        }
        .windowStyle(.volumetric)
        .defaultSize(width: 0.5, height: 0.5, depth: 0.5, in: .meters)
    }
}
```

---

## 4. Game Data Models & Schemas

### Core Data Models

#### Case Model
```swift
struct CaseData: Codable, Identifiable {
    let id: UUID
    let title: String
    let difficulty: Difficulty
    let narrative: CaseNarrative
    let crimeScene: CrimeSceneData
    let suspects: [Suspect]
    let evidence: [Evidence]
    let solution: CaseSolution
    let timelineEvents: [TimelineEvent]

    enum Difficulty: String, Codable {
        case beginner, intermediate, advanced, expert
    }
}

struct CaseNarrative: Codable {
    let briefing: String
    let victimBackground: String
    let initialReport: String
    let unlockableClues: [String]
}
```

#### Evidence Model
```swift
struct Evidence: Codable, Identifiable {
    let id: UUID
    let type: EvidenceType
    let name: String
    let description: String
    let spatialLocation: SpatialAnchor
    let isRedHerring: Bool
    let relatedSuspects: [UUID]
    let forensicData: ForensicData?
    let discoveryHints: [String]

    enum EvidenceType: String, Codable {
        case fingerprint, dna, weapon, document,
             photograph, fiber, footprint, bloodSpatter,
             digitalEvidence, testimony
    }
}

struct ForensicData: Codable {
    let analysisType: String
    let results: [String: String]
    let conclusionText: String
}
```

#### Suspect Model
```swift
struct Suspect: Codable, Identifiable {
    let id: UUID
    let name: String
    let age: Int
    let occupation: String
    let relationship: String // to victim
    let alibi: String
    let personality: PersonalityProfile
    let appearance: AppearanceData
    let dialogueTree: DialogueTree
    let isGuilty: Bool
    let motivations: [String]
}

struct PersonalityProfile: Codable {
    let traits: [String]
    let stressLevel: Float // 0-1
    let truthfulness: Float // 0-1
    let cooperativeness: Float // 0-1
}
```

#### Spatial Anchor System
```swift
struct SpatialAnchor: Codable {
    let anchorID: UUID
    let relativePosition: SIMD3<Float>
    let surfaceType: SurfaceType
    let persistenceKey: String

    enum SurfaceType: String, Codable {
        case floor, wall, table, ceiling, custom
    }
}
```

---

## 5. RealityKit Gaming Components

### Custom ECS Components

#### Evidence Component
```swift
struct EvidenceComponent: Component {
    var evidenceData: Evidence
    var isDiscovered: Bool = false
    var examinationProgress: Float = 0.0
    var highlightState: HighlightState = .none

    enum HighlightState {
        case none, gazed, selected, examined
    }
}
```

#### Interactive Component
```swift
struct InteractiveComponent: Component {
    var interactionType: InteractionType
    var isEnabled: Bool = true
    var interactionRadius: Float = 0.5

    enum InteractionType {
        case pickup, examine, use, toggle, combine
    }
}
```

#### Hologram Component
```swift
struct HologramComponent: Component {
    var suspectData: Suspect
    var animationState: AnimationState
    var dialogueState: DialogueState
    var emotionalState: EmotionalState

    enum AnimationState {
        case idle, talking, nervous, defensive, cooperative
    }

    enum DialogueState {
        case waiting, speaking, listening, interrupted
    }
}
```

### Custom ECS Systems

#### Evidence Discovery System
```swift
class EvidenceDiscoverySystem: System {
    static let query = EntityQuery(where: .has(EvidenceComponent.self))

    func update(context: SceneUpdateContext) {
        for entity in context.entities(matching: Self.query) {
            guard var evidence = entity.components[EvidenceComponent.self] else { continue }

            // Check player proximity and gaze
            if isPlayerNearby(entity) && isPlayerGazing(entity) {
                evidence.highlightState = .gazed
                showDiscoveryHint(evidence)
            }

            entity.components[EvidenceComponent.self] = evidence
        }
    }
}
```

#### Interrogation System
```swift
class InterrogationSystem: System {
    static let query = EntityQuery(where: .has(HologramComponent.self))

    func update(context: SceneUpdateContext) {
        for entity in context.entities(matching: Self.query) {
            guard var hologram = entity.components[HologramComponent.self] else { continue }

            // Update suspect behavior based on evidence pressure
            updateSuspectBehavior(&hologram, context: context)

            // Animate emotional responses
            animateEmotionalState(&hologram, context: context)

            entity.components[HologramComponent.self] = hologram
        }
    }
}
```

---

## 6. ARKit Integration

### Spatial Mapping & Room Scanning
```swift
class SpatialMappingManager {
    private var arkitSession: ARKitSession
    private var worldTrackingProvider: WorldTrackingProvider
    private var sceneReconstruction: SceneReconstructionProvider

    func startRoomScanning() async {
        do {
            try await arkitSession.run([
                worldTrackingProvider,
                sceneReconstruction
            ])

            // Process room geometry
            await processRoomGeometry()
        } catch {
            handleARKitError(error)
        }
    }

    func placeEvidence(at anchor: SpatialAnchor) {
        // Use ARKit plane detection for evidence placement
        // Ensure evidence respects room geometry
    }
}
```

### Hand Tracking Integration
```swift
class HandTrackingManager {
    private var handTracking: HandTrackingProvider

    func processHandGestures() {
        // Pinch gesture for evidence pickup
        // Spread gesture for magnification
        // Writing gesture for note-taking
    }
}
```

---

## 7. Multiplayer Architecture

### SharePlay Integration
```swift
class MultiplayerManager: ObservableObject {
    private var groupSession: GroupSession<InvestigationActivity>?
    private var messenger: GroupSessionMessenger?

    struct SyncedInvestigationState: Codable {
        var discoveredEvidence: Set<UUID>
        var interrogationProgress: [UUID: Float]
        var sharedNotes: [Note]
        var currentTheory: Theory?
    }

    func syncEvidenceDiscovery(_ evidenceID: UUID) async {
        let message = EvidenceDiscoveredMessage(evidenceID: evidenceID)
        try? await messenger?.send(message)
    }
}
```

### Network Synchronization
- Evidence discovery synced in real-time
- Suspect interrogation state shared
- Theory building collaborative
- Voice chat for team communication

---

## 8. Physics & Collision Systems

### RealityKit Physics Configuration
```swift
class PhysicsManager {
    func configureEvidencePhysics(_ entity: Entity) {
        // Evidence has realistic physics
        entity.components[PhysicsBodyComponent.self] = PhysicsBodyComponent(
            shapes: [.generateBox(size: entity.visualBounds(relativeTo: nil).extents)],
            mass: 0.1,
            material: .generate(staticFriction: 0.8, dynamicFriction: 0.6),
            mode: .dynamic
        )

        // Collision detection for pickup
        entity.components[CollisionComponent.self] = CollisionComponent(
            shapes: [.generateBox(size: entity.visualBounds(relativeTo: nil).extents)]
        )
    }
}
```

---

## 9. Audio Architecture

### Spatial Audio System
```swift
class SpatialAudioManager {
    private var audioEngine: AVAudioEngine
    private var environment: AVAudioEnvironmentNode

    // Evidence audio sources positioned in 3D space
    func playEvidenceSound(at position: SIMD3<Float>) {
        let source = AVAudioPlayerNode()
        source.position = AVAudio3DPoint(x: position.x, y: position.y, z: position.z)
        environment.add(source)
    }

    // Suspect voice spatially positioned
    func playSuspectDialogue(_ suspect: Suspect, at position: SIMD3<Float>) {
        // Spatial dialogue with emotional processing
    }

    // Environmental ambiance
    func setCrimeSceneAmbiance(_ scene: CrimeSceneData) {
        // Location-appropriate background audio
    }
}
```

### Audio Categories
- **Environmental**: Crime scene ambiance, weather, location sounds
- **Evidence**: Discovery chimes, forensic tool sounds
- **Dialogue**: Suspect/witness voice acting
- **UI**: Menu sounds, notification alerts
- **Music**: Investigative tension, mystery themes

---

## 10. Performance Optimization

### Rendering Optimization
```swift
class RenderOptimizationManager {
    // Level of Detail (LOD) for evidence
    func applyLOD(entity: Entity, distanceFromPlayer: Float) {
        if distanceFromPlayer < 1.0 {
            entity.model = highDetailModel
        } else if distanceFromPlayer < 3.0 {
            entity.model = mediumDetailModel
        } else {
            entity.model = lowDetailModel
        }
    }

    // Occlusion culling
    func enableOcclusionCulling() {
        // Only render visible evidence
        // RealityKit handles automatically
    }

    // Dynamic resolution scaling
    func maintainFrameRate(currentFPS: Float) {
        if currentFPS < 60 {
            reduceRenderQuality()
        }
    }
}
```

### Memory Management
- Object pooling for frequently spawned entities
- Lazy loading of case data
- Texture compression for evidence models
- Audio streaming for long dialogues

### Performance Budgets
- **Frame Rate**: 90 FPS target, 60 FPS minimum
- **Memory**: <500MB for core game, <200MB per case
- **Storage**: <2GB base app, <100MB per case pack
- **Network**: <50KB/s for multiplayer sync

---

## 11. Save/Load System Architecture

### Persistence Layer
```swift
class SaveGameManager {
    private let fileManager = FileManager.default

    struct SaveData: Codable {
        let playerProgress: PlayerProgress
        let activeCases: [UUID: CaseProgress]
        let discoveredEvidence: Set<UUID>
        let unlockedTools: Set<String>
        let achievements: [Achievement]
        let settings: GameSettings
    }

    func saveGame() async throws {
        let saveData = gatherSaveData()
        let encoder = JSONEncoder()
        let data = try encoder.encode(saveData)

        // Save to app documents directory
        let saveURL = getSaveFileURL()
        try data.write(to: saveURL)

        // iCloud sync
        await syncToiCloud(saveData)
    }

    func loadGame() async throws -> SaveData {
        // Load from local or iCloud
    }
}
```

### Cloud Sync
- iCloud integration for cross-device progress
- Conflict resolution for multiple devices
- Offline mode with background sync

---

## 12. AI & Procedural Generation

### Case Generation System
```swift
class ProceduralCaseGenerator {
    func generateCase(difficulty: Difficulty, theme: CaseTheme) -> CaseData {
        // 1. Generate crime scenario
        let crime = generateCrimeScenario(theme)

        // 2. Create suspects with motives
        let suspects = generateSuspects(count: Int.random(in: 3...6))

        // 3. Distribute evidence
        let evidence = distributeEvidence(suspects: suspects, guilty: crime.culprit)

        // 4. Add red herrings
        let allEvidence = evidence + generateRedHerrings(count: difficulty.redHerringCount)

        // 5. Create dialogue trees
        let dialogues = generateDialogueTrees(suspects: suspects)

        // 6. Validate logical consistency
        validateCaseLogic(crime, suspects, allEvidence)

        return CaseData(/* ... */)
    }
}
```

### NPC Behavior AI
```swift
class NPCBehaviorAI {
    func generateResponse(
        suspect: Suspect,
        question: String,
        evidencePresented: [Evidence],
        previousAnswers: [DialogueNode]
    ) -> DialogueResponse {
        // Use behavior trees + LLM for natural responses
        let context = buildDialogueContext(suspect, evidencePresented)
        let response = queryLLM(question, context)

        // Apply personality filters
        return applyPersonalityTraits(response, suspect.personality)
    }
}
```

---

## 13. Data Flow Architecture

### Investigation State Flow
```
User Input (Hand/Eye/Voice)
    ↓
Input System Processing
    ↓
Game State Update
    ↓
ECS Component Updates
    ↓
RealityKit Rendering
    ↓
Display Output
```

### Evidence Discovery Flow
```
Player Approaches Evidence
    ↓
Proximity Detection System
    ↓
Gaze Tracking (Eye)
    ↓
Highlight Evidence
    ↓
Player Gesture (Pinch)
    ↓
Pickup & Examine
    ↓
Update Investigation State
    ↓
Log to Evidence Database
```

---

## 14. Security & Privacy

### Spatial Data Privacy
- Room mapping data stays on-device
- No cloud upload of spatial geometry
- User can delete all spatial anchors
- No analytics on physical room layout

### Data Encryption
- Save files encrypted with CryptoKit
- iCloud sync uses end-to-end encryption
- No PII collected beyond Apple ID (for sync)

---

## 15. Testing Architecture

### Unit Testing
```swift
@testable import MysteryInvestigation

class EvidenceSystemTests: XCTestCase {
    func testEvidenceDiscovery() {
        // Test evidence discovery logic
    }

    func testForensicAnalysis() {
        // Test forensic tool accuracy
    }
}
```

### Integration Testing
- ARKit integration tests
- Multiplayer synchronization tests
- Save/load system tests

### Playtest Metrics
- Case completion time
- Evidence discovery rate
- Player movement heatmaps
- Interaction accuracy

---

## 16. Technology Stack Summary

### Core Technologies
- **Language**: Swift 6.0+
- **UI Framework**: SwiftUI 5.0+
- **3D Engine**: RealityKit 2.0+
- **AR Framework**: ARKit 6.0+
- **Platform**: visionOS 2.0+
- **Audio**: AVFoundation (Spatial Audio)
- **Networking**: GroupActivities (SharePlay)
- **Persistence**: SwiftData / CoreData
- **Cloud**: iCloud / CloudKit

### Development Tools
- Xcode 16+
- Reality Composer Pro
- Instruments (Performance Profiling)
- TestFlight (Beta Testing)

---

## 17. Deployment Architecture

### App Bundle Structure
```
MysteryInvestigation.app/
├── Executable
├── Info.plist
├── Assets.xcassets
├── RealityKitContent/
│   ├── Scenes/
│   ├── Models/
│   └── Materials/
├── Audio/
│   ├── Music/
│   ├── SFX/
│   └── Dialogue/
├── Cases/
│   ├── TutorialCase.json
│   ├── Case001.json
│   └── ...
└── Frameworks/
```

### Content Delivery
- Base app with tutorial case
- Additional cases via In-App Purchase
- Content updates via App Store
- Educational content via enterprise distribution

---

## Conclusion

This architecture provides a robust, scalable foundation for Mystery Investigation on visionOS. The ECS pattern, spatial computing integration, and modular systems enable rich detective gameplay while maintaining performance and user comfort.

**Key Architectural Principles:**
1. **Spatial-First**: Designed for 3D space from the ground up
2. **Performance**: 90 FPS target with optimization systems
3. **Modularity**: Decoupled systems for maintainability
4. **Scalability**: Support for procedural content generation
5. **Privacy**: On-device processing for spatial data
6. **Accessibility**: Designed for diverse player needs

This architecture supports both the MVP requirements and future enhancements outlined in the PRD.
