# Implementation Instructions for Claude Code Web - VisionOS Gaming App

## Project Overview
This is a visionOS gaming application for Apple Vision Pro. Review the PRD in this folder to understand the full requirements and features.

## Implementation Workflow

### IMPORTANT: Always Start with Documentation Phase
Before writing any code, generate the following design and technical documents:

## Phase 1: Document Generation (MANDATORY FIRST STEP)

### 1. Create ARCHITECTURE.md
Generate a comprehensive technical architecture document including:
- Game architecture overview (game loop, state management, scene graph)
- visionOS-specific gaming patterns (Windows, Volumes, Immersive Spaces)
- Game data models and schemas
- RealityKit gaming components and systems
- ARKit integration for gameplay
- Multiplayer architecture (if applicable)
- Physics and collision systems
- Audio architecture (spatial audio, music, SFX)
- Performance optimization for gaming (60-90 FPS target)
- Save/load system architecture

### 2. Create TECHNICAL_SPEC.md
Generate detailed technical specifications including:
- Technology stack:
  - Swift 6.0+ with gaming patterns
  - SwiftUI for UI/menus
  - RealityKit for 3D gameplay
  - ARKit for spatial tracking
  - visionOS 2.0+ Gaming APIs
  - GameplayKit (if applicable)
- Game mechanics implementation details
- Control schemes (gesture, gaze, hand tracking, game controllers)
- Physics specifications
- Rendering requirements
- Multiplayer/networking specifications
- Performance budgets (frame rate, memory, battery)
- Testing requirements for gaming

### 3. Create DESIGN.md
Generate comprehensive game design and UI/UX specifications including:
- Game design document (GDD) elements
- Core gameplay loop
- Player progression systems
- Level design principles
- Spatial gameplay design for Vision Pro
- UI/UX for gaming:
  - HUD design in spatial context
  - Menu systems
  - Game settings and options
- Visual style guide
- Audio design (music, SFX, spatial audio)
- Accessibility for gaming
- Tutorial and onboarding design
- Difficulty balancing

### 4. Create IMPLEMENTATION_PLAN.md
Generate a detailed implementation roadmap including:
- Development phases and milestones
- Feature prioritization
- Prototype stages
- Playtesting strategy
- Performance optimization plan
- Multiplayer testing (if applicable)
- Beta testing approach
- Success metrics and KPIs

## Phase 2: Project Setup

### 5. Create Xcode Project
- Create new visionOS gaming app project in Xcode 16+
- Configure project settings:
  - Minimum deployment target: visionOS 2.0
  - Enable required gaming capabilities
  - Configure Info.plist for gaming features
- Set up project structure:
  ```
  GameName/
  ├── App/
  │   ├── GameApp.swift
  │   └── GameCoordinator.swift
  ├── Game/
  │   ├── GameLogic/
  │   ├── GameState/
  │   ├── Entities/
  │   └── Components/
  ├── Systems/
  │   ├── PhysicsSystem/
  │   ├── InputSystem/
  │   └── AudioSystem/
  ├── Scenes/
  │   ├── MenuScene/
  │   └── GameScene/
  ├── Views/
  │   ├── UI/
  │   └── HUD/
  ├── Models/
  ├── Resources/
  │   ├── Assets.xcassets
  │   ├── 3DModels/
  │   ├── Audio/
  │   └── Levels/
  └── Tests/
  ```

### 6. Configure Dependencies & Assets
- Set up Swift Package Manager dependencies
- Import or create 3D assets
- Set up Reality Composer Pro
- Configure audio assets
- Set up level data

## Phase 3: Core Game Implementation

### 7. Implement Game Architecture
- Game loop and update cycle
- State management system
- Scene management
- Entity-Component-System (ECS) setup
- Event system

### 8. Implement Core Gameplay
- Player controls and input handling
- Game mechanics per PRD
- Physics and collision detection
- AI/enemies (if applicable)
- Scoring/progression system
- Game rules enforcement

### 9. Implement Spatial Gaming Features
- RealityKit entities and components for game objects
- Spatial gameplay mechanics
- Hand tracking for controls
- Eye tracking integration
- Spatial audio for immersion
- Room-scale gameplay (if applicable)

### 10. Implement UI/UX
- Main menu and settings
- In-game HUD
- Pause menu
- Game over/victory screens
- Tutorial/onboarding
- Options and settings

