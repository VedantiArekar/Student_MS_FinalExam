
import http from 'k6/http';
import { check, sleep } from 'k6';

export const options = {
  stages: [
    { duration: '20s', target: 100 },
    { duration: '20s', target: 300 },
    { duration: '20s', target: 500 },
    { duration: '60s', target: 500 },
    { duration: '20s', target: 0 },
  ],

  thresholds: {
    http_req_failed: ['rate<0.05'],
    http_req_duration: ['p(95)<2000'],
    checks: ['rate>0.95'],
  },
};

export default function () {
  const response = http.get('http://127.0.0.1:8080/', {
    headers: {
      Host: 'student-ms.test',
    },
  });

  check(response, {
    'Application returns HTTP 200': (r) => r.status === 200,
  });

  sleep(0.2);
}
