# Troubleshooting Guide - AI Agent Coordinator

## Quick Reference

| Issue | Quick Fix | Details |
|-------|-----------|---------|
| Agents not loading | Check network connection | [Link](#agents-not-loading) |
| Slow performance | Reduce visible agents | [Link](#slow-performance-in-3d-views) |
| Can't connect platform | Verify API credentials | [Link](#platform-connection-issues) |
| Hand tracking fails | Check lighting | [Link](#hand-tracking-issues) |
| Collaboration not working | Restart SharePlay | [Link](#collaboration-issues) |
| App crashes on launch | Clear app data | [Link](#app-crashes-on-launch) |

---

## Table of Contents

1. [Agent Management Issues](#agent-management-issues)
2. [Connection & Network Issues](#connection--network-issues)
3. [Performance Issues](#performance-issues)
4. [Visualization Issues](#visualization-issues)
5. [Collaboration Issues](#collaboration-issues)
6. [Hand Tracking & Gestures](#hand-tracking--gestures)
7. [Data & Sync Issues](#data--sync-issues)
8. [Installation & Updates](#installation--updates)
9. [Platform-Specific Issues](#platform-specific-issues)
10. [Getting Additional Help](#getting-additional-help)

---

## Agent Management Issues

### Agents Not Loading

**Symptoms**:
- Empty agent list
- "No agents found" message
- Agents disappear after a while

**Causes & Solutions**:

1. **Network Connection Failed**
   ```
   Check: Settings > Network
   Solution:
   - Verify internet connection
   - Try toggling Wi-Fi off and on
   - Check if backend is reachable
   - Test with curl: curl https://api.aiagentcoordinator.dev/health
   ```

2. **Invalid Platform Credentials**
   ```
   Check: Settings > Integrations > [Platform]
   Solution:
   - Re-enter API credentials
   - Verify key is active (check platform dashboard)
   - Ensure correct permissions granted
   - Try disconnecting and reconnecting
   ```

3. **Filter Too Restrictive**
   ```
   Check: Control Panel > Filters
   Solution:
   - Clear all filters (Reset button)
   - Check status filter (might be hiding healthy agents)
   - Check type filter
   - Verify search query is empty
   ```

4. **Cache Corruption**
   ```
   Solution:
   - Settings > Advanced > Clear Cache
   - Restart app
   - If persists: Settings > Advanced > Reset All Data (⚠️ Warning: Deletes local data)
   ```

### Agent Stuck in "Loading" State

**Symptoms**:
- Agent shows spinner indefinitely
- Status never updates
- Can't interact with agent

**Solutions**:

1. **Force Refresh**
   ```
   - Pull to refresh in agent list
   - Or: Select agent > Force Refresh button
   ```

2. **Restart Agent**
   ```
   - Select agent
   - Click "Stop Agent"
   - Wait 5 seconds
   - Click "Start Agent"
   ```

3. **Check Backend**
   ```
   - Verify platform API is responding
   - Check agent's platform dashboard
   - Look for errors in agent logs
   ```

### Can't Start/Stop Agent

**Symptoms**:
- Start button does nothing
- Error message appears
- Agent starts then immediately stops

**Solutions**:

1. **Permission Issues**
   ```
   Error: "Insufficient permissions"
   Solution:
   - Verify API key has start/stop permissions
   - Check agent ownership (enterprise setups)
   - Use admin credentials if available
   ```

2. **Agent Configuration Invalid**
   ```
   Error: "Invalid configuration"
   Solution:
   - Review agent settings: Agent Detail > Configuration
   - Fix any validation errors (red indicators)
   - Reset to defaults if needed
   - Save changes before starting
   ```

3. **Resource Limits Exceeded**
   ```
   Error: "Resource limit exceeded"
   Solution:
   - Check platform quotas (API rate limits, concurrent agents)
   - Stop other agents to free resources
   - Upgrade platform plan if needed
   ```

### Agent Metrics Not Updating

**Symptoms**:
- Stale data in performance graphs
- Last updated timestamp old
- Metrics show "N/A"

**Solutions**:

1. **Enable Real-Time Monitoring**
   ```
   - Settings > Monitoring > Enable Real-Time Updates
   - Set update interval (default: 10 seconds)
   ```

2. **Check Platform Integration**
   ```
   - Some platforms don't support real-time metrics
   - Verify platform adapter supports metrics
   - Check logs: Settings > Advanced > View Logs
   ```

3. **Restart Metrics Collection**
   ```
   - Select agent
   - Agent Detail > Metrics tab
   - Click "Restart Collection"
   ```

---

## Connection & Network Issues

### Platform Connection Issues

**Symptoms**:
- "Connection failed" error
- Can't add new platform integration
- Existing integration shows "Disconnected"

**Diagnostic Steps**:

```bash
# 1. Test basic connectivity
ping api.openai.com

# 2. Test HTTPS
curl -I https://api.openai.com

# 3. Test with credentials
curl -H "Authorization: Bearer YOUR_API_KEY" \
  https://api.openai.com/v1/models
```

**Solutions**:

1. **Invalid API Key**
   ```
   Error: "401 Unauthorized" or "403 Forbidden"
   Solution:
   - Verify API key is correct (no extra spaces)
   - Check key hasn't expired
   - Generate new key from platform dashboard
   - Re-enter in Settings > Integrations
   ```

2. **Network Blocked**
   ```
   Error: "Connection timeout" or "Network unreachable"
   Solution:
   - Check Vision Pro Wi-Fi connection
   - Try different network
   - Check corporate firewall settings
   - Verify VPN isn't blocking connections
   - Add API domains to allowlist:
     * api.openai.com
     * api.anthropic.com
     * *.amazonaws.com
     * *.azure.com
   ```

3. **SSL Certificate Issues**
   ```
   Error: "SSL certificate verification failed"
   Solution:
   - Update visionOS to latest version
   - Check system date/time is correct
   - Contact platform support if persists
   ```

### WebSocket Connection Drops

**Symptoms**:
- Real-time updates stop
- "Reconnecting..." message
- Delayed metric updates

**Solutions**:

1. **Network Instability**
   ```
   - Move closer to Wi-Fi router
   - Switch to 5GHz network (less interference)
   - Check for network congestion
   ```

2. **Firewall Blocking WebSocket**
   ```
   - Ensure WebSocket protocol allowed
   - Check ports: 443 (WSS), 80 (WS)
   - Add to firewall allowlist
   ```

3. **Increase Reconnection Timeout**
   ```
   - Settings > Advanced > Network
   - Increase "WebSocket Timeout" to 60 seconds
   - Enable "Aggressive Reconnect"
   ```

---

## Performance Issues

### Slow Performance in 3D Views

**Symptoms**:
- Low frame rate (< 60 FPS)
- Stuttering animations
- Delayed response to gestures
- Vision Pro feels warm

**Solutions**:

1. **Reduce Agent Count**
   ```
   - Use filters to show fewer agents (< 1000 recommended)
   - Hide idle agents: Filters > Status > Uncheck "Idle"
   - Use search to focus on specific agents
   ```

2. **Lower Graphics Quality**
   ```
   Settings > Graphics:
   - Level of Detail: Auto (recommended) or High
   - Particle Effects: Medium or Low
   - Shadow Quality: Low
   - Anti-Aliasing: Off
   ```

3. **Disable Expensive Features**
   ```
   - Turn off data flow particles
   - Reduce connection visibility
   - Disable bloom effects
   - Use simple agent shapes (spheres instead of complex models)
   ```

4. **Close Other Apps**
   ```
   - Quit unused Vision Pro apps
   - Close background windows
   - Check memory: Settings > General > Storage
   ```

5. **Increase Update Interval**
   ```
   - Settings > Monitoring > Update Interval: 30 seconds
   - Reduces CPU/network load
   ```

### High Memory Usage

**Symptoms**:
- "Low memory warning"
- App force quits
- System sluggishness

**Solutions**:

1. **Clear Cache**
   ```
   - Settings > Advanced > Clear Cache
   - Frees up memory used by cached data
   ```

2. **Reduce History Retention**
   ```
   - Settings > Monitoring > History
   - Keep Last: 1 hour (instead of 24 hours)
   - Reduces stored metrics
   ```

3. **Limit Immersive Spaces**
   ```
   - Close unused immersive views
   - Use only one visualization at a time
   - Exit immersive mode when not needed
   ```

4. **Restart App**
   ```
   - Double-click Digital Crown
   - Swipe up on app
   - Relaunch from Home
   ```

### Slow Agent List Scrolling

**Symptoms**:
- Laggy scrolling
- List jumps or stutters
- Delay when selecting agents

**Solutions**:

1. **Enable Virtual Scrolling**
   ```
   - Settings > Performance > Virtual Scrolling: On
   - Renders only visible items
   ```

2. **Reduce Visible Information**
   ```
   - Settings > Agent List > Show Metrics: Off
   - Hides metrics in list (faster rendering)
   ```

3. **Use Search Instead**
   ```
   - Use search bar to filter
   - More efficient than scrolling through thousands
   ```

---

## Visualization Issues

### Galaxy View Not Loading

**Symptoms**:
- Black screen in immersive space
- "Loading..." never completes
- App crashes when opening

**Solutions**:

1. **Too Many Agents**
   ```
   - Limit to < 5,000 agents
   - Use filters before opening Galaxy View
   - Try Performance Landscape instead (more optimized)
   ```

2. **Graphics Driver Issue**
   ```
   - Restart Vision Pro (hold Digital Crown + top button)
   - Update visionOS: Settings > General > Software Update
   ```

3. **Corrupted Layout Cache**
   ```
   - Settings > Advanced > Clear Layout Cache
   - Reopen Galaxy View
   ```

### Agents Not Visible in 3D Space

**Symptoms**:
- Empty 3D view
- Some agents missing
- Agents outside visible area

**Solutions**:

1. **Reset Camera Position**
   ```
   - Say "reset view" (voice command)
   - Or: Three-finger tap in air
   - Or: Settings menu > Reset Camera
   ```

2. **Zoom Out**
   ```
   - Spread hands apart (pinch-out gesture)
   - Agents might be clustered far from camera
   ```

3. **Check Visibility Filters**
   ```
   - Some agents might be hidden by filters
   - Check: Visualization Settings > Visibility
   - Reset to defaults
   ```

### Connection Lines Not Showing

**Symptoms**:
- No lines between agents
- Data flow particles missing
- Network topology unclear

**Solutions**:

1. **Enable Connections**
   ```
   - Visualization Settings > Show Connections: On
   - Connection Style: Lines (or Particles)
   ```

2. **Adjust Connection Threshold**
   ```
   - Settings > Show Connections Where:
     * Data Flow > 10 MB/s (default)
     * Lower threshold to see more connections
   ```

3. **Performance Mode Enabled**
   ```
   - Check if Performance Mode is on (hides connections)
   - Settings > Graphics > Performance Mode: Off
   ```

---

## Collaboration Issues

### SharePlay Session Won't Start

**Symptoms**:
- "Start SharePlay" button disabled
- Error: "SharePlay not available"
- No participants can join

**Solutions**:

1. **Requirements Check**
   ```
   ✓ FaceTime call active (or Group FaceTime)
   ✓ All participants on Vision Pro
   ✓ All participants have app installed
   ✓ Same app version
   ✓ Wi-Fi connected (not cellular)
   ```

2. **Enable SharePlay**
   ```
   - Vision Pro Settings > FaceTime > SharePlay: On
   - Try starting FaceTime call first
   - Then launch AI Agent Coordinator
   ```

3. **Restart FaceTime**
   ```
   - End current call
   - Start new FaceTime call
   - Try SharePlay again
   ```

### Participants Can't See My View

**Symptoms**:
- Others see different view
- Selections not syncing
- Annotations not visible

**Solutions**:

1. **Sync State**
   ```
   - Collaboration menu > Force Sync
   - Everyone should see sync indicator
   ```

2. **Network Latency**
   ```
   - Check Wi-Fi signal strength
   - Move closer to router
   - All participants should be on same network
   ```

3. **Version Mismatch**
   ```
   - Settings > About > Version
   - All participants must have same version
   - Update app if different
   ```

### Voice Chat Not Working

**Symptoms**:
- Can't hear participants
- Participants can't hear you
- Audio cutting out

**Solutions**:

1. **Check Permissions**
   ```
   - Vision Pro Settings > Privacy > Microphone
   - Ensure AI Agent Coordinator has permission
   ```

2. **Spatial Audio Issues**
   ```
   - Settings > Audio > Spatial Audio: On
   - Adjust volume
   - Check Vision Pro audio settings
   ```

3. **FaceTime Audio**
   ```
   - FaceTime handles audio, not the app
   - Check FaceTime audio settings
   - Test audio in FaceTime before collaboration
   ```

---

## Hand Tracking & Gestures

### Hand Tracking Issues

**Symptoms**:
- Gestures not recognized
- Cursor jumps erratically
- "Hand tracking lost" message

**Solutions**:

1. **Lighting Conditions**
   ```
   - Ensure good lighting (not too dark, not too bright)
   - Avoid direct sunlight (washes out cameras)
   - Indoor lighting works best
   ```

2. **Hand Position**
   ```
   - Keep hands in front of you
   - Within 0.3 - 1.5 meters from body
   - Hands must be visible to cameras
   - Don't block cameras with hands
   ```

3. **Recalibrate**
   ```
   - Vision Pro Settings > Hand Tracking
   - Run calibration wizard
   - Follow on-screen instructions
   ```

4. **Remove Obstructions**
   ```
   - Take off gloves
   - Remove hand jewelry (if interfering)
   - Ensure hands are clean (no dirt/grease)
   ```

### Gestures Not Working

**Symptoms**:
- Pinch doesn't select
- Drag doesn't move objects
- Rotate gesture doesn't work

**Solutions**:

1. **Enable Hand Tracking**
   ```
   - App Settings > Input > Hand Tracking: On
   - Vision Pro Settings > Hand Tracking: On
   ```

2. **Learn Correct Gestures**
   ```
   - Settings > Help > Gesture Tutorial
   - Practice gestures in tutorial mode
   ```

3. **Reduce Sensitivity**
   ```
   - Settings > Input > Gesture Sensitivity: Medium
   - Too sensitive can cause false triggers
   ```

4. **Use Alternative Input**
   ```
   - Pair Bluetooth keyboard and trackpad
   - Use eye gaze + tap instead of hand gestures
   ```

---

## Data & Sync Issues

### Data Not Syncing (iCloud)

**Symptoms**:
- Changes don't sync across devices
- "Last synced: Never"
- Different data on different devices

**Solutions**:

1. **Enable iCloud Sync**
   ```
   - Settings > Account > iCloud Sync: On
   - Ensure signed into iCloud
   - Check iCloud storage available
   ```

2. **Force Sync**
   ```
   - Settings > Account > Sync Now
   - Wait for sync to complete
   - Check for errors
   ```

3. **iCloud Issues**
   ```
   - Vision Pro Settings > [Your Name] > iCloud
   - Verify iCloud Drive is on
   - Check network connection
   - Sign out and sign back in
   ```

### Lost Data After Update

**Symptoms**:
- Agents disappeared
- Settings reset
- Workspaces gone

**Solutions**:

1. **Restore from Backup**
   ```
   - Settings > Advanced > Restore from Backup
   - Select most recent backup
   - Restore (may take a few minutes)
   ```

2. **Check iCloud**
   ```
   - Data might be in iCloud
   - Settings > Account > Download iCloud Data
   ```

3. **Re-import Agents**
   ```
   - Settings > Integrations > Sync All Platforms
   - Re-discovers agents from connected platforms
   ```

### Export Failed

**Symptoms**:
- Can't export metrics to CSV
- Export button does nothing
- File not found after export

**Solutions**:

1. **Check Storage**
   ```
   - Vision Pro Settings > General > Storage
   - Ensure sufficient space available
   - Free up space if needed
   ```

2. **Grant File Access**
   ```
   - Vision Pro Settings > Privacy > Files and Folders
   - Ensure AI Agent Coordinator has access
   ```

3. **Try Different Format**
   ```
   - Try JSON instead of CSV
   - Smaller date range
   - Fewer agents/metrics
   ```

---

## Installation & Updates

### App Won't Install

**Symptoms**:
- Download stuck
- "Unable to install" error
- App icon grayed out

**Solutions**:

1. **Storage Space**
   ```
   - Need ~500 MB free space
   - Vision Pro Settings > General > Storage
   - Delete unused apps
   ```

2. **Network Issues**
   ```
   - Check Wi-Fi connection
   - Try different network
   - Restart Wi-Fi router
   ```

3. **App Store Issues**
   ```
   - App Store > Account > Redownload
   - Sign out and back into App Store
   - Restart Vision Pro
   ```

### App Crashes on Launch

**Symptoms**:
- App opens then immediately closes
- Crash before UI appears
- Boot loop

**Solutions**:

1. **Force Quit and Relaunch**
   ```
   - Double-click Digital Crown
   - Swipe up on AI Agent Coordinator
   - Wait 10 seconds
   - Relaunch
   ```

2. **Clear App Data**
   ```
   ⚠️ Warning: Deletes all local data
   - Hold app icon on Home
   - Select "Reset App"
   - Confirm
   ```

3. **Reinstall App**
   ```
   - Delete app
   - Restart Vision Pro
   - Reinstall from App Store
   ```

4. **Check visionOS Version**
   ```
   - Requires visionOS 2.0+
   - Settings > General > Software Update
   - Update if available
   ```

### Update Won't Install

**Symptoms**:
- Update available but won't download
- "Unable to update" error
- Update fails halfway

**Solutions**:

1. **Delete and Reinstall**
   ```
   - Backup data first (Settings > Backup Now)
   - Delete app
   - Reinstall from App Store (gets latest version)
   - Restore data
   ```

2. **Check Update Requirements**
   ```
   - Sufficient storage
   - Wi-Fi connected
   - Vision Pro plugged in (for major updates)
   ```

---

## Platform-Specific Issues

### OpenAI Integration Issues

**Common Errors**:

```
Error: "Rate limit exceeded"
Solution:
- Slow down request rate
- Upgrade OpenAI plan
- Settings > Integrations > OpenAI > Request Delay: 1000ms

Error: "Invalid model"
Solution:
- Check model name is correct (gpt-4, gpt-3.5-turbo, etc.)
- Verify account has access to model
- Some models require special access

Error: "Insufficient quota"
Solution:
- Add payment method to OpenAI account
- Purchase credits
- Check billing dashboard
```

### AWS SageMaker Issues

**Common Errors**:

```
Error: "Endpoint not found"
Solution:
- Verify endpoint exists in AWS console
- Check region is correct
- Ensure IAM role has permissions

Error: "Throttling exception"
Solution:
- Request quota increase from AWS
- Reduce request frequency
- Use batch invocations

Error: "Invalid credentials"
Solution:
- Regenerate AWS access keys
- Check IAM permissions include:
  * sagemaker:DescribeEndpoint
  * sagemaker:InvokeEndpoint
  * cloudwatch:GetMetricData
```

### Anthropic (Claude) Issues

**Common Errors**:

```
Error: "API key invalid"
Solution:
- Verify key format: sk-ant-...
- Generate new key from console.anthropic.com
- Check key has correct permissions

Error: "Overloaded"
Solution:
- Retry with exponential backoff
- Service is at capacity, try later
- Consider using caching

Error: "Context length exceeded"
Solution:
- Reduce input size
- Use Claude 2 (100k context) instead of Claude Instant
```

---

## Getting Additional Help

### Diagnostic Information

When contacting support, include:

1. **System Info**:
   ```
   - Settings > About
   - Vision Pro model
   - visionOS version
   - App version
   ```

2. **Export Logs**:
   ```
   - Settings > Advanced > Export Logs
   - Include in support request
   ```

3. **Screenshots/Recording**:
   ```
   - Capture error messages
   - Record issue happening (if possible)
   ```

### Support Channels

1. **Documentation**:
   - User Guide: [USER_GUIDE.md](USER_GUIDE.md)
   - API Reference: [API_REFERENCE.md](API_REFERENCE.md)
   - Online docs: https://docs.aiagentcoordinator.dev

2. **Community**:
   - GitHub Issues: https://github.com/yourusername/visionOS_ai-agent-coordinator/issues
   - Community Forum: https://community.aiagentcoordinator.dev
   - Discord: https://discord.gg/aiagentcoordinator

3. **Direct Support**:
   - Email: support@aiagentcoordinator.dev
   - Live Chat: Available 9am-5pm PT (Mon-Fri)
   - Emergency: emergency@aiagentcoordinator.dev (critical production issues)

### Before Contacting Support

- [ ] Searched this troubleshooting guide
- [ ] Checked known issues: https://status.aiagentcoordinator.dev
- [ ] Tried restarting the app
- [ ] Verified latest version installed
- [ ] Collected diagnostic information

### Bug Report Template

```markdown
**Issue Description**:
[Clear description of the problem]

**Steps to Reproduce**:
1.
2.
3.

**Expected Behavior**:
[What should happen]

**Actual Behavior**:
[What actually happens]

**Environment**:
- Vision Pro Model:
- visionOS Version:
- App Version:
- Network: Wi-Fi / Cellular

**Screenshots/Logs**:
[Attach files]

**Additional Context**:
[Any other relevant information]
```

---

## Known Issues

### Current Known Issues (v1.0.0)

1. **Performance Degradation with 50,000+ Agents**
   - **Issue**: Frame rate drops below 30 FPS
   - **Workaround**: Use filters to display < 10,000 agents
   - **Status**: Fix planned for v1.1.0

2. **Collaboration Sync Delay**
   - **Issue**: 2-3 second delay in some network conditions
   - **Workaround**: Use wired network when possible
   - **Status**: Investigating

3. **OpenAI Assistant Status Not Real-Time**
   - **Issue**: Status updates every 60 seconds
   - **Workaround**: Use manual refresh
   - **Status**: OpenAI API limitation

Check status page for updates: https://status.aiagentcoordinator.dev

---

**Still having issues?** Contact support@aiagentcoordinator.dev with your diagnostic information.
