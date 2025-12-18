# API Integration Guide

Comprehensive guide for integrating with the Spatial Meeting Platform API.

## Table of Contents

1. [Getting Started](#getting-started)
2. [Authentication](#authentication)
3. [API Endpoints](#api-endpoints)
4. [WebSocket Integration](#websocket-integration)
5. [Code Examples](#code-examples)
6. [Error Handling](#error-handling)
7. [Best Practices](#best-practices)

## Getting Started

### Base URL

```
Development: http://localhost:3000/api
Production: https://api.spatialmeeting.com/api
```

### API Documentation

Interactive API documentation is available at:
```
http://localhost:3000/api-docs
```

### Prerequisites

- API credentials (email/password)
- HTTP client (axios, fetch, etc.)
- WebSocket client for real-time features

## Authentication

### Register a New User

```bash
curl -X POST http://localhost:3000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com",
    "username": "johndoe",
    "password": "securepassword123",
    "display_name": "John Doe"
  }'
```

**Response:**
```json
{
  "user": {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "email": "user@example.com",
    "username": "johndoe",
    "display_name": "John Doe",
    "created_at": "2025-01-15T10:30:00Z"
  },
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

### Login

```bash
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com",
    "password": "securepassword123"
  }'
```

### Using the Token

Include the JWT token in the Authorization header for all protected endpoints:

```bash
curl -X GET http://localhost:3000/api/meetings \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

## API Endpoints

### Meetings

#### Create a Meeting

```bash
curl -X POST http://localhost:3000/api/meetings \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Team Standup",
    "description": "Daily team sync",
    "environment_type": "conference_room",
    "layout_type": "circle",
    "max_participants": 10,
    "scheduled_start": "2025-01-16T09:00:00Z"
  }'
```

#### Get All Meetings

```bash
curl -X GET "http://localhost:3000/api/meetings?status=active&limit=20" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

#### Join a Meeting

```bash
curl -X POST http://localhost:3000/api/meetings/{meeting_id}/join \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "role": "participant"
  }'
```

#### Get Meeting Participants

```bash
curl -X GET http://localhost:3000/api/meetings/{meeting_id}/participants \
  -H "Authorization: Bearer YOUR_TOKEN"
```

### Content Sharing

#### Share Content in Meeting

```bash
curl -X POST http://localhost:3000/api/meetings/{meeting_id}/content \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Q4 Presentation",
    "content_type": "document",
    "content_url": "https://example.com/presentation.pdf",
    "position_x": 0,
    "position_y": 1.5,
    "position_z": -2
  }'
```

## WebSocket Integration

### Connecting to WebSocket Server

```javascript
const token = 'YOUR_JWT_TOKEN';
const ws = new WebSocket(`ws://localhost:3001?token=${token}`);

ws.onopen = () => {
  console.log('Connected to WebSocket server');

  // Join a meeting
  ws.send(JSON.stringify({
    type: 'join_meeting',
    payload: { meetingId: 'meeting-uuid' },
    timestamp: Date.now()
  }));
};

ws.onmessage = (event) => {
  const message = JSON.parse(event.data);
  console.log('Received:', message);

  switch (message.type) {
    case 'participant_joined':
      console.log('New participant:', message.payload);
      break;
    case 'participant_position':
      updateParticipantPosition(message.payload);
      break;
    case 'content_added':
      displayNewContent(message.payload);
      break;
  }
};

ws.onerror = (error) => {
  console.error('WebSocket error:', error);
};

ws.onclose = () => {
  console.log('Disconnected from WebSocket server');
};
```

### WebSocket Message Types

#### Join Meeting
```json
{
  "type": "join_meeting",
  "payload": { "meetingId": "meeting-uuid" },
  "timestamp": 1705401600000
}
```

#### Update Position
```json
{
  "type": "participant_position",
  "payload": {
    "x": 1.5,
    "y": 0.0,
    "z": -2.0,
    "rotX": 0,
    "rotY": 90,
    "rotZ": 0
  },
  "timestamp": 1705401600000
}
```

#### Audio/Video State
```json
{
  "type": "audio_state",
  "payload": { "is_muted": true },
  "timestamp": 1705401600000
}
```

## Code Examples

### JavaScript/TypeScript (Using Axios)

```typescript
import axios from 'axios';

const API_URL = 'http://localhost:3000/api';

// Create API client
const api = axios.create({
  baseURL: API_URL,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Add auth token to requests
api.interceptors.request.use((config) => {
  const token = localStorage.getItem('token');
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

// Login
async function login(email: string, password: string) {
  const response = await api.post('/auth/login', { email, password });
  localStorage.setItem('token', response.data.token);
  return response.data.user;
}

// Create Meeting
async function createMeeting(data: any) {
  const response = await api.post('/meetings', data);
  return response.data;
}

// Join Meeting
async function joinMeeting(meetingId: string) {
  const response = await api.post(`/meetings/${meetingId}/join`, {
    role: 'participant'
  });
  return response.data;
}

// Get Participants
async function getParticipants(meetingId: string) {
  const response = await api.get(`/meetings/${meetingId}/participants`);
  return response.data;
}
```

### Python

```python
import requests
import json

API_URL = "http://localhost:3000/api"

class SpatialMeetingClient:
    def __init__(self):
        self.session = requests.Session()
        self.token = None

    def login(self, email, password):
        response = self.session.post(
            f"{API_URL}/auth/login",
            json={"email": email, "password": password}
        )
        data = response.json()
        self.token = data['token']
        self.session.headers.update({
            'Authorization': f'Bearer {self.token}'
        })
        return data['user']

    def create_meeting(self, title, environment_type, layout_type):
        response = self.session.post(
            f"{API_URL}/meetings",
            json={
                "title": title,
                "environment_type": environment_type,
                "layout_type": layout_type
            }
        )
        return response.json()

    def join_meeting(self, meeting_id):
        response = self.session.post(
            f"{API_URL}/meetings/{meeting_id}/join",
            json={"role": "participant"}
        )
        return response.json()

    def get_participants(self, meeting_id):
        response = self.session.get(
            f"{API_URL}/meetings/{meeting_id}/participants"
        )
        return response.json()

# Usage
client = SpatialMeetingClient()
user = client.login("user@example.com", "password")
meeting = client.create_meeting("Team Meeting", "conference_room", "circle")
participant = client.join_meeting(meeting['id'])
```

### Swift (visionOS)

```swift
import Foundation

class SpatialMeetingAPI {
    let baseURL = "http://localhost:3000/api"
    var token: String?

    func login(email: String, password: String) async throws -> User {
        let url = URL(string: "\(baseURL)/auth/login")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = ["email": email, "password": password]
        request.httpBody = try JSONEncoder().encode(body)

        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try JSONDecoder().decode(LoginResponse.self, from: data)

        self.token = response.token
        return response.user
    }

    func createMeeting(title: String, environmentType: String, layoutType: String) async throws -> Meeting {
        let url = URL(string: "\(baseURL)/meetings")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token ?? "")", forHTTPHeaderField: "Authorization")

        let body: [String: Any] = [
            "title": title,
            "environment_type": environmentType,
            "layout_type": layoutType
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode(Meeting.self, from: data)
    }
}
```

## Error Handling

### HTTP Status Codes

| Code | Meaning | Description |
|------|---------|-------------|
| 200 | OK | Request successful |
| 201 | Created | Resource created successfully |
| 204 | No Content | Request successful, no content returned |
| 400 | Bad Request | Invalid request data |
| 401 | Unauthorized | Authentication required or failed |
| 403 | Forbidden | Insufficient permissions |
| 404 | Not Found | Resource not found |
| 409 | Conflict | Resource already exists |
| 429 | Too Many Requests | Rate limit exceeded |
| 500 | Internal Server Error | Server error |

### Error Response Format

```json
{
  "error": "Error message description"
}
```

### Example Error Handling

```typescript
try {
  const meeting = await createMeeting(data);
} catch (error) {
  if (error.response) {
    switch (error.response.status) {
      case 400:
        console.error('Invalid meeting data:', error.response.data.error);
        break;
      case 401:
        console.error('Authentication required');
        // Redirect to login
        break;
      case 403:
        console.error('Insufficient permissions');
        break;
      case 404:
        console.error('Meeting not found');
        break;
      case 429:
        console.error('Rate limit exceeded, please wait');
        break;
      default:
        console.error('Unexpected error:', error.response.data.error);
    }
  }
}
```

## Best Practices

### 1. Token Management

- Store tokens securely (localStorage for web, Keychain for iOS)
- Refresh tokens before expiration
- Clear tokens on logout
- Handle token expiration gracefully

### 2. Error Handling

- Always handle network errors
- Implement retry logic for transient failures
- Show user-friendly error messages
- Log errors for debugging

### 3. Performance

- Use pagination for large lists
- Cache frequently accessed data
- Debounce position updates
- Close WebSocket connections when not needed

### 4. Security

- Always use HTTPS in production
- Never log sensitive data
- Validate all input data
- Implement rate limiting on client side

### 5. WebSocket

- Implement reconnection logic
- Handle connection drops gracefully
- Send heartbeat/ping messages
- Clean up listeners on disconnect

### Rate Limiting

The API implements rate limiting:
- **Window**: 15 minutes
- **Max Requests**: 100 per window

Handle 429 responses by implementing exponential backoff.

## Support

- **API Documentation**: http://localhost:3000/api-docs
- **GitHub Issues**: https://github.com/yourorg/spatial-meeting-platform
- **Email**: support@spatialmeeting.com

## Changelog

### v1.0.0 (2025-01-15)
- Initial API release
- Authentication endpoints
- Meeting CRUD operations
- WebSocket real-time sync
- Content sharing
