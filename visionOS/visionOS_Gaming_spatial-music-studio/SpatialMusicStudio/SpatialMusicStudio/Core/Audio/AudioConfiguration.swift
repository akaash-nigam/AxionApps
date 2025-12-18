import Foundation

struct AudioConfiguration {
    static let sampleRate: Double = 48000.0  // 48kHz for high quality
    static let bitDepth: Int = 24             // 24-bit audio
    static let targetLatency: TimeInterval = 0.010  // 10ms target latency
    static let bufferSize: Int = 512
    static let channels: Int = 2
}
