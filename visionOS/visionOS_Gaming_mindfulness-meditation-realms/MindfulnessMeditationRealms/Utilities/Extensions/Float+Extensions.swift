import Foundation

extension Float {

    // MARK: - Clamping

    /// Clamp value between 0.0 and 1.0
    var clamped01: Float {
        max(0.0, min(1.0, self))
    }

    /// Clamp value between min and max
    func clamped(min: Float, max: Float) -> Float {
        Swift.max(min, Swift.min(max, self))
    }

    // MARK: - Percentage

    /// Convert to percentage string (e.g., 0.75 -> "75%")
    var percentageString: String {
        String(format: "%.0f%%", self * 100)
    }

    /// Convert to percentage string with decimal (e.g., 0.754 -> "75.4%")
    var percentageStringWithDecimal: String {
        String(format: "%.1f%%", self * 100)
    }

    // MARK: - Rounding

    /// Round to decimal places
    func rounded(toPlaces places: Int) -> Float {
        let divisor = pow(10.0, Float(places))
        return (self * divisor).rounded() / divisor
    }

    // MARK: - Quality/Rating Helpers

    /// Convert to 1-5 star rating
    var starRating: Int {
        let clamped = self.clamped01
        return Int((clamped * 5).rounded())
    }

    /// Get quality description
    var qualityDescription: String {
        let clamped = self.clamped01

        switch clamped {
        case 0.9...1.0:
            return "Excellent"
        case 0.7..<0.9:
            return "Good"
        case 0.5..<0.7:
            return "Fair"
        case 0.3..<0.5:
            return "Poor"
        default:
            return "Very Poor"
        }
    }

    /// Get meditation depth description
    var depthDescription: String {
        let clamped = self.clamped01

        switch clamped {
        case 0.8...1.0:
            return "Deep"
        case 0.6..<0.8:
            return "Moderate"
        case 0.4..<0.6:
            return "Light"
        default:
            return "Settling"
        }
    }

    // MARK: - Stress/Calm Helpers

    /// Get stress level description
    var stressLevelDescription: String {
        let clamped = self.clamped01

        switch clamped {
        case 0.8...1.0:
            return "Very High"
        case 0.6..<0.8:
            return "High"
        case 0.4..<0.6:
            return "Moderate"
        case 0.2..<0.4:
            return "Low"
        default:
            return "Very Low"
        }
    }

    /// Get calm level description
    var calmLevelDescription: String {
        let clamped = self.clamped01

        switch clamped {
        case 0.8...1.0:
            return "Very Calm"
        case 0.6..<0.8:
            return "Calm"
        case 0.4..<0.6:
            return "Neutral"
        case 0.2..<0.4:
            return "Restless"
        default:
            return "Agitated"
        }
    }

    // MARK: - Color Helpers (for UI)

    /// Get color based on quality (green=good, red=poor)
    var qualityColor: (red: Float, green: Float, blue: Float) {
        let clamped = self.clamped01

        if clamped >= 0.7 {
            // Green
            return (0.3, 0.8, 0.4)
        } else if clamped >= 0.4 {
            // Yellow
            return (0.9, 0.8, 0.3)
        } else {
            // Red
            return (0.9, 0.3, 0.3)
        }
    }

    /// Get color based on stress (green=low, red=high)
    var stressColor: (red: Float, green: Float, blue: Float) {
        let clamped = self.clamped01
        let inverted = 1.0 - clamped // Invert so low stress = green

        if inverted >= 0.7 {
            return (0.3, 0.8, 0.4) // Green (low stress)
        } else if inverted >= 0.4 {
            return (0.9, 0.8, 0.3) // Yellow (medium stress)
        } else {
            return (0.9, 0.3, 0.3) // Red (high stress)
        }
    }

    // MARK: - Interpolation

    /// Linear interpolation between two values
    static func lerp(from: Float, to: Float, t: Float) -> Float {
        from + (to - from) * t.clamped01
    }

    /// Smooth interpolation (ease in/out)
    static func smoothLerp(from: Float, to: Float, t: Float) -> Float {
        let smoothT = t * t * (3 - 2 * t) // Smoothstep formula
        return lerp(from: from, to: to, t: smoothT)
    }
}
