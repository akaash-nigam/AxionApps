# 3D Rendering & Spatial Layout Design Document

## Document Information
- **Version**: 1.0
- **Last Updated**: 2025-11-24
- **Status**: Draft
- **Owner**: Engineering Team

## 1. Overview

This document specifies the 3D rendering architecture, spatial layout algorithms, and RealityKit implementation for Spatial Code Reviewer. It defines how code is visualized in 3D space and how users interact with spatial elements.

## 2. RealityKit Architecture

### 2.1 Entity Hierarchy

```
RootEntity (Scene anchor)
├── CodeSpaceEntity (Container for all code windows)
│   ├── CodeWindowEntity (Individual code file)
│   │   ├── BackgroundEntity (Panel background)
│   │   ├── TextContentEntity (Code text)
│   │   └── BorderEntity (Window border)
│   └── CodeWindowEntity (...)
├── DependencyGraphEntity (Container for dependencies)
│   ├── DependencyLineEntity (Connection between files)
│   └── DependencyLineEntity (...)
├── IssueMarkersEntity (Container for bug indicators)
│   ├── IssueMarkerEntity (Individual issue marker)
│   └── IssueMarkerEntity (...)
├── AvatarContainerEntity (Container for collaborators)
│   ├── ParticipantAvatarEntity (Individual avatar)
│   └── ParticipantAvatarEntity (...)
└── UIOverlayEntity (Spatial UI elements)
    ├── TimelineEntity (Git history scrubber)
    └── ControlPanelEntity (Settings, controls)
```

### 2.2 Coordinate System

```
User is at origin (0, 0, 0)
+Y: Up
+X: Right
+Z: Forward (toward user)
-Z: Away from user

Default code space:
- Center: (0, 1.5, -2) // Eye level, 2m away
- Radius: 1.5m hemisphere
```

### 2.3 Entity Component System

```swift
// Base component for all spatial code elements
struct SpatialCodeComponent: Component {
    var targetPosition: SIMD3<Float>
    var targetScale: SIMD3<Float>
    var animationDuration: TimeInterval
    var isInteractive: Bool
}

// Component for code windows
struct CodeWindowComponent: Component {
    var filePath: String
    var language: String
    var lineRange: Range<Int>
    var scrollOffset: Float
    var opacity: Float
    var isFocused: Bool
}

// Component for dependency lines
struct DependencyLineComponent: Component {
    var sourceEntityID: Entity.ID
    var targetEntityID: Entity.ID
    var dependencyType: DependencyType
    var strength: Float
    var isHighlighted: Bool
}

// Component for avatars
struct AvatarComponent: Component {
    var participantID: UUID
    var gazeDirection: SIMD3<Float>
    var isActive: Bool
}
```

## 3. Spatial Layouts

### 3.1 Hemisphere Layout (Default)

**Purpose**: Display multiple files in a natural, browsable arrangement.

**Algorithm**:
```swift
class HemisphereLayout: LayoutAlgorithm {
    let radius: Float = 1.5 // meters
    let centerHeight: Float = 1.5 // eye level
    let centerDistance: Float = 2.0 // from user

    func calculatePositions(for files: [CodeFile]) -> [Transform] {
        let count = files.count
        var transforms: [Transform] = []

        // Distribute files across hemisphere
        let goldenRatio: Float = (1.0 + sqrt(5.0)) / 2.0
        let goldenAngle = 2.0 * .pi * (1.0 - 1.0 / goldenRatio)

        for i in 0..<count {
            let t = Float(i) / Float(max(count - 1, 1))

            // Spherical coordinates using golden ratio
            let inclination = acos(1.0 - t)
            let azimuth = goldenAngle * Float(i)

            // Convert to Cartesian (hemisphere only, y >= 0)
            let x = radius * sin(inclination) * cos(azimuth)
            let y = radius * cos(inclination)
            let z = -radius * sin(inclination) * sin(azimuth) - centerDistance

            // Adjust y to be around eye level
            let position = SIMD3<Float>(x, y + centerHeight, z)

            // Orientation: face toward user
            let lookAt = SIMD3<Float>(0, centerHeight, 0)
            let direction = normalize(lookAt - position)
            let rotation = rotationToFace(direction: direction)

            transforms.append(Transform(translation: position, rotation: rotation))
        }

        return transforms
    }

    private func rotationToFace(direction: SIMD3<Float>) -> simd_quatf {
        let up = SIMD3<Float>(0, 1, 0)
        let right = normalize(cross(up, direction))
        let correctedUp = cross(direction, right)

        let rotationMatrix = simd_float3x3(right, correctedUp, -direction)
        return simd_quatf(rotationMatrix)
    }
}
```

