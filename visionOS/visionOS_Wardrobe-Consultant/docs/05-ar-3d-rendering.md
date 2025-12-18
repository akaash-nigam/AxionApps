# AR/3D Rendering Technical Specification

## Document Overview

**Version**: 1.0
**Last Updated**: 2025-11-24
**Status**: Draft

## 1. Executive Summary

This document defines the technical implementation of AR body tracking, 3D clothing rendering, and cloth simulation for Wardrobe Consultant. The system leverages ARKit for body tracking, RealityKit for 3D rendering, and Metal shaders for realistic fabric materials to create a convincing virtual try-on experience.

## 2. AR Body Tracking System

### 2.1 ARKit Body Tracking Overview

**Capabilities**:
- 23-joint skeleton tracking
- Person segmentation (body masking)
- Body pose estimation
- Real-time updates at 60fps

**Requirements**:
- Vision Pro (ARKit 4+)
- Adequate lighting conditions
- User standing 1-3 meters from device
- Minimal occlusion

### 2.2 ARSession Configuration

```swift
import ARKit
import RealityKit

class ARBodyTrackingManager {
    private var arSession: ARSession
    private var bodyAnchor: ARBodyAnchor?

    init() {
        self.arSession = ARSession()
    }

    func startTracking() throws {
        // Check if body tracking is supported
        guard ARBodyTrackingConfiguration.isSupported else {
            throw ARError.deviceNotSupported
        }

        // Configure session
        let configuration = ARBodyTrackingConfiguration()
        configuration.automaticSkeletonScaleEstimationEnabled = true
        configuration.initialWorldMap = nil
        configuration.frameSemantics = [.personSegmentation, .personSegmentationWithDepth]

        // Start session
        arSession.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }

    func stopTracking() {
        arSession.pause()
    }

    func getCurrentBodyAnchor() -> ARBodyAnchor? {
        return bodyAnchor
    }
}

// MARK: - ARSessionDelegate
extension ARBodyTrackingManager: ARSessionDelegate {
    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        for anchor in anchors {
            if let bodyAnchor = anchor as? ARBodyAnchor {
                self.bodyAnchor = bodyAnchor
                notifyBodyUpdated(bodyAnchor)
            }
        }
    }

    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        // Process person segmentation
        if let segmentationBuffer = frame.segmentationBuffer {
            processSegmentation(segmentationBuffer)
        }
    }
}
```

### 2.3 Body Skeleton Joints

**ARKit Skeleton Joints** (23 joints):
```swift
enum BodyJoint {
    case root                  // Hip center
    case hipsJoint
    case leftUpLeg
    case leftLeg
    case leftFoot
    case rightUpLeg
    case rightLeg
    case rightFoot
    case spine1
    case spine2
    case spine3
    case spine4
    case spine5
    case spine6
    case spine7                // Neck base
    case leftShoulder1
    case leftArm
    case leftForearm
    case leftHand
    case rightShoulder1
    case rightArm
    case rightForearm
    case rightHand
    case neck1                 // Neck top

    var jointName: String {
        // ARSkeleton.JointName equivalents
        switch self {
        case .root: return ARSkeleton.JointName.root.rawValue
        case .leftHand: return ARSkeleton.JointName.leftHand.rawValue
        // ... all joints
        default: return ""
        }
    }
}
```

### 2.4 Body Measurements Extraction

