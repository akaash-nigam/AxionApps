# Manual Test Checklist
## Living Building System - visionOS

**Version**: 1.0
**Last Updated**: 2025-11-24
**Testers**: Engineering Team, QA, Beta Users

---

## Purpose

This checklist covers manual tests that require human judgment, physical hardware, or real-world conditions that cannot be automated. Use this before each release to ensure quality.

---

## Pre-Test Setup

- [ ] Device: Apple Vision Pro (physical device preferred)
- [ ] OS Version: visionOS 2.0 or later
- [ ] Build Type: Release configuration
- [ ] Test Environment: Clean install OR upgrade from previous version
- [ ] Real HomeKit devices available for testing (optional but recommended)
- [ ] Smart meter simulator or real smart meter for energy testing

---

## Test Session Information

**Date**: ________________
**Tester**: ________________
**Build Number**: ________________
**Device Serial**: ________________
**Test Duration**: ________________

---

## MVP Features (Must Pass)

### 1. First Launch Experience

- [ ] **1.1** App launches without crashing
- [ ] **1.2** Onboarding appears automatically
- [ ] **1.3** Welcome screen displays correctly with branding
- [ ] **1.4** Navigation through 3 onboarding steps works
- [ ] **1.5** Can create home with custom name
- [ ] **1.6** Can enter optional address
- [ ] **1.7** Can create user profile with name
- [ ] **1.8** Role selection works (Owner, Admin, Member, Guest)
- [ ] **1.9** "Complete" button finishes onboarding
- [ ] **1.10** Dashboard appears after onboarding
- [ ] **1.11** Default rooms created (4 rooms)
- [ ] **1.12** No errors or crashes during onboarding

**Notes**: _______________________________________________

### 2. HomeKit Integration

- [ ] **2.1** HomeKit permission dialog appears on first device discovery
- [ ] **2.2** Permission dialog text is clear and accurate
- [ ] **2.3** Granting permission succeeds
- [ ] **2.4** Denying permission shows appropriate error message
- [ ] **2.5** Can retry after permission denial
- [ ] **2.6** Device discovery starts automatically after permission grant
- [ ] **2.7** Discovery progress indicator shows
- [ ] **2.8** Real HomeKit devices detected (if available)
- [ ] **2.9** Devices display with correct names
- [ ] **2.10** Devices show correct types (light, switch, thermostat, etc.)
- [ ] **2.11** Device reachability status accurate
- [ ] **2.12** "Refresh" button triggers new discovery

**Devices Found**: ______
**Device Types**: _______________________________________________
**Notes**: _______________________________________________

### 3. Device Control

- [ ] **3.1** Can tap device card to toggle on/off
- [ ] **3.2** Device state changes immediately (optimistic UI)
- [ ] **3.3** Visual feedback when tapping (animation, color change)
- [ ] **3.4** Actual device responds to control command
- [ ] **3.5** Brightness slider works for dimmable lights
- [ ] **3.6** Temperature control works for thermostats
- [ ] **3.7** Can set target temperature
- [ ] **3.8** Current temperature displays accurately
- [ ] **3.9** Lock/unlock works for smart locks
- [ ] **3.10** Device detail view opens on long press (optional feature)
- [ ] **3.11** Multiple rapid taps handled gracefully
- [ ] **3.12** Error handling for unreachable devices

**Tested Device Types**:
- [ ] Light
- [ ] Switch
- [ ] Thermostat
- [ ] Lock
- [ ] Other: _______________

**Notes**: _______________________________________________

### 4. Real-Time State Updates

- [ ] **4.1** Physical device state changes reflect in app
- [ ] **4.2** Update latency is acceptable (<2 seconds)
- [ ] **4.3** Multiple devices can update simultaneously
- [ ] **4.4** No UI jank during state updates
- [ ] **4.5** Device grid refreshes smoothly
- [ ] **4.6** Status badges update correctly
- [ ] **4.7** Battery level updates (if applicable)

**Test Method**: Control device from physical switch/app, observe UI
**Notes**: _______________________________________________

### 5. Data Persistence

- [ ] **5.1** Home name persists after app restart
- [ ] **5.2** Room data persists after restart
- [ ] **5.3** User profile persists
- [ ] **5.4** Device list persists
- [ ] **5.5** Device room assignments persist
- [ ] **5.6** User preferences persist
- [ ] **5.7** Energy configuration persists
- [ ] **5.8** Auto-save works (wait 5 minutes, force quit, relaunch)
- [ ] **5.9** No data loss on crash (simulate crash if possible)
- [ ] **5.10** No data corruption after multiple saves