**Visual**: Files arranged in dome shape around user, all facing inward.

### 3.2 Focus Mode Layout

**Purpose**: Single file maximized, others dimmed and minimized.

**Algorithm**:
```swift
class FocusLayout: LayoutAlgorithm {
    let focusPosition = SIMD3<Float>(0, 1.5, -1.5)
    let focusScale = SIMD3<Float>(1.2, 1.2, 1.0)
    let contextScale = SIMD3<Float>(0.3, 0.3, 1.0)
    let contextRadius: Float = 1.0

    func calculatePositions(for files: [CodeFile], focused: CodeFile) -> [Transform] {
        var transforms: [Transform] = []

        for file in files {
            if file.id == focused.id {
                // Main focused window
                transforms.append(Transform(
                    scale: focusScale,
                    translation: focusPosition
                ))
            } else {
                // Context windows arranged in arc below
                let index = files.firstIndex(where: { $0.id == file.id })!
                let angle = Float(index) * 0.3 - Float(files.count) * 0.15

                let x = contextRadius * sin(angle)
                let y = 0.8
                let z = -1.8 - contextRadius * cos(angle)

                transforms.append(Transform(
                    scale: contextScale,
                    translation: SIMD3<Float>(x, y, z)
                ))
            }
        }

        return transforms
    }
}
```

**Visual**: Main file centered and large, others small and arranged in arc below.

### 3.3 Comparison Mode Layout

**Purpose**: Two files side-by-side for diff comparison.

**Algorithm**:
```swift
class ComparisonLayout: LayoutAlgorithm {
    let separation: Float = 0.8
    let position = SIMD3<Float>(0, 1.5, -1.5)
    let scale = SIMD3<Float>(0.9, 1.0, 1.0)

    func calculatePositions(for files: [CodeFile]) -> [Transform] {
        guard files.count == 2 else { return [] }

        let leftPosition = position + SIMD3<Float>(-separation / 2, 0, 0)
        let rightPosition = position + SIMD3<Float>(separation / 2, 0, 0)

        return [
            Transform(scale: scale, translation: leftPosition),
            Transform(scale: scale, translation: rightPosition)
        ]
    }
}
```

**Visual**: Two files side-by-side, equal size, centered.

### 3.4 Architecture Mode Layout

**Purpose**: Top-down view of dependency graph.

**Algorithm**:
```swift
class ArchitectureLayout: LayoutAlgorithm {
    let viewHeight: Float = 3.0
    let viewDistance: Float = 2.5
    let nodeSpacing: Float = 0.5

    func calculatePositions(
        for files: [CodeFile],
        graph: DependencyGraph
    ) -> [Transform] {
        // Force-directed graph layout
        let positions = forceDirectedLayout(graph: graph, iterations: 50)

        // Position graph at comfortable viewing angle
        let basePosition = SIMD3<Float>(0, viewHeight, -viewDistance)

        return positions.map { pos in
            let worldPos = basePosition + SIMD3<Float>(pos.x * nodeSpacing, 0, pos.y * nodeSpacing)
            // Tilt windows to face downward at angle
            let tilt = simd_quatf(angle: .pi / 6, axis: SIMD3<Float>(1, 0, 0))
            return Transform(translation: worldPos, rotation: tilt)
        }
    }

    private func forceDirectedLayout(
        graph: DependencyGraph,
        iterations: Int
    ) -> [SIMD2<Float>] {
        // Initialize random positions
        var positions = (0..<graph.nodes.count).map { _ in
            SIMD2<Float>(
                Float.random(in: -2...2),
                Float.random(in: -2...2)
            )
        }

        let k = sqrt(1.0 / Float(graph.nodes.count)) // Optimal distance
        let c = 0.1 // Cooling factor

        for iteration in 0..<iterations {
            var forces = [SIMD2<Float>](repeating: .zero, count: graph.nodes.count)

            // Repulsive forces between all nodes
            for i in 0..<positions.count {
                for j in 0..<positions.count where i != j {
                    let delta = positions[i] - positions[j]
                    let distance = length(delta)
                    if distance > 0 {
                        let repulsion = (k * k) / distance
                        forces[i] += normalize(delta) * repulsion
                    }
                }
            }

            // Attractive forces along edges
            for edge in graph.edges {
                let delta = positions[edge.target] - positions[edge.source]
                let distance = length(delta)
                if distance > 0 {
                    let attraction = (distance * distance) / k
                    let force = normalize(delta) * attraction
                    forces[edge.source] += force
                    forces[edge.target] -= force
                }
            }

            // Apply forces with cooling
            let temp = c * Float(iterations - iteration) / Float(iterations)
            for i in 0..<positions.count {
                let displacement = forces[i] * temp
                positions[i] += displacement
            }
        }

        return positions
    }
}
```

