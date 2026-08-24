import { buildApp } from './app.js';
import { config } from './config/env.js';
import { initSocketIO } from './realtime/socket.js';
import { redisSubscriber } from './config/redis.js';
import { startOutboxWorker } from './services/outboxWorker.js';

async function startServer() {
  const app = await buildApp();

  // Start Transactional Outbox Event Worker
  startOutboxWorker(1000);


  // Initialize Socket.IO Server attached to Fastify's raw HTTP server
  const io = initSocketIO(app.server);

  // Redis Subscriber Event Bridge -> Socket.IO Broadcast
  try {
    await redisSubscriber.subscribe('repository.events', 'swarm.events');
    redisSubscriber.on('message', (channel, message) => {
      try {
        const payload = JSON.parse(message);
        const eventName = payload.type || payload.event;
        if (eventName) {
          io.emit(eventName, payload);
          if (payload.event && payload.event !== eventName) {
            io.emit(payload.event, payload);
          }
        }
      } catch (e) {}
    });
  } catch (err) {
    console.warn('⚠️ Redis event subscription notice:', err);
  }

  try {
    await app.listen({ port: config.port, host: config.host });
    console.log(`🚀 CodeHub Fastify Control Plane API running at http://${config.host}:${config.port}`);
  } catch (err) {
    app.log.error(err);
    process.exit(1);
  }
}

startServer();
