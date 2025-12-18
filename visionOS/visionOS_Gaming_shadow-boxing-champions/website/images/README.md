# Website Images

## Required Images

Place the following images in this directory for the landing page:

### Hero Section
- **hero-screenshot.png** (1200x800px) - Main hero image showing the app in action
  - Show a boxer in Vision Pro facing a holographic opponent
  - High quality, professional screenshot
  - Format: PNG with transparency or JPG

### How It Works Steps
- **step-1.png** (600x400px) - User setting up play area
- **step-2.png** (600x400px) - Tutorial/training screen
- **step-3.png** (600x400px) - Active sparring match
- **step-4.png** (600x400px) - Progress/stats dashboard

### Favicon
- **favicon.png** (32x32px, 64x64px, 128x128px) - App icon
  - Boxing glove icon in red
  - Simple, recognizable design

## Image Guidelines

### Dimensions
- Hero: 1200x800px minimum
- Steps: 600x400px
- Favicon: Multiple sizes (32px, 64px, 128px, 256px)

### Format
- Screenshots: PNG or JPG
- Icons: PNG with transparency
- Optimize all images for web (use tools like TinyPNG)

### Style
- Match the brand colors:
  - Primary Red: #E02020
  - Secondary Blue: #2962FF
  - Accent Gold: #FFD700
- Keep backgrounds clean and professional
- Show Vision Pro device when possible
- Highlight spatial/3D aspects

## Placeholder Images

Until actual screenshots are available, you can use:

1. **Figma/Sketch mockups** - Design mockups of the interface
2. **Stock photos** - VR/AR fitness stock images (properly licensed)
3. **Gradient placeholders** - Temporary colored blocks

### Creating Placeholder Gradients

Use these CSS gradients as placeholders:

```css
/* Hero gradient */
background: linear-gradient(135deg, #E02020 0%, #2962FF 100%);

/* Step gradients */
background: linear-gradient(135deg, #F0F9FF 0%, #FFF5F5 100%);
```

## Image Optimization

Before deploying, optimize all images:

1. **Compress** - Use TinyPNG, ImageOptim, or Squoosh
2. **Responsive** - Create multiple sizes for different screens
3. **WebP** - Convert to WebP format with JPG/PNG fallbacks
4. **Lazy Loading** - Images are already set to lazy load in HTML

## Copyright

Ensure all images used have proper licensing:
- Original screenshots ✓
- Licensed stock photos ✓
- Properly attributed creative commons ✓
- No copyrighted material without permission ✗
