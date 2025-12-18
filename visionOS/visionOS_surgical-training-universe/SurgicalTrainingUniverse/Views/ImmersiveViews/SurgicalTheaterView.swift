//
//  SurgicalTheaterView.swift
//  Surgical Training Universe
//
//  Main immersive surgical training environment
//

import SwiftUI
import RealityKit

/// Full immersive surgical theater for hands-on training
struct SurgicalTheaterView: View {

    @Environment(AppState.self) private var appState
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace

    @State private var procedureState = ProcedureState()
    @State private var realityKitService = RealityKitService()
    @State private var showingInstructions = true
    @State private var selectedInstrument: SurgicalInstrument?
    @State private var procedurePhase: ProcedurePhase = .preparation

    var body: some View {
        ZStack {
            // Main RealityView content
            RealityView { content in
                await setupSurgicalTheater(content: content)
            } update: { content in
                updateSurgicalTheater(content: content)
            }

            // UI Overlays
            VStack {
                // Top bar
                topBarOverlay

                Spacer()

                // Bottom instrument panel
                instrumentPanel
            }
            .padding()
        }
        .onAppear {
            appState.enterImmersiveMode()
            startProcedure()
        }
        .onDisappear {
            appState.exitImmersiveMode()
        }
        .sheet(isPresented: $showingInstructions) {
            procedureInstructionsView
        }
    }

    // MARK: - Top Bar Overlay

    private var topBarOverlay: some View {
        HStack {
            // Procedure info
            VStack(alignment: .leading, spacing: 4) {
                Text(procedureState.currentProcedure?.rawValue ?? "Surgical Procedure")
                    .font(.headline)
                    .foregroundStyle(.white)

                Text("Phase: \(procedurePhase.rawValue)")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.8))
            }
            .padding()
            .background(.ultraThinMaterial)
            .cornerRadius(12)

            Spacer()

            // Timer
            Text(formattedTime)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(12)

            Spacer()

            // AI Coach toggle
            Button {
                procedureState.showAICoach.toggle()
            } label: {
                Label(
                    procedureState.showAICoach ? "Hide AI Coach" : "Show AI Coach",
                    systemImage: "brain.head.profile"
                )
            }
            .buttonStyle(.bordered)

