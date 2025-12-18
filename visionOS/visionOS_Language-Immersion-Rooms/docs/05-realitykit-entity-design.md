# RealityKit Entity Design

## Entity Architecture

### Entity Component System (ECS)

Language Immersion Rooms uses RealityKit's Entity Component System for all 3D content. This document defines custom components, entity hierarchies, and spatial interactions.

## Core Entity Types

### 1. Object Label Entity

**Purpose**: 3D labels attached to real-world objects

```swift
class ObjectLabelEntity: Entity {
    // Components
    var labelComponent: LabelComponent
    var anchorComponent: AnchoringComponent
    var interactionComponent: InteractionComponent

    init(word: VocabularyWord, anchor: AnchorEntity) {
        super.init()

        // Add label component
        self.labelComponent = LabelComponent(
            text: word.word,
            translation: word.translation,
            style: .standard
        )

        // Anchor to world position
        self.anchorComponent = AnchoringComponent(.world(transform: anchor.transform))

        // Make interactive
        self.interactionComponent = InteractionComponent()

        // Add visual components
        self.components.set(ModelComponent(mesh: createLabelMesh()))
        self.components.set(CollisionComponent(shapes: [.generateBox(size: [0.2, 0.1, 0.01])]))
    }

    private func createLabelMesh() -> MeshResource {
        // Generate 3D text mesh
        return MeshResource.generateText(
            labelComponent.text,
            extrusionDepth: 0.01,
            font: .systemFont(ofSize: 0.05)
        )
    }
}
```

### 2. AI Character Entity

**Purpose**: Holographic native speaker for conversations

```swift
class AICharacterEntity: Entity {
    // Components
    var characterComponent: CharacterComponent
    var animationController: AnimationController
    var audioComponent: AudioComponent

    init(character: AICharacter, position: SIMD3<Float>) {
        super.init()

        // Load character model
        self.characterComponent = CharacterComponent(modelName: character.modelAssetName)

        // Setup animations
        self.animationController = AnimationController()

        // Audio source for speech
        self.audioComponent = AudioComponent()

        // Position in space
        self.position = position

        // Load 3D model
        loadModel(named: character.modelAssetName)
    }

    func speak(_ text: String, audioURL: URL) async {
        // Play lip-sync animation
        await animationController.playAnimation(named: "speak")

        // Play audio
        audioComponent.playAudio(from: audioURL, spatialize: true)
    }

    func setEmotion(_ emotion: Emotion) {
        animationController.playAnimation(named: emotion.animationName)
    }

    private func loadModel(named name: String) {
        Entity.loadModelAsync(named: name) { result in
            switch result {
            case .success(let model):
                self.addChild(model)
            case .failure(let error):
                print("Failed to load model: \(error)")
            }
        }
    }
}

enum Emotion {
    case happy, neutral, confused, excited

    var animationName: String {
        switch self {
        case .happy: return "smile"
        case .neutral: return "idle"
        case .confused: return "thinking"
        case .excited: return "celebration"
        }
    }
}
```

### 3. Environment Entity

**Purpose**: Themed environment (café, restaurant, etc.)

```swift
class EnvironmentEntity: Entity {
    var environmentComponent: EnvironmentComponent
    var lightingComponent: LightingComponent
    var audioComponent: AmbientAudioComponent

    init(environment: Environment) {
        super.init()

        self.environmentComponent = EnvironmentComponent(id: environment.id)

        // Load environment bundle
        loadEnvironment(bundleName: environment.assetBundleName)

        // Setup lighting
        setupLighting(profile: environment.lightingProfile)

        // Ambient audio
        if let soundURL = environment.ambientSoundURL {
            audioComponent.playAmbient(from: soundURL, volume: 0.3)
        }
    }

    private func loadEnvironment(bundleName: String) {
        // Load USDZ bundle
        Entity.loadAsync(named: bundleName) { result in
            switch result {
            case .success(let environmentModel):
                self.addChild(environmentModel)
                self.setupInteractiveObjects()
            case .failure(let error):
                print("Failed to load environment: \(error)")
            }
        }
    }

    private func setupLighting(profile: LightingProfile) {
        let directionalLight = DirectionalLight()
        directionalLight.light.intensity = profile.intensity
        directionalLight.light.color = profile.color
        directionalLight.shadow = DirectionalLightComponent.Shadow()
        self.addChild(directionalLight)
    }

    private func setupInteractiveObjects() {
        // Find and setup interactive elements
        let interactives = self.findEntities(with: "interactive" as RealityKit.Entity.ComponentType)
        for entity in interactives {
            entity.components.set(InteractionComponent())
            entity.components.set(CollisionComponent(shapes: [.generateConvex(from: entity)]))
        }
    }
}
```

