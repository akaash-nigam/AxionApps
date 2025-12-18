# Implementation Instructions for Claude Code Web

## Project Overview
This is a visionOS enterprise application for Apple Vision Pro. Review the PRD in this folder to understand the full requirements and features.

## Implementation Workflow

### IMPORTANT: Always Start with Documentation Phase
Before writing any code, generate the following design and technical documents:

## Phase 1: Document Generation (MANDATORY FIRST STEP)

### 1. Create ARCHITECTURE.md
Generate a comprehensive technical architecture document including:
- System architecture overview and component diagram
- visionOS-specific architecture patterns (Windows, Volumes, Spaces)
- Data models and schemas
- Service layer architecture
- RealityKit and ARKit integration approach
- API design and external integrations
- State management strategy
- Performance optimization strategy
- Security architecture

### 2. Create TECHNICAL_SPEC.md
Generate detailed technical specifications including:
- Technology stack details
  - Swift 6.0+ with modern concurrency
  - SwiftUI for UI components
  - RealityKit for 3D content
  - ARKit for spatial tracking
  - visionOS 2.0+ APIs
- visionOS presentation modes (WindowGroup, ImmersiveSpace, etc.)
- Gesture and interaction specifications
- Hand tracking implementation details
- Eye tracking implementation (if applicable)
- Spatial audio specifications
- Accessibility requirements (VoiceOver, Dynamic Type, etc.)
- Privacy and security requirements
- Data persistence strategy
- Network architecture
- Testing requirements

### 3. Create DESIGN.md
Generate comprehensive UI/UX design specifications including:
- Spatial design principles for this app
- Window layouts and configurations
- Volume designs (3D bounded spaces)
- Full space/immersive experiences
- 3D visualization specifications
- Interaction patterns:
  - Gaze and pinch gestures
  - Hand tracking gestures
  - Voice commands (if applicable)
- Visual design system:
  - Color palette (considering glass materials)
  - Typography (spatial text rendering)
  - Materials and lighting
  - Iconography in 3D space
- User flows and navigation
- Accessibility design
- Error states and loading indicators
- Animation and transition specifications

### 4. Create IMPLEMENTATION_PLAN.md
Generate a detailed implementation roadmap including:
- Development phases with milestones
- Feature breakdown and prioritization
- Sprint planning (if applicable)
- Dependencies and prerequisites
- Risk assessment and mitigation
- Testing strategy:
  - Unit testing approach
  - UI testing for spatial interfaces
  - Integration testing
  - Performance testing
- Deployment plan
- Success metrics

## Phase 2: Project Setup

### 5. Create Xcode Project
- Create new visionOS app project in Xcode 16+
- Configure project settings:
  - Minimum deployment target: visionOS 2.0
  - Enable required capabilities
  - Configure Info.plist entries
- Set up project structure:
  ```
  ProjectName/
  ├── App/
  │   ├── ProjectNameApp.swift
  │   └── ContentView.swift
  ├── Models/
  │   └── DataModels.swift
  ├── Views/
  │   ├── Windows/
  │   ├── Volumes/
  │   └── ImmersiveViews/
  ├── ViewModels/
  ├── Services/
  ├── Utilities/
  ├── Resources/
  │   ├── Assets.xcassets
  │   └── 3DModels/
  └── Tests/
  ```

### 6. Configure Dependencies
- Set up Swift Package Manager dependencies if needed
- Configure Reality Composer Pro files
- Set up any required frameworks

## Phase 3: Core Implementation

### 7. Implement Data Layer
- Create data models (structs/classes)
- Implement @Observable models for SwiftUI
- Set up data persistence (SwiftData, CoreData, or file storage)
- Create networking layer (if applicable)
- Implement caching strategy

### 8. Implement Services Layer
- Business logic services
- API clients
- Data transformation services
- Spatial computing utilities
- Error handling

### 9. Implement UI Components

#### Basic UI Components
- Create reusable SwiftUI components
- Implement custom views
- Create ornaments and toolbars
- Design glass background materials

#### Spatial Components
- RealityKit entities and components
- 3D models and textures
- Volumetric content
- Particle systems (if applicable)
- Spatial audio sources

### 10. Implement Window/Volume/Space Layouts
- Configure WindowGroup definitions
- Create volume content
- Implement ImmersiveSpace views
- Set up scene configurations

### 11. Implement Interactions

#### Gesture Handling
- Tap gestures
- Drag gestures
- Rotation and scale gestures
- Custom spatial gestures

#### Eye & Hand Tracking
- Eye tracking for focus indicators
- Hand pose detection
- Custom hand gestures
- Spatial input handling

#### Voice Commands (if applicable)
- Speech recognition setup
- Command parsing
- Voice feedback

### 12. Integrate Features
- Connect ViewModels to Views
- Implement navigation flows
- Add animations and transitions
- Integrate spatial audio
- Implement all PRD features

