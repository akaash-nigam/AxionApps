import Foundation

// MARK: - Date Extensions

extension Date {
    /// Returns the start of the day for this date
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }

    /// Returns the end of the day for this date
    var endOfDay: Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfDay) ?? self
    }

    /// Returns the start of the month for this date
    var startOfMonth: Date {
        let components = Calendar.current.dateComponents([.year, .month], from: self)
        return Calendar.current.date(from: components) ?? self
    }

    /// Returns the end of the month for this date
    var endOfMonth: Date {
        var components = DateComponents()
        components.month = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfMonth) ?? self
    }

    /// Returns the start of the year for this date
    var startOfYear: Date {
        let components = Calendar.current.dateComponents([.year], from: self)
        return Calendar.current.date(from: components) ?? self
    }

    /// Returns true if this date is in the current week
    var isInCurrentWeek: Bool {
        Calendar.current.isDate(self, equalTo: Date(), toGranularity: .weekOfYear)
    }

    /// Returns true if this date is in the current month
    var isInCurrentMonth: Bool {
        Calendar.current.isDate(self, equalTo: Date(), toGranularity: .month)
    }

    /// Returns true if this date is in the current year
    var isInCurrentYear: Bool {
        Calendar.current.isDate(self, equalTo: Date(), toGranularity: .year)
    }

    /// Returns the number of days from another date
    func days(from date: Date) -> Int {
        Calendar.current.dateComponents([.day], from: date, to: self).day ?? 0
    }

    /// Returns a date by adding specified number of days
    func addingDays(_ days: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: days, to: self) ?? self
    }

    /// Returns a date by adding specified number of months
    func addingMonths(_ months: Int) -> Date {
        Calendar.current.date(byAdding: .month, value: months, to: self) ?? self
    }

    /// Returns a formatted string for display
    func formatted(style: DateFormatter.Style = .medium) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = style
        formatter.timeStyle = .none
        return formatter.string(from: self)
    }

    /// Returns a relative date string (e.g., "2 days ago", "in 3 weeks")
    var relativeFormatted: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: self, relativeTo: Date())
    }
}

// MARK: - Double Extensions

extension Double {
    /// Formats the number as emissions (e.g., "1,234.5 tCO2e")
    var asEmissions: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 1
        formatter.minimumFractionDigits = 0
        return "\(formatter.string(from: NSNumber(value: self)) ?? "0") tCO2e"
    }

    /// Formats the number as percentage (e.g., "45.2%")
    var asPercentage: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.maximumFractionDigits = 1
        formatter.minimumFractionDigits = 0
        return formatter.string(from: NSNumber(value: self / 100)) ?? "0%"
    }

    /// Formats the number as currency (e.g., "$1,234.56")
    func asCurrency(code: String = "USD") -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = code
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: self)) ?? "$0.00"
    }

    /// Formats the number with abbreviation (e.g., "1.2K", "3.4M")
    var abbreviated: String {
        let abbreviations = ["", "K", "M", "B", "T"]
        var index = 0
        var value = self

        while abs(value) >= 1000 && index < abbreviations.count - 1 {
            value /= 1000
            index += 1
        }

        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 1
        formatter.minimumFractionDigits = 0

        return "\(formatter.string(from: NSNumber(value: value)) ?? "0")\(abbreviations[index])"
    }

    /// Rounds to specified decimal places
    func rounded(to places: Int) -> Double {
        let multiplier = pow(10.0, Double(places))
        return (self * multiplier).rounded() / multiplier
    }
}

// MARK: - Array Extensions

extension Array where Element == Double {
    /// Returns the sum of all elements
    var sum: Double {
        reduce(0, +)
    }

    /// Returns the average of all elements
    var average: Double {
        isEmpty ? 0 : sum / Double(count)
    }

    /// Returns the minimum value or 0 if empty
    var minimum: Double {
        self.min() ?? 0
    }

    /// Returns the maximum value or 0 if empty
    var maximum: Double {
        self.max() ?? 0
    }

    /// Returns the standard deviation
    var standardDeviation: Double {
        guard count > 1 else { return 0 }
        let avg = average
        let squaredDifferences = map { pow($0 - avg, 2) }
        let variance = squaredDifferences.sum / Double(count - 1)
        return sqrt(variance)
    }
}

extension Array where Element: Identifiable {
    /// Finds an element by ID
    func find(by id: Element.ID) -> Element? {
        first { $0.id == id }
    }

    /// Removes an element by ID
    mutating func remove(by id: Element.ID) {
        removeAll { $0.id == id }
    }
}

// MARK: - String Extensions

extension String {
    /// Validates if the string is a valid email
    var isValidEmail: Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let predicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return predicate.evaluate(with: self)
    }

    /// Truncates the string to specified length with ellipsis
    func truncated(to length: Int, trailing: String = "...") -> String {
        if count > length {
            return String(prefix(length - trailing.count)) + trailing
        }
        return self
    }

    /// Capitalizes first letter only
    var capitalizedFirstLetter: String {
        prefix(1).capitalized + dropFirst()
    }
}

// MARK: - Collection Extensions

extension Collection {
    /// Safe subscript that returns nil if index is out of bounds
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

// MARK: - Result Extensions

extension Result {
    /// Returns the success value or nil
    var value: Success? {
        switch self {
        case .success(let value):
            return value
        case .failure:
            return nil
        }
    }

    /// Returns the failure error or nil
    var error: Failure? {
        switch self {
        case .success:
            return nil
        case .failure(let error):
            return error
        }
    }
}
