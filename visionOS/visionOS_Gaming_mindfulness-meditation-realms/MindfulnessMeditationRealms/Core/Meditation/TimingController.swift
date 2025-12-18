import Foundation

/// High-precision timing controller for meditation sessions
class TimingController {

    // MARK: - Properties

    private var startTime: CFAbsoluteTime?
    private var pausedDuration: CFAbsoluteTime = 0
    private var lastPauseTime: CFAbsoluteTime?
    private var isRunning = false

    var elapsedTime: TimeInterval {
        guard let startTime = startTime else { return 0 }

        if isRunning {
            return CFAbsoluteTimeGetCurrent() - startTime - pausedDuration
        } else if let pauseTime = lastPauseTime {
            return pauseTime - startTime - pausedDuration
        } else {
            return 0
        }
    }

    // MARK: - Control Methods

    func start() {
        guard !isRunning else { return }

        if startTime == nil {
            startTime = CFAbsoluteTimeGetCurrent()
        } else if let pauseTime = lastPauseTime {
            pausedDuration += CFAbsoluteTimeGetCurrent() - pauseTime
            lastPauseTime = nil
        }

        isRunning = true
    }

    func pause() {
        guard isRunning else { return }

        lastPauseTime = CFAbsoluteTimeGetCurrent()
        isRunning = false
    }

    func stop() {
        isRunning = false
        startTime = nil
        pausedDuration = 0
        lastPauseTime = nil
    }

    func reset() {
        stop()
    }

    // MARK: - Query Methods

    func remainingTime(targetDuration: TimeInterval) -> TimeInterval {
        return max(0, targetDuration - elapsedTime)
    }

    func progress(targetDuration: TimeInterval) -> Double {
        guard targetDuration > 0 else { return 0 }
        return min(1.0, elapsedTime / targetDuration)
    }

    func isComplete(targetDuration: TimeInterval) -> Bool {
        return elapsedTime >= targetDuration
    }
}
