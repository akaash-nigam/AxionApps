# API Integration Guide

Complete guide for integrating with the Business Operating System API.

## Table of Contents

1. [Quick Start](#quick-start)
2. [Authentication](#authentication)
3. [API Endpoints](#api-endpoints)
4. [WebSocket Real-time Updates](#websocket-real-time-updates)
5. [Error Handling](#error-handling)
6. [Rate Limiting](#rate-limiting)
7. [Code Examples](#code-examples)
8. [Best Practices](#best-practices)

---

## Quick Start

### Base URL

```
Production: https://api.businessos.app/v1
Staging:    https://api-staging.businessos.app/v1
```

### Prerequisites

- API Key (obtain from Settings > API Keys in the dashboard)
- OAuth 2.0 Client ID and Secret (for user authentication)

### Making Your First Request

```bash
curl -X GET "https://api.businessos.app/v1/organization" \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
  -H "Content-Type: application/json"
```

---

## Authentication

### OAuth 2.0 + JWT Flow

The Business Operating System API uses OAuth 2.0 with JWT tokens for authentication.

#### Step 1: Obtain Access Token

```http
POST /auth/login
Content-Type: application/json

{
  "email": "user@company.com",
  "password": "secure_password"
}
```

**Response:**

```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "token_type": "Bearer",
  "expires_in": 3600,
  "user": {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "email": "user@company.com",
    "name": "John Doe",
    "role": "executive"
  }
}
```

#### Step 2: Use Access Token

Include the access token in the Authorization header for all subsequent requests:

```http
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

#### Step 3: Refresh Token

When the access token expires (after 1 hour), use the refresh token:

```http
POST /auth/refresh
Content-Type: application/json

{
  "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

**Response:**

```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "token_type": "Bearer",
  "expires_in": 3600
}
```

---

## API Endpoints

### Organization Management

#### Get Organization Details

```http
GET /organization
Authorization: Bearer {token}
```

**Response:**

```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "name": "Acme Corporation",
  "structure": "hierarchical",
  "total_employees": 5000,
  "department_count": 15,
  "settings": {
    "timezone": "America/New_York",
    "currency": "USD"
  },
  "created_at": "2024-01-15T10:00:00Z"
}
```

#### Update Organization

```http
PUT /organization
Authorization: Bearer {token}
Content-Type: application/json

{
  "name": "Acme Corp",
  "settings": {
    "timezone": "America/Los_Angeles"
  }
}
```

### Department Management

#### List All Departments

```http
GET /departments?page=1&limit=20
Authorization: Bearer {token}
```

**Query Parameters:**
- `page` (optional): Page number (default: 1)
- `limit` (optional): Items per page (default: 20, max: 100)
- `parent_id` (optional): Filter by parent department
- `search` (optional): Search by name

**Response:**

```json
{
  "data": [
    {
      "id": "dept-1",
      "name": "Engineering",
      "parent_id": null,
      "manager_id": "user-123",
      "employee_count": 250,
      "budget_allocated": 5000000.00,
      "budget_spent": 3750000.00,
      "hierarchy_level": 1
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 15,
    "total_pages": 1
  }
}
```

#### Get Department Details

```http
GET /departments/{department_id}
Authorization: Bearer {token}
```

#### Create Department

```http
POST /departments
Authorization: Bearer {token}
Content-Type: application/json

{
  "name": "Machine Learning",
  "parent_id": "dept-1",
  "manager_id": "user-456",
  "budget_allocated": 2000000.00
}
```

#### Update Department

```http
PUT /departments/{department_id}
Authorization: Bearer {token}
Content-Type: application/json

{
  "name": "AI & Machine Learning",
  "budget_allocated": 2500000.00
}
```

#### Delete Department

```http
DELETE /departments/{department_id}
Authorization: Bearer {token}
```

### KPI Management

#### List KPIs

```http
GET /kpis?department_id={dept_id}&status=active
Authorization: Bearer {token}
```

**Query Parameters:**
- `department_id` (optional): Filter by department
- `status` (optional): Filter by status (active, archived)
- `type` (optional): Filter by type (financial, operational, customer, employee)

**Response:**

```json
{
  "data": [
    {
      "id": "kpi-1",
      "name": "Monthly Revenue",
      "description": "Total revenue generated per month",
      "value": 1250000.00,
      "target": 1500000.00,
      "unit": "USD",
      "type": "financial",
      "department_id": "dept-1",
      "owner_id": "user-123",
      "performance": 83.33,
      "trend": "improving",
      "last_updated": "2024-11-15T14:30:00Z"
    }
  ]
}
```

#### Create KPI

```http
POST /kpis
Authorization: Bearer {token}
Content-Type: application/json

{
  "name": "Customer Satisfaction Score",
  "description": "CSAT score from quarterly surveys",
  "target": 95.0,
  "unit": "percentage",
  "type": "customer",
  "department_id": "dept-support"
}
```

#### Update KPI Value

```http
PATCH /kpis/{kpi_id}/value
Authorization: Bearer {token}
Content-Type: application/json

{
  "value": 92.5,
  "timestamp": "2024-11-15T14:30:00Z"
}
```

#### Get KPI History

```http
GET /kpis/{kpi_id}/history?from=2024-01-01&to=2024-12-31&interval=month
Authorization: Bearer {token}
```

**Response:**

```json
{
  "kpi_id": "kpi-1",
  "data_points": [
    {
      "timestamp": "2024-01-31T23:59:59Z",
      "value": 1200000.00,
      "target": 1500000.00
    },
    {
      "timestamp": "2024-02-29T23:59:59Z",
      "value": 1350000.00,
      "target": 1500000.00
    }
  ]
}
```

### Employee Management

#### List Employees

```http
GET /employees?department_id={dept_id}
Authorization: Bearer {token}
```

#### Get Employee Details

```http
GET /employees/{employee_id}
Authorization: Bearer {token}
```

**Response:**

```json
{
  "id": "user-123",
  "name": "John Doe",
  "email": "john.doe@acme.com",
  "role": "engineering_manager",
  "department_id": "dept-1",
  "manager_id": "user-100",
  "direct_reports_count": 12,
  "hire_date": "2020-03-15",
  "performance_rating": 4.5,
  "kpis_owned": ["kpi-1", "kpi-2"]
}
```

### Reports

#### Generate Report

```http
POST /reports/generate
Authorization: Bearer {token}
Content-Type: application/json

{
  "title": "Q4 2024 Performance Report",
  "type": "performance",
  "department_id": "dept-1",
  "date_range": {
    "start": "2024-10-01",
    "end": "2024-12-31"
  },
  "metrics": ["revenue", "employee_productivity", "customer_satisfaction"],
  "format": "pdf"
}
```

**Response:**

```json
{
  "report_id": "report-123",
  "status": "generating",
  "estimated_completion": "2024-11-15T15:00:00Z"
}
```

#### Get Report Status

```http
GET /reports/{report_id}
Authorization: Bearer {token}
```

**Response:**

```json
{
  "id": "report-123",
  "status": "completed",
  "download_url": "https://api.businessos.app/v1/reports/report-123/download",
  "expires_at": "2024-11-22T15:00:00Z"
}
```

### AI Services

#### Analyze Anomaly

```http
POST /ai/analyze-anomaly
Authorization: Bearer {token}
Content-Type: application/json

{
  "kpi_id": "kpi-1",
  "data_points": [
    {"timestamp": "2024-11-01", "value": 1200000},
    {"timestamp": "2024-11-02", "value": 1250000},
    {"timestamp": "2024-11-03", "value": 850000}
  ]
}
```

**Response:**

```json
{
  "anomalies_detected": true,
  "anomalies": [
    {
      "timestamp": "2024-11-03",
      "value": 850000,
      "expected_range": [1150000, 1350000],
      "severity": "high",
      "confidence": 0.95
    }
  ],
  "insights": "Significant drop detected on Nov 3. Recommend investigating sales pipeline.",
  "recommended_actions": [
    "Review sales activity for Nov 3",
    "Check for system outages",
    "Compare with previous month patterns"
  ]
}
```

#### Get Predictive Insights

```http
POST /ai/predict
Authorization: Bearer {token}
Content-Type: application/json

{
  "kpi_id": "kpi-1",
  "forecast_period": "3_months"
}
```

**Response:**

```json
{
  "predictions": [
    {
      "period": "2024-12",
      "predicted_value": 1450000,
      "confidence_interval": {
        "lower": 1350000,
        "upper": 1550000
      },
      "confidence": 0.87
    },
    {
      "period": "2025-01",
      "predicted_value": 1500000,
      "confidence_interval": {
        "lower": 1400000,
        "upper": 1600000
      },
      "confidence": 0.82
    }
  ]
}
```

---

## WebSocket Real-time Updates

### Connection

Connect to the WebSocket server for real-time updates:

```javascript
const ws = new WebSocket('wss://api.businessos.app/v1/ws');

// Authenticate
ws.onopen = () => {
  ws.send(JSON.stringify({
    type: 'AUTH',
    payload: {
      token: 'YOUR_ACCESS_TOKEN'
    }
  }));
};

// Handle authentication response
ws.onmessage = (event) => {
  const message = JSON.parse(event.data);

  if (message.type === 'AUTH_SUCCESS') {
    console.log('Authenticated!');

    // Subscribe to updates
    ws.send(JSON.stringify({
      type: 'SUBSCRIBE',
      payload: {
        channels: ['kpis', 'departments']
      }
    }));
  }
};
```

### Subscribing to Updates

```javascript
// Subscribe to specific KPI updates
ws.send(JSON.stringify({
  type: 'SUBSCRIBE',
  payload: {
    channels: ['kpis'],
    filters: {
      kpi_ids: ['kpi-1', 'kpi-2']
    }
  }
}));

// Handle KPI updates
ws.onmessage = (event) => {
  const message = JSON.parse(event.data);

  if (message.type === 'KPI_UPDATED') {
    console.log('KPI Updated:', message.payload);
    // Update UI with new KPI value
  }
};
```

### Message Types

- `AUTH` - Authenticate connection
- `AUTH_SUCCESS` / `AUTH_FAILED` - Authentication response
- `SUBSCRIBE` / `UNSUBSCRIBE` - Channel subscription
- `KPI_UPDATED` - KPI value changed
- `DEPARTMENT_UPDATED` - Department modified
- `EMPLOYEE_UPDATED` - Employee data changed
- `HEARTBEAT` / `PONG` - Connection keep-alive

See `WEBSOCKET_PROTOCOL.md` for complete protocol documentation.

---

## Error Handling

### Error Response Format

```json
{
  "error": {
    "code": "RESOURCE_NOT_FOUND",
    "message": "Department with ID 'dept-999' not found",
    "details": {
      "resource_type": "department",
      "resource_id": "dept-999"
    },
    "request_id": "req-12345",
    "timestamp": "2024-11-15T14:30:00Z"
  }
}
```

### Common Error Codes

| Code | HTTP Status | Description |
|------|-------------|-------------|
| `UNAUTHORIZED` | 401 | Invalid or expired access token |
| `FORBIDDEN` | 403 | Insufficient permissions |
| `RESOURCE_NOT_FOUND` | 404 | Resource does not exist |
| `VALIDATION_ERROR` | 400 | Invalid request parameters |
| `RATE_LIMIT_EXCEEDED` | 429 | Too many requests |
| `INTERNAL_ERROR` | 500 | Server error |

### Retry Strategy

```javascript
async function apiCall(url, options, maxRetries = 3) {
  for (let i = 0; i < maxRetries; i++) {
    try {
      const response = await fetch(url, options);

      if (response.status === 429) {
        // Rate limited - exponential backoff
        const delay = Math.pow(2, i) * 1000;
        await new Promise(resolve => setTimeout(resolve, delay));
        continue;
      }

      if (response.status >= 500) {
        // Server error - retry
        const delay = Math.pow(2, i) * 1000;
        await new Promise(resolve => setTimeout(resolve, delay));
        continue;
      }

      return await response.json();

    } catch (error) {
      if (i === maxRetries - 1) throw error;
      const delay = Math.pow(2, i) * 1000;
      await new Promise(resolve => setTimeout(resolve, delay));
    }
  }
}
```

---

## Rate Limiting

### Limits

| Tier | Requests per minute | Burst |
|------|---------------------|-------|
| Free | 60 | 10 |
| Pro | 300 | 50 |
| Enterprise | 1000 | 200 |

### Rate Limit Headers

```http
X-RateLimit-Limit: 1000
X-RateLimit-Remaining: 995
X-RateLimit-Reset: 1700059200
```

### Handling Rate Limits

```javascript
const response = await fetch(url, options);

if (response.status === 429) {
  const resetTime = response.headers.get('X-RateLimit-Reset');
  const waitTime = (resetTime * 1000) - Date.now();

  console.log(`Rate limited. Retry after ${waitTime}ms`);
  await new Promise(resolve => setTimeout(resolve, waitTime));

  // Retry request
  return await fetch(url, options);
}
```

---

## Code Examples

### Python

```python
import requests
import json

class BusinessOSClient:
    def __init__(self, api_key, base_url='https://api.businessos.app/v1'):
        self.api_key = api_key
        self.base_url = base_url
        self.access_token = None

    def login(self, email, password):
        """Authenticate and get access token"""
        response = requests.post(
            f"{self.base_url}/auth/login",
            json={"email": email, "password": password}
        )
        response.raise_for_status()
        data = response.json()
        self.access_token = data['access_token']
        return data

    def get_headers(self):
        """Get request headers with authorization"""
        return {
            'Authorization': f'Bearer {self.access_token}',
            'Content-Type': 'application/json'
        }

    def get_kpis(self, department_id=None):
        """Get KPIs for a department"""
        url = f"{self.base_url}/kpis"
        params = {}
        if department_id:
            params['department_id'] = department_id

        response = requests.get(url, headers=self.get_headers(), params=params)
        response.raise_for_status()
        return response.json()

    def update_kpi_value(self, kpi_id, value):
        """Update a KPI value"""
        url = f"{self.base_url}/kpis/{kpi_id}/value"
        response = requests.patch(
            url,
            headers=self.get_headers(),
            json={'value': value}
        )
        response.raise_for_status()
        return response.json()

# Usage
client = BusinessOSClient()
client.login('user@company.com', 'password')
kpis = client.get_kpis(department_id='dept-1')
print(f"Found {len(kpis['data'])} KPIs")
```

### JavaScript/TypeScript

```typescript
class BusinessOSClient {
  private baseURL: string;
  private accessToken: string | null = null;

  constructor(baseURL = 'https://api.businessos.app/v1') {
    this.baseURL = baseURL;
  }

  async login(email: string, password: string) {
    const response = await fetch(`${this.baseURL}/auth/login`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ email, password })
    });

    if (!response.ok) {
      throw new Error(`Login failed: ${response.statusText}`);
    }

    const data = await response.json();
    this.accessToken = data.access_token;
    return data;
  }

  private getHeaders() {
    return {
      'Authorization': `Bearer ${this.accessToken}`,
      'Content-Type': 'application/json'
    };
  }

  async getKPIs(departmentId?: string) {
    const params = new URLSearchParams();
    if (departmentId) params.append('department_id', departmentId);

    const response = await fetch(
      `${this.baseURL}/kpis?${params}`,
      { headers: this.getHeaders() }
    );

    if (!response.ok) {
      throw new Error(`Failed to fetch KPIs: ${response.statusText}`);
    }

    return await response.json();
  }

  async updateKPIValue(kpiId: string, value: number) {
    const response = await fetch(
      `${this.baseURL}/kpis/${kpiId}/value`,
      {
        method: 'PATCH',
        headers: this.getHeaders(),
        body: JSON.stringify({ value })
      }
    );

    if (!response.ok) {
      throw new Error(`Failed to update KPI: ${response.statusText}`);
    }

    return await response.json();
  }
}

// Usage
const client = new BusinessOSClient();
await client.login('user@company.com', 'password');
const kpis = await client.getKPIs('dept-1');
console.log(`Found ${kpis.data.length} KPIs`);
```

### Swift (for visionOS app)

```swift
import Foundation

class BusinessOSClient {
    private let baseURL = "https://api.businessos.app/v1"
    private var accessToken: String?

    func login(email: String, password: String) async throws -> AuthResponse {
        let url = URL(string: "\(baseURL)/auth/login")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = ["email": email, "password": password]
        request.httpBody = try JSONEncoder().encode(body)

        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try JSONDecoder().decode(AuthResponse.self, from: data)
        self.accessToken = response.accessToken
        return response
    }

    func getKPIs(departmentId: String? = nil) async throws -> KPIListResponse {
        var components = URLComponents(string: "\(baseURL)/kpis")!
        if let departmentId = departmentId {
            components.queryItems = [URLQueryItem(name: "department_id", value: departmentId)]
        }

        var request = URLRequest(url: components.url!)
        request.setValue("Bearer \(accessToken ?? "")", forHTTPHeaderField: "Authorization")

        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode(KPIListResponse.self, from: data)
    }
}
```

---

## Best Practices

### 1. Token Management

- Store access tokens securely (keychain, secure storage)
- Refresh tokens proactively before expiration
- Handle token expiration gracefully

### 2. Error Handling

- Always check HTTP status codes
- Implement exponential backoff for retries
- Log request IDs for debugging

### 3. Rate Limiting

- Implement client-side rate limiting
- Cache responses when appropriate
- Use webhooks/WebSockets instead of polling

### 4. Performance

- Use pagination for large datasets
- Request only needed fields (if field selection is supported)
- Batch requests when possible

### 5. Security

- Always use HTTPS
- Never log access tokens
- Validate SSL certificates
- Use API keys for server-to-server communication

---

## Support

- **Documentation**: https://docs.businessos.app
- **API Reference**: https://api.businessos.app/docs
- **Status Page**: https://status.businessos.app
- **Support Email**: api-support@businessos.app

---

## Changelog

### v1.0.0 (2024-11-15)

- Initial API release
- Authentication endpoints
- Organization, Department, KPI, Employee endpoints
- AI services (anomaly detection, predictions)
- WebSocket real-time updates
- Report generation