### 4. Grammar Card Entity

**Purpose**: Floating grammar correction cards

```swift
class GrammarCardEntity: Entity {
    var cardComponent: GrammarCardComponent
    var materialComponent: MaterialComponent

    init(grammarError: GrammarError, position: SIMD3<Float>) {
        super.init()

        self.cardComponent = GrammarCardComponent(error: grammarError)

        // Create card mesh
        let mesh = MeshResource.generatePlane(width: 0.4, depth: 0.3)
        let material = createCardMaterial(for: grammarError)

        self.components.set(ModelComponent(mesh: mesh, materials: [material]))

        // Position in user's view
        self.position = position

        // Make it face the user
        self.look(at: [0, 0, 0], from: position, relativeTo: nil)

        // Add gentle float animation
        addFloatAnimation()
    }

    private func createCardMaterial(for error: GrammarError) -> Material {
        // Create material with text texture
        var material = UnlitMaterial()

        // Generate texture with text
        let texture = generateTextTexture(
            incorrect: error.incorrectPhrase,
            correct: error.correctPhrase,
            explanation: error.explanation
        )

        material.color = .init(texture: .init(texture))
        return material
    }

    private func addFloatAnimation() {
        // Gentle bobbing animation
        let duration: TimeInterval = 2.0
        let moveUp = Transform(translation: [0, 0.02, 0])
        let moveDown = Transform(translation: [0, -0.02, 0])

        var animation = FromToByAnimation(
            from: moveDown,
            to: moveUp,
            duration: duration,
            autoreverses: true,
            repeatMode: .repeat
        )

        self.playAnimation(animation.repeat())
    }
}
```

### 5. Pronunciation Feedback Entity

**Purpose**: Visual pronunciation feedback (waveforms, mouth shapes)

```swift
class PronunciationFeedbackEntity: Entity {
    var waveformEntity: WaveformEntity
    var mouthShapeEntity: MouthShapeEntity

    init(feedback: PronunciationFeedback) {
        super.init()

        // Waveform visualization
        waveformEntity = WaveformEntity(
            userAudio: feedback.userAudioURL,
            referenceAudio: feedback.referenceAudioURL
        )
        self.addChild(waveformEntity)

        // 3D mouth shape guide
        mouthShapeEntity = MouthShapeEntity(phoneme: feedback.phoneme)
        mouthShapeEntity.position = [0.5, 0, 0]
        self.addChild(mouthShapeEntity)
    }
}

class WaveformEntity: Entity {
    init(userAudio: URL?, referenceAudio: URL?) {
        super.init()

        // Generate waveform meshes
        if let userURL = userAudio {
            let userWaveform = generateWaveformMesh(from: userURL, color: .red)
            userWaveform.position = [0, 0.1, 0]
            self.addChild(userWaveform)
        }

        if let refURL = referenceAudio {
            let refWaveform = generateWaveformMesh(from: refURL, color: .green)
            refWaveform.position = [0, -0.1, 0]
            self.addChild(refWaveform)
        }
    }

    private func generateWaveformMesh(from audioURL: URL, color: UIColor) -> Entity {
        // Parse audio and create 3D waveform
        let samples = extractAudioSamples(from: audioURL)
        let mesh = createWaveformMesh(from: samples)

        var material = SimpleMaterial()
        material.color = .init(tint: color)

        let entity = ModelEntity(mesh: mesh, materials: [material])
        return entity
    }

    private func extractAudioSamples(from url: URL) -> [Float] {
        // Extract audio waveform data
        // Implementation using AVFoundation
        return []
    }

    private func createWaveformMesh(from samples: [Float]) -> MeshResource {
        // Convert samples to 3D line mesh
        var vertices: [SIMD3<Float>] = []
        for (index, sample) in samples.enumerated() {
            let x = Float(index) / Float(samples.count) * 0.3
            let y = sample * 0.05
            vertices.append([x, y, 0])
        }

        return MeshResource.generateLines(between: vertices)
    }
}

class MouthShapeEntity: Entity {
    init(phoneme: String) {
        super.init()

        // Load 3D mouth model showing correct position
        Entity.loadModelAsync(named: "mouth_\(phoneme)") { result in
            if case .success(let model) = result {
                self.addChild(model)
            }
        }
    }
}
```

## Custom Components

### LabelComponent

```swift
struct LabelComponent: Component {
    var text: String
    var translation: String
    var pronunciation: String
    var style: LabelStyle
    var fontSize: Float
    var color: UIColor

    enum LabelStyle {
        case minimal      // Word only
        case standard     // Word + pronunciation
        case detailed     // Word + pronunciation + example
    }
}
```

