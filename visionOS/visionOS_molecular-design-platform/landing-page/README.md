# Molecular Design Platform - Landing Page

A modern, responsive landing page designed to attract pharmaceutical companies, research institutions, and scientists to the Molecular Design Platform for Apple Vision Pro.

## 🎨 Design Features

### Visual Design
- **Modern Gradient Design**: Purple-blue gradient theme matching scientific/tech aesthetics
- **Molecular Graphics**: Animated SVG molecule visualizations
- **Glass Morphism**: Frosted glass effects for depth
- **Smooth Animations**: Fade-ins, counter animations, parallax effects
- **Fully Responsive**: Optimized for desktop, tablet, and mobile

### Key Sections

1. **Hero Section**
   - Compelling value proposition
   - Animated 3D molecule visualization
   - Key metrics (75% faster, 10x more molecules, 3x success rate)
   - Dual CTAs (Request Demo, Watch Video)

2. **Problem Section**
   - Highlights current drug discovery challenges
   - $2.6B cost, 90% failure rate, 2D limitations

3. **Features Section**
   - 6 core features with icons:
     - Immersive 3D Visualization
     - AI-Powered Predictions
     - Molecular Dynamics Simulation
     - Real-Time Collaboration
     - Enterprise Integration
     - Regulatory Compliance

4. **How It Works**
   - 3-step process visualization
   - Import/Design → Analyze/Optimize → Export/Synthesize

5. **Social Proof**
   - 3 customer testimonials
   - From CSO, Research Director, Professor personas

6. **Stats Section**
   - Animated counters showing impact
   - 75% time reduction, 3x success rate, 10x molecules, $5B saved

7. **Pricing Section**
   - 3 tiers: Researcher ($299/mo), Team ($999/mo), Enterprise (Custom)
   - Clear feature differentiation
   - "Most Popular" badge on Team plan

8. **Demo Request Form**
   - Simple 4-field form with validation
   - Integrated submission handling
   - Success feedback

## 📁 File Structure

```
landing-page/
├── index.html          # Main HTML file
├── css/
│   └── style.css       # All styles and animations
├── js/
│   └── main.js         # Interactions and animations
├── images/             # Image assets (to be added)
└── README.md          # This file
```

## 🚀 Quick Start

### Local Development

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd landing-page
   ```

2. **Open in browser**
   ```bash
   # On macOS
   open index.html

   # On Linux
   xdg-open index.html

   # Or use a local server (recommended)
   python3 -m http.server 8000
   # Then visit http://localhost:8000
   ```

3. **Edit content**
   - Modify `index.html` for content changes
   - Edit `css/style.css` for styling
   - Update `js/main.js` for behavior changes

### Using a Local Server

For best results, use a local web server:

```bash
# Using Python
python3 -m http.server 8000

# Using Node.js
npx serve .

# Using PHP
php -S localhost:8000
```

## 🌐 Deployment Options

### 1. Netlify (Recommended)

**Via Netlify CLI:**
```bash
npm install -g netlify-cli
netlify deploy --dir=. --prod
```

**Via Drag & Drop:**
1. Go to https://app.netlify.com/drop
2. Drag the `landing-page` folder
3. Site is live instantly!

### 2. Vercel

```bash
npm install -g vercel
vercel --prod
```

### 3. GitHub Pages

1. Push to GitHub repository
2. Go to Settings → Pages
3. Select branch and folder
4. Save and wait for deployment

### 4. AWS S3 + CloudFront

```bash
# Upload to S3
aws s3 sync . s3://your-bucket-name --acl public-read

# Configure CloudFront distribution
# Point origin to S3 bucket
```

### 5. Traditional Web Hosting

Upload files via FTP/SFTP to your web host's public_html directory.

## 🎯 Customization Guide

### Update Company Information

**Logo:**
- Replace the SVG logo in `index.html` (lines 17-25)
- Or add your logo image to `/images/` and reference it

**Contact Information:**
- Update form submission endpoint in `js/main.js` (line 65)
- Add your API endpoint or email service

**Pricing:**
- Edit prices in `index.html` (pricing section)
- Modify features in each tier

**Testimonials:**
- Replace names, titles, and quotes (lines 590-640 in index.html)
- Add real customer photos to `/images/testimonials/`

### Color Scheme

Edit CSS variables in `css/style.css` (lines 6-20):

```css
:root {
    --primary-color: #667eea;      /* Main brand color */
    --secondary-color: #764ba2;    /* Secondary brand color */
    --accent-color: #f093fb;       /* Accent highlights */
    /* ... more colors */
}
```

### Typography

Change the font family in `css/style.css`:

```css
body {
    font-family: 'Your-Font', -apple-system, sans-serif;
}
```

Update the Google Fonts link in `index.html`:
```html
<link href="https://fonts.googleapis.com/css2?family=Your-Font:wght@300;400;600;700&display=swap" rel="stylesheet">
```

## 📊 Analytics Integration

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

### Facebook Pixel

Add before `</head>`:

```html
<!-- Facebook Pixel Code -->
<script>
  !function(f,b,e,v,n,t,s)
  {if(f.fbq)return;n=f.fbq=function(){n.callMethod?
  n.callMethod.apply(n,arguments):n.queue.push(arguments)};
  if(!f._fbq)f._fbq=n;n.push=n;n.loaded=!0;n.version='2.0';
  n.queue=[];t=b.createElement(e);t.async=!0;
  t.src=v;s=b.getElementsByTagName(e)[0];
  s.parentNode.insertBefore(t,s)}(window, document,'script',
  'https://connect.facebook.net/en_US/fbevents.js');
  fbq('init', 'YOUR_PIXEL_ID');
  fbq('track', 'PageView');
