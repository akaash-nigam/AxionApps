# Architecture Decision Records

This directory contains Architecture Decision Records (ADRs) for the Business Operating System visionOS application.

## What is an ADR?

An ADR is a document that captures an important architectural decision made along with its context and consequences.

## ADR Index

| ADR | Title | Status |
|-----|-------|--------|
| [0001](0001-mvvm-with-observable.md) | MVVM Architecture with @Observable | Accepted |
| [0002](0002-dependency-injection.md) | Service Container Dependency Injection | Accepted |
| [0003](0003-entity-pooling-for-3d.md) | Entity Pooling for 3D Performance | Accepted |
| [0004](0004-barnes-hut-layout.md) | Barnes-Hut Algorithm for Force-Directed Layout | Accepted |
| [0005](0005-progressive-immersion.md) | Progressive Immersion Levels | Accepted |

## Creating New ADRs

1. Copy the template below
2. Name file as `NNNN-short-title.md` where NNNN is the next number
3. Fill in all sections
4. Update this index

## Template

```markdown
# ADR NNNN: Title

## Status
[Proposed | Accepted | Deprecated | Superseded by ADR-XXXX]

## Context
What is the issue that we're seeing that is motivating this decision or change?

## Decision
What is the change that we're proposing and/or doing?

## Consequences
What becomes easier or more difficult to do because of this change?
```

## References

- [Michael Nygard's ADR article](https://cognitect.com/blog/2011/11/15/documenting-architecture-decisions)
- [ADR GitHub organization](https://adr.github.io/)
