# Quick Start - Landing Page

## 🚀 Get Running in 30 Seconds

### Step 1: Start Local Server
```bash
cd landing-page
python3 -m http.server 8000
```

### Step 2: Open in Browser
Visit: **http://localhost:8000**

That's it! 🎉

---

## 🎨 Preview

You'll see:
- **Hero section** with animated globe background
- **Feature cards** showcasing 6 key capabilities
- **Quantified benefits** (30%, 25%, 80% improvements)
- **Customer testimonials** with 5-star ratings
- **Pricing tiers** (Starter, Professional, Enterprise)
- **Contact form** for lead capture

---

## 📱 Test Responsive Design

- **Desktop**: Full layout with side-by-side grids
- **Tablet**: Use browser DevTools (F12 → Device Toolbar)
- **Mobile**: Resize browser or use real device

---

## ✏️ Quick Customizations

### Change Colors
Edit `css/styles.css` line 14-20:
```css
--primary-color: #0071e3;  /* Your brand blue */
--accent-color: #00d4ff;   /* Your accent */
```

### Update Hero Text
Edit `index.html` line 41:
```html
<h1 class="hero-title">
    Your Custom <span class="gradient-text">Headline</span>
</h1>
```

### Replace Logo
Edit `index.html` line 20:
```html
<span class="logo-icon">🌐</span>
<!-- Replace with: -->
<img src="images/logo.png" alt="Logo" height="32">
```

---

## 🧪 Test Features

### Scroll Animations
Scroll down - watch cards fade in using Intersection Observer

### Stats Counter
Watch numbers animate in hero section (30%, 25%, 80%, 500%)

### Form Validation
Try submitting the contact form:
- Fill all fields correctly → Success message
- Invalid email → Error message

### Mobile Menu
Resize browser < 768px → Hamburger menu appears

### Hover Effects
Hover over feature cards → Lift animation + border glow

---

## 📊 Validation Test

Run automated validation:
```bash
./test-validation.sh
```

Expected output:
- ✅ All files present
- ✅ 8 sections found
- ✅ Meta tags present
- ✅ Responsive (3 breakpoints)

---

## 🚀 Deploy

### Netlify (Easiest)
1. Drag `landing-page/` folder to [Netlify Drop](https://app.netlify.com/drop)
2. Get instant URL
3. Done! ✅

### GitHub Pages
```bash
# In repository root
git subtree push --prefix landing-page origin gh-pages
# Visit: https://username.github.io/repo-name
```

### Vercel
```bash
cd landing-page
vercel
# Follow prompts
```

---

## 💡 Tips

1. **Before Launch**: Replace all placeholder content
2. **Performance**: Run [PageSpeed Insights](https://pagespeed.web.dev/)
3. **Accessibility**: Test with [WAVE](https://wave.webaim.org/)
4. **Mobile**: Test on real iOS/Android devices
5. **Analytics**: Add Google Analytics tag to `<head>`

---

## 🆘 Troubleshooting

**Issue**: Styles not loading
- **Fix**: Ensure `css/styles.css` path is correct
- Check browser console (F12) for errors

**Issue**: JavaScript not working
- **Fix**: Check browser console for errors
- Ensure `js/main.js` is loading

**Issue**: Form not submitting
- **Expected**: Form is client-side only
- **Action**: Connect to your backend API in `js/main.js`

**Issue**: Animations choppy
- **Fix**: Test in production (local dev can be slow)
- Reduce particle count in `js/main.js` line 300

---

## 📞 Need Help?

- Check: `README.md` (full documentation)
- Review: `index.html` comments
- Inspect: Browser DevTools (F12)

---

**Built with ❤️ for Supply Chain Control Tower**