## Phase 4: Polish & Optimization

### 13. Accessibility Implementation
- VoiceOver support for all interactive elements
- Dynamic Type support
- Alternative interaction methods
- High contrast modes
- Reduce motion support

### 14. Performance Optimization
- Profile with Instruments
- Optimize 3D assets (LOD systems)
- Reduce draw calls
- Optimize memory usage
- Async/await optimization
- Battery impact optimization

### 15. Error Handling & Edge Cases
- Comprehensive error handling
- Loading states
- Empty states
- Network error recovery
- Graceful degradation

## Phase 5: Testing & Documentation

### 16. Testing
- Write unit tests for models and services
- Create UI tests for critical flows
- Test spatial interactions
- Test on actual Vision Pro hardware (if available)
- Performance testing
- Accessibility testing

### 17. Documentation
- Code documentation (inline comments + DocC)
- API documentation
- User guide / README
- Setup and build instructions
- Troubleshooting guide

### 18. Final Review
- Code review and refactoring
- Security audit
- Privacy compliance check
- App Store guidelines compliance
- Performance benchmarks

## Development Best Practices

### visionOS-Specific Guidelines
1. **Spatial Ergonomics**: Place content 10-15° below eye level
2. **Depth Management**: Use z-axis meaningfully for hierarchy
3. **Hit Targets**: Minimum 60pt for interactive elements
4. **Progressive Disclosure**: Start with windows, expand to volumes/spaces
5. **Visual Clarity**: Use appropriate glass materials and lighting

### Swift & SwiftUI Best Practices
1. Use Swift 6.0 strict concurrency
2. Leverage @Observable for state management
3. Use async/await for asynchronous operations
4. Follow MVVM architecture pattern
5. Keep views small and composable

### RealityKit Best Practices
1. Use Entity Component System (ECS) architecture
2. Optimize 3D models (polygon count, textures)
3. Implement Level of Detail (LOD)
4. Use object pooling for repeated entities
5. Leverage spatial audio effectively

### Performance Considerations
1. Target 90 FPS for smooth experience
2. Minimize CPU/GPU usage
3. Use efficient rendering techniques
4. Profile regularly with Instruments
5. Test thermal performance

## Key Questions to Answer Before Implementation

1. **Spatial Mode**: Which visionOS presentation mode is primary?
   - Windows (2D floating panels)
   - Volumes (3D bounded content)
   - Full Space (fully immersive)
   - Hybrid approach?

2. **Interaction Model**: What are the primary interaction methods?
   - Gaze + pinch
   - Hand tracking
   - Voice commands
   - Hardware controllers?

3. **Data Sources**: What data does the app need?
   - Local data only?
   - Cloud APIs?
   - Real-time data streams?
   - External integrations?

4. **3D Content**: What 3D assets are needed?
   - Custom 3D models?
   - Procedural geometry?
   - Data visualizations?
   - Reality Composer content?

5. **Multi-user**: Does it support collaboration?
   - SharePlay integration?
   - Real-time sync?
   - Presence indicators?

6. **Offline Support**: Does it work offline?
   - Full offline functionality?
   - Partial offline mode?
   - Online-only?

7. **Deployment**: How will it be distributed?
   - Enterprise distribution?
   - App Store?
   - TestFlight beta?

## Resources & References

### Apple Documentation
- [visionOS Documentation](https://developer.apple.com/visionos/)
- [visionOS Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/visionos)
- [RealityKit Documentation](https://developer.apple.com/documentation/realitykit/)
- [SwiftUI for visionOS](https://developer.apple.com/documentation/swiftui/bringing-your-app-to-visionos)
- [ARKit Documentation](https://developer.apple.com/documentation/arkit/)

### Development Tools
- Xcode 16+ with visionOS SDK
- Reality Composer Pro
- Instruments for profiling
- visionOS Simulator

### Sample Code
- [Apple Sample Code for visionOS](https://developer.apple.com/documentation/visionos/world)
- [WWDC Videos on spatial computing](https://developer.apple.com/videos/)

## Getting Started Checklist

- [ ] Read and understand the PRD thoroughly
- [ ] Generate ARCHITECTURE.md
- [ ] Generate TECHNICAL_SPEC.md
- [ ] Generate DESIGN.md
- [ ] Generate IMPLEMENTATION_PLAN.md
- [ ] Review all documents and confirm approach
- [ ] Set up Xcode project
- [ ] Implement data models
- [ ] Build core UI components
- [ ] Implement spatial features
- [ ] Add interactions
- [ ] Test thoroughly
- [ ] Optimize performance
- [ ] Create documentation

---

**Remember**: Always start with the documentation phase. This ensures a well-planned, maintainable, and scalable visionOS application. Do not skip to implementation without proper planning and design documentation.

