# Service Level Agreement (SLA)

**Financial Trading Dimension - Service Level Agreement**

**Effective Date**: [Date]
**Version**: 1.0
**Last Updated**: 2025-11-17

---

## 1. Agreement Overview

This Service Level Agreement ("SLA") describes the service levels that Financial Trading Dimension Inc. ("Company", "we", "us") commits to provide to its subscribers ("Customer", "you") for the Financial Trading Dimension application ("Service").

### 1.1 Parties

**Provider**: Financial Trading Dimension Inc.
**Customer**: Subscriber to Financial Trading Dimension services

### 1.2 Term

This SLA is effective upon Customer's subscription to the Service and remains in effect for the duration of the subscription period, subject to the terms outlined in the Terms of Service.

### 1.3 Agreement Updates

We reserve the right to modify this SLA with 30 days' advance notice to Customers. Continued use of the Service after the effective date of changes constitutes acceptance of the modified SLA.

---

## 2. Service Tiers

### 2.1 Free Tier

**Availability**: Best effort
**Support**: Community forum only
**Data**: 15-minute delayed market data
**Features**: Limited to basic functionality
**SLA Coverage**: Not covered by this SLA

### 2.2 Premium Tier

**Monthly Subscription**: $29.99/month
**Availability Target**: 99.5% uptime
**Support**: Email support (24-48 hour response)
**Data**: Real-time market data
**Features**: Full feature access
**SLA Coverage**: Full SLA applies

### 2.3 Professional Tier

**Monthly Subscription**: $99.99/month
**Availability Target**: 99.9% uptime
**Support**: Priority email + chat (4-12 hour response)
**Data**: Real-time + extended hours data
**Features**: Full access + advanced analytics
**SLA Coverage**: Enhanced SLA with higher credits

### 2.4 Enterprise Tier

**Subscription**: Custom pricing
**Availability Target**: 99.95% uptime
**Support**: Dedicated account manager, phone support (1-4 hour response)
**Data**: Real-time + historical + custom data feeds
**Features**: Full access + custom features
**SLA Coverage**: Custom SLA with maximum credits

---

## 3. Service Availability

### 3.1 Uptime Commitment

#### Definition of Uptime

"Uptime" means the Service is operational and accessible to Customers. Downtime is measured as any period when the Service is unavailable to the majority of users.

#### Uptime Percentage Calculation

```
Uptime % = (Total Minutes in Month - Downtime Minutes) / Total Minutes in Month × 100
```

#### Uptime Targets by Tier

| Tier | Monthly Uptime Target | Maximum Downtime/Month |
|------|----------------------|------------------------|
| Premium | 99.5% | 3.6 hours |
| Professional | 99.9% | 43.2 minutes |
| Enterprise | 99.95% | 21.6 minutes |

### 3.2 Excluded Downtime

The following do not count as Downtime for SLA purposes:

1. **Scheduled Maintenance**
   - Maintenance windows: Sundays 2:00 AM - 6:00 AM ET
   - Advance notice: 48 hours minimum
   - Maximum frequency: Twice per month
   - Maximum duration: 4 hours per event

2. **Emergency Maintenance**
   - Critical security patches
   - Notice: As soon as practicable
   - Duration: Minimized to extent possible

3. **Customer-Caused Downtime**
   - Network issues on customer side
   - Device issues
   - Incorrect configuration
   - Violation of Terms of Service

4. **Force Majeure Events**
   - Natural disasters
   - War, terrorism, civil unrest
   - Government actions
   - Internet service provider failures
   - Third-party service failures beyond our control

5. **Third-Party Service Disruptions**
   - Market data provider outages
   - Broker API unavailability
   - Cloud infrastructure provider issues (AWS, etc.)

6. **Free Tier Usage**
   - Free tier is excluded from SLA coverage

### 3.3 Uptime Measurement

