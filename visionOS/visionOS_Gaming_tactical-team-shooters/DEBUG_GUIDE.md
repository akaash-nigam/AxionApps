# Debug Guide - Tactical Team Shooters

Comprehensive debugging guide for visionOS development.

## Xcode Debugging Tools

### Breakpoints

```swift
// Set breakpoint on specific line
// Click gutter in Xcode or press ⌘\

// Conditional breakpoint
// Right-click breakpoint → Edit Breakpoint
// Condition: player.health < 20

// Symbolic breakpoint
// Debug → Breakpoints → Create Symbolic Breakpoint
// Symbol: PlayerDied
```

### LLDB Commands

```lldb
# Print variable
(lldb) po player
(lldb) p player.health

# Continue execution
(lldb) c

# Step over
(lldb) n

# Step into
(lldb) s

# Print backtrace
(lldb) bt

# List all breakpoints
(lldb) br list

# Delete breakpoint
(lldb) br delete 1
```

### Debug Console

```swift
// Print to console
print("Player health: \(player.health)")

// Debug-only logging
#if DEBUG
print("Debug info: \(debugData)")
#endif
```

## RealityKit Debugging

### Visual Debug Options

```swift
#if DEBUG
// Enable physics visualization
arView.debugOptions.insert(.showPhysics)

// Show anchor origins
arView.debugOptions.insert(.showAnchorOrigins)

// Show anchor geometry
arView.debugOptions.insert(.showAnchorGeometry)

// Show world origin
arView.debugOptions.insert(.showWorldOrigin)

// Show feature points
arView.debugOptions.insert(.showFeaturePoints)
#endif
```

### Entity Inspection

```swift
func debugEntity(_ entity: Entity) {
    print("Entity: \(entity.name)")
    print("Position: \(entity.position)")
    print("Rotation: \(entity.orientation)")
    print("Components: \(entity.components)")
    print("Children: \(entity.children.count)")
}
```

## Network Debugging

### Network Monitor

```swift
class NetworkDebugger {
    func logMessage(_ data: Data, direction: Direction) {
        #if DEBUG
        let size = data.count
        let timestamp = Date()
        print("[\(timestamp)] \(direction.rawValue): \(size) bytes")

        if let json = try? JSONSerialization.jsonObject(with: data) {
            print(json)
        }
        #endif
    }
}

enum Direction: String {
    case sent = "→"
    case received = "←"
}
```

### Latency Measurement

```swift
func measureLatency() async {
    let start = CACurrentMediaTime()
    try? await networkManager.ping()
    let latency = CACurrentMediaTime() - start
    print("Latency: \(latency * 1000)ms")
}
```

## Performance Profiling

### Instruments

```bash
# Profile with Instruments
# Xcode → Product → Profile (⌘I)

# Key instruments:
# - Time Profiler: CPU usage
# - Allocations: Memory allocations
# - Leaks: Memory leaks
# - Core Animation: Rendering performance
# - Network: Network activity
```

### Custom Signposts

```swift
import os.signpost

let log = OSLog(subsystem: "com.tacticalsquad", category: .pointsOfInterest)

func updatePhysics() {
    os_signpost(.begin, log: log, name: "Physics Update")
    // Physics code
    os_signpost(.end, log: log, name: "Physics Update")
}
```

### FPS Counter

```swift
class FPSCounter {
    private var lastTime = CACurrentMediaTime()
    private var frameCount = 0
    private var fps: Double = 0

    func update() {
        frameCount += 1
        let currentTime = CACurrentMediaTime()

        if currentTime - lastTime >= 1.0 {
            fps = Double(frameCount) / (currentTime - lastTime)
            print("FPS: \(Int(fps))")
            frameCount = 0
            lastTime = currentTime
        }
    }
}
```

## Memory Debugging

### Detect Leaks

```bash
# Run with Memory Graph Debugger
# Debug → Debug Workflow → View Memory Graph (⌘⇧M)
```

### Check Retain Cycles

