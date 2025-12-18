# How to View the Landing Page

## Quick Start

### Option 1: Open Directly in Browser
1. Navigate to the `landing-page` folder
2. Double-click `index.html`
3. It will open in your default web browser

### Option 2: Use a Local Server (Recommended)
For the best experience, use a local web server:

**Python (if installed):**
```bash
cd landing-page
python -m http.server 8000
# Then open: http://localhost:8000
```

**Node.js (if installed):**
```bash
cd landing-page
npx serve
# Then open the URL shown
```

**VS Code Live Server:**
1. Install "Live Server" extension
2. Right-click `index.html`
3. Select "Open with Live Server"

## What You'll See

### Hero Section
- Bold headline: "Transform Product Development with Spatial Computing"
- Key statistics: 70% faster, 90% fewer prototypes, $8.5M savings
- Apple Vision Pro mockup visualization
- Two CTAs: "Start Free Trial" and "Watch Demo Video"

### Features Section
6 feature cards with icons:
- 🎯 Immersive 3D Design
- 🔧 Advanced Manufacturing
- 📊 Real-Time Simulation
- 🤝 Collaborative Workspaces
- 🤖 AI-Powered Intelligence
- ⚡ Lightning Fast

### ROI Section (Blue Gradient)
Quantified business impact with 4 major metrics

### Pricing Section
3 tiers:
- Design Studio: $599/user/month
- Manufacturing Pro: $1,199/user/month (Most Popular)
- Enterprise Innovation: $1,999/user/month

### Testimonials
3 customer success stories from industry leaders

### Final CTA
Strong call-to-action with multiple conversion options

## Interactive Elements

Try these interactions:
- **Hover over feature cards** - They lift up with shadow
- **Hover over pricing cards** - Smooth scale animation
- **Click navigation links** - Smooth scroll to sections
- **Scroll down** - Elements fade in as you scroll
- **Resize window** - Fully responsive design

## Mobile View

To see mobile design:
1. Open browser DevTools (F12)
2. Click "Toggle Device Toolbar" (Ctrl+Shift+M)
3. Select iPhone or iPad
4. See responsive layout changes

## Customization

To customize for your needs, edit `index.html`:
- **Line 240**: Hero headline
- **Line 370**: Features content
- **Line 550**: Pricing tiers
- **Line 650**: Testimonials
- **Colors**: CSS variables at top of `<style>` section

Enjoy exploring the landing page! 🚀
