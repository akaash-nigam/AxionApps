# Reality MMO Layer - Technical Specification

## Document Information

**Version:** 1.0
**Last Updated:** 2025-01-20
**Status:** Design Phase
**Authors:** Development Team
**Reviewed By:** Pending

---

## Table of Contents

1. [Technology Stack](#1-technology-stack)
2. [Game Mechanics Implementation](#2-game-mechanics-implementation)
3. [Control Schemes](#3-control-schemes)
4. [Physics Specifications](#4-physics-specifications)
5. [Rendering Requirements](#5-rendering-requirements)
6. [Multiplayer/Networking Specifications](#6-multiplayernetworking-specifications)
7. [Performance Budgets](#7-performance-budgets)
8. [Testing Requirements](#8-testing-requirements)
9. [API Specifications](#9-api-specifications)
10. [Security Specifications](#10-security-specifications)
11. [Deployment Architecture](#11-deployment-architecture)

---

## 1. Technology Stack

### 1.1 Client Technologies

#### Core Platform
```yaml
Platform:
  Name: Apple Vision Pro
  OS: visionOS 2.0+
  Minimum Device: Vision Pro (1st generation)
  Target SDK: visionOS SDK 2.0

Language:
  Primary: Swift 6.0+
  Version Requirements:
    - Swift 6.0 for concurrency safety
    - Async/await for asynchronous operations
    - Actors for thread-safe state management
```

#### Frameworks & Libraries

**UI Layer:**
```swift
// SwiftUI 5.0+ for all UI/menus
import SwiftUI

// Key features used:
// - WindowGroup for 2D windows
// - ImmersiveSpace for AR gameplay
// - Observable for state management
// - Environment values for configuration
// - Custom view modifiers for spatial UI
```

**3D Rendering:**
```swift
// RealityKit 2.0+ for 3D gameplay
import RealityKit

// Features:
// - Entity-Component-System architecture
// - Custom components for game logic
// - Material system for visuals
// - Particle systems for effects
// - Animation system
```

**AR Tracking:**
```swift
// ARKit 6.0+ for spatial tracking
import ARKit

// Providers used:
// - WorldTrackingProvider: Camera tracking
// - PlaneDetectionProvider: Surface detection
// - SceneReconstructionProvider: Mesh generation
// - HandTrackingProvider: Hand gesture input
// - ImageTrackingProvider: Marker detection
```

**Location Services:**
```swift
// CoreLocation for GPS
import CoreLocation

// Features:
// - Continuous location updates
// - Geofencing for zone triggers
// - Heading for orientation
// - Background location updates
```

**Spatial Audio:**
```swift
// AVFoundation with spatial audio
import AVFoundation

// Components:
// - AVAudioEngine for 3D audio
// - AVAudioEnvironmentNode for spatialization
// - AVAudioPlayerNode for sound sources
// - Custom audio session configuration
```

**Networking:**
```swift
// Network communication
import Foundation // URLSession
import Network // Network.framework for WebSocket

// Third-party:
// - Socket.IO Swift client for real-time
// - Alamofire for HTTP REST APIs
// - gRPC Swift for service communication
```

**Local Persistence:**
```swift
// Data storage
import CoreData // Structured local storage
import SwiftData // Modern persistence (visionOS 2.0+)

// File storage:
// - FileManager for asset caching
// - UserDefaults for settings
// - Keychain for secure tokens
```

### 1.2 Server Technologies

#### Backend Services
```yaml
Primary Runtime:
  Language: Node.js 20 LTS
  Framework: Express.js 4.18+
  Type System: TypeScript 5.0+

Secondary Runtime:
  Language: Go 1.21+
  Framework: Gin / Fiber
  Use Case: High-performance services (spatial indexing, physics validation)

API Layer:
  REST: Express.js with OpenAPI 3.0 spec
  GraphQL: Apollo Server 4.0+
  gRPC: @grpc/grpc-js for service-to-service

Real-Time:
  WebSocket: Socket.IO 4.6+
  Message Queue: Apache Kafka 3.5+
  Pub/Sub: Redis Pub/Sub for broadcasts

Containerization:
  Runtime: Docker 24+
  Orchestration: Kubernetes 1.28+
  Service Mesh: Istio 1.20+
```

#### Database Systems

**Relational Database:**
```sql
-- PostgreSQL 15+ for structured data
-- Configuration:
max_connections = 500
shared_buffers = 8GB
effective_cache_size = 24GB
work_mem = 32MB
maintenance_work_mem = 2GB

-- Extensions:
-- PostGIS for geospatial queries
-- pg_trgm for text search
-- uuid-ossp for UUID generation
-- TimescaleDB for time-series data
```

**Document Database:**
```javascript
// MongoDB 7+ for spatial content
// Configuration:
{
  "storage": {
    "engine": "wiredTiger",
    "wiredTiger": {
      "engineConfig": {
        "cacheSizeGB": 16
      }
    }
  },
  "replication": {
    "replSetName": "realitymmo-rs",
    "members": 5
  }
}

// Sharding strategy:
// - Shard key: geohash of location (enables geo-distributed queries)
// - Chunks distributed across regions
```

**Cache Layer:**
```redis
# Redis 7+ for caching
# Configuration:
maxmemory 32gb
maxmemory-policy allkeys-lru
appendonly yes
appendfsync everysec

# Cluster mode with 6 nodes (3 masters, 3 replicas)
# Hash slots distributed for high availability
```

**Object Storage:**
```yaml
Storage: AWS S3 / CloudFlare R2
Purpose: 3D models, textures, audio files

Configuration:
  Bucket Structure:
    - assets-models: 3D meshes (.usdz, .reality)
    - assets-textures: PBR texture maps
    - assets-audio: Spatial audio files

  CDN: CloudFlare for edge delivery

  Lifecycle:
    - Hot tier: Frequently accessed (last 30 days)
    - Cool tier: Infrequently accessed (30-90 days)
    - Archive: Historical content (90+ days)
```

### 1.3 AI/ML Stack

```yaml
LLM Services:
  Provider: OpenAI API / Azure OpenAI
  Models:
    - GPT-4 Turbo: Complex content generation
    - GPT-3.5 Turbo: NPC dialogue, simple tasks

  Usage:
    - Quest generation
    - NPC conversation
    - Dynamic event creation
    - Content moderation

On-Device ML:
  Framework: Core ML / Create ML
  Models:
    - Player behavior prediction (compressed LSTM)
    - Voice command recognition
    - Gesture classification

  Model Format: .mlmodel (Core ML format)
  Quantization: 8-bit for inference speed

ML Pipeline:
  Training: Python 3.11 + TensorFlow 2.15
  Deployment: TensorFlow Lite for on-device
  Monitoring: MLflow for experiment tracking
```

### 1.4 DevOps & Infrastructure

```yaml
CI/CD:
  Platform: GitHub Actions
  Build: Xcode Cloud for iOS builds
  Testing: XCTest + Appium for E2E
  Deployment: Fastlane for automation

Infrastructure as Code:
  Tool: Terraform 1.6+
  Providers: AWS, Azure, GCP
  State: S3 backend with DynamoDB locking

Monitoring:
  APM: New Relic / DataDog
  Logging: ELK Stack (Elasticsearch, Logstash, Kibana)
  Metrics: Prometheus + Grafana
  Tracing: Jaeger for distributed tracing

Analytics:
  Platform: Mixpanel for user analytics
  Custom: InfluxDB for game telemetry
  Real-time: Apache Kafka + Flink for stream processing
```

---

## 2. Game Mechanics Implementation

### 2.1 Character Progression System

```swift
// Character class system
enum CharacterClass: String, Codable {
    case warrior    // Melee combat specialist
    case mage       // Ranged magical attacks
    case rogue      // Stealth and agility
    case cleric     // Support and healing
    case ranger     // Ranged physical attacks
}

// Experience and leveling
struct ProgressionSystem {
    // XP curve: exponential scaling
    static func experienceRequired(for level: Int) -> Int {
        return Int(100 * pow(1.5, Double(level - 1)))
    }

    // Level up rewards
    static func rewardsForLevel(_ level: Int) -> LevelRewards {
        return LevelRewards(
            skillPoints: level <= 10 ? 1 : 2,
            attributePoints: 3,
            healthIncrease: 20,
            manaIncrease: 15,
            unlockedAbilities: abilitiesAtLevel(level)
        )
    }
}

// Skill tree implementation
struct SkillTree {
    var skills: [Skill] = []
    var activeSkills: Set<UUID> = []
    var passiveSkills: Set<UUID> = []

    // Skill requirements
    func canLearnSkill(_ skill: Skill, player: Player) -> Bool {
        // Check level requirement
        guard player.level >= skill.minimumLevel else { return false }

        // Check prerequisite skills
        for prereqID in skill.prerequisites {
            guard activeSkills.contains(prereqID) || passiveSkills.contains(prereqID) else {
                return false
            }
        }

        // Check skill points
        guard player.availableSkillPoints >= skill.cost else { return false }

        return true
    }
}

// Stats and attributes
struct CharacterStats {
    // Core attributes
    var strength: Int      // Physical damage, carry weight
    var agility: Int       // Attack speed, dodge chance
    var intelligence: Int  // Magical damage, mana pool
    var vitality: Int      // Health pool, regeneration
    var wisdom: Int        // Mana regeneration, resistance

    // Derived stats (calculated)
    var health: Int {
        return 100 + (vitality * 20)
    }

    var mana: Int {
        return 50 + (intelligence * 15)
    }

    var attackPower: Int {
        return strength * 5
    }

    var spellPower: Int {
        return intelligence * 5
    }

    var defense: Int {
        return vitality * 2
    }

    var dodgeChance: Float {
        return min(0.75, Float(agility) * 0.005) // Cap at 75%
    }
}
```

### 2.2 Combat System

```swift
// Combat mechanics
class CombatSystem {
    // Damage calculation
    func calculateDamage(
        attacker: Entity,
        target: Entity,
        ability: Ability
    ) -> DamageResult {
        guard let attackerStats = attacker.components[StatsComponent.self],
              let targetStats = target.components[StatsComponent.self] else {
            return DamageResult.failed
        }

        // Base damage from ability
        var damage = ability.baseDamage

        // Apply attacker's power scaling
        if ability.damageType == .physical {
            damage += Float(attackerStats.attackPower) * ability.scaling
        } else if ability.damageType == .magical {
            damage += Float(attackerStats.spellPower) * ability.scaling
        }

        // Random variance ±10%
        let variance = Float.random(in: 0.9...1.1)
        damage *= variance

        // Critical hit check
        let isCritical = Float.random(in: 0...1) < attackerStats.criticalChance
        if isCritical {
            damage *= 2.0
        }

        // Apply defense
        let damageReduction = Float(targetStats.defense) * 0.5
        damage = max(1, damage - damageReduction)

        // Dodge check
        if Float.random(in: 0...1) < targetStats.dodgeChance {
            return DamageResult.dodged
        }

        return DamageResult(
            damage: Int(damage),
            isCritical: isCritical,
            damageType: ability.damageType
        )
    }

    // Cooldown system
    private var abilityCooldowns: [UUID: [UUID: TimeInterval]] = [:] // [playerID: [abilityID: endTime]]

    func canUseAbility(player: UUID, ability: Ability) -> Bool {
        guard let cooldowns = abilityCooldowns[player],
              let cooldownEnd = cooldowns[ability.id] else {
            return true // No cooldown active
        }

        return Date().timeIntervalSince1970 > cooldownEnd
    }

    func useAbility(player: UUID, ability: Ability) {
        let cooldownEnd = Date().timeIntervalSince1970 + ability.cooldown

        if abilityCooldowns[player] == nil {
            abilityCooldowns[player] = [:]
        }

        abilityCooldowns[player]![ability.id] = cooldownEnd
    }
}

// Status effects
enum StatusEffect {
    case stun(duration: TimeInterval)
    case slow(percentage: Float, duration: TimeInterval)
    case burn(damagePerTick: Int, duration: TimeInterval)
    case heal(amountPerTick: Int, duration: TimeInterval)
    case shield(absorb: Int, duration: TimeInterval)
    case invisible(duration: TimeInterval)
}

class StatusEffectManager {
    private var activeEffects: [UUID: [StatusEffectInstance]] = [:]

    func applyEffect(_ effect: StatusEffect, to entity: UUID) {
        let instance = StatusEffectInstance(
            effect: effect,
            startTime: Date(),
            source: entity
        )

        activeEffects[entity, default: []].append(instance)
    }

    func updateEffects(deltaTime: TimeInterval) {
        for (entity, effects) in activeEffects {
            var remainingEffects: [StatusEffectInstance] = []

            for effect in effects {
                if !effect.isExpired() {
                    applyEffectTick(effect, to: entity, deltaTime: deltaTime)
                    remainingEffects.append(effect)
                }
            }

            activeEffects[entity] = remainingEffects
        }
    }
}
```

### 2.3 Guild System

```swift
// Guild management
struct Guild {
    let id: UUID
    var name: String
    var tag: String // 3-5 characters

    // Membership
    var leader: UUID
    var officers: [UUID]
    var members: [UUID]

    // Ranks
    var ranks: [GuildRank]

    // Resources
    var treasury: Int
    var reputation: Int
    var level: Int

    // Territory
    var controlledZones: [TerritoryZone]
    var headquarters: GeoCoordinate?

    // Settings
    var isRecruiting: Bool
    var minimumLevel: Int
    var description: String

    // Computed properties
    var totalMembers: Int {
        return 1 + officers.count + members.count
    }

    var maxMembers: Int {
        return 50 + (level * 10) // Scales with guild level
    }
}

// Territory control
struct TerritoryZone {
    let id: UUID
    let name: String
    let location: GeoCoordinate
    let radius: Double // meters

    var controllingGuild: UUID?
    var contestStartTime: Date?

    // Benefits for controlling guild
    var benefits: [TerritoryBenefit]
}

enum TerritoryBenefit {
    case resourceBonus(percentage: Float)
    case experienceBonus(percentage: Float)
    case fastTravel(enabled: Bool)
    case vendorDiscount(percentage: Float)
    case respawnPoint(enabled: Bool)
}

// Guild warfare
class GuildWarfareSystem {
    func initiateTerritoryClaim(zone: TerritoryZone, guild: Guild) -> Bool {
        // Requirements
        guard guild.level >= 5 else { return false }
        guard guild.treasury >= 10000 else { return false }

        // Start contest period (24 hours)
        var mutableZone = zone
        mutableZone.contestStartTime = Date()

        // Notify all guilds
        notifyGuildContest(zone: mutableZone)

        return true
    }

    func resolveTerritoryClaim(zone: TerritoryZone) -> UUID? {
        // After contest period, guild with most presence wins
        let guildPresence = calculateGuildPresence(in: zone)

        let winner = guildPresence.max(by: { $0.value < $1.value })

        return winner?.key
    }

    private func calculateGuildPresence(in zone: TerritoryZone) -> [UUID: Int] {
        // Count player-hours in zone during contest
        var presence: [UUID: Int] = [:]

        // Query from database
        // presence[guildID] = total seconds spent by members

        return presence
    }
}
```

### 2.4 Economy System

```swift
// Currency types
enum Currency {
    case gold           // Basic currency
    case gems           // Premium currency
    case guildTokens    // Guild contribution points
    case eventTokens    // Limited-time event currency
}

// Item system
struct Item: Codable, Identifiable {
    let id: UUID
    let name: String
    let description: String
    let itemType: ItemType
    let rarity: ItemRarity

    // Stats
    let level: Int
    let stats: [StatModifier]

    // Trading
    let isTradeable: Bool
    let vendorValue: Int

    // Metadata
    let iconName: String
    let modelName: String?
}

enum ItemType {
    case weapon(WeaponType)
    case armor(ArmorSlot)
    case consumable(ConsumableEffect)
    case material
    case quest
    case cosmetic
}

enum ItemRarity: Int, Comparable {
    case common = 1
    case uncommon = 2
    case rare = 3
    case epic = 4
    case legendary = 5

    var color: UIColor {
        switch self {
        case .common: return .gray
        case .uncommon: return .green
        case .rare: return .blue
        case .epic: return .purple
        case .legendary: return .orange
        }
    }
}

// Marketplace
class MarketplaceSystem {
    struct Listing {
        let id: UUID
        let seller: UUID
        let item: Item
        let quantity: Int
        let pricePerUnit: Int
        let currency: Currency
        let listedAt: Date
        let expiresAt: Date
    }

    func createListing(
        seller: UUID,
        item: Item,
        quantity: Int,
        price: Int,
        currency: Currency
    ) async throws -> Listing {
        // Validation
        guard item.isTradeable else {
            throw MarketplaceError.itemNotTradeable
        }

        guard await verifyInventory(seller: seller, item: item, quantity: quantity) else {
            throw MarketplaceError.insufficientItems
        }

        // Create listing
        let listing = Listing(
            id: UUID(),
            seller: seller,
            item: item,
            quantity: quantity,
            pricePerUnit: price,
            currency: currency,
            listedAt: Date(),
            expiresAt: Date().addingTimeInterval(7 * 86400) // 7 days
        )

        // Lock items in escrow
        await lockItemsInEscrow(listing: listing)

        // Save to database
        try await database.saveListing(listing)

        return listing
    }

    func purchaseListing(buyer: UUID, listing: Listing, quantity: Int) async throws {
        let totalCost = listing.pricePerUnit * quantity

        // Verify funds
        guard await verifyFunds(buyer: buyer, amount: totalCost, currency: listing.currency) else {
            throw MarketplaceError.insufficientFunds
        }

        // Process transaction
        await deductFunds(buyer: buyer, amount: totalCost, currency: listing.currency)
        await addFunds(seller: listing.seller, amount: totalCost, currency: listing.currency)

        // Transfer items
        await transferItems(from: listing.seller, to: buyer, item: listing.item, quantity: quantity)

        // Update or remove listing
        if quantity == listing.quantity {
            await database.deleteListing(listing.id)
        } else {
            await database.updateListingQuantity(listing.id, newQuantity: listing.quantity - quantity)
        }
    }
}
```

### 2.5 Quest System

```swift
// Quest types
enum QuestType {
    case main               // Main storyline
    case side               // Optional side content
    case daily              // Resets daily
    case weekly             // Resets weekly
    case guild              // Guild-specific
    case event              // Limited-time event
    case generated          // AI-generated
}

// Quest objectives
enum QuestObjective {
    case kill(enemyType: String, count: Int)
    case collect(itemID: UUID, count: Int)
    case visit(location: GeoCoordinate, radius: Double)
    case interact(entityID: UUID)
    case escort(npcID: UUID, destination: GeoCoordinate)
    case craft(itemID: UUID, count: Int)
    case trade(npcID: UUID, items: [UUID])
}

// Quest progression
class QuestManager {
    private var activeQuests: [UUID: Quest] = [:]
    private var completedQuests: Set<UUID> = []

    func acceptQuest(_ quest: Quest, player: UUID) -> Bool {
        // Check requirements
        guard canAcceptQuest(quest, player: player) else {
            return false
        }

        // Check active quest limit
        let playerQuests = activeQuests.filter { $0.value.acceptedBy == player }
        guard playerQuests.count < 20 else {
            return false // Quest log full
        }

        // Accept quest
        var mutableQuest = quest
        mutableQuest.acceptedBy = player
        mutableQuest.acceptedAt = Date()
        activeQuests[quest.id] = mutableQuest

        return true
    }

    func updateQuestProgress(
        player: UUID,
        objective: QuestObjective,
        progress: Int
    ) {
        for (questID, quest) in activeQuests where quest.acceptedBy == player {
            for (index, questObjective) in quest.objectives.enumerated() {
                if objectivesMatch(questObjective, objective) {
                    var mutableQuest = quest
                    mutableQuest.objectiveProgress[index] = progress

                    activeQuests[questID] = mutableQuest

                    // Check if all objectives complete
                    if allObjectivesComplete(mutableQuest) {
                        completeQuest(mutableQuest, player: player)
                    }
                }
            }
        }
    }

    func completeQuest(_ quest: Quest, player: UUID) {
        // Grant rewards
        grantExperience(player: player, amount: quest.experienceReward)
        grantCurrency(player: player, amount: quest.currencyReward, currency: .gold)

        for item in quest.itemRewards {
            grantItem(player: player, item: item)
        }

        // Mark complete
        activeQuests.removeValue(forKey: quest.id)
        completedQuests.insert(quest.id)

        // Trigger next quests in chain
        for nextQuestID in quest.nextQuests {
            if let nextQuest = loadQuest(nextQuestID) {
                makeQuestAvailable(nextQuest, for: player)
            }
        }
    }
}
```

---

## 3. Control Schemes

### 3.1 Hand Tracking Controls

```swift
class HandTrackingController {
    private let handTracking = HandTrackingProvider()

    // Gesture recognition
    enum GameGesture {
        case pinch(hand: Hand)
        case grab(hand: Hand)
        case point(hand: Hand, direction: SIMD3<Float>)
        case swipe(hand: Hand, direction: SwipeDirection)

        // Combat gestures
        case fireball          // Push forward with open palm
        case shield            // Cross arms
        case sword_slash       // Diagonal swipe
        case bow_draw          // Pull motion
    }

    func processHandTracking() async {
        guard handTracking.state == .isSupported else { return }

        for await update in handTracking.anchorUpdates {
            let handAnchor = update.anchor

            if let gesture = recognizeGesture(handAnchor) {
                handleGesture(gesture)
            }
        }
    }

    private func recognizeGesture(_ hand: HandAnchor) -> GameGesture? {
        // Get hand skeleton
        guard let skeleton = hand.handSkeleton else { return nil }

        // Pinch detection
        if isPinching(skeleton) {
            return .pinch(hand: hand.chirality)
        }

        // Fireball gesture (palm push)
        if isFireballGesture(skeleton) {
            return .fireball
        }

        // Add more gesture recognition...

        return nil
    }

    private func isPinching(_ skeleton: HandSkeleton) -> Bool {
        // Distance between thumb tip and index finger tip
        guard let thumbTip = skeleton.joint(.thumbTip),
              let indexTip = skeleton.joint(.indexFingerTip) else {
            return false
        }

        let distance = simd_distance(
            thumbTip.anchorFromJointTransform.translation,
            indexTip.anchorFromJointTransform.translation
        )

        return distance < 0.02 // 2cm threshold
    }
}
```

### 3.2 Eye Tracking Controls

```swift
class EyeTrackingController {
    private var eyeTracking: EyeTrackingProvider?
    private var currentGazeTarget: Entity?

    // Gaze targeting parameters
    private let dwellTime: TimeInterval = 0.5 // Time to confirm selection
    private let gazeRadius: Float = 0.05 // Acceptance radius in meters

    private var gazeStartTime: Date?
    private var gazedEntity: Entity?

    func processEyeTracking() async {
        guard let provider = eyeTracking else { return }

        for await update in provider.anchorUpdates {
            let eyeAnchor = update.anchor

            // Cast ray from gaze direction
            let gazeOrigin = eyeAnchor.originFromAnchorTransform.translation
            let gazeDirection = eyeAnchor.lookAtPoint

            if let hit = performGazeRaycast(origin: gazeOrigin, direction: gazeDirection) {
                handleGazeTarget(hit.entity)
            } else {
                clearGazeTarget()
            }
        }
    }

    private func handleGazeTarget(_ entity: Entity) {
        if entity == gazedEntity {
            // Still gazing at same target
            if let startTime = gazeStartTime,
               Date().timeIntervalSince(startTime) >= dwellTime {
                // Dwell time reached, select target
                selectTarget(entity)
                clearGazeTarget()
            }
        } else {
            // New target
            gazedEntity = entity
            gazeStartTime = Date()
            highlightEntity(entity)
        }
    }

    // Gaze + pinch for activation
    func checkGazeAndPinch(isPinching: Bool) {
        if isPinching, let target = currentGazeTarget {
            activateTarget(target)
        }
    }
}
```

### 3.3 Voice Commands

```swift
class VoiceCommandController {
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?

    // Command vocabulary
    enum VoiceCommand: String, CaseIterable {
        case map = "show map"
        case inventory = "open inventory"
        case quests = "show quests"
        case guild = "open guild"
        case help = "help"

        // Combat
        case attack = "attack"
        case defend = "defend"
        case retreat = "retreat"
        case useSkillOne = "skill one"
        case useSkillTwo = "skill two"
        case useSkillThree = "skill three"

        // Social
        case party = "party"
        case trade = "trade"
        case friend = "add friend"
    }

    func startListening() {
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()

        guard let recognitionRequest = recognitionRequest else { return }

        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            guard let result = result else { return }

            let transcript = result.bestTranscription.formattedString.lowercased()

            // Match against commands
            for command in VoiceCommand.allCases {
                if transcript.contains(command.rawValue) {
                    self?.executeCommand(command)
                    break
                }
            }
        }
    }

    private func executeCommand(_ command: VoiceCommand) {
        switch command {
        case .attack:
            gameController.performBasicAttack()
        case .inventory:
            uiManager.showInventory()
        case .useSkillOne:
            gameController.useSkill(slot: 1)
        // Handle other commands...
        default:
            break
        }
    }
}
```

### 3.4 Game Controller Support

```swift
class GameControllerManager {
    private var controllers: [GCController] = []

    func setupControllers() {
        // Observe controller connections
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(controllerConnected),
            name: .GCControllerDidConnect,
            object: nil
        )

        // Configure for extended gamepad
        GCController.controllers().forEach { controller in
            if let extended = controller.extendedGamepad {
                configureExtendedGamepad(extended)
            }
        }
    }

    private func configureExtendedGamepad(_ gamepad: GCExtendedGamepad) {
        // Left stick: Movement
        gamepad.leftThumbstick.valueChangedHandler = { [weak self] stick, x, y in
            self?.handleMovement(x: x, y: y)
        }

        // Right stick: Camera/Look
        gamepad.rightThumbstick.valueChangedHandler = { [weak self] stick, x, y in
            self?.handleCameraRotation(x: x, y: y)
        }

        // Face buttons
        gamepad.buttonA.valueChangedHandler = { [weak self] button, value, pressed in
            if pressed {
                self?.performJump()
            }
        }

        gamepad.buttonB.valueChangedHandler = { [weak self] button, value, pressed in
            if pressed {
                self?.performDodge()
            }
        }

        gamepad.buttonX.valueChangedHandler = { [weak self] button, value, pressed in
            if pressed {
                self?.performInteraction()
            }
        }

        gamepad.buttonY.valueChangedHandler = { [weak self] button, value, pressed in
            if pressed {
                self?.performSpecialAbility()
            }
        }

        // Triggers
        gamepad.leftTrigger.valueChangedHandler = { [weak self] button, value, pressed in
            self?.handleLeftTrigger(value: value)
        }

        gamepad.rightTrigger.valueChangedHandler = { [weak self] button, value, pressed in
            self?.handleRightTrigger(value: value) // Basic attack
        }

        // Bumpers
        gamepad.leftShoulder.valueChangedHandler = { [weak self] button, value, pressed in
            if pressed {
                self?.cycleTargetPrevious()
            }
        }

        gamepad.rightShoulder.valueChangedHandler = { [weak self] button, value, pressed in
            if pressed {
                self?.cycleTargetNext()
            }
        }

        // D-Pad: Quick access
        gamepad.dpad.up.valueChangedHandler = { [weak self] button, value, pressed in
            if pressed {
                self?.useConsumable(slot: 1)
            }
        }
    }
}
```

---

## 4. Physics Specifications

### 4.1 Physics Engine Configuration

```swift
// RealityKit physics settings
struct PhysicsConfiguration {
    // Global physics settings
    static let gravity: SIMD3<Float> = [0, -9.81, 0] // m/s²
    static let timeStep: Float = 1.0 / 60.0 // 60Hz fixed timestep
    static let maxSubsteps: Int = 4

    // Collision layers (bit masks)
    enum CollisionLayer: UInt32 {
        case player = 0b0001
        case enemy = 0b0010
        case projectile = 0b0100
        case environment = 0b1000
        case trigger = 0b10000

        static let playerMask: UInt32 = CollisionLayer.enemy.rawValue |
                                         CollisionLayer.environment.rawValue |
                                         CollisionLayer.trigger.rawValue

        static let enemyMask: UInt32 = CollisionLayer.player.rawValue |
                                        CollisionLayer.projectile.rawValue |
                                        CollisionLayer.environment.rawValue

        static let projectileMask: UInt32 = CollisionLayer.enemy.rawValue |
                                             CollisionLayer.environment.rawValue
    }

    // Material properties
    static let defaultFriction: Float = 0.5
    static let defaultRestitution: Float = 0.3 // Bounciness

    // Performance settings
    static let maxActivePhysicsBodies: Int = 500
    static let sleepThreshold: Float = 0.1 // m/s
}
```

### 4.2 Collision Detection

```swift
class CollisionManager {
    // Collision callbacks
    func setupCollisionHandlers() {
        // Subscribe to collision events
        scene.subscribe(
            to: CollisionEvents.Began.self,
            on: nil
        ) { [weak self] event in
            self?.handleCollisionBegan(event)
        }

        scene.subscribe(
            to: CollisionEvents.Updated.self,
            on: nil
        ) { [weak self] event in
            self?.handleCollisionUpdated(event)
        }

        scene.subscribe(
            to: CollisionEvents.Ended.self,
            on: nil
        ) { [weak self] event in
            self?.handleCollisionEnded(event)
        }
    }

    private func handleCollisionBegan(_ event: CollisionEvents.Began) {
        let entityA = event.entityA
        let entityB = event.entityB

        // Player-Enemy collision
        if entityA.hasComponent(PlayerComponent.self) &&
           entityB.hasComponent(EnemyComponent.self) {
            handlePlayerEnemyCollision(player: entityA, enemy: entityB)
        }

        // Projectile-Target collision
        if let projectile = entityA.components[ProjectileComponent.self] {
            handleProjectileImpact(projectile: entityA, target: entityB)
        }

        // Trigger volumes
        if entityB.hasComponent(TriggerComponent.self) {
            handleTriggerEntered(entity: entityA, trigger: entityB)
        }
    }

    // Raycast for targeting
    func performRaycast(
        origin: SIMD3<Float>,
        direction: SIMD3<Float>,
        maxDistance: Float
    ) -> [CollisionCastHit] {
        return scene.raycast(
            origin: origin,
            direction: direction,
            length: maxDistance,
            query: .nearest,
            mask: .all,
            relativeTo: nil
        )
    }
}
```

### 4.3 Movement Physics

```swift
class CharacterPhysicsController {
    // Character controller settings
    struct CharacterSettings {
        var walkSpeed: Float = 1.5 // m/s
        var runSpeed: Float = 3.0 // m/s
        var jumpForce: Float = 5.0 // m/s
        var airControl: Float = 0.3 // Reduced control in air

        var capsuleHeight: Float = 1.8 // meters
        var capsuleRadius: Float = 0.3 // meters

        var stepHeight: Float = 0.3 // Can climb steps up to this height
        var slopeLimit: Float = 45.0 // degrees
    }

    let settings = CharacterSettings()
    private var velocity: SIMD3<Float> = .zero
    private var isGrounded: Bool = false

    func updateMovement(input: SIMD2<Float>, deltaTime: Float) {
        // Ground check
        isGrounded = checkGrounded()

        // Calculate desired velocity
        let speed = input.length() > 0.7 ? settings.runSpeed : settings.walkSpeed
        let moveDirection = SIMD3<Float>(input.x, 0, input.y)
        var targetVelocity = normalize(moveDirection) * speed

        // Apply air control
        let controlFactor = isGrounded ? 1.0 : settings.airControl

        // Smooth acceleration
        let acceleration: Float = 10.0 * controlFactor
        velocity.x = lerp(velocity.x, targetVelocity.x, acceleration * deltaTime)
        velocity.z = lerp(velocity.z, targetVelocity.z, acceleration * deltaTime)

        // Apply gravity
        if !isGrounded {
            velocity.y += PhysicsConfiguration.gravity.y * deltaTime
        } else {
            velocity.y = -0.1 // Small downward force to stay grounded
        }

        // Apply velocity to character
        let movement = velocity * deltaTime
        moveCharacter(by: movement)
    }

    func jump() {
        guard isGrounded else { return }
        velocity.y = settings.jumpForce
    }

    private func checkGrounded() -> Bool {
        // Raycast downward from character center
        let rayOrigin = characterPosition
        let rayDirection = SIMD3<Float>(0, -1, 0)
        let rayLength: Float = (settings.capsuleHeight / 2) + 0.1

        let hits = scene.raycast(
            origin: rayOrigin,
            direction: rayDirection,
            length: rayLength,
            query: .nearest,
            mask: .all
        )

        return !hits.isEmpty
    }
}
```

---

## 5. Rendering Requirements

### 5.1 Graphics Settings

```swift
struct GraphicsSettings {
    // Target specifications
    static let targetFrameRate: Int = 90 // Hz
    static let minimumFrameRate: Int = 60 // Hz

    // Resolution
    static let renderScale: Float = 1.0 // Can reduce for performance

    // Quality presets
    enum QualityPreset {
        case low
        case medium
        case high
        case ultra

        var shadowQuality: ShadowQuality {
            switch self {
            case .low: return .off
            case .medium: return .hard
            case .high: return .soft
            case .ultra: return .contactShadows
            }
        }

        var lodBias: Float {
            switch self {
            case .low: return 0.5
            case .medium: return 0.75
            case .high: return 1.0
            case .ultra: return 1.5
            }
        }

        var particleCount: Float {
            switch self {
            case .low: return 0.25
            case .medium: return 0.5
            case .high: return 1.0
            case .ultra: return 2.0
            }
        }
    }
}
```

### 5.2 Material System

```swift
// PBR materials
struct GameMaterial {
    var baseColor: UIColor
    var metallic: Float // 0-1
    var roughness: Float // 0-1
    var emissive: UIColor?
    var emissiveIntensity: Float?

    // Textures
    var albedoTexture: TextureResource?
    var normalTexture: TextureResource?
    var metallicRoughnessTexture: TextureResource?
    var occlusionTexture: TextureResource?
    var emissiveTexture: TextureResource?

    func toRealityKitMaterial() -> Material {
        var material = PhysicallyBasedMaterial()

        material.baseColor = .init(tint: baseColor, texture: albedoTexture)
        material.metallic = .init(floatLiteral: metallic)
        material.roughness = .init(floatLiteral: roughness)

        if let normal = normalTexture {
            material.normal = .init(texture: normal)
        }

        if let emissiveColor = emissive, let intensity = emissiveIntensity {
            material.emissiveColor = .init(color: emissiveColor)
            material.emissiveIntensity = intensity
        }

        return material
    }
}

// Shader graph support for custom effects
class CustomShaderManager {
    // Glowing outline for selected objects
    func createSelectionOutline(entity: Entity, color: UIColor) {
        // Use CustomMaterial with ShaderGraphMaterial
        var material = try? CustomMaterial(
            from: ShaderGraphMaterial(named: "SelectionOutline")
        )

        material?.custom.color = color
        material?.custom.thickness = 0.01

        if var model = entity.components[ModelComponent.self] {
            model.materials = [material!]
            entity.components[ModelComponent.self] = model
        }
    }
}
```

### 5.3 Visual Effects

```swift
class VFXManager {
    // Particle systems
    func createHitEffect(at position: SIMD3<Float>) -> Entity {
        let particles = Entity()

        // Configure particle emitter
        var particleEmitter = ParticleEmitterComponent()

        particleEmitter.mainEmitter.birthRate = 100
        particleEmitter.mainEmitter.lifeSpan = 0.5
        particleEmitter.mainEmitter.size = 0.01

        particleEmitter.mainEmitter.color = .evolving(
            start: .single(.yellow),
            end: .single(.red)
        )

        particleEmitter.mainEmitter.speed = 2.0
        particleEmitter.mainEmitter.spreadingAngle = Float.pi * 2

        // One-shot emission
        particleEmitter.isEmitting = true
        particleEmitter.burstCount = 50

        particles.components[ParticleEmitterComponent.self] = particleEmitter
        particles.position = position

        // Auto-remove after 1 second
        Task {
            try? await Task.sleep(for: .seconds(1))
            particles.removeFromParent()
        }

        return particles
    }

    // Screen-space effects
    func createDamageVignette() {
        // Post-processing effect when player takes damage
        // Apply red vignette overlay
    }
}
```

---

## 6. Multiplayer/Networking Specifications

### 6.1 Network Protocol

```swift
// Message framing
struct NetworkPacket: Codable {
    let messageType: MessageType
    let payload: Data
    let timestamp: UInt64
    let sequenceNumber: UInt64
    let reliability: ReliabilityMode

    enum MessageType: UInt8 {
        case playerUpdate = 0x01
        case entitySpawn = 0x02
        case entityUpdate = 0x03
        case entityDestroy = 0x04
        case combat = 0x05
        case chat = 0x06
        case worldEvent = 0x07
        case sync = 0x08
    }

    enum ReliabilityMode {
        case unreliable      // Fire and forget (movement updates)
        case reliable        // Guaranteed delivery (combat actions)
        case ordered         // Reliable + ordered (chat messages)
    }
}

// Connection parameters
struct NetworkConfig {
    static let serverURL = "wss://realitymmo.game/ws"
    static let heartbeatInterval: TimeInterval = 5.0
    static let connectionTimeout: TimeInterval = 10.0
    static let reconnectDelay: TimeInterval = 2.0
    static let maxReconnectAttempts = 5

    // Update rates
    static let playerUpdateRate = 20 // Hz (50ms)
    static let entityUpdateRate = 10 // Hz (100ms)

    // Compression
    static let compressionThreshold = 512 // bytes
}
```

### 6.2 Client-Side Prediction

```swift
class PredictionSystem {
    private var pendingInputs: [UInt64: PlayerInput] = [:]
    private var lastProcessedInput: UInt64 = 0

    func processInput(_ input: PlayerInput) {
        // Store input with sequence number
        input.sequenceNumber = nextSequenceNumber()
        pendingInputs[input.sequenceNumber] = input

        // Predict movement immediately
        applyInputLocally(input)

        // Send to server
        networkManager.send(input)
    }

    func handleServerReconciliation(_ update: ServerStateUpdate) {
        // Server confirmed state up to this sequence number
        let confirmedSequence = update.lastProcessedInput

        // Remove confirmed inputs
        pendingInputs = pendingInputs.filter { $0.key > confirmedSequence }

        // Check for misprediction
        if update.position != predictedPosition {
            // Rollback to server state
            playerPosition = update.position

            // Replay pending inputs
            for (_, input) in pendingInputs.sorted(by: { $0.key < $1.key }) {
                applyInputLocally(input)
            }
        }
    }
}
```

### 6.3 Entity Interpolation

```swift
class EntityInterpolationSystem {
    private struct SnapshotBuffer {
        var snapshots: [(timestamp: TimeInterval, state: EntityState)] = []
        let bufferTime: TimeInterval = 0.1 // 100ms interpolation delay
    }

    private var entityBuffers: [UUID: SnapshotBuffer] = [:]

    func addSnapshot(entityID: UUID, state: EntityState, timestamp: TimeInterval) {
        var buffer = entityBuffers[entityID, default: SnapshotBuffer()]
        buffer.snapshots.append((timestamp, state))

        // Keep last 10 snapshots
        if buffer.snapshots.count > 10 {
            buffer.snapshots.removeFirst()
        }

        entityBuffers[entityID] = buffer
    }

    func updateEntities(currentTime: TimeInterval) {
        for (entityID, buffer) in entityBuffers {
            guard let entity = getEntity(entityID) else { continue }

            // Interpolate to time slightly in the past
            let renderTime = currentTime - buffer.bufferTime

            if let interpolated = interpolateState(buffer: buffer, time: renderTime) {
                entity.position = interpolated.position
                entity.orientation = interpolated.orientation
            }
        }
    }

    private func interpolateState(
        buffer: SnapshotBuffer,
        time: TimeInterval
    ) -> EntityState? {
        // Find surrounding snapshots
        var before: (TimeInterval, EntityState)?
        var after: (TimeInterval, EntityState)?

        for snapshot in buffer.snapshots {
            if snapshot.timestamp <= time {
                before = snapshot
            }
            if snapshot.timestamp >= time && after == nil {
                after = snapshot
            }
        }

        guard let before = before, let after = after else { return nil }

        // Linear interpolation
        let duration = after.0 - before.0
        guard duration > 0 else { return before.1 }

        let t = Float((time - before.0) / duration)

        return EntityState(
            position: mix(before.1.position, after.1.position, t: t),
            orientation: simd_slerp(before.1.orientation, after.1.orientation, t)
        )
    }
}
```

### 6.4 Lag Compensation

```swift
class LagCompensationSystem {
    // Store historical world states
    private struct WorldSnapshot {
        let timestamp: TimeInterval
        let entities: [UUID: EntityState]
    }

    private var historyBuffer: [WorldSnapshot] = []
    private let maxHistoryDuration: TimeInterval = 1.0

    func addSnapshot(timestamp: TimeInterval, entities: [UUID: EntityState]) {
        let snapshot = WorldSnapshot(timestamp: timestamp, entities: entities)
        historyBuffer.append(snapshot)

        // Remove old snapshots
        let cutoff = timestamp - maxHistoryDuration
        historyBuffer.removeAll { $0.timestamp < cutoff }
    }

    func validateHit(
        shooter: UUID,
        target: UUID,
        clientTime: TimeInterval,
        ping: TimeInterval
    ) -> Bool {
        // Rewind to when shooter saw the target
        let rewindTime = clientTime - (ping / 2)

        guard let snapshot = findSnapshot(at: rewindTime),
              let targetState = snapshot.entities[target] else {
            return false
        }

        // Check if hit was valid at that time
        return checkHitValidation(targetState: targetState)
    }
}
```

---

## 7. Performance Budgets

### 7.1 Frame Rate Targets

```yaml
Frame Rate:
  Target: 90 FPS (11.1ms per frame)
  Minimum: 60 FPS (16.7ms per frame)

  Budget Breakdown (90 FPS):
    Game Logic: 2.5ms
    Physics: 1.5ms
    Rendering: 5.0ms
    Networking: 1.0ms
    Audio: 0.5ms
    Other: 0.6ms
```

### 7.2 Memory Budget

```yaml
Memory Usage:
  Total Budget: 4 GB

  Breakdown:
    Game Code: 200 MB
    RealityKit/ARKit: 800 MB
    3D Assets (loaded): 1 GB
    Textures: 1.5 GB
    Audio: 200 MB
    Network Buffers: 50 MB
    UI: 100 MB
    Other: 150 MB

  Streaming:
    Asset Cache: 500 MB LRU cache
    Preload Radius: 1 km
    Unload Distance: 2 km
```

### 7.3 Battery Life

```yaml
Battery Target:
  Gameplay Duration: 2.5 hours continuous

  Power Management:
    - Reduce update rate when stationary
    - Lower LOD when battery < 20%
    - Reduce particle effects when battery < 10%
    - Disable non-essential features when < 5%

  Thermal Management:
    - Monitor CPU/GPU temperature
    - Reduce quality if > 40°C
    - Force cooldown if > 45°C
```

### 7.4 Network Budget

```yaml
Bandwidth:
  Per Player Upload: 10 KB/s average, 50 KB/s peak
  Per Player Download: 50 KB/s average, 200 KB/s peak

  Packet Budget:
    Player Updates: 20 packets/second (200 bytes each)
    Entity Updates: 10 packets/second (variable size)
    Chat: As needed (compressed)

  Latency Targets:
    Player Actions: < 100ms round-trip
    Combat: < 50ms server processing
    Chat: < 200ms delivery
```

---

## 8. Testing Requirements

### 8.1 Unit Testing

```swift
// XCTest framework
import XCTest
@testable import RealityMMO

class CombatSystemTests: XCTestCase {
    var combatSystem: CombatSystem!

    override func setUp() {
        super.setUp()
        combatSystem = CombatSystem()
    }

    func testDamageCalculation() {
        let attacker = createTestEntity(attackPower: 100)
        let target = createTestEntity(defense: 50)
        let ability = Ability(baseDamage: 50, scaling: 1.0)

        let result = combatSystem.calculateDamage(
            attacker: attacker,
            target: target,
            ability: ability
        )

        XCTAssertGreaterThan(result.damage, 0)
        XCTAssertLessThanOrEqual(result.damage, 200)
    }

    func testCooldownSystem() {
        let playerID = UUID()
        let ability = Ability(cooldown: 5.0)

        XCTAssertTrue(combatSystem.canUseAbility(player: playerID, ability: ability))

        combatSystem.useAbility(player: playerID, ability: ability)

        XCTAssertFalse(combatSystem.canUseAbility(player: playerID, ability: ability))
    }
}

// Code coverage target: 80%+
```

### 8.2 Integration Testing

```swift
class MultiplayerIntegrationTests: XCTestCase {
    func testPlayerSync() async throws {
        // Start test server
        let server = TestGameServer()
        try await server.start()

        // Connect two clients
        let client1 = TestClient()
        let client2 = TestClient()

        try await client1.connect(to: server)
        try await client2.connect(to: server)

        // Move client1
        await client1.move(to: SIMD3<Float>(1, 0, 1))

        // Wait for sync
        try await Task.sleep(for: .milliseconds(100))

        // Verify client2 sees client1's position
        let visiblePlayers = await client2.getNearbyPlayers()
        XCTAssertTrue(visiblePlayers.contains(client1.playerID))

        await server.shutdown()
    }
}
```

### 8.3 Performance Testing

```swift
class PerformanceTests: XCTestCase {
    func testFrameRate() {
        let performance = XCTMetric.applicationLaunch

        measure(metrics: [XCTClockMetric(), XCTMemoryMetric()]) {
            // Simulate game loop
            for _ in 0..<1000 {
                gameCoordinator.update(deltaTime: 1.0/90.0)
            }
        }

        // Assert meets performance budget
    }

    func testMemoryLeaks() {
        measure(metrics: [XCTMemoryMetric()]) {
            // Create and destroy many entities
            for _ in 0..<10000 {
                let entity = createEntity()
                entityManager.add(entity)
                entityManager.remove(entity)
            }
        }
    }
}
```

### 8.4 Multiplayer Testing Requirements

```yaml
Concurrent Users Test:
  - Test with 10, 100, 1000, 10000 concurrent users
  - Monitor server CPU, memory, network
  - Measure response times
  - Check for crashes/errors

Location-Based Test:
  - Simulate users across globe
  - Test geolocation queries
  - Verify content streaming
  - Test regional servers

Combat Stress Test:
  - 100v100 guild battle simulation
  - Validate hit detection
  - Check lag compensation
  - Monitor frame rate client-side

Network Conditions:
  - Test on 4G, 5G, WiFi
  - Simulate packet loss (0%, 1%, 5%, 10%)
  - Simulate latency (50ms, 100ms, 200ms, 500ms)
  - Test reconnection scenarios
```

---

## 9. API Specifications

### 9.1 REST API

```yaml
Base URL: https://api.realitymmo.game/v1

Authentication:
  Type: Bearer Token (JWT)
  Header: Authorization: Bearer <token>

Endpoints:

# Authentication
POST /auth/register
  Body: { email, password, username }
  Response: { userId, token, refreshToken }

POST /auth/login
  Body: { email, password }
  Response: { userId, token, refreshToken }

# Player
GET /players/:id
  Response: Player object

PUT /players/:id
  Body: Partial player updates
  Response: Updated player

GET /players/:id/inventory
  Response: { items: [Item] }

# Guilds
GET /guilds/:id
  Response: Guild object

POST /guilds
  Body: { name, tag, description }
  Response: Created guild

POST /guilds/:id/join
  Response: { success: boolean }

# World Content
GET /world/content
  Query: ?lat=<lat>&lon=<lon>&radius=<meters>
  Response: { content: [WorldContent] }

POST /world/content
  Body: WorldContent object
  Response: Created content

# Quests
GET /quests/available
  Query: ?playerId=<id>&location=<lat,lon>
  Response: { quests: [Quest] }

POST /quests/:id/accept
  Body: { playerId }
  Response: { success: boolean }

# Marketplace
GET /marketplace/listings
  Query: ?item=<name>&rarity=<rarity>
  Response: { listings: [Listing] }

POST /marketplace/list
  Body: Listing object
  Response: Created listing

Rate Limiting:
  - 100 requests per minute per user
  - 1000 requests per minute per IP
```

### 9.2 WebSocket API

```javascript
// Connection
const socket = io('wss://realtime.realitymmo.game', {
    auth: { token: jwtToken },
    transports: ['websocket']
});

// Events from client
socket.emit('player:update', {
    position: [x, y, z],
    rotation: [x, y, z, w],
    location: { lat, lon },
    timestamp: Date.now()
});

socket.emit('combat:action', {
    abilityId: uuid,
    targetId: uuid,
    position: [x, y, z],
    timestamp: Date.now()
});

// Events from server
socket.on('entity:spawn', (data) => {
    // { entityId, type, position, components }
});

socket.on('entity:update', (data) => {
    // { entityId, position, rotation, components }
});

socket.on('entity:destroy', (data) => {
    // { entityId }
});

socket.on('world:event', (data) => {
    // { eventType, location, data }
});
```

---

## 10. Security Specifications

### 10.1 Authentication

```swift
class SecurityManager {
    // JWT token management
    func authenticateUser(email: String, password: String) async throws -> AuthToken {
        // Hash password with bcrypt
        let hashedPassword = BCrypt.hash(password, cost: 12)

        // Call auth service
        let response = try await authAPI.login(email: email, passwordHash: hashedPassword)

        // Store token securely in Keychain
        try keychainManager.store(response.token, for: "auth_token")
        try keychainManager.store(response.refreshToken, for: "refresh_token")

        return response.token
    }

    // Token refresh
    func refreshToken() async throws -> AuthToken {
        guard let refreshToken = try? keychainManager.retrieve("refresh_token") else {
            throw AuthError.noRefreshToken
        }

        let response = try await authAPI.refresh(token: refreshToken)
        try keychainManager.store(response.token, for: "auth_token")

        return response.token
    }
}
```

### 10.2 Data Encryption

```yaml
In Transit:
  Protocol: TLS 1.3
  Cipher Suites: AES-256-GCM, ChaCha20-Poly1305
  Certificate: Valid SSL certificate from trusted CA

At Rest:
  Database: AES-256 encryption for sensitive fields
  File Storage: S3 server-side encryption (SSE-S3)
  Local Storage: iOS Data Protection API (Complete until first user authentication)

Location Privacy:
  - Fuzzing: ±50m random offset
  - Aggregation: Never store exact coordinates
  - Opt-out: Privacy zones (home, work)
```

### 10.3 Input Validation

```swift
class ValidationManager {
    // Prevent SQL injection
    func sanitizeInput(_ input: String) -> String {
        // Use parameterized queries (not string interpolation)
        return input
    }

    // Prevent XSS
    func sanitizeHTML(_ input: String) -> String {
        let allowed = CharacterSet.alphanumerics.union(.whitespaces)
        return input.components(separatedBy: allowed.inverted).joined()
    }

    // Rate limiting
    private var requestCounts: [UUID: (count: Int, resetTime: Date)] = [:]

    func checkRateLimit(user: UUID) -> Bool {
        let now = Date()

        if let existing = requestCounts[user] {
            if now > existing.resetTime {
                // Reset window
                requestCounts[user] = (count: 1, resetTime: now.addingTimeInterval(60))
                return true
            } else if existing.count < 100 {
                // Increment count
                requestCounts[user] = (count: existing.count + 1, resetTime: existing.resetTime)
                return true
            } else {
                // Rate limited
                return false
            }
        } else {
            // First request
            requestCounts[user] = (count: 1, resetTime: now.addingTimeInterval(60))
            return true
        }
    }
}
```

---

## 11. Deployment Architecture

### 11.1 Infrastructure

```yaml
Cloud Provider: Multi-cloud (AWS primary, Azure backup)

Regions:
  - us-east-1 (North America)
  - eu-west-1 (Europe)
  - ap-southeast-1 (Asia Pacific)

Kubernetes Cluster:
  Node Groups:
    - api-nodes: 10 x c5.2xlarge
    - game-nodes: 20 x c5.4xlarge (CPU-intensive)
    - db-nodes: 5 x r5.2xlarge (memory-optimized)

  Auto-scaling:
    Min: 50% capacity
    Max: 200% capacity
    Metric: CPU > 70% or custom (concurrent players)

Load Balancing:
  Type: Application Load Balancer
  Health Checks: /health endpoint every 30s
  SSL Termination: Yes

CDN:
  Provider: CloudFlare
  Caching: Static assets (models, textures, audio)
  Edge locations: Global
```

### 11.2 CI/CD Pipeline

```yaml
Source Control: GitHub

Build Pipeline (GitHub Actions):
  on: [push, pull_request]

  steps:
    - Checkout code
    - Install dependencies
    - Run unit tests
    - Run integration tests
    - Build app (xcodebuild)
    - Archive for distribution
    - Upload to TestFlight (beta)
    - Deploy to App Store (production)

Server Deployment:
  on: [merge to main]

  steps:
    - Run tests
    - Build Docker images
    - Push to container registry
    - Update Kubernetes manifests
    - Rolling deployment (10% at a time)
    - Health checks
    - Rollback if failed

Environments:
  - Development: Auto-deploy from develop branch
  - Staging: Manual approval
  - Production: Manual approval + verification
```

---

## Conclusion

This technical specification provides comprehensive implementation details for Reality MMO Layer, covering all aspects from game mechanics to deployment infrastructure. The specification ensures:

- **Performance**: 60-90 FPS gameplay with efficient resource usage
- **Scalability**: Supports millions of concurrent players globally
- **Security**: Robust authentication, encryption, and anti-cheat systems
- **Quality**: Comprehensive testing at unit, integration, and system levels
- **Maintainability**: Clear APIs and well-documented systems

All specifications are designed to support iterative development, starting with P0 features and expanding through post-launch updates.

---

**Next Documents:**
1. DESIGN.md - Game design and UI/UX specifications
2. IMPLEMENTATION_PLAN.md - Detailed development roadmap
