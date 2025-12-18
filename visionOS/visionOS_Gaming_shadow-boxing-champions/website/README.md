# Shadow Boxing Champions - Landing Page

Professional landing page for Shadow Boxing Champions, the revolutionary boxing training app for Apple Vision Pro.

## 🚀 Overview

This is a modern, responsive landing page built with HTML, CSS, and vanilla JavaScript. It showcases the app's features, pricing, and value proposition to potential customers.

## 📁 Structure

```
website/
├── index.html          # Main landing page
├── css/
│   └── styles.css      # All styling
├── js/
│   └── script.js       # Interactive features
├── images/             # Image assets
│   └── README.md       # Image requirements
└── README.md           # This file
```

## ✨ Features

### Landing Page Sections

1. **Hero Section**
   - Compelling headline and value proposition
   - Call-to-action buttons
   - Live stats (downloads, ratings, users)
   - Product visualization

2. **Features Grid**
   - 6 key features with icons
   - Highlighted "Most Popular" feature
   - Hover effects and animations

3. **How It Works**
   - 4-step process visualization
   - Alternating layout for visual interest
   - Clear instructions for getting started

4. **Training Modes**
   - Technical Training
   - Fitness Workout
   - Competitive Match
   - Duration and feature details

5. **Testimonials**
   - Real user quotes
   - Star ratings
   - User credentials

6. **Pricing**
   - Three pricing tiers
   - Feature comparison
   - Clear call-to-action
   - Free trial offering

7. **FAQ**
   - Common questions answered
   - 2-column responsive grid
   - Easily scannable format

8. **Footer**
   - Navigation links
   - Social media links
   - Legal information

### Interactive Features

- Smooth scroll navigation
- Sticky navbar with scroll effect
- Mobile menu toggle
- Animated counters for statistics
- Scroll-triggered animations
- Responsive design (mobile, tablet, desktop)

## 🎨 Design

### Color Palette

- **Primary Red**: #E02020 (Boxing, energy, action)
- **Secondary Blue**: #2962FF (Technology, trust)
- **Accent Gold**: #FFD700 (Achievement, premium)
- **Dark**: #1A1A1A (Text, backgrounds)
- **Light**: #FFFFFF (Backgrounds, text on dark)

### Typography

- **Font**: Inter (Google Fonts)
- **Weights**: 300-900 for flexibility
- **Hierarchy**: Clear size progression

### Components

- Gradient buttons with hover effects
- Card-based layouts with shadows
- Smooth animations and transitions
- Mobile-responsive navigation

## 📱 Responsive Design

The landing page is fully responsive with breakpoints at:

- **Desktop**: 1024px+
- **Tablet**: 768px - 1023px
- **Mobile**: < 768px

### Mobile Optimizations

- Hamburger menu
- Stacked layouts
- Touch-friendly buttons
- Optimized font sizes

## 🛠️ Setup & Deployment

### Local Development

1. **Clone the repository**
   ```bash
   cd website
   ```

2. **Open in browser**
   - Simply open `index.html` in your browser
   - Or use a local server:
     ```bash
     python -m http.server 8000
     # Visit http://localhost:8000
     ```

3. **Development server (recommended)**
   ```bash
   # Using VS Code Live Server extension
   # Or use any static server
   npx serve .
   ```

### Production Deployment

#### Option 1: Static Hosting (Recommended)

Deploy to any static hosting service:

**Netlify:**
```bash
# Install Netlify CLI
npm install -g netlify-cli

# Deploy
netlify deploy --prod --dir=.
```

**Vercel:**
```bash
# Install Vercel CLI
npm install -g vercel

# Deploy
vercel --prod
```

**GitHub Pages:**
```bash
# Push to gh-pages branch
git subtree push --prefix website origin gh-pages
```

#### Option 2: Traditional Hosting

Upload all files to your web server:
- Upload entire `website/` folder
- Ensure `index.html` is in root
- Set proper MIME types
- Enable gzip compression

