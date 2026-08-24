import { FastifyInstance } from 'fastify';
import { Server } from 'socket.io';
import { publishEvent } from '../services/redis.js';

export async function issueAndPullRoutes(fastify: FastifyInstance, io: Server) {
  // REST: Fetch Issues
  fastify.get('/api/v1/repositories/:id/issues', async (request, reply) => {
    const { id } = request.params as any;
    return reply.send({
      success: true,
      repository_id: id,
      data: [
        {
          issue_number: 1,
          title: 'Implement DHT delta replication strategy',
          author: 'GranthikSom',
          status: 'OPEN',
          labels: ['enhancement', 'p2p'],
          assignees: ['SohamMondal'],
          created_at: '2026-08-22T14:30:00Z',
        },
      ],
    });
  });

  // REST: Create Issue -> Triggers Socket.IO Event `issue.created`
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

    const eventPayload = {
      event: 'issue_created',
      type: 'issue.created',
      timestamp: Math.floor(Date.now() / 1000),
      issue: newIssue,
    };

    await publishEvent('swarm.events', eventPayload);
    io.emit('issue.created', eventPayload);
    io.emit('issue_created', eventPayload);

    return reply.status(201).send({
      success: true,
      message: 'Issue created successfully',
      data: newIssue,
    });
  });

  // REST: Fetch Pull Requests
  fastify.get('/api/v1/repositories/:id/pulls', async (request, reply) => {
    const { id } = request.params as any;
    return reply.send({
      success: true,
      repository_id: id,
      data: [
        {
          pr_number: 24,
          title: 'feat: add interactive DAG node graph view',
          author: 'SohamMondal',
          source_branch: 'feat/dag-view',
          target_branch: 'main',
          status: 'OPEN',
        },
      ],
    });
  });

  // REST: Create Pull Request -> Triggers Socket.IO Event `pr.created`
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

    const eventPayload = {
      event: 'pr_created',
      type: 'pr.created',
      timestamp: Math.floor(Date.now() / 1000),
      pull_request: newPR,
    };

    await publishEvent('swarm.events', eventPayload);
    io.emit('pr.created', eventPayload);
    io.emit('pr_created', eventPayload);

    return reply.status(201).send({
      success: true,
      message: 'Pull Request created successfully',
      data: newPR,
    });
  });
}
