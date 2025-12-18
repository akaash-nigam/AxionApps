import Foundation
import RealityKit

@MainActor
class InstrumentManager: ObservableObject {
    // MARK: - Properties
    @Published var activeInstruments: [Instrument] = []

    private var instrumentEntities: [UUID: InstrumentEntity] = [:]
    private var scene: SpatialMusicScene?

    // MARK: - Initialization
    init() {}

    func setScene(_ scene: SpatialMusicScene) {
        self.scene = scene
    }

    // MARK: - Instrument Management

    func createInstrumentEntity(_ instrument: Instrument, at position: SIMD3<Float>) {
        guard let scene = scene else { return }

        let entity = scene.placeInstrument(instrument, at: position)
        instrumentEntities[instrument.id] = entity
        activeInstruments.append(instrument)
    }

    func removeInstrumentEntity(_ instrumentId: UUID) {
        scene?.removeInstrument(instrumentId)
        instrumentEntities.removeValue(forKey: instrumentId)
        activeInstruments.removeAll { $0.id == instrumentId }
    }

    func updateInstrumentPosition(_ instrumentId: UUID, position: SIMD3<Float>) {
        if let entity = instrumentEntities[instrumentId] {
            entity.position = position
        }
    }

    func getInstrumentEntity(_ instrumentId: UUID) -> InstrumentEntity? {
        return instrumentEntities[instrumentId]
    }

    // MARK: - Audio Visualization

    func updateVisualization(for instrumentId: UUID, audioLevel: Float, frequency: Float) {
        if let entity = instrumentEntities[instrumentId] {
            entity.updateVisualization(audioLevel: audioLevel, frequency: frequency)
        }
    }
}
