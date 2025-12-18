# Documentation Index

Complete documentation guide for the Narrative Story Worlds visionOS project.

## Quick Links

- **[README.md](README.md)** - Start here! Project overview and getting started
- **[CONTRIBUTING.md](CONTRIBUTING.md)** - How to contribute to the project
- **[CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md)** - Community guidelines
- **[SECURITY.md](SECURITY.md)** - Security policies and reporting
- **[RELEASE_CHECKLIST.md](RELEASE_CHECKLIST.md)** - Pre-release verification steps

---

## For Developers

### Getting Started

1. **[README.md](README.md)** - Project overview, setup, and requirements
2. **[CONTRIBUTING.md](CONTRIBUTING.md)** - Development workflow and guidelines
3. **[IMPLEMENTATION_PLAN.md](IMPLEMENTATION_PLAN.md)** - 22-week development roadmap

### Architecture & Design

- **[ARCHITECTURE.md](ARCHITECTURE.md)** - Technical architecture and system design
  - System overview
  - Component architecture
  - Data flow
  - Technology stack
  - Performance considerations

- **[TECHNICAL_SPEC.md](TECHNICAL_SPEC.md)** - Detailed technical specifications
  - Core systems
  - AI implementation
  - Spatial computing
  - Audio systems
  - Persistence
  - Security & privacy

- **[DESIGN.md](DESIGN.md)** - Game design document
  - Narrative design
  - Game mechanics
  - UI/UX design
  - Visual style
  - User experience flow

### Testing

- **[NarrativeStoryWorlds/Tests/README.md](NarrativeStoryWorlds/Tests/README.md)** - Main testing guide
  - Running tests
  - Test types
  - Coverage goals
  - CI/CD integration

- **[NarrativeStoryWorlds/Tests/TEST_STRATEGY.md](NarrativeStoryWorlds/Tests/TEST_STRATEGY.md)** - Comprehensive test strategy
  - Test categories
  - Coverage matrix
  - CI/CD pipelines
  - Performance baselines

- **[NarrativeStoryWorlds/Tests/VISIONOS_HARDWARE_TESTS.md](NarrativeStoryWorlds/Tests/VISIONOS_HARDWARE_TESTS.md)** - Hardware test procedures
  - ARKit tests
  - Spatial audio tests
  - Gesture recognition tests
  - Performance tests

- **[NarrativeStoryWorlds/Tests/TEST_EXECUTION_REPORT.md](NarrativeStoryWorlds/Tests/TEST_EXECUTION_REPORT.md)** - Test execution status
  - Test coverage summary
  - Execution instructions
  - Environment requirements

### Landing Page

- **[landing-page/README.md](landing-page/README.md)** - Landing page documentation
  - Deployment options
  - Customization guide
  - SEO optimization
  - Analytics integration

---

## For Product Managers

### Product Strategy

- **[Narrative-Story-Worlds-PRD.md](Narrative-Story-Worlds-PRD.md)** - Product Requirements Document
  - Product vision
  - User personas
  - Feature requirements
  - Success metrics

- **[Narrative-Story-Worlds-PRFAQ.md](Narrative-Story-Worlds-PRFAQ.md)** - Press Release / FAQ
  - Product positioning
  - Value proposition
  - Common questions
  - Launch messaging

### Implementation

- **[IMPLEMENTATION_PLAN.md](IMPLEMENTATION_PLAN.md)** - Development roadmap
  - Phase breakdown (22 weeks)
  - Milestones
  - Dependencies
  - Risk mitigation

---

## For QA / Testing

### Test Execution

1. **[NarrativeStoryWorlds/Tests/README.md](NarrativeStoryWorlds/Tests/README.md)** - Start here for testing overview
2. **[NarrativeStoryWorlds/Tests/TEST_STRATEGY.md](NarrativeStoryWorlds/Tests/TEST_STRATEGY.md)** - Understand test strategy
3. **[NarrativeStoryWorlds/Tests/VISIONOS_HARDWARE_TESTS.md](NarrativeStoryWorlds/Tests/VISIONOS_HARDWARE_TESTS.md)** - Execute hardware tests

### Release

- **[RELEASE_CHECKLIST.md](RELEASE_CHECKLIST.md)** - Pre-release verification
  - Code quality checks
  - Test execution
  - Beta testing
  - App Store submission

---

## For Content Creators

### Story Development

- **[DESIGN.md](DESIGN.md)** - Game design and narrative structure
- **[NarrativeStoryWorlds/Resources/README.md](NarrativeStoryWorlds/Resources/README.md)** - Asset organization
  - Story content structure
  - Audio asset guidelines
  - Character definitions

### Sample Content

