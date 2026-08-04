import { check } from 'k6';
import http from 'k6/http';
import { Rate, Trend } from 'k6/metrics';

export const usuariosCrudDuration = new Trend('usuarios_crud_duration');
export const usuariosCrudSuccess = new Rate('usuarios_crud_success');

const requestParams = {
  headers: {
    'Content-Type': 'application/json',
  },
};

export function runUserCrudFlow(baseUrl) {
  const startedAt = Date.now();
  const uniqueValue = `${__VU}-${__ITER}-${Date.now()}`;
  const userPayload = JSON.stringify({
    nome: `Usuario k6 ${uniqueValue}`,
    dtNascimento: '1992-03-14',
    status: true,
    telefones: [`119${String(__VU).padStart(4, '0')}${String(__ITER).padStart(4, '0')}`],
  });

  const createResponse = http.post(`${baseUrl}/usuarios`, userPayload, requestParams);
  const createdUser = createResponse.status === 201 ? createResponse.json() : null;
  const userId = createdUser?.id;

  let flowSucceeded = check(createResponse, {
    'create user returns 201': (response) => response.status === 201,
    'create user returns an id': () => Number.isInteger(userId) && userId > 0,
  });

  if (userId) {
    const getResponse = http.get(`${baseUrl}/usuarios/${userId}`);
    const updateResponse = http.put(
      `${baseUrl}/usuarios/${userId}`,
      JSON.stringify({
        nome: `Usuario k6 atualizado ${uniqueValue}`,
        dtNascimento: '1992-03-14',
        status: false,
        telefones: ['11900001111'],
      }),
      requestParams,
    );
    const deleteResponse = http.del(`${baseUrl}/usuarios/${userId}`);

    flowSucceeded = check(getResponse, {
      'get user returns 200': (response) => response.status === 200,
    }) && flowSucceeded;
    flowSucceeded = check(updateResponse, {
      'update user returns 200': (response) => response.status === 200,
    }) && flowSucceeded;
    flowSucceeded = check(deleteResponse, {
      'delete user returns 204': (response) => response.status === 204,
    }) && flowSucceeded;
  }

  usuariosCrudDuration.add(Date.now() - startedAt);
  usuariosCrudSuccess.add(flowSucceeded);
}