```swift
class BodyMeasurementExtractor {
    func extractMeasurements(from bodyAnchor: ARBodyAnchor) -> BodyMeasurements? {
        let skeleton = bodyAnchor.skeleton

        // Get joint transforms
        guard let leftShoulder = getJointPosition(skeleton, .leftShoulder1),
              let rightShoulder = getJointPosition(skeleton, .rightShoulder1),
              let leftHip = getJointPosition(skeleton, .leftUpLeg),
              let rightHip = getJointPosition(skeleton, .rightUpLeg),
              let root = getJointPosition(skeleton, .root),
              let head = getJointPosition(skeleton, .neck1) else {
            return nil
        }

        // Calculate measurements
        let shoulderWidth = distance(leftShoulder, rightShoulder)
        let hipWidth = distance(leftHip, rightHip)
        let height = distance(root, head) * 1.15 // Estimate full height

        // Chest estimation (proportional to shoulder width)
        let chestCircumference = shoulderWidth * 2.5

        // Waist estimation (proportional to hip width)
        let waistCircumference = hipWidth * 2.2

        return BodyMeasurements(
            height: Measurement(value: Double(height), unit: .meters),
            shoulderWidth: Measurement(value: Double(shoulderWidth), unit: .meters),
            chest: Measurement(value: Double(chestCircumference), unit: .meters),
            waist: Measurement(value: Double(waistCircumference), unit: .meters),
            hips: Measurement(value: Double(hipWidth * 2.3), unit: .meters),
            inseam: Measurement(value: Double(height * 0.45), unit: .meters),
            confidence: calculateConfidence(skeleton)
        )
    }

    private func getJointPosition(_ skeleton: ARSkeleton3D, _ joint: BodyJoint) -> simd_float3? {
        guard let transform = skeleton.jointModelTransforms[ARSkeleton.JointName(rawValue: joint.jointName)] else {
            return nil
        }
        return simd_make_float3(transform.columns.3)
    }

    private func distance(_ a: simd_float3, _ b: simd_float3) -> Float {
        return simd_distance(a, b)
    }

    private func calculateConfidence(_ skeleton: ARSkeleton3D) -> Float {
        // Calculate confidence based on joint visibility and tracking quality
        // 0.0 = poor tracking, 1.0 = excellent tracking
        let trackedJointsCount = skeleton.jointModelTransforms.count
        let expectedJointsCount = 23
        return Float(trackedJointsCount) / Float(expectedJointsCount)
    }
}
```

### 2.5 Person Segmentation

```swift
class PersonSegmentationProcessor {
    func processSegmentation(_ buffer: CVPixelBuffer) -> CVPixelBuffer {
        // Person segmentation buffer from ARFrame
        // Values: 0 = background, 255 = person

        // Use for:
        // 1. Masking clothing overlay to body only
        // 2. Depth-based occlusion
        // 3. Boundary detection for cloth fitting

        return buffer
    }

    func createBodyMask(from segmentation: CVPixelBuffer, size: CGSize) -> MTLTexture? {
        // Convert CVPixelBuffer to Metal texture for shader use
        var texture: MTLTexture?

        let textureCache = getTextureCache()
        CVMetalTextureCacheCreateTextureFromImage(
            nil,
            textureCache,
            segmentation,
            nil,
            .r8Unorm,
            CVPixelBufferGetWidth(segmentation),
            CVPixelBufferGetHeight(segmentation),
            0,
            &texture
        )

        return texture
    }
}
```

## 3. 3D Clothing Model System

### 3.1 Model Format & Structure

**Supported Formats**:
- **USDZ** (Preferred): Apple's AR format, supports materials, animations
- **GLB**: Fallback format from retailers
- **OBJ**: Legacy support

**Model Requirements**:
```
Clothing Model Structure:
- Vertices: 5,000-50,000 (LOD dependent)
- Triangles: 10,000-100,000
- UV Mapping: Required for textures
- Rigging: Optional (for animation)
- Materials: PBR (Physically Based Rendering)

Directory Structure:
/Models
  /Shirts
    /shirt_001.usdz
    /shirt_001_lod1.usdz (lower detail)
    /shirt_001_lod2.usdz (lowest detail)
  /Pants
  /Dresses
  ...
```

### 3.2 Model Loading & Caching

