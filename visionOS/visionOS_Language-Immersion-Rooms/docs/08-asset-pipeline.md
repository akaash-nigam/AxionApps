# Asset Pipeline & Management

## Asset Types

### 3D Models
- Character models (USDZ, Reality Composer)
- Environment models (USDZ bundles)
- Interactive objects
- UI elements (floating cards, labels)

### Audio
- TTS-generated speech (MP3, M4A)
- Ambient sounds (environment audio)
- Background music
- Pronunciation samples

### Textures
- Environment textures (4K PBR materials)
- Character textures
- UI textures
- Icons and symbols

### Data
- Translation databases (SQLite)
- Grammar rules (JSON)
- Vocabulary lists (JSON)
- Scenario definitions (JSON)

## Directory Structure

```
Assets/
├── 3DModels/
│   ├── Characters/
│   │   ├── maria_spanish.usdz
│   │   ├── jean_french.usdz
│   │   └── yuki_japanese.usdz
│   ├── Environments/
│   │   ├── ParisianCafe/
│   │   │   ├── cafe.usdz
│   │   │   ├── props.usdz
│   │   │   └── lighting.usda
│   │   └── TokyoRamen/
│   └── Objects/
│       ├── table.usdz
│       └── chair.usdz
│
├── Audio/
│   ├── Pronunciations/
│   │   ├── es/
│   │   │   ├── hola.m4a
│   │   │   └── gracias.m4a
│   │   └── fr/
│   ├── Ambient/
│   │   ├── cafe_chatter.m4a
│   │   └── city_street.m4a
│   └── Music/
│
├── Textures/
│   ├── PBR/
│   │   ├── wood_albedo.png
│   │   ├── wood_normal.png
│   │   ├── wood_metallic.png
│   │   └── wood_roughness.png
│   └── UI/
│
└── Data/
    ├── Translations/
    │   └── es_en.db
    ├── Grammar/
    │   └── spanish_rules.json
    └── Scenarios/
        └── cafe_ordering.json
```

## Asset Bundles

### Language Pack Structure

```
LanguagePack_Spanish.bundle/
├── Info.plist
├── vocabulary.db        (50MB - 50K words)
├── grammar_rules.json   (5MB)
├── audio/               (200MB - pronunciations)
│   ├── common/          (100MB - top 1K words)
│   └── extended/        (100MB - remaining words)
└── scenarios/           (10MB)
    ├── cafe.json
    ├── restaurant.json
    └── shopping.json

Total: ~265MB per language pack
```

### Environment Bundle Structure

```
Environment_ParisianCafe.bundle/
├── Info.plist
├── scene.usdz           (50MB - main 3D scene)
├── props/               (30MB - interactive objects)
│   ├── table.usdz
│   ├── chair.usdz
│   └── menu.usdz
├── textures/            (100MB - high-res textures)
│   └── pbr/
├── audio/               (20MB - ambient sounds)
│   ├── ambient.m4a
│   └── music.m4a
└── metadata.json

Total: ~200MB per environment
```

## Asset Loading

### Lazy Loading Strategy

```swift
class AssetManager {
    private var loadedAssets: [String: Any] = [:]
    private let cache: NSCache<NSString, AnyObject>

    init() {
        cache = NSCache()
        cache.totalCostLimit = 500_000_000 // 500MB cache
    }

    func loadModel(named name: String) async throws -> ModelEntity {
        // Check cache
        if let cached = cache.object(forKey: name as NSString) as? ModelEntity {
            return cached
        }

        // Load from bundle
        let entity = try await Entity.load(named: name)

        // Cache
        cache.setObject(entity as AnyObject, forKey: name as NSString, cost: estimateSize(entity))

        return entity as! ModelEntity
    }

    private func estimateSize(_ entity: Entity) -> Int {
        // Rough estimate of entity memory footprint
        return 10_000_000 // 10MB default
    }
}
```