**Visual**: Graph view from above, nodes spread out with connections visible.

## 4. Entity Implementations

### 4.1 CodeWindowEntity

```swift
class CodeWindowEntity: Entity, HasModel, HasCollision {
    var codeWindow: CodeWindowComponent

    init(file: CodeFile, position: SIMD3<Float>) {
        self.codeWindow = CodeWindowComponent(
            filePath: file.path,
            language: file.language,
            lineRange: 0..<min(file.lineCount, 100),
            scrollOffset: 0,
            opacity: 0.95,
            isFocused: false
        )

        super.init()

        // Create visual components
        setupBackground()
        setupTextContent(file: file)
        setupBorder()
        setupCollision()

        self.position = position
        self.components[CodeWindowComponent.self] = codeWindow
    }

    required init() {
        fatalError("Use init(file:position:)")
    }

    private func setupBackground() {
        let mesh = MeshResource.generatePlane(width: 0.6, depth: 0.8)
        var material = UnlitMaterial()
        material.color = .init(tint: UIColor(white: 0.1, alpha: 0.95))
        material.blending = .transparent(opacity: .init(floatLiteral: 0.95))

        let background = ModelEntity(mesh: mesh, materials: [material])
        addChild(background)
    }

    private func setupTextContent(file: CodeFile) {
        // Text rendering using TextKit/Core Text
        let textEntity = Entity()

        // Create text mesh for code content
        let textMesh = generateTextMesh(for: file)
        let textModel = ModelEntity(mesh: textMesh)

        textEntity.addChild(textModel)
        textEntity.position.z = 0.001 // Slight offset from background

        addChild(textEntity)
    }

    private func setupBorder() {
        // Thin border around window
        let borderMesh = MeshResource.generateBox(
            width: 0.605, height: 0.805, depth: 0.002
        )
        var borderMaterial = UnlitMaterial()
        borderMaterial.color = .init(tint: .systemBlue.withAlphaComponent(0.3))

        let border = ModelEntity(mesh: borderMesh, materials: [borderMaterial])
        border.position.z = -0.001

        addChild(border)
    }

    private func setupCollision() {
        // Enable collision for tap/pinch gestures
        let shape = ShapeResource.generateBox(width: 0.6, height: 0.8, depth: 0.01)
        collision = CollisionComponent(shapes: [shape])

        // Enable input handling
        components[InputTargetComponent.self] = InputTargetComponent()
    }

    private func generateTextMesh(for file: CodeFile) -> MeshResource {
        // Convert code text to 3D mesh using TextKit
        // This is a simplified version - actual implementation would be more complex

        let attributedString = SyntaxHighlighter.highlight(
            code: file.content,
            language: file.language
        )

        // Use TextKit to layout text
        // Convert to mesh geometry
        // Return mesh

        // Placeholder
        return MeshResource.generatePlane(width: 0.55, depth: 0.75)
    }

    func updateScroll(offset: Float) {
        codeWindow.scrollOffset = offset
        // Re-render visible text
    }

    func setFocus(_ focused: Bool) {
        codeWindow.isFocused = focused

        // Animate border highlight
        if let border = children.last as? ModelEntity {
            var material = border.model?.materials.first as? UnlitMaterial
            material?.color = .init(tint: focused ? .systemBlue : .gray.withAlphaComponent(0.3))
            border.model?.materials = [material!]
        }
    }
}
```

### 4.2 DependencyLineEntity

