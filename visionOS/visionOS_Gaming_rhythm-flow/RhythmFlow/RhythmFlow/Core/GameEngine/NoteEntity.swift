//
//  NoteEntity.swift
//  RhythmFlow
//
//  RealityKit entity representing a note
//

import Foundation
import RealityKit
import simd

class NoteEntity {
    // MARK: - Properties
    var id: UUID
    var noteType: NoteType
    var position: SIMD3<Float>
    var targetTime: TimeInterval
    var spawnTime: TimeInterval
    var points: Int
    var requiredHand: Hand
    var requiredGesture: GestureType
    var isHit: Bool = false
    var hitQuality: HitQuality?

    // MARK: - Visual
    var color: SIMD3<Float>
    var radius: Float = 0.1

    // MARK: - Movement
    var velocity: SIMD3<Float>
    var targetPosition: SIMD3<Float>

    // MARK: - Hit Detection
    var hitRadius: Float {
        switch hitQuality {
        case .perfect: return 0.05
        case .great: return 0.10
        case .good: return 0.15
        default: return 0.20
        }
    }

    // MARK: - Initialization
    init(type: NoteType) {
        self.id = UUID()
        self.noteType = type
        self.position = .zero
        self.targetTime = 0
        self.spawnTime = 0
        self.points = 100
        self.requiredHand = .right
        self.requiredGesture = .punch
        self.color = SIMD3<Float>(1, 1, 1)
        self.velocity = .zero
        self.targetPosition = .zero
    }

    // MARK: - Configuration
    func configure(from event: NoteEvent) {
        self.id = event.id
        self.noteType = event.type
        self.targetTime = event.timestamp
        self.spawnTime = CACurrentMediaTime()
        self.points = event.points
        self.requiredHand = event.hand
        self.requiredGesture = event.gesture
        self.color = event.color.rgbValues

        // Set initial position (spawn distance)
        let spawnDistance: Float = 3.0
        self.position = event.position + SIMD3<Float>(0, 0, -spawnDistance)
        self.targetPosition = event.position

        // Calculate velocity to reach target on time
        let approachDuration = event.timestamp - CACurrentMediaTime()
        self.velocity = (targetPosition - position) / Float(approachDuration)
    }

    // MARK: - Update
    func update(deltaTime: TimeInterval) {
        guard !isHit else { return }

        // Move towards target
        position += velocity * Float(deltaTime)

        // TODO: Update visual entity transform
    }

    // MARK: - Hit Handling
    func markAsHit(quality: HitQuality) {
        isHit = true
        hitQuality = quality

        // TODO: Trigger hit visual effects
        // TODO: Play hit sound
    }

    // MARK: - Reset
    func reset() {
        id = UUID()
        isHit = false
        hitQuality = nil
        position = .zero
        velocity = .zero
    }
}

// MARK: - Note Entity Pool

class NoteEntityPool {
    private var pools: [NoteType: [NoteEntity]] = [:]
    private let maxPoolSize = 100

    init() {
        // Pre-populate pools
        for noteType in [NoteType.punch, .swipe, .hold] {
            pools[noteType] = []
        }
    }

    func acquire(type: NoteType) -> NoteEntity {
        // Try to reuse from pool
        if var pool = pools[type], !pool.isEmpty {
            let note = pool.removeLast()
            pools[type] = pool
            return note
        }

        // Create new if pool is empty
        return NoteEntity(type: type)
    }

    func release(_ entity: NoteEntity) {
        // Reset state
        entity.reset()

        // Return to pool
        var pool = pools[entity.noteType] ?? []
        if pool.count < maxPoolSize {
            pool.append(entity)
            pools[entity.noteType] = pool
        }
    }

    func preload(type: NoteType, count: Int) {
        var pool = pools[type] ?? []
        let needed = count - pool.count

        for _ in 0..<needed {
            pool.append(NoteEntity(type: type))
        }

        pools[type] = pool
    }
}
