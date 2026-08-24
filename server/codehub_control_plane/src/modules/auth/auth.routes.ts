import { FastifyInstance } from 'fastify';
import { registerUser, validateUser } from './auth.service.js';

export async function authRoutes(fastify: FastifyInstance) {
  fastify.post('/api/v1/auth/register', async (request, reply) => {
    const { username, email, password } = request.body as any;
    if (!username) {
      return reply.status(400).send({ success: false, message: 'Username required' });
    }

    const user = await registerUser(username, email, password);
    const accessToken = fastify.jwt.sign({ id: user.id, username: user.username }, { expiresIn: '15m' });
    const refreshToken = fastify.jwt.sign({ id: user.id, username: user.username, type: 'refresh' }, { expiresIn: '7d' });

    return reply.status(201).send({
      success: true,
      message: `User '${username}' registered`,
      data: { user, access_token: accessToken, refresh_token: refreshToken, token_type: 'Bearer' },
    });
  });

  fastify.post('/api/v1/auth/login', async (request, reply) => {
    const { username, password } = request.body as any;
    if (!username) {
      return reply.status(400).send({ success: false, message: 'Username required' });
    }

    const user = await validateUser(username, password);
    const accessToken = fastify.jwt.sign({ id: user.id, username: user.username }, { expiresIn: '15m' });
    const refreshToken = fastify.jwt.sign({ id: user.id, username: user.username, type: 'refresh' }, { expiresIn: '7d' });

    return reply.send({
      success: true,
      message: 'Authentication successful',
      data: { user, access_token: accessToken, refresh_token: refreshToken, token_type: 'Bearer' },
    });
  });

  fastify.post('/api/v1/auth/refresh', async (request, reply) => {
    const { refresh_token } = request.body as any;
    if (!refresh_token) {
      return reply.status(400).send({ success: false, message: 'Refresh token required' });
    }

    try {
      const decoded: any = fastify.jwt.verify(refresh_token);
      const newAccessToken = fastify.jwt.sign({ id: decoded.id, username: decoded.username }, { expiresIn: '15m' });
      return reply.send({ success: true, data: { access_token: newAccessToken, token_type: 'Bearer' } });
    } catch (err) {
      return reply.status(401).send({ success: false, message: 'Invalid or expired refresh token' });
    }
  });
}