**Test Method**: Make changes, restart app, verify data intact
**Notes**: _______________________________________________

---

## Epic 1: Spatial Interface (Critical for visionOS)

### 6. Immersive Home View

- [ ] **6.1** "Enter Immersive View" button visible and enabled
- [ ] **6.2** Tap button to enter immersive space
- [ ] **6.3** Immersive space loads within 3 seconds
- [ ] **6.4** 3D environment appears correctly
- [ ] **6.5** Device entities render in 3D space
- [ ] **6.6** Devices positioned at correct locations (if spatial data exists)
- [ ] **6.7** Device icons/models visible and clear
- [ ] **6.8** Contextual displays attach to devices
- [ ] **6.9** No visual glitches or z-fighting
- [ ] **6.10** Frame rate is smooth (subjectively 90fps)
- [ ] **6.11** No motion sickness or discomfort
- [ ] **6.12** Can exit immersive view cleanly

**Performance**: Smooth / Occasional Stutters / Laggy
**Notes**: _______________________________________________

### 7. Look-to-Control

- [ ] **7.1** Looking at device highlights it
- [ ] **7.2** Highlight appears within 0.5 seconds
- [ ] **7.3** Highlight is visually clear
- [ ] **7.4** Looking away de-highlights device
- [ ] **7.5** Control panel appears when gazing at device
- [ ] **7.6** Control panel follows device in space
- [ ] **7.7** Can tap air to toggle device
- [ ] **7.8** Air tap is responsive
- [ ] **7.9** Device state changes after air tap
- [ ] **7.10** Visual feedback for air tap
- [ ] **7.11** Can control multiple devices sequentially
- [ ] **7.12** No false positives (accidental triggers)

**Accuracy**: Excellent / Good / Fair / Poor
**Notes**: _______________________________________________

### 8. Room Scanning

- [ ] **8.1** Can trigger room scan from settings or elsewhere
- [ ] **8.2** Room scan immersive space loads
- [ ] **8.3** Instructions are clear
- [ ] **8.4** Mesh visualization appears
- [ ] **8.5** Mesh renders in real-time
- [ ] **8.6** Mesh color (cyan) is appropriate
- [ ] **8.7** Surface count updates during scan
- [ ] **8.8** Progress indication clear
- [ ] **8.9** Scan completes successfully
- [ ] **8.10** Can save scanned room
- [ ] **8.11** Spatial anchors persist
- [ ] **8.12** Can place devices in scanned room

**Scan Quality**: Excellent / Good / Fair / Poor
**Notes**: _______________________________________________

---

## Epic 2: Energy Monitoring

### 9. Energy Configuration

- [ ] **9.1** Can open energy dashboard
- [ ] **9.2** Configuration prompt appears if not set up
- [ ] **9.3** Can open configuration sheet
- [ ] **9.4** All toggles work (Smart Meter, Solar, Battery)
- [ ] **9.5** Can enter API identifier
- [ ] **9.6** Can set electricity rate
- [ ] **9.7** Can set gas rate
- [ ] **9.8** Can set water rate
- [ ] **9.9** Numeric input fields work correctly
- [ ] **9.10** "Save" button enables after changes
- [ ] **9.11** Configuration saves successfully
- [ ] **9.12** "Connected" status appears after save

**Notes**: _______________________________________________

### 10. Real-Time Energy Monitoring

- [ ] **10.1** Current power consumption displays
- [ ] **10.2** Value is numeric and reasonable
- [ ] **10.3** Updates automatically (every 5 seconds)
- [ ] **10.4** Solar generation displays (if configured)
- [ ] **10.5** Net power calculation is correct
- [ ] **10.6** To grid / from grid indicator accurate
- [ ] **10.7** Status cards are visually clear
- [ ] **10.8** Icons are appropriate
- [ ] **10.9** Units displayed correctly (kW)
- [ ] **10.10** No flickering during updates
- [ ] **10.11** Pull-to-refresh works
- [ ] **10.12** Data loads quickly (<1 second)

**Real-Time Performance**: Excellent / Good / Fair / Poor
**Notes**: _______________________________________________

### 11. Energy Visualization

- [ ] **11.1** Cost summary card displays
- [ ] **11.2** Today's cost shown
- [ ] **11.3** This week's cost shown
- [ ] **11.4** Cost calculations are reasonable
- [ ] **11.5** Consumption chart renders
- [ ] **11.6** Chart bars display correctly
- [ ] **11.7** Can switch between Today/Week views
- [ ] **11.8** Chart updates when switching views
- [ ] **11.9** Chart is readable and clear
- [ ] **11.10** X-axis labels visible
- [ ] **11.11** Y-axis labels visible
- [ ] **11.12** Chart data makes sense