```swift
class DependencyLineEntity: Entity, HasModel {
    var dependencyLine: DependencyLineComponent

    init(from source: Entity, to target: Entity, type: DependencyType) {
        self.dependencyLine = DependencyLineComponent(
            sourceEntityID: source.id,
            targetEntityID: target.id,
            dependencyType: type,
            strength: 1.0,
            isHighlighted: false
        )

        super.init()

        components[DependencyLineComponent.self] = dependencyLine
        updateLine(from: source.position, to: target.position)
    }

    required init() {
        fatalError("Use init(from:to:type:)")
    }

    func updateLine(from start: SIMD3<Float>, to end: SIMD3<Float>) {
        // Generate curved line using Bezier curve
        let controlPoint = calculateControlPoint(from: start, to: end)
        let curve = generateBezierCurve(start: start, control: controlPoint, end: end)

        // Create tube mesh along curve
        let mesh = generateTubeMesh(alongPath: curve, radius: 0.003)

        // Material based on dependency type
        var material = UnlitMaterial()
        material.color = .init(tint: colorForDependencyType(dependencyLine.dependencyType))
        material.blending = .transparent(opacity: .init(floatLiteral: 0.7))

        let model = ModelEntity(mesh: mesh, materials: [material])
        addChild(model)
    }

    private func calculateControlPoint(
        from start: SIMD3<Float>,
        to end: SIMD3<Float>
    ) -> SIMD3<Float> {
        let midpoint = (start + end) / 2
        let distance = length(end - start)

        // Control point offset perpendicular to line
        let offset = SIMD3<Float>(0, distance * 0.2, 0)
        return midpoint + offset
    }

    private func generateBezierCurve(
        start: SIMD3<Float>,
        control: SIMD3<Float>,
        end: SIMD3<Float>,
        segments: Int = 20
    ) -> [SIMD3<Float>] {
        var points: [SIMD3<Float>] = []

        for i in 0...segments {
            let t = Float(i) / Float(segments)
            let point = quadraticBezier(t: t, p0: start, p1: control, p2: end)
            points.append(point)
        }

        return points
    }

    private func quadraticBezier(
        t: Float,
        p0: SIMD3<Float>,
        p1: SIMD3<Float>,
        p2: SIMD3<Float>
    ) -> SIMD3<Float> {
        let u = 1 - t
        return u * u * p0 + 2 * u * t * p1 + t * t * p2
    }

    private func generateTubeMesh(
        alongPath path: [SIMD3<Float>],
        radius: Float
    ) -> MeshResource {
        // Generate cylindrical tube following the path
        // This would use MeshDescriptor to create custom geometry

        // Simplified: use boxes as segments
        // Real implementation would create smooth tube

        return MeshResource.generateBox(size: 0.001)
    }

    private func colorForDependencyType(_ type: DependencyType) -> UIColor {
        switch type {
        case .import: return .systemBlue
        case .inheritance: return .systemGreen
        case .call: return .systemOrange
        case .reference: return .systemGray
        }
    }

    func highlight(_ highlighted: Bool) {
        dependencyLine.isHighlighted = highlighted

        // Animate glow effect
        guard let model = children.first as? ModelEntity else { return }
        var material = model.model?.materials.first as? UnlitMaterial
        material?.blending = .transparent(
            opacity: .init(floatLiteral: highlighted ? 1.0 : 0.7)
        )
        model.model?.materials = [material!]
    }
}
```

### 4.3 IssueMarkerEntity

```swift
class IssueMarkerEntity: Entity, HasModel, HasCollision {
    let issue: Issue

    init(issue: Issue, nearFile: CodeWindowEntity) {
        self.issue = issue

        super.init()

        // Position near associated file
        self.position = nearFile.position + SIMD3<Float>(0.35, 0, 0.1)

        // Create visual marker
        setupMarker()
        setupCollision()
    }

    required init() {
        fatalError("Use init(issue:nearFile:)")
    }

    private func setupMarker() {
        // Icon sphere
        let mesh = MeshResource.generateSphere(radius: 0.03)
        var material = UnlitMaterial()
        material.color = .init(tint: colorForSeverity(issue.severity))

        let sphere = ModelEntity(mesh: mesh, materials: [material])
        addChild(sphere)

        // Badge with issue number
        let badgeMesh = MeshResource.generatePlane(width: 0.04, depth: 0.04)
        var badgeMaterial = UnlitMaterial()
        badgeMaterial.color = .init(tint: .white)

        let badge = ModelEntity(mesh: badgeMesh, materials: [badgeMaterial])
        badge.position.z = 0.031

        addChild(badge)

        // Add subtle pulse animation
        addPulseAnimation()
    }

    private func setupCollision() {
        let shape = ShapeResource.generateSphere(radius: 0.03)
        collision = CollisionComponent(shapes: [shape])
        components[InputTargetComponent.self] = InputTargetComponent()
    }

    private func colorForSeverity(_ severity: Issue.Severity) -> UIColor {
        switch severity {
        case .critical: return .systemRed
        case .major: return .systemOrange
        case .minor: return .systemYellow
        case .info: return .systemBlue
        }
    }

    private func addPulseAnimation() {
        // Animate scale pulsing
        let duration = 2.0
        let scaleAnimation = FromToByAnimation(
            from: Transform(scale: SIMD3<Float>(1, 1, 1)),
            to: Transform(scale: SIMD3<Float>(1.1, 1.1, 1.1)),
            duration: duration,
            timing: .easeInOut,
            isAdditive: false,
            bindTarget: .transform,
            repeatMode: .repeat
        )

        playAnimation(scaleAnimation)
    }

    func showDetails() -> IssueCardView {
        // Return SwiftUI view with issue details
        return IssueCardView(issue: issue)
    }
}
```

