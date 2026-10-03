import { FastifyInstance } from 'fastify';

export async function exploreRoutes(fastify: FastifyInstance) {
  fastify.get('/api/v1/search', async (request, reply) => {
    const { q } = request.query as any;
    const queryTerm = (q || '').toLowerCase();

    return reply.send({
      success: true,
      query: q,
      results: [],
    });
  });
}
