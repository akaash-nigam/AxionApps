//
//  City3DModelView.swift
//  SmartCityCommandPlatform
//
//  3D volumetric city visualization
//

import SwiftUI
import RealityKit

struct City3DModelView: View {
    @State private var visibleLayers: Set<CityLayer> = [.buildings, .roads]
    @State private var cityEntity: Entity?

    var body: some View {
        RealityView { content in
            // Create root entity for city
            let root = Entity()
            root.name = "CityRoot"

            // Generate procedural city (simplified for now)
            let city = createProceduralCity()
            root.addChild(city)

            // Add lighting
            setupLighting(in: root)

            cityEntity = root
            content.add(root)
        } update: { content in
            // Update visible layers
            if let city = cityEntity {
                updateLayerVisibility(in: city, layers: visibleLayers)
            }
        }
        .toolbar {
            ToolbarItemGroup {
                Menu {
                    ForEach(CityLayer.allCases, id: \.self) { layer in
                        Toggle(isOn: Binding(
                            get: { visibleLayers.contains(layer) },
                            set: { isOn in
                                if isOn {
                                    visibleLayers.insert(layer)
                                } else {
                                    visibleLayers.remove(layer)
                                }
                            }
                        )) {
                            Label(layer.rawValue, systemImage: layer.icon)
                        }
                    }
                } label: {
                    Label("Layers", systemImage: "square.3.layers.3d")
                }
            }
        }
        .gesture(
            DragGesture()
                .onChanged { value in
                    rotateCity(by: value.translation)
                }
        )
    }

    // MARK: - City Generation

    private func createProceduralCity() -> Entity {
        let cityContainer = Entity()
        cityContainer.name = "City"

        // Create a simple grid of buildings
        let gridSize = 5
        let spacing: Float = 30.0

        for x in 0..<gridSize {
            for z in 0..<gridSize {
                let height = Float.random(in: 20...80)
                let building = createBuilding(height: height)

                building.position = SIMD3(
                    Float(x) * spacing - Float(gridSize) * spacing / 2,
                    0,
                    Float(z) * spacing - Float(gridSize) * spacing / 2
                )

                cityContainer.addChild(building)
            }
        }

        // Create ground plane
        let ground = createGroundPlane()
        cityContainer.addChild(ground)

        return cityContainer
    }

    private func createBuilding(height: Float) -> ModelEntity {
        let width: Float = 20
        let depth: Float = 20

        let mesh = MeshResource.generateBox(
            width: width,
            height: height,
            depth: depth
        )

        var material = PhysicallyBasedMaterial()
        material.baseColor = .init(tint: .init(
            red: 0.7,
            green: 0.7,
            blue: 0.8,
            alpha: 0.9
        ))
        material.roughness = .init(floatLiteral: 0.6)
        material.metallic = .init(floatLiteral: 0.1)

        let entity = ModelEntity(mesh: mesh, materials: [material])
        entity.position.y = height / 2 // Center on ground

        // Add interaction components
        entity.components.set(InputTargetComponent())
        entity.components.set(HoverEffectComponent())

        return entity
    }

    private func createGroundPlane() -> ModelEntity {
        let size: Float = 200

        let mesh = MeshResource.generatePlane(
            width: size,
            depth: size
        )

        var material = SimpleMaterial()
        material.color = .init(tint: .init(
            red: 0.2,
            green: 0.3,
            blue: 0.2,
            alpha: 1.0
        ))

        let entity = ModelEntity(mesh: mesh, materials: [material])
        entity.position.y = -0.5

        return entity
    }

    // MARK: - Lighting

    private func setupLighting(in parent: Entity) {
        // Directional light (sun)
        let sunlight = DirectionalLight()
        sunlight.light.intensity = 1000
        sunlight.light.color = .white
        sunlight.look(at: [0, 0, 0], from: [5, 10, 5], relativeTo: nil)

        // Ambient light
        let ambient = PointLight()
        ambient.light.intensity = 500
        ambient.light.color = .init(white: 0.9, alpha: 1.0)
        ambient.position = [0, 50, 0]

        parent.addChild(sunlight)
        parent.addChild(ambient)
    }

    // MARK: - Layer Management

    private func updateLayerVisibility(in entity: Entity, layers: Set<CityLayer>) {
        // Update visibility based on selected layers
        // This is a simplified version - would be expanded in full implementation
    }

    private func rotateCity(by translation: CGSize) {
        guard let city = cityEntity else { return }

        // Rotate city based on drag gesture
        let rotationY = Float(translation.width) * 0.01
        let rotationX = Float(translation.height) * 0.01

        var transform = city.transform
        transform.rotation *= simd_quatf(angle: rotationY, axis: [0, 1, 0])
        transform.rotation *= simd_quatf(angle: rotationX, axis: [1, 0, 0])

        city.transform = transform
    }
}

// MARK: - City Layers

enum CityLayer: String, CaseIterable {
    case buildings = "Buildings"
    case roads = "Roads"
    case infrastructure = "Infrastructure"
    case sensors = "Sensors"
    case traffic = "Traffic"
    case districts = "Districts"

    var icon: String {
        switch self {
        case .buildings: return "building.2"
        case .roads: return "road.lanes"
        case .infrastructure: return "network"
        case .sensors: return "sensor"
        case .traffic: return "car"
        case .districts: return "map"
        }
    }
}

#Preview {
    City3DModelView()
}