- **[NarrativeStoryWorlds/Resources/SampleContent/Episode1Story.swift](NarrativeStoryWorlds/Resources/SampleContent/Episode1Story.swift)** - Episode 1 story implementation
  - Character creation
  - Dialogue trees
  - Choice branching
  - Achievement definitions

---

## For Community

### Contributing

- **[CONTRIBUTING.md](CONTRIBUTING.md)** - Contribution guidelines
  - How to contribute
  - Coding standards
  - Pull request process
  - Commit conventions

- **[CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md)** - Community standards
  - Expected behavior
  - Reporting issues
  - Enforcement

### Security

- **[SECURITY.md](SECURITY.md)** - Security policies
  - Reporting vulnerabilities
  - Security considerations
  - Privacy practices

---

## Reference Documentation

### Code Organization

```
NarrativeStoryWorlds/
├── App/                    # Main app entry and state
├── Core/                   # Game state management
├── Game/                   # Dialogue, choices, story
├── Spatial/                # Room scanning, character positioning
├── Models/                 # Data models
├── Persistence/            # Save/load
├── Views/                  # UI components
├── AI/                     # AI systems
│   ├── StoryDirector/      # Pacing & branching
│   ├── Character/          # Character AI
│   ├── EmotionRecognition/ # Player emotion
│   └── Dialogue/           # Dialogue generation
├── Audio/                  # Spatial audio & haptics
├── Input/                  # Gesture recognition
├── Resources/              # Assets & content
└── Tests/                  # Test suite
```

### Key Files

| File | Purpose | Audience |
|------|---------|----------|
| `README.md` | Project overview | Everyone |
| `ARCHITECTURE.md` | System design | Developers |
| `TECHNICAL_SPEC.md` | Technical details | Developers |
| `DESIGN.md` | Game design | Designers, PMs |
| `IMPLEMENTATION_PLAN.md` | Development roadmap | Developers, PMs |
| `CONTRIBUTING.md` | Contribution guide | Contributors |
| `CODE_OF_CONDUCT.md` | Community rules | Community |
| `SECURITY.md` | Security policy | Security researchers |
| `RELEASE_CHECKLIST.md` | Release process | QA, Release managers |

---

## GitHub-Specific Documentation

### Issue Templates

- **[.github/ISSUE_TEMPLATE/bug_report.yml](.github/ISSUE_TEMPLATE/bug_report.yml)** - Bug report template
- **[.github/ISSUE_TEMPLATE/feature_request.yml](.github/ISSUE_TEMPLATE/feature_request.yml)** - Feature request template
- **[.github/ISSUE_TEMPLATE/hardware_test_report.yml](.github/ISSUE_TEMPLATE/hardware_test_report.yml)** - Hardware test report

### PR Template

- **[.github/PULL_REQUEST_TEMPLATE.md](.github/PULL_REQUEST_TEMPLATE.md)** - Pull request template

### Workflows

- **[.github/workflows/test.yml](.github/workflows/test.yml)** - Automated testing
- **[.github/workflows/lint.yml](.github/workflows/lint.yml)** - Code linting
- **[.github/workflows/release.yml](.github/workflows/release.yml)** - Release automation

---

## External Resources

### Apple Documentation

- [visionOS Documentation](https://developer.apple.com/documentation/visionos)
- [RealityKit Documentation](https://developer.apple.com/documentation/realitykit)
- [ARKit Documentation](https://developer.apple.com/documentation/arkit)
- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui)
- [App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)

### Learning Resources

- [Swift Programming Language](https://docs.swift.org/swift-book/)
- [Swift Concurrency](https://docs.swift.org/swift-book/LanguageGuide/Concurrency.html)
- [Spatial Computing Design Principles](https://developer.apple.com/design/human-interface-guidelines/designing-for-visionos)

---

## Documentation Standards

### Writing Style

- Use clear, concise language
- Write in present tense
- Use active voice
- Include code examples where helpful
- Keep paragraphs short (3-5 sentences)

### Markdown Conventions

- Use ATX-style headings (`#` not underlines)
- Include table of contents for long documents
- Use code blocks with language specification
- Use tables for structured data
- Include links to related documents

### Maintenance

- Update documentation with code changes
- Review quarterly for accuracy
- Mark outdated sections clearly
- Archive old documentation in `/docs/archive/`

---

## Getting Help

### Documentation Issues

If you find errors, outdated information, or missing documentation:

1. Check if the issue is already reported
2. Create an issue with the `documentation` label
3. Suggest improvements via pull request

### Questions

- **Technical questions**: GitHub Discussions
- **Bug reports**: GitHub Issues
- **Security issues**: See [SECURITY.md](SECURITY.md)

---

## Version History

| Date | Version | Changes |
|------|---------|---------|
| 2025-11-19 | 1.0 | Initial documentation index created |

---

**Last Updated**: 2025-11-19
**Maintained By**: Development Team
