# Troubleshooting Guide - Tactical Team Shooters

Common issues and solutions for Tactical Team Shooters on Apple Vision Pro.

## Table of Contents

- [Build & Compilation Issues](#build--compilation-issues)
- [Runtime Errors](#runtime-errors)
- [Performance Issues](#performance-issues)
- [Networking Issues](#networking-issues)
- [Vision Pro Specific Issues](#vision-pro-specific-issues)
- [Game Logic Issues](#game-logic-issues)

---

## Build & Compilation Issues

### Issue: "No such module 'RealityKit'"

**Symptoms**: Build fails with module not found error

**Cause**: Missing visionOS SDK or incorrect deployment target

**Solution**:
```bash
# Check Xcode version
xcodebuild -version  # Should be 16.0+

# Verify visionOS SDK
xcodebuild -showsdks | grep visionOS

# Update deployment target
# In Package.swift:
platforms: [.visionOS(.v2)]
```

---

### Issue: Swift 6 Concurrency Errors

**Symptoms**: "Actor-isolated property cannot be referenced" errors

**Cause**: Strict concurrency checking in Swift 6

**Solution**:
```swift
// ❌ Wrong: Accessing actor property from non-isolated context
func update() {
    print(playerManager.players)  // Error
}

// ✅ Correct: Use await
func update() async {
    print(await playerManager.players)
}

// Or mark function as isolated
@MainActor
func update() {
    print(playerManager.players)
}
```

---

### Issue: "Command SwiftCompile failed"

**Symptoms**: Generic Swift compiler crash

**Solutions**:
1. **Clean build folder**:
   ```bash
   # Xcode
   Product → Clean Build Folder (⇧⌘K)

   # Command line
   rm -rf .build
   swift build
   ```

2. **Check for syntax errors**:
   ```bash
   # Build with verbose output
   swift build -v
   ```

3. **Reduce optimization**:
   ```swift
   // Build Settings
   SWIFT_OPTIMIZATION_LEVEL = -Onone
   ```

---

## Runtime Errors

### Issue: App Crashes on Launch

**Symptoms**: Immediate crash after launch

**Diagnostics**:
```bash
# View crash logs
# On device: Settings → Privacy → Analytics → Analytics Data
# In Xcode: Window → Devices and Simulators → View Device Logs
```

**Common Causes**:

1. **Missing Info.plist keys**:
   ```xml
   <!-- Required for ARKit -->
   <key>NSCameraUsageDescription</key>
   <string>Required for spatial mapping</string>

   <!-- Required for multiplayer -->
   <key>NSLocalNetworkUsageDescription</key>
   <string>Required for multiplayer gaming</string>
   ```

2. **Force unwrapping nil**:
   ```swift
   // ❌ Crashes if nil
   let player = players[id]!

   // ✅ Safe unwrapping
   guard let player = players[id] else {
       return
   }
   ```

---

### Issue: "Player not found" Error

**Symptoms**: `GameError.playerNotFound` thrown

**Cause**: Attempting to access removed or non-existent player

**Solution**:
```swift
// Always check existence
if let player = players[playerId] {
    // Safe to use player
} else {
    print("Player \(playerId) not found")
}

// Or use throws
func getPlayer(_ id: UUID) throws -> Player {
    guard let player = players[id] else {
        throw GameError.playerNotFound
    }
    return player
}
```

---

### Issue: "Team is full" Error

**Symptoms**: Cannot add player to team

**Cause**: Attempting to add 6th player to 5-player team

**Solution**:
```swift
// Check before adding
if !team.isFullTeam {
    try team.addPlayer(player)
} else {
    print("Team is full (\(team.players.count)/5)")
}
```

---

## Performance Issues

### Issue: Low Frame Rate (< 90 FPS)

**Symptoms**: Choppy gameplay, motion sickness

**Diagnostics**:
```swift
// Add FPS counter
class FPSCounter {
    private var lastTime = CACurrentMediaTime()
    private var frameCount = 0

    func update() {
        frameCount += 1
        let currentTime = CACurrentMediaTime()

        if currentTime - lastTime >= 1.0 {
            print("FPS: \(frameCount)")
            frameCount = 0
            lastTime = currentTime
        }
    }
}
```

**Common Causes**:

1. **Too many draw calls**:
   ```swift
   // Profile draw calls
   print("Draw calls: \(renderer.drawCallCount)")

   // Solution: Use instancing and batching
   ```

2. **Unoptimized physics**:
   ```swift
   // Check physics entity count
   print("Physics entities: \(physicsWorld.entityCount)")

   // Solution: Use spatial partitioning
   ```

3. **Memory pressure**:
   ```bash
   # Check memory in Instruments
   # Reduce texture sizes
   # Use texture compression
   ```

**Solutions**: See [PERFORMANCE_OPTIMIZATION.md](PERFORMANCE_OPTIMIZATION.md)

---

### Issue: High Latency

**Symptoms**: Input lag, delayed actions

**Diagnostics**:
```swift
func measureInputLatency() {
    let inputTime = CACurrentMediaTime()

    // Perform action
    performAction()

    // Measure response time
    let responseTime = CACurrentMediaTime() - inputTime
    print("Input latency: \(responseTime * 1000)ms")
}
```

**Target**: < 10ms input latency

**Solutions**:
- Process input on high-priority queue
- Reduce work in main game loop
- Profile with Instruments

---

### Issue: Memory Warnings

**Symptoms**: "Memory warning" log messages, eventual crash

**Diagnostics**:
```swift
// Monitor memory
func getMemoryUsage() -> UInt64 {
    var info = mach_task_basic_info()
    var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4

    let result = withUnsafeMutablePointer(to: &info) {
        $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
            task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
        }
    }

    return info.resident_size
}

// Log memory usage
print("Memory: \(getMemoryUsage() / 1024 / 1024) MB")
```

**Solutions**:
```swift
// 1. Release unused resources
textureCache.clear()
audioCache.clear()

// 2. Use texture compression
// ASTC, BC7 formats

// 3. Implement texture streaming
loadTexture(resolution: distance < 10 ? .high : .low)

// 4. Reduce object pooling sizes
bulletPool.trimToSize(50)
```

---

## Networking Issues

### Issue: "Connection failed" Error

**Symptoms**: Cannot connect to multiplayer session

**Diagnostics**:
```swift
func diagnoseConnection() {
    print("Network reachability: \(networkMonitor.isReachable)")
    print("Available peers: \(mcBrowser.foundPeers.count)")
    print("Session state: \(mcSession.state)")
}
```

**Solutions**:

1. **Check network permissions**:
   ```xml
   <!-- Info.plist -->
   <key>NSLocalNetworkUsageDescription</key>
   <string>Required for multiplayer</string>
   ```

2. **Verify both devices on same network**

3. **Restart MultipeerConnectivity**:
   ```swift
   mcAdvertiser.stopAdvertisingPeer()
   mcBrowser.stopBrowsingForPeers()

   // Wait 1 second
   try await Task.sleep(nanoseconds: 1_000_000_000)

   mcAdvertiser.startAdvertisingPeer()
   mcBrowser.startBrowsingForPeers()
   ```

---

### Issue: High Ping / Network Lag

**Symptoms**: Players teleporting, delayed actions

**Diagnostics**:
```swift
func measureLatency() async -> TimeInterval {
    let start = CACurrentMediaTime()
    try? await networkManager.ping()
    return CACurrentMediaTime() - start
}

let latency = await measureLatency()
print("Latency: \(latency * 1000)ms")
```

**Target**: < 50ms latency

**Solutions**:
- Use unreliable messaging for position updates
- Implement client-side prediction
- Reduce update frequency for distant players
- Check network quality (WiFi vs cellular)

---

### Issue: "Packet loss detected"

**Symptoms**: Rubber-banding, missed inputs

**Diagnostics**:
```swift
class PacketLossMonitor {
    private var sent = 0
    private var received = 0

    var packetLoss: Double {
        Double(sent - received) / Double(sent)
    }
}

print("Packet loss: \(monitor.packetLoss * 100)%")
```

**Solutions**:
- Switch to more reliable network
- Implement message acknowledgment
- Use redundant transmission for critical data

---

## Vision Pro Specific Issues

### Issue: Hand Tracking Not Working

**Symptoms**: Hand gestures not recognized

**Diagnostics**:
```swift
// Check hand tracking state
if let handTracking = arSession.currentFrame?.handAnchors {
    print("Hands detected: \(handTracking.count)")
} else {
    print("Hand tracking unavailable")
}
```

**Solutions**:

1. **Check permissions**:
   ```xml
   <key>NSHandsTrackingUsageDescription</key>
   <string>Required for gesture controls</string>
   ```

2. **Verify hand visibility**:
   - Hands must be in front of Vision Pro
   - Adequate lighting required
   - No gloves or obstructions

3. **Recalibrate**:
   - Settings → Accessibility → Hand Tracking → Recalibrate

---

### Issue: ARKit Session Interruption

**Symptoms**: "ARSession interrupted" message

**Causes**:
- Camera covered
- Low light conditions
- Excessive movement
- System resource constraints

**Solution**:
```swift
func sessionWasInterrupted(_ session: ARSession) {
    // Pause game
    gameState.transition(to: .paused)

    // Show message to user
    showAlert("AR session interrupted. Please ensure adequate lighting and camera visibility.")
}

func sessionInterruptionEnded(_ session: ARSession) {
    // Resume game
    gameState.transition(to: .inGame)
}
```

---

### Issue: Room Scanning Fails

**Symptoms**: Cannot generate room mesh

**Solutions**:
1. **Ensure adequate lighting**
2. **Move slowly** during scanning
3. **Cover entire room** - look at all walls
4. **Clear surfaces** - remove reflective/transparent objects

```swift
func improveRoomScanning() {
    // Increase confidence threshold
    arSession.configuration.planeDetection = .all

    // Enable scene reconstruction
    let config = ARWorldTrackingConfiguration()
    config.sceneReconstruction = .meshWithClassification
    arSession.run(config)
}
```

---

### Issue: Eye Tracking Inaccurate

**Symptoms**: Gaze-based aiming missing targets

**Solutions**:
1. **Recalibrate eye tracking**:
   - Settings → Accessibility → Eye Tracking → Recalibrate

2. **Adjust for glasses**:
   - Settings → Vision Pro → Eye Tracking → Wearing Glasses

3. **Implement smoothing**:
   ```swift
   class GazeSmoother {
       private var history: [SIMD3<Float>] = []
       private let windowSize = 5

       func smooth(_ gazePosition: SIMD3<Float>) -> SIMD3<Float> {
           history.append(gazePosition)
           if history.count > windowSize {
               history.removeFirst()
           }

           return history.reduce(SIMD3<Float>.zero, +) / Float(history.count)
       }
   }
   ```

---

### Issue: Spatial Audio Not Working

**Symptoms**: No 3D positional audio

**Diagnostics**:
```swift
// Check spatial audio support
if AVAudioSession.sharedInstance().currentRoute.outputs.first?.portType == .headphones {
    print("Spatial audio supported")
} else {
    print("Spatial audio not available")
}
```

**Solutions**:
```swift
// Configure audio session
let session = AVAudioSession.sharedInstance()
try session.setCategory(.ambient, mode: .spokenAudio)
try session.setActive(true)

// Enable spatial audio
audioSource.spatialBlend = 1.0  // Fully spatial
```

---

## Game Logic Issues

### Issue: Weapon Not Firing

**Symptoms**: No bullets spawned on shoot action

**Diagnostics**:
```swift
func debugWeaponFiring() {
    print("Ammo: \(currentWeapon.currentAmmo)")
    print("Can fire: \(canFire)")
    print("Time since last shot: \(timeSinceLastShot)")
    print("Fire rate: \(currentWeapon.stats.fireRate)")
}
```

**Common Causes**:

1. **No ammo**:
   ```swift
   guard currentWeapon.currentAmmo > 0 else {
       playEmptySound()
       return
   }
   ```

2. **Fire rate limit**:
   ```swift
   let fireInterval = 60.0 / currentWeapon.stats.fireRate
   guard timeSinceLastShot >= fireInterval else {
       return  // Too soon
   }
   ```

---

### Issue: Hit Detection Not Working

**Symptoms**: Bullets passing through players

**Diagnostics**:
```swift
func debugHitDetection() {
    print("Ray origin: \(ray.origin)")
    print("Ray direction: \(ray.direction)")
    print("Target position: \(target.position)")
    print("Hit: \(rayIntersects)")
}
```

**Solutions**:

1. **Check collision layers**:
   ```swift
   // Ensure bullet and player on correct layers
   bullet.collisionFilter.mask = .player
   player.collisionFilter.group = .player
   ```

2. **Verify hitbox size**:
   ```swift
   // Visualize hitbox for debugging
   let debugBox = ModelEntity(mesh: .generateBox(size: player.hitboxSize))
   player.addChild(debugBox)
   ```

3. **Implement lag compensation**:
   ```swift
   // Rewind player positions for hit detection
   let rewoundPosition = lagCompensation.rewindTo(timestamp: input.timestamp)
   ```

---

### Issue: Player Falling Through Floor

**Symptoms**: Player clips through ground

**Solutions**:

1. **Check collision shapes**:
   ```swift
   // Ensure floor has collision
   floor.components[CollisionComponent.self] = CollisionComponent(
       shapes: [.generateBox(size: floor.size)],
       isStatic: true
   )
   ```

2. **Verify physics material**:
   ```swift
   // Reduce bounciness
   let material = PhysicsMaterialResource.generate(
       restitution: 0.0,
       friction: 0.5
   )
   ```

---

## Getting Help

### Before Asking for Help

1. ✅ Check this troubleshooting guide
2. ✅ Review [FAQ.md](FAQ.md)
3. ✅ Search existing GitHub issues
4. ✅ Check Apple Developer Forums
5. ✅ Review relevant documentation

### Reporting Issues

When reporting an issue, include:

```markdown
**Description**: Brief description of issue

**Environment**:
- visionOS Version: X.X
- Xcode Version: X.X
- Device: Vision Pro / Simulator

**Steps to Reproduce**:
1. Step 1
2. Step 2
3. Step 3

**Expected Behavior**: What should happen

**Actual Behavior**: What actually happens

**Logs/Screenshots**: Attach relevant logs or screenshots

**Code Snippet** (if applicable):
```swift
// Relevant code
```
```

### Resources

- **GitHub Issues**: https://github.com/your-repo/issues
- **Apple Developer Forums**: https://developer.apple.com/forums/
- **Vision Pro Documentation**: https://developer.apple.com/visionos/
- **Stack Overflow**: Tag with `visionos` and `swift`

---

## Debug Tools

### Enable Verbose Logging

```swift
// Enable debug logging
#if DEBUG
let logLevel: LogLevel = .verbose
#else
let logLevel: LogLevel = .error
#endif

func log(_ message: String, level: LogLevel = .info) {
    if level.rawValue >= logLevel.rawValue {
        print("[\(level)] \(message)")
    }
}
```

### Visual Debugging

```swift
// Visualize collision shapes
#if DEBUG
func enablePhysicsDebug() {
    arView.debugOptions.insert(.showPhysics)
    arView.debugOptions.insert(.showAnchorGeometry)
}
#endif
```

### Network Simulation

```swift
// Simulate poor network conditions
let networkSimulator = NetworkSimulator()
networkSimulator.simulatedLatency = 0.1  // 100ms
networkSimulator.simulatedPacketLoss = 0.05  // 5%
```

---

For additional support, see [CONTRIBUTING.md](CONTRIBUTING.md) or open an issue on GitHub.
