# Release Checklist - AI Agent Coordinator

Use this checklist for every release to ensure quality and completeness.

## Pre-Release (1 Week Before)

### Code Freeze
- [ ] All planned features merged to main
- [ ] No new features accepted after this point
- [ ] Only bug fixes allowed

### Version Management
- [ ] Update `MARKETING_VERSION` in Xcode
- [ ] Increment `CURRENT_PROJECT_VERSION`
- [ ] Update version in all documentation
- [ ] Create release branch: `release/vX.Y.Z`

### Documentation
- [ ] Update CHANGELOG.md with all changes
- [ ] Update README.md if needed
- [ ] Review and update API_REFERENCE.md
- [ ] Update USER_GUIDE.md for new features
- [ ] Prepare App Store release notes

## Testing (5 Days Before)

### Automated Testing
- [ ] All unit tests pass
- [ ] All integration tests pass
- [ ] Code coverage > 80%
- [ ] No compiler warnings
- [ ] Run static analysis (SwiftLint)

### Manual Testing on Device
- [ ] Test on actual Vision Pro (not just simulator)
- [ ] Test all major features
- [ ] Test platform integrations (OpenAI, AWS, etc.)
- [ ] Test with 1,000 agents
- [ ] Test with 10,000 agents
- [ ] Test SharePlay collaboration
- [ ] Test hand tracking gestures
- [ ] Test voice commands
- [ ] Test all visualization modes

### Performance Testing
- [ ] App launch < 2 seconds
- [ ] Frame rate ≥ 60 FPS
- [ ] Memory usage < 500 MB
- [ ] No memory leaks (run Instruments)
- [ ] Network efficiency verified
- [ ] Battery impact acceptable

### Accessibility Testing
- [ ] VoiceOver works correctly
- [ ] Voice Control functional
- [ ] Dynamic Type supported
- [ ] High Contrast mode works
- [ ] Reduce Motion respected

## Build & Archive (3 Days Before)

### Clean Build
- [ ] Clean build folder (Cmd + Shift + K)
- [ ] Delete Derived Data
- [ ] Fresh checkout from release branch
- [ ] Verify no debug code

### Create Archive
- [ ] Product > Archive
- [ ] Archive created successfully
- [ ] Validate archive (no errors)
- [ ] Generate dSYMs
- [ ] Save archive for records

### Code Signing
- [ ] Distribution certificate valid
- [ ] Provisioning profile valid
- [ ] Entitlements correct
- [ ] App ID matches
- [ ] Bundle ID correct

## App Store Submission (2 Days Before)

### App Store Connect Setup
- [ ] Version created in App Store Connect
- [ ] App information updated
- [ ] Screenshots uploaded (all required sizes)
- [ ] Preview videos uploaded (optional)
- [ ] Release notes prepared
- [ ] Keywords optimized (100 chars max)
- [ ] Support URL active
- [ ] Privacy Policy URL active
- [ ] Age rating appropriate

### Upload Build
- [ ] Upload via Xcode Organizer
- [ ] Build appears in App Store Connect
- [ ] Build processes successfully
- [ ] Select build for version

### TestFlight (Optional but Recommended)
- [ ] Add build to TestFlight
- [ ] Internal testing (if time permits)
- [ ] Collect feedback
- [ ] Fix critical issues

### Submit for Review
- [ ] Answer all questions accurately
- [ ] Export compliance (encryption)
- [ ] Advertising identifier usage
- [ ] Content rights confirmation
- [ ] Click "Submit for Review"

## Post-Submission

### Monitor Status
- [ ] Check submission status daily
- [ ] Respond to App Review questions within 24h
- [ ] Fix rejection issues promptly

### Prepare for Launch
- [ ] Draft launch announcement
- [ ] Prepare social media posts
- [ ] Update website
- [ ] Notify beta testers
- [ ] Prepare support team

## On Launch Day

### Release
- [ ] Monitor App Store - build goes live
- [ ] Verify app downloads correctly
- [ ] Test on fresh device
- [ ] Post launch announcement
- [ ] Share on social media
- [ ] Send email to users (if applicable)

### Monitor
- [ ] Watch for crash reports
- [ ] Monitor App Store reviews
- [ ] Check analytics
- [ ] Respond to user feedback
- [ ] Monitor support channels

### Infrastructure
- [ ] Backend services ready (if applicable)
- [ ] Monitoring dashboards active
- [ ] On-call team ready
- [ ] Rollback plan prepared

## Post-Launch (First Week)

### Metrics
- [ ] Track downloads
- [ ] Monitor crash rate (target: < 0.1%)
- [ ] Check retention rate
- [ ] Review App Store rating
- [ ] Analyze user feedback

### Support
- [ ] Respond to reviews
- [ ] Answer support emails
- [ ] Update FAQ based on questions
- [ ] Fix critical bugs immediately

### Retrospective
- [ ] Hold release retrospective meeting
- [ ] Document lessons learned
- [ ] Update process for next release
- [ ] Celebrate success! 🎉

## Hotfix Process (If Needed)

If critical bug discovered:

1. **Assess Severity**
   - [ ] Critical (crash, data loss): Immediate hotfix
   - [ ] High (major feature broken): Hotfix within 24h
   - [ ] Medium: Include in next regular release

2. **Create Hotfix**
   - [ ] Branch from release tag: `hotfix/vX.Y.Z+1`
   - [ ] Fix the specific issue only
   - [ ] Test thoroughly
   - [ ] Update version (patch number)

3. **Release Hotfix**
   - [ ] Follow abbreviated checklist
   - [ ] Mark as critical bug fix
   - [ ] Request expedited review
   - [ ] Monitor closely

## Sign-Off

**Release Manager**: _______________
**QA Lead**: _______________
**Engineering Lead**: _______________
**Date**: _______________

---

**Note**: Customize this checklist for your team's specific needs.