```swift
import RealityKit

class ClothingModelLoader {
    private var modelCache: [UUID: ModelEntity] = [:]
    private let cacheQueue = DispatchQueue(label: "com.wardrobe.modelCache")

    func loadModel(for item: WardrobeItem) async throws -> ModelEntity {
        // Check cache first
        if let cached = getCachedModel(item.id) {
            return cached.clone(recursive: true)
        }

        // Load from file or generate
        let model: ModelEntity

        if let modelURL = item.modelURL {
            // Load existing 3D model
            model = try await loadFromURL(modelURL)
        } else {
            // Generate model from photo
            model = try await generateFromPhoto(item)
        }

        // Apply materials
        try await applyMaterials(to: model, item: item)

        // Cache
        cacheModel(model, for: item.id)

        return model
    }

    private func loadFromURL(_ url: URL) async throws -> ModelEntity {
        return try await ModelEntity.load(contentsOf: url)
    }

    private func generateFromPhoto(_ item: WardrobeItem) async throws -> ModelEntity {
        // Generate 3D model from 2D photo (future enhancement)
        // For MVP: Use parametric templates

        let template = getTemplateForCategory(item.category)
        let model = template.clone(recursive: true)

        return model
    }

    private func applyMaterials(to model: ModelEntity, item: WardrobeItem) async throws {
        // Get or create material
        let material = try await createMaterial(for: item)

        // Apply to model
        model.model?.materials = [material]
    }

    private func getTemplateForCategory(_ category: String) -> ModelEntity {
        // Return parametric template based on category
        // Template is basic shape that can be scaled/deformed

        switch ClothingCategory(rawValue: category) {
        case .shirt, .blouse:
            return createShirtTemplate()
        case .pants, .jeans:
            return createPantsTemplate()
        case .dress:
            return createDressTemplate()
        default:
            return createGenericTemplate()
        }
    }

    private func createShirtTemplate() -> ModelEntity {
        // Create basic shirt mesh
        let mesh = MeshResource.generateBox(size: [0.5, 0.7, 0.3])
        let entity = ModelEntity(mesh: mesh)
        return entity
    }
}
```

### 3.3 Model Attachment to Body

```swift
class ClothingAttachmentSystem {
    func attachClothingToBody(
        _ clothingModel: ModelEntity,
        bodyAnchor: ARBodyAnchor,
        item: WardrobeItem
    ) {
        // Determine attachment strategy based on clothing category
        let category = ClothingCategory(rawValue: item.category) ?? .shirt

        switch category {
        case .shirt, .blouse, .tshirt:
            attachToUpperBody(clothingModel, bodyAnchor: bodyAnchor)
        case .pants, .jeans, .shorts:
            attachToLowerBody(clothingModel, bodyAnchor: bodyAnchor)
        case .dress:
            attachToDress(clothingModel, bodyAnchor: bodyAnchor)
        default:
            attachToClosestJoint(clothingModel, bodyAnchor: bodyAnchor)
        }
    }

    private func attachToUpperBody(_ model: ModelEntity, bodyAnchor: ARBodyAnchor) {
        let skeleton = bodyAnchor.skeleton

        // Key joints for upper body clothing
        guard let spine = getJointTransform(skeleton, .spine4),
              let leftShoulder = getJointTransform(skeleton, .leftShoulder1),
              let rightShoulder = getJointTransform(skeleton, .rightShoulder1) else {
            return
        }

        // Position clothing at spine (chest center)
        model.transform.matrix = spine

        // Scale based on body dimensions
        let shoulderWidth = distance(
            simd_make_float3(leftShoulder.columns.3),
            simd_make_float3(rightShoulder.columns.3)
        )
        let scale = shoulderWidth / 0.4 // 0.4m is standard template width
        model.scale = [scale, scale, scale]
    }

    private func attachToLowerBody(_ model: ModelEntity, bodyAnchor: ARBodyAnchor) {
        let skeleton = bodyAnchor.skeleton

        // Key joints for lower body clothing
        guard let hips = getJointTransform(skeleton, .hipsJoint),
              let leftHip = getJointTransform(skeleton, .leftUpLeg),
              let rightHip = getJointTransform(skeleton, .rightUpLeg) else {
            return
        }

        // Position clothing at hips
        model.transform.matrix = hips

        // Scale based on body dimensions
        let hipWidth = distance(
            simd_make_float3(leftHip.columns.3),
            simd_make_float3(rightHip.columns.3)
        )
        let scale = hipWidth / 0.35 // 0.35m is standard template width
        model.scale = [scale, scale, scale]
    }

    private func getJointTransform(_ skeleton: ARSkeleton3D, _ joint: BodyJoint) -> simd_float4x4? {
        return skeleton.jointModelTransforms[ARSkeleton.JointName(rawValue: joint.jointName)]
    }

    private func distance(_ a: simd_float3, _ b: simd_float3) -> Float {
        return simd_distance(a, b)
    }
}
```

