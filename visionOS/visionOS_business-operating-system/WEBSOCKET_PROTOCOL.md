# Business Operating System - WebSocket Protocol Documentation

**Version:** 1.0.0
**Protocol:** WebSocket (RFC 6455)
**Last Updated:** 2025-01-20

---

## Table of Contents

1. [Overview](#overview)
2. [Connection Lifecycle](#connection-lifecycle)
3. [Message Format](#message-format)
4. [Authentication](#authentication)
5. [Message Types](#message-types)
6. [Real-time Sync Events](#real-time-sync-events)
7. [Collaboration Protocol](#collaboration-protocol)
8. [Error Handling](#error-handling)
9. [Heartbeat & Reconnection](#heartbeat--reconnection)
10. [Security](#security)
11. [Client Implementation Examples](#client-implementation-examples)

---

## Overview

The BOS WebSocket protocol enables:
- **Real-time data synchronization** across devices
- **Collaborative sessions** with spatial annotations
- **Live KPI updates** without polling
- **Push notifications** for alerts and insights
- **Presence tracking** for users in shared spaces

### Protocol Features

- ✅ **Bidirectional**: Client ↔ Server communication
- ✅ **Efficient**: Binary and text message support
- ✅ **Reliable**: Message acknowledgment and retry
- ✅ **Scalable**: Horizontal scaling with Redis pub/sub
- ✅ **Secure**: JWT-based authentication, TLS encryption

### Connection Details

- **Endpoint**: `wss://api.businessos.io/v1/ws`
- **Subprotocol**: `bos-v1`
- **Max Message Size**: 1 MB
- **Idle Timeout**: 5 minutes (with heartbeat)
- **Reconnection**: Exponential backoff (2s, 4s, 8s, 16s, 30s max)

---

## Connection Lifecycle

### Connection States

```
┌──────────────┐
│ Disconnected │
└──────┬───────┘
       │ WebSocket.connect()
       ▼
┌──────────────┐
│  Connecting  │
└──────┬───────┘
       │ Connection established
       ▼
┌──────────────┐
│ Authenticating│
└──────┬───────┘
       │ Send AUTH message
       ▼
┌──────────────┐
│  Connected   │◄─┐ Heartbeat every 30s
└──────┬───────┘  │
       │          │
       ▼          │
┌──────────────┐  │
│   Active     │──┘
└──────┬───────┘
       │ Error / Close
       ▼
┌──────────────┐
│ Disconnected │
└──────────────┘
```

### Connection Sequence

```javascript
// 1. Establish WebSocket connection
const ws = new WebSocket('wss://api.businessos.io/v1/ws', ['bos-v1']);

// 2. On connection open, authenticate
ws.onopen = () => {
    ws.send(JSON.stringify({
        type: 'AUTH',
        payload: {
            token: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...'
        }
    }));
};

// 3. Receive authentication response
ws.onmessage = (event) => {
    const message = JSON.parse(event.data);
    if (message.type === 'AUTH_SUCCESS') {
        console.log('Authenticated:', message.payload.userId);
        // Subscribe to channels
        ws.send(JSON.stringify({
            type: 'SUBSCRIBE',
            payload: {
                channels: ['organization:123', 'department:456']
            }
        }));
    }
};
```

---

## Message Format

### Standard Message Structure

All messages follow this JSON structure:

```typescript
interface WebSocketMessage {
    type: string;                    // Message type (uppercase)
    payload: object;                 // Type-specific payload
    requestId?: string;              // Optional request correlation ID
    timestamp?: string;              // ISO 8601 timestamp
    version?: string;                // Protocol version (default: '1.0')
}
```

### Example Messages

#### Client → Server

```json
{
    "type": "KPI_UPDATE",
    "payload": {
        "kpiId": "550e8400-e29b-41d4-a716-446655440000",
        "value": 1250000.00
    },
    "requestId": "req-12345",
    "timestamp": "2025-01-20T10:30:00Z",
    "version": "1.0"
}
```

#### Server → Client

```json
{
    "type": "KPI_UPDATED",
    "payload": {
        "kpiId": "550e8400-e29b-41d4-a716-446655440000",
        "value": 1250000.00,
        "updatedBy": "user-789",
        "updatedAt": "2025-01-20T10:30:00Z"
    },
    "requestId": "req-12345",
    "timestamp": "2025-01-20T10:30:01Z"
}
```

---

## Authentication

### Initial Authentication

**Client → Server**

```json
{
    "type": "AUTH",
    "payload": {
        "token": "JWT_ACCESS_TOKEN"
    }
}
```

**Server → Client (Success)**

```json
{
    "type": "AUTH_SUCCESS",
    "payload": {
        "userId": "user-123",
        "organizationId": "org-456",
        "sessionId": "session-789",
        "expiresAt": "2025-01-20T11:30:00Z"
    }
}
```

**Server → Client (Failure)**

```json
{
    "type": "AUTH_FAILED",
    "payload": {
        "error": "INVALID_TOKEN",
        "message": "Authentication token is invalid or expired"
    }
}
```

### Token Expiration

When a JWT expires during an active WebSocket connection:

**Server → Client**

```json
{
    "type": "TOKEN_EXPIRED",
    "payload": {
        "message": "Authentication token has expired. Please reauthenticate."
    }
}
```

**Client Response**: Client should obtain a new token (via `/auth/refresh`) and send a new `AUTH` message.

---

## Message Types

### 1. Connection Management

| Type | Direction | Description |
|------|-----------|-------------|
| `AUTH` | Client → Server | Initial authentication |
| `AUTH_SUCCESS` | Server → Client | Authentication successful |
| `AUTH_FAILED` | Server → Client | Authentication failed |
| `TOKEN_EXPIRED` | Server → Client | JWT token expired |
| `PING` | Bidirectional | Heartbeat ping |
| `PONG` | Bidirectional | Heartbeat pong |
| `SUBSCRIBE` | Client → Server | Subscribe to channels |
| `UNSUBSCRIBE` | Client → Server | Unsubscribe from channels |
| `SUBSCRIBED` | Server → Client | Subscription confirmed |
| `UNSUBSCRIBED` | Server → Client | Unsubscription confirmed |

### 2. Data Synchronization

| Type | Direction | Description |
|------|-----------|-------------|
| `SYNC_START` | Server → Client | Sync session started |
| `SYNC_UPDATE` | Server → Client | Data entity updated |
| `SYNC_DELETE` | Server → Client | Data entity deleted |
| `SYNC_COMPLETE` | Server → Client | Sync session complete |
| `SYNC_ERROR` | Server → Client | Sync error occurred |

### 3. Business Data

| Type | Direction | Description |
|------|-----------|-------------|
| `KPI_UPDATED` | Server → Client | KPI value changed |
| `DEPARTMENT_UPDATED` | Server → Client | Department data changed |
| `EMPLOYEE_UPDATED` | Server → Client | Employee data changed |
| `REPORT_GENERATED` | Server → Client | Report generation complete |

### 4. Collaboration

| Type | Direction | Description |
|------|-----------|-------------|
| `SESSION_CREATED` | Bidirectional | Collaboration session created |
| `SESSION_JOINED` | Bidirectional | User joined session |
| `SESSION_LEFT` | Bidirectional | User left session |
| `SESSION_ENDED` | Server → Client | Session ended by host |
| `PARTICIPANT_UPDATE` | Server → Client | Participant state changed |
| `ANNOTATION_CREATED` | Bidirectional | Spatial annotation added |
| `ANNOTATION_UPDATED` | Bidirectional | Annotation modified |
| `ANNOTATION_DELETED` | Bidirectional | Annotation removed |
| `CURSOR_MOVE` | Bidirectional | User cursor/focus moved |

### 5. AI & Insights

| Type | Direction | Description |
|------|-----------|-------------|
| `ANOMALY_DETECTED` | Server → Client | AI detected anomaly |
| `RECOMMENDATION` | Server → Client | AI recommendation |
| `PREDICTION_READY` | Server → Client | Prediction completed |

### 6. Notifications

| Type | Direction | Description |
|------|-----------|-------------|
| `NOTIFICATION` | Server → Client | Generic notification |
| `ALERT` | Server → Client | Critical alert |

### 7. Errors

| Type | Direction | Description |
|------|-----------|-------------|
| `ERROR` | Server → Client | Generic error |
| `RATE_LIMIT` | Server → Client | Rate limit exceeded |

---

## Real-time Sync Events

### Channel Subscription

Clients subscribe to channels to receive relevant updates:

**Client → Server**

```json
{
    "type": "SUBSCRIBE",
    "payload": {
        "channels": [
            "organization:550e8400-e29b-41d4-a716-446655440000",
            "department:660e8400-e29b-41d4-a716-446655440001",
            "kpi:770e8400-e29b-41d4-a716-446655440002"
        ]
    }
}
```

**Server → Client**

```json
{
    "type": "SUBSCRIBED",
    "payload": {
        "channels": [
            "organization:550e8400-e29b-41d4-a716-446655440000",
            "department:660e8400-e29b-41d4-a716-446655440001",
            "kpi:770e8400-e29b-41d4-a716-446655440002"
        ]
    }
}
```

### Channel Naming Convention

- **Organization**: `organization:{orgId}`
- **Department**: `department:{deptId}`
- **KPI**: `kpi:{kpiId}`
- **User**: `user:{userId}`
- **Collaboration Session**: `session:{sessionId}`

### Sync Update Event

**Server → Client**

```json
{
    "type": "SYNC_UPDATE",
    "payload": {
        "entityType": "kpi",
        "entityId": "770e8400-e29b-41d4-a716-446655440002",
        "changeType": "updated",
        "data": {
            "id": "770e8400-e29b-41d4-a716-446655440002",
            "name": "Monthly Revenue",
            "value": 1350000.00,
            "target": 1500000.00,
            "updatedAt": "2025-01-20T10:35:00Z"
        },
        "updatedBy": "user-123"
    },
    "timestamp": "2025-01-20T10:35:00Z"
}
```

### Sync Delete Event

**Server → Client**

```json
{
    "type": "SYNC_DELETE",
    "payload": {
        "entityType": "department",
        "entityId": "660e8400-e29b-41d4-a716-446655440001",
        "deletedBy": "user-456",
        "deletedAt": "2025-01-20T10:40:00Z"
    }
}
```

---

## Collaboration Protocol

### Starting a Session

**Client → Server**

```json
{
    "type": "SESSION_CREATE",
    "payload": {
        "title": "Q4 Planning Session",
        "activeSpace": "dashboard",
        "inviteUserIds": ["user-456", "user-789"]
    },
    "requestId": "req-session-create-1"
}
```

**Server → Client**

```json
{
    "type": "SESSION_CREATED",
    "payload": {
        "sessionId": "session-12345",
        "hostId": "user-123",
        "title": "Q4 Planning Session",
        "activeSpace": "dashboard",
        "participants": ["user-123"],
        "createdAt": "2025-01-20T10:45:00Z"
    },
    "requestId": "req-session-create-1"
}
```

### Joining a Session

**Client → Server**

```json
{
    "type": "SESSION_JOIN",
    "payload": {
        "sessionId": "session-12345"
    },
    "requestId": "req-join-1"
}
```

**Server → All Participants**

```json
{
    "type": "SESSION_JOINED",
    "payload": {
        "sessionId": "session-12345",
        "userId": "user-456",
        "userName": "Jane Doe",
        "joinedAt": "2025-01-20T10:46:00Z"
    }
}
```

### Spatial Annotation

**Client → Server**

```json
{
    "type": "ANNOTATION_CREATE",
    "payload": {
        "sessionId": "session-12345",
        "position": {
            "x": 1.5,
            "y": 0.8,
            "z": -2.0
        },
        "content": "This KPI needs attention",
        "contentType": "text"
    },
    "requestId": "req-annotation-1"
}
```

**Server → All Participants**

```json
{
    "type": "ANNOTATION_CREATED",
    "payload": {
        "annotationId": "annot-98765",
        "sessionId": "session-12345",
        "authorId": "user-123",
        "authorName": "John Smith",
        "position": {
            "x": 1.5,
            "y": 0.8,
            "z": -2.0
        },
        "content": "This KPI needs attention",
        "contentType": "text",
        "createdAt": "2025-01-20T10:47:00Z"
    },
    "requestId": "req-annotation-1"
}
```

### Cursor/Focus Tracking

**Client → Server** (sent frequently, every 100ms when moving)

```json
{
    "type": "CURSOR_MOVE",
    "payload": {
        "sessionId": "session-12345",
        "position": {
            "x": 0.5,
            "y": 1.2,
            "z": -1.5
        },
        "focusedEntity": {
            "type": "kpi",
            "id": "kpi-123"
        }
    }
}
```

**Server → Other Participants** (throttled to 10 messages/sec)

```json
{
    "type": "CURSOR_MOVE",
    "payload": {
        "userId": "user-456",
        "position": {
            "x": 0.5,
            "y": 1.2,
            "z": -1.5
        },
        "focusedEntity": {
            "type": "kpi",
            "id": "kpi-123"
        }
    },
    "timestamp": "2025-01-20T10:48:00Z"
}
```

### Leaving a Session

**Client → Server**

```json
{
    "type": "SESSION_LEAVE",
    "payload": {
        "sessionId": "session-12345"
    }
}
```

**Server → All Remaining Participants**

```json
{
    "type": "SESSION_LEFT",
    "payload": {
        "sessionId": "session-12345",
        "userId": "user-456",
        "userName": "Jane Doe",
        "leftAt": "2025-01-20T10:50:00Z"
    }
}
```

---

## Error Handling

### Error Message Format

```json
{
    "type": "ERROR",
    "payload": {
        "code": "ERROR_CODE",
        "message": "Human-readable error message",
        "details": {
            "field": "value"
        }
    },
    "requestId": "req-123",
    "timestamp": "2025-01-20T10:55:00Z"
}
```

### Error Codes

| Code | Description | Action |
|------|-------------|--------|
| `INVALID_MESSAGE_FORMAT` | Message JSON is malformed | Fix message format |
| `AUTHENTICATION_REQUIRED` | Message sent before AUTH | Send AUTH message first |
| `INVALID_TOKEN` | JWT token is invalid | Reauthenticate |
| `TOKEN_EXPIRED` | JWT token expired | Refresh token and reauthenticate |
| `UNAUTHORIZED` | User lacks permission | Check user permissions |
| `INVALID_CHANNEL` | Channel name is invalid | Use correct channel format |
| `SUBSCRIPTION_FAILED` | Failed to subscribe to channel | Retry or check permissions |
| `SESSION_NOT_FOUND` | Collaboration session doesn't exist | Use valid session ID |
| `SESSION_FULL` | Session at max participant limit | Wait or join different session |
| `RATE_LIMIT_EXCEEDED` | Too many messages sent | Slow down message frequency |
| `INTERNAL_SERVER_ERROR` | Unexpected server error | Retry with exponential backoff |

### Example Error Response

```json
{
    "type": "ERROR",
    "payload": {
        "code": "RATE_LIMIT_EXCEEDED",
        "message": "You are sending messages too quickly. Please slow down.",
        "details": {
            "limit": 100,
            "window": "60s",
            "retryAfter": 30
        }
    },
    "timestamp": "2025-01-20T11:00:00Z"
}
```

---

## Heartbeat & Reconnection

### Heartbeat Protocol

**Purpose**: Keep connection alive and detect network failures

**Frequency**: Every 30 seconds

**Client → Server**

```json
{
    "type": "PING",
    "timestamp": "2025-01-20T11:05:00Z"
}
```

**Server → Client**

```json
{
    "type": "PONG",
    "timestamp": "2025-01-20T11:05:00Z"
}
```

**Server → Client** (proactive ping)

```json
{
    "type": "PING",
    "timestamp": "2025-01-20T11:05:30Z"
}
```

**Client → Server**

```json
{
    "type": "PONG",
    "timestamp": "2025-01-20T11:05:30Z"
}
```

### Heartbeat Timeout

- If no `PONG` received within 10 seconds, assume connection dead
- Close WebSocket and attempt reconnection

### Reconnection Strategy

**Exponential Backoff Algorithm**

```javascript
const INITIAL_DELAY = 2000;  // 2 seconds
const MAX_DELAY = 30000;     // 30 seconds
const JITTER = 1000;         // ±1 second randomness

let reconnectAttempt = 0;

function getReconnectDelay() {
    const delay = Math.min(
        INITIAL_DELAY * Math.pow(2, reconnectAttempt),
        MAX_DELAY
    );
    const jitter = Math.random() * JITTER * 2 - JITTER;
    reconnectAttempt++;
    return delay + jitter;
}

function reconnect() {
    const delay = getReconnectDelay();
    setTimeout(() => {
        console.log(`Reconnecting (attempt ${reconnectAttempt})...`);
        connect();
    }, delay);
}
```

**Reconnection Delays**

| Attempt | Delay (approx) |
|---------|----------------|
| 1 | 2s |
| 2 | 4s |
| 3 | 8s |
| 4 | 16s |
| 5+ | 30s |

### Session Resume

After reconnection, the client should:

1. **Reauthenticate** with current JWT token
2. **Resubscribe** to previous channels
3. **Request sync** for missed updates

**Client → Server**

```json
{
    "type": "SYNC_REQUEST",
    "payload": {
        "lastSyncTimestamp": "2025-01-20T11:00:00Z",
        "channels": [
            "organization:550e8400-e29b-41d4-a716-446655440000"
        ]
    }
}
```

**Server → Client**

```json
{
    "type": "SYNC_START",
    "payload": {
        "updateCount": 5,
        "fromTimestamp": "2025-01-20T11:00:00Z"
    }
}
```

(Followed by `SYNC_UPDATE` messages for each missed update)

```json
{
    "type": "SYNC_COMPLETE",
    "payload": {
        "updatesSent": 5,
        "lastSyncTimestamp": "2025-01-20T11:10:00Z"
    }
}
```

---

## Security

### Transport Layer Security

- **TLS 1.3** required for all connections
- **Certificate Validation**: Client must validate server certificate
- **WSS Protocol**: `wss://` (WebSocket Secure)

### Authentication

- **JWT-based**: Bearer token authentication
- **Token Refresh**: Use REST API `/auth/refresh` to obtain new token
- **Token Expiration**: Tokens expire after 1 hour
- **Automatic Reauthentication**: Client handles token refresh transparently

### Authorization

- **Channel-level**: Users can only subscribe to channels they have access to
- **Message Validation**: Server validates all incoming messages
- **Rate Limiting**:
  - **Connection**: Max 10 connections per user
  - **Messages**: Max 100 messages/minute per connection
  - **Cursor Updates**: Throttled to 10/second server-side

### Data Privacy

- **Multi-tenant Isolation**: Users only receive data for their organization
- **End-to-End Validation**: All payloads validated against schemas
- **Sensitive Data**: PII and financial data encrypted in transit

---

## Client Implementation Examples

### Swift (visionOS)

```swift
import Foundation

class WebSocketManager: NSObject, URLSessionWebSocketDelegate {
    private var webSocketTask: URLSessionWebSocketTask?
    private var urlSession: URLSession?
    private let accessToken: String

    init(accessToken: String) {
        self.accessToken = accessToken
        super.init()

        let configuration = URLSessionConfiguration.default
        urlSession = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    }

    func connect() {
        let url = URL(string: "wss://api.businessos.io/v1/ws")!
        webSocketTask = urlSession?.webSocketTask(with: url)
        webSocketTask?.resume()

        // Send authentication
        authenticate()

        // Start receiving messages
        receiveMessage()
    }

    private func authenticate() {
        let authMessage: [String: Any] = [
            "type": "AUTH",
            "payload": [
                "token": accessToken
            ]
        ]

        if let data = try? JSONSerialization.data(withJSONObject: authMessage),
           let jsonString = String(data: data, encoding: .utf8) {
            let message = URLSessionWebSocketTask.Message.string(jsonString)
            webSocketTask?.send(message) { error in
                if let error = error {
                    print("Auth failed: \(error)")
                }
            }
        }
    }

    private func receiveMessage() {
        webSocketTask?.receive { [weak self] result in
            switch result {
            case .success(let message):
                switch message {
                case .string(let text):
                    self?.handleMessage(text)
                case .data(let data):
                    print("Received binary data: \(data)")
                @unknown default:
                    break
                }

                // Continue receiving
                self?.receiveMessage()

            case .failure(let error):
                print("Receive failed: \(error)")
                self?.reconnect()
            }
        }
    }

    private func handleMessage(_ text: String) {
        guard let data = text.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let type = json["type"] as? String else {
            return
        }

        switch type {
        case "AUTH_SUCCESS":
            print("Authenticated successfully")
            subscribe(toChannels: ["organization:123"])

        case "KPI_UPDATED":
            if let payload = json["payload"] as? [String: Any] {
                print("KPI updated: \(payload)")
            }

        case "PING":
            sendPong()

        default:
            print("Unknown message type: \(type)")
        }
    }

    private func subscribe(toChannels channels: [String]) {
        let message: [String: Any] = [
            "type": "SUBSCRIBE",
            "payload": [
                "channels": channels
            ]
        ]

        send(message: message)
    }

    private func sendPong() {
        let message: [String: Any] = [
            "type": "PONG",
            "timestamp": ISO8601DateFormatter().string(from: Date())
        ]

        send(message: message)
    }

    private func send(message: [String: Any]) {
        if let data = try? JSONSerialization.data(withJSONObject: message),
           let jsonString = String(data: data, encoding: .utf8) {
            let wsMessage = URLSessionWebSocketTask.Message.string(jsonString)
            webSocketTask?.send(wsMessage) { error in
                if let error = error {
                    print("Send failed: \(error)")
                }
            }
        }
    }

    private func reconnect() {
        // Implement exponential backoff
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.connect()
        }
    }

    func disconnect() {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
    }
}
```

### Usage

```swift
let wsManager = WebSocketManager(accessToken: "your-jwt-token")
wsManager.connect()
```

---

## Best Practices

### Client-Side

1. **Heartbeat**: Implement both client → server and server → client heartbeat
2. **Reconnection**: Use exponential backoff with jitter
3. **State Management**: Track connection state machine
4. **Message Queue**: Queue messages during reconnection, send after AUTH_SUCCESS
5. **Throttling**: Limit cursor update frequency (max 10/sec)
6. **Error Handling**: Handle all error codes gracefully
7. **Token Refresh**: Refresh JWT proactively before expiration

### Server-Side

1. **Horizontal Scaling**: Use Redis pub/sub for multi-instance deployments
2. **Rate Limiting**: Implement per-connection and per-user limits
3. **Message Validation**: Validate all incoming messages against schemas
4. **Channel Authorization**: Verify user access before subscribing
5. **Graceful Shutdown**: Send CLOSE frame before shutdown
6. **Monitoring**: Track connection count, message throughput, error rates
7. **Load Balancing**: Use sticky sessions or shared state for reconnections

---

## Appendix: Full Message Type Reference

### Complete Message Type Catalog

```typescript
// Connection Management
'AUTH'
'AUTH_SUCCESS'
'AUTH_FAILED'
'TOKEN_EXPIRED'
'PING'
'PONG'
'SUBSCRIBE'
'UNSUBSCRIBE'
'SUBSCRIBED'
'UNSUBSCRIBED'

// Data Sync
'SYNC_START'
'SYNC_UPDATE'
'SYNC_DELETE'
'SYNC_COMPLETE'
'SYNC_ERROR'
'SYNC_REQUEST'

// Business Data
'KPI_UPDATED'
'DEPARTMENT_UPDATED'
'EMPLOYEE_UPDATED'
'REPORT_GENERATED'

// Collaboration
'SESSION_CREATE'
'SESSION_CREATED'
'SESSION_JOIN'
'SESSION_JOINED'
'SESSION_LEAVE'
'SESSION_LEFT'
'SESSION_ENDED'
'PARTICIPANT_UPDATE'
'ANNOTATION_CREATE'
'ANNOTATION_CREATED'
'ANNOTATION_UPDATE'
'ANNOTATION_UPDATED'
'ANNOTATION_DELETE'
'ANNOTATION_DELETED'
'CURSOR_MOVE'

// AI & Insights
'ANOMALY_DETECTED'
'RECOMMENDATION'
'PREDICTION_READY'

// Notifications
'NOTIFICATION'
'ALERT'

// Errors
'ERROR'
'RATE_LIMIT'
```

---

**End of WebSocket Protocol Documentation**
