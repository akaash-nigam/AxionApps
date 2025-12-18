# 3D Assets & Rendering Pipeline

## Overview

This document defines the 3D asset pipeline and rendering system for Spatial Screenplay Workshop, including asset creation, optimization, loading, and real-time rendering on Apple Vision Pro.

## Asset Categories

### 1. Scene Cards
- 2D/3D hybrid UI elements
- Floating in 3D space
- Dynamic text content
- Low polygon count

### 2. Character Avatars
- Life-sized humanoid models
- Basic to detailed representations
- Animated (dialogue, gestures)
- Memory-efficient

### 3. Virtual Environments
- 100+ location library
- Interior and exterior spaces
- Dynamic lighting
- Weather effects

### 4. Props & Furniture
- Decorative and functional items
- Placed within environments
- Physics-enabled (optional)
- Scalable

### 5. UI Elements
- 3D buttons and controls
- Floating panels
- Spatial indicators
- Hover effects

## Asset Specifications

### Scene Cards

**Geometry**:
- Quad mesh (2 triangles)
- Size: 0.4m × 0.5m
- Rounded corners (shader-based)

**Materials**:
- PBR material (Physically Based Rendering)
- Base color: Dynamic (from project settings)
- Metallic: 0.0
- Roughness: 0.3
- Emissive: Subtle glow on hover

**Textures**:
- Base color map: Procedural gradient
- Text rendering: SwiftUI → RenderTexture
- Resolution: 512×640 px (updates dynamically)

**Implementation**:
```swift
import RealityKit

class SceneCardGenerator {
    func createSceneCard(scene: Scene, settings: CardSettings) -> Entity {
        let mesh = MeshResource.generatePlane(
            width: 0.4,
            height: 0.5,
            cornerRadius: 0.02
        )

        var material = PhysicallyBasedMaterial()
        material.baseColor = .init(tint: settings.backgroundColor)
        material.roughness = .init(floatLiteral: 0.3)
        material.metallic = .init(floatLiteral: 0.0)

        let entity = ModelEntity(mesh: mesh, materials: [material])

        // Add text overlay
        let textEntity = generateTextOverlay(scene: scene)
        textEntity.position.z = 0.001  // Slightly in front
        entity.addChild(textEntity)

        // Add interaction component
        entity.components[InputTargetComponent.self] = InputTargetComponent()
        entity.components[HoverEffectComponent.self] = HoverEffectComponent()

        return entity
    }

    private func generateTextOverlay(scene: Scene) -> Entity {
        // Render SwiftUI view to texture
        let swiftUIView = SceneCardContentView(scene: scene)
        let renderer = ImageRenderer(content: swiftUIView)
        renderer.scale = 2.0  // Retina

        guard let cgImage = renderer.cgImage else {
            return Entity()
        }

        // Create texture from CGImage
        let texture = try! TextureResource.generate(
            from: cgImage,
            options: .init(semantic: .color)
        )

        var material = UnlitMaterial()
        material.color = .init(texture: .init(texture))

        let mesh = MeshResource.generatePlane(
            width: 0.38,
            height: 0.48
        )

        return ModelEntity(mesh: mesh, materials: [material])
    }
}
```

### Character Avatars

**Representation Levels**:

#### Level 1: Silhouette (Low-Resource)
- **Geometry**: Capsule (50 triangles)
- **Material**: Emissive only
- **Animation**: None (static or simple float)
- **Memory**: ~100 KB per character
- **Use case**: Multiple characters visible

```swift
func createSilhouetteAvatar(character: Character) -> Entity {
    let height = character.appearance.height ?? 1.7
    let radius: Float = 0.2

    let mesh = MeshResource.generateCapsule(height: height, radius: radius)

    var material = UnlitMaterial()
    material.color = .init(tint: character.color.withAlphaComponent(0.8))

    let entity = ModelEntity(mesh: mesh, materials: [material])

    // Add name label above
    let label = createNameLabel(character.name)
    label.position.y = height / 2 + 0.2
    entity.addChild(label)

    return entity
}
```

#### Level 2: Simple Avatar (Medium-Resource)
- **Geometry**: 2,000-5,000 triangles
- **Material**: PBR with base colors
- **Animation**: Basic (idle, talking)
- **Memory**: ~2 MB per character
- **Use case**: 1-2 characters in performance mode

**Model Structure**:
```
SimpleAvatar.usdz
├── Body (1,500 tris)
├── Head (800 tris)
├── Arms (600 tris)
├── Legs (600 tris)
└── Skeleton (15 bones)
    ├── Root
    ├── Spine
    ├── Head
    ├── LeftArm / RightArm
    └── LeftLeg / RightLeg
```