### CharacterComponent

```swift
struct CharacterComponent: Component {
    var characterID: String
    var modelName: String
    var voiceID: String
    var currentEmotion: Emotion
    var isSpeaking: Bool
}
```

### EnvironmentComponent

```swift
struct EnvironmentComponent: Component {
    var environmentID: String
    var theme: EnvironmentTheme
    var isLoaded: Bool
    var interactiveObjects: [Entity]

    enum EnvironmentTheme {
        case cafe, restaurant, office, outdoor
    }
}
```

### InteractionComponent

```swift
struct InteractionComponent: Component {
    var isInteractive: Bool = true
    var interactionType: InteractionType
    var onTap: (() -> Void)?

    enum InteractionType {
        case tap
        case longPress
        case gaze
        case voice
    }
}
```

### GrammarCardComponent

```swift
struct GrammarCardComponent: Component {
    var errorType: String
    var incorrectPhrase: String
    var correctPhrase: String
    var explanation: String
    var ruleID: String
    var isVisible: Bool = true
}
```

## Entity Hierarchies

### Scene Hierarchy

```
RootEntity (Scene)
├── AnchorEntity (World Anchor)
│   └── ObjectLabels/
│       ├── ObjectLabelEntity (Table)
│       ├── ObjectLabelEntity (Chair)
│       └── ObjectLabelEntity (Lamp)
│
├── EnvironmentEntity
│   ├── Walls
│   ├── Floor
│   ├── Ceiling
│   ├── Props/
│   │   ├── Table
│   │   ├── Menu
│   │   └── Decorations
│   └── Lighting
│
├── CharactersGroup/
│   ├── AICharacterEntity (Waiter)
│   └── AICharacterEntity (Customer)
│
└── UIOverlays/
    ├── GrammarCardEntity
    └── PronunciationFeedbackEntity
```

## Spatial Anchoring

### World Anchors

```swift
class SpatialAnchorManager {
    private var worldAnchors: [UUID: AnchorEntity] = [:]

    func createWorldAnchor(at transform: simd_float4x4) -> AnchorEntity {
        let anchor = AnchorEntity(.world(transform: transform))
        worldAnchors[anchor.id] = anchor
        return anchor
    }

    func saveAnchor(_ anchor: AnchorEntity) async throws {
        // Save to ARWorldMap
        let worldMap = try await ARSession.shared.worldMap()
        // Persist worldMap data
    }

    func loadAnchors() async throws -> [AnchorEntity] {
        // Load from saved ARWorldMap
        // Restore anchor positions
        return []
    }
}
```

### Image Anchors

```swift
func createImageAnchor(for imageName: String) -> AnchorEntity {
    guard let image = UIImage(named: imageName)?.cgImage else {
        fatalError("Image not found")
    }

    let anchor = AnchorEntity(.image(group: "LanguagePosters", name: imageName))
    return anchor
}
```

## Materials and Shaders

### Custom Materials

```swift
extension Material {
    static func createLabelMaterial(color: UIColor = .white, opacity: Float = 0.9) -> Material {
        var material = UnlitMaterial()
        material.color = .init(tint: color.withAlphaComponent(CGFloat(opacity)))
        material.blending = .transparent(opacity: .init(floatLiteral: Double(opacity)))
        return material
    }

    static func createGlowMaterial(color: UIColor) -> Material {
        var material = UnlitMaterial()
        material.color = .init(tint: color)
        material.emissiveColor = .init(color: color)
        material.emissiveIntensity = 2.0
        return material
    }

    static func createEnvironmentMaterial() -> Material {
        var material = PhysicallyBasedMaterial()
        material.baseColor = .init(tint: .white)
        material.roughness = .init(floatLiteral: 0.6)
        material.metallic = .init(floatLiteral: 0.0)
        return material
    }
}
```

## Animations

### Character Animations

```swift
class AnimationController {
    private var animations: [String: AnimationResource] = [:]
    private var entity: Entity

    init(entity: Entity) {
        self.entity = entity
        loadAnimations()
    }

    private func loadAnimations() {
        // Load animation clips
        animations["idle"] = try? AnimationResource.load(named: "idle")
        animations["speak"] = try? AnimationResource.load(named: "speak")
        animations["smile"] = try? AnimationResource.load(named: "smile")
        animations["thinking"] = try? AnimationResource.load(named: "thinking")
    }

    func playAnimation(named name: String, loop: Bool = true) {
        guard let animation = animations[name] else { return }

        if loop {
            entity.playAnimation(animation.repeat())
        } else {
            entity.playAnimation(animation)
        }
    }
}
```