### 4.4 ParticipantAvatarEntity

```swift
class ParticipantAvatarEntity: Entity, HasModel {
    var avatar: AvatarComponent

    init(participant: Participant) {
        self.avatar = AvatarComponent(
            participantID: participant.id,
            gazeDirection: SIMD3<Float>(0, 0, -1),
            isActive: true
        )

        super.init()

        components[AvatarComponent.self] = avatar
        setupAvatar(participant: participant)
        setupGazeIndicator()
    }

    required init() {
        fatalError("Use init(participant:)")
    }

    private func setupAvatar(participant: Participant) {
        // Simple avatar representation
        // In production, use FaceTime's PersonaEntity or custom avatar

        // Head sphere
        let headMesh = MeshResource.generateSphere(radius: 0.15)
        var headMaterial = SimpleMaterial()
        headMaterial.color = .init(tint: .systemBlue)

        let head = ModelEntity(mesh: headMesh, materials: [headMaterial])
        addChild(head)

        // Name label
        // (Would use TextKit to render name)

        // Load avatar image if available
        if let avatarURL = participant.avatarURL {
            loadAvatarTexture(from: avatarURL)
        }
    }

    private func setupGazeIndicator() {
        // Line showing where participant is looking
        let lineMesh = MeshResource.generateBox(
            width: 0.005, height: 0.005, depth: 0.5
        )
        var lineMaterial = UnlitMaterial()
        lineMaterial.color = .init(tint: .systemBlue.withAlphaComponent(0.5))

        let gazeLine = ModelEntity(mesh: lineMesh, materials: [lineMaterial])
        gazeLine.position.z = -0.25 // Extend forward

        addChild(gazeLine)
    }

    func updatePosition(_ transform: Transform) {
        self.transform = transform
    }

    func updateGaze(direction: SIMD3<Float>) {
        avatar.gazeDirection = direction

        // Rotate gaze indicator
        if let gazeLine = children.last as? ModelEntity {
            let rotation = rotationToDirection(direction)
            gazeLine.orientation = rotation
        }
    }

    private func rotationToDirection(_ direction: SIMD3<Float>) -> simd_quatf {
        let normalized = normalize(direction)
        let forward = SIMD3<Float>(0, 0, -1)
        let axis = cross(forward, normalized)
        let angle = acos(dot(forward, normalized))

        return simd_quatf(angle: angle, axis: axis)
    }

    private func loadAvatarTexture(from url: URL) {
        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                if let image = UIImage(data: data) {
                    applyTexture(image)
                }
            } catch {
                print("Failed to load avatar texture: \(error)")
            }
        }
    }

    private func applyTexture(_ image: UIImage) {
        // Apply texture to head sphere
        guard let head = children.first as? ModelEntity else { return }

        do {
            let texture = try TextureResource.generate(
                from: image.cgImage!,
                options: .init(semantic: .color)
            )
            var material = SimpleMaterial()
            material.color = .init(texture: .init(texture))

            head.model?.materials = [material]
        } catch {
            print("Failed to apply texture: \(error)")
        }
    }
}
```

## 5. Gesture Handling

### 5.1 Gesture Recognizers

```swift
class SpatialGestureHandler {
    private let arView: ARView
    private let spatialManager: SpatialManager

    init(arView: ARView, spatialManager: SpatialManager) {
        self.arView = arView
        self.spatialManager = spatialManager

        setupGestures()
    }

    private func setupGestures() {
        // Tap gesture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        arView.addGestureRecognizer(tapGesture)

        // Pinch gesture for scaling
        let pinchGesture = UIPinchGestureRecognizer(
            target: self,
            action: #selector(handlePinch)
        )
        arView.addGestureRecognizer(pinchGesture)

        // Pan gesture for moving
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        arView.addGestureRecognizer(panGesture)
    }

    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: arView)

        if let entity = arView.entity(at: location) {
            handleEntityTap(entity)
        }
    }

    @objc private func handlePinch(_ gesture: UIPinchGestureRecognizer) {
        guard let entity = getSelectedEntity() else { return }

        let scale = Float(gesture.scale)
        entity.scale *= SIMD3<Float>(repeating: scale)

        gesture.scale = 1.0 // Reset for next delta
    }

    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        guard let entity = getSelectedEntity() else { return }

        let translation = gesture.translation(in: arView)

        // Convert 2D translation to 3D movement
        let deltaX = Float(translation.x) * 0.001
        let deltaY = -Float(translation.y) * 0.001

        entity.position += SIMD3<Float>(deltaX, deltaY, 0)

        gesture.setTranslation(.zero, in: arView)
    }

    private func handleEntityTap(_ entity: Entity) {
        if let codeWindow = entity as? CodeWindowEntity {
            spatialManager.focusOnWindow(codeWindow)
        } else if let issueMarker = entity as? IssueMarkerEntity {
            spatialManager.showIssueDetails(issueMarker.issue)
        } else if entity.components[DependencyLineComponent.self] != nil {
            spatialManager.highlightDependencyChain(entity)
        }
    }

    private func getSelectedEntity() -> Entity? {
        // Return currently selected entity
        return spatialManager.selectedEntity
    }
}
```

