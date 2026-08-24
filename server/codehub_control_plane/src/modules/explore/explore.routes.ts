import { FastifyInstance } from 'fastify';

export async function exploreRoutes(fastify: FastifyInstance) {
  fastify.get('/api/v1/search', async (request, reply) => {
    const { q } = request.query as any;
    const queryTerm = (q || '').toLowerCase();

    return reply.send({
      success: true,
      query: q,
      results: [
        { id: 'repo_101', name: 'codehub-core-p2p', type: 'repository', relevance: 0.98 },
        { id: 'repo_102', name: 'flutter-torrent-ui', type: 'repository', relevance: 0.89 },
      ].filter((r) => r.name.includes(queryTerm)),
    });
  });
}