- Monitored 24/7/365
- Measured in 1-minute intervals
- Automated monitoring from multiple geographic locations
- Status page available at: status.financialtradingdimension.com

---

## 4. Performance Targets

### 4.1 Response Time

#### Application Performance

| Metric | Premium | Professional | Enterprise |
|--------|---------|--------------|------------|
| App Launch | < 3s | < 2s | < 2s |
| Market Data Latency | < 500ms | < 200ms | < 100ms |
| Order Execution | < 1s | < 500ms | < 300ms |
| API Response Time | < 1s | < 500ms | < 300ms |

#### Data Freshness

| Data Type | Premium | Professional | Enterprise |
|-----------|---------|--------------|------------|
| Stock Quotes | Real-time | Real-time | Real-time |
| Market Data | 1-second updates | 1-second updates | Sub-second |
| Order Status | 2-second updates | 1-second updates | Real-time |
| Portfolio Sync | 30 seconds | 10 seconds | 5 seconds |

### 4.2 Performance Measurement

- Response times measured from application server
- Based on 95th percentile (p95) of all requests
- Excludes network latency outside our infrastructure
- Measured over each calendar month

### 4.3 Performance Degradation

If performance consistently falls below targets:

**Premium**: No specific remedies (best effort)
**Professional**: 10% service credit if below target >10% of month
**Enterprise**: Custom remedies as specified in enterprise agreement

---

## 5. Support Services

### 5.1 Support Channels

#### Premium Tier
- **Email**: support@financialtradingdimension.com
- **Community Forum**: community.financialtradingdimension.com
- **Documentation**: docs.financialtradingdimension.com

#### Professional Tier
- All Premium channels, plus:
- **Priority Email**: priority@financialtradingdimension.com
- **In-App Chat**: Available during business hours
- **Phone**: Callback upon request

#### Enterprise Tier
- All Professional channels, plus:
- **Dedicated Account Manager**
- **Direct Phone Line**: 24/7 emergency line
- **Slack Channel**: Direct integration with our support team

### 5.2 Response Time Targets

| Priority | Premium | Professional | Enterprise |
|----------|---------|--------------|------------|
| Critical (P1) | 24 hours | 4 hours | 1 hour |
| High (P2) | 48 hours | 12 hours | 4 hours |
| Medium (P3) | 5 business days | 2 business days | 1 business day |
| Low (P4) | 7 business days | 5 business days | 2 business days |

#### Priority Definitions

**P1 - Critical**: Service completely unavailable, or critical trading function broken affecting multiple users.

**P2 - High**: Major feature unavailable or severely degraded, significant impact on trading ability.

**P3 - Medium**: Minor feature issue, workaround available, moderate impact.

**P4 - Low**: Cosmetic issue, feature request, or question with minimal impact.

### 5.3 Support Hours

#### Premium & Professional
- **Email Support**: 24/7 (response during business hours)
- **Business Hours**: Monday - Friday, 9:00 AM - 6:00 PM ET
- **Holidays**: Closed on major U.S. holidays

#### Enterprise
- **Critical Support**: 24/7/365
- **General Support**: 24/5 (Monday - Friday)
- **Account Manager**: Business hours

### 5.4 Resolution Time Targets

| Priority | Target Resolution Time |
|----------|----------------------|
| P1 | 12 hours (best effort) |
| P2 | 48 hours |
| P3 | 10 business days |
| P4 | 20 business days |

**Note**: Resolution time targets are goals, not guarantees. Actual resolution depends on issue complexity.

---

## 6. Data Accuracy and Integrity

### 6.1 Market Data Accuracy

We strive for accurate market data but do not guarantee accuracy, as we rely on third-party providers.

**Commitment**:
- Source data from reputable providers
- Implement validation checks
- Display data disclaimers
- Provide data timestamps

**No Guarantee**: Market data is provided "as is" without warranty. Not liable for trading decisions based on data.

### 6.2 Portfolio Data Integrity

