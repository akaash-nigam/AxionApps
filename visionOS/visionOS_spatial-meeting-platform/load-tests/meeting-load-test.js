import http from 'k6/http';
import { check, sleep } from 'k6';
import { Counter, Rate, Trend } from 'k6/metrics';

const errorRate = new Rate('errors');
const meetingCreations = new Counter('meeting_creations');
const meetingJoins = new Counter('meeting_joins');
const participantCount = new Trend('participant_count');

export const options = {
  scenarios: {
    // Simulate concurrent meeting creation
    meeting_creation: {
      executor: 'ramping-vus',
      startVUs: 0,
      stages: [
        { duration: '1m', target: 10 },
        { duration: '2m', target: 10 },
        { duration: '30s', target: 0 },
      ],
      gracefulRampDown: '10s',
    },
    // Simulate users joining existing meetings
    meeting_joining: {
      executor: 'ramping-vus',
      startVUs: 0,
      stages: [
        { duration: '30s', target: 0 },  // Wait for meetings to be created
        { duration: '1m', target: 30 },
        { duration: '2m', target: 50 },   // Peak: 50 concurrent users
        { duration: '30s', target: 0 },
      ],
      gracefulRampDown: '10s',
    },
  },
  thresholds: {
    http_req_duration: ['p(95)<1000'],  // 95% under 1s
    http_req_failed: ['rate<0.05'],      // Less than 5% errors
    errors: ['rate<0.05'],
  },
};

const BASE_URL = __ENV.API_URL || 'http://localhost:3000/api';
let sharedMeetingIds = [];

function registerAndLogin() {
  const email = `loadtest${__VU}_${Date.now()}@example.com`;
  const registerPayload = JSON.stringify({
    email: email,
    username: `loadtest${__VU}_${Date.now()}`,
    password: 'testpass123',
    display_name: `Load Test User ${__VU}`,
  });

  let res = http.post(`${BASE_URL}/auth/register`, registerPayload, {
    headers: { 'Content-Type': 'application/json' },
  });

  if (res.status !== 201) {
    console.error(`Registration failed: ${res.status}`);
    return null;
  }

  return JSON.parse(res.body).token;
}

export function setup() {
  // Create some initial meetings
  const meetings = [];
  for (let i = 0; i < 5; i++) {
    const token = registerAndLogin();
    if (!token) continue;

    const meetingPayload = JSON.stringify({
      title: `Initial Meeting ${i + 1}`,
      environment_type: 'conference_room',
      layout_type: ['circle', 'theater', 'u_shape'][i % 3],
      max_participants: 50,
    });

    let res = http.post(`${BASE_URL}/meetings`, meetingPayload, {
      headers: {
        'Content-Type': 'application/json',
        Authorization: `Bearer ${token}`,
      },
    });

    if (res.status === 201) {
      meetings.push(JSON.parse(res.body).id);
    }
  }

  return { meetingIds: meetings };
}

export default function (data) {
  const token = registerAndLogin();
  if (!token) return;

  const scenarioName = __ENV.SCENARIO || 'meeting_creation';

  if (scenarioName === 'meeting_creation') {
    // Create new meeting
    const meetingPayload = JSON.stringify({
      title: `Meeting VU${__VU} Iter${__ITER}`,
      description: 'Load test meeting',
      environment_type: ['conference_room', 'theater', 'outdoor'][__VU % 3],
      layout_type: ['circle', 'theater', 'u_shape', 'classroom'][__VU % 4],
      max_participants: 50,
    });

    let res = http.post(`${BASE_URL}/meetings`, meetingPayload, {
      headers: {
        'Content-Type': 'application/json',
        Authorization: `Bearer ${token}`,
      },
    });

    let success = check(res, {
      'meeting created': (r) => r.status === 201,
    });

    if (success) {
      meetingCreations.add(1);
    } else {
      errorRate.add(1);
    }

    sleep(3);
  } else {
    // Join existing meeting
    if (data.meetingIds && data.meetingIds.length > 0) {
      const meetingId = data.meetingIds[__VU % data.meetingIds.length];

      let joinRes = http.post(`${BASE_URL}/meetings/${meetingId}/join`,
        JSON.stringify({ role: 'participant' }),
        {
          headers: {
            'Content-Type': 'application/json',
            Authorization: `Bearer ${token}`,
          },
        }
      );

      let success = check(joinRes, {
        'joined meeting': (r) => r.status === 201,
      });

      if (success) {
        meetingJoins.add(1);

        // Get participants count
        let participantsRes = http.get(`${BASE_URL}/meetings/${meetingId}/participants`, {
          headers: { Authorization: `Bearer ${token}` },
        });

        if (participantsRes.status === 200) {
          const participants = JSON.parse(participantsRes.body);
          participantCount.add(participants.length);
        }
      } else {
        errorRate.add(1);
      }

      sleep(5);

      // Leave meeting
      http.post(`${BASE_URL}/meetings/${meetingId}/leave`, null, {
        headers: { Authorization: `Bearer ${token}` },
      });
    }

    sleep(2);
  }
}

export function teardown(data) {
  console.log('Load test completed');
  console.log(`Created meetings: ${meetingCreations.value}`);
  console.log(`Meeting joins: ${meetingJoins.value}`);
}
