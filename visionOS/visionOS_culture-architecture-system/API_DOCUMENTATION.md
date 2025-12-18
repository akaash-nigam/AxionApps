# Culture Architecture System API Documentation

**Version**: 1.0.0
**Base URL**: `https://api.culturearchitecture.com/v1`
**Protocol**: HTTPS only
**Authentication**: OAuth 2.0 with PKCE

---

## Quick Start

### 1. Authentication

```http
POST /v1/auth/login
Content-Type: application/json

{
  "email": "user@company.com",
  "password": "password123",
  "codeVerifier": "dBjftJeZ4CVP-mB92K27uhbUJU1p1r_wW1gFWFOEjXk"
}
```

**Response**:
```json
{
  "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refreshToken": "7d7e8c7f-4c7d-4b7c-8e7d-7e8c7f4c7d4b",
  "expiresIn": 3600,
  "tokenType": "Bearer"
}
```

### 2. Make Authenticated Request

```http
GET /v1/organizations
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

---

## Authentication Flow

### OAuth 2.0 + PKCE

#### Step 1: Generate Code Verifier & Challenge

```javascript
// Generate random code verifier
const codeVerifier = generateRandomString(128);

// Create SHA256 hash and base64url encode
const codeChallenge = base64url(sha256(codeVerifier));
```

#### Step 2: Login with Code Verifier

```bash
curl -X POST https://api.culturearchitecture.com/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@company.com",
    "password": "secure_password",
    "codeVerifier": "your_code_verifier"
  }'
```

#### Step 3: Store Tokens Securely

```swift
// iOS Keychain
let keychain = KeychainSwift()
keychain.set(accessToken, forKey: "access_token")
keychain.set(refreshToken, forKey: "refresh_token")
```

#### Step 4: Refresh Token When Expired

```bash
curl -X POST https://api.culturearchitecture.com/v1/auth/refresh \
  -H "Content-Type: application/json" \
  -d '{
    "refreshToken": "7d7e8c7f-4c7d-4b7c-8e7d-7e8c7f4c7d4b"
  }'
