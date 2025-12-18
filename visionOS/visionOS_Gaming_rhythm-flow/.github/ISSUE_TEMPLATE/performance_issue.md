---
name: Performance Issue
about: Report frame rate drops, lag, or memory issues
title: '[PERFORMANCE] '
labels: performance
assignees: ''
---

## ⚡ Performance Issue Summary

**Brief description of the performance problem.**

## 📊 Performance Metrics

### Frame Rate
- **Expected**: 90 FPS
- **Actual**: _____ FPS
- **Measurement Method**: [e.g., Xcode Instruments, visual estimation, FPS counter]

### Memory Usage
- **Expected**: < 2GB
- **Actual**: _____ MB/GB
- **Growing over time**: [ ] Yes [ ] No

### CPU Usage
- **CPU Load**: _____ %
- **Thermal State**: [Normal / Elevated / Critical]

## 📱 Device Information

- **Device**: [e.g., Apple Vision Pro]
- **visionOS Version**: [e.g., 2.0]
- **App Version**: [e.g., 1.0.0]
- **Power Status**: [ ] Plugged in [ ] On battery

## 🎮 Scenario

**When does the performance issue occur?**

### Game Mode
- [ ] Main Menu
- [ ] Song Selection
- [ ] Gameplay - Solo
- [ ] Gameplay - Multiplayer
- [ ] Fitness Mode
- [ ] Practice Mode
- [ ] Results Screen
- [ ] Other: ____________

### Gameplay Details (if applicable)
- **Song**: [song name]
- **Difficulty**: [Easy/Normal/Hard/Expert/Expert+]
- **Note Density**: [Low/Medium/High/Extreme]
- **Duration**: [how long into song/session]

## 🔄 Reproducibility

**How consistently can you reproduce this?**

- [ ] Always (100% of the time)
- [ ] Frequently (>75% of the time)
- [ ] Sometimes (25-75% of the time)
- [ ] Rarely (<25% of the time)
- [ ] Only once

## 📋 Steps to Reproduce

1. Launch app
2. Navigate to '...'
3. Start song '...' on difficulty '...'
4. Observe performance degradation at timestamp '...'

## 📈 Performance Timeline

**Does performance degrade over time?**

- [ ] Immediate - Poor from the start
- [ ] Gradual - Gets worse over minutes
- [ ] Sudden - Drops at specific point
- [ ] Intermittent - Comes and goes

**If gradual, how long until noticeable?**
- Time: _____ minutes

## 🎯 Impact

**How does this affect gameplay?**

- [ ] Game is unplayable
- [ ] Significant impact on gameplay (missing notes due to lag)
- [ ] Noticeable but still playable
- [ ] Minor visual stuttering
- [ ] Only visible in performance metrics

## 📸 Evidence

**Screenshots/videos showing the performance issue.**

### Performance Metrics Screenshot
[Attach screenshot from Xcode Instruments or system monitor]

### Gameplay Video
[Attach video showing lag/stuttering]

## 🔧 Instruments Profile (if available)

**If you've run Xcode Instruments, please attach the trace file or screenshots.**

<details>
<summary>Time Profiler Results</summary>

```
Paste relevant profiling data
```

</details>

<details>
<summary>Allocations Results</summary>

```
Paste memory allocation data
```

</details>

## 🌡 Thermal Information

- **Device Temperature**: [Cool / Warm / Hot / Very Hot]
- **Did device show thermal warning**: [ ] Yes [ ] No
- **Was CPU throttled**: [ ] Yes [ ] No [ ] Unknown

## 🔍 What You've Tried

**Have you tried any of these troubleshooting steps?**

- [ ] Restarted the app
- [ ] Restarted the device
- [ ] Closed other apps
- [ ] Reduced graphics settings (if available)
- [ ] Tested different songs/difficulties
- [ ] Tested in airplane mode

## 📊 Comparison

**Does the issue occur:**

- [ ] On all songs
- [ ] Only on specific songs: ____________
- [ ] Only on certain difficulties: ____________
- [ ] Only after playing for X minutes: ____________
- [ ] Only in certain game modes: ____________

## 💾 Memory Leaks

**Have you noticed the app using more memory over time?**

- [ ] Yes, memory increases steadily
- [ ] Yes, memory spikes then stays high
- [ ] No, memory usage is stable
- [ ] Not sure

**Peak memory usage**: _____ MB/GB

## 🔊 Audio Performance

**Are there audio issues?**

- [ ] Audio cutting out
- [ ] Audio-visual desync
- [ ] Audio crackling/popping
- [ ] No audio issues

## 🎨 Visual Performance

**Are there visual issues?**

- [ ] Frame drops / stuttering
- [ ] Screen tearing
- [ ] Objects popping in/out
- [ ] Delayed UI responses
- [ ] No visual issues

## 🤝 Other Apps

**Do you experience performance issues in other visionOS apps?**

- [ ] Yes, similar issues
- [ ] No, only in Rhythm Flow
- [ ] Haven't tested

## 📱 Background Apps

**What other apps were running?**

- [ ] No other apps
- [ ] Few apps (1-3)
- [ ] Many apps (4+)
- [ ] Don't know

## 🔧 Workaround

**Have you found any workaround?**

## 📝 Additional Context

**Any other context about the performance issue.**

## 🎯 Expected Performance

**Reference from TECHNICAL_SPEC.md:**
- **Frame Rate**: 90 FPS sustained
- **Frame Time**: < 11.1ms per frame
- **Memory**: < 2GB peak
- **Input Latency**: < 20ms
- **Audio Sync**: ±2ms

## ✅ Checklist

- [ ] I have searched existing performance issues
- [ ] I have included performance metrics
- [ ] I have described the scenario clearly
- [ ] I have indicated how consistently it reproduces
- [ ] I have attached evidence (screenshots/videos)
- [ ] I have tried basic troubleshooting steps
