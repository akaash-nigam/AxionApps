#!/bin/bash

# Deploy script for Retail Space Optimizer
# Uploads build to TestFlight

set -e

echo "🚀 Deploying Retail Space Optimizer to TestFlight..."

# Check required environment variables
if [ -z "$APP_STORE_CONNECT_API_KEY" ]; then
    echo "❌ Error: APP_STORE_CONNECT_API_KEY not set"
    exit 1
fi

if [ -z "$APP_STORE_CONNECT_API_KEY_ID" ]; then
    echo "❌ Error: APP_STORE_CONNECT_API_KEY_ID not set"
    exit 1
fi

if [ -z "$APP_STORE_CONNECT_ISSUER_ID" ]; then
    echo "❌ Error: APP_STORE_CONNECT_ISSUER_ID not set"
    exit 1
fi

cd RetailSpaceOptimizer

# Increment build number
echo "📝 Incrementing build number..."
BUILD_NUMBER=$(($(git rev-list --count HEAD)))
agvtool new-version -all $BUILD_NUMBER
echo "✅ Build number set to $BUILD_NUMBER"

# Archive
echo "📦 Creating archive..."
xcodebuild archive \
    -scheme RetailSpaceOptimizer \
    -destination generic/platform=visionOS \
    -archivePath ../build/RetailSpaceOptimizer.xcarchive \
    -configuration Release \
    -allowProvisioningUpdates

# Export IPA
echo "📤 Exporting IPA..."
xcodebuild -exportArchive \
    -archivePath ../build/RetailSpaceOptimizer.xcarchive \
    -exportOptionsPlist ../ExportOptions.plist \
    -exportPath ../build \
    -allowProvisioningUpdates

# Upload to TestFlight
echo "☁️  Uploading to TestFlight..."
xcrun altool --upload-app \
    --type visionos \
    --file ../build/RetailSpaceOptimizer.ipa \
    --apiKey $APP_STORE_CONNECT_API_KEY_ID \
    --apiIssuer $APP_STORE_CONNECT_ISSUER_ID

echo ""
echo "✅ Upload complete!"
echo ""
echo "📱 Your build is now processing on App Store Connect"
echo "   It will be available for testing in 10-15 minutes"
echo ""
echo "Next steps:"
echo "1. Go to App Store Connect > TestFlight"
echo "2. Add testers to your build"
echo "3. Monitor crash reports and feedback"
