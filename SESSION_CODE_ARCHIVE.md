# Code Archive - AxionApps Session

## Key Scripts Created

### 1. GitHub Pages Configuration Script
```bash
#!/bin/bash
# configure_github_pages.sh
repos="iOS_CalmSpaceAI iOS_ExpenseAI ..."
for repo in $repos; do
  echo '{"source":{"branch":"master","path":"/docs"}}' | \
    gh api -X POST repos/akaash-nigam/$repo/pages \
    -H "Accept: application/vnd.github+json" --input -
done
```

### 2. Landing Page HTML Template
```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{APP_NAME} - {TAGLINE}</title>
    <meta name="description" content="{DESCRIPTION}">

    <!-- Open Graph / Facebook -->
    <meta property="og:type" content="website">
    <meta property="og:url" content="https://{app-name}.com/">
    <meta property="og:title" content="{APP_NAME}">
    <meta property="og:description" content="{DESCRIPTION}">

    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: -apple-system, BlinkMacSystemFont, sans-serif; }

        .hero {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 100px 20px;
            text-align: center;
        }

        .container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 80px 20px;
        }

        .feature-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 40px;
        }

        .testimonial {
            background: white;
            padding: 30px;
            border-radius: 15px;
            box-shadow: 0 4px 6px rgba(0,0,0,0.1);
        }
    </style>
</head>
<body>
    <div class="hero">
        <h1>{APP_NAME}</h1>
        <p>{TAGLINE}</p>
        <a href="#" class="cta-button">Download on App Store</a>
    </div>

    <div class="container features">
        <h2>Features</h2>
        <div class="feature-grid">{FEATURES}</div>
    </div>

    <div class="container testimonials">
        <h2>What Users Say</h2>
        <div class="testimonial-grid">{TESTIMONIALS}</div>
    </div>

    <footer>
        <p>&copy; 2024 {APP_NAME}. All rights reserved.</p>
    </footer>
</body>
</html>
```

### 3. Push Documentation Script
```bash
#!/bin/bash
# push_all_documentation.sh

for app in iOS_* visionOS_* android_*; do
  if [ -d "$app/docs" ]; then
    cd "$app"
    git add docs/*.md
    git commit -m "Add comprehensive documentation"
    git push
    cd ..
  fi
done
```

### 4. Verification Script
```bash
#!/bin/bash
# verify_all_pages.sh

repos=(
  "iOS_CalmSpaceAI"
  "visionOS_ai-agent-coordinator"
  "android_BattlegroundIndia"
)

for repo in "${repos[@]}"; do
  result=$(gh api repos/akaash-nigam/$repo/pages 2>&1)
  if echo "$result" | grep -q '"status":"built"'; then
    echo "✅ Built - https://akaash-nigam.github.io/$repo/"
  fi
done
```

### 5. Cleanup Duplicates Script
```bash
#!/bin/bash
# move_duplicates_to_delete.sh

mkdir -p to_be_deleted

DUPLICATES=(
  "ios_calmspace-ai"
  "iOS_BorderBuddy_Concept"
  "iOS_BorderBuddyApp"
)

for folder in "${DUPLICATES[@]}"; do
  if [ -d "$folder" ]; then
    mv "$folder" to_be_deleted/
  fi
done
```

### 6. Documentation Template
```markdown
# {APP_NAME}

## Overview
{APP_NAME} is a revolutionary {CATEGORY} application that {DESCRIPTION}.

## Features
- **Feature 1**: Description
- **Feature 2**: Description
- **Feature 3**: Description

## Installation

### iOS
1. Open App Store
2. Search for "{APP_NAME}"
3. Tap "Get" to install

### Android
1. Open Google Play Store
2. Search for "{APP_NAME}"
3. Tap "Install"

## Getting Started
1. Launch the app
2. Create an account or sign in
3. Follow the onboarding tutorial

## Support
- Email: support@{appname}.com
- Website: https://akaash-nigam.github.io/{APP_NAME}/
- FAQ: See FAQ.md

## License
MIT License - see LICENSE file for details
```

### 7. API Documentation Template
```markdown
# API Documentation

## Base URL
```
https://api.{appname}.com/v1
```

## Authentication
All API requests require an API key in the header:
```
Authorization: Bearer YOUR_API_KEY
```

## Endpoints

### GET /users
Returns list of users.

**Response:**
```json
{
  "users": [
    {
      "id": "123",
      "name": "John Doe",
      "email": "john@example.com"
    }
  ]
}
```

### POST /data
Creates new data entry.

**Request:**
```json
{
  "type": "example",
  "value": "data"
}
```

**Response:**
```json
{
  "id": "456",
  "status": "created"
}
```

## Error Codes
- 400: Bad Request
- 401: Unauthorized
- 404: Not Found
- 500: Internal Server Error
```

---

## All Scripts Location
- iOS: `/Users/aakashnigam/Axion/AxionApps/ios/`
- VisionOS: `/Users/aakashnigam/Axion/AxionApps/visionOS/`
- Android: `/Users/aakashnigam/Axion/AxionApps/android/`
- Root: `/Users/aakashnigam/Axion/AxionApps/`

---

*Code archive complete - All scripts and templates preserved*