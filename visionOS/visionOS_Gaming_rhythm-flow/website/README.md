# Rhythm Flow - Landing Page

Modern, responsive landing page for Rhythm Flow, the revolutionary spatial rhythm game for Apple Vision Pro.

## 🎨 Design Features

### Visual Design
- **Cyberpunk/Neon Aesthetic** - Vibrant gradients matching the game's visual style
- **Animated Background** - Floating gradient orbs with parallax effects
- **Smooth Animations** - Fade-in effects, hover states, and micro-interactions
- **Glassmorphism** - Frosted glass effects with backdrop blur
- **Responsive Layout** - Perfect on desktop, tablet, and mobile

### Sections Included
1. **Hero** - Eye-catching headline with CTA buttons
2. **Features** - 6 key feature cards with icons
3. **How It Works** - 3-step process explanation
4. **Gameplay Video** - Video player placeholder
5. **Testimonials** - Social proof from players
6. **Pricing** - 3 pricing tiers (Base, Subscription, À la carte)
7. **FAQ** - Interactive accordion with common questions
8. **CTA** - Download section with App Store button
9. **Footer** - Links, social media, legal

## 🚀 Quick Start

### Option 1: Open Locally

Simply open `index.html` in your web browser:

```bash
cd website
open index.html
# or
python3 -m http.server 8000
# Then visit http://localhost:8000
```

### Option 2: Local Development Server

For better development experience with live reload:

```bash
# Using Python
cd website
python3 -m http.server 8000

# Using Node.js (if you have http-server installed)
npx http-server website -p 8000

# Using PHP
php -S localhost:8000
```

Then open http://localhost:8000 in your browser.

## 📁 File Structure

```
website/
├── index.html           # Main HTML file
├── css/
│   └── styles.css      # All styling (responsive, animations)
├── js/
│   └── script.js       # Interactive features
├── assets/
│   ├── images/         # Images and screenshots (to be added)
│   └── videos/         # Video files (to be added)
└── README.md           # This file
```

## 🎯 Key Features Implemented

### Interactive Elements
- ✅ Smooth scroll navigation
- ✅ Sticky navbar with scroll effects
- ✅ Mobile-responsive hamburger menu
- ✅ FAQ accordion (expand/collapse)
- ✅ Hover effects on all interactive elements
- ✅ Video play button (ready for video embed)
- ✅ Animated counters for statistics
- ✅ Intersection Observer for fade-in animations
- ✅ Parallax mouse tracking on hero orbs

### Animations
- ✅ Floating gradient orbs in hero
- ✅ Pulsing note elements
- ✅ Fade-in on scroll
- ✅ Hover transforms and glows
- ✅ Smooth transitions throughout

### Performance
- ✅ Optimized CSS with custom properties
- ✅ Lazy loading support (for images)
- ✅ Efficient animations (GPU-accelerated)
- ✅ Minimal JavaScript bundle

## 🎨 Customization

### Colors

Edit the CSS variables in `css/styles.css`:

```css
:root {
    --primary-cyan: #00D9FF;
    --primary-pink: #FF0099;
    --primary-purple: #B900FF;
    --primary-green: #00FF88;
    --primary-yellow: #FFD700;
    /* ... more colors ... */
}
```

### Fonts

The landing page uses:
- **Inter** - Body text
- **Space Grotesk** - Headlines

To change fonts, update the Google Fonts link in `index.html` and the font variables in `styles.css`.

### Content

All content is easily editable in `index.html`. Look for sections marked with comments like:

```html
<!-- Hero Section -->
<!-- Features Section -->
<!-- Pricing Section -->
```

## 📱 Responsive Breakpoints

- **Desktop**: > 1024px (full layout)
- **Tablet**: 768px - 1024px (adapted grid)
- **Mobile**: < 768px (single column, hamburger menu)

## 🔧 Adding Real Content

### Images

Add screenshots and images to `assets/images/`:

```html
<!-- Replace placeholders with: -->
<img src="assets/images/screenshot-1.jpg" alt="Gameplay screenshot">
```

### Video

Add gameplay video to `assets/videos/`:

```html
<!-- Replace video placeholder in GameplaySpace: -->
<video src="assets/videos/trailer.mp4" controls></video>
```

### Links

Update all `#` links with actual URLs:

```html
<!-- App Store link -->
<a href="https://apps.apple.com/app/rhythm-flow/id123456789">

<!-- Social media links -->
<a href="https://twitter.com/rhythmflowgame">
<a href="https://discord.gg/rhythmflow">
```

## 🌐 Deployment

### Option 1: GitHub Pages

```bash
# Push to GitHub
git add website/
git commit -m "Add landing page"
git push

# Enable GitHub Pages in repository settings
# Select branch: main
# Folder: /website
```

Your site will be live at: `https://username.github.io/repository-name/`

### Option 2: Netlify

1. Go to [Netlify](https://netlify.com)
2. Click "New site from Git"
3. Connect your GitHub repository
4. Set build folder to `website`
5. Deploy!

### Option 3: Vercel

```bash
# Install Vercel CLI
npm i -g vercel

# Deploy
cd website
vercel
```

### Option 4: Custom Server

Upload files via FTP/SFTP to your web server:

```bash
# Example with rsync
rsync -avz website/ user@yourserver.com:/var/www/html/
```

## 🔍 SEO Optimization

Already included:
- ✅ Meta description
- ✅ Open Graph tags
- ✅ Semantic HTML5
- ✅ Descriptive alt texts (add to images)
- ✅ Clean URL structure

To improve further:
1. Add `sitemap.xml`
2. Add `robots.txt`
3. Optimize images (compress, use WebP)
4. Add schema.org markup
5. Create blog for content marketing

## 📊 Analytics Integration

### Google Analytics

Add to `<head>` in `index.html`:

```html
<!-- Global site tag (gtag.js) - Google Analytics -->
<script async src="https://www.googletagmanager.com/gtag/js?id=GA_TRACKING_ID"></script>
<script>
  window.dataLayer = window.dataLayer || [];
  function gtag(){dataLayer.push(arguments);}
  gtag('js', new Date());
  gtag('config', 'GA_TRACKING_ID');
</script>
```

### Plausible (Privacy-friendly alternative)

```html
<script defer data-domain="yourdomain.com" src="https://plausible.io/js/plausible.js"></script>
```

## 🐛 Browser Support

Tested and working on:
- ✅ Chrome 90+
- ✅ Firefox 88+
- ✅ Safari 14+
- ✅ Edge 90+

Note: Some CSS features may require vendor prefixes for older browsers.

## 🎓 Learning Resources

This landing page demonstrates:
- Modern CSS Grid and Flexbox
- CSS Custom Properties (Variables)
- CSS Animations and Transitions
- Intersection Observer API
- Responsive Design Patterns
- Glassmorphism Effects
- Gradient Design

## 🤝 Contributing

To improve the landing page:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/improvement`)
3. Make your changes
4. Test responsiveness (Chrome DevTools)
5. Commit (`git commit -m 'Improve landing page'`)
6. Push (`git push origin feature/improvement`)
7. Open a Pull Request

## 📄 License

Same as main project (MIT License)

## 🎁 Easter Eggs

Try the Konami code: ↑ ↑ ↓ ↓ ← → ← → B A

## 📞 Support

Questions about the landing page?
- Open an issue on GitHub
- Contact: contact@beatspacestudios.com (TBD)

---

**Built with HTML5, CSS3, and Vanilla JavaScript**
**No frameworks, no build tools, just clean code**

Enjoy! 🎵
