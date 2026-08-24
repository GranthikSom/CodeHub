import { Server as HttpServer } from 'http';
import { Server as SocketIOServer } from 'socket.io';
import { createAdapter } from '@socket.io/redis-adapter';
import { redisPublisher, redisSubscriber } from '../config/redis.js';

let io: SocketIOServer | null = null;

export function initSocketIO(httpServer: HttpServer): SocketIOServer {
  io = new SocketIOServer(httpServer, {
    cors: { origin: '*', methods: ['GET', 'POST'] },
  });

  try {
    io.adapter(createAdapter(redisPublisher, redisSubscriber));
    console.log('✅ Socket.IO Redis Adapter connected');
  } catch (err) {
    console.warn('⚠️ Socket.IO running without Redis adapter fallback');
  }

  io.on('connection', (socket) => {
    console.log(`⚡ Peer Socket.IO client connected: ${socket.id}`);

    socket.emit('users_live_update', {
      event: 'users_live_update',
      timestamp: Math.floor(Date.now() / 1000),
      total_users: 14,
      users: [
        { id: 'usr_granthik_101', username: 'GranthikSom', role: 'admin', peer_id: '12D3KooWLocalDevNode7890x12' },
      ],
    });

    socket.on('disconnect', () => {
      console.log(`🔌 Peer Socket.IO client disconnected: ${socket.id}`);
    });
  });

  return io;
}

export function getIO(): SocketIOServer {
  if (!io) throw new Error('Socket.IO not initialized');
  return io;
}
