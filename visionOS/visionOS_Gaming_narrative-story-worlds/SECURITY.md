# Security Policy

## Supported Versions

We release patches for security vulnerabilities for the following versions:

| Version | Supported          |
| ------- | ------------------ |
| 1.0.x   | :white_check_mark: |
| < 1.0   | :x:                |

## Reporting a Vulnerability

We take the security of Narrative Story Worlds seriously. If you discover a security vulnerability, please follow these steps:

### 1. **Do NOT** Disclose Publicly

Please do not create a public GitHub issue for security vulnerabilities. Public disclosure could put users at risk.

### 2. Report Privately

Send your security report to: **[INSERT SECURITY EMAIL]**

Include:
- Description of the vulnerability
- Steps to reproduce
- Potential impact
- Suggested fix (if you have one)

### 3. Response Timeline

- **24 hours**: We will acknowledge receipt of your report
- **72 hours**: We will provide an initial assessment
- **7-30 days**: We will work on a fix (timeline depends on severity)
- **Upon fix**: We will notify you and coordinate disclosure

### 4. Coordinated Disclosure

We request that you:
- Give us reasonable time to fix the vulnerability before public disclosure
- Do not exploit the vulnerability beyond proof-of-concept
- Maintain confidentiality until we've released a patch

## Security Considerations

### Data Protection

**User Data**:
- Story progress and choices are stored locally on device
- CloudKit sync is encrypted in transit (TLS) and at rest
- No personally identifiable information (PII) is collected
- No analytics are sent to third parties without explicit consent

**Privacy by Design**:
- Face tracking data is processed on-device only
- Emotion recognition never leaves the device
- No voice recordings are stored
- No video is captured

### Authentication & Authorization

**iCloud Account**:
- CloudKit access requires authenticated iCloud account
- Story saves are scoped to user's private database
- No cross-user data access

**App Sandbox**:
- Full App Sandbox enabled
- Limited network access (CloudKit only)
- No file system access outside container

### Secure Coding Practices

**Memory Safety**:
- Swift 6.0 strict concurrency eliminates data races
- No unsafe pointer operations
- Automatic reference counting prevents memory leaks

**Input Validation**:
- All user choices validated before processing
- Save data integrity checks on load
- CloudKit records validated on sync

**Dependency Security**:
- No third-party dependencies (reduces attack surface)
- Apple frameworks only (ARKit, RealityKit, etc.)

## Common Vulnerabilities (How We Prevent)

### Save File Tampering

**Risk**: User modifies save file to unlock content or cheat

**Mitigation**:
- Save files are hashed and validated on load
- Invalid saves are rejected with error message
- CloudKit sync validates data integrity

### Jailbreak Detection

**Risk**: App runs on jailbroken device with modified system

**Decision**: We do NOT implement jailbreak detection
- Users should be free to modify their own devices
- Detection can be bypassed and creates false positives
- Focus on data integrity, not environment restrictions

### Face Tracking Privacy

**Risk**: Emotion data could be logged or transmitted

**Mitigation**:
- Face tracking data never leaves device
- Emotion classification happens on-device via ARKit
- No emotion data is logged or stored
- Privacy manifest declares ARKit usage

### CloudKit Data Leakage

**Risk**: User data accessible by others

**Mitigation**:
- All data stored in private database (user-scoped)
- CloudKit queries restricted to user's own records
- No public database usage

## Privacy Manifest

As required by Apple, we declare:

**Tracking Domains**: None

**Required Reason APIs**:
- ARKit Face Tracking: Emotion recognition for adaptive storytelling
- File Timestamp Access: Save file validation
- User Defaults: App preferences storage

**Data Types Collected**: None

**Data Linked to User**: CloudKit story saves (deletable by user)

**Data Not Linked to User**: Anonymous crash reports (via Xcode Organizer)

## Security Updates

We will:
- Release security patches as soon as possible
- Notify users via App Store update notes
- Publish security advisories for critical vulnerabilities
- Credit researchers (with permission) in release notes

## Bug Bounty

We currently do not have a formal bug bounty program, but we deeply appreciate security research and will:
- Publicly thank researchers in our CONTRIBUTORS.md
- Mention you in security advisories (with permission)
- Consider feature requests from security contributors

## Best Practices for Users

To keep your data secure:
- Keep visionOS updated to the latest version
- Use a strong iCloud password with 2FA enabled
- Review app permissions in Settings
- Report suspicious behavior immediately

## Compliance

**Apple App Store Guidelines**:
- Full compliance with App Store Review Guidelines
- Privacy manifest included
- No hidden features or undocumented behavior

**COPPA (Children's Online Privacy Protection Act)**:
- App rated 12+ (no children under 12)
- No data collection from minors

**GDPR (for EU users)**:
- Right to access: Export CloudKit data via Settings
- Right to deletion: Delete CloudKit data via Settings
- Right to portability: Export save files in JSON format

## Security Audit History

| Date | Auditor | Scope | Findings |
|------|---------|-------|----------|
| TBD  | TBD     | TBD   | TBD      |

(To be updated after security audits)

## Contact

For security concerns: **[INSERT SECURITY EMAIL]**

For general questions: **[INSERT GENERAL EMAIL]**

---

**Last Updated**: 2025-11-19