### 5.2 Eye Tracking Integration

```swift
class EyeTrackingHandler {
    private let arView: ARView

    func startTracking() {
        // Monitor eye tracking events
        arView.scene.subscribe(to: SceneEvents.Update.self) { [weak self] event in
            self?.updateEyeTracking(event)
        }
    }

    private func updateEyeTracking(_ event: SceneEvents.Update) {
        // Get eye tracking data from ARKit
        guard let eyeTracking = arView.session.currentFrame?.eyeTracking else {
            return
        }

        // Cast ray from eye gaze
        let origin = eyeTracking.origin
        let direction = eyeTracking.direction

        // Find entity at gaze point
        if let entity = castRay(from: origin, direction: direction) {
            handleGazeHover(entity)
        }
    }

    private func castRay(
        from origin: SIMD3<Float>,
        direction: SIMD3<Float>
    ) -> Entity? {
        let raycastResult = arView.scene.raycast(
            origin: origin,
            direction: direction
        )

        return raycastResult.first?.entity
    }

    private func handleGazeHover(_ entity: Entity) {
        // Provide subtle feedback when looking at interactive elements
        if entity.components[InputTargetComponent.self] != nil {
            // Highlight or show tooltip
        }
    }
}
```

## 6. Animation System

### 6.1 Layout Transitions

```swift
class LayoutAnimator {
    func animateLayoutTransition(
        from currentLayout: LayoutType,
        to newLayout: LayoutType,
        entities: [CodeWindowEntity],
        duration: TimeInterval = 0.5
    ) {
        let oldTransforms = entities.map { $0.transform }
        let newTransforms = calculateTransforms(for: newLayout, entities: entities)

        for (index, entity) in entities.enumerated() {
            let animation = FromToByAnimation(
                from: oldTransforms[index],
                to: newTransforms[index],
                duration: duration,
                timing: .easeInOut,
                bindTarget: .transform
            )

            entity.playAnimation(animation)
        }
    }

    private func calculateTransforms(
        for layout: LayoutType,
        entities: [CodeWindowEntity]
    ) -> [Transform] {
        switch layout {
        case .hemisphere:
            return HemisphereLayout().calculatePositions(for: entities.map { $0.codeWindow })
        case .focus:
            return FocusLayout().calculatePositions(for: entities.map { $0.codeWindow })
        case .comparison:
            return ComparisonLayout().calculatePositions(for: entities.map { $0.codeWindow })
        case .architecture:
            return ArchitectureLayout().calculatePositions(for: entities.map { $0.codeWindow })
        }
    }
}
```

### 6.2 Git History Time-Lapse Animation