```swift
// Use weak self in closures
closure = { [weak self] in
    self?.doSomething()
}

// Debug retain cycle
deinit {
    print("\(type(of: self)) deallocated")
}
```

### Memory Usage

```swift
func printMemoryUsage() {
    var info = mach_task_basic_info()
    var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4

    let result = withUnsafeMutablePointer(to: &info) {
        $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
            task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
        }
    }

    guard result == KERN_SUCCESS else { return }
    let usedMB = Double(info.resident_size) / 1024 / 1024
    print("Memory: \(usedMB) MB")
}
```

## Common Issues & Solutions

### Simulator vs Device

```swift
#if targetEnvironment(simulator)
// Simulator-specific code
print("Running in simulator")
#else
// Device-specific code
print("Running on device")
#endif
```

### Thread Safety

```swift
// Ensure main thread for UI updates
@MainActor
func updateUI() {
    // UI code
}

// Or
DispatchQueue.main.async {
    // UI updates
}
```

### Asset Loading

```swift
func loadAsset() {
    #if DEBUG
    guard let url = Bundle.main.url(forResource: "model", withExtension: "usdz") else {
        fatalError("Asset not found")
    }
    #else
    guard let url = Bundle.main.url(forResource: "model", withExtension: "usdz") else {
        print("Asset not found")
        return
    }
    #endif
}
```

## Logging Best Practices

### Structured Logging

```swift
import os

let logger = Logger(subsystem: "com.tacticalsquad", category: "gameplay")

// Different log levels
logger.trace("Detailed trace info")
logger.debug("Debug information")
logger.info("General info")
logger.notice("Notable events")
logger.warning("Warning conditions")
logger.error("Error conditions")
logger.critical("Critical errors")

// With metadata
logger.info("Player joined", metadata: [
    "playerId": "\(player.id)",
    "username": "\(player.username)"
])
```

### Debug Flags

```swift
enum DebugFlags {
    static let showPhysicsDebug = true
    static let logNetworkMessages = true
    static let showFPS = true
    static let verboseLogging = false
}

if DebugFlags.showFPS {
    fpsCounter.update()
}
```

## Testing in Simulator vs Device

### Simulator Limitations

❌ Cannot test:
- Hand tracking
- Eye tracking
- Room mapping (limited)
- Full performance
- Actual network latency

✅ Can test:
- UI layout
- Basic game logic
- Unit tests
- Integration tests

### Device Testing

Always test on physical Vision Pro:
- Hand gesture controls
- Eye tracking accuracy
- Performance (120 FPS)
- Spatial audio
- Room mapping
- Real network conditions

## Debug Menu

```swift
#if DEBUG
struct DebugMenu: View {
    @State private var showPhysics = false
    @State private var showFPS = true

    var body: some View {
        Form {
            Toggle("Show Physics", isOn: $showPhysics)
            Toggle("Show FPS", isOn: $showFPS)

            Button("Spawn 100 Entities") {
                debugSpawnEntities(100)
            }

            Button("Clear All Entities") {
                debugClearEntities()
            }

            Button("Print Memory Usage") {
                printMemoryUsage()
            }
        }
    }
}
#endif
```

## Crash Debugging

### Crash Logs

```bash
# View crash logs
# Xcode → Window → Devices and Simulators
# Select device → View Device Logs

# Symbolicate crash log
# Drag .crash file to Xcode Organizer
```

### Common Crashes

```swift
// Force unwrap crash
let player = players[id]!  // ❌ Crashes if nil

// Safe unwrapping
guard let player = players[id] else {
    return
}  // ✅

// Index out of bounds
let item = array[10]  // ❌ Crashes if array.count < 11

// Safe access
guard array.indices.contains(10) else {
    return
}
let item = array[10]  // ✅
```

## Resources

- [Xcode Debugging Guide](https://developer.apple.com/documentation/xcode/debugging)
- [Instruments User Guide](https://help.apple.com/instruments/)
- [LLDB Quick Start](https://lldb.llvm.org/use/tutorial.html)

See also: [TROUBLESHOOTING.md](TROUBLESHOOTING.md)
