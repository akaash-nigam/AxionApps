# Security Policy

## Supported Versions

We release security updates for the following versions of Mystery Investigation:

| Version | Supported          | End of Support |
| ------- | ------------------ | -------------- |
| 1.x.x   | :white_check_mark: | Active         |
| 0.4.x   | :white_check_mark: | Dec 2025       |
| 0.3.x   | :warning:          | Jun 2025       |
| < 0.3.0 | :x:                | Unsupported    |

**Legend:**
* :white_check_mark: - Full security support
* :warning: - Critical security fixes only
* :x: - No longer supported

## Reporting a Vulnerability

We take security seriously. If you discover a security vulnerability, please follow responsible disclosure practices.

### How to Report

**DO NOT** create a public GitHub issue for security vulnerabilities.

Instead, report security issues to:

**Email:** security@mysteryinvestigation.com
**PGP Key:** Available at https://mysteryinvestigation.com/pgp-key.asc (when available)

### What to Include

Please provide as much information as possible:

```
Subject: [SECURITY] Brief description of vulnerability

1. Type of vulnerability
   - e.g., XSS, SQL Injection, Authentication Bypass, etc.

2. Affected component
   - Which part of the app is affected?
   - File names and line numbers if possible

3. Steps to reproduce
   - Detailed steps to reproduce the vulnerability
   - Include code snippets or proof-of-concept

4. Impact assessment
   - What can an attacker do?
   - What data is at risk?
   - Who is affected?

5. Suggested fix (if known)
   - Any ideas on how to fix it?

6. Your details
   - Name (or handle) for credit
   - Contact information for follow-up
```

### Example Report

```
Subject: [SECURITY] Authentication Bypass in Case Loading

Type: Authentication Bypass
Component: CaseManager.swift:loadCase()
Severity: High

Steps to Reproduce:
1. Open app without authenticating
2. Call loadCase() directly with case ID
3. Access premium content without purchase

Impact:
- Users can access paid content without payment
- Affects all users on iOS 1.0.0-1.0.5

Suggested Fix:
Add authentication check before case loading

Reporter: JohnDoe (@johndoe)
Contact: john@example.com
```

## Response Timeline

We commit to the following response timeline:

| Action | Timeline |
|--------|----------|
| **Initial Response** | Within 24 hours |
| **Severity Assessment** | Within 48 hours |
| **Fix Development** | Varies by severity |
| **Security Patch Release** | See table below |
| **Public Disclosure** | After patch released |

### Patch Timeline by Severity

| Severity | Description | Patch Timeline |
|----------|-------------|----------------|
| **Critical** | Remote code execution, data breach | 24-48 hours |
| **High** | Authentication bypass, privilege escalation | 3-7 days |
| **Medium** | XSS, CSRF, information disclosure | 14-30 days |
| **Low** | Minor information leaks, DoS | Next release |

## Vulnerability Disclosure Policy

### Our Commitment

When you report a vulnerability to us:

1. **We will acknowledge** your report within 24 hours
2. **We will validate** the vulnerability within 48 hours
3. **We will work with you** to understand the full scope
4. **We will keep you updated** on our progress
5. **We will credit you** (if desired) when we disclose
6. **We will not take legal action** against good-faith security researchers

### Your Commitment

We ask that you:

1. **Give us reasonable time** to fix the issue before public disclosure
2. **Do not exploit** the vulnerability beyond proof-of-concept
3. **Do not access or modify** user data without permission
4. **Do not perform** denial of service attacks
5. **Make a good faith effort** to avoid privacy violations
6. **Follow responsible disclosure** practices

### Coordinated Disclosure

We follow a 90-day coordinated disclosure timeline:

* **Day 0:** Vulnerability reported
* **Day 1-7:** Investigation and validation
* **Day 7-30:** Patch development
* **Day 30-90:** Testing and deployment
* **Day 90+:** Public disclosure (or earlier if patch is released)

We may request an extension if the fix is complex.

## Security Best Practices

### For Users

**Keep Updated:**
* Enable automatic updates
* Install security patches promptly
* Check for updates weekly

**Protect Your Account:**
* Use strong passwords
* Enable two-factor authentication (when available)
* Don't share account credentials
* Log out on shared devices

**Be Cautious:**
* Don't install the app from unofficial sources
* Verify app signatures
* Be wary of phishing attempts
* Report suspicious activity

### For Developers

