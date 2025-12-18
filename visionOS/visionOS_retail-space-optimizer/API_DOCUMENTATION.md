# API Documentation

Complete API reference for Retail Space Optimizer backend services.

## Table of Contents

- [Overview](#overview)
- [Authentication](#authentication)
- [Base URL](#base-url)
- [Endpoints](#endpoints)
  - [Stores](#stores)
  - [Layouts](#layouts)
  - [Fixtures](#fixtures)
  - [Analytics](#analytics)
  - [Simulation](#simulation)
  - [Users](#users)
- [Data Models](#data-models)
- [Error Handling](#error-handling)
- [Rate Limiting](#rate-limiting)
- [Versioning](#versioning)

## Overview

The Retail Space Optimizer API provides RESTful endpoints for managing retail stores, layouts, fixtures, and analytics. All endpoints use JSON for request and response bodies.

### API Features

- RESTful architecture
- JSON request/response format
- JWT authentication
- Rate limiting
- Comprehensive error handling
- Real-time WebSocket support (planned)
- GraphQL support (planned)

### HTTP Methods

- `GET` - Retrieve resources
- `POST` - Create new resources
- `PUT` - Update existing resources (full update)
- `PATCH` - Partial update of resources
- `DELETE` - Delete resources

## Authentication

### JWT Token Authentication

All API requests require a valid JWT token in the Authorization header:

```http
Authorization: Bearer <your-jwt-token>
```

### Obtaining a Token

```http
POST /api/v1/auth/login
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "your-password"
}
```

**Response:**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIs...",
  "refreshToken": "eyJhbGciOiJIUzI1NiIs...",
  "expiresIn": 3600,
  "user": {
    "id": "123e4567-e89b-12d3-a456-426614174000",
    "email": "user@example.com",
    "name": "John Doe"
  }
}
```

### Refreshing Tokens

```http
POST /api/v1/auth/refresh
Content-Type: application/json

{
  "refreshToken": "eyJhbGciOiJIUzI1NiIs..."
}
```

## Base URL

### Production
```
https://api.retailspaceoptimizer.com/api/v1
```

### Staging
```
https://staging-api.retailspaceoptimizer.com/api/v1
```

### Development
```
http://localhost:8080/api/v1
```

## Endpoints

### Stores

#### List All Stores

```http
GET /stores
```

**Query Parameters:**
- `page` (integer, optional): Page number (default: 1)
- `limit` (integer, optional): Items per page (default: 20, max: 100)
- `sort` (string, optional): Sort field (e.g., `name`, `createdAt`)
- `order` (string, optional): Sort order (`asc` or `desc`, default: `asc`)

**Response:**
```json
{
  "stores": [
    {
      "id": "123e4567-e89b-12d3-a456-426614174000",
      "name": "Downtown Flagship",
      "location": {
        "address": "123 Main St",
        "city": "San Francisco",
        "state": "CA",
        "country": "USA",
        "postalCode": "94102",
        "latitude": 37.7749,
        "longitude": -122.4194
      },
      "dimensions": {
        "width": 20.0,
        "length": 30.0,
        "height": 4.0,
        "area": 600.0,
        "usableArea": 510.0
      },
      "version": 1,
      "createdAt": "2025-11-19T10:00:00Z",
      "updatedAt": "2025-11-19T10:00:00Z"
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 100,
    "totalPages": 5
  }
}
```

#### Get Store by ID

```http
GET /stores/:id
```

**Parameters:**
- `id` (UUID, required): Store ID

**Response:**
```json
{
  "id": "123e4567-e89b-12d3-a456-426614174000",
  "name": "Downtown Flagship",
  "location": { ... },
  "dimensions": { ... },
  "layouts": [
    {
      "id": "223e4567-e89b-12d3-a456-426614174001",
      "name": "Standard Layout",
      "isActive": true
    }
  ],
  "performanceMetrics": { ... },
  "version": 1,
  "createdAt": "2025-11-19T10:00:00Z",
  "updatedAt": "2025-11-19T10:00:00Z"
}
```

#### Create Store

```http
POST /stores
Content-Type: application/json

{
  "name": "New Store",
  "location": {
    "address": "456 Oak Ave",
    "city": "Los Angeles",
    "state": "CA",
    "country": "USA",
    "postalCode": "90001"
  },
  "dimensions": {
    "width": 15.0,
    "length": 25.0,
    "height": 3.5
  }
}
```

**Response:**
```json
{
  "id": "323e4567-e89b-12d3-a456-426614174002",
  "name": "New Store",
  "location": { ... },
  "dimensions": {
    "width": 15.0,
    "length": 25.0,
    "height": 3.5,
    "area": 375.0,
    "usableArea": 318.75
  },
  "version": 1,
  "createdAt": "2025-11-19T11:00:00Z",
  "updatedAt": "2025-11-19T11:00:00Z"
}
```

#### Update Store

```http
PUT /stores/:id
Content-Type: application/json

{
  "name": "Updated Store Name",
  "location": { ... },
  "dimensions": { ... }
}
```

#### Delete Store

```http
DELETE /stores/:id
```

**Response:**
```json
{
  "message": "Store deleted successfully",
  "id": "123e4567-e89b-12d3-a456-426614174000"
}
```

---

### Layouts

#### List Layouts for Store

```http
GET /stores/:storeId/layouts
```

**Response:**
```json
{
  "layouts": [
    {
      "id": "223e4567-e89b-12d3-a456-426614174001",
      "storeId": "123e4567-e89b-12d3-a456-426614174000",
      "name": "Standard Layout",
      "isActive": true,
      "fixtureCount": 25,
      "version": 1,
      "createdAt": "2025-11-19T10:00:00Z",
      "updatedAt": "2025-11-19T10:00:00Z"
    }
  ]
}
```

#### Get Layout by ID

```http
GET /layouts/:id
```

**Response:**
```json
{
  "id": "223e4567-e89b-12d3-a456-426614174001",
  "storeId": "123e4567-e89b-12d3-a456-426614174000",
  "name": "Standard Layout",
  "isActive": true,
  "fixtures": [
    {
      "id": "423e4567-e89b-12d3-a456-426614174003",
      "name": "Clothing Rack Standard",
      "fixtureType": "rack",
      "category": "apparel",
      "position": {
        "x": 5.0,
        "y": 0.0,
        "z": 10.0
      },
      "rotation": {
        "angle": 0.0,
        "axis": {
          "x": 0.0,
          "y": 1.0,
          "z": 0.0
        }
      },
      "dimensions": {
        "x": 2.0,
        "y": 1.8,
        "z": 0.6
      },
      "capacity": 50,
      "modelAsset": "Rack_Standard"
    }
  ],
  "walls": [ ... ],
  "entrances": [ ... ],
  "version": 1,
  "createdAt": "2025-11-19T10:00:00Z",
  "updatedAt": "2025-11-19T10:00:00Z"
}
```

#### Create Layout

```http
POST /stores/:storeId/layouts
Content-Type: application/json

{
  "name": "New Layout",
  "isActive": false
}
```

#### Update Layout

```http
PUT /layouts/:id
Content-Type: application/json

{
  "name": "Updated Layout",
  "isActive": true
}
```

#### Validate Layout

```http
POST /layouts/:id/validate
```

**Response:**
```json
{
  "valid": true,
  "issues": [],
  "warnings": [
    {
      "code": "FIXTURE_OVERLAP",
      "message": "Fixtures A and B are overlapping",
      "severity": "warning"
    }
  ]
}
```

---

### Fixtures

#### List Fixture Library

```http
GET /fixtures/library
```

**Query Parameters:**
- `category` (string, optional): Filter by category
- `type` (string, optional): Filter by fixture type

**Response:**
```json
{
  "fixtures": [
    {
      "id": "template-rack-01",
      "name": "Clothing Rack Standard",
      "fixtureType": "rack",
      "category": "apparel",
      "dimensions": {
        "x": 2.0,
        "y": 1.8,
        "z": 0.6
      },
      "capacity": 50,
      "modelAsset": "Rack_Standard",
      "thumbnail": "https://cdn.example.com/thumbnails/rack-standard.png"
    }
  ]
}
```

#### Add Fixture to Layout

```http
POST /layouts/:layoutId/fixtures
Content-Type: application/json

{
  "templateId": "template-rack-01",
  "position": {
    "x": 5.0,
    "y": 0.0,
    "z": 10.0
  },
  "rotation": {
    "angle": 1.5708,
    "axis": {
      "x": 0.0,
      "y": 1.0,
      "z": 0.0
    }
  }
}
```

#### Update Fixture

```http
PATCH /fixtures/:id
Content-Type: application/json

{
  "position": {
    "x": 6.0,
    "y": 0.0,
    "z": 12.0
  },
  "rotation": {
    "angle": 3.1416,
    "axis": {
      "x": 0.0,
      "y": 1.0,
      "z": 0.0
    }
  }
}
```

#### Delete Fixture

```http
DELETE /fixtures/:id
```

---

### Analytics

#### Get Heat Map

```http
GET /analytics/stores/:storeId/heatmap
```

**Query Parameters:**
- `metric` (string, required): `traffic`, `dwell`, `conversion`, `sales`
- `startDate` (ISO 8601, required): Start date
- `endDate` (ISO 8601, required): End date
- `resolution` (string, optional): `low`, `medium`, `high` (default: `medium`)

**Response:**
```json
{
  "storeId": "123e4567-e89b-12d3-a456-426614174000",
  "metric": "traffic",
  "gridResolution": {
    "x": 20,
    "y": 30
  },
  "dataPoints": [
    [0.0, 0.1, 0.2, ...],
    [0.1, 0.3, 0.5, ...],
    ...
  ],
  "timeRange": {
    "start": "2025-11-01T00:00:00Z",
    "end": "2025-11-30T23:59:59Z"
  },
  "maxValue": 1.0,
  "minValue": 0.0
}
```

#### Get Performance Metrics

```http
GET /analytics/stores/:storeId/metrics
```

**Query Parameters:**
- `startDate` (ISO 8601, required)
- `endDate` (ISO 8601, required)
- `granularity` (string, optional): `hourly`, `daily`, `weekly`, `monthly`

**Response:**
```json
{
  "storeId": "123e4567-e89b-12d3-a456-426614174000",
  "timeRange": {
    "start": "2025-11-01T00:00:00Z",
    "end": "2025-11-30T23:59:59Z"
  },
  "metrics": {
    "totalVisitors": 12543,
    "totalSales": 543210.50,
    "conversionRate": 0.28,
    "averageDwellTime": 420,
    "salesPerSquareFoot": 905.35,
    "topZones": [
      {
        "zoneId": "zone-entrance",
        "name": "Entrance",
        "traffic": 12543,
        "sales": 125000.00
      }
    ]
  },
  "trends": {
    "visitorsTrend": "up",
    "salesTrend": "up",
    "conversionTrend": "stable"
  }
}
```

#### Get Customer Journeys

```http
GET /analytics/stores/:storeId/journeys
```

**Query Parameters:**
- `startDate` (ISO 8601, required)
- `endDate` (ISO 8601, required)
- `limit` (integer, optional): Max journeys to return

**Response:**
```json
{
  "journeys": [
    {
      "id": "journey-001",
      "customerPersona": {
        "demographicProfile": "Young Professional",
        "shoppingMission": "browse",
        "timeConstraint": "flexible",
        "priceSensitivity": 0.5
      },
      "entryPoint": {
        "x": 0.0,
        "y": 0.0,
        "z": 15.0
      },
      "exitPoint": {
        "x": 20.0,
        "y": 0.0,
        "z": 15.0
      },
      "totalTime": 1200,
      "conversionValue": 125.50,
      "pathPoints": [ ... ],
      "dwellZones": [ ... ]
    }
  ]
}
```

---

### Simulation

#### Run Customer Flow Simulation

```http
POST /simulation/stores/:storeId/flow
Content-Type: application/json

{
  "layoutId": "223e4567-e89b-12d3-a456-426614174001",
  "customerCount": 100,
  "timeWindow": {
    "start": "09:00",
    "end": "21:00"
  },
  "personas": [
    {
      "type": "quick-shopper",
      "percentage": 0.3
    },
    {
      "type": "browser",
      "percentage": 0.4
    },
    {
      "type": "focused-buyer",
      "percentage": 0.3
    }
  ]
}
```

**Response:**
```json
{
  "simulationId": "sim-12345",
  "status": "running",
  "progress": 0,
  "estimatedCompletionTime": "2025-11-19T12:05:00Z"
}
```

#### Get Simulation Results

```http
GET /simulation/:simulationId
```

**Response:**
```json
{
  "simulationId": "sim-12345",
  "status": "completed",
  "progress": 100,
  "results": {
    "totalCustomers": 100,
    "avgDwellTime": 450,
    "conversionRate": 0.32,
    "bottlenecks": [
      {
        "location": {
          "x": 10.0,
          "y": 0.0,
          "z": 15.0
        },
        "severity": "medium",
        "description": "High congestion near checkout"
      }
    ],
    "heatmap": { ... },
    "recommendations": [
      "Move checkout counter to reduce congestion",
      "Add additional entrance to improve flow"
    ]
  },
  "completedAt": "2025-11-19T12:03:45Z"
}
```

---

### Users

#### Get Current User

```http
GET /users/me
```

**Response:**
```json
{
  "id": "user-123",
  "email": "user@example.com",
  "name": "John Doe",
  "role": "admin",
  "organization": {
    "id": "org-456",
    "name": "Acme Retail"
  },
  "preferences": {
    "defaultView": "3d",
    "units": "metric"
  },
  "createdAt": "2025-01-15T10:00:00Z"
}
```

#### Update User Profile

```http
PATCH /users/me
Content-Type: application/json

{
  "name": "John Smith",
  "preferences": {
    "defaultView": "2d",
    "units": "imperial"
  }
}
```

---

## Data Models

### Store

```typescript
interface Store {
  id: UUID
  name: string
  location: StoreLocation
  dimensions: StoreDimensions
  layouts?: Layout[]
  performanceMetrics?: PerformanceMetric[]
  version: number
  createdAt: ISO8601DateTime
  updatedAt: ISO8601DateTime
}

interface StoreLocation {
  address: string
  city: string
  state: string
  country: string
  postalCode: string
  latitude?: number
  longitude?: number
}

interface StoreDimensions {
  width: number  // meters
  length: number // meters
  height: number // meters
  area: number   // calculated: width × length
  usableArea: number // calculated: area × 0.85
}
```

### Layout

```typescript
interface Layout {
  id: UUID
  storeId: UUID
  name: string
  isActive: boolean
  fixtures?: Fixture[]
  walls?: Wall[]
  entrances?: Entrance[]
  version: number
  createdAt: ISO8601DateTime
  updatedAt: ISO8601DateTime
}
```

### Fixture

```typescript
interface Fixture {
  id: UUID
  name: string
  fixtureType: FixtureType
  category: FixtureCategory
  position: Vector3D
  rotation: Rotation3D
  dimensions: Vector3D
  capacity: number
  modelAsset: string
}

type FixtureType =
  | "shelf"
  | "rack"
  | "table"
  | "mannequin"
  | "checkout"
  | "entrance"
  | "signage"
  | "display"

type FixtureCategory =
  | "apparel"
  | "footwear"
  | "accessories"
  | "electronics"
  | "home"
  | "beauty"
  | "grocery"
  | "checkout"

interface Vector3D {
  x: number
  y: number
  z: number
}

interface Rotation3D {
  angle: number      // radians
  axis: Vector3D     // normalized axis
}
```

---

## Error Handling

### Error Response Format

All errors follow this format:

```json
{
  "error": {
    "code": "ERROR_CODE",
    "message": "Human-readable error message",
    "details": {
      "field": "Additional context about the error"
    },
    "requestId": "req-123456"
  }
}
```

### HTTP Status Codes

| Code | Description |
|------|-------------|
| 200 | Success |
| 201 | Created |
| 204 | No Content (successful deletion) |
| 400 | Bad Request - Invalid input |
| 401 | Unauthorized - Invalid or missing token |
| 403 | Forbidden - Insufficient permissions |
| 404 | Not Found - Resource doesn't exist |
| 409 | Conflict - Resource already exists |
| 422 | Unprocessable Entity - Validation failed |
| 429 | Too Many Requests - Rate limit exceeded |
| 500 | Internal Server Error |
| 503 | Service Unavailable |

### Common Error Codes

```typescript
type ErrorCode =
  | "INVALID_REQUEST"
  | "UNAUTHORIZED"
  | "FORBIDDEN"
  | "NOT_FOUND"
  | "CONFLICT"
  | "VALIDATION_ERROR"
  | "RATE_LIMIT_EXCEEDED"
  | "INTERNAL_ERROR"
  | "SERVICE_UNAVAILABLE"
```

### Error Examples

**Validation Error:**
```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid store dimensions",
    "details": {
      "width": "Must be greater than 0",
      "length": "Must be greater than 0"
    },
    "requestId": "req-123456"
  }
}
```

**Authentication Error:**
```json
{
  "error": {
    "code": "UNAUTHORIZED",
    "message": "Invalid or expired token",
    "requestId": "req-123457"
  }
}
```

---

## Rate Limiting

### Limits

| Tier | Requests per Minute | Requests per Day |
|------|---------------------|------------------|
| Free | 60 | 1,000 |
| Professional | 600 | 50,000 |
| Enterprise | Unlimited | Unlimited |

### Rate Limit Headers

Every response includes rate limit information:

```http
X-RateLimit-Limit: 60
X-RateLimit-Remaining: 45
X-RateLimit-Reset: 1637582400
```

### Rate Limit Exceeded

```json
{
  "error": {
    "code": "RATE_LIMIT_EXCEEDED",
    "message": "Too many requests. Please try again in 60 seconds.",
    "details": {
      "retryAfter": 60
    },
    "requestId": "req-123458"
  }
}
```

---

## Versioning

### URL Versioning

The API uses URL-based versioning:

```
https://api.retailspaceoptimizer.com/api/v1/stores
```

### Version Lifecycle

- **v1**: Current stable version
- **v2**: Planned for 2026 (breaking changes)

### Deprecation Policy

- Versions are supported for **12 months** after a new major version is released
- Deprecated endpoints will include a warning header:
  ```http
  Deprecation: version="v1", date="2026-01-01"
  ```

---

## Webhooks (Planned)

### Event Types

- `store.created`
- `store.updated`
- `store.deleted`
- `layout.created`
- `layout.updated`
- `simulation.completed`
- `analytics.report_ready`

### Webhook Payload

```json
{
  "event": "store.created",
  "timestamp": "2025-11-19T12:00:00Z",
  "data": {
    "id": "123e4567-e89b-12d3-a456-426614174000",
    "name": "New Store"
  }
}
```

---

## GraphQL Support (Planned)

GraphQL endpoint will be available at:

```
https://api.retailspaceoptimizer.com/graphql
```

---

## SDK Libraries

### Swift (Official)

```swift
import RetailSpaceOptimizerAPI

let client = RSO.Client(token: "your-jwt-token")
let stores = try await client.stores.list()
```

### JavaScript/TypeScript (Planned)

```typescript
import { RSOClient } from '@retailspaceoptimizer/api'

const client = new RSOClient({ token: 'your-jwt-token' })
const stores = await client.stores.list()
```

---

## Support

- **API Issues**: api-support@retailspaceoptimizer.com
- **Documentation**: https://docs.retailspaceoptimizer.com
- **Status Page**: https://status.retailspaceoptimizer.com

---

**API Version**: 1.0
**Last Updated**: 2025-11-19
