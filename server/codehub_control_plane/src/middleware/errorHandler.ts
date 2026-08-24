import { FastifyRequest, FastifyReply } from 'fastify';

export async function rateLimiter(request: FastifyRequest, reply: FastifyReply) {
  // Rate limiting hook placeholder
}

export function errorHandler(error: any, request: FastifyRequest, reply: FastifyReply) {
  console.error('[Global Error Handler]:', error);
  reply.status(error.statusCode || 500).send({
    success: false,
    message: error.message || 'Internal Server Error',
  });
}