**Commitment**:
- Daily backups of portfolio data
- Data encryption at rest and in transit
- Multi-region redundancy
- Point-in-time recovery capability

**Recovery Point Objective (RPO)**:
- Premium: 24 hours
- Professional: 4 hours
- Enterprise: 1 hour

**Recovery Time Objective (RTO)**:
- Premium: 24 hours
- Professional: 8 hours
- Enterprise: 2 hours

### 6.3 Data Retention

| Data Type | Retention Period |
|-----------|-----------------|
| Trade History | 7 years (regulatory requirement) |
| Portfolio History | Account lifetime + 7 years |
| Market Data | Real-time (not historical storage) |
| Account Settings | Account lifetime |
| Support Tickets | 3 years |
| Audit Logs | 7 years |

---

## 7. Security and Compliance

### 7.1 Security Commitments

- **Encryption**: TLS 1.3 for data in transit, AES-256 for data at rest
- **Authentication**: Multi-factor authentication available
- **Access Control**: Role-based access control
- **Monitoring**: 24/7 security monitoring
- **Audits**: Annual third-party security audits

### 7.2 Compliance

- **GDPR**: Compliant for EU users
- **CCPA**: Compliant for California residents
- **SOC 2 Type II**: Certification in progress
- **ISO 27001**: Certification planned

### 7.3 Data Breach Notification

In the event of a data breach affecting Customer data:

1. **Notification Timeline**: Within 72 hours of discovery
2. **Notification Method**: Email to registered email address
3. **Information Provided**:
   - Nature of the breach
   - Data potentially affected
   - Steps being taken
   - Recommended customer actions

---

## 8. Service Credits

### 8.1 Eligibility

Service credits are available when monthly uptime falls below the target for your tier. Credits are applied automatically to the next billing cycle.

### 8.2 Credit Schedule

#### Premium Tier (99.5% target)

| Monthly Uptime | Service Credit |
|----------------|----------------|
| < 99.5% to 99.0% | 10% of monthly fee |
| < 99.0% to 98.0% | 25% of monthly fee |
| < 98.0% | 50% of monthly fee |

#### Professional Tier (99.9% target)

| Monthly Uptime | Service Credit |
|----------------|----------------|
| < 99.9% to 99.5% | 15% of monthly fee |
| < 99.5% to 99.0% | 30% of monthly fee |
| < 99.0% | 50% of monthly fee |

#### Enterprise Tier (99.95% target)

| Monthly Uptime | Service Credit |
|----------------|----------------|
| < 99.95% to 99.9% | 20% of monthly fee |
| < 99.9% to 99.5% | 40% of monthly fee |
| < 99.5% | 100% of monthly fee |

### 8.3 Credit Limitations

- **Maximum Credit**: 100% of one month's subscription fee
- **No Rollover**: Credits expire if not used within 12 months
- **No Cash Value**: Credits cannot be redeemed for cash
- **Automatic Application**: Credits applied automatically; no request needed
- **Calculation Period**: Credits calculated monthly

### 8.4 Requesting Credits

While credits are applied automatically, you may request verification:

1. Email: sla@financialtradingdimension.com
2. Include: Account ID, month in question, evidence of downtime
3. Response within 10 business days
4. Decision is final

---

## 9. Customer Responsibilities

### 9.1 Requirements

To receive SLA benefits, Customer must:

1. **Maintain Valid Subscription**: Active, paid subscription in good standing
2. **Use Supported Configuration**:
   - Apple Vision Pro device
   - visionOS 2.0 or later
   - Stable internet connection (minimum 5 Mbps)
3. **Comply with Terms**: Adhere to Terms of Service
4. **Report Issues Promptly**: Report outages within 24 hours
5. **Provide Information**: Cooperate with troubleshooting

### 9.2 Prohibited Uses

SLA does not apply if Customer:

- Uses Service for unauthorized purposes
- Reverse engineers, modifies, or hacks the application
- Exceeds fair use or rate limits
- Violates securities laws or regulations
- Engages in fraudulent activity

