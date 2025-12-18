# visionOS Landing Page Design Guidelines

**Created:** December 18, 2024
**Purpose:** Define design standards for visionOS app landing pages that properly convey spatial computing experiences

---

## Core Principle

**visionOS apps exist in 3D space, not on flat screens.** Landing pages must communicate immersion, depth, natural interaction, and spatial scale—not just features and screenshots.

---

## 1. Visual Design System

### A. Glass Morphism (Primary Design Language)

visionOS uses glass morphism extensively. Landing pages should reflect this:

```css
/* Glass Card Example */
background: rgba(30, 27, 75, 0.4);
backdrop-filter: blur(20px);
border: 1px solid rgba(139, 92, 246, 0.2);
box-shadow:
    0 8px 32px rgba(0, 0, 0, 0.3),
    inset 0 1px 0 rgba(255, 255, 255, 0.05);
```

**Characteristics:**
- Semi-transparent backgrounds (rgba with 0.2-0.6 alpha)
- Backdrop blur (10px-30px)
- Subtle borders with low opacity
- Inset highlights for depth
- Multiple shadow layers for elevation

### B. Depth & Layering

Create perception of 3D space through CSS:

```css
/* Background Depth Layers */
.bg-layer-1 {
    background: radial-gradient(circle at 20% 30%, rgba(139, 92, 246, 0.15) 0%, transparent 50%);
    z-index: 1;
}

.bg-layer-2 {
    background: radial-gradient(circle at 80% 70%, rgba(167, 139, 250, 0.1) 0%, transparent 50%);
    z-index: 2;
}

/* 3D Transform Effects */
transform: rotateY(-5deg) rotateX(2deg);
transform-style: preserve-3d;
perspective: 1000px;
```

**Key Techniques:**
- Fixed background layers at different z-indexes
- Radial gradients suggesting depth
- CSS 3D transforms (rotateY, rotateX, perspective)
- Parallax scrolling effects
- Floating/hovering animations

### C. Color Palette

**Dark Base:** visionOS experiences are typically in darker environments

```
Background: #0a0a0f to #1a1a1f
Primary: #8b5cf6 (Purple/Violet for tech/AI)
Secondary: #a78bfa to #c4b5fd (Lighter purples)
Accent: #ffffff (Pure white for key elements)
Text: #f0f0f0 (Light gray), #b5a3e8 (Muted purple)
```