#### Level 3: Detailed Avatar (High-Resource)
- **Geometry**: 10,000-20,000 triangles
- **Material**: PBR with texture maps
- **Animation**: Full (body language, facial)
- **Memory**: ~10 MB per character
- **Use case**: Single character focus

**Texture Maps**:
- Base color: 2048×2048
- Normal map: 2048×2048
- Roughness/Metallic: 1024×1024

**Animation**:
- Idle cycle (looping)
- Talking (triggered by dialogue)
- Gesture library (point, shrug, nod, etc.)

```swift
class AvatarAnimator {
    func playDialogue(avatar: Entity, audioBuffer: AVAudioBuffer) {
        // Extract phonemes from audio
        let phonemes = analyzePhonemes(audioBuffer)

        // Animate based on phonemes
        for phoneme in phonemes {
            let blendShapes = phonemeToBlendShapes(phoneme)
            animateBlendShapes(avatar, blendShapes, duration: phoneme.duration)
        }

        // Body language
        let gesture = selectRandomGesture()
        animateGesture(avatar, gesture)
    }
}
```

### Virtual Environments

**Asset Structure**:
```
Environment.usdz
├── Ground (plane, tiled texture)
├── Walls (geometry or skybox)
├── Ceiling (geometry or omitted)
├── Furniture (grouped)
│   ├── Table
│   ├── Chairs
│   └── Decorations
├── Lighting (baked or dynamic)
├── Props (interactive)
└── Effects (particles, fog, etc.)
```

**Polygon Budget**:
- Small environments (café, office): 50,000 triangles
- Medium environments (apartment): 100,000 triangles
- Large environments (street, park): 200,000 triangles

**Optimization Techniques**:
- **Instancing**: Reuse chairs, windows, etc.
- **LOD**: Swap high/low poly models based on distance
- **Occlusion culling**: Don't render hidden geometry
- **Baked lighting**: Pre-compute shadows and GI

**Material Setup**:
```swift
var environmentMaterial = PhysicallyBasedMaterial()

// Load textures
environmentMaterial.baseColor = .init(
    texture: .init(try! .load(named: "floor_basecolor"))
)
environmentMaterial.normal = .init(
    texture: .init(try! .load(named: "floor_normal"))
)
environmentMaterial.roughness = .init(
    texture: .init(try! .load(named: "floor_roughness"))
)

// Tiling
environmentMaterial.textureCoordinateTransform = .init(
    scale: SIMD2(repeating: 5.0)
)
```

**Dynamic Lighting**:
```swift
func setupLighting(in environment: Entity, settings: LightingSettings) {
    // Directional light (sun/moon)
    let directionalLight = DirectionalLight()
    directionalLight.light.intensity = settings.intensity * 1000
    directionalLight.light.color = .white
    directionalLight.shadow = DirectionalLightComponent.Shadow(
        maximumDistance: 10.0,
        depthBias: 2.0
    )

    let lightEntity = Entity()
    lightEntity.components[DirectionalLight.self] = directionalLight
    lightEntity.orientation = simd_quatf(
        angle: .pi / 4,
        axis: SIMD3(x: 1, y: -1, z: 0)
    )
    environment.addChild(lightEntity)

    // Ambient light
    let ambientLight = Entity()
    var ambient = AmbientLightComponent()
    ambient.intensity = settings.intensity * 200
    ambientLight.components[AmbientLightComponent.self] = ambient
    environment.addChild(ambientLight)

    // Point lights (lamps, etc.)
    for lightSource in settings.customLights {
        let pointLight = createPointLight(lightSource)
        environment.addChild(pointLight)
    }
}
```

## Asset Library Structure

### Directory Layout