---

## 10. Limitations of Liability

### 10.1 Exclusive Remedy

Service credits are your **sole and exclusive remedy** for any failure to meet this SLA.

### 10.2 Disclaimers

**NO WARRANTY**: Service provided "AS IS" without warranty of any kind.

**NO LIABILITY FOR**:
- Trading losses due to service unavailability
- Inaccurate market data from third-party providers
- Broker execution issues
- Missed trading opportunities
- Loss of profits or business
- Indirect, incidental, consequential damages

### 10.3 Maximum Liability

In no event shall our total liability exceed the amount paid by Customer in the 12 months preceding the claim, or $1,000, whichever is less.

### 10.4 Third-Party Dependencies

We are not liable for failures of:
- Market data providers
- Broker APIs
- Cloud infrastructure (AWS, Azure, etc.)
- Internet service providers
- Apple Vision Pro hardware/software

---

## 11. Monitoring and Reporting

### 11.1 Status Page

Real-time service status available at:
**https://status.financialtradingdimension.com**

Displays:
- Current operational status
- Ongoing incidents
- Scheduled maintenance
- Historical uptime (90 days)

### 11.2 Incident Communication

During incidents:

1. **Status Page Update**: Within 15 minutes of detection
2. **Email Notification**: To affected premium/professional/enterprise users
3. **Regular Updates**: Every 2 hours until resolved
4. **Post-Incident Review**: Published within 5 business days

### 11.3 Monthly Reports

**Professional and Enterprise tiers receive**:
- Monthly uptime statistics
- Performance metrics
- Incident summary
- Planned maintenance schedule

Available in: Settings > Account > Service Reports

---

## 12. Maintenance Windows

### 12.1 Scheduled Maintenance

**Standard Window**:
- **When**: Sundays, 2:00 AM - 6:00 AM ET
- **Frequency**: Maximum twice per month
- **Duration**: Maximum 4 hours
- **Notice**: 48 hours minimum via email and status page

**Extended Maintenance** (rare):
- **When**: By arrangement
- **Duration**: Up to 8 hours
- **Notice**: 2 weeks minimum
- **Credits**: Not eligible for service credits

### 12.2 Emergency Maintenance

Performed when necessary for:
- Critical security patches
- Data integrity issues
- Infrastructure failures

**Notice**: Best effort, as soon as practicable
**Credits**: Emergency maintenance counts toward SLA uptime calculation

---

## 13. Geographic Scope

### 13.1 Service Availability

Service is available globally, subject to:
- Local internet connectivity
- Regulatory compliance
- Market data licensing restrictions

### 13.2 Restricted Regions

Service may not be available or may have limited functionality in:
- Countries under U.S. sanctions
- Regions where securities trading is prohibited
- Jurisdictions where we lack regulatory approval

### 13.3 Performance by Region

SLA performance targets apply globally, but actual performance may vary by:
- Geographic distance from data centers
- Local internet infrastructure
- Regulatory requirements

---

## 14. Definitions

**Availability**: Percentage of time Service is operational and accessible.

**Business Hours**: Monday - Friday, 9:00 AM - 6:00 PM Eastern Time, excluding U.S. federal holidays.

**Customer**: Individual or entity subscribing to the Service.

**Downtime**: Period when Service is unavailable to majority of users, as measured by our monitoring systems.

**Monthly Uptime Percentage**: Calculated as described in Section 3.1.

**Response Time**: Time from when support request is received to when first response is provided.

**Resolution Time**: Time from when issue is reported to when it is resolved.

**Service**: Financial Trading Dimension application and associated backend services.

**Service Credit**: Credit applied to future subscription fees as compensation for SLA failures.

---

## 15. Contact Information

### 15.1 SLA Questions

**Email**: sla@financialtradingdimension.com
**Response Time**: 5 business days

### 15.2 Support

See Section 5 for support contact information by tier.