```

---

## API Endpoints

### Organizations

#### List Organizations

```http
GET /v1/organizations?page=1&limit=20
Authorization: Bearer {token}
```

**Response**:
```json
{
  "data": [
    {
      "id": "550e8400-e29b-41d4-a716-446655440000",
      "name": "TechCorp",
      "industry": "Technology",
      "employeeCount": 1250,
      "foundedYear": 2015,
      "healthScore": 82.5,
      "engagementScore": 78.3,
      "alignmentScore": 85.1,
      "retentionRate": 89.2,
      "createdAt": "2024-01-15T10:30:00Z",
      "updatedAt": "2025-01-20T14:22:00Z"
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 50,
    "pages": 3
  }
}
```

#### Get Organization Health

```http
GET /v1/organizations/{organizationId}/health
Authorization: Bearer {token}
```

**Response**:
```json
{
  "healthScore": 82.5,
  "engagementScore": 78.3,
  "alignmentScore": 85.1,
  "trends": {
    "health": "improving",
    "engagement": "stable"
  }
}
```

### Cultural Values

#### List Values

```http
GET /v1/values?organizationId=550e8400-e29b-41d4-a716-446655440000
Authorization: Bearer {token}
```

**Response**:
```json
{
  "data": [
    {
      "id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
      "organizationId": "550e8400-e29b-41d4-a716-446655440000",
      "name": "Innovation",
      "description": "Drive innovation across the organization",
      "dimension": "Organizational",
      "priority": 1,
      "adoptionRate": 87.5,
      "behaviorCount": 425,
      "createdAt": "2024-03-01T09:00:00Z"
    }
  ]
}
```

#### Create Value

```http
POST /v1/values
Authorization: Bearer {token}
Content-Type: application/json

{
  "organizationId": "550e8400-e29b-41d4-a716-446655440000",
  "name": "Collaboration",
  "description": "Foster collaboration across teams",
  "dimension": "Team",
  "priority": 2
}
```

### Analytics

#### Dashboard Data

```http
GET /v1/analytics/dashboard?organizationId=550e8400-e29b-41d4-a716-446655440000
Authorization: Bearer {token}
```

**Response**:
```json
{
  "healthScore": 82.5,
  "engagementScore": 78.3,
  "alignmentScore": 85.1,
  "recognitionCount": 1247,
  "recentActivities": [
    {
      "type": "recognition",
      "timestamp": "2025-01-20T14:30:00Z",
      "description": "John gave recognition to Sarah"
    }
  ]
}
```

#### Engagement Metrics

```http
GET /v1/analytics/engagement?organizationId=550e8400-e29b-41d4-a716-446655440000
Authorization: Bearer {token}
```

**Response**:
```json
{
  "overall": 78.3,
  "byDepartment": [
    {
      "departmentId": "dept-001",
      "score": 82.1
    },
    {
      "departmentId": "dept-002",
      "score": 75.5
    }
  ],
  "trend": "up"
}
```

#### Trend Analysis

```http
GET /v1/analytics/trends?organizationId=550e8400-e29b-41d4-a716-446655440000&metric=engagement&period=week&duration=12
Authorization: Bearer {token}
```

**Response**:
```json
{
  "metric": "engagement",
  "period": "week",
  "data": [
    {
      "timestamp": "2025-01-06T00:00:00Z",
      "value": 76.5
    },
    {
      "timestamp": "2025-01-13T00:00:00Z",
      "value": 77.8
    },
    {
      "timestamp": "2025-01-20T00:00:00Z",
      "value": 78.3
    }
  ]
}
```

### Recognition

#### Get Recognition Feed

```http
GET /v1/recognitions?organizationId=550e8400-e29b-41d4-a716-446655440000&filter=all&page=1&limit=20
Authorization: Bearer {token}
```

**Response**:
```json
{
  "data": [
    {
      "id": "rec-001",
      "organizationId": "550e8400-e29b-41d4-a716-446655440000",
      "giverId": "anon-emp-001",
      "receiverId": "anon-emp-002",
      "valueId": "val-001",
      "type": "Peer Recognition",
      "message": "Great work on the project!",
      "visibility": "Public",
      "reactionCount": 15,
      "createdAt": "2025-01-20T14:30:00Z"
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 1247,
    "pages": 63
  }
}
```

#### Give Recognition

```http
POST /v1/recognitions
Authorization: Bearer {token}
Content-Type: application/json

{
  "organizationId": "550e8400-e29b-41d4-a716-446655440000",
  "receiverId": "anon-emp-002",
  "valueId": "val-001",
  "type": "Peer Recognition",
  "message": "Thank you for your help with the project!",
  "visibility": "Public"
}
```

#### React to Recognition

```http
POST /v1/recognitions/rec-001/react
Authorization: Bearer {token}
Content-Type: application/json

{
  "emoji": "👍"
}
```

### Behavior Tracking

#### Track Behavior

```http
POST /v1/behaviors
Authorization: Bearer {token}
Content-Type: application/json

{
  "organizationId": "550e8400-e29b-41d4-a716-446655440000",
  "employeeId": "anon-emp-001",
  "valueId": "val-001",
  "behaviorType": "Collaboration",
  "impact": "High",
  "context": "Team meeting"
}
```

#### Get Behavior Analytics

```http
GET /v1/behaviors/analytics?organizationId=550e8400-e29b-41d4-a716-446655440000
Authorization: Bearer {token}
```

**Response**:
```json
{
  "totalEvents": 60686,
  "byType": [
    {
      "type": "Collaboration",
      "count": 12500
    },
    {
      "type": "Innovation",
      "count": 9800
    }
  ],
  "byValue": [
    {
      "valueId": "val-001",
      "count": 15000
    }
  ]
}
```

### Employees (Anonymized)

#### List Employees

```http
GET /v1/employees?organizationId=550e8400-e29b-41d4-a716-446655440000
Authorization: Bearer {token}
```

**Response**:
```json
[
  {
    "id": "anon-a1b2c3d4-e5f6-7890",
    "organizationId": "550e8400-e29b-41d4-a716-446655440000",
    "departmentId": "dept-001",
    "teamId": "team-001",
    "role": "Senior Contributor",
    "tenureMonths": 36,
    "engagementScore": 85.2,
    "culturalContributions": 25,
    "recognitionsReceived": 12,
    "recognitionsGiven": 18,
    "lastActiveDate": "2025-01-20T14:00:00Z"
  }
]
```

---

## Error Handling

### Error Response Format

```json
{
  "code": "INVALID_REQUEST",
  "message": "The request body is invalid",
  "details": {
    "field": "email",
    "issue": "Invalid email format"
  }
}
```

### Common Error Codes

| Code | HTTP Status | Description |
|------|-------------|-------------|
| `UNAUTHORIZED` | 401 | Invalid or expired token |
| `FORBIDDEN` | 403 | Insufficient permissions |
| `NOT_FOUND` | 404 | Resource not found |
| `INVALID_REQUEST` | 400 | Invalid request body |
| `RATE_LIMIT_EXCEEDED` | 429 | Too many requests |
| `INTERNAL_ERROR` | 500 | Server error |

### Example Error Handling (Swift)

```swift
enum APIError: Error {
    case unauthorized
    case forbidden
    case notFound
    case invalidRequest(String)
    case rateLimitExceeded
    case serverError
}

func handleError(_ response: HTTPURLResponse, data: Data) -> APIError {
    switch response.statusCode {
    case 401:
        return .unauthorized
    case 403:
        return .forbidden
    case 404:
        return .notFound
    case 429:
        return .rateLimitExceeded
    default:
        return .serverError
    }
}
```

---

## Rate Limiting

### Limits

- **Per User**: 1,000 requests/hour
- **Per Organization**: 10,000 requests/hour
- **Burst**: Up to 100 requests in 1 minute

### Headers

```http
X-RateLimit-Limit: 1000
X-RateLimit-Remaining: 950
X-RateLimit-Reset: 1642694400
```

### Best Practices

1. **Cache responses** where appropriate
2. **Use pagination** for large datasets
3. **Batch requests** when possible
4. **Implement exponential backoff** on 429 errors

---

## Pagination

### Request Parameters

```http
GET /v1/recognitions?page=2&limit=50
```

- `page`: Page number (default: 1)
- `limit`: Items per page (default: 20, max: 100)

### Response Format

```json
{
  "data": [...],
  "pagination": {
    "page": 2,
    "limit": 50,
    "total": 1247,
    "pages": 25
  }
}
```

---

## Filtering & Sorting

### Filtering

```http
GET /v1/recognitions?organizationId=550e8400&filter=received&visibility=Public
```

### Sorting

```http
GET /v1/recognitions?sort=-createdAt,receiverId
```

- Prefix with `-` for descending order
- Multiple sort fields comma-separated

---

## Webhooks

### Subscribe to Events

```http
POST /v1/webhooks
Authorization: Bearer {token}
Content-Type: application/json

{
  "url": "https://your-server.com/webhooks",
  "events": ["recognition.created", "behavior.tracked"],
  "secret": "your_webhook_secret"
}
```

### Webhook Payload

```json
{
  "event": "recognition.created",
  "timestamp": "2025-01-20T14:30:00Z",
  "data": {
    "id": "rec-001",
    "organizationId": "550e8400",
    "giverId": "anon-emp-001",
    "receiverId": "anon-emp-002"
  }
}
```

### Verify Webhook Signature

```swift
import CryptoKit

func verifyWebhook(payload: Data, signature: String, secret: String) -> Bool {
    let key = SymmetricKey(data: Data(secret.utf8))
    let hmac = HMAC<SHA256>.authenticationCode(for: payload, using: key)
    let expectedSignature = Data(hmac).hexString
    return signature == expectedSignature
}
```

---

## SDK Examples

### Swift (visionOS/iOS)

```swift
import Foundation

class CultureAPIClient {
    let baseURL = URL(string: "https://api.culturearchitecture.com/v1")!
    var accessToken: String?

    func login(email: String, password: String, codeVerifier: String) async throws -> AuthResponse {
        let url = baseURL.appendingPathComponent("/auth/login")

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = [
            "email": email,
            "password": password,
            "codeVerifier": codeVerifier
        ]
        request.httpBody = try JSONEncoder().encode(body)

        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try JSONDecoder().decode(AuthResponse.self, from: data)

        self.accessToken = response.accessToken
        return response
    }

    func getOrganizations() async throws -> [Organization] {
        let url = baseURL.appendingPathComponent("/organizations")

        var request = URLRequest(url: url)
        request.setValue("Bearer \(accessToken ?? "")", forHTTPHeaderField: "Authorization")

        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try JSONDecoder().decode(OrganizationsResponse.self, from: data)

        return response.data
    }
}
```

### JavaScript/TypeScript

```typescript
class CultureAPIClient {
  private baseURL = 'https://api.culturearchitecture.com/v1';
  private accessToken?: string;

  async login(email: string, password: string, codeVerifier: string): Promise<AuthResponse> {
    const response = await fetch(`${this.baseURL}/auth/login`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ email, password, codeVerifier }),
    });

    const data = await response.json();
    this.accessToken = data.accessToken;
    return data;
  }

  async getOrganizations(): Promise<Organization[]> {
    const response = await fetch(`${this.baseURL}/organizations`, {
      headers: {
        'Authorization': `Bearer ${this.accessToken}`,
      },
    });

    const data = await response.json();
    return data.data;
  }
}
```

---

## Testing

### Postman Collection

Import the included `postman_collection.json` file into Postman for easy API testing.

### cURL Examples

See `API_EXAMPLES.md` for comprehensive cURL examples.

### Mock Server

For development, use the mock server:

```bash
docker run -p 8080:8080 culturearchitecture/mock-api
```

---

## Support

### Documentation
- **API Reference**: `api-specification.yaml` (OpenAPI 3.0)
- **Postman Collection**: `postman_collection.json`
- **Examples**: `API_EXAMPLES.md`

### Contact
- **API Support**: api@culturearchitecture.com
- **Documentation**: docs@culturearchitecture.com
- **Issues**: https://github.com/culturearch/api/issues

---

**Version**: 1.0.0
**Last Updated**: January 20, 2025