</script>
```

## 🔧 Form Integration

### Email Service (EmailJS)

1. Sign up at https://www.emailjs.com/
2. Add this script before `</body>`:

```html
<script src="https://cdn.jsdelivr.net/npm/@emailjs/browser@3/dist/email.min.js"></script>
<script>
  emailjs.init("YOUR_PUBLIC_KEY");
</script>
```

3. Update form submission in `js/main.js`:

```javascript
emailjs.send("YOUR_SERVICE_ID", "YOUR_TEMPLATE_ID", data)
  .then((response) => {
    console.log('SUCCESS!', response.status, response.text);
  });
```

### API Integration

Replace the form submission code in `js/main.js` (line 42):

```javascript
const response = await fetch('https://your-api.com/demo-request', {
    method: 'POST',
    headers: {
        'Content-Type': 'application/json',
    },
    body: JSON.stringify(data)
});
```

## 🎨 Adding Images

### Screenshots/Mockups

1. Add images to `/images/` folder:
   - `hero-visual.png` - Main hero image
   - `feature-1.png` through `feature-6.png` - Feature screenshots
   - `step-1.png` through `step-3.png` - Process steps

2. Update image references in `index.html`:

```html
<img src="images/hero-visual.png" alt="Molecular Design Platform">
```

### Optimizing Images

```bash
# Install imagemin-cli
npm install -g imagemin-cli

# Optimize all images
imagemin images/* --out-dir=images/optimized
```

## ⚡ Performance Optimization

### Minify CSS and JS

```bash
# Install minifiers
npm install -g clean-css-cli uglify-js

# Minify CSS
cleancss -o css/style.min.css css/style.css

# Minify JS
uglifyjs js/main.js -o js/main.min.js -c -m
```

Then update references in `index.html`.

### Enable Caching

Add to `.htaccess` (for Apache):

```apache
<IfModule mod_expires.c>
  ExpiresActive On
  ExpiresByType text/css "access plus 1 year"
  ExpiresByType application/javascript "access plus 1 year"
  ExpiresByType image/svg+xml "access plus 1 year"
</IfModule>
```

## 📱 Testing

### Responsive Testing

Test on different screen sizes:
- Desktop: 1920px, 1440px, 1024px
- Tablet: 768px, 834px
- Mobile: 375px, 414px

### Browser Testing

Test on:
- Chrome (latest)
- Firefox (latest)
- Safari (latest)
- Edge (latest)

### Lighthouse Audit

```bash
# Install Lighthouse
npm install -g lighthouse

# Run audit
lighthouse http://localhost:8000 --view
```

Target scores:
- Performance: >90
- Accessibility: >90
- Best Practices: >90
- SEO: >90

## 📈 SEO Optimization

### Meta Tags

Already included in `index.html`:
- Title tag
- Description meta tag
- Viewport meta tag

### Add More SEO

```html
<!-- Open Graph for social sharing -->
<meta property="og:title" content="Molecular Design Platform">
<meta property="og:description" content="Transform drug discovery with immersive 3D">
<meta property="og:image" content="https://yourdomain.com/images/og-image.png">
<meta property="og:url" content="https://yourdomain.com">

<!-- Twitter Card -->
<meta name="twitter:card" content="summary_large_image">
<meta name="twitter:title" content="Molecular Design Platform">
<meta name="twitter:description" content="Transform drug discovery with immersive 3D">
<meta name="twitter:image" content="https://yourdomain.com/images/twitter-card.png">
```

## 🐛 Troubleshooting

### Animations Not Working

1. Check browser console for JavaScript errors
2. Ensure `js/main.js` is loaded correctly
3. Clear browser cache

### Form Not Submitting

1. Check network tab in developer tools
2. Verify API endpoint is correct
3. Check CORS settings if using external API

### Styles Not Applying

1. Clear browser cache
2. Check CSS file path in `index.html`
3. Inspect elements in browser dev tools

## 📄 License

Copyright © 2025 Molecular Design Platform. All rights reserved.

## 🤝 Support

For questions or issues:
- Email: support@moleculardesign.com
- Documentation: https://docs.moleculardesign.com
- GitHub Issues: https://github.com/your-org/molecular-design-platform

---

**Built with ❤️ for Apple Vision Pro**
