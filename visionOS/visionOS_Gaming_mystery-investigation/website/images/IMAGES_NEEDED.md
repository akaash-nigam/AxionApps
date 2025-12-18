# Required Images for Landing Page

This document lists all images needed for the Mystery Investigation landing page.

## Hero Section

### hero-screenshot.png
- **Dimensions**: 1920x1200px (16:10 aspect ratio)
- **Description**: Main screenshot showing:
  - Crime scene with evidence markers floating in space
  - Vision Pro user examining holographic evidence
  - Dark, atmospheric detective aesthetic
- **Format**: PNG with transparency
- **Size**: < 500KB (optimized)

### hero-background.jpg
- **Dimensions**: 1920x1080px
- **Description**: Subtle grid pattern or detective-themed texture
- **Format**: JPG
- **Size**: < 200KB

## How It Works Section

### step1-case-selection.png
- **Dimensions**: 600x600px (square)
- **Description**: UI showing case selection grid with difficulty stars
- **Format**: PNG
- **Style**: Match app UI design

### step2-room-scan.png
- **Dimensions**: 600x600px
- **Description**: ARKit scanning visualization with room mesh
- **Format**: PNG
- **Style**: Technical, futuristic

### step3-evidence-collect.png
- **Dimensions**: 600x600px
- **Description**: Hand reaching for virtual evidence on table
- **Format**: PNG
- **Style**: Photorealistic

### step4-interrogation.png
- **Dimensions**: 600x600px
- **Description**: Life-sized suspect hologram with stress indicator
- **Format**: PNG
- **Style**: Holographic effect

### step5-solution.png
- **Dimensions**: 600x600px
- **Description**: Case solved celebration with rating stars
- **Format**: PNG
- **Style**: Celebratory, bright

## Features Section (Optional Enhancement)

### feature-crime-scene.jpg
- **Dimensions**: 800x600px
- **Description**: Evidence laid out on table in 3D space
- **Format**: JPG

### feature-forensics.jpg
- **Dimensions**: 800x600px
- **Description**: Magnifying glass examining fingerprint
- **Format**: JPG

### feature-hologram.jpg
- **Dimensions**: 800x600px
- **Description**: Suspect hologram in living room
- **Format**: JPG

## Testimonials/Social Proof

### testimonial-avatar-placeholder.png
- **Dimensions**: 96x96px (circular)
- **Description**: Generic avatar or initials
- **Format**: PNG with transparency
- **Size**: < 10KB

## Favicon & Logos

### favicon.ico
- **Dimensions**: 32x32px, 64x64px (multi-size .ico)
- **Description**: Magnifying glass or detective badge icon
- **Format**: ICO

### logo.svg
- **Description**: Vector logo for high-quality scaling
- **Format**: SVG
- **Colors**: Use brand colors (#FFB800 primary)

### apple-touch-icon.png
- **Dimensions**: 180x180px
- **Description**: iOS home screen icon
- **Format**: PNG

## Social Media

### og-image.png
- **Dimensions**: 1200x630px (Facebook/LinkedIn)
- **Description**: Hero shot with text overlay:
  - Title: "Mystery Investigation"
  - Subtitle: "Become the Detective in Your Own Crime Scene"
  - Apple Vision Pro badge
- **Format**: PNG
- **Size**: < 300KB

### twitter-card.png
- **Dimensions**: 1200x675px (Twitter)
- **Description**: Similar to og-image but optimized for Twitter
- **Format**: PNG
- **Size**: < 200KB

## Badges & Icons

### app-store-badge.svg
- **Description**: Download on Vision Pro badge
- **Format**: SVG (Apple official asset)
- **Source**: Apple Design Resources

### rating-stars.svg
- **Description**: 5-star rating graphic
- **Format**: SVG
- **Colors**: Gold (#FFB800)

## Video

### demo-video-thumbnail.jpg
- **Dimensions**: 1920x1080px
- **Description**: Compelling frame from demo video
- **Format**: JPG
- **Size**: < 200KB

### demo-video.mp4
- **Duration**: 60-90 seconds
- **Resolution**: 1920x1080px (1080p)
- **Description**:
  - Opening: Vision Pro user in home
  - Scene: Crime scene materializes
  - Action: Evidence examination and interrogation
  - Closing: Case solved celebration
- **Format**: MP4 (H.264)
- **Size**: < 50MB

## Animation Frames (Optional)

### evidence-float-*.png
- **Dimensions**: 256x256px each
- **Description**: Animated evidence items for hero background
- **Count**: 5-10 different evidence types
- **Format**: PNG with transparency

## Image Optimization Guidelines

### General
- All images should be optimized for web
- Use WebP format with JPG/PNG fallback
- Implement lazy loading
- Provide 1x, 2x, 3x versions for retina displays

### Naming Convention
```
[section]-[description]-[size].ext
Examples:
- hero-screenshot-1920w.png
- step1-case-selection-600w.png
- og-image.png
```

### Responsive Images
Provide multiple sizes:
- Small: 600px width
- Medium: 1200px width
- Large: 1920px width

### srcset Example
```html
<img
  src="hero-screenshot-600w.png"
  srcset="
    hero-screenshot-600w.png 600w,
    hero-screenshot-1200w.png 1200w,
    hero-screenshot-1920w.png 1920w"
  sizes="(max-width: 768px) 100vw, 50vw"
  alt="Mystery Investigation on Vision Pro">
```

## Current Placeholders

Until actual images are created, the landing page uses:
- CSS gradients for hero background
- Solid color blocks for step visuals
- Icon fonts for avatars and badges
- CSS-only effects for animations

## Design Tools

Recommended tools for creating these images:
- **Figma**: UI mockups and screenshots
- **Blender**: 3D renders of Vision Pro and scenes
- **Adobe Photoshop**: Photo editing and composition
- **After Effects**: Video creation and animation
- **Reality Composer Pro**: Actual app screenshots

## Brand Guidelines

All images should follow:
- Dark theme (navy/black backgrounds)
- Gold/yellow accent color (#FFB800)
- Professional, mystery/detective aesthetic
- High quality, sharp details
- Consistent style throughout

---

**Note**: These are placeholder specifications. Actual images should be created by the design team following these guidelines and the brand identity established in the PRD.
