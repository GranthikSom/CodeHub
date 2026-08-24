import { FastifyInstance } from 'fastify';
import { publishEvent } from '../../events/eventBus.js';
import { getIO } from '../../realtime/socket.js';

export async function pullRequestRoutes(fastify: FastifyInstance) {
  fastify.get('/api/v1/repositories/:id/pulls', async (request, reply) => {
    const { id } = request.params as any;
    return reply.send({
      success: true,
      repository_id: id,
      data: [
        { pr_number: 24, title: 'feat: add interactive DAG node graph view', author: 'SohamMondal', source_branch: 'feat/dag-view', target_branch: 'main', status: 'OPEN' },
      ],
    });
  });

  fastify.post('/api/v1/repositories/:id/pulls', async (request, reply) => {
    const { id } = request.params as any;
    const body = request.body as any;

    const newPR = {
      pr_number: Math.floor(Math.random() * 90) + 20,
      repository_id: id,
      title: body.title || 'New Pull Request',
      author: body.author || 'SohamMondal',
      source_branch: body.source_branch || 'feature',
      target_branch: body.target_branch || 'main',
      status: 'OPEN',
      created_at: new Date().toISOString(),
    };

    const eventPayload = { event: 'pr_created', type: 'pr.created', timestamp: Math.floor(Date.now() / 1000), pull_request: newPR };

    publishEvent('swarm.events', eventPayload);
    try {
      getIO().emit('pr.created', eventPayload);
    } catch (e) {}

    return reply.status(201).send({ success: true, message: 'Pull Request created successfully', data: newPR });
  });
}