**Chart Usability**: Excellent / Good / Fair / Poor
**Notes**: _______________________________________________

### 12. Top Consumers & Anomalies

- [ ] **12.1** Top consumers list displays
- [ ] **12.2** Circuit names shown
- [ ] **12.3** Power values shown for each circuit
- [ ] **12.4** Progress bars visualize usage
- [ ] **12.5** List sorted by usage (highest first)
- [ ] **12.6** Anomalies section displays (if any)
- [ ] **12.7** Anomaly count badge visible
- [ ] **12.8** Anomaly descriptions clear
- [ ] **12.9** Severity icons appropriate
- [ ] **12.10** Can dismiss anomalies
- [ ] **12.11** Dismissed anomalies disappear
- [ ] **12.12** Count updates after dismissal

**Notes**: _______________________________________________

---

## User Experience & Polish

### 13. Visual Design

- [ ] **13.1** App looks professional and polished
- [ ] **13.2** Color scheme is consistent
- [ ] **13.3** Typography is clear and readable
- [ ] **13.4** Icons are recognizable
- [ ] **13.5** Spacing and padding appropriate
- [ ] **13.6** No visual glitches or artifacts
- [ ] **13.7** Dark mode support (if applicable)
- [ ] **13.8** Contrast ratios meet accessibility standards
- [ ] **13.9** Animations are smooth
- [ ] **13.10** Transitions feel natural
- [ ] **13.11** No UI elements overlapping incorrectly
- [ ] **13.12** Empty states are well-designed

**Overall Visual Quality**: Excellent / Good / Fair / Poor
**Notes**: _______________________________________________

### 14. Performance & Stability

- [ ] **14.1** App launches in <3 seconds
- [ ] **14.2** Dashboard loads quickly
- [ ] **14.3** Scrolling is smooth (60fps)
- [ ] **14.4** No frame drops during normal use
- [ ] **14.5** Immersive space maintains 90fps
- [ ] **14.6** Memory usage reasonable (<300MB baseline)
- [ ] **14.7** No memory leaks (use Instruments)
- [ ] **14.8** Battery drain acceptable
- [ ] **14.9** No crashes during 30-minute session
- [ ] **14.10** No crashes when switching apps
- [ ] **14.11** Handles interruptions gracefully (calls, notifications)
- [ ] **14.12** App remains responsive under load

**Performance Rating**: Excellent / Good / Fair / Poor
**Stability Rating**: Excellent / Good / Fair / Poor
**Notes**: _______________________________________________

### 15. Accessibility

- [ ] **15.1** VoiceOver reads all UI elements
- [ ] **15.2** VoiceOver labels are descriptive
- [ ] **15.3** VoiceOver hints are helpful
- [ ] **15.4** Can navigate entire app with VoiceOver
- [ ] **15.5** Touch targets are large enough (44x44pt minimum)
- [ ] **15.6** Dynamic Type support (text scales)
- [ ] **15.7** High contrast mode works (if applicable)
- [ ] **15.8** Reduce Motion respected
- [ ] **15.9** Color is not the only indicator
- [ ] **15.10** Pointer control works
- [ ] **15.11** Keyboard shortcuts work (if applicable)
- [ ] **15.12** All features accessible without vision

**Accessibility Rating**: Excellent / Good / Fair / Poor
**Notes**: _______________________________________________

---

## Error Handling & Edge Cases

### 16. Network & Connectivity

- [ ] **16.1** App works without internet connection
- [ ] **16.2** Appropriate message when network unavailable
- [ ] **16.3** Graceful degradation for cloud features
- [ ] **16.4** Reconnects automatically when network restored
- [ ] **16.5** No crashes due to network errors
- [ ] **16.6** HomeKit devices work on local network only
- [ ] **16.7** Energy monitoring handles connection loss
- [ ] **16.8** iCloud sync works (if enabled)

**Network Conditions Tested**:
- [ ] WiFi
- [ ] Cellular (if applicable)
- [ ] No connection
- [ ] Intermittent connection

**Notes**: _______________________________________________

### 17. Error Messages

- [ ] **17.1** Error messages are user-friendly
- [ ] **17.2** Technical jargon avoided
- [ ] **17.3** Error messages suggest solutions
- [ ] **17.4** "Retry" buttons work
- [ ] **17.5** Error banners display correctly
- [ ] **17.6** Errors are dismissible
- [ ] **17.7** Multiple errors handled gracefully
- [ ] **17.8** No error spam (repeating errors)