```
Assets/
├── SceneCards/
│   └── Templates/
│       ├── default.usdz
│       └── minimal.usdz
├── Avatars/
│   ├── Silhouettes/
│   ├── Simple/
│   │   ├── male_01.usdz
│   │   ├── female_01.usdz
│   │   └── neutral_01.usdz
│   └── Detailed/
│       ├── male_detailed_01.usdz
│       └── female_detailed_01.usdz
├── Environments/
│   ├── Interiors/
│   │   ├── Residential/
│   │   │   ├── apartment_modern.usdz
│   │   │   ├── house_suburban.usdz
│   │   │   └── loft_industrial.usdz
│   │   ├── Commercial/
│   │   │   ├── coffee_shop_01.usdz
│   │   │   ├── restaurant_casual.usdz
│   │   │   └── bar_dive.usdz
│   │   └── Office/
│   │       ├── corporate_office.usdz
│   │       └── startup_office.usdz
│   └── Exteriors/
│       ├── Urban/
│       │   ├── city_street.usdz
│       │   └── alley_downtown.usdz
│       └── Nature/
│           ├── park_public.usdz
│           └── forest_clearing.usdz
├── Props/
│   ├── Furniture/
│   │   ├── chair_modern.usdz
│   │   ├── table_dining.usdz
│   │   └── couch_sectional.usdz
│   └── Decorations/
│       ├── plant_potted.usdz
│       └── picture_frame.usdz
└── Materials/
    ├── Wood/
    │   ├── oak_basecolor.png
    │   ├── oak_normal.png
    │   └── oak_roughness.png
    └── Concrete/
        └── ...
```

### Asset Metadata

```swift
struct AssetMetadata: Codable {
    let id: String
    let name: String
    let category: AssetCategory
    let subcategory: String?
    let tags: [String]
    let fileURL: URL
    let thumbnailURL: URL
    let fileSize: Int  // bytes
    let triangleCount: Int
    let requiredMemory: Int  // estimated MB
    let lodLevels: [LODLevel]
    let author: String
    let license: String
    let version: String
}

enum AssetCategory: String, Codable {
    case sceneCard
    case avatar
    case environment
    case prop
    case furniture
    case material
}

struct LODLevel: Codable {
    let level: Int  // 0 = highest quality
    let fileURL: URL
    let triangleCount: Int
    let minDistance: Float
    let maxDistance: Float
}
```

### Asset Catalog

```swift
class AssetCatalog {
    static let shared = AssetCatalog()

    private var catalog: [String: AssetMetadata] = [:]
    private let catalogURL: URL

    init() {
        catalogURL = Bundle.main.url(forResource: "AssetCatalog", withExtension: "json")!
        loadCatalog()
    }

    func searchAssets(
        category: AssetCategory? = nil,
        tags: [String] = [],
        query: String? = nil
    ) -> [AssetMetadata] {
        var results = Array(catalog.values)

        if let category = category {
            results = results.filter { $0.category == category }
        }

        if !tags.isEmpty {
            results = results.filter { asset in
                !Set(asset.tags).intersection(tags).isEmpty
            }
        }

        if let query = query?.lowercased() {
            results = results.filter {
                $0.name.lowercased().contains(query) ||
                $0.tags.contains { $0.lowercased().contains(query) }
            }
        }

        return results
    }

    func getAsset(id: String) -> AssetMetadata? {
        return catalog[id]
    }
}
```

## Asset Loading Pipeline

### Async Loading

```swift
class AssetLoader {
    static let shared = AssetLoader()

    private var cache: NSCache<NSString, Entity> = NSCache()
    private var loadingTasks: [String: Task<Entity, Error>] = [:]

    func loadAsset(id: String) async throws -> Entity {
        // Check cache
        if let cached = cache.object(forKey: id as NSString) {
            return cached.clone(recursive: true)
        }

        // Check if already loading
        if let existingTask = loadingTasks[id] {
            return try await existingTask.value
        }

        // Start new load
        let task = Task<Entity, Error> {
            guard let metadata = AssetCatalog.shared.getAsset(id: id) else {
                throw AssetError.notFound(id)
            }

            let entity = try await Entity.load(contentsOf: metadata.fileURL)

            // Optimize
            optimize(entity)

            // Cache
            cache.setObject(entity, forKey: id as NSString)

            return entity
        }

        loadingTasks[id] = task

        defer {
            loadingTasks.removeValue(forKey: id)
        }

        return try await task.value
    }

    private func optimize(_ entity: Entity) {
        // Generate collision shapes
        if entity.components[ModelComponent.self] != nil {
            entity.generateCollisionShapes(recursive: true)
        }

        // Optimize textures
        for child in entity.children {
            optimize(child)
        }
    }
}
```

### Streaming & Progressive Loading