**Usage Rules:**
- Start with near-black backgrounds (#0a0a0f)
- Use purple/violet gradients for technology themes
- Apply white sparingly for maximum impact
- Muted colors for body text (don't overpower)
- Glow effects around interactive elements

### D. Typography

**Font Stack:**
```css
font-family: -apple-system, BlinkMacSystemFont, 'SF Pro Display', 'Segoe UI', Roboto, sans-serif;
```

**Hierarchy:**
- **Hero Title:** 64-72px, weight 800, gradient fill
- **Section Headers:** 48-56px, weight 800
- **Taglines:** 24-28px, weight 400
- **Body Text:** 17-18px, weight 300-400
- **Captions:** 14-16px, weight 500

**Characteristics:**
- Heavy weights (700-800) for headers
- Light weights (300-400) for body text
- Negative letter-spacing for large text (-1px to -3px)
- Line-height 1.6-1.8 for readability
- Gradient text fills for hero elements

---

## 2. Spatial Computing Messaging

### A. Core Differentiators to Emphasize

**Traditional App Messaging (Avoid):**
- "Powerful features"
- "Easy to use"
- "Available on the App Store"

**Spatial Computing Messaging (Use):**
- "Infinite 3D workspace"
- "Control with natural gestures"
- "Transforms your physical space"
- "Room-scale experience"
- "Immersive environment"

### B. Required Content Sections

#### 1. Hero Section
- **Badge:** "Built for Vision Pro" / "Spatial Computing"
- **Title:** App name + spatial context
- **Tagline:** Focus on 3D, immersion, or natural interaction
- **Spatial Message:** 2-3 sentences explaining how it uses space
- **CTA:** "Download for Vision Pro"

**Example:**
```
Badge: "Built for Vision Pro"
Title: "AI Agent Coordinator"
Tagline: "Orchestrate AI in Immersive 3D Space"
Message: "Transform your workspace into an AI command center.
         Arrange agents in unlimited 3D space, control with
         natural gestures, and experience the future of AI coordination."
```

#### 2. Spatial Pillars (5 Key Features)

Replace traditional "Features" with **"Spatial Pillars"** that emphasize spatial computing advantages:

1. **Infinite 3D Workspace** - Unlimited canvas, room-scale, arrange in space
2. **Natural Gesture Control** - Eyes, hands, voice control
3. **Mixed Reality Integration** - Blend with physical environment
4. **Real-Time 3D [Core Function]** - Spatial visualization of app's purpose
5. **Immersive Focus Modes** - Environment dial, passthrough vs immersion

**Content Structure:**
- Icon (emoji or symbol)
- Bold title (3-5 words)
- Description (2-3 sentences focusing on spatial benefits)

### C. Language Guidelines

**Spatial Terminology (Use Frequently):**
- 3D space, spatial canvas, room-scale
- Immersive, presence, depth
- Natural gestures, eye tracking, hand tracking
- Passthrough, mixed reality, environment
- Floating, anchored, positioned
- Unlimited, infinite, boundless

**Avoid:**
- Screen, display, monitor
- Click, tap, swipe
- Window, icon, menu (use spatial equivalents)
- Flat, 2D interface
- Traditional navigation terms

---

## 3. Interactive Elements

### A. Buttons

**Primary Button (Download CTA):**
```css
background: linear-gradient(135deg, #8b5cf6 0%, #a78bfa 100%);
padding: 20px 48px;
border-radius: 16px;
box-shadow:
    0 8px 30px rgba(139, 92, 246, 0.4),
    0 0 60px rgba(139, 92, 246, 0.2);
```

**Features:**
- Large padding (18-24px vertical)
- Generous border-radius (12-20px)
- Glow/shadow effects
- Smooth hover transitions (0.3-0.5s)
- Shimmer effect on hover

**Secondary Button:**
```css
background: rgba(139, 92, 246, 0.1);
backdrop-filter: blur(10px);
border: 2px solid rgba(139, 92, 246, 0.3);
```

### B. Cards (Feature/Pillar Cards)

**Structure:**
```css
background: rgba(30, 27, 75, 0.4);
backdrop-filter: blur(20px);
padding: 48px;
border-radius: 24px;
border: 1px solid rgba(139, 92, 246, 0.2);
transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
```

**Hover Effects:**
```css
transform: translateY(-8px) scale(1.02);
border-color: rgba(139, 92, 246, 0.4);
box-shadow: 0 16px 48px rgba(139, 92, 246, 0.3);
```

**Guidelines:**
- Large padding (40-50px)
- Generous border-radius (20-28px)
- Hover lifts card upward
- Slight scale on hover
- Radial gradient overlay appears on hover

### C. Animations

**Key Animations:**

```css
/* Float Effect (Badges, Icons) */
@keyframes float {
    0%, 100% { transform: translateY(0px); }
    50% { transform: translateY(-10px); }
}

/* 3D Rotation (Logo) */
@keyframes rotateY {
    0%, 100% { transform: rotateY(-5deg) rotateX(2deg); }
    50% { transform: rotateY(5deg) rotateX(-2deg); }
}

/* Shimmer Effect (Buttons) */
.btn::before {
    content: '';
    position: absolute;
    background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.2), transparent);
    transition: left 0.5s;
}
```

**Rules:**
- Slow, smooth animations (3-8 seconds)
- Subtle movements (5-10px max)
- Easing functions: `ease-in-out` or `cubic-bezier(0.4, 0, 0.2, 1)`
- Hover transitions: 0.3-0.5s
- Avoid jarring or rapid animations

---

## 4. Screenshot/Media Strategy

### A. Aspect Ratios

**Traditional (Avoid):** 9:19.5 (phone portrait)
**Spatial (Use):** 16:9 or wider (landscape spatial views)

```css
/* Spatial Screenshot Frame */
aspect-ratio: 16 / 9;
background: rgba(55, 48, 163, 0.3);
backdrop-filter: blur(15px);
border-radius: 24px;
```

### B. Content Types

**Priority Order:**
1. **Video demos** - Short clips showing gesture interaction
2. **Wide spatial views** - 16:9 showing room-scale context
3. **Environment mockups** - App overlaid on physical spaces
4. **Gesture overlays** - Visual hints of hand/eye interaction
5. **Placeholder symbols** - Until real screenshots available

**Avoid:**
- Vertical phone screenshots
- Traditional UI screenshots
- Desktop application views
- Anything suggesting 2D interaction

### C. Placeholder Strategy

Until real screenshots are available:

```html
<div class="experience-placeholder">∞</div>
```

**Recommended Symbols:**
- ∞ (Infinity) - Unlimited space
- ◇ (Diamond) - Precision/focus
- ⚡ (Lightning) - Real-time/fast
- 🌊 (Wave) - Flow/dynamic
- 🌐 (Globe) - Spatial/3D

---

## 5. Layout Structure

### A. Responsive Grid

```css
/* Feature/Pillar Grid */
display: grid;
grid-template-columns: repeat(auto-fit, minmax(320px, 1fr));
gap: 40px;

/* Experience/Screenshot Grid */
grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
gap: 36px;
```

**Rules:**
- Use auto-fit for responsive grids
- Minimum column width: 280-320px
- Large gaps (36-48px) for breathing room
- Max-width containers: 1200-1400px
- Generous padding: 80-100px vertical sections

### B. Section Order

1. **Hero Section** - Badge, logo, title, tagline, spatial message, CTAs
2. **Spatial Pillars** - 5 key spatial features
3. **Experience Section** - Screenshots/videos in glass frames
4. **Footer** - Links, copyright

**Optional Sections:**
- Technical Specs (for developer tools)
- Team/Community (for collaborative apps)
- Pricing (for commercial apps)

---

## 6. Technical Implementation

### A. Performance

```css
/* Use hardware acceleration */
transform: translateZ(0);
will-change: transform;

/* Efficient animations */
transition: transform 0.3s, opacity 0.3s;

/* Backdrop filter with fallback */
backdrop-filter: blur(20px);
-webkit-backdrop-filter: blur(20px);
```

**Guidelines:**
- Minimize heavy backdrop-filter usage
- Use CSS transforms (not top/left for animations)
- Add will-change for animated elements
- Provide fallback for older browsers

### B. Accessibility

```html
<!-- Semantic HTML -->
<header>
<main>
    <section aria-label="Spatial Features">
<footer>

<!-- Alt text for meaning -->
<div class="pillar-icon" aria-label="Infinite workspace">🌐</div>

<!-- Keyboard navigation -->
tabindex="0"
role="button"
```

**Requirements:**
- Semantic HTML5 elements
- ARIA labels for icon-only elements
- Keyboard navigation support
- Sufficient color contrast (WCAG AA minimum)
- Focus indicators on interactive elements

### C. Mobile Responsiveness

```css
@media (max-width: 768px) {
    h1 { font-size: 44px; }
    .pillar-card { padding: 36px; }
    .btn { padding: 16px 36px; }
}
```

**Key Adjustments:**
- Reduce font sizes (60-70% of desktop)
- Decrease padding (75-80% of desktop)
- Stack grids earlier (min 280px)
- Simplify animations (reduce motion)

---

## 7. Comparison: Before vs After

### Traditional Landing Page
```
❌ "Powerful AI management platform"
❌ Features: Dashboard, Reports, Analytics
❌ Screenshots: 9:19.5 phone mockups
❌ Colors: Bright, flat
❌ Buttons: Small, standard
❌ Language: "Click here", "Easy to use"
```

### Spatial Computing Landing Page
```
✅ "Orchestrate AI in Immersive 3D Space"
✅ Pillars: Infinite 3D Workspace, Natural Gesture Control
✅ Screenshots: 16:9 spatial views
✅ Colors: Dark, depth, glass morphism
✅ Buttons: Large, glowing, spatial depth
✅ Language: "Transform your workspace", "Arrange in unlimited space"
```

---

## 8. Quick Checklist

### Visual Design
- [ ] Dark background (#0a0a0f or similar)
- [ ] Glass morphism cards with backdrop-filter
- [ ] Multiple depth layers (radial gradients)
- [ ] 3D transform effects (perspective, rotateY)
- [ ] Purple/violet color scheme
- [ ] Gradient text for headers
- [ ] Glow/shadow effects

### Messaging
- [ ] "Built for Vision Pro" badge
- [ ] Spatial computing in title/tagline
- [ ] Mentions: 3D space, gestures, immersion
- [ ] 5 spatial pillars (not generic features)
- [ ] Natural interaction language
- [ ] Avoids traditional UI terms

### Layout
- [ ] Wide screenshot aspect ratio (16:9)
- [ ] Large padding/spacing (40-80px)
- [ ] Responsive grid (auto-fit, minmax)
- [ ] Glass morphism buttons
- [ ] Floating/depth animations
- [ ] Mobile responsive breakpoints

### Technical
- [ ] Hardware-accelerated animations
- [ ] Semantic HTML
- [ ] ARIA labels where needed
- [ ] Keyboard navigation
- [ ] Performance optimized
- [ ] Cross-browser tested

---

## 9. Example Code Template

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <title>[App Name] - Spatial Computing for Vision Pro</title>
    <meta name="description" content="[App purpose] in immersive 3D space. Control with natural gestures...">
    <style>
        /* Dark base */
        body {
            background: #0a0a0f;
            color: #f0f0f0;
        }

        /* Glass morphism card */
        .pillar-card {
            background: rgba(30, 27, 75, 0.4);
            backdrop-filter: blur(20px);
            border: 1px solid rgba(139, 92, 246, 0.2);
            border-radius: 24px;
            padding: 48px;
        }

        /* 3D logo animation */
        .logo {
            animation: rotateY 8s ease-in-out infinite;
        }

        /* Wide screenshots */
        .screenshot-frame {
            aspect-ratio: 16 / 9;
        }
    </style>
</head>
<body>
    <header>
        <div class="badge">Built for Vision Pro</div>
        <div class="logo">Logo</div>
        <h1>[App Name]</h1>
        <p class="tagline">[Spatial benefit] in [3D/Immersive/Spatial] [context]</p>
        <p class="spatial-message">[2-3 sentences about spatial experience]</p>
        <a href="#" class="btn-primary">Download for Vision Pro</a>
    </header>

    <section class="spatial-pillars">
        <h2>Spatial Computing Reimagined</h2>
        <div class="pillars-grid">
            <div class="pillar-card">
                <div class="icon">🌐</div>
                <h3>Infinite 3D Workspace</h3>
                <p>[Description focusing on unlimited spatial canvas]</p>
            </div>
            <!-- 4 more pillars -->
        </div>
    </section>

    <section class="experience">
        <h2>Experience Spatial [App Type]</h2>
        <div class="screenshots-grid">
            <!-- 16:9 spatial views -->
        </div>
    </section>
</body>
</html>
```

---

## 10. Resources & References

### Inspiration Sources
- Apple Vision Pro website
- Apple visionOS developer documentation
- visionOS HIG (Human Interface Guidelines)
- Spatial computing demos at WWDC
- Meta Quest Pro experiences

### Design Tools
- Figma with 3D plugins
- Spline for 3D mockups
- After Effects for spatial animations
- Reality Composer Pro for visionOS previews

### Testing
- Test on large displays (27"+ to simulate spatial scale)
- View in VR headset if possible
- Check with accessibility tools
- Test responsive breakpoints (360px-1920px)
- Validate color contrast ratios

---

## Summary

**The Golden Rule:** Every element of a visionOS landing page should reinforce that the app exists in **immersive 3D space**, is controlled by **natural gestures**, and provides benefits **only possible in spatial computing**.

If your landing page could work for a traditional mobile app with minor tweaks, you haven't gone far enough into spatial computing territory.

---

**Version:** 1.0
**Last Updated:** December 18, 2024
**Status:** Complete
