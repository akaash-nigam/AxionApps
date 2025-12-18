import Foundation

@Observable
class CacheService {
    private var memoryCache = NSCache<NSString, AnyObject>()
    private let diskCacheURL: URL

    init() {
        let cacheDirectory = FileManager.default.urls(
            for: .cachesDirectory,
            in: .userDomainMask
        ).first!

        diskCacheURL = cacheDirectory.appendingPathComponent("RetailOptimizer")

        // Create cache directory if needed
        try? FileManager.default.createDirectory(
            at: diskCacheURL,
            withIntermediateDirectories: true
        )

        // Configure memory cache
        memoryCache.countLimit = 100
        memoryCache.totalCostLimit = 50 * 1024 * 1024 // 50 MB
    }

    func cache<T: Codable>(_ object: T, forKey key: String) {
        // Memory cache
        memoryCache.setObject(object as AnyObject, forKey: key as NSString)

        // Disk cache
        Task {
            do {
                let data = try JSONEncoder().encode(object)
                let fileURL = diskCacheURL.appendingPathComponent(key)
                try data.write(to: fileURL)
            } catch {
                print("Failed to cache \(key): \(error)")
            }
        }
    }

    func retrieve<T: Codable>(forKey key: String) -> T? {
        // Check memory first
        if let cached = memoryCache.object(forKey: key as NSString) as? T {
            return cached
        }

        // Check disk
        let fileURL = diskCacheURL.appendingPathComponent(key)
        guard let data = try? Data(contentsOf: fileURL),
              let object = try? JSONDecoder().decode(T.self, from: data) else {
            return nil
        }

        // Restore to memory
        memoryCache.setObject(object as AnyObject, forKey: key as NSString)
        return object
    }

    func clear() {
        memoryCache.removeAllObjects()

        try? FileManager.default.removeItem(at: diskCacheURL)
        try? FileManager.default.createDirectory(
            at: diskCacheURL,
            withIntermediateDirectories: true
        )
    }
}
