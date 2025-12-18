# Resources Directory

This directory contains all assets and resources for the Narrative Story Worlds app.

## Structure

```
Resources/
├── Assets.xcassets/        # App icons, images, and visual assets
├── Audio/                  # Audio files (dialogue, music, SFX)
├── SampleContent/          # Sample story content and data
│   └── Episode1Story.swift # Episode 1 story definition
└── README.md              # This file
```

## Asset Organization

### Assets.xcassets
- App icon
- Character portraits
- UI elements
- Story-related imagery

### Audio
**Note:** Audio files are not included in the repository due to size.
In production, this directory should contain:
- Character dialogue audio clips
- Background music tracks
- Sound effects
- Ambient audio loops

### Sample Content
- `Episode1Story.swift`: Complete Episode 1 story with:
  - Character definitions
  - Dialogue trees
  - Choice branches
  - Story progression

## Adding New Assets

### Images
1. Add to `Assets.xcassets` via Xcode
2. Use appropriate naming conventions
3. Provide @2x and @3x variants where needed

### Audio
1. Place files in `Audio/` directory
2. Use .m4a format for optimal compression
3. Name files descriptively (e.g., `sarah_intro_01.m4a`)
4. Reference in story data by filename without extension

### Story Content
1. Create new Swift files in `SampleContent/`
2. Follow the pattern established in `Episode1Story.swift`
3. Use UUIDs for consistent referencing
4. Define characters, chapters, scenes, and story beats

## Production Considerations

Before shipping:
1. Optimize all audio files for size and quality
2. Compress images appropriately
3. Test all asset loading paths
4. Verify spatial audio file formats
5. Ensure all assets are properly licensed