## 4. Fabric Material System

### 4.1 PBR Material Properties

```swift
struct FabricMaterialProperties {
    // Base color
    var baseColor: UIColor

    // PBR properties
    var roughness: Float        // 0.0 (smooth) - 1.0 (rough)
    var metallic: Float         // 0.0 (non-metal) - 1.0 (metal)
    var specular: Float         // Specular intensity

    // Fabric-specific
    var fabricType: FabricType
    var normalMapIntensity: Float
    var patternScale: Float

    static func forFabricType(_ type: FabricType) -> FabricMaterialProperties {
        switch type {
        case .cotton:
            return FabricMaterialProperties(
                baseColor: .white,
                roughness: 0.8,
                metallic: 0.0,
                specular: 0.2,
                fabricType: .cotton,
                normalMapIntensity: 0.5,
                patternScale: 1.0
            )
        case .silk:
            return FabricMaterialProperties(
                baseColor: .white,
                roughness: 0.2,
                metallic: 0.0,
                specular: 0.9,
                fabricType: .silk,
                normalMapIntensity: 0.2,
                patternScale: 1.0
            )
        case .denim:
            return FabricMaterialProperties(
                baseColor: .blue,
                roughness: 0.9,
                metallic: 0.0,
                specular: 0.1,
                fabricType: .denim,
                normalMapIntensity: 0.8,
                patternScale: 1.5
            )
        case .leather:
            return FabricMaterialProperties(
                baseColor: .brown,
                roughness: 0.5,
                metallic: 0.0,
                specular: 0.6,
                fabricType: .leather,
                normalMapIntensity: 0.6,
                patternScale: 1.0
            )
        case .wool:
            return FabricMaterialProperties(
                baseColor: .gray,
                roughness: 0.95,
                metallic: 0.0,
                specular: 0.1,
                fabricType: .wool,
                normalMapIntensity: 0.9,
                patternScale: 0.8
            )
        default:
            return FabricMaterialProperties(
                baseColor: .white,
                roughness: 0.7,
                metallic: 0.0,
                specular: 0.3,
                fabricType: .cotton,
                normalMapIntensity: 0.5,
                patternScale: 1.0
            )
        }
    }
}
```

### 4.2 Material Creation