```swift
class GitHistoryAnimator {
    func animateCommitTransition(
        from oldCommit: Commit,
        to newCommit: Commit,
        duration: TimeInterval
    ) {
        let diff = calculateDiff(from: oldCommit, to: newCommit)

        for change in diff.changes {
            animateFileChange(change, duration: duration)
        }
    }

    private func animateFileChange(_ change: FileChange, duration: TimeInterval) {
        switch change.type {
        case .added:
            animateAddition(file: change.file, duration: duration)
        case .modified:
            animateModification(file: change.file, lines: change.lines, duration: duration)
        case .deleted:
            animateDeletion(file: change.file, duration: duration)
        }
    }

    private func animateAddition(file: CodeFile, duration: TimeInterval) {
        // Fade in with green tint
        guard let entity = findEntity(for: file) else { return }

        entity.opacity = 0
        let fadeIn = FromToByAnimation(
            from: Transform(scale: .init(repeating: 0.8)),
            to: Transform(scale: .init(repeating: 1.0)),
            duration: duration,
            timing: .easeOut,
            bindTarget: .transform
        )

        entity.playAnimation(fadeIn)

        // Animate opacity separately
        animateOpacity(entity: entity, from: 0, to: 1, duration: duration)

        // Green glow effect
        applyColorTint(entity: entity, color: .systemGreen, duration: duration * 0.5)
    }

    private func animateModification(
        file: CodeFile,
        lines: [LineChange],
        duration: TimeInterval
    ) {
        guard let entity = findEntity(for: file) else { return }

        // Highlight changed lines
        for line in lines {
            let color: UIColor = line.type == .addition ? .systemGreen : .systemRed
            highlightLine(entity: entity, line: line.number, color: color, duration: duration)
        }
    }

    private func animateDeletion(file: CodeFile, duration: TimeInterval) {
        // Fade out with red tint
        guard let entity = findEntity(for: file) else { return }

        let fadeOut = FromToByAnimation(
            from: Transform(scale: .init(repeating: 1.0)),
            to: Transform(scale: .init(repeating: 0.8)),
            duration: duration,
            timing: .easeIn,
            bindTarget: .transform
        )

        entity.playAnimation(fadeOut)

        animateOpacity(entity: entity, from: 1, to: 0, duration: duration)

        applyColorTint(entity: entity, color: .systemRed, duration: duration * 0.5)

        // Remove entity after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            entity.removeFromParent()
        }
    }

    private func animateOpacity(
        entity: Entity,
        from: Float,
        to: Float,
        duration: TimeInterval
    ) {
        // Custom opacity animation
        // Would use custom animation system or shader
    }

    private func applyColorTint(
        entity: Entity,
        color: UIColor,
        duration: TimeInterval
    ) {
        // Apply temporary color tint that fades out
    }

    private func highlightLine(
        entity: CodeWindowEntity,
        line: Int,
        color: UIColor,
        duration: TimeInterval
    ) {
        // Highlight specific line in code window
    }

    private func findEntity(for file: CodeFile) -> CodeWindowEntity? {
        // Find entity by file path
        return nil // Implementation would search scene
    }
}
```

## 7. Performance Optimization

### 7.1 Culling System

```swift
class SpatialCullingSystem: System {
    static let query = EntityQuery(where: .has(CodeWindowComponent.self))

    init(scene: Scene) {}

    func update(context: SceneUpdateContext) {
        let cameraTransform = context.scene.camera?.transform ?? .identity

        for entity in context.entities(matching: Self.query, updatingSystemWhen: .rendering) {
            // Frustum culling
            let isVisible = isInFrustum(entity, camera: cameraTransform)

            // Distance culling
            let distance = length(entity.position - cameraTransform.translation)
            let isTooFar = distance > 5.0 // 5 meters

            // Enable/disable based on visibility
            entity.isEnabled = isVisible && !isTooFar

            // Adjust LOD based on distance
            if isVisible && !isTooFar {
                adjustLOD(entity, distance: distance)
            }
        }
    }

    private func isInFrustum(_ entity: Entity, camera: Transform) -> Bool {
        // Simplified frustum check
        // Real implementation would use proper frustum planes

        let toEntity = entity.position - camera.translation
        let forward = camera.rotation.act(SIMD3<Float>(0, 0, -1))

        let dot = dot(normalize(toEntity), forward)
        return dot > -0.5 // ~120 degree FOV
    }

    private func adjustLOD(_ entity: Entity, distance: Float) {
        guard var codeWindow = entity.components[CodeWindowComponent.self] else {
            return
        }

        // Reduce text detail at distance
        if distance > 3.0 {
            // Show only function signatures
            codeWindow.lineRange = 0..<20
        } else if distance > 2.0 {
            // Show partial code
            codeWindow.lineRange = 0..<50
        } else {
            // Show full code
            codeWindow.lineRange = 0..<codeWindow.lineRange.upperBound
        }

        entity.components[CodeWindowComponent.self] = codeWindow
    }
}
```

### 7.2 Entity Pooling

```swift
class EntityPool<T: Entity> {
    private var available: [T] = []
    private var inUse: Set<ObjectIdentifier> = []
    private let factory: () -> T

    init(initialSize: Int = 10, factory: @escaping () -> T) {
        self.factory = factory

        for _ in 0..<initialSize {
            available.append(factory())
        }
    }

    func acquire() -> T {
        let entity = available.popLast() ?? factory()
        inUse.insert(ObjectIdentifier(entity))
        entity.isEnabled = true
        return entity
    }

    func release(_ entity: T) {
        guard inUse.contains(ObjectIdentifier(entity)) else { return }

        inUse.remove(ObjectIdentifier(entity))
        entity.isEnabled = false
        entity.removeFromParent()
        available.append(entity)
    }

    func clear() {
        available.removeAll()
        inUse.removeAll()
    }
}

// Usage
class SpatialManager {
    private let codeWindowPool = EntityPool<CodeWindowEntity>(initialSize: 20) {
        CodeWindowEntity(
            file: CodeFile(path: "", content: ""),
            position: .zero
        )
    }

    func showFile(_ file: CodeFile) {
        let window = codeWindowPool.acquire()
        // Configure window with file data
        window.updateContent(file)
    }

    func hideFile(_ window: CodeWindowEntity) {
        codeWindowPool.release(window)
    }
}
```

