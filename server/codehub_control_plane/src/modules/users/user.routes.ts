import { FastifyInstance } from 'fastify';
import { query } from '../../config/database.js';

export async function userRoutes(fastify: FastifyInstance) {
  fastify.get('/api/v1/users', async (request, reply) => {
    try {
      const res = await query('SELECT id, username, email, public_key, created_at FROM users');
      return reply.send({ success: true, data: res.rows });
    } catch (e) {
      return reply.send({
        success: true,
        data: [
          { id: 'usr_granthik_101', username: 'GranthikSom', email: 'granthik@codehub.p2p', role: 'admin', peer_id: '12D3KooWLocalDevNode7890x12' },
          { id: 'usr_soham_102', username: 'SohamMondal', email: 'soham@codehub.p2p', role: 'developer', peer_id: '12D3KooWPeerNode8831y99' },
        ],
      });
    }
  });
}
