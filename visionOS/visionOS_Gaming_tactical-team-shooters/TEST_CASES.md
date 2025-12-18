# Test Cases - Tactical Team Shooters

Detailed test case specifications for manual and automated testing.

## Test Case Template

```
TC-XXX: Test Case Name

**Priority**: Critical / High / Medium / Low
**Type**: Functional / Performance / Security / UI/UX
**Environment**: Simulator / Device

**Preconditions**:
- List prerequisites

**Steps**:
1. Step 1
2. Step 2

**Expected Result**:
- What should happen

**Actual Result**:
- What actually happened (filled during testing)

**Status**: Pass / Fail / Blocked

**Notes**:
- Additional information
```

## Functional Test Cases

### Player Management

**TC-001: Player Creation**
- **Priority**: Critical
- **Preconditions**: None
- **Steps**:
  1. Create new player with username "TestPlayer"
  2. Verify player has unique ID
  3. Verify default rank is Recruit
- **Expected**: Player created with correct defaults
- **Status**: Pass

**TC-002: Player Stats KDR Calculation**
- **Priority**: High
- **Steps**:
  1. Create player
  2. Set kills = 10, deaths = 5
  3. Check KDR value
- **Expected**: KDR = 2.0
- **Status**: Pass

### Weapon System

**TC-010: AK-47 Initialization**
- **Priority**: Critical
- **Steps**:
  1. Get AK-47 weapon
  2. Verify stats: damage=36, fireRate=600, magazineSize=30
- **Expected**: All stats match specification

**TC-011: Weapon Damage Calculation**
- **Priority**: High
- **Steps**:
  1. Fire AK-47 at player with 100 HP
  2. Verify damage dealt is 36
  3. Verify player health is 64
- **Expected**: Correct damage applied

**TC-012: Weapon Reload**
- **Priority**: High
- **Steps**:
  1. Fire until empty (30 shots)
  2. Trigger reload
  3. Wait reload time (2.5s)
  4. Verify magazine full
- **Expected**: Magazine refilled to 30

### Team Management

**TC-020: Team Creation**
- **Priority**: Critical
- **Steps**:
  1. Create team "Alpha"
  2. Verify team has 0 players initially
- **Expected**: Empty team created

**TC-021: Add Player to Team**
- **Priority**: Critical
- **Steps**:
  1. Create team
  2. Add player
  3. Verify player in team
- **Expected**: Team contains 1 player

**TC-022: Team Size Limit**
- **Priority**: High
- **Steps**:
  1. Add 5 players to team
  2. Attempt to add 6th player
- **Expected**: Error thrown (teamFull)

## Multiplayer Test Cases

### Networking

**TC-100: Connection Establishment**
- **Priority**: Critical
- **Environment**: 2+ Devices
- **Steps**:
  1. Start game on device 1
  2. Start game on device 2
  3. Join same session
- **Expected**: Devices connect successfully

**TC-101: Player Synchronization**
- **Priority**: Critical
- **Environment**: 2 Devices
- **Steps**:
  1. Connect 2 players
  2. Move player 1
  3. Observe on player 2's screen
- **Expected**: Player 1's movement visible to player 2

**TC-102: Latency Measurement**
- **Priority**: High
- **Environment**: 2 Devices
- **Steps**:
  1. Connect players
  2. Measure round-trip time
- **Expected**: Latency < 50ms on good network

**TC-103: Disconnection Handling**
- **Priority**: High
- **Environment**: 2 Devices
- **Steps**:
  1. Connect players
  2. Force disconnect player 1
  3. Observe behavior
- **Expected**: Player 1 removed from match after timeout

## Vision Pro Specific Test Cases

### Hand Tracking

**TC-200: Weapon Switch Gesture**
- **Priority**: Critical
- **Environment**: Vision Pro Device
- **Steps**:
  1. Equipped weapon
  2. Perform switch gesture (pinch + swipe)
  3. Verify weapon switches
- **Expected**: Weapon switched successfully

**TC-201: Reload Gesture**
- **Priority**: High
- **Environment**: Vision Pro Device
- **Steps**:
  1. Empty magazine
  2. Perform reload gesture
  3. Verify reload animation
- **Expected**: Weapon reloads

### Eye Tracking

**TC-210: Gaze Aiming**
- **Priority**: Critical
- **Environment**: Vision Pro Device
- **Steps**:
  1. Look at target
  2. Verify crosshair follows gaze
  3. Fire weapon
- **Expected**: Weapon fires where looking

**TC-211: Menu Navigation**
- **Priority**: High
- **Environment**: Vision Pro Device
- **Steps**:
  1. Open menu
  2. Look at menu item
  3. Pinch to select
- **Expected**: Item selected

### Spatial Audio

