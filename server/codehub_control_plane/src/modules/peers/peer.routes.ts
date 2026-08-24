import { FastifyInstance } from 'fastify';
import { emitPeerOnline, emitPeerOffline } from '../../events/peer.events.js';
import { getIO } from '../../realtime/socket.js';

export async function peerRoutes(fastify: FastifyInstance) {
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

  fastify.post('/api/v1/swarm/peers/heartbeat', async (request, reply) => {
    const { peer_id, status } = request.body as any;
    let event: any;

    if (status === 'offline') {
      event = emitPeerOffline(peer_id || '12D3KooWPeerNode8831y99');
      try {
        getIO().emit('peer.offline', event);
      } catch (e) {}
    } else {
      event = emitPeerOnline({ peer_id: peer_id || '12D3KooWPeerNode8831y99', status: 'online', last_seen: new Date().toISOString() });
      try {
        getIO().emit('peer.online', event);
      } catch (e) {}
    }

    return reply.send({ success: true, data: event });
  });
}
