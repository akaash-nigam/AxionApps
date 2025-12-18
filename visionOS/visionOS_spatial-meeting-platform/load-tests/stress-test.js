import http from 'k6/http';
import { check, sleep } from 'k6';
import { Counter, Rate, Trend } from 'k6/metrics';

const errorRate = new Rate('errors');
const requestDuration = new Trend('request_duration');
const successfulRequests = new Counter('successful_requests');

export const options = {
  stages: [
    { duration: '2m', target: 100 },   // Ramp to 100 users
    { duration: '5m', target: 100 },   // Stay at 100 users
    { duration: '2m', target: 200 },   // Spike to 200 users
    { duration: '3m', target: 200 },   // Stay at peak
    { duration: '2m', target: 50 },    // Recover
    { duration: '3m', target: 50 },    // Recovery period
    { duration: '2m', target: 0 },     // Ramp down
  ],
  thresholds: {
    http_req_duration: ['p(99)<5000'],  // 99% under 5s (stress conditions)
    http_req_failed: ['rate<0.2'],      // Accept up to 20% errors during stress
    errors: ['rate<0.2'],
  },
};

const BASE_URL = __ENV.API_URL || 'http://localhost:3000/api';

export default function () {
  const startTime = Date.now();

  // Register
  const registerPayload = JSON.stringify({
    email: `stress${__VU}_${Date.now()}@example.com`,
    username: `stress${__VU}_${Date.now()}`,
    password: 'password123',
    display_name: `Stress Test ${__VU}`,
  });

  let registerRes = http.post(`${BASE_URL}/auth/register`, registerPayload, {
    headers: { 'Content-Type': 'application/json' },
    timeout: '10s',
  });

  const registrationTime = Date.now() - startTime;
  requestDuration.add(registrationTime);

  let success = check(registerRes, {
    'registration status ok': (r) => r.status === 201 || r.status === 409,
  });

  if (!success) {
    errorRate.add(1);
    console.error(`Registration failed: ${registerRes.status}`);
    return;
  }

  if (registerRes.status === 409) {
    // User exists, try to login instead
    return;
  }

  const token = JSON.parse(registerRes.body).token;
  successfulRequests.add(1);

  sleep(0.5);

  // Create multiple meetings rapidly
  for (let i = 0; i < 3; i++) {
    const meetingPayload = JSON.stringify({
      title: `Stress Meeting ${__VU}-${i}`,
      environment_type: 'conference_room',
      layout_type: 'circle',
    });

    let meetingRes = http.post(`${BASE_URL}/meetings`, meetingPayload, {
      headers: {
        'Content-Type': 'application/json',
        Authorization: `Bearer ${token}`,
      },
      timeout: '10s',
    });

    success = check(meetingRes, {
      'meeting created or limited': (r) => r.status === 201 || r.status === 429,
    });

    if (success && meetingRes.status === 201) {
      successfulRequests.add(1);
    } else {
      errorRate.add(1);
    }

    sleep(0.3);
  }

  // Get meetings list
  let getMeetingsRes = http.get(`${BASE_URL}/meetings?limit=100`, {
    headers: { Authorization: `Bearer ${token}` },
    timeout: '10s',
  });

  success = check(getMeetingsRes, {
    'get meetings ok': (r) => r.status === 200 || r.status === 429,
  });

  if (success && getMeetingsRes.status === 200) {
    successfulRequests.add(1);
  } else {
    errorRate.add(1);
  }

  sleep(1);
}

export function handleSummary(data) {
  return {
    'stress-test-summary.json': JSON.stringify(data),
    stdout: `
Stress Test Summary
===================
VUs: ${data.metrics.vus.values.max}
Requests: ${data.metrics.http_reqs.values.count}
Success Rate: ${((1 - data.metrics.errors.values.rate) * 100).toFixed(2)}%
Avg Response Time: ${data.metrics.http_req_duration.values.avg.toFixed(2)}ms
P95 Response Time: ${data.metrics.http_req_duration.values['p(95)'].toFixed(2)}ms
P99 Response Time: ${data.metrics.http_req_duration.values['p(99)'].toFixed(2)}ms
    `,
  };
}