### Environment Setup

No build process required! This is pure HTML/CSS/JS.

Optional optimizations for production:

1. **Minify CSS/JS**
   ```bash
   # Using npm packages
   npm install -g clean-css-cli uglify-js

   cleancss -o css/styles.min.css css/styles.css
   uglifyjs js/script.js -o js/script.min.js
   ```

2. **Optimize Images**
   - Use ImageOptim or similar
   - Convert to WebP with fallbacks
   - Use responsive images

3. **CDN Setup**
   - Upload assets to CDN
   - Update image paths
   - Enable caching headers

## 🎯 SEO & Performance

### SEO Optimization

Already included:
- ✅ Semantic HTML5
- ✅ Meta descriptions
- ✅ Proper heading hierarchy
- ✅ Alt text on images
- ✅ Open Graph tags (add these)
- ✅ Twitter Cards (add these)

Add to `<head>` for social sharing:
```html
<!-- Open Graph -->
<meta property="og:title" content="Shadow Boxing Champions">
<meta property="og:description" content="Professional boxing training for Apple Vision Pro">
<meta property="og:image" content="https://yoursite.com/images/og-image.jpg">
<meta property="og:url" content="https://yoursite.com">

<!-- Twitter Card -->
<meta name="twitter:card" content="summary_large_image">
<meta name="twitter:title" content="Shadow Boxing Champions">
<meta name="twitter:description" content="Professional boxing training for Apple Vision Pro">
<meta name="twitter:image" content="https://yoursite.com/images/twitter-card.jpg">
```

### Performance

Current optimizations:
- ✅ Lazy loading images
- ✅ Efficient CSS (no frameworks)
- ✅ Minimal JavaScript
- ✅ Web fonts optimized
- ✅ Intersection Observer for animations

Additional recommendations:
- Add resource hints (preconnect, prefetch)
- Implement service worker for caching
- Use HTTP/2 server push
- Enable gzip/brotli compression

## 📊 Analytics (Optional)

Add tracking code before `</head>`:

```html
<!-- Google Analytics -->
<script async src="https://www.googletagmanager.com/gtag/js?id=GA_MEASUREMENT_ID"></script>
<script>
  window.dataLayer = window.dataLayer || [];
  function gtag(){dataLayer.push(arguments);}
  gtag('js', new Date());
  gtag('config', 'GA_MEASUREMENT_ID');
</script>
```

## 🔧 Customization

### Update Content

1. **Edit text** in `index.html`
2. **Update colors** in `:root` variables in `styles.css`
3. **Modify animations** in `script.js`

### Add New Sections

1. Add HTML section in `index.html`
2. Style in `styles.css`
3. Add interactivity in `script.js` if needed

### Change Images

Replace images in `images/` folder following the guidelines in `images/README.md`

## 🐛 Browser Support

Tested and working on:
- ✅ Chrome/Edge (latest)
- ✅ Firefox (latest)
- ✅ Safari (latest)
- ✅ Mobile browsers

Requires modern browser features:
- CSS Grid
- CSS Custom Properties
- Intersection Observer
- ES6 JavaScript

## 📝 To-Do Before Launch

- [ ] Add real images (see `images/README.md`)
- [ ] Update all links (download, demo, social media)
- [ ] Add actual demo video URL
- [ ] Test all forms (if added)
- [ ] Validate HTML/CSS
- [ ] Test on all major browsers
- [ ] Mobile device testing
- [ ] Performance audit (Lighthouse)
- [ ] SEO audit
- [ ] Set up analytics
- [ ] Configure SSL certificate
- [ ] Set up redirect rules
- [ ] Create 404 page

## 📞 Support

For issues or questions about the landing page:
- Check browser console for errors
- Validate HTML: https://validator.w3.org/
- Test performance: https://developers.google.com/speed/pagespeed/insights/

## 📄 License

Copyright © 2025 Shadow Boxing Champions. All rights reserved.

---

**Built with ❤️ for Apple Vision Pro**
