# GitHub OAuth Setup Guide

This guide explains how to configure GitHub OAuth authentication for the Spatial Code Reviewer app.

## Prerequisites

- GitHub account
- Xcode 16.0+ with visionOS SDK
- Apple Vision Pro device or simulator

## Step 1: Create a GitHub OAuth App

1. Go to [GitHub Developer Settings](https://github.com/settings/developers)
2. Click **"New OAuth App"**
3. Fill in the application details:
   - **Application name**: `Spatial Code Reviewer`
   - **Homepage URL**: `https://yourdomain.com` (or your app's website)
   - **Authorization callback URL**: `spatialcodereviewer://oauth/github`
4. Click **"Register application"**
5. Save your **Client ID** (you'll need this in Step 2)
6. Click **"Generate a new client secret"**
7. Save your **Client Secret** securely (you'll need this in Step 2)

## Step 2: Configure OAuth Credentials

There are two methods to configure your OAuth credentials:

### Method 1: Environment Variables (Recommended for Development)

Create a `.env` file in the project root (this file is gitignored):

```bash
GITHUB_CLIENT_ID=your_client_id_here
GITHUB_CLIENT_SECRET=your_client_secret_here
```

### Method 2: Xcode Configuration (Recommended for Production)

1. Open the project in Xcode
2. Select the app target
3. Go to **Build Settings**
4. Add two User-Defined Settings:
   - `GITHUB_CLIENT_ID` = `your_client_id_here`
   - `GITHUB_CLIENT_SECRET` = `your_client_secret_here`
5. In **Info.plist**, add:
   ```xml
   <key>GithubClientID</key>
   <string>$(GITHUB_CLIENT_ID)</string>
   <key>GithubClientSecret</key>
   <string>$(GITHUB_CLIENT_SECRET)</string>
   ```

### Method 3: Keychain Configuration (Most Secure)

For production apps, store credentials in the system Keychain:

```swift
// Store credentials once during initial setup
KeychainService.shared.storeCredential(
    "your_client_id",
    forKey: "github_client_id"
)
KeychainService.shared.storeCredential(
    "your_client_secret",
    forKey: "github_client_secret"
)
```

## Step 3: Update OAuthConfiguration.swift

Update the credential loading methods in `OAuthConfiguration.swift`:

```swift
private static func loadClientID() -> String {
    // Method 1: Environment variable
    if let clientID = ProcessInfo.processInfo.environment["GITHUB_CLIENT_ID"] {
        return clientID
    }

    // Method 2: Info.plist
    if let clientID = Bundle.main.infoDictionary?["GithubClientID"] as? String {
        return clientID
    }

    // Method 3: Keychain (most secure)
    if let clientID = try? KeychainService.shared.retrieveCredential(forKey: "github_client_id") {
        return clientID
    }

    fatalError("GitHub Client ID not configured. See docs/OAUTH_SETUP.md")
}

private static func loadClientSecret() -> String {
    // Method 1: Environment variable
    if let clientSecret = ProcessInfo.processInfo.environment["GITHUB_CLIENT_SECRET"] {
        return clientSecret
    }

    // Method 2: Info.plist
    if let clientSecret = Bundle.main.infoDictionary?["GithubClientSecret"] as? String {
        return clientSecret
    }

    // Method 3: Keychain (most secure)
    if let clientSecret = try? KeychainService.shared.retrieveCredential(forKey: "github_client_secret") {
        return clientSecret
    }

    fatalError("GitHub Client Secret not configured. See docs/OAUTH_SETUP.md")
}
```

## Step 4: Configure URL Scheme

The URL scheme `spatialcodereviewer://` is already configured in `Info.plist`. Verify it's present:

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>spatialcodereviewer</string>
        </array>
    </dict>
</array>
```

## Step 5: Test OAuth Flow

1. Build and run the app on Vision Pro simulator or device
2. Tap **"Connect GitHub"** on the welcome screen
3. You should see the GitHub authorization page
4. Log in with your GitHub credentials
5. Authorize the app
6. You should be redirected back to the app with a success message

## Security Considerations

### PKCE (Proof Key for Code Exchange)

This app implements PKCE (RFC 7636) for enhanced OAuth security:

- **Code Verifier**: Randomly generated 32-byte string
- **Code Challenge**: SHA256 hash of code verifier, base64url-encoded
- Prevents authorization code interception attacks

### Token Storage

OAuth tokens are stored securely in the iOS Keychain:

- **Accessibility**: `kSecAttrAccessibleWhenUnlockedThisDeviceOnly`
- **Synchronization**: Disabled (tokens don't sync to iCloud)
- **Encryption**: Keychain handles encryption automatically

### Best Practices

1. **Never commit credentials**: Add `.env` to `.gitignore`
2. **Rotate secrets regularly**: Generate new client secrets periodically
3. **Use minimal scopes**: Only request necessary GitHub permissions
4. **Monitor token usage**: Implement token refresh before expiration
5. **Validate tokens**: Check token validity on app launch

## Required GitHub Scopes

The app requests the following OAuth scopes:

- `repo`: Access to repositories (read/write)
- `read:user`: Read user profile information
- `read:org`: Read organization membership

## Troubleshooting

### "Invalid callback URL" Error

**Solution**: Verify the callback URL in your GitHub OAuth App matches exactly:
```
spatialcodereviewer://oauth/github
```

### "Client ID not configured" Fatal Error

**Solution**: Ensure you've set up credentials using one of the methods in Step 2.

### "Authentication was cancelled" Error

**Solution**: This is normal if the user cancels the OAuth flow. The app should handle this gracefully.

### Token Refresh Fails

**Solution**: GitHub tokens don't expire by default. If using refresh tokens with another provider, ensure the refresh token endpoint is correct.

## Testing with Mock Data

For UI development without GitHub credentials:

1. Comment out the OAuth flow in `AuthService.authenticate()`
2. Use the mock token for testing:

```swift
let mockToken = Token(
    accessToken: "gho_mock_token_for_development",
    refreshToken: nil,
    expiresAt: Date().addingTimeInterval(3600),
    tokenType: "Bearer",
    scope: "repo read:user"
)
```

## Production Deployment

Before deploying to the App Store:

1. **Create separate OAuth apps** for development and production
2. **Use different callback URLs** for each environment
3. **Store production credentials securely** (never in source code)
4. **Implement certificate pinning** for API requests
5. **Add rate limiting** for OAuth requests
6. **Monitor OAuth failures** with analytics

## Additional Resources

- [GitHub OAuth Documentation](https://docs.github.com/en/developers/apps/building-oauth-apps)
- [PKCE RFC 7636](https://tools.ietf.org/html/rfc7636)
- [iOS Keychain Services](https://developer.apple.com/documentation/security/keychain_services)
- [ASWebAuthenticationSession](https://developer.apple.com/documentation/authenticationservices/aswebauthenticationsession)

## Support

For issues or questions:

- Check the [Troubleshooting](#troubleshooting) section
- Review [GitHub OAuth logs](https://github.com/settings/applications)
- Open an issue in the repository