**Notes**: _______________________________________________

### 18. Edge Cases

- [ ] **18.1** Works with 0 devices
- [ ] **18.2** Works with 100+ devices
- [ ] **18.3** Works with very long device names
- [ ] **18.4** Works with special characters in names
- [ ] **18.5** Works with multiple homes (HomeKit)
- [ ] **18.6** Handles device removal gracefully
- [ ] **18.7** Handles device addition during session
- [ ] **18.8** Works after iOS/visionOS update
- [ ] **18.9** Works with low battery
- [ ] **18.10** Works in low light conditions
- [ ] **18.11** Works in bright light conditions
- [ ] **18.12** Works with user wearing glasses

**Notes**: _______________________________________________

---

## Integration Testing

### 19. Real Smart Home Devices

**Test with at least 3 different manufacturer devices**:

**Device 1**: _______________
- [ ] **19.1** Discovered successfully
- [ ] **19.2** Control commands work
- [ ] **19.3** State updates work
- [ ] **19.4** No connectivity issues

**Device 2**: _______________
- [ ] **19.5** Discovered successfully
- [ ] **19.6** Control commands work
- [ ] **19.7** State updates work
- [ ] **19.8** No connectivity issues

**Device 3**: _______________
- [ ] **19.9** Discovered successfully
- [ ] **19.10** Control commands work
- [ ] **19.11** State updates work
- [ ] **19.12** No connectivity issues

**Notes**: _______________________________________________

### 20. Long-Running Session

- [ ] **20.1** Run app continuously for 1 hour
- [ ] **20.2** No memory leaks observed
- [ ] **20.3** No performance degradation
- [ ] **20.4** No unexpected crashes
- [ ] **20.5** Energy monitoring continues
- [ ] **20.6** Real-time updates continue
- [ ] **20.7** Auto-save works as expected

**Session Duration**: ________________
**Notes**: _______________________________________________

---

## Upgrade Testing (if applicable)

### 21. Upgrade from Previous Version

- [ ] **21.1** App upgrades without errors
- [ ] **21.2** Existing data migrates correctly
- [ ] **21.3** No data loss
- [ ] **21.4** New features accessible
- [ ] **21.5** Onboarding does not repeat
- [ ] **21.6** Settings preserved
- [ ] **21.7** Device associations intact

**Previous Version**: ________________
**New Version**: ________________
**Notes**: _______________________________________________

---

## Final Assessment

### Blocker Issues (Must Fix Before Release)

1. _______________________________________________
2. _______________________________________________
3. _______________________________________________

### Critical Issues (Should Fix Before Release)

1. _______________________________________________
2. _______________________________________________
3. _______________________________________________

### Minor Issues (Can Fix in Next Release)

1. _______________________________________________
2. _______________________________________________
3. _______________________________________________

### Overall Quality Rating

- **Functionality**: ☆ ☆ ☆ ☆ ☆ (1-5 stars)
- **Performance**: ☆ ☆ ☆ ☆ ☆ (1-5 stars)
- **User Experience**: ☆ ☆ ☆ ☆ ☆ (1-5 stars)
- **Stability**: ☆ ☆ ☆ ☆ ☆ (1-5 stars)
- **Polish**: ☆ ☆ ☆ ☆ ☆ (1-5 stars)

### Recommendation

- [ ] **APPROVED** - Ready for release
- [ ] **APPROVED WITH MINOR ISSUES** - Release with known issues documented
- [ ] **NOT APPROVED** - Blockers must be fixed before release

### Tester Signature

Tested By: _______________________________________________
Date: _______________________________________________
Signature: _______________________________________________

---

## Notes & Observations

Use this space for additional observations, suggestions, or issues not covered above:

_______________________________________________
_______________________________________________
_______________________________________________
_______________________________________________
_______________________________________________
_______________________________________________
_______________________________________________

---

## Appendix: Test Environment Details

**Device Information**:
- Model: _______________
- OS Version: _______________
- Build Number: _______________
- Storage Available: _______________

**HomeKit Setup**:
- HomeKit Devices: _______________
- Manufacturer(s): _______________
- Hub Type: _______________

**Network**:
- WiFi SSID: _______________
- Signal Strength: _______________
- Router Model: _______________

---

**Document Version**: 1.0
**Last Updated**: 2025-11-24
**Maintained By**: QA Team