```swift
class FabricMaterialFactory {
    func createMaterial(for item: WardrobeItem) async throws -> Material {
        // Get base properties for fabric type
        let fabricType = FabricType(rawValue: item.fabric ?? "cotton") ?? .cotton
        var properties = FabricMaterialProperties.forFabricType(fabricType)

        // Override base color with item's actual color
        properties.baseColor = UIColor(hex: item.primaryColor)

        // Create PBR material
        var material = PhysicallyBasedMaterial()

        // Base color
        material.baseColor = PhysicallyBasedMaterial.BaseColor(tint: properties.baseColor)

        // Roughness
        material.roughness = PhysicallyBasedMaterial.Roughness(floatLiteral: properties.roughness)

        // Metallic
        material.metallic = PhysicallyBasedMaterial.Metallic(floatLiteral: properties.metallic)

        // Specular
        material.specular = PhysicallyBasedMaterial.Specular(floatLiteral: properties.specular)

        // Normal map for fabric texture
        if let normalMap = await loadNormalMap(for: fabricType) {
            material.normal = PhysicallyBasedMaterial.Normal(texture: .init(normalMap))
        }

        // Pattern/texture overlay
        if let pattern = item.pattern,
           let patternTexture = await loadPatternTexture(pattern) {
            // Blend pattern with base color
            material.baseColor = PhysicallyBasedMaterial.BaseColor(
                texture: .init(patternTexture)
            )
        }

        return material
    }

    private func loadNormalMap(for fabricType: FabricType) async -> TextureResource? {
        // Load pre-made normal maps for fabric types
        let fileName = "\(fabricType.rawValue)_normal"
        return try? await TextureResource.load(named: fileName)
    }

    private func loadPatternTexture(_ pattern: String) async -> TextureResource? {
        // Load pattern textures (stripes, florals, etc.)
        return try? await TextureResource.load(named: pattern)
    }
}
```

### 4.3 Custom Metal Shaders (Advanced)

```metal
// fabric_shader.metal

#include <metal_stdlib>
#include <RealityKit/RealityKit.h>
using namespace metal;

[[visible]]
void fabricSurfaceShader(realitykit::surface_parameters params)
{
    // Get surface properties
    half3 baseColor = params.material().base_color().rgb;
    float roughness = params.material().roughness();
    float metallic = params.material().metallic();

    // Fabric-specific adjustments
    // Add subtle noise for fabric texture
    float2 uv = params.geometry().uv0();
    float noise = fract(sin(dot(uv, float2(12.9898, 78.233))) * 43758.5453);
    roughness = mix(roughness, roughness + 0.05, noise);

    // Apply to surface
    params.surface().set_base_color(baseColor);
    params.surface().set_roughness(roughness);
    params.surface().set_metallic(metallic);

    // Add subsurface scattering for thin fabrics (silk, cotton)
    if (roughness < 0.5) {
        params.surface().set_opacity(0.98); // Slight translucency
    }
}
```

## 5. Cloth Simulation & Physics

### 5.1 Simulation Strategy

**Approaches** (in order of complexity):
1. **Static Overlay** (MVP): No physics, clothing sticks to body
2. **Vertex Animation**: Pre-baked animations for movement
3. **Spring-Based Physics**: Simple cloth simulation
4. **Full Cloth Simulation**: Realistic draping and movement

**For MVP: Use Static Overlay + Vertex Animation**

### 5.2 Static Overlay Implementation

```swift
class StaticClothingOverlay {
    func updateClothingPosition(
        _ model: ModelEntity,
        bodyAnchor: ARBodyAnchor
    ) {
        // Update clothing position to follow body
        // No physics, just direct attachment

        let attachmentSystem = ClothingAttachmentSystem()
        attachmentSystem.attachClothingToBody(
            model,
            bodyAnchor: bodyAnchor,
            item: getCurrentItem()
        )
    }
}
```

### 5.3 Simple Physics (Future Enhancement)

