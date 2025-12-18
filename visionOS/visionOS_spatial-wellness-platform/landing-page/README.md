# Spatial Wellness Platform - Landing Page

A modern, interactive landing page for the Spatial Wellness Platform - the world's first spatial wellness application for Apple Vision Pro.

## 🌟 Features

### Visual Design
- **Modern Gradient Design**: Eye-catching gradients using brand colors (Primary Green #2ECC71, Secondary Blue #3498DB, Accent Purple #9B59B6)
- **Responsive Layout**: Fully responsive design that works on all devices
- **Smooth Animations**: Professional animations and transitions throughout
- **Glass Morphism**: Modern frosted glass effects for navigation and cards
- **Floating Shapes**: Animated background elements for visual interest

### Interactive Elements
- **Animated Counters**: Stats that count up when scrolled into view (40%, 30%, 90%)
- **ROI Calculator**: Real-time calculator showing projected savings based on company size
- **Smooth Scrolling**: Smooth anchor link navigation
- **Mobile Menu**: Responsive mobile navigation
- **Hover Effects**: Interactive hover states on all clickable elements
- **Scroll Reveal**: Elements animate in as you scroll down the page

### Sections

1. **Hero Section**
   - Compelling headline and value proposition
   - Call-to-action buttons (Watch Demo, Schedule Consultation)
   - Animated statistics (40% cost reduction, 30% productivity gain, 90% engagement)
   - Vision Pro mockup with simulated health data

2. **Trust Indicators**
   - Placeholder logos for client companies
   - Social proof and credibility

3. **Problem Statement**
   - Highlights the healthcare cost crisis
   - Shows pain points with statistics
   - Rising costs, lost productivity, poor engagement

4. **Features Grid**
   - 6 key features with icons and descriptions:
     - 3D Health Landscapes
     - AI Health Coach
     - Immersive Meditation
     - Virtual Gym
     - Social Challenges
     - HealthKit Integration

5. **ROI Calculator**
   - Interactive calculator with inputs for:
     - Number of employees
     - Average healthcare cost per employee
   - Real-time calculation of:
     - Healthcare savings (40%)
     - Productivity gain (30%)
     - Absenteeism reduction (50%)
     - Total annual ROI

6. **Demo Video Section**
   - Placeholder for product demo video
   - Feature highlights below video

7. **Testimonials**
   - Customer success stories
   - 5-star ratings
   - Company names and titles

8. **Pricing Section**
   - 3 pricing tiers: Starter, Professional, Enterprise
   - Feature comparison
   - Clear CTAs for each plan

9. **Final CTA**
   - Strong call-to-action
   - Multiple conversion options
   - Trust badges (HIPAA Compliant, Enterprise Security, SLA)

10. **Footer**
    - Navigation links
    - Social media links
    - Legal links

## 🚀 Getting Started

### Prerequisites
None! The landing page uses CDN links for all dependencies:
- Tailwind CSS (styling framework)
- Font Awesome (icons)
- Google Fonts (Inter font family)

### Installation

1. Clone the repository:
```bash
git clone https://github.com/your-org/visionOS_spatial-wellness-platform.git
cd visionOS_spatial-wellness-platform/landing-page
```

2. Open `index.html` in your browser:
```bash
# macOS
open index.html

# Linux
xdg-open index.html

# Windows
start index.html
```

Or use a local server:
```bash
# Python
python -m http.server 8000

# Node.js (if you have http-server installed)
npx http-server

# Then visit http://localhost:8000
```

### Deployment

#### Deploy to GitHub Pages

1. Push to GitHub
2. Go to Settings → Pages
3. Select branch and `/landing-page` folder
4. Your site will be live at `https://username.github.io/repo-name/`

#### Deploy to Netlify

1. Create account at [netlify.com](https://netlify.com)
2. Drag and drop the `landing-page` folder
3. Site goes live instantly with custom domain option

#### Deploy to Vercel

```bash
cd landing-page
npx vercel
```

## 📱 Customization

### Update Colors

Edit the Tailwind config in `index.html`:
```javascript
tailwind.config = {
    theme: {
        extend: {
            colors: {
                primary: '#2ECC71',    // Change to your primary color
                secondary: '#3498DB',   // Change to your secondary color
                accent: '#9B59B6',      // Change to your accent color
            }
        }
    }
}
```

### Update Content

All content is in `index.html`. Key sections to customize:

- **Hero Section**: Lines 70-150
  - Update headline, subheadline, and CTA buttons

- **Features**: Lines 350-500
  - Update the 6 feature cards with your features

- **Pricing**: Lines 800-950
  - Update pricing tiers and features

- **Testimonials**: Lines 700-800
  - Replace with real customer testimonials

### Add Real Images

1. Add images to `assets/images/`
2. Replace placeholder content:
```html
<img src="assets/images/your-image.jpg" alt="Description">
```

### Add Real Video

Replace the video placeholder section with actual video:
```html
<video controls>
    <source src="assets/videos/demo.mp4" type="video/mp4">
</video>
```

Or embed YouTube/Vimeo:
```html
<iframe src="https://www.youtube.com/embed/VIDEO_ID" ...></iframe>
```

## 🎨 Color Scheme

| Color | Hex | Usage |
|-------|-----|-------|
| Primary (Green) | `#2ECC71` | Main CTA buttons, success states |
| Secondary (Blue) | `#3498DB` | Links, secondary CTAs |
| Accent (Purple) | `#9B59B6` | Highlights, special elements |
| Dark | `#1a202c` | Footer, dark sections |
| Gray | `#f7fafc` - `#1a202c` | Backgrounds, text |

## 📊 Analytics Integration

Add your analytics tracking code:

### Google Analytics
```html
<!-- Add before closing </head> tag -->
<script async src="https://www.googletagmanager.com/gtag/js?id=GA_MEASUREMENT_ID"></script>
<script>
  window.dataLayer = window.dataLayer || [];
  function gtag(){dataLayer.push(arguments);}
  gtag('js', new Date());
  gtag('config', 'GA_MEASUREMENT_ID');
</script>
```

### Mixpanel
```html
<script>
(function(c,a){...})(document,window);
mixpanel.init("YOUR_TOKEN");
</script>
```

## 🔧 JavaScript Features

### ROI Calculator
Located in `js/main.js`, the calculator automatically updates based on inputs:
```javascript
function calculateROI() {
    const employees = parseInt(document.getElementById('employee-count')?.value) || 500;
    const avgCost = parseInt(document.getElementById('avg-cost')?.value) || 15000;
    // Calculations based on PRD metrics...
}
```

### Counter Animation
Animates numbers when they scroll into view:
```javascript
function initCounters() {
    // Uses Intersection Observer API
    // Animates from 0 to target value
}
```

### Scroll Reveal
Elements fade in as you scroll:
```javascript
function initScrollReveal() {
    // Observes elements with .scroll-reveal class
    // Adds .revealed class when visible
}
```

## 🎯 Conversion Optimization

### Current CTAs
1. **Primary**: "Request Demo" (Navigation, Hero, Footer)
2. **Secondary**: "Watch Demo" (Hero)
3. **Tertiary**: "Schedule Consultation" (Hero)
4. **Pricing**: Start Free Trial buttons

### A/B Testing Suggestions
- Test different hero headlines
- Test CTA button colors and text
- Test pricing display formats
- Test testimonial positions

## ♿ Accessibility

The landing page is built with accessibility in mind:
- Semantic HTML5 elements
- ARIA labels where needed
- Keyboard navigation support
- Focus visible states
- Color contrast ratios meet WCAG AA standards
- Respects `prefers-reduced-motion`
- Screen reader friendly

## 📈 Performance

### Optimization Techniques
- Uses CDN for all external resources
- Minimal JavaScript (< 10KB)
- CSS animations (GPU accelerated)
- Lazy loading (ready for images)
- Debounced scroll events
- Intersection Observer (not scroll listeners)

### Lighthouse Score Goals
- Performance: 95+
- Accessibility: 100
- Best Practices: 100
- SEO: 100

## 🔒 Security

- No external form submissions (ready for your backend)
- HTTPS enforced (when deployed)
- No inline JavaScript (CSP friendly)
- Sanitized user inputs

## 📝 SEO

The page includes:
- Meta descriptions
- Open Graph tags (ready for social sharing)
- Semantic HTML structure
- Descriptive alt texts (when real images added)
- Mobile-friendly design

### Add Open Graph Tags
```html
<meta property="og:title" content="Spatial Wellness Platform">
<meta property="og:description" content="Transform workplace wellness...">
<meta property="og:image" content="https://yoursite.com/og-image.jpg">
<meta property="og:url" content="https://yoursite.com">
```

## 🛠️ Development

### File Structure
```
landing-page/
├── index.html              # Main HTML file
├── css/
│   └── styles.css         # Custom CSS and animations
├── js/
│   └── main.js           # Interactive features
├── assets/
│   ├── images/           # Image assets (add your images here)
│   └── videos/           # Video assets
└── README.md             # This file
```

### Browser Support
- Chrome/Edge: Last 2 versions
- Firefox: Last 2 versions
- Safari: Last 2 versions
- Mobile browsers: iOS Safari, Chrome Mobile

## 📧 Contact Form Integration

To connect to a real backend:

### Option 1: Netlify Forms
```html
<form netlify>
    <input type="text" name="name" required>
    <input type="email" name="email" required>
    <button type="submit">Submit</button>
</form>
```

### Option 2: Formspree
```html
<form action="https://formspree.io/f/YOUR_FORM_ID" method="POST">
    ...
</form>
```

### Option 3: Custom API
Update `js/main.js`:
```javascript
fetch('/api/contact', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(formData)
});
```

## 🎬 Next Steps

1. **Add Real Content**
   - Replace placeholder company logos
   - Add real customer testimonials
   - Upload product screenshots/videos

2. **Connect Backend**
   - Set up contact form submission
   - Integrate with CRM (HubSpot, Salesforce, etc.)
   - Add email marketing integration (Mailchimp, etc.)

3. **Add Analytics**
   - Google Analytics or Mixpanel
   - Conversion tracking
   - Heatmap tools (Hotjar, etc.)

4. **SEO Optimization**
   - Submit to Google Search Console
   - Create sitemap.xml
   - Optimize meta tags

5. **Marketing**
   - Set up social media sharing
   - Create email campaigns
   - Launch ad campaigns (Google Ads, LinkedIn, etc.)

## 📞 Support

For questions or issues:
- Email: support@spatialwellness.health
- GitHub Issues: [Create an issue](https://github.com/your-org/repo/issues)

## 📄 License

Copyright © 2025 Spatial Wellness Platform. All rights reserved.

---

**Built with ❤️ for healthier workplaces**
