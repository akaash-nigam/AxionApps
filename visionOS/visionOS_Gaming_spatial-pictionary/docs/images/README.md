# Image Assets for Landing Page

## Required Images

### Logo
- **File**: `logo.svg`
- **Size**: 200x200px (vector preferred)
- **Format**: SVG or PNG with transparency
- **Usage**: Navigation bar, footer
- **Description**: Spatial Pictionary logo with gradient

### Open Graph Image
- **File**: `og-image.jpg`
- **Size**: 1200x630px
- **Format**: JPG or PNG
- **Usage**: Social media previews (Facebook, Twitter, LinkedIn)
- **Description**: App screenshot or branded graphic

### App Screenshots
Create a `screenshots/` subdirectory with:
- `hero-screenshot.png` - 1920x1080px (Hero section)
- `gameplay-1.png` - 800x600px (Features section)
- `gameplay-2.png` - 800x600px (Features section)
- `gallery-view.png` - 800x600px (Features section)

### Optional Assets
- `favicon.ico` - 32x32px (Browser tab icon)
- `apple-touch-icon.png` - 180x180px (iOS home screen)
- `app-icon.png` - 512x512px (Various uses)

---

## Design Guidelines

### Brand Colors
```
Primary: #667eea (Purple-Blue)
Secondary: #764ba2 (Deep Purple)
Accent: #f093fb (Pink)
Accent 2: #f5576c (Coral)
```

### Logo Usage
- Maintain aspect ratio
- Use on light or dark backgrounds
- Apply gradient when possible
- Keep clear space around logo

### Screenshot Guidelines
- High resolution (2x for retina displays)
- Show app in action
- Include realistic content
- Maintain consistent style
- No copyrighted content

---

## Placeholder Images

Until actual images are created, the landing page uses:
- **CSS gradients** for visual appeal
- **SVG illustrations** for diagrams
- **Emoji** for quick visual communication
- **Color blocks** as image placeholders

---

## Image Optimization

Before adding images to production:

1. **Compress images**
   - Use TinyPNG or ImageOptim
   - Target: <200KB per image
   - Maintain visual quality

2. **Use modern formats**
   - WebP for photos (with JPG fallback)
   - SVG for logos and icons
   - PNG for transparency

3. **Implement responsive images**
   ```html
   <picture>
     <source srcset="image.webp" type="image/webp">
     <source srcset="image.jpg" type="image/jpeg">
     <img src="image.jpg" alt="Description">
   </picture>
   ```

4. **Lazy load**
   ```html
   <img src="placeholder.jpg" data-src="actual-image.jpg" loading="lazy">
   ```

---

## Tools for Image Creation

### Screenshots
- **macOS**: Xcode Simulator screenshots (⌘S)
- **visionOS**: Device screenshots via Xcode
- **Editing**: Photoshop, Sketch, Figma

### Graphics
- **Figma** - Design tool
- **Canva** - Quick graphics
- **Blender** - 3D renders
- **Adobe Illustrator** - Vector graphics

### Optimization
- **TinyPNG** - PNG compression
- **Squoosh** - Multi-format optimizer
- **ImageOptim** - Batch optimization (macOS)
- **SVGO** - SVG optimization

---

## Current Status

⚠️ **Placeholder Stage**
- No actual images yet
- Using CSS and SVG for visuals
- Landing page functional without images

✅ **Next Steps**
1. Create app logo
2. Generate app screenshots from simulator
3. Design social media preview image
4. Optimize and add to repository
5. Update HTML image references

---

*Last Updated: 2025-11-19*