### Label Animations

```swift
extension ObjectLabelEntity {
    func showWithAnimation() {
        // Scale up from zero
        var transform = self.transform
        transform.scale = [0, 0, 0]
        self.transform = transform

        self.move(
            to: Transform(scale: [1, 1, 1]),
            relativeTo: self.parent,
            duration: 0.3,
            timingFunction: .easeOut
        )
    }

    func hideWithAnimation() {
        self.move(
            to: Transform(scale: [0, 0, 0]),
            relativeTo: self.parent,
            duration: 0.2,
            timingFunction: .easeIn
        )
    }

    func pulse() {
        // Attention-grabbing pulse
        let scaleUp = Transform(scale: [1.2, 1.2, 1.2])
        let scaleDown = Transform(scale: [1.0, 1.0, 1.0])

        self.move(to: scaleUp, relativeTo: self.parent, duration: 0.3)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.move(to: scaleDown, relativeTo: self.parent, duration: 0.3)
        }
    }
}
```

## Collision and Physics

### Collision Setup

```swift
extension Entity {
    func enableCollision(shape: ShapeResource) {
        self.components.set(CollisionComponent(shapes: [shape]))
    }

    func enablePhysics(mass: Float = 1.0) {
        self.components.set(PhysicsBodyComponent(
            massProperties: .default,
            mode: .dynamic
        ))
    }
}
```

### Ray Casting

```swift
class InteractionHandler {
    func handleGaze(at point: CGPoint, in arView: ARView) {
        let results = arView.hitTest(point)

        for result in results {
            if let entity = result.entity as? ObjectLabelEntity {
                highlightLabel(entity)
            }
        }
    }

    func handleTap(at point: CGPoint, in arView: ARView) {
        let results = arView.hitTest(point)

        for result in results {
            if let entity = result.entity as? ObjectLabelEntity {
                entity.labelComponent.onTap?()
            }
        }
    }

    private func highlightLabel(_ label: ObjectLabelEntity) {
        // Visual feedback
        label.pulse()
    }
}
```

## Performance Optimization

### LOD (Level of Detail)

```swift
class LODComponent: Component {
    var lodLevels: [LODLevel]
    var currentLOD: Int = 0

    struct LODLevel {
        let maxDistance: Float
        let modelName: String
    }

    func updateLOD(distance: Float, entity: Entity) {
        for (index, level) in lodLevels.enumerated() {
            if distance < level.maxDistance {
                if currentLOD != index {
                    currentLOD = index
                    switchModel(to: level.modelName, for: entity)
                }
                break
            }
        }
    }

    private func switchModel(to modelName: String, for entity: Entity) {
        // Load and swap model
        Entity.loadModelAsync(named: modelName) { result in
            if case .success(let model) = result {
                entity.children.removeAll()
                entity.addChild(model)
            }
        }
    }
}
```

### Entity Culling

```swift
class EntityCullingSystem {
    func cullEntities(in scene: Scene, from cameraPosition: SIMD3<Float>) {
        let maxDistance: Float = 10.0

        for entity in scene.findAllEntities() {
            let distance = simd_distance(entity.position, cameraPosition)

            if distance > maxDistance {
                entity.isEnabled = false
            } else {
                entity.isEnabled = true
            }
        }
    }
}
```

## Spatial Audio

```swift
extension AICharacterEntity {
    func setupSpatialAudio() {
        // Create spatial audio source
        let audioSource = AudioFileResource.load(named: "character_voice.m4a")

        let audioController = entity.prepareAudio(audioSource)
        audioController.gain = 1.0
        audioController.speed = 1.0

        // Configure spatial blend
        // 0 = non-spatial, 1 = fully spatial
        audioController.spatialBlend = 1.0
    }
}
```

## Entity Pooling

```swift
class EntityPool<T: Entity> {
    private var available: [T] = []
    private var inUse: [T] = []
    private let createEntity: () -> T

    init(initialSize: Int, factory: @escaping () -> T) {
        self.createEntity = factory
        for _ in 0..<initialSize {
            available.append(factory())
        }
    }

    func acquire() -> T {
        if available.isEmpty {
            return createEntity()
        } else {
            let entity = available.removeLast()
            inUse.append(entity)
            return entity
        }
    }

    func release(_ entity: T) {
        if let index = inUse.firstIndex(where: { $0 === entity }) {
            inUse.remove(at: index)
            available.append(entity)
        }
    }
}

// Usage
let labelPool = EntityPool<ObjectLabelEntity>(initialSize: 50) {
    ObjectLabelEntity(word: .default, anchor: AnchorEntity())
}
```