## 8. Lighting & Materials

### 8.1 Lighting Setup

```swift
class SpatialLightingSetup {
    func setupLighting(in scene: Scene) {
        // Ambient light
        let ambient = AmbientLight()
        ambient.intensity = 300

        // Directional light (simulating room lighting)
        let directional = DirectionalLight()
        directional.light.intensity = 500
        directional.light.color = .white
        directional.orientation = simd_quatf(
            angle: -.pi / 4,
            axis: SIMD3<Float>(1, -1, 0)
        )

        // Point light for subtle rim lighting
        let rim = PointLight()
        rim.light.intensity = 200
        rim.light.attenuationRadius = 5.0
        rim.position = SIMD3<Float>(0, 2, 1)

        scene.addChild(ambient)
        scene.addChild(directional)
        scene.addChild(rim)
    }
}
```

### 8.2 Material Definitions

```swift
enum SpatialMaterials {
    static func codeWindowMaterial(theme: Theme) -> Material {
        var material = UnlitMaterial()

        switch theme {
        case .light:
            material.color = .init(tint: UIColor(white: 0.95, alpha: 0.95))
        case .dark:
            material.color = .init(tint: UIColor(white: 0.1, alpha: 0.95))
        }

        material.blending = .transparent(opacity: .init(floatLiteral: 0.95))
        return material
    }

    static func dependencyLineMaterial(type: DependencyType) -> Material {
        var material = UnlitMaterial()

        let color: UIColor = {
            switch type {
            case .import: return .systemBlue
            case .inheritance: return .systemGreen
            case .call: return .systemOrange
            case .reference: return .systemGray
            }
        }()

        material.color = .init(tint: color.withAlphaComponent(0.7))
        material.blending = .transparent(opacity: .init(floatLiteral: 0.7))

        return material
    }

    static func glowMaterial(color: UIColor) -> Material {
        var material = UnlitMaterial()
        material.color = .init(tint: color)
        material.blending = .additive
        return material
    }
}
```

## 9. Testing & Debugging

### 9.1 Debug Visualization

```swift
class SpatialDebugger {
    private let scene: Scene
    private var debugEntities: [Entity] = []

    init(scene: Scene) {
        self.scene = scene
    }

    func showCoordinateAxes(at position: SIMD3<Float>, size: Float = 0.5) {
        // X axis (red)
        let xAxis = createAxisLine(
            from: position,
            to: position + SIMD3<Float>(size, 0, 0),
            color: .red
        )

        // Y axis (green)
        let yAxis = createAxisLine(
            from: position,
            to: position + SIMD3<Float>(0, size, 0),
            color: .green
        )

        // Z axis (blue)
        let zAxis = createAxisLine(
            from: position,
            to: position + SIMD3<Float>(0, 0, size),
            color: .blue
        )

        debugEntities.append(contentsOf: [xAxis, yAxis, zAxis])
    }

    func showBoundingBoxes() {
        // Show collision boxes for all entities
    }

    func clearDebug() {
        debugEntities.forEach { $0.removeFromParent() }
        debugEntities.removeAll()
    }

    private func createAxisLine(
        from start: SIMD3<Float>,
        to end: SIMD3<Float>,
        color: UIColor
    ) -> Entity {
        let length = length(end - start)
        let mesh = MeshResource.generateBox(width: 0.01, height: 0.01, depth: length)

        var material = UnlitMaterial()
        material.color = .init(tint: color)

        let entity = ModelEntity(mesh: mesh, materials: [material])
        entity.position = (start + end) / 2

        // Orient along axis
        let direction = normalize(end - start)
        entity.look(at: end, from: start, relativeTo: nil)

        scene.addChild(entity)
        return entity
    }
}
```

## 10. References

- [System Architecture Document](./01-system-architecture.md)
- [UI/UX Design Specifications](./08-ui-ux-design.md)
- [Performance Optimization Strategy](./09-performance-optimization.md)
- Apple RealityKit Documentation
- Apple ARKit Documentation

## 11. Revision History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2025-11-24 | Engineering Team | Initial draft |
