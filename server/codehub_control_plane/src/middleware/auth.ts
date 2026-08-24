import { FastifyRequest, FastifyReply } from 'fastify';

export async function authenticateToken(request: FastifyRequest, reply: FastifyReply) {
  try {
    await request.jwtVerify();
  } catch (err) {
    reply.status(401).send({ success: false, message: 'Unauthorized: Invalid access token' });
  }
}