### 15.3 Legal

**Email**: legal@financialtradingdimension.com
**Address**:
Financial Trading Dimension Inc.
123 Market Street, Suite 500
San Francisco, CA 94105
United States

---

## 16. Changes to This SLA

### 16.1 Modification Process

We may modify this SLA by:

1. Posting updated SLA to our website
2. Notifying Customers via email (30 days advance notice)
3. Providing summary of changes

### 16.2 Customer Options

If you do not agree to modified SLA:

- You may cancel subscription before effective date
- Continued use after effective date constitutes acceptance

---

## 17. Severability

If any provision of this SLA is found to be unenforceable or invalid, that provision will be limited or eliminated to the minimum extent necessary so that this SLA will otherwise remain in full force and effect.

---

## 18. Governing Law

This SLA is governed by the laws of the State of California, United States, without regard to conflict of law principles.

---

## Appendix A: Service Level Summary Table

| Metric | Premium | Professional | Enterprise |
|--------|---------|--------------|------------|
| **Availability** |
| Monthly Uptime | 99.5% | 99.9% | 99.95% |
| Max Downtime/Month | 3.6 hours | 43 minutes | 22 minutes |
| **Performance** |
| App Launch | < 3s | < 2s | < 2s |
| Market Data Latency | < 500ms | < 200ms | < 100ms |
| Order Execution | < 1s | < 500ms | < 300ms |
| **Support** |
| P1 Response | 24h | 4h | 1h |
| P2 Response | 48h | 12h | 4h |
| Support Hours | Business | 24/5 | 24/7 |
| **Data** |
| Backup RPO | 24h | 4h | 1h |
| Recovery RTO | 24h | 8h | 2h |
| **Credits** |
| Max Monthly Credit | 50% | 50% | 100% |

---

## Appendix B: Service Status Definitions

### Status Levels

**Operational** 🟢: All systems functioning normally.

**Degraded Performance** 🟡: Service operational but slower than normal. No action required from users.

**Partial Outage** 🟠: Some features unavailable. Core functionality working. May impact subset of users.

**Major Outage** 🔴: Critical features unavailable. Significant impact. Actively working on resolution.

**Under Maintenance** 🔵: Scheduled maintenance in progress. Expected downtime.

### Incident Severity

**Severity 1 (Critical)**: Complete service outage affecting all or most users.

**Severity 2 (High)**: Major functionality unavailable, significant user impact.

**Severity 3 (Medium)**: Minor functionality issue, limited user impact, workaround available.

**Severity 4 (Low)**: Cosmetic issue or minor bug, minimal impact.

---

## Appendix C: Uptime Calculation Examples

### Example 1: Premium Tier

**Month**: January 2025 (31 days = 44,640 minutes)
**Downtime**:
- Scheduled maintenance: 2 hours (excluded)
- Unplanned outage: 3 hours = 180 minutes

**Calculation**:
```
Uptime % = (44,640 - 180) / 44,640 × 100 = 99.60%
```

**Result**: 99.60% > 99.5% target ✅ No service credit

### Example 2: Professional Tier

**Month**: February 2025 (28 days = 40,320 minutes)
**Downtime**:
- Scheduled maintenance: 1.5 hours (excluded)
- Emergency maintenance: 30 minutes (included)
- Unplanned outage: 45 minutes

**Total Downtime**: 75 minutes

**Calculation**:
```
Uptime % = (40,320 - 75) / 40,320 × 100 = 99.81%
```

**Result**: 99.81% < 99.9% target ❌
**Service Credit**: 15% of monthly fee

---

**Effective Date**: January 1, 2026
**Version**: 1.0
**Last Updated**: November 17, 2025

---

**Acceptance**

By using Financial Trading Dimension, you acknowledge that you have read, understood, and agree to be bound by this Service Level Agreement.

---

*This SLA is incorporated by reference into the Financial Trading Dimension Terms of Service.*
