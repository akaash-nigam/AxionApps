# Security Policy

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| 1.0.x   | :white_check_mark: |
| < 1.0   | :x:                |

## Reporting a Vulnerability

**DO NOT** open public issues for security vulnerabilities.

### How to Report

Email: security@tacticalsquad.com

Include:
- Description of the vulnerability
- Steps to reproduce
- Potential impact
- Suggested fix (if any)

### Response Timeline

- **Acknowledgment**: Within 24 hours
- **Initial Assessment**: Within 72 hours
- **Status Updates**: Weekly
- **Fix Timeline**: Depends on severity

### Severity Levels

**Critical** (Fix within 24-48 hours):
- Remote code execution
- Authentication bypass
- Data breach

**High** (Fix within 1 week):
- Privilege escalation
- Significant data exposure

**Medium** (Fix within 1 month):
- DoS vulnerabilities
- Information disclosure

**Low** (Fix in next release):
- Minor information leaks
- Low-impact issues

## Security Best Practices

### For Contributors

1. **Never commit secrets**:
   - API keys
   - Passwords
   - Private keys
   - Certificates

2. **Validate all input**:
   ```swift
   func validateUsername(_ username: String) -> Bool {
       // Check length
       guard username.count >= 3 && username.count <= 20 else {
           return false
       }

       // Check characters
       let allowedCharacters = CharacterSet.alphanumerics
       return username.unicodeScalars.allSatisfy {
           allowedCharacters.contains($0)
       }
   }
   ```

3. **Use secure random**:
   ```swift
   // ✅ Secure
   var bytes = [UInt8](repeating: 0, count: 32)
   _ = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)

   // ❌ Insecure
   let insecure = Int.random(in: 0...100)
   ```

4. **Sanitize user data**:
   ```swift
   func sanitizeInput(_ input: String) -> String {
       input
           .trimmingCharacters(in: .whitespacesAndNewlines)
           .replacingOccurrences(of: "<", with: "&lt;")
           .replacingOccurrences(of: ">", with: "&gt;")
   }
   ```

### For Players

1. **Use strong passwords**
2. **Enable two-factor authentication** (when available)
3. **Keep app updated**
4. **Report suspicious behavior**
5. **Don't share account credentials**

## Known Security Considerations

### Network Security

- All network traffic uses encrypted channels
- Server validates all client inputs
- Rate limiting implemented
- DDoS protection active

### Data Privacy

- User data encrypted at rest
- Minimal data collection
- GDPR compliant
- See [PRIVACY_POLICY.md](PRIVACY_POLICY.md)

### Anti-Cheat

- Server-authoritative game state
- Input validation
- Anomaly detection
- Regular security audits

## Security Features

- ✅ Encrypted network communications
- ✅ Server-side validation
- ✅ Input sanitization
- ✅ Rate limiting
- ✅ Secure random number generation
- ✅ No hardcoded secrets

## Dependencies

We use only Apple frameworks with no third-party dependencies, reducing attack surface.

## Bug Bounty

Currently no formal bug bounty program. Security researchers who responsibly disclose vulnerabilities will be acknowledged in release notes (with permission).

## Disclosure Policy

After fix is deployed:
1. Security advisory published
2. CVE requested if applicable
3. Credit given to reporter
4. Details disclosed after 90 days

## Security Updates

Security patches released as soon as possible:
- **Critical**: Immediate hotfix
- **High**: Within 1 week
- **Medium/Low**: Next regular update

## Questions?

For security questions (non-sensitive):
- Open GitHub Discussion
- Tag with `security` label

For vulnerabilities:
- Email security@tacticalsquad.com
- Use PGP key if available

---

**Last Updated**: 2025-11-19