### 11. Implement Game Systems
- Audio system (music, SFX, spatial audio)
- Particle effects and VFX
- Animation system
- Save/load system
- Achievement system (if applicable)

### 12. Multiplayer (if applicable)
- Network synchronization
- Matchmaking
- SharePlay integration
- Multiplayer game state management
- Lag compensation

## Phase 4: Polish & Optimization

### 13. Performance Optimization
- Profile with Instruments
- Optimize 3D assets and textures
- Reduce draw calls
- Optimize physics calculations
- Memory management
- Battery optimization
- Maintain 60-90 FPS

### 14. Game Polish
- Juice and game feel
- Visual effects polish
- Audio polish
- Animation polish
- Difficulty balancing
- Tutorial refinement

### 15. Accessibility
- VoiceOver support
- Alternative control schemes
- Difficulty options
- Visual/audio accessibility options
- Motion sickness considerations

## Phase 5: Testing & Release

### 16. Testing
- Unit tests for game logic
- Playtest sessions
- Multiplayer testing (if applicable)
- Performance testing across devices
- Accessibility testing
- Edge case testing

### 17. Documentation
- Code documentation
- Player guide
- Level editor documentation (if applicable)
- API documentation for extensions

### 18. Deployment Preparation
- App Store metadata
- Screenshots and videos
- Privacy policy
- Age rating preparation
- TestFlight beta testing

## VisionOS Gaming Best Practices

### Spatial Gaming Design
1. **Comfort First**: Design for extended play without motion sickness
2. **Natural Interactions**: Use intuitive gestures and gaze
3. **Spatial Audio**: Leverage 3D audio for immersion and gameplay
4. **Room Awareness**: Respect physical space boundaries
5. **Progressive Complexity**: Start simple, add depth

### Performance for Gaming
1. Target 90 FPS for fast-paced games, 60 FPS minimum
2. Optimize for thermal management
3. Implement LOD (Level of Detail) systems
4. Use object pooling for frequently spawned objects
5. Profile early and often

### Input Methods
1. **Gaze + Pinch**: Primary interaction
2. **Hand Tracking**: For gesture-based games
3. **Game Controllers**: Support for traditional gaming
4. **Voice Commands**: For accessibility and convenience

### Multiplayer Gaming
1. Use SharePlay for social experiences
2. Implement smooth network synchronization
3. Handle disconnections gracefully
4. Support spectator modes when appropriate

## Key Questions Before Implementation

1. **Game Genre**: What type of game is this? (Action, puzzle, RPG, etc.)
2. **Spatial Mode**: Window, volume, or full immersive space?
3. **Input Method**: Primary control scheme?
4. **Multiplayer**: Single-player, co-op, competitive, or MMO?
5. **Session Length**: Quick play or extended sessions?
6. **Progression**: How does the player advance?
7. **Monetization**: Paid, free, IAP, subscriptions?

## Resources

- [Apple Game Development Documentation](https://developer.apple.com/games/)
- [visionOS Gaming Guidelines](https://developer.apple.com/design/human-interface-guidelines/visionos)
- [RealityKit for Games](https://developer.apple.com/documentation/realitykit/)
- [GameplayKit Documentation](https://developer.apple.com/documentation/gameplaykit)
- [Spatial Audio for Games](https://developer.apple.com/documentation/avfoundation/spatial_audio)

## Getting Started Checklist

- [ ] Read and understand the PRD thoroughly
- [ ] Generate ARCHITECTURE.md
- [ ] Generate TECHNICAL_SPEC.md
- [ ] Generate DESIGN.md (Game Design Document)
- [ ] Generate IMPLEMENTATION_PLAN.md
- [ ] Review all documents and confirm approach
- [ ] Set up Xcode project with proper structure
- [ ] Create game architecture and systems
- [ ] Implement core gameplay loop
- [ ] Build spatial gaming features
- [ ] Add UI/UX and menus
- [ ] Implement audio systems
- [ ] Playtest and iterate
- [ ] Optimize performance
- [ ] Polish and add juice
- [ ] Test thoroughly
- [ ] Prepare for release

---

**Remember**: Start with documentation to ensure a well-designed, fun, and performant visionOS game. Gaming requires special attention to performance, feel, and player experience.

