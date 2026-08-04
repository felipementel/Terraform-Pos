import { check, group, sleep } from 'k6';
import http from 'k6/http';
import { runUserCrudFlow } from './scenarios/usuarios-crud.js';

const baseUrl = (__ENV.BASE_URL || 'http://localhost:5266').replace(/\/$/, '');

export const options = {
  stages: [
    { duration: '15s', target: 5 },
    { duration: '30s', target: 10 },
    { duration: '15s', target: 0 },
  ],
  thresholds: {
    checks: ['rate>0.99'],
    http_req_failed: ['rate<0.01'],
    http_req_duration: ['p(95)<500'],
    usuarios_crud_duration: ['p(95)<750'],
    usuarios_crud_success: ['rate>0.99'],
  },
};

export default function runLoadTest() {
  group('Health', () => {
    const response = http.get(`${baseUrl}/health/ready`);
    check(response, {
      'health ready returns 200': (item) => item.status === 200,
    });
  });

  group('Usuarios CRUD', () => {
    runUserCrudFlow(baseUrl);
  });

  sleep(1);
};