```swift
class ProgressiveAssetLoader {
    func loadEnvironment(
        id: String,
        progressHandler: @escaping (Float) -> Void
    ) async throws -> Entity {
        let metadata = AssetCatalog.shared.getAsset(id: id)!

        // Load lowest LOD first (fast)
        progressHandler(0.1)
        let lowLOD = try await loadLOD(metadata.lodLevels.last!)
        progressHandler(0.3)

        // Return early for immediate display
        let environment = lowLOD.clone(recursive: true)

        // Continue loading higher LODs in background
        Task {
            progressHandler(0.5)
            let mediumLOD = try await loadLOD(metadata.lodLevels[1])
            progressHandler(0.7)

            let highLOD = try await loadLOD(metadata.lodLevels[0])
            progressHandler(1.0)

            // Swap LODs
            await swapLOD(in: environment, with: highLOD)
        }

        return environment
    }

    private func loadLOD(_ lod: LODLevel) async throws -> Entity {
        return try await Entity.load(contentsOf: lod.fileURL)
    }

    @MainActor
    private func swapLOD(in entity: Entity, with newLOD: Entity) {
        // Smoothly transition between LODs
        entity.children.removeAll()
        entity.children.append(contentsOf: newLOD.children)
    }
}
```

### Memory Management

```swift
class AssetMemoryManager {
    static let shared = AssetMemoryManager()

    private let memoryBudget: Int = 1_500_000_000  // 1.5 GB
    private var currentUsage: Int = 0
    private var loadedAssets: [String: (entity: Entity, size: Int)] = [:]

    func canLoadAsset(metadata: AssetMetadata) -> Bool {
        return currentUsage + metadata.requiredMemory * 1_000_000 <= memoryBudget
    }

    func trackAsset(id: String, entity: Entity, metadata: AssetMetadata) {
        let size = metadata.requiredMemory * 1_000_000
        loadedAssets[id] = (entity, size)
        currentUsage += size
    }

    func unloadAsset(id: String) {
        guard let (entity, size) = loadedAssets.removeValue(forKey: id) else {
            return
        }

        // Remove from scene
        entity.removeFromParent()

        // Update usage
        currentUsage -= size

        // Invalidate cache
        AssetLoader.shared.cache.removeObject(forKey: id as NSString)
    }

    func freeMemoryIfNeeded(toLoad metadata: AssetMetadata) {
        let requiredMemory = metadata.requiredMemory * 1_000_000

        while currentUsage + requiredMemory > memoryBudget {
            // Unload least recently used asset
            guard let lruAssetId = findLeastRecentlyUsed() else {
                break
            }
            unloadAsset(id: lruAssetId)
        }
    }

    private func findLeastRecentlyUsed() -> String? {
        // Implement LRU logic
        // For simplicity, unload first asset
        return loadedAssets.keys.first
    }
}
```

## LOD (Level of Detail) System

### Dynamic LOD Selection

```swift
class LODManager {
    func selectLOD(
        for entity: Entity,
        userPosition: SIMD3<Float>,
        metadata: AssetMetadata
    ) -> LODLevel? {
        let distance = distance(entity.position, userPosition)

        for lod in metadata.lodLevels.sorted(by: { $0.level < $1.level }) {
            if distance >= lod.minDistance && distance < lod.maxDistance {
                return lod
            }
        }

        return metadata.lodLevels.last  // Fallback to lowest
    }

    func updateLODs(in scene: Entity, userPosition: SIMD3<Float>) {
        for child in scene.children {
            guard let metadata = getMetadata(for: child) else { continue }

            let currentLOD = getCurrentLOD(child)
            let desiredLOD = selectLOD(
                for: child,
                userPosition: userPosition,
                metadata: metadata
            )

            if currentLOD?.level != desiredLOD?.level {
                Task {
                    await swapLOD(child, to: desiredLOD!)
                }
            }
        }
    }
}
```

## Rendering Optimization

### Culling

```swift
class CullingSystem {
    func cullEntities(
        in scene: Entity,
        camera: Entity
    ) -> [Entity] {
        var visibleEntities: [Entity] = []

        for entity in scene.children {
            if isFrustumCulled(entity, camera: camera) {
                entity.isEnabled = false
                continue
            }

            if isOcclusionCulled(entity, camera: camera) {
                entity.isEnabled = false
                continue
            }

            if isDistanceCulled(entity, camera: camera) {
                entity.isEnabled = false
                continue
            }

            entity.isEnabled = true
            visibleEntities.append(entity)
        }

        return visibleEntities
    }

    private func isFrustumCulled(_ entity: Entity, camera: Entity) -> Bool {
        // Check if entity is outside camera frustum
        // ...
        return false
    }

    private func isOcclusionCulled(_ entity: Entity, camera: Entity) -> Bool {
        // Check if entity is blocked by other geometry
        // Note: Expensive, use sparingly
        return false
    }

    private func isDistanceCulled(_ entity: Entity, camera: Entity) -> Bool {
        let distance = distance(entity.position, camera.position)
        return distance > 10.0  // Hide entities > 10m away
    }
}
```

