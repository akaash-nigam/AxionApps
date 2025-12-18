//
//  CacheManager.swift
//  HomeMaintenanceOracle
//
//  Created on 2025-11-24.
//

import Foundation

protocol CacheManager {
    func get<T: Codable>(forKey key: String) -> T?
    func set<T: Codable>(_ value: T, forKey key: String)
}

class TwoLevelCacheManager: CacheManager {
    private let memoryCache = NSCache<NSString, CacheEntry>()

    func get<T: Codable>(forKey key: String) -> T? {
        // TODO: Implement caching
        return nil
    }

    func set<T: Codable>(_ value: T, forKey key: String) {
        // TODO: Implement caching
    }
}

class CacheEntry {
    let value: Any
    let expiration: Date?

    init(value: Any, expiration: Date?) {
        self.value = value
        self.expiration = expiration
    }
}

protocol NotificationManager {
    func requestPermission() async throws
    func scheduleNotification(title: String, body: String, date: Date) throws
}

class LocalNotificationManager: NotificationManager {
    func requestPermission() async throws {}
    func scheduleNotification(title: String, body: String, date: Date) throws {}
}