```swift
class ClothPhysicsSimulator {
    private var clothVertices: [simd_float3] = []
    private var clothConstraints: [(Int, Int, Float)] = [] // (vertex1, vertex2, restDistance)

    func initializeCloth(mesh: MeshResource) {
        // Extract vertices from mesh
        // Create constraints between vertices

        // Spring constraints for cloth
        // Each vertex connected to neighbors
    }

    func simulateStep(deltaTime: Float, bodyAnchor: ARBodyAnchor) {
        // Verlet integration for physics
        for i in 0..<clothVertices.count {
            // Apply gravity
            let gravity = simd_float3(0, -9.8, 0) * deltaTime * deltaTime

            // Predict position
            let predicted = clothVertices[i] + gravity

            // Apply constraints
            clothVertices[i] = applyConstraints(predicted, index: i, bodyAnchor: bodyAnchor)
        }
    }

    private func applyConstraints(
        _ position: simd_float3,
        index: Int,
        bodyAnchor: ARBodyAnchor
    ) -> simd_float3 {
        var adjusted = position

        // Collision with body
        adjusted = resolveBodyCollision(adjusted, bodyAnchor: bodyAnchor)

        // Spring constraints
        for (v1, v2, restDistance) in clothConstraints where v1 == index || v2 == index {
            let other = v1 == index ? v2 : v1
            let delta = clothVertices[other] - adjusted
            let distance = simd_length(delta)
            let correction = (distance - restDistance) / distance * 0.5
            adjusted += delta * correction
        }

        return adjusted
    }

    private func resolveBodyCollision(
        _ position: simd_float3,
        bodyAnchor: ARBodyAnchor
    ) -> simd_float3 {
        // Check collision with body joints
        // Push vertex outside if inside body

        let skeleton = bodyAnchor.skeleton
        for joint in getAllJoints() {
            guard let jointTransform = skeleton.jointModelTransforms[joint] else { continue }
            let jointPosition = simd_make_float3(jointTransform.columns.3)
            let distance = simd_distance(position, jointPosition)

            // If too close to joint, push away
            if distance < 0.1 { // 10cm threshold
                let direction = simd_normalize(position - jointPosition)
                return jointPosition + direction * 0.1
            }
        }

        return position
    }
}
```

## 6. Rendering Pipeline

### 6.1 RealityKit Scene Setup

```swift
class VirtualTryOnScene {
    private var arView: ARView!
    private var clothingAnchor: AnchorEntity!

    func setupScene() -> ARView {
        // Create AR view
        arView = ARView(frame: .zero)

        // Create anchor for clothing
        clothingAnchor = AnchorEntity(.body)
        arView.scene.addAnchor(clothingAnchor)

        // Configure lighting
        setupLighting()

        // Configure rendering quality
        arView.renderOptions = [.disableAREnvironmentLighting]

        return arView
    }

    private func setupLighting() {
        // Ambient light
        let ambientLight = DirectionalLight()
        ambientLight.light.color = .white
        ambientLight.light.intensity = 1000
        clothingAnchor.addChild(ambientLight)

        // Key light (front)
        let keyLight = DirectionalLight()
        keyLight.light.intensity = 3000
        keyLight.position = [0, 1, 1]
        keyLight.look(at: [0, 0, 0], from: keyLight.position, relativeTo: nil)
        clothingAnchor.addChild(keyLight)

        // Fill light (side)
        let fillLight = DirectionalLight()
        fillLight.light.intensity = 1500
        fillLight.position = [1, 0.5, 0.5]
        clothingAnchor.addChild(fillLight)
    }

    func addClothing(_ model: ModelEntity) {
        clothingAnchor.addChild(model)
    }

    func removeClothing(_ model: ModelEntity) {
        model.removeFromParent()
    }
}
```

### 6.2 Rendering Loop

```swift
class RenderingCoordinator {
    private var bodyTracker: ARBodyTrackingManager
    private var clothingModels: [ModelEntity] = []
    private var updateTimer: Timer?

    func startRendering() {
        // Start body tracking
        try? bodyTracker.startTracking()

        // Start update loop (60fps)
        updateTimer = Timer.scheduledTimer(
            withTimeInterval: 1.0 / 60.0,
            repeats: true
        ) { [weak self] _ in
            self?.updateFrame()
        }
    }

    private func updateFrame() {
        guard let bodyAnchor = bodyTracker.getCurrentBodyAnchor() else {
            return
        }

        // Update each clothing piece
        for model in clothingModels {
            updateClothingPosition(model, bodyAnchor: bodyAnchor)
        }
    }

    private func updateClothingPosition(_ model: ModelEntity, bodyAnchor: ARBodyAnchor) {
        // Update position based on body movement
        let attachmentSystem = ClothingAttachmentSystem()
        // ... update logic
    }

    func stopRendering() {
        updateTimer?.invalidate()
        bodyTracker.stopTracking()
    }
}
```

