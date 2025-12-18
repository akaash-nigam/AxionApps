# Deployment Guide - Business Operating System

**Version:** 1.0.0
**Last Updated:** November 17, 2025
**Platform:** visionOS 2.0+ & Web

---

## Table of Contents

1. [Overview](#overview)
2. [Prerequisites](#prerequisites)
3. [visionOS App Deployment](#visionos-app-deployment)
4. [Landing Page Deployment](#landing-page-deployment)
5. [Backend Integration](#backend-integration)
6. [Production Checklist](#production-checklist)
7. [Monitoring and Analytics](#monitoring-and-analytics)
8. [Troubleshooting](#troubleshooting)

---

## Overview

This guide covers deploying both components of the Business Operating System:
- **visionOS App:** Native spatial computing application for Apple Vision Pro
- **Landing Page:** Marketing website to drive adoption

---

## Prerequisites

### For visionOS App

#### Development Environment
- **macOS:** 15.0 (Sequoia) or later
- **Xcode:** 16.0 or later
- **Swift:** 6.0 (included with Xcode)
- **visionOS SDK:** 2.0 or later

#### Apple Developer Account
- **Program:** Apple Developer Program ($99/year)
- **Team:** Organization account (for enterprise distribution)
- **Capabilities:** visionOS app development enabled

#### Hardware
- **Development:** Mac with Apple Silicon (M1+) or Intel (2018+)
- **Testing:** Apple Vision Pro device (recommended)
- **Alternative:** visionOS Simulator (limited testing)

### For Landing Page

#### Web Server
- **Server:** Any web server (Apache, Nginx, Cloudflare Pages, Vercel, Netlify)
- **Domain:** Custom domain with SSL certificate
- **Storage:** Minimal (< 100 MB)
- **Bandwidth:** Standard (low traffic expected initially)

#### Optional Services
- **CDN:** CloudFlare, AWS CloudFront (for global distribution)
- **Analytics:** Google Analytics, Plausible, or similar
- **Form Backend:** FormSpree, Basin, or custom API

---

## visionOS App Deployment

### Step 1: Project Setup in Xcode

#### 1.1 Open Project

```bash
cd /path/to/visionOS_business-operating-system
open BusinessOperatingSystem.xcodeproj
```

If `.xcodeproj` doesn't exist, create it:

```bash
# In Xcode:
File → New → Project
Choose: visionOS → App
Product Name: BusinessOperatingSystem
Organization Identifier: com.yourcompany
Interface: SwiftUI
Language: Swift
```

#### 1.2 Import Source Files

1. **Add Files to Project:**
   ```
   Right-click project → Add Files to "BusinessOperatingSystem"
   Select: BusinessOperatingSystem folder
   Options:
     ✅ Copy items if needed
     ✅ Create groups
     ✅ Add to targets: BusinessOperatingSystem
   ```

2. **Verify File Structure:**
   ```
   BusinessOperatingSystem/
   ├── App/
   ├── Models/
   ├── Services/
   ├── Views/
   ├── ViewModels/
   ├── Utilities/
   ├── Tests/
   └── Resources/
   ```

#### 1.3 Configure Project Settings

**General Tab:**
- **Bundle Identifier:** `com.yourcompany.businessoperatingsystem`
- **Version:** 1.0.0
- **Build:** 1
- **Deployment Target:** visionOS 2.0
- **Supported Destinations:** Apple Vision Pro

**Signing & Capabilities:**
- **Team:** Select your Apple Developer team
- **Signing Certificate:** Development / Distribution
- **Provisioning Profile:** Xcode Managed or Manual

**Capabilities to Add:**
1. Click "+ Capability"
2. Add **Hand Tracking**
3. Add **World Sensing**

**Info.plist Permissions:**
```xml
<key>NSHandsTrackingUsageDescription</key>
<string>Business Operating System uses hand tracking for intuitive spatial interactions</string>

<key>NSWorldSensingUsageDescription</key>
<string>World sensing enables spatial anchoring of business data</string>
```

#### 1.4 Build Settings

**Swift Compiler:**
- **Swift Language Version:** 6.0
- **Concurrency Checking:** Complete
- **Optimization Level:**
  - Debug: None [-Onone]
  - Release: Optimize for Speed [-O]

**Linking:**
- **Dead Code Stripping:** Yes (Release)
- **Strip Debug Symbols:** Yes (Release)

### Step 2: Testing in Simulator

#### 2.1 Select Simulator

```
Xcode → Product → Destination → Apple Vision Pro (Simulator)
```

#### 2.2 Run Tests

```bash
# Via Xcode
⌘ + U (Command + U)

# Via Command Line
xcodebuild test \
  -scheme BusinessOperatingSystem \
  -destination 'platform=visionOS Simulator,name=Apple Vision Pro'
```

**Expected Results:**
- **Tests Run:** 59+
- **Tests Passed:** 59+
- **Tests Failed:** 0
- **Code Coverage:** 85%+

#### 2.3 Build and Run

```bash
# Build
⌘ + B (Command + B)

# Run
⌘ + R (Command + R)
```

**First Launch Checklist:**
- [ ] App launches without crashes
- [ ] Dashboard loads with mock data
- [ ] KPI cards display correctly
- [ ] Department navigation works
- [ ] Volume views render
- [ ] Immersive space can be opened
- [ ] No console errors

### Step 3: Testing on Device

#### 3.1 Connect Apple Vision Pro

1. **Pair Device:**
   ```
   Vision Pro → Settings → Privacy & Security → Developer Mode → ON
   Restart Vision Pro
   Connect to Mac via USB-C or Wi-Fi
   ```

2. **Trust Computer:**
   ```
   Vision Pro will show "Trust This Computer?" prompt
   Enter passcode
   Tap "Trust"
   ```

3. **Select Device in Xcode:**
   ```
   Product → Destination → Apple Vision Pro
   ```

#### 3.2 Deploy to Device

```bash
# In Xcode
⌘ + R (Command + R)

# App will install and launch on Vision Pro
```

#### 3.3 Device Testing Checklist

**Functionality:**
- [ ] Hand tracking gestures work (pinch, tap)
- [ ] Eye tracking for focus
- [ ] Spatial windows position correctly
- [ ] Volumes render in 3D space
- [ ] Immersive space is comfortable
- [ ] Navigation is intuitive

**Performance:**
- [ ] App launch < 2 seconds
- [ ] Frame rate 90 FPS sustained
- [ ] Memory usage < 500 MB baseline
- [ ] No thermal issues after 30 min use
- [ ] Smooth animations

**Comfort:**
- [ ] Text readable at default size
- [ ] No motion sickness triggers
- [ ] Comfortable for 30+ minute sessions
- [ ] Proper depth cues
- [ ] No eye strain

### Step 4: Prepare for Distribution

#### 4.1 Update Version and Build

```swift
// Update version numbers
General → Version: 1.0.0
General → Build: 1
```

#### 4.2 Create Archive

```bash
# In Xcode
Product → Archive

# Wait for archive to complete
# Archive appears in Organizer
```

#### 4.3 Validate Archive

```bash
# In Organizer
Right-click Archive → Validate App

# Checks:
✅ App Store Connect connection
✅ Signing configuration
✅ Required capabilities
✅ Info.plist completeness
✅ Binary size and dependencies
```

### Step 5: Distribution Options

#### Option A: App Store Distribution

**Best For:** Public release, consumer apps

**Steps:**

1. **Create App in App Store Connect:**
   ```
   https://appstoreconnect.apple.com
   My Apps → + → New App
   Platform: visionOS
   Name: Business Operating System
   SKU: BOS-VISION-PRO-001
   Bundle ID: com.yourcompany.businessoperatingsystem
   ```

2. **Upload Build:**
   ```
   Xcode Organizer → Distribute App → App Store Connect
   Select: Upload
   Signing: Automatic
   ```

3. **Submit for Review:**
   ```
   App Store Connect → App Information
   Complete all required fields:
   - App Description
   - Screenshots (visionOS)
   - Privacy Policy URL
   - Support URL
   - Keywords
   - Category: Business / Productivity
   ```

4. **Review Process:**
   - Apple review: 1-3 days typically
   - Respond to any feedback
   - Once approved, release

**Pricing:**
- **Free:** Demo/trial version
- **Paid:** $99 - $499 (one-time purchase)
- **Subscription:** $25 - $200/month (enterprise)

#### Option B: Enterprise Distribution (Recommended)

**Best For:** Fortune 500 companies, internal deployment

**Requirements:**
- **Apple Developer Enterprise Program:** $299/year
- **D-U-N-S Number:** Required for enrollment
- **Legal Entity:** Corporation or organization

**Steps:**

1. **Create Enterprise Distribution Profile:**
   ```
   developer.apple.com → Certificates, IDs & Profiles
   Profiles → + → Distribution → In-House
   App ID: Business Operating System
   Certificate: Enterprise Distribution Certificate
   ```

2. **Archive with Enterprise Profile:**
   ```
   Xcode → Build Settings → Signing
   Code Signing Identity: Enterprise Distribution
   Provisioning Profile: Enterprise In-House
   Product → Archive
   ```

3. **Export for Enterprise:**
   ```
   Organizer → Distribute App → Enterprise
   Distribution Method: Enterprise
   Rebuild from Bitcode: Yes
   Include manifest for over-the-air installation: Yes
   ```

4. **Host .ipa File:**
   ```bash
   # Upload to secure server (HTTPS required)
   # Create manifest.plist with download URL
   # Share installation link with enterprise users
   ```

5. **Installation Instructions for Users:**
   ```
   1. Open Safari on Vision Pro
   2. Navigate to: https://yourcompany.com/bos-install
   3. Tap "Install Business Operating System"
   4. Confirm installation
   5. Settings → General → VPN & Device Management
   6. Trust enterprise certificate
   ```

#### Option C: TestFlight (Beta Testing)

**Best For:** Beta testers, pilot programs

**Steps:**

1. **Upload to TestFlight:**
   ```
   Organizer → Distribute App → TestFlight
   ```

2. **Add Testers:**
   ```
   App Store Connect → TestFlight → Testers
   Add by email (up to 10,000 testers)
   ```

3. **Beta Information:**
   ```
   What to Test: "Please test hand tracking, performance, and UI"
   Privacy Policy: Required
   Beta App Description: Brief overview
   ```

4. **Distribute:**
   ```
   Testers receive email invitation
   Install via TestFlight app
   Feedback collected automatically
   ```

### Step 6: Backend Integration

Before production release, replace mock services with real backends.

#### 6.1 Update Service Implementations

```swift
// Replace MockBusinessRepository with RealBusinessRepository

final class RealBusinessRepository: BusinessDataRepository {
    private let apiBaseURL = "https://api.yourcompany.com/v1"
    private let networkService: NetworkService

    func fetchOrganization() async throws -> Organization {
        let url = URL(string: "\(apiBaseURL)/organization")!
        let data = try await networkService.request(url: url)
        return try JSONDecoder().decode(Organization.self, from: data)
    }

    // Implement other methods...
}
```

#### 6.2 Configure API Endpoints

```swift
// Configuration.swift
enum APIEnvironment {
    case development
    case staging
    case production

    var baseURL: String {
        switch self {
        case .development:
            return "https://dev-api.yourcompany.com"
        case .staging:
            return "https://staging-api.yourcompany.com"
        case .production:
            return "https://api.yourcompany.com"
        }
    }
}
```

#### 6.3 Update ServiceContainer

```swift
// ServiceContainer.swift
init() {
    let environment: APIEnvironment = .production // Change based on build configuration

    // Use real services instead of mocks
    self.repository = RealBusinessRepository(apiBaseURL: environment.baseURL)
    self.auth = RealAuthenticationService()
    self.sync = RealSyncService()
    // ...
}
```

---

## Landing Page Deployment

### Step 1: Prepare Files

#### 1.1 Verify Files

```bash
cd landing-page/

# Check all files are present
ls -la
# Should see:
# - index.html
# - css/styles.css
# - js/main.js
# - README.md
```

#### 1.2 Update Configuration

**Update Form Endpoint (js/main.js):**

```javascript
async function simulateFormSubmission(data) {
    // Replace with your actual endpoint
    const response = await fetch('https://api.yourcompany.com/demo-requests', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify(data)
    });

    if (!response.ok) {
        throw new Error('Submission failed');
    }

    return await response.json();
}
```

**Update Analytics (js/main.js):**

```javascript
function trackEvent(eventName, data = {}) {
    // Google Analytics 4
    if (typeof gtag !== 'undefined') {
        gtag('event', eventName, data);
    }

    // Or Plausible
    if (typeof plausible !== 'undefined') {
        plausible(eventName, { props: data });
    }
}
```

### Step 2: Optimization

#### 2.1 Minify Assets

```bash
# Install minification tools
npm install -g html-minifier clean-css-cli terser

# Minify HTML
html-minifier \
  --collapse-whitespace \
  --remove-comments \
  --minify-css true \
  --minify-js true \
  index.html \
  -o index.min.html

# Minify CSS
cleancss css/styles.css -o css/styles.min.css

# Minify JavaScript
terser js/main.js -c -m -o js/main.min.js
```

#### 2.2 Update References

If using minified versions, update index.html:

```html
<link rel="stylesheet" href="css/styles.min.css">
<script src="js/main.min.js"></script>
```

### Step 3: Choose Hosting Provider

#### Option A: Vercel (Recommended for Speed)

**Setup:**

```bash
# Install Vercel CLI
npm install -g vercel

# Deploy
cd landing-page/
vercel

# Follow prompts:
# Set up and deploy? Yes
# Which scope? Your account
# Link to existing project? No
# What's your project's name? business-operating-system
# In which directory is your code located? ./
```

**Custom Domain:**

```bash
vercel domains add bos-enterprise.com
# Follow DNS configuration instructions
```

**Cost:** Free for personal, $20/month for team

#### Option B: Netlify

**Setup:**

```bash
# Install Netlify CLI
npm install -g netlify-cli

# Deploy
cd landing-page/
netlify deploy

# For production:
netlify deploy --prod
```

**Custom Domain:**

```
Netlify Dashboard → Domain Settings → Add custom domain
```

**Cost:** Free for basic, $19/month for pro

#### Option C: Cloudflare Pages

**Setup:**

1. **Push to Git:**
   ```bash
   git add landing-page/
   git commit -m "Prepare landing page for deployment"
   git push origin main
   ```

2. **Connect in Cloudflare:**
   ```
   Cloudflare Dashboard → Pages → Create a project
   Connect Git repository
   Build settings: None (static site)
   Build output directory: landing-page/
   ```

**Cost:** Free

#### Option D: AWS S3 + CloudFront

**Setup:**

```bash
# Install AWS CLI
brew install awscli
aws configure

# Create S3 bucket
aws s3 mb s3://bos-enterprise.com

# Upload files
aws s3 sync landing-page/ s3://bos-enterprise.com/ \
  --exclude "README.md" \
  --acl public-read

# Enable static website hosting
aws s3 website s3://bos-enterprise.com/ \
  --index-document index.html \
  --error-document index.html
```

**CloudFront Distribution:**

```bash
# Create distribution (via AWS Console or CLI)
# Origin: S3 bucket
# SSL Certificate: ACM certificate for custom domain
# Caching: Customize TTL for CSS/JS (1 year), HTML (1 hour)
```

**Cost:** ~$0.50 - $5/month (low traffic)

### Step 4: DNS Configuration

#### 4.1 Add DNS Records

For custom domain `bos-enterprise.com`:

**A Records (IPv4):**
```
A  @  points to  76.76.21.21  (example IP from hosting)
A  www  points to  76.76.21.21
```

**Or CNAME (for CDN):**
```
CNAME  www  points to  cname.vercel-dns.com
CNAME  @  points to  alias.netlify.app
```

#### 4.2 SSL Certificate

Most providers (Vercel, Netlify, Cloudflare) provide free SSL via Let's Encrypt:

```
✅ Automatic SSL provisioning
✅ Auto-renewal every 90 days
✅ HTTPS enforcement
```

For AWS, use ACM (AWS Certificate Manager):

```bash
# Request certificate
aws acm request-certificate \
  --domain-name bos-enterprise.com \
  --validation-method DNS \
  --subject-alternative-names www.bos-enterprise.com
```

### Step 5: Performance Optimization

#### 5.1 Enable Compression

**Vercel/Netlify:**
Automatic gzip/brotli compression

**Nginx:**
```nginx
gzip on;
gzip_types text/css application/javascript text/html;
gzip_min_length 1000;
```

**Apache:**
```apache
<IfModule mod_deflate.c>
  AddOutputFilterByType DEFLATE text/html text/css application/javascript
</IfModule>
```

#### 5.2 Set Cache Headers

```html
<!-- In HTML or via server config -->
Cache-Control: public, max-age=31536000, immutable  # CSS, JS
Cache-Control: public, max-age=3600  # HTML
```

#### 5.3 Add CDN

Cloudflare (Free):
```
1. Add site to Cloudflare
2. Update nameservers
3. Enable Auto Minify (HTML, CSS, JS)
4. Enable Brotli compression
5. Set caching rules
```

### Step 6: Analytics Integration

#### 6.1 Google Analytics 4

```html
<!-- Add to <head> in index.html -->
<script async src="https://www.googletagmanager.com/gtag/js?id=G-XXXXXXXXXX"></script>
<script>
  window.dataLayer = window.dataLayer || [];
  function gtag(){dataLayer.push(arguments);}
  gtag('js', new Date());
  gtag('config', 'G-XXXXXXXXXX');
</script>
```

#### 6.2 Plausible (Privacy-Friendly Alternative)

```html
<script defer data-domain="bos-enterprise.com" src="https://plausible.io/js/script.js"></script>
```

### Step 7: Form Backend

#### Option A: FormSpree (Easiest)

```html
<form action="https://formspree.io/f/your-form-id" method="POST">
  <input type="email" name="email" required>
  <input type="text" name="name" required>
  <button type="submit">Submit</button>
</form>
```

#### Option B: Custom API

```javascript
// js/main.js - already implemented
async function simulateFormSubmission(data) {
    const response = await fetch('https://api.yourcompany.com/demo-requests', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(data)
    });
    return await response.json();
}
```

#### Option C: AWS Lambda + API Gateway

```javascript
// serverless function
exports.handler = async (event) => {
    const data = JSON.parse(event.body);

    // Send to CRM (Salesforce, HubSpot, etc.)
    await sendToCRM(data);

    // Send confirmation email
    await sendEmail(data.email);

    return {
        statusCode: 200,
        body: JSON.stringify({ success: true })
    };
};
```

---

## Production Checklist

### Pre-Launch

#### visionOS App
- [ ] All tests passing (59+ tests)
- [ ] Code coverage > 85%
- [ ] No compiler warnings
- [ ] Performance targets met (90 FPS, < 2s launch)
- [ ] Tested on actual Vision Pro hardware
- [ ] Privacy permissions implemented
- [ ] Backend services integrated
- [ ] Error tracking configured (Sentry, Crashlytics)
- [ ] Analytics implemented
- [ ] App Store screenshots prepared
- [ ] App description written
- [ ] Privacy policy published
- [ ] Support URL configured

#### Landing Page
- [ ] HTML/CSS/JS validated
- [ ] Cross-browser tested (Chrome, Firefox, Safari, Edge)
- [ ] Mobile responsive verified
- [ ] Forms working
- [ ] Analytics configured
- [ ] SSL certificate installed
- [ ] DNS configured correctly
- [ ] Performance tested (Lighthouse > 90)
- [ ] Accessibility checked (WCAG AA)
- [ ] Meta tags for social sharing
- [ ] Sitemap.xml created
- [ ] robots.txt configured

### Post-Launch

#### Week 1
- [ ] Monitor crash reports
- [ ] Check analytics for usage patterns
- [ ] Respond to user feedback
- [ ] Fix critical bugs immediately
- [ ] Monitor server performance
- [ ] Track conversion rates (landing page)

#### Month 1
- [ ] Collect user feedback
- [ ] Plan first update
- [ ] Optimize based on analytics
- [ ] A/B test landing page elements
- [ ] Review performance metrics
- [ ] Update documentation

---

## Monitoring and Analytics

### visionOS App Monitoring

#### Crash Reporting

**Xcode Organizer:**
```
Xcode → Window → Organizer → Crashes
View crash logs from App Store distribution
```

**Third-Party Services:**

**Sentry:**
```swift
import Sentry

SentrySDK.start { options in
    options.dsn = "https://your-dsn@sentry.io/project-id"
    options.tracesSampleRate = 1.0
}
```

**Firebase Crashlytics:**
```swift
import FirebaseCrashlytics

Crashlytics.crashlytics().setCus tomValue("1.0.0", forKey: "app_version")
```

#### Performance Monitoring

**Instruments:**
```
Xcode → Product → Profile
Choose:
- Time Profiler (CPU usage)
- Allocations (memory)
- Leaks (memory leaks)
- Metal System Trace (GPU/rendering)
```

**Metrics to Track:**
- App launch time
- Frame rate (target: 90 FPS)
- Memory usage
- Network request latency
- User retention (1 day, 7 day, 30 day)
- Feature usage

### Landing Page Monitoring

#### Analytics Dashboard

**Key Metrics:**
- Page views
- Unique visitors
- Bounce rate (target: < 40%)
- Time on page (target: > 2 minutes)
- Conversion rate (demo requests)
- Traffic sources
- Geographic distribution
- Device breakdown

#### Conversion Tracking

```javascript
// Track demo request conversion
trackEvent('demo_request_submitted', {
    company: data.company,
    role: data.role,
    timestamp: new Date().toISOString()
});
```

#### Uptime Monitoring

**Services:**
- **UptimeRobot** (free, checks every 5 min)
- **Pingdom** (advanced, $15/month)
- **StatusCake** (free tier available)

---

## Troubleshooting

### Common visionOS Issues

#### Build Fails

**Error:** "Signing for requires a development team"
**Solution:**
```
Xcode → Project → Signing & Capabilities
Select your Team from dropdown
```

**Error:** "Unable to install..."
**Solution:**
```
Vision Pro → Settings → Developer Mode → ON
Restart device
```

#### App Crashes on Launch

**Check:**
1. Console logs in Xcode
2. Crash reports in Organizer
3. Validate Info.plist permissions
4. Check for missing resources

#### Hand Tracking Not Working

**Verify:**
1. Permission granted in Settings
2. Hands visible to cameras
3. Sufficient lighting
4. No conflicting apps using hand tracking

### Common Landing Page Issues

#### Form Not Submitting

**Check:**
1. Browser console for JavaScript errors
2. Network tab for failed requests
3. CORS configuration on API
4. Form endpoint URL correct

#### Slow Load Time

**Optimize:**
1. Enable compression (gzip/brotli)
2. Minify CSS/JS
3. Use CDN
4. Optimize images (convert to WebP)
5. Lazy load below-fold content

#### SSL Not Working

**Verify:**
1. Certificate installed correctly
2. DNS propagated (24-48 hours)
3. HTTP → HTTPS redirect configured
4. Mixed content warnings resolved

---

## Support

### Resources

- **Apple Developer:** https://developer.apple.com/visionos
- **visionOS Documentation:** https://developer.apple.com/documentation/visionos
- **Swift Forums:** https://forums.swift.org
- **Project Documentation:** See `ARCHITECTURE.md`, `TECHNICAL_SPEC.md`

### Contact

- **Technical Issues:** tech-support@yourcompany.com
- **Sales Inquiries:** sales@yourcompany.com
- **General:** info@yourcompany.com

---

**Last Updated:** November 17, 2025
**Version:** 1.0.0
**Next Review:** December 17, 2025
