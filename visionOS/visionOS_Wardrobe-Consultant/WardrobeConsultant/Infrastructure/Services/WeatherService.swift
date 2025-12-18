//
//  WeatherService.swift
//  WardrobeConsultant
//
//  Created by Claude Code
//  Copyright © 2025 Wardrobe Consultant. All rights reserved.
//

import Foundation
import CoreLocation

/// Service for fetching weather data
@MainActor
class WeatherService {
    static let shared = WeatherService()

    private init() {}

    // MARK: - Fetch Weather
    /// Fetch current weather for user's location
    func fetchCurrentWeather() async throws -> WeatherData {
        // TODO: Integrate with actual weather API (e.g., OpenWeatherMap, WeatherKit)
        // For now, return mock data

        return WeatherData(
            temperature: 22,
            condition: .partlyCloudy,
            humidity: 65,
            windSpeed: 10,
            feelsLike: 21,
            high: 25,
            low: 18
        )
    }

    /// Fetch weather forecast
    func fetchForecast(days: Int = 7) async throws -> [DailyForecast] {
        // TODO: Integrate with actual weather API
        // Mock data for now

        var forecasts: [DailyForecast] = []
        let baseTemp = 20

        for day in 0..<days {
            let date = Calendar.current.date(byAdding: .day, value: day, to: Date())!
            forecasts.append(DailyForecast(
                date: date,
                high: baseTemp + Int.random(in: 0...5),
                low: baseTemp - Int.random(in: 3...7),
                condition: [.clear, .partlyCloudy, .cloudy, .rain].randomElement()!,
                precipitationChance: Int.random(in: 0...100)
            ))
        }

        return forecasts
    }
}

// MARK: - Weather Data Models
struct WeatherData {
    let temperature: Int // Celsius or Fahrenheit based on settings
    let condition: WeatherCondition
    let humidity: Int // Percentage
    let windSpeed: Int // km/h or mph
    let feelsLike: Int
    let high: Int
    let low: Int
}

struct DailyForecast {
    let date: Date
    let high: Int
    let low: Int
    let condition: WeatherCondition
    let precipitationChance: Int // Percentage
}
