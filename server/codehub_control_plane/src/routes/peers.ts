import { FastifyInstance } from 'fastify';
import { Server } from 'socket.io';
import { publishEvent } from '../services/redis.js';

export async function peerTelemetryRoutes(fastify: FastifyInstance, io: Server) {
  // REST: Get Active Swarm Peers
  fastify.get('/api/v1/swarm/peers', async (request, reply) => {
    return reply.send({
      success: true,
      total_peers: 14,
      peers: [
        { peer_id: '12D3KooWControlRelayServer', status: 'online', addr: '10.0.0.1:4001' },
        { peer_id: '12D3KooWPeerNode8831y99', status: 'online', addr: '192.168.1.15:4001' },
      ],
    });
  });

  // REST: Peer Heartbeat Ping -> Triggers Socket.IO Event `peer.online` / `peer.offline`
  fastify.post('/api/v1/swarm/peers/heartbeat', async (request, reply) => {
    const { peer_id, status } = request.body as any;

    const eventName = status === 'offline' ? 'peer.offline' : 'peer.online';
    const eventPayload = {
      event: eventName,
      type: eventName,
      timestamp: Math.floor(Date.now() / 1000),
      peer: {
        peer_id: peer_id || '12D3KooWPeerNode8831y99',
        status: status || 'online',
        last_seen: new Date().toISOString(),
      },
    };

    await publishEvent('swarm.events', eventPayload);
    io.emit(eventName, eventPayload);

    return reply.send({ success: true, data: eventPayload });
  });

  // REST: Trigger Replication Event -> Emits Socket.IO `replication.updated` & `transfer.progress`
  fastify.post('/api/v1/swarm/replication/trigger', async (request, reply) => {
    const { repository_id, bytes_transferred, progress_percent } = request.body as any;

    const progressEvent = {
      event: 'transfer.progress',
      type: 'transfer.progress',
      timestamp: Math.floor(Date.now() / 1000),
      repository_id: repository_id || 'repo_101',
      bytes_transferred: bytes_transferred || 42100000,
      progress_percent: progress_percent || 100.0,
    };

    const replicationEvent = {
      event: 'replication.updated',
      type: 'replication.updated',
      timestamp: Math.floor(Date.now() / 1000),
      repository_id: repository_id || 'repo_101',
      replica_count: 9,
      status: 'synced',
    };

    await publishEvent('swarm.events', progressEvent);
    await publishEvent('swarm.events', replicationEvent);

    io.emit('transfer.progress', progressEvent);
    io.emit('replication.updated', replicationEvent);

    return reply.send({ success: true, data: { progressEvent, replicationEvent } });
  });
}
