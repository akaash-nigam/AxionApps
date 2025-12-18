# Landing Page - Supply Chain Control Tower

A modern, responsive landing page for the Supply Chain Control Tower visionOS application.

## 🎨 Features

### Design
- **Modern Dark Theme** - Matches visionOS aesthetic
- **Responsive Layout** - Mobile-first design
- **Smooth Animations** - Engaging micro-interactions
- **Gradient Accents** - Eye-catching visual elements
- **Glass Morphism** - Modern UI effects

### Sections
1. **Hero** - Compelling value proposition with animated background
2. **Social Proof** - Enterprise trust indicators
3. **Features** - 6 key features with hover effects
4. **Benefits** - Quantified business impact (30%, 25%, 80% improvements)
5. **Demo** - Video placeholder with call-to-action
6. **Testimonials** - 3 customer success stories
7. **Pricing** - 3-tier pricing (Starter, Professional, Enterprise)
8. **Contact Form** - Lead capture with validation
9. **Footer** - Links and legal information

### Interactivity
- ✅ Smooth scroll navigation
- ✅ Mobile menu toggle
- ✅ Intersection Observer animations
- ✅ Stats counter animation
- ✅ Form validation
- ✅ Particle system background
- ✅ Video player integration
- ✅ Hover effects on cards

## 🚀 Quick Start

### Option 1: Open Directly
Simply open `index.html` in your web browser:
```bash
open index.html
# or
google-chrome index.html
# or
firefox index.html
```

### Option 2: Local Server (Recommended)
For better testing, use a local server:

**Using Python:**
```bash
# Python 3
cd landing-page
python -m http.server 8000

# Visit: http://localhost:8000
```

**Using Node.js:**
```bash
npm install -g http-server
cd landing-page
http-server -p 8000

# Visit: http://localhost:8000
```

**Using PHP:**
```bash
cd landing-page
php -S localhost:8000

# Visit: http://localhost:8000
```

## 📁 File Structure

```
landing-page/
├── index.html              # Main HTML file
├── css/
│   └── styles.css         # All styles (15KB+)
├── js/
│   └── main.js            # Interactive features (8KB+)
├── images/                 # Image assets (add your images here)
│   ├── logo.png
│   ├── demo-video-thumbnail.jpg
│   └── screenshots/
└── README.md              # This file
```

## 🎯 Key Metrics & Stats

The landing page highlights:
- **30%** Inventory Reduction
- **25%** OTIF Improvement
- **20%** Cost Reduction
- **80%** Disruption Prevention
- **75%** Faster Response
- **11-month** Payback Period
- **500%** 5-Year ROI

## 🛠️ Customization

### Colors
Edit CSS variables in `styles.css`:
```css
:root {
    --primary-color: #0071e3;      /* Blue */
    --accent-color: #00d4ff;       /* Cyan */
    --success-color: #30d158;      /* Green */
    --warning-color: #ff9f0a;      /* Orange */
    --error-color: #ff3b30;        /* Red */
}
```

### Content
Edit sections in `index.html`:
- Hero title/subtitle
- Feature descriptions
- Testimonials
- Pricing tiers
- Company information

### Images
Add your images to `images/` folder and update:
- Logo: Replace `🌐` emoji with `<img>` tag
- Demo video thumbnail
- Company logos
- Customer avatars
- Screenshots

### Form Integration
Connect to your backend in `js/main.js`:
```javascript
// ContactForm.handleSubmit()
// Replace console.log with actual API call
await fetch('/api/leads', {
    method: 'POST',
    body: JSON.stringify(formData)
});
```

## 📱 Responsive Breakpoints

- **Desktop**: > 1024px (full layout)
- **Tablet**: 768px - 1024px (adapted grid)
- **Mobile**: < 768px (stacked layout, hamburger menu)
- **Small Mobile**: < 480px (optimized for small screens)

## ⚡ Performance

### Optimizations
- ✅ CSS minification ready
- ✅ JavaScript debouncing
- ✅ Lazy loading animations
- ✅ Efficient particle system
- ✅ Optimized scroll listeners

### Load Times
- Initial HTML: <1KB (compressed)
- CSS: ~15KB
- JavaScript: ~8KB
- **Total**: ~24KB (excluding images)

### Best Practices
- Use WebP images for better compression
- Enable GZIP compression on server
- Add CDN for static assets
- Implement lazy loading for images
- Use modern image formats (WebP, AVIF)

