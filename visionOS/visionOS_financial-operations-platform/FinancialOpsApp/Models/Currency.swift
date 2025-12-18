//
//  Currency.swift
//  Financial Operations Platform
//
//  Currency and related models
//

import Foundation

// MARK: - Currency

struct Currency: Codable, Hashable, Identifiable {
    let code: String // ISO 4217
    let symbol: String
    let name: String

    var id: String { code }

    // MARK: - Common Currencies

    static let USD = Currency(code: "USD", symbol: "$", name: "US Dollar")
    static let EUR = Currency(code: "EUR", symbol: "€", name: "Euro")
    static let GBP = Currency(code: "GBP", symbol: "£", name: "British Pound")
    static let JPY = Currency(code: "JPY", symbol: "¥", name: "Japanese Yen")
    static let CNY = Currency(code: "CNY", symbol: "¥", name: "Chinese Yuan")
    static let CHF = Currency(code: "CHF", symbol: "Fr", name: "Swiss Franc")
    static let AUD = Currency(code: "AUD", symbol: "A$", name: "Australian Dollar")
    static let CAD = Currency(code: "CAD", symbol: "C$", name: "Canadian Dollar")

    static let all: [Currency] = [.USD, .EUR, .GBP, .JPY, .CNY, .CHF, .AUD, .CAD]
}

// MARK: - Close Period

struct ClosePeriod: Codable, Hashable {
    let year: Int
    let month: Int
    let type: PeriodType

    enum PeriodType: String, Codable {
        case monthly
        case quarterly
        case annual
    }

    // MARK: - Computed Properties

    var displayName: String {
        let monthName = DateFormatter().monthSymbols[month - 1]
        switch type {
        case .monthly:
            return "\(monthName) \(year)"
        case .quarterly:
            return "Q\((month - 1) / 3 + 1) \(year)"
        case .annual:
            return "FY \(year)"
        }
    }

    var startDate: Date {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = 1
        return Calendar.current.date(from: components) ?? Date()
    }

    var endDate: Date {
        var components = DateComponents()
        components.month = 1
        components.day = -1
        return Calendar.current.date(byAdding: components, to: startDate) ?? Date()
    }

    // MARK: - Factory Methods

    static func current() -> ClosePeriod {
        let now = Date()
        let calendar = Calendar.current
        let year = calendar.component(.year, from: now)
        let month = calendar.component(.month, from: now)
        return ClosePeriod(year: year, month: month, type: .monthly)
    }

    static func previous() -> ClosePeriod {
        let current = Self.current()
        var components = DateComponents()
        components.month = -1
        let previousDate = Calendar.current.date(byAdding: components, to: current.startDate) ?? Date()
        let year = Calendar.current.component(.year, from: previousDate)
        let month = Calendar.current.component(.month, from: previousDate)
        return ClosePeriod(year: year, month: month, type: .monthly)
    }
}

// MARK: - Date Extensions

extension DateInterval {
    static var last30Days: DateInterval {
        let end = Date()
        let start = Calendar.current.date(byAdding: .day, value: -30, to: end) ?? end
        return DateInterval(start: start, end: end)
    }

    static var last90Days: DateInterval {
        let end = Date()
        let start = Calendar.current.date(byAdding: .day, value: -90, to: end) ?? end
        return DateInterval(start: start, end: end)
    }

    static var currentMonth: DateInterval {
        let now = Date()
        let calendar = Calendar.current
        let start = calendar.date(from: calendar.dateComponents([.year, .month], from: now)) ?? now
        let end = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: start) ?? now
        return DateInterval(start: start, end: end)
    }
}
