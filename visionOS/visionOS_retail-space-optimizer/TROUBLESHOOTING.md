# Troubleshooting Guide

Common issues and solutions for Retail Space Optimizer.

## Installation & Launch Issues

### App Won't Install
**Symptoms**: Installation fails or app doesn't appear
**Solutions**:
1. Check visionOS version (requires 2.0+)
2. Ensure sufficient storage (requires 500MB)
3. Restart Vision Pro
4. Re-download from App Store

### Crashes on Launch
**Symptoms**: App closes immediately after opening
**Solutions**:
1. Force quit and restart app
2. Restart Vision Pro
3. Check for app updates
4. Reinstall app if persists

## Performance Issues

### Slow Performance / Lag
**Symptoms**: Choppy animations, slow response
**Solutions**:
1. Reduce fixture count (target < 100)
2. Lower graphics quality: Settings > Graphics > Quality: Medium
3. Close other apps
4. Restart Vision Pro
5. Clear app cache: Settings > Storage > Clear Cache

### Low Frame Rate in Immersive Mode
**Symptoms**: Stuttering, motion sickness
**Solutions**:
1. Reduce fixture complexity
2. Disable analytics overlay
3. Lower immersion level
4. Exit and re-enter immersive space

## Display Issues

### Fixtures Not Visible in 3D
**Symptoms**: Missing or invisible fixtures
**Solutions**:
1. Download fixture assets: Settings > Storage > Download Assets
2. Check fixture is within store bounds
3. Toggle walls visibility
4. Reset camera view: Tap Home icon

### Distorted or Glitchy Graphics
**Symptoms**: Visual artifacts, flickering
**Solutions**:
1. Restart app
2. Update to latest app version
3. Report bug with screenshots

## Data Sync Issues

### CloudKit Sync Failing
**Symptoms**: Changes not syncing across devices
**Solutions**:
1. Check internet connection
2. Sign in to iCloud
3. Enable iCloud Drive for app: Settings > iCloud
4. Check iCloud storage space

### Data Loss
**Symptoms**: Missing stores or layouts
**Solutions**:
1. Check iCloud sync status
2. Restore from backup: Settings > Data > Restore
3. Contact support if data unrecoverable

## Analytics Issues

### Heat Map Not Displaying
**Symptoms**: Blank or error in analytics
**Solutions**:
1. Ensure date range has data
2. Check POS integration status
3. Use simulated data: Settings > Analytics > Use Mock Data

### Incorrect Metrics
**Symptoms**: Numbers seem wrong
**Solutions**:
1. Verify POS integration settings
2. Check date range filters
3. Recalculate: Analytics > ⋯ > Recalculate

## Import/Export Issues

### Can't Import Floor Plan
**Symptoms**: Import fails or wrong format
**Solutions**:
1. Check file format (DWG, DXF, PNG, JPG)
2. Ensure file size < 50MB
3. Try converting to different format

### Export Fails
**Symptoms**: Export doesn't complete
**Solutions**:
1. Check storage space
2. Reduce export quality
3. Try different format

## Network Issues

### API Connection Fails
**Symptoms**: "Cannot connect to server" error
**Solutions**:
1. Check internet connection
2. Check firewall settings
3. Try again later (may be maintenance)
4. Check status: https://status.retailspaceoptimizer.com

## Known Issues

### visionOS 2.0
- Immersive space may flicker on first entry (restart app)
- Hand tracking occasionally loses precision (recalibrate)

### Large Stores (> 1000 sq ft)
- May need to split into zones for optimal performance

## Getting More Help

If issues persist:

1. **Check App Version**: Settings > About (ensure latest version)
2. **View Logs**: Settings > Help > View Logs
3. **Contact Support**:
   - Email: support@retailspaceoptimizer.com
   - Include: Device model, visionOS version, app version, logs
4. **Report Bug**: GitHub Issues or in-app feedback

---

**Last Updated**: 2025-11-19
