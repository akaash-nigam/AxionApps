# visionOS Landing Page Design System

## Design Philosophy

**"Spatial Enterprise"** - Professional apps for the immersive future. Our landing pages communicate the premium, cutting-edge nature of Apple Vision Pro while maintaining enterprise credibility.

---

## Core Design Principles

### 1. Dark-First Aesthetic
- Background: Deep space black (`#0a0a0f`)
- Glassmorphism with backdrop blur
- Subtle animated depth layers
- No harsh whites - use off-whites (`rgba(255,255,255,0.9)`)

### 2. Spatial Depth
- 3D floating elements with subtle animations
- Multiple gradient depth layers creating parallax
- Card elevation with box-shadows
- Perspective transforms on interactive elements

### 3. Premium Accent Colors (by category)
| Category | Primary Color | RGB |
|----------|--------------|-----|
| AI/Tech | Purple | `#a855f7` |
| Healthcare | Teal | `#14b8a6` |
| Finance | Blue | `#3b82f6` |
| Enterprise | Indigo | `#6366f1` |
| Construction/Industrial | Orange | `#f97316` |
| Education | Green | `#22c55e` |
| Creative | Pink | `#ec4899` |
| Legal/Compliance | Slate | `#64748b` |
| Real Estate | Amber | `#f59e0b` |
| Sustainability | Emerald | `#10b981` |

### 4. Typography
- Font: SF Pro Display (system font)
- Hero title: 64px, 700 weight
- Tagline: 28px, 500 weight
- Body: 16-18px, 400 weight
- All text with subtle gradient for depth

---

## Required Sections

### 1. Vision Pro Strip (NEW)
Top banner showing platform credentials:
```
[Vision Pro] [Spatial Computing] [visionOS 2.0+] [Enterprise Ready]
```
- Glassmorphism background
- Animated subtle glow
- Fixed position

### 2. Hero Section
- Floating app icon with 3D animation
- Gradient title (white to accent color)
- Compelling tagline
- Spatial description paragraph
- CTA button with hover glow
- **NEW**: Hero image showing spatial computing visualization

### 3. Spatial Pillars (Features)
- 5 key features in glassmorphic cards
- Large emoji icons
- Accent-colored titles
- Hover lift effect

### 4. Immersive Gallery
- Generated images showing the app in spatial context
- 16:9 aspect ratio
- Glassmorphic frames
- **NEW**: Actual generated images, not placeholders

### 5. Enterprise Benefits (NEW)
- ROI/value propositions
- Integration capabilities
- Security/compliance badges
- Scalability metrics

### 6. Social Proof (NEW)
- Enterprise testimonials
- Industry recognition badges
- Customer logos (if applicable)

### 7. Call to Action
- "Experience in Vision Pro" button
- App Store badge (when available)
- Contact/demo request option

### 8. Footer
- Copyright
- Privacy/Terms links
- Enterprise contact

---

## Image Generation Guidelines

For each app, generate:

### 1. Hero Image (1792x1024)
**Prompt template:**
```
Photorealistic image of Apple Vision Pro headset floating in a premium dark environment,
displaying [APP_SPECIFIC_VISUALIZATION] as holographic 3D interface elements surrounding
the user, soft purple/blue ambient lighting, enterprise setting, ultra high quality,
cinematic lighting, depth of field
```

### 2. Feature Visualization (1024x1024)
**Prompt template:**
```
Abstract 3D visualization of [FEATURE_NAME] concept, floating holographic interface
elements, dark background with [ACCENT_COLOR] glow, spatial computing aesthetic,
glass and light materials, professional enterprise style
```

---

## Animation Specifications

### Depth Layers
- 3 radial gradient layers
- Floating animation: 20-30s duration
- Subtle rotation: ±5 degrees
- Opacity: 15-30%

### Logo Float
- Y-axis rotation: ±10 degrees
- X-axis tilt: ±5 degrees
- Duration: 6s ease-in-out

### Card Hover
- translateY: -5px
- Border glow increase
- Box-shadow expansion
- Duration: 0.3s

---

## App Categories & Theming

### Enterprise & Operations (Indigo #6366f1)
- spatial-erp
- spatial-crm
- spatial-hcm
- business-operating-system
- enterprise-apps
- executive-briefing
- board-meeting-dimension

### Healthcare (Teal #14b8a6)
- healthcare-ecosystem-orchestrator
- Medical-Imaging-Suite
- surgical-training-universe
- spatial-wellness-platform

### Finance (Blue #3b82f6)
- Financial-Trading-Cockpit
- financial-trading-dimension
- financial-operations-platform
- Personal-Finance-Navigator
- insurance-risk-assessor

### AI & Technology (Purple #a855f7)
- ai-agent-coordinator
- digital-twin-orchestrator
- Research-Web-Crawler
- Spatial-Code-Reviewer

### Industrial & Construction (Orange #f97316)
- construction-site-manager
- industrial-cad-cam-suite
- industrial-safety-simulator
- supply-chain-control-tower

### Smart Infrastructure (Emerald #10b981)
- smart-city-command-platform
- smart-agriculture
- energy-grid-visualizer
- sustainability-command
- Living-Building-System

### Education & Training (Green #22c55e)
- corporate-university-platform
- Language-Immersion-Rooms
- military-defense-training

### Creative & Design (Pink #ec4899)
- architectural-visualization-studio
- Architecture-Time-Machine
- Spatial-Screenplay-Workshop
- Wardrobe-Consultant

### Legal & Compliance (Slate #64748b)
- legal-discovery-universe
- regulatory-navigation-space
- institutional-memory-vault

### Real Estate & Retail (Amber #f59e0b)
- real-estate-spatial
- retail-space-optimizer

### Collaboration (Cyan #06b6d4)
- spatial-meeting-platform
- virtual-collaboration-arena
- research-collaboration-space
- innovation-laboratory

---

## Implementation Checklist

For each app:
- [ ] Apply Vision Pro strip
- [ ] Update color theme based on category
- [ ] Generate hero image with DALL-E
- [ ] Generate 2-4 feature images
- [ ] Add enterprise benefits section
- [ ] Add social proof section
- [ ] Update meta tags for SEO
- [ ] Add proper Open Graph tags
- [ ] Test responsiveness

---

## File Structure

```
visionOS_[app-name]/
├── docs/
│   ├── index.html          # Landing page
│   ├── privacy.html        # Privacy policy
│   ├── terms.html          # Terms of service
│   ├── support.html        # Support page
│   ├── hero-spatial.png    # Generated hero image
│   ├── feature-1.png       # Feature visualization 1
│   ├── feature-2.png       # Feature visualization 2
│   └── icon.png            # App icon
```

---

## Version History

- v1.0 (Jan 2026): Initial visionOS Design System