## 🎨 Design System

### Typography
- **Primary Font**: Inter (sans-serif)
- **Weights**: 300, 400, 500, 600, 700, 800, 900
- **Loaded from**: Google Fonts

### Spacing Scale
```css
--spacing-xs: 0.5rem   /* 8px */
--spacing-sm: 1rem     /* 16px */
--spacing-md: 2rem     /* 32px */
--spacing-lg: 4rem     /* 64px */
--spacing-xl: 6rem     /* 96px */
```

### Border Radius
```css
--border-radius: 12px
--border-radius-lg: 24px
```

## 🔧 Browser Support

Tested and working on:
- ✅ Chrome/Edge (100+)
- ✅ Firefox (100+)
- ✅ Safari (15+)
- ✅ Mobile browsers (iOS Safari, Chrome Mobile)

## 📊 Analytics Integration

To track page performance and conversions:

### Google Analytics
Add to `<head>` in `index.html`:
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

### Track Custom Events
Use the exposed API in `main.js`:
```javascript
window.SupplyChainApp.trackEvent('button_click', {
    button: 'Get Started',
    location: 'Hero'
});
```

## 🚀 Deployment

### Option 1: Static Hosting
Upload to:
- **Netlify**: Drag & drop or connect Git
- **Vercel**: Connect repository
- **GitHub Pages**: Push to gh-pages branch
- **AWS S3**: Upload to S3 bucket + CloudFront

### Option 2: Web Server
Upload to any web server:
```bash
# Using SCP
scp -r landing-page/* user@server:/var/www/html/

# Using FTP
# Use FileZilla or similar FTP client
```

### Custom Domain
1. Point your domain to hosting provider
2. Configure DNS (A record or CNAME)
3. Enable HTTPS (Let's Encrypt)
4. Test across devices

## 🎬 Adding Video

Replace the placeholder in `index.html`:

### YouTube Embed
```html
<iframe
    width="100%"
    height="450"
    src="https://www.youtube.com/embed/YOUR_VIDEO_ID"
    frameborder="0"
    allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
    allowfullscreen
></iframe>
```

### Vimeo Embed
```html
<iframe
    src="https://player.vimeo.com/video/YOUR_VIDEO_ID"
    width="100%"
    height="450"
    frameborder="0"
    allow="autoplay; fullscreen; picture-in-picture"
    allowfullscreen
></iframe>
```

## ✅ Pre-Launch Checklist

- [ ] Replace placeholder content with real copy
- [ ] Add company logo
- [ ] Add real customer testimonials
- [ ] Update pricing information
- [ ] Connect contact form to backend
- [ ] Add real demo video
- [ ] Add company/partner logos
- [ ] Configure analytics
- [ ] Test on mobile devices
- [ ] Test form validation
- [ ] Check all links
- [ ] Optimize images
- [ ] Enable HTTPS
- [ ] Add meta tags for SEO
- [ ] Add Open Graph tags for social sharing
- [ ] Test page speed (Google PageSpeed Insights)
- [ ] Test accessibility (WAVE, Lighthouse)

## 🔍 SEO Optimization

### Meta Tags (add to `<head>`)
```html
<!-- Primary Meta Tags -->
<meta name="title" content="Supply Chain Control Tower | visionOS App">
<meta name="description" content="Transform your supply chain with immersive 3D visualization on Apple Vision Pro. 30% inventory reduction, 25% OTIF improvement.">

<!-- Open Graph / Facebook -->
<meta property="og:type" content="website">
<meta property="og:url" content="https://yoursite.com/">
<meta property="og:title" content="Supply Chain Control Tower">
<meta property="og:description" content="Transform your supply chain with spatial computing">
<meta property="og:image" content="https://yoursite.com/images/og-image.jpg">

<!-- Twitter -->
<meta property="twitter:card" content="summary_large_image">
<meta property="twitter:url" content="https://yoursite.com/">
<meta property="twitter:title" content="Supply Chain Control Tower">
<meta property="twitter:description" content="Transform your supply chain with spatial computing">
<meta property="twitter:image" content="https://yoursite.com/images/twitter-image.jpg">
```

## 📞 Support

For questions or issues:
- Email: support@supplychainapp.com
- Documentation: See main README.md
- GitHub Issues: [Link to repo]

## 📄 License

© 2025 Supply Chain Control Tower. All rights reserved.

---

**Built with ❤️ for Apple Vision Pro**