### Progressive Loading

```swift
class EnvironmentLoader {
    enum LoadingPhase {
        case skeleton      // Low-poly placeholders
        case mediumDetail  // Mid-poly models
        case fullDetail    // High-poly with textures
    }

    func loadEnvironment(_ environment: Environment, phase: LoadingPhase) async throws {
        switch phase {
        case .skeleton:
            // Load basic shapes immediately
            await loadSkeletonModels(environment)
        case .mediumDetail:
            // Load medium poly models
            await loadMediumModels(environment)
        case .fullDetail:
            // Stream in high-res textures
            await loadFullDetails(environment)
        }
    }
}
```

## Asset Download & Caching

### Download Manager

```swift
class AssetDownloadManager {
    private let session: URLSession
    private var activeDownloads: [URL: URLSessionDownloadTask] = [:]

    func downloadLanguagePack(_ language: Language) async throws {
        let url = URL(string: "https://cdn.languageimmersion.app/packs/\(language.id).bundle.zip")!

        let (localURL, response) = try await session.download(from: url)

        // Verify download
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw DownloadError.failed
        }

        // Unzip and install
        try await installBundle(at: localURL, for: language)
    }

    func downloadEnvironment(_ environment: Environment, priority: URLSessionTask.Priority = .default) async throws {
        let url = URL(string: "https://cdn.languageimmersion.app/envs/\(environment.id).bundle.zip")!

        let task = session.downloadTask(with: url)
        task.priority = priority

        activeDownloads[url] = task
        task.resume()

        // Track progress
        for await progress in task.progress.values {
            print("Download progress: \(progress.fractionCompleted)")
        }
    }

    private func installBundle(at url: URL, for language: Language) async throws {
        let fileManager = FileManager.default

        // Destination directory
        let appSupport = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        let bundleDir = appSupport.appendingPathComponent("LanguagePacks/\(language.id)")

        // Unzip
        try fileManager.unzipItem(at: url, to: bundleDir)
    }
}
```

### CDN Structure

```
CDN: https://cdn.languageimmersion.app/
├── packs/
│   ├── es.bundle.zip        (265MB)
│   ├── fr.bundle.zip        (265MB)
│   └── ja.bundle.zip        (300MB)
├── envs/
│   ├── parisian_cafe.bundle.zip     (200MB)
│   ├── tokyo_ramen.bundle.zip       (200MB)
│   └── madrid_tapas.bundle.zip      (200MB)
└── updates/
    └── models/
        └── yolov8_v2.mlmodel    (50MB)
```

## Asset Optimization

### 3D Model Optimization

```bash
# Use Reality Converter or usdz_converter

# Reduce polygon count
usdz_converter input.fbx output.usdz \
  --optimize-geometry \
  --max-vertices 50000

# Optimize for streaming
usdz_converter input.fbx output.usdz \
  --streaming \
  --lod-levels 3
```

### Texture Optimization

```swift
class TextureOptimizer {
    func compressTexture(_ url: URL) async throws -> URL {
        let image = UIImage(contentsOfFile: url.path)!

        // Resize to power of 2
        let optimizedImage = image.resize(to: CGSize(width: 2048, height: 2048))

        // Compress to ASTC (Apple's GPU texture format)
        let compressed = optimizedImage.compressToASTC()

        // Save
        let outputURL = url.deletingPathExtension().appendingPathExtension("astc")
        try compressed.write(to: outputURL)

        return outputURL
    }
}
```

### Audio Optimization

```bash
# Convert to AAC (better compression than MP3)
ffmpeg -i input.wav -c:a aac -b:a 64k -ar 22050 output.m4a

# For ambient sounds (lower quality acceptable)
ffmpeg -i ambient.wav -c:a aac -b:a 32k -ar 22050 ambient.m4a
```

## Asset Validation

### Pre-Upload Validation