            // Menu button
            Button {
                showProcedureMenu()
            } label: {
                Label("Menu", systemImage: "line.3.horizontal")
            }
            .buttonStyle(.bordered)
        }
    }

    // MARK: - Instrument Panel

    private var instrumentPanel: some View {
        HStack(spacing: 16) {
            ForEach(availableInstruments, id: \.id) { instrument in
                instrumentButton(for: instrument)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(16)
    }

    private func instrumentButton(for instrument: SurgicalInstrument) -> some View {
        Button {
            selectInstrument(instrument)
        } label: {
            VStack(spacing: 8) {
                Image(systemName: instrument.type.iconName)
                    .font(.title2)

                Text(instrument.name)
                    .font(.caption)
            }
            .padding()
            .background(selectedInstrument?.id == instrument.id ? Color.blue : Color.clear)
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Procedure Instructions

    private var procedureInstructionsView: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("Procedure Instructions")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        instructionStep(
                            number: 1,
                            title: "Prepare Surgical Field",
                            description: "Position yourself comfortably. The patient anatomy is on the operating table ahead of you."
                        )

                        instructionStep(
                            number: 2,
                            title: "Select Instruments",
                            description: "Choose instruments from the panel below. Use gaze + pinch to interact."
                        )

                        instructionStep(
                            number: 3,
                            title: "Perform Procedure",
                            description: "Follow the AI coach guidance. Perform precise movements and maintain safety protocols."
                        )

                        instructionStep(
                            number: 4,
                            title: "Complete Procedure",
                            description: "Ensure all steps are completed correctly. Review your performance metrics."
                        )
                    }
                    .padding()
                }

                Button("Start Procedure") {
                    showingInstructions = false
                    procedurePhase = .incision
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            }
            .padding(40)
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func instructionStep(number: Int, title: String, description: String) -> some View {
        HStack(alignment: .top, spacing: 16) {
            Text("\(number)")
                .font(.title)
                .fontWeight(.bold)
                .foregroundStyle(.blue)
                .frame(width: 40, height: 40)
                .background(Color.blue.opacity(0.2))
                .cornerRadius(20)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)

                Text(description)
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }
        }
    }

    // MARK: - RealityKit Setup

    @MainActor
    private func setupSurgicalTheater(content: RealityViewContent) async {
        // Create root entity
        let root = Entity()

        // Operating room environment
        let orEnvironment = await createOREnvironment()
        root.addChild(orEnvironment)

        // Operating table
        let operatingTable = await createOperatingTable()
        operatingTable.position = [0, 0.9, 0.8] // In front of user
        root.addChild(operatingTable)

        // Surgical lights
        let surgicalLight = await createSurgicalLight()
        surgicalLight.position = [0, 2.5, 0.8] // Above table
        root.addChild(surgicalLight)

        // Patient anatomy
        if let anatomy = await createPatientAnatomy() {
            anatomy.position = [0, 0.95, 0.8] // On table
            root.addChild(anatomy)
        }

        // Instrument table
        let instrumentTable = await createInstrumentTable()
        instrumentTable.position = [0.6, 0.8, 0.6] // To the right
        root.addChild(instrumentTable)

        content.add(root)

        // Store reference for updates
        realityKitService.rootEntity = root
    }

    @MainActor
    private func updateSurgicalTheater(content: RealityViewContent) {
        // Update entities based on procedure state
        // This would be called when procedure state changes
    }

    // MARK: - Entity Creation Methods

    @MainActor
    private func createOREnvironment() async -> Entity {
        let environment = Entity()

        // Create room bounds
        let wallMaterial = SimpleMaterial(color: .init(white: 0.85, alpha: 1.0), isMetallic: false)
        let floorMaterial = SimpleMaterial(color: .init(white: 0.7, alpha: 1.0), isMetallic: false)

        // Floor
        let floor = ModelEntity(
            mesh: .generatePlane(width: 5, depth: 5),
            materials: [floorMaterial]
        )
        floor.position = [0, 0, 0]
        environment.addChild(floor)

        // Walls (simplified)
        let backWall = ModelEntity(
            mesh: .generatePlane(width: 5, height: 3),
            materials: [wallMaterial]
        )
        backWall.position = [0, 1.5, 2.5]
        environment.addChild(backWall)

        return environment
    }

    @MainActor
    private func createOperatingTable() async -> Entity {
        let table = Entity()

        // Table top
        let tableMaterial = SimpleMaterial(color: .init(white: 0.8, alpha: 1.0), isMetallic: true)
        let tableTop = ModelEntity(
            mesh: .generateBox(width: 0.6, height: 0.05, depth: 1.8),
            materials: [tableMaterial]
        )
        table.addChild(tableTop)

        // Legs (simplified)
        let legMaterial = SimpleMaterial(color: .gray, isMetallic: true)
        for x in [-0.25, 0.25] as [Float] {
            for z in [-0.8, 0.8] as [Float] {
                let leg = ModelEntity(
                    mesh: .generateCylinder(height: 0.9, radius: 0.03),
                    materials: [legMaterial]
                )
                leg.position = [x, -0.45, z]
                table.addChild(leg)
            }
        }

        return table
    }

    @MainActor
    private func createSurgicalLight() async -> Entity {
        let light = Entity()

        // Light fixture
        let fixture = ModelEntity(
            mesh: .generateCylinder(height: 0.1, radius: 0.2),
            materials: [SimpleMaterial(color: .white, isMetallic: true)]
        )
        light.addChild(fixture)

        // Point light
        var pointLight = PointLightComponent(color: .white, intensity: 800, attenuationRadius: 3.0)
        pointLight.isEnabled = true
        light.components.set(pointLight)

        return light
    }

    @MainActor
    private func createPatientAnatomy() async -> Entity? {
        // In production, this would load a complex 3D anatomical model
        // For now, create a placeholder
        let anatomy = Entity()

        let bodyMaterial = SimpleMaterial(color: .init(red: 0.9, green: 0.7, blue: 0.6, alpha: 1.0), isMetallic: false)
        let body = ModelEntity(
            mesh: .generateBox(width: 0.4, height: 0.15, depth: 0.6),
            materials: [bodyMaterial]
        )

        anatomy.addChild(body)
        return anatomy
    }

    @MainActor
    private func createInstrumentTable() async -> Entity {
        let table = Entity()

        let tableMaterial = SimpleMaterial(color: .gray, isMetallic: true)
        let tableTop = ModelEntity(
            mesh: .generateBox(width: 0.4, height: 0.02, depth: 0.8),
            materials: [tableMaterial]
        )
        table.addChild(tableTop)

        return table
    }

    // MARK: - Methods

    private var formattedTime: String {
        let minutes = Int(procedureState.elapsedTime / 60)
        let seconds = Int(procedureState.elapsedTime.truncatingRemainder(dividingBy: 60))
        return String(format: "%02d:%02d", minutes, seconds)
    }

    private var availableInstruments: [SurgicalInstrument] {
        // Return instruments appropriate for current procedure
        [
            SurgicalInstrument(name: "Scalpel", type: .scalpel, modelURL: URL(string: "file://scalpel.usdz")!),
            SurgicalInstrument(name: "Forceps", type: .forceps, modelURL: URL(string: "file://forceps.usdz")!),
            SurgicalInstrument(name: "Retractor", type: .retractor, modelURL: URL(string: "file://retractor.usdz")!),
            SurgicalInstrument(name: "Suture", type: .suture, modelURL: URL(string: "file://suture.usdz")!),
        ]
    }

    private func startProcedure() {
        procedureState.currentProcedure = .appendectomy
        procedureState.startTime = Date()
    }

    private func selectInstrument(_ instrument: SurgicalInstrument) {
        selectedInstrument = instrument
        appState.selectedInstrument = instrument
        print("Selected instrument: \(instrument.name)")
    }

    private func showProcedureMenu() {
        Task {
            await dismissImmersiveSpace()
        }
    }
}

