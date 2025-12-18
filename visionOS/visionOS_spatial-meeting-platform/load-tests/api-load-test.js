import http from 'k6/http';
import { check, sleep } from 'k6';
import { Rate } from 'k6/metrics';

const errorRate = new Rate('errors');

export const options = {
  stages: [
    { duration: '30s', target: 20 },  // Ramp up to 20 users
    { duration: '1m', target: 50 },   // Ramp up to 50 users
    { duration: '2m', target: 50 },   // Stay at 50 users
    { duration: '30s', target: 0 },   // Ramp down
  ],
  thresholds: {
    http_req_duration: ['p(95)<500'], // 95% of requests should be below 500ms
    http_req_failed: ['rate<0.1'],     // Error rate should be below 10%
    errors: ['rate<0.1'],               // Custom error rate
  },
};

const BASE_URL = __ENV.API_URL || 'http://localhost:3000/api';

export default function () {
  // Test user registration
  const registerPayload = JSON.stringify({
    email: `user${__VU}_${Date.now()}@example.com`,
    username: `user${__VU}_${Date.now()}`,
    password: 'password123456',
    display_name: `Test User ${__VU}`,
  });

  let registerRes = http.post(`${BASE_URL}/auth/register`, registerPayload, {
    headers: { 'Content-Type': 'application/json' },
  });

  let success = check(registerRes, {
    'registration successful': (r) => r.status === 201,
    'has token': (r) => JSON.parse(r.body).token !== undefined,
  });

  errorRate.add(!success);

  if (!success) {
    console.error(`Registration failed: ${registerRes.status} ${registerRes.body}`);
    return;
  }

  const token = JSON.parse(registerRes.body).token;

  sleep(1);

  // Test meeting creation
  const meetingPayload = JSON.stringify({
    title: `Test Meeting ${__VU}`,
    description: 'Load test meeting',
    environment_type: 'conference_room',
    layout_type: 'circle',
    max_participants: 50,
  });

  let meetingRes = http.post(`${BASE_URL}/meetings`, meetingPayload, {
    headers: {
      'Content-Type': 'application/json',
      Authorization: `Bearer ${token}`,
    },
  });

  success = check(meetingRes, {
    'meeting created': (r) => r.status === 201,
    'has meeting id': (r) => JSON.parse(r.body).id !== undefined,
  });

  errorRate.add(!success);

  sleep(1);

  // Test getting meetings
  let getMeetingsRes = http.get(`${BASE_URL}/meetings`, {
    headers: { Authorization: `Bearer ${token}` },
  });

  success = check(getMeetingsRes, {
    'get meetings successful': (r) => r.status === 200,
    'has meetings array': (r) => JSON.parse(r.body).meetings !== undefined,
  });

  errorRate.add(!success);

  sleep(1);

  // Test profile retrieval
  let profileRes = http.get(`${BASE_URL}/auth/profile`, {
    headers: { Authorization: `Bearer ${token}` },
  });

  success = check(profileRes, {
    'profile retrieved': (r) => r.status === 200,
    'has user data': (r) => JSON.parse(r.body).email !== undefined,
  });

  errorRate.add(!success);

  sleep(2);
}
