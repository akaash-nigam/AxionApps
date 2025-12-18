import { check } from 'k6';
import ws from 'k6/ws';
import { Counter, Rate } from 'k6/metrics';
import http from 'k6/http';

const wsConnections = new Counter('ws_connections');
const wsMessages = new Counter('ws_messages');
const wsErrors = new Rate('ws_errors');

export const options = {
  stages: [
    { duration: '30s', target: 10 },  // Start with 10 connections
    { duration: '1m', target: 30 },   // Ramp to 30
    { duration: '1m', target: 50 },   // Ramp to 50
    { duration: '30s', target: 0 },   // Ramp down
  ],
  thresholds: {
    ws_connecting: ['p(95)<1000'],     // Connection time under 1s
    ws_messages: ['count>100'],         // Minimum messages exchanged
    ws_errors: ['rate<0.1'],            // Less than 10% errors
  },
};

const BASE_URL = __ENV.API_URL || 'http://localhost:3000/api';
const WS_URL = __ENV.WS_URL || 'ws://localhost:3001';

function getAuthToken() {
  const registerPayload = JSON.stringify({
    email: `wstest${__VU}_${Date.now()}@example.com`,
    username: `wstest${__VU}_${Date.now()}`,
    password: 'testpass123',
    display_name: `WS Test User ${__VU}`,
  });

  let res = http.post(`${BASE_URL}/auth/register`, registerPayload, {
    headers: { 'Content-Type': 'application/json' },
  });

  if (res.status === 201) {
    return JSON.parse(res.body).token;
  }
  return null;
}

function createMeeting(token) {
  const meetingPayload = JSON.stringify({
    title: `WebSocket Test Meeting ${__VU}`,
    environment_type: 'conference_room',
    layout_type: 'circle',
  });

  let res = http.post(`${BASE_URL}/meetings`, meetingPayload, {
    headers: {
      'Content-Type': 'application/json',
      Authorization: `Bearer ${token}`,
    },
  });

  if (res.status === 201) {
    return JSON.parse(res.body).id;
  }
  return null;
}

export default function () {
  const token = getAuthToken();
  if (!token) {
    wsErrors.add(1);
    return;
  }

  const meetingId = createMeeting(token);
  if (!meetingId) {
    wsErrors.add(1);
    return;
  }

  const url = `${WS_URL}?token=${token}`;

  const res = ws.connect(url, {}, function (socket) {
    wsConnections.add(1);

    socket.on('open', () => {
      console.log(`VU ${__VU}: WebSocket connected`);

      // Join meeting
      socket.send(JSON.stringify({
        type: 'join_meeting',
        payload: { meetingId: meetingId },
        timestamp: Date.now(),
      }));
      wsMessages.add(1);

      // Send position updates
      let updateCount = 0;
      const interval = setInterval(() => {
        if (updateCount >= 10) {
          clearInterval(interval);
          socket.close();
          return;
        }

        socket.send(JSON.stringify({
          type: 'participant_position',
          payload: {
            x: Math.random() * 6 - 3,
            y: 0,
            z: Math.random() * 6 - 3,
            rotX: 0,
            rotY: Math.random() * 360,
            rotZ: 0,
          },
          timestamp: Date.now(),
        }));
        wsMessages.add(1);
        updateCount++;
      }, 1000);

      // Send audio state updates
      setTimeout(() => {
        socket.send(JSON.stringify({
          type: 'audio_state',
          payload: { is_muted: Math.random() > 0.5 },
          timestamp: Date.now(),
        }));
        wsMessages.add(1);
      }, 2000);
    });

    socket.on('message', (data) => {
      const message = JSON.parse(data);

      check(message, {
        'has valid type': (m) => m.type !== undefined,
        'has timestamp': (m) => m.timestamp !== undefined,
      });

      if (message.type === 'error') {
        console.error(`WS Error: ${message.payload.message}`);
        wsErrors.add(1);
      }
    });

    socket.on('error', (e) => {
      console.error(`WebSocket error: ${e}`);
      wsErrors.add(1);
    });

    socket.on('close', () => {
      console.log(`VU ${__VU}: WebSocket closed`);
    });

    socket.setTimeout(() => {
      console.log(`VU ${__VU}: Timeout - closing connection`);
      socket.close();
    }, 30000); // 30 second timeout
  });

  check(res, {
    'WebSocket connection successful': (r) => r && r.status === 101,
  });
}
