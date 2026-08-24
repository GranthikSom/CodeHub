import { FastifyInstance } from 'fastify';
import { publishEvent } from '../../events/eventBus.js';
import { getIO } from '../../realtime/socket.js';

export async function issueRoutes(fastify: FastifyInstance) {
  fastify.get('/api/v1/repositories/:id/issues', async (request, reply) => {
    const { id } = request.params as any;
    return reply.send({
      success: true,
      repository_id: id,
      data: [
        { issue_number: 1, title: 'Implement DHT delta replication strategy', author: 'GranthikSom', status: 'OPEN', labels: ['enhancement'], assignees: ['SohamMondal'], created_at: '2026-08-22T14:30:00Z' },
      ],
    });
  });

  fastify.post('/api/v1/repositories/:id/issues', async (request, reply) => {
    const { id } = request.params as any;
    const body = request.body as any;

    const newIssue = {
      issue_number: Math.floor(Math.random() * 90) + 10,
      repository_id: id,
      title: body.title || 'New Swarm Issue',
      body: body.body || '',
      author: body.author || 'GranthikSom',
      status: 'OPEN',
      labels: body.labels || ['bug'],
      assignees: body.assignees || [],
      created_at: new Date().toISOString(),
    };

    const eventPayload = { event: 'issue_created', type: 'issue.created', timestamp: Math.floor(Date.now() / 1000), issue: newIssue };

    publishEvent('swarm.events', eventPayload);
    try {
      getIO().emit('issue.created', eventPayload);
    } catch (e) {}

    return reply.status(201).send({ success: true, message: 'Issue created successfully', data: newIssue });
  });
}
