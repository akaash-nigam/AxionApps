# Parkour Pathways Landing Page

A modern, responsive landing page for the Parkour Pathways visionOS application.

## 🎨 Design Features

### Visual Design
- **Modern Gradient Design**: Cyan to purple gradient throughout
- **Dark Theme**: Sleek dark background with glass morphism effects
- **Smooth Animations**: Fade-in animations, hover effects, and transitions
- **Responsive Layout**: Works on desktop, tablet, and mobile devices

### Sections
1. **Hero Section**: Eye-catching headline with CTA buttons and stats
2. **Features**: 6 key features in a responsive grid
3. **How It Works**: 4-step process visualization
4. **Pricing**: 3 pricing tiers with featured option
5. **Testimonials**: Customer reviews and ratings
6. **CTA Section**: Strong call-to-action with gradient background
7. **Footer**: Links, social media, and site information

### Interactive Elements
- Smooth scroll navigation
- Animated stat counters
- Hover effects on cards
- Parallax effects on feature cards
- Mobile-responsive menu
- Scroll-based animations

## 🚀 Quick Start

### Local Development

Simply open the `index.html` file in a modern web browser:

```bash
open index.html
```

Or use a local server:

```bash
# Python
python -m http.server 8000

# Node.js
npx http-server

# PHP
php -S localhost:8000
```

Then visit `http://localhost:8000` in your browser.

## 📁 File Structure

```
landing-page/
├── index.html          # Main HTML file
├── styles.css          # All CSS styles
├── script.js           # JavaScript functionality
└── README.md           # This file
```

## 🎯 Key Features

### Performance
- Lightweight (< 100KB total)
- Fast loading with minimal dependencies
- Optimized CSS with modern features
- Lazy loading ready for images

### SEO Optimized
- Semantic HTML5 structure
- Meta tags for description and social sharing
- Proper heading hierarchy
- Alt tags ready for images

### Accessibility
- ARIA labels on interactive elements
- Keyboard navigation support
- High contrast ratios
- Responsive text sizing

## 🎨 Customization

### Colors

Edit the CSS variables in `styles.css`:

```css
:root {
    --primary: #00D9FF;        /* Main brand color */
    --secondary: #FF3D71;      /* Secondary accent */
    --dark: #0A0E27;           /* Background */
    --gradient: linear-gradient(135deg, #00D9FF 0%, #7B61FF 100%);
}
```

### Content

All content can be edited directly in `index.html`:
- Hero headline and subtitle
- Feature descriptions
- Pricing plans
- Testimonials
- Footer links

### Analytics

Add your analytics tracking code:

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

## 📱 Responsive Breakpoints

- **Mobile**: < 768px
- **Tablet**: 768px - 1024px
- **Desktop**: > 1024px

## 🔧 Technologies Used

- **HTML5**: Semantic markup
- **CSS3**: Modern features (Grid, Flexbox, Custom Properties)
- **JavaScript (ES6+)**: Interactive features
- **Google Fonts**: Inter font family

## 🌐 Browser Support

- Chrome (latest)
- Firefox (latest)
- Safari (latest)
- Edge (latest)
- Mobile browsers

## 📦 Deployment

### GitHub Pages

1. Push to GitHub repository
2. Go to Settings > Pages
3. Select branch and folder
4. Visit your site at `username.github.io/repo-name`

### Netlify

1. Sign up at netlify.com
2. Connect your Git repository
3. Deploy automatically on push

### Vercel

1. Sign up at vercel.com
2. Import your repository
3. Deploy with zero configuration

## 🎭 Assets Needed

To complete the landing page, add:

### Images
- Hero background or video
- Feature icons/screenshots
- App screenshots for different sections
- Testimonial photos
- Logo (SVG or PNG)

### Recommended Sizes
- Hero image: 1920x1080px
- Feature screenshots: 800x600px
- Testimonial photos: 400x400px
- Logo: SVG (scalable) or PNG @ 2x

### Video
- Demo video (MP4, WebM)
- Recommended: 1920x1080, < 50MB

## 🔗 Links to Update

Before going live, update these placeholder links:

- [ ] Navigation links
- [ ] Download button (App Store link)
- [ ] Social media URLs (footer)
- [ ] Privacy Policy page
- [ ] Terms of Service page
- [ ] Contact/Support pages

## 📊 Analytics Events Tracked

The landing page tracks these events:
- Download button clicks
- Demo video views
- Page load performance
- Form submissions (if added)

## 🎨 Design System

### Typography
- **Headings**: Inter (900 weight)
- **Body**: Inter (400 weight)
- **Links**: Inter (600 weight)

### Spacing Scale
- 4px, 8px, 12px, 16px, 20px, 24px, 32px, 40px, 60px, 80px, 100px

### Border Radius
- Small: 8px
- Medium: 12px
- Large: 24px
- Round: 50%/50px

## 🐛 Known Issues

None currently. Please report issues via GitHub.

## 📝 License

Copyright © 2025 Parkour Pathways. All rights reserved.

## 👨‍💻 Development

### Future Enhancements
- [ ] Add video background to hero
- [ ] Implement modal for demo video
- [ ] Add newsletter signup form
- [ ] Create blog section
- [ ] Add FAQ accordion
- [ ] Implement dark/light mode toggle
- [ ] Add more testimonials with carousel
- [ ] Create comparison table
- [ ] Add live chat widget
- [ ] Implement A/B testing

## 🤝 Contributing

To contribute improvements:
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## 📞 Support

For questions or support:
- Email: support@parkourpathways.com
- Twitter: @ParkourPathways
- Discord: Join our community

---

**Version**: 1.0.0
**Last Updated**: January 2025
**Status**: Production Ready
