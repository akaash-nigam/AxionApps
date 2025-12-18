# Architecture Decision Records (ADRs)

This directory contains Architecture Decision Records (ADRs) for the Wardrobe Consultant project.

## What is an ADR?

An Architecture Decision Record (ADR) is a document that captures an important architectural decision made along with its context and consequences.

## Format

We use the following format for ADRs:

```
# ADR-XXX: [Short Title]

**Status:** [Proposed | Accepted | Deprecated | Superseded]
**Date:** YYYY-MM-DD
**Decision Makers:** [Who was involved]
**Technical Story:** [Link to issue/epic if applicable]

## Context

What is the issue that we're seeing that is motivating this decision or change?

## Decision

What is the change that we're proposing and/or doing?

## Consequences

What becomes easier or more difficult to do because of this change?

### Positive
- List positive consequences

### Negative
- List negative consequences

### Risks
- List potential risks

## Alternatives Considered

What other options were considered and why were they rejected?

## References

- Links to relevant documentation
- Related ADRs
- External resources
```

## Index of ADRs

| ADR | Title | Status | Date |
|-----|-------|--------|------|
| [001](ADR-001-clean-architecture.md) | Adopt Clean Architecture | Accepted | 2025-11-24 |
| [002](ADR-002-swiftui-mvvm.md) | Use SwiftUI with MVVM Pattern | Accepted | 2025-11-24 |
| [003](ADR-003-core-data.md) | Use Core Data for Persistence | Accepted | 2025-11-24 |
| [004](ADR-004-local-first.md) | Implement Local-First Data Strategy | Accepted | 2025-11-24 |
| [005](ADR-005-async-await.md) | Use async/await for Concurrency | Accepted | 2025-11-24 |
| [006](ADR-006-protocol-oriented.md) | Protocol-Oriented Design | Accepted | 2025-11-24 |
| [007](ADR-007-hsl-color-space.md) | Use HSL Color Space for Harmony | Accepted | 2025-11-24 |
| [008](ADR-008-keychain-storage.md) | Store Sensitive Data in Keychain | Accepted | 2025-11-24 |
| [009](ADR-009-visionos-first.md) | Design for visionOS First | Accepted | 2025-11-24 |
| [010](ADR-010-no-third-party-analytics.md) | No Third-Party Analytics | Accepted | 2025-11-24 |

## Creating a New ADR

1. Copy the template above
2. Number it sequentially (next available number)
3. Fill in all sections
4. Submit for review via Pull Request
5. Update this index when accepted

## Review Process

1. Create ADR document
2. Submit PR with ADR
3. Team reviews and discusses
4. Address feedback
5. Merge when consensus reached
6. Update status to "Accepted"

## Superseding ADRs

When an ADR is superseded:
1. Update old ADR status to "Superseded"
2. Link to new ADR
3. Create new ADR explaining changes
4. Reference old ADR in new one

---

Last Updated: 2025-11-24