```swift
class AssetValidator {
    func validate(model url: URL) throws {
        // Check file exists
        guard FileManager.default.fileExists(atPath: url.path) else {
            throw ValidationError.fileNotFound
        }

        // Check format
        guard url.pathExtension == "usdz" else {
            throw ValidationError.invalidFormat
        }

        // Check size
        let size = try FileManager.default.attributesOfItem(atPath: url.path)[.size] as! Int
        guard size < 100_000_000 else { // 100MB
            throw ValidationError.fileTooLarge
        }

        // Validate USD structure
        let scene = try USDZScene(url: url)
        guard scene.isValid else {
            throw ValidationError.invalidStructure
        }
    }

    func validate(languagePack pack: LanguagePackBundle) throws {
        // Check required files
        guard pack.hasVocabularyDatabase else {
            throw ValidationError.missingVocabulary
        }

        guard pack.hasGrammarRules else {
            throw ValidationError.missingGrammar
        }

        // Validate database schema
        try validateDatabaseSchema(pack.vocabularyDatabase)
    }
}
```

## Storage Management

### Storage Limits

```swift
class StorageManager {
    func getAvailableSpace() -> Int64 {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        if let dictionary = try? FileManager.default.attributesOfFileSystem(forPath: paths.last!) {
            if let freeSize = dictionary[.systemFreeSize] as? Int64 {
                return freeSize
            }
        }
        return 0
    }

    func canDownload(assetSize: Int64) -> Bool {
        let available = getAvailableSpace()
        let safetyMargin: Int64 = 1_000_000_000 // 1GB safety margin
        return available > (assetSize + safetyMargin)
    }

    func clearCache() {
        let cacheDir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]

        try? FileManager.default.removeItem(at: cacheDir)
        try? FileManager.default.createDirectory(at: cacheDir, withIntermediateDirectories: true)
    }
}
```

### LRU Cache for Assets

```swift
class LRUAssetCache<Key: Hashable, Value> {
    private var cache: [Key: CacheEntry] = [:]
    private var accessOrder: [Key] = []
    private let maxSize: Int

    struct CacheEntry {
        let value: Value
        var lastAccess: Date
        let size: Int
    }

    init(maxSize: Int) {
        self.maxSize = maxSize
    }

    func get(_ key: Key) -> Value? {
        guard var entry = cache[key] else { return nil }

        // Update access time
        entry.lastAccess = Date()
        cache[key] = entry

        // Move to front of access order
        accessOrder.removeAll { $0 == key }
        accessOrder.append(key)

        return entry.value
    }

    func set(_ key: Key, value: Value, size: Int) {
        // Evict if necessary
        while currentSize() + size > maxSize, let lru = accessOrder.first {
            cache.removeValue(forKey: lru)
            accessOrder.removeFirst()
        }

        // Insert
        cache[key] = CacheEntry(value: value, lastAccess: Date(), size: size)
        accessOrder.append(key)
    }

    private func currentSize() -> Int {
        return cache.values.reduce(0) { $0 + $1.size }
    }
}
```

## Asset Versioning

```swift
struct AssetVersion: Codable {
    let assetID: String
    let version: String
    let url: URL
    let checksum: String // SHA-256
    let size: Int64
    let releaseDate: Date
}

class AssetVersionManager {
    func checkForUpdates() async throws -> [AssetVersion] {
        let url = URL(string: "https://api.languageimmersion.app/assets/versions")!
        let (data, _) = try await URLSession.shared.data(from: url)

        let versions = try JSONDecoder().decode([AssetVersion].self, from: data)

        // Compare with installed versions
        let updates = versions.filter { shouldUpdate($0) }
        return updates
    }

    private func shouldUpdate(_ version: AssetVersion) -> Bool {
        // Check if newer version available
        guard let installedVersion = getInstalledVersion(for: version.assetID) else {
            return true
        }

        return version.version > installedVersion
    }
}
```