**Code Security:**
* Follow secure coding guidelines
* Use parameterized queries (prevent SQL injection)
* Validate and sanitize all inputs
* Implement proper error handling
* Use secure random number generation
* Keep dependencies updated

**Authentication & Authorization:**
* Implement proper authentication
* Use secure session management
* Enforce least privilege principle
* Validate user permissions on server
* Never trust client-side validation alone

**Data Protection:**
* Encrypt sensitive data at rest
* Use TLS for all network communication
* Implement proper key management
* Minimize data collection
* Securely delete data when no longer needed

**RealityKit/ARKit Security:**
* Validate spatial anchor data
* Sanitize user-generated content
* Prevent injection through 3D models
* Limit resource consumption
* Validate scene reconstruction data

## Known Security Considerations

### Platform-Specific

**visionOS/Vision Pro:**
* Spatial data privacy - User environment is captured
* Hand tracking data - Biometric information
* Eye tracking data - Sensitive behavioral data
* Passthrough camera - Visual information about environment

**Mitigations:**
* All spatial data stays on-device
* No hand/eye tracking data is transmitted
* Privacy disclosures in app and privacy policy
* User consent required for each feature

### Third-Party Dependencies

We regularly audit our dependencies for vulnerabilities:

```swift
// Key dependencies (monitored for CVEs)
- RealityKit (Apple, bundled with visionOS)
- ARKit (Apple, bundled with visionOS)
- SwiftUI (Apple, bundled with visionOS)
```

## Security Features

### Current Implementation

**Data Protection:**
* ✅ Save games encrypted at rest (UserDefaults encryption)
* ✅ No sensitive data in logs
* ✅ Secure memory handling
* ✅ No third-party analytics (privacy by design)

**Code Integrity:**
* ✅ App signing with Apple Developer certificate
* ✅ Code obfuscation (Swift optimization)
* ✅ No embedded secrets in source code
* ✅ Environment-based configuration

**Network Security:**
* 🔄 TLS 1.3 for all network requests (planned)
* 🔄 Certificate pinning (planned)
* 🔄 Request signing (planned)

**Input Validation:**
* ✅ Case data JSON schema validation
* ✅ Save game data validation
* ✅ User input sanitization

### Future Enhancements

**Planned for v1.1:**
* [ ] Jailbreak detection
* [ ] Runtime integrity checks
* [ ] Additional encryption for sensitive saves
* [ ] Secure enclave integration (if applicable)

## Compliance

### Privacy Regulations

**GDPR Compliance:**
* Data minimization
* User consent
* Right to erasure
* Data portability

**COPPA Compliance:**
* Age verification
* Parental consent (for under-13 users)
* Limited data collection

**CCPA Compliance:**
* Privacy policy disclosure
* Opt-out mechanisms
* Data deletion requests

### App Store Guidelines

We comply with:
* Apple App Store Review Guidelines
* Apple Vision Pro Developer Guidelines
* Apple Privacy Policy requirements

## Security Audits

### Internal Audits

We conduct internal security reviews:

* **Code Review:** All pull requests reviewed for security
* **Dependency Audit:** Monthly dependency vulnerability scans
* **Penetration Testing:** Quarterly internal pen tests
* **Static Analysis:** Automated SAST on every commit

### External Audits

**Planned:**
* Professional security audit before 1.0 launch
* Annual third-party penetration testing
* Bug bounty program (post-launch)

## Bug Bounty Program

**Status:** Planned for post-launch

**Scope:**
* iOS app (visionOS)
* Backend services (when available)
* Website

**Rewards:**
* Critical: $500-$2,000
* High: $250-$500
* Medium: $100-$250
* Low: $50-$100
* Recognition in Hall of Fame

**Details:** To be announced

## Hall of Fame

Security researchers who have responsibly disclosed vulnerabilities:

_No reports yet - be the first!_

## Contact

**Security Team Email:** security@mysteryinvestigation.com
**Response Time:** Within 24 hours
**Encryption:** PGP available (link TBD)

**Other Security Resources:**
* Security Blog: https://mysteryinvestigation.com/security
* Security Advisories: https://github.com/[org]/visionOS_Gaming_mystery-investigation/security/advisories
* Previous CVEs: None yet

## Version History

* **v1.0.0** - January 19, 2025 - Initial security policy
* Future updates will be documented here

---

**We appreciate the security community's efforts to make Mystery Investigation safe for all users. Thank you for helping us protect our users! 🔒**

---

_Last Updated: January 19, 2025_
