//
//  ExperimentSession.swift
//  Science Lab Sandbox
//
//  Represents an active experiment session with data collection
//

import Foundation

// MARK: - Experiment Session

struct ExperimentSession: Codable, Identifiable {
    let id: UUID
    let experimentID: UUID
    let startTime: Date
    var endTime: Date?

    var hypothesis: String?
    var conclusion: String?

    var observations: [Observation]
    var measurements: [Measurement]
    var dataPoints: [DataPoint]

    // Session metadata
    var safetyViolations: Int
    var hintsUsed: Int
    var stepsCompleted: [UUID]

    init(
        id: UUID = UUID(),
        experimentID: UUID,
        startTime: Date,
        endTime: Date? = nil,
        hypothesis: String? = nil,
        conclusion: String? = nil,
        observations: [Observation] = [],
        measurements: [Measurement] = [],
        dataPoints: [DataPoint] = [],
        safetyViolations: Int = 0,
        hintsUsed: Int = 0,
        stepsCompleted: [UUID] = []
    ) {
        self.id = id
        self.experimentID = experimentID
        self.startTime = startTime
        self.endTime = endTime
        self.hypothesis = hypothesis
        self.conclusion = conclusion
        self.observations = observations
        self.measurements = measurements
        self.dataPoints = dataPoints
        self.safetyViolations = safetyViolations
        self.hintsUsed = hintsUsed
        self.stepsCompleted = stepsCompleted
    }

    var duration: TimeInterval? {
        guard let endTime = endTime else { return nil }
        return endTime.timeIntervalSince(startTime)
    }

    mutating func addObservation(_ text: String, category: ObservationCategory) {
        let observation = Observation(
            id: UUID(),
            timestamp: Date(),
            text: text,
            category: category
        )
        observations.append(observation)
    }

    mutating func addMeasurement(parameter: String, value: Double, unit: String) {
        let measurement = Measurement(
            id: UUID(),
            timestamp: Date(),
            parameter: parameter,
            value: value,
            unit: unit
        )
        measurements.append(measurement)
    }

    mutating func addDataPoint(_ point: DataPoint) {
        dataPoints.append(point)
    }

    mutating func recordSafetyViolation() {
        safetyViolations += 1
    }

    mutating func recordHintUsed() {
        hintsUsed += 1
    }

    mutating func completeStep(_ stepID: UUID) {
        guard !stepsCompleted.contains(stepID) else { return }
        stepsCompleted.append(stepID)
    }
}

// MARK: - Observation

struct Observation: Codable, Identifiable {
    let id: UUID
    let timestamp: Date
    let text: String
    let category: ObservationCategory

    init(id: UUID = UUID(), timestamp: Date, text: String, category: ObservationCategory) {
        self.id = id
        self.timestamp = timestamp
        self.text = text
        self.category = category
    }
}

enum ObservationCategory: String, Codable {
    case visual
    case auditory
    case tactile
    case olfactory
    case general
    case safety
    case unexpected
}

// MARK: - Measurement

struct Measurement: Codable, Identifiable {
    let id: UUID
    let timestamp: Date
    let parameter: String
    let value: Double
    let unit: String
    var precision: Double?

    init(
        id: UUID = UUID(),
        timestamp: Date,
        parameter: String,
        value: Double,
        unit: String,
        precision: Double? = nil
    ) {
        self.id = id
        self.timestamp = timestamp
        self.parameter = parameter
        self.value = value
        self.unit = unit
        self.precision = precision
    }
}

// MARK: - Data Point

struct DataPoint: Codable, Identifiable {
    let id: UUID
    let timestamp: Date
    let x: Double
    let y: Double
    let category: String?

    init(
        id: UUID = UUID(),
        timestamp: Date = Date(),
        x: Double,
        y: Double,
        category: String? = nil
    ) {
        self.id = id
        self.timestamp = timestamp
        self.x = x
        self.y = y
        self.category = category
    }
}