### Instancing

```swift
class InstancedRenderer {
    func createInstanced(
        mesh: MeshResource,
        material: Material,
        count: Int,
        transforms: [Transform]
    ) -> Entity {
        let instancedEntity = Entity()

        var model = ModelComponent(
            mesh: mesh,
            materials: [material]
        )
        model.instanceCount = count

        instancedEntity.components[ModelComponent.self] = model

        // Set instance transforms
        instancedEntity.components[InstancedComponent.self] = InstancedComponent(
            transforms: transforms
        )

        return instancedEntity
    }
}

// Usage: Render 50 chairs with single draw call
let chairMesh = try! await loadMesh("chair.usdz")
let chairMaterial = createMaterial()

let chairPositions: [Transform] = generateChairPositions()

let instancedChairs = InstancedRenderer().createInstanced(
    mesh: chairMesh,
    material: chairMaterial,
    count: 50,
    transforms: chairPositions
)
```

### Texture Compression

```swift
func compressTexture(image: CGImage) throws -> TextureResource {
    // Use ASTC compression for smaller memory footprint
    let options = TextureResource.CreateOptions(
        semantic: .color,
        mipmapsMode: .allocateAndGenerateAll
    )

    return try TextureResource.generate(
        from: image,
        options: options
    )
}
```

## Performance Targets

### Frame Rate
- **Target**: 90 FPS
- **Minimum**: 60 FPS
- **Dropped frames**: < 1% during normal use

### Memory Budget
- **Total app memory**: 4 GB
- **3D assets**: 1.5 GB
- **Scene cards**: 500 MB (100 cards)
- **Characters**: 500 MB (2-3 visible)
- **Environment**: 500 MB (1 active)

### Draw Calls
- **Target**: < 100 draw calls per frame
- **Use instancing** for repeated objects
- **Batch** similar materials

### Triangle Budget
- **Per frame**: < 1,000,000 triangles
- **Scene cards**: 2 triangles each (200 total)
- **Characters**: 2,000-5,000 each (10,000 max)
- **Environment**: 50,000-200,000

## Asset Creation Guidelines

### For Artists

**Polygon Count**:
- Keep models as low-poly as possible
- Use normal maps for detail instead of geometry
- Target polycount based on object importance and size

**Textures**:
- Use power-of-2 dimensions (512, 1024, 2048)
- Compress textures (ASTC on device)
- Share textures between similar objects
- Bake lighting when possible

**Materials**:
- Use PBR workflow (Metallic/Roughness)
- Limit number of materials per model
- Use texture atlases for small objects

**Hierarchy**:
- Keep hierarchy shallow
- Group logical parts
- Name objects clearly

**Export Settings**:
- USDZ format for primary assets
- Include LODs in single file
- Embed textures or reference external
- Set appropriate scale (meters)

### Quality Checklist

- [ ] Model under triangle budget
- [ ] All textures compressed
- [ ] Materials using PBR
- [ ] LODs generated (if needed)
- [ ] Collision shapes appropriate
- [ ] Proper scale (1 unit = 1 meter)
- [ ] Pivot point centered
- [ ] No unnecessary geometry
- [ ] Clean topology
- [ ] Manifold mesh (watertight)

## Shader System

### Custom Shaders

```swift
import Metal

class CustomShaderLibrary {
    static func createHologramShader() -> CustomMaterial {
        let surfaceShader = CustomMaterial.SurfaceShader(
            named: "hologramShader",
            in: MetalLibrary.default
        )

        var material = try! CustomMaterial(
            surfaceShader: surfaceShader,
            lightingModel: .unlit
        )

        material.custom.value = SIMD4<Float>(0.0, 1.0, 1.0, 0.5)  // Cyan hologram

        return material
    }
}

// Metal shader (hologramShader.metal)
/*
#include <metal_stdlib>
using namespace metal;

[[visible]]
void hologramShader(realitykit::surface_parameters params) {
    float3 color = float3(0.0, 1.0, 1.0);  // Cyan
    float alpha = 0.5 + 0.2 * sin(params.time * 2.0);  // Pulsing

    params.base_color = float4(color, alpha);
    params.emissive_color = float3(color * 0.5);
}
*/
```

---

**Document Version**: 1.0
**Last Updated**: 2025-11-24
**Author**: 3D Graphics Team