**TC-220: Positional Audio**
- **Priority**: High
- **Environment**: Vision Pro Device
- **Steps**:
  1. Spawn audio source to left
  2. Verify sound from left
  3. Move source to right
  4. Verify sound from right
- **Expected**: Audio position matches source

**TC-221: Distance Attenuation**
- **Priority**: Medium
- **Environment**: Vision Pro Device
- **Steps**:
  1. Place audio source 1m away
  2. Note volume
  3. Move to 10m away
  4. Compare volume
- **Expected**: Volume decreases with distance

### Room Mapping

**TC-230: Room Scan**
- **Priority**: Critical
- **Environment**: Vision Pro Device
- **Steps**:
  1. Start room scan
  2. Look around room
  3. Complete scan
- **Expected**: Room mesh generated

**TC-231: Dynamic Cover Generation**
- **Priority**: High
- **Environment**: Vision Pro Device
- **Steps**:
  1. Scan room
  2. Identify furniture as cover
  3. Verify cover works in gameplay
- **Expected**: Real objects provide cover

## Performance Test Cases

**TC-300: Frame Rate**
- **Priority**: Critical
- **Environment**: Vision Pro Device
- **Steps**:
  1. Start match
  2. Measure FPS during gameplay
- **Expected**: 120 FPS sustained

**TC-301: Memory Usage**
- **Priority**: High
- **Environment**: Vision Pro Device
- **Steps**:
  1. Play for 30 minutes
  2. Monitor memory usage
- **Expected**: < 3GB total memory

**TC-302: Battery Life**
- **Priority**: Medium
- **Environment**: Vision Pro Device
- **Steps**:
  1. Full charge
  2. Play until battery depleted
  3. Measure time
- **Expected**: > 2 hours gameplay

**TC-303: Thermal Performance**
- **Priority**: High
- **Environment**: Vision Pro Device
- **Steps**:
  1. Play for 30+ minutes
  2. Monitor performance
- **Expected**: No thermal throttling

## UI/UX Test Cases

**TC-400: Main Menu Navigation**
- **Priority**: High
- **Steps**:
  1. Launch app
  2. Navigate through menus
  3. Verify all buttons work
- **Expected**: All navigation functions correctly

**TC-401: HUD Readability**
- **Priority**: Medium
- **Environment**: Vision Pro Device
- **Steps**:
  1. Enter match
  2. Verify HUD elements readable
  3. Check in various lighting
- **Expected**: All text and icons clear

**TC-402: Settings Persistence**
- **Priority**: Medium
- **Steps**:
  1. Change settings
  2. Quit app
  3. Relaunch
  4. Verify settings saved
- **Expected**: Settings persisted

## Security Test Cases

**TC-500: Input Validation**
- **Priority**: High
- **Steps**:
  1. Create player with username "A"
  2. Create player with 100-char username
  3. Create player with special chars
- **Expected**: Only valid usernames accepted

**TC-501: Anti-Cheat Detection**
- **Priority**: Critical
- **Steps**:
  1. Send invalid player position
  2. Verify server rejects
- **Expected**: Cheating attempt blocked

## Regression Test Cases

**TC-600: Core Functionality Smoke Test**
- **Priority**: Critical
- **Steps**:
  1. Launch app
  2. Create/login
  3. Join match
  4. Play for 5 minutes
  5. Quit
- **Expected**: No crashes, major bugs

## Test Execution Summary

| Category | Total | Pass | Fail | Blocked |
|----------|-------|------|------|---------|
| Functional | 22 | - | - | - |
| Multiplayer | 4 | - | - | - |
| Vision Pro | 12 | - | - | - |
| Performance | 4 | - | - | - |
| UI/UX | 3 | - | - | - |
| Security | 2 | - | - | - |
| Regression | 1 | - | - | - |
| **Total** | **48** | - | - | - |

## Test Coverage Matrix

| Component | Unit Tests | Integration Tests | Manual Tests |
|-----------|------------|-------------------|--------------|
| Player | ✅ | ✅ | ✅ |
| Weapon | ✅ | ✅ | ✅ |
| Team | ✅ | ✅ | ✅ |
| Network | ✅ | ✅ | ✅ |
| Hand Tracking | ❌ | ❌ | ✅ |
| Eye Tracking | ❌ | ❌ | ✅ |
| Spatial Audio | ❌ | ❌ | ✅ |

## Test Execution Checklist

- [ ] All unit tests pass
- [ ] All integration tests pass
- [ ] Critical manual tests completed
- [ ] Performance tests meet targets
- [ ] Vision Pro device tests completed
- [ ] Security tests completed
- [ ] Regression tests pass
- [ ] Bugs logged and tracked
- [ ] Test report generated

---

See [VISIONOS_TESTING_GUIDE.md](VISIONOS_TESTING_GUIDE.md) for execution instructions.
