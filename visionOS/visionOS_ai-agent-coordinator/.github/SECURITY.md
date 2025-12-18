# Security Policy

## Supported Versions

We release security updates for the following versions:

| Version | Supported          |
| ------- | ------------------ |
| 1.0.x   | :white_check_mark: |
| < 1.0   | :x:                |

## Reporting a Vulnerability

We take the security of AI Agent Coordinator seriously. If you discover a security vulnerability, please follow responsible disclosure practices.

### Where to Report

**Email**: security@aiagentcoordinator.dev
**PGP Key**: Available at https://aiagentcoordinator.dev/pgp.txt

### What to Include

When reporting a vulnerability, please include:

1. **Description**: Clear description of the vulnerability
2. **Impact**: Potential impact if exploited
3. **Reproduction**: Step-by-step instructions to reproduce
4. **Environment**: Platform, version, configuration
5. **Proof of Concept**: If applicable (do not exploit in production)
6. **Suggested Fix**: If you have recommendations

### What NOT to Do

- **Do NOT** disclose the vulnerability publicly before we've had a chance to address it
- **Do NOT** exploit the vulnerability in production environments
- **Do NOT** access, modify, or delete data that doesn't belong to you
- **Do NOT** perform DoS attacks

### Response Timeline

- **24 hours**: Initial acknowledgment
- **7 days**: Initial assessment and severity classification
- **30 days**: Fix development and testing
- **60 days**: Fix deployed to production
- **90 days**: Public disclosure (coordinated with reporter)

### Severity Classification

We use CVSS 3.1 to classify vulnerabilities:

- **Critical (9.0-10.0)**: Immediate attention, emergency patch
- **High (7.0-8.9)**: Next release cycle, expedited if needed
- **Medium (4.0-6.9)**: Regular release cycle
- **Low (0.1-3.9)**: Future release or documented

### Bug Bounty Program

While we don't currently have a formal bug bounty program, we do recognize security researchers:

- **Public acknowledgment** in our security hall of fame
- **Swag** for significant findings
- **Monetary rewards** considered for critical vulnerabilities (case-by-case)

### Scope

**In Scope**:
- visionOS application
- Backend APIs (if applicable)
- Web services and documentation sites

**Out of Scope**:
- Social engineering
- Physical attacks
- Denial of Service (DoS/DDoS)
- Third-party services (report to them directly)
- Already known and documented issues

### Security Best Practices

For users:
1. Keep visionOS updated
2. Use strong, unique passwords
3. Enable two-factor authentication where available
4. Never share API keys or credentials
5. Review connected platforms regularly

For developers:
1. Follow secure coding guidelines (see CONTRIBUTING.md)
2. Use dependency scanning tools
3. Perform code reviews for security
4. Never commit secrets to git
5. Use environment variables for sensitive data

### Contact

For security concerns, contact security@aiagentcoordinator.dev

For general inquiries, use support@aiagentcoordinator.dev

---

**Note**: This security policy may be updated. Check back regularly or watch the repository for notifications.

Last updated: 2025-01-20