// MARK: - Procedure State

@Observable
class ProcedureState {
    var currentProcedure: ProcedureType?
    var currentPhase: ProcedurePhase = .preparation
    var startTime: Date = Date()
    var elapsedTime: TimeInterval = 0
    var selectedInstrument: SurgicalInstrument?
    var showAICoach: Bool = true
    var performanceMetrics = PerformanceMetrics()
}

enum ProcedurePhase: String {
    case preparation = "Preparation"
    case incision = "Incision"
    case dissection = "Dissection"
    case mainProcedure = "Main Procedure"
    case closure = "Closure"
    case complete = "Complete"
}

struct PerformanceMetrics {
    var accuracy: Double = 0
    var efficiency: Double = 0
    var safety: Double = 0
    var movements: Int = 0
    var errors: Int = 0
}

// MARK: - Collaborative Theater View

struct CollaborativeTheaterView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        ZStack {
            RealityView { content in
                // Similar to SurgicalTheaterView but with collaboration features
                await setupCollaborativeTheater(content: content)
            }

            // Collaboration UI
            VStack {
                HStack {
                    Text("Collaborative Session")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(12)

                    Spacer()

                    participantsView
                }
                .padding()

                Spacer()
            }
        }
    }

    private var participantsView: some View {
        HStack(spacing: 8) {
            ForEach(appState.connectedPeers, id: \.id) { peer in
                VStack(spacing: 4) {
                    Circle()
                        .fill(.green)
                        .frame(width: 8, height: 8)

                    Text(peer.name)
                        .font(.caption)
                }
                .padding(8)
                .background(.ultraThinMaterial)
                .cornerRadius(8)
            }
        }
    }

    @MainActor
    private func setupCollaborativeTheater(content: RealityViewContent) async {
        // Similar setup to SurgicalTheaterView with collaboration features
        let root = Entity()
        content.add(root)
    }
}

// MARK: - RealityKit Service

@Observable
class RealityKitService {
    var rootEntity: Entity?
    var anatomyEntities: [UUID: ModelEntity] = [:]
    var instrumentEntities: [UUID: ModelEntity] = [:]

    func loadInstrument(_ instrument: SurgicalInstrument) async throws -> ModelEntity {
        // Load 3D model from URL
        // In production, use Entity.load(named:) or Entity.load(contentsOf:)
        let entity = ModelEntity()
        return entity
    }
}

#Preview {
    SurgicalTheaterView()
        .environment(AppState())
}