### 6.3 Performance Optimization

**Level of Detail (LOD)**:
```swift
class LODManager {
    func selectLOD(for model: ModelEntity, cameraDistance: Float) -> ModelEntity {
        // Select appropriate LOD based on distance

        if cameraDistance < 1.5 { // Close up
            return model // Full detail
        } else if cameraDistance < 3.0 { // Medium distance
            return loadLOD1(model) // Medium detail
        } else { // Far away
            return loadLOD2(model) // Low detail
        }
    }

    private func loadLOD1(_ model: ModelEntity) -> ModelEntity {
        // Load reduced polygon version
        // 50% of original vertices
        return model
    }

    private func loadLOD2(_ model: ModelEntity) -> ModelEntity {
        // Load lowest detail version
        // 25% of original vertices
        return model
    }
}
```

**Occlusion Culling**:
```swift
// Only render clothing visible to camera
model.components[ModelComponent.self]?.mesh.contents.instances[0].isEnabled = isVisible
```

**Texture Compression**:
- Use ASTC texture compression for iOS
- Mipmap generation for textures
- Texture atlasing for multiple materials

## 7. Performance Targets

| Metric | Target | Critical Threshold |
|--------|--------|-------------------|
| Frame Rate | 60 fps | 50 fps (minimum) |
| Model Load Time | < 2 seconds | < 5 seconds |
| Body Tracking Latency | < 33ms (2 frames) | < 50ms |
| Memory (3D Models) | < 200MB | < 500MB |
| GPU Utilization | < 70% | < 90% |

## 8. Error Handling & Fallbacks

### 8.1 Body Tracking Failures

```swift
enum BodyTrackingError: Error {
    case notSupported
    case poorLighting
    case userTooFar
    case userTooClose
    case occluded

    var userMessage: String {
        switch self {
        case .notSupported:
            return "Body tracking is not supported on this device."
        case .poorLighting:
            return "Lighting is too low. Please move to a brighter area."
        case .userTooFar:
            return "Please move closer to the device (1-3 meters)."
        case .userTooClose:
            return "Please step back slightly."
        case .occluded:
            return "Full body must be visible. Please adjust your position."
        }
    }
}
```

### 8.2 Fallback Modes

**Static Photo Mode**:
- If body tracking fails, show 2D photo overlay
- User can adjust position/size manually

**Simplified Rendering**:
- Disable physics simulation
- Reduce texture quality
- Lower frame rate to 30fps

## 9. Testing & Validation

### 9.1 Tracking Accuracy Tests

```swift
class TrackingAccuracyTests: XCTestCase {
    func testBodyMeasurementAccuracy() {
        // Compare extracted measurements to ground truth
        // Tolerance: ±5cm
    }

    func testJointPositionStability() {
        // Verify joints don't jitter excessively
        // Threshold: < 2cm movement per frame for stationary user
    }
}
```

### 9.2 Rendering Performance Tests

```swift
class RenderingPerformanceTests: XCTestCase {
    func testFrameRate() {
        // Measure average FPS over 60 seconds
        // Assert: >= 55 fps
    }

    func testModelLoadTime() {
        // Measure time to load various models
        // Assert: < 2 seconds for typical model
    }
}
```

## 10. Next Steps

- ✅ AR/3D rendering specification complete
- ⬜ Prototype body tracking in AR
- ⬜ Create basic cloth templates
- ⬜ Implement material system
- ⬜ Test on Vision Pro hardware
- ⬜ Optimize performance

---

**Document Status**: Draft - Ready for Review
**Next Document**: Machine Learning Model Specifications
