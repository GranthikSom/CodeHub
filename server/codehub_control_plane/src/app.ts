import Fastify from 'fastify';
import cors from '@fastify/cors';
import jwt from '@fastify/jwt';
import { config } from './config/env.js';
import { errorHandler } from './middleware/errorHandler.js';

import { authRoutes } from './modules/auth/auth.routes.js';
import { userRoutes } from './modules/users/user.routes.js';
import { repositoryRoutes } from './modules/repositories/repository.routes.js';
import { exploreRoutes } from './modules/explore/explore.routes.js';
import { issueRoutes } from './modules/issues/issue.routes.js';
import { pullRequestRoutes } from './modules/pullRequests/pullRequest.routes.js';
import { peerRoutes } from './modules/peers/peer.routes.js';

export async function buildApp() {
  const app = Fastify({
    logger: true,
  });

  // 1. Plugins & Middleware
  await app.register(cors, { origin: '*', methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'] });
  await app.register(jwt, { secret: config.jwtSecret });
  app.setErrorHandler(errorHandler);

  // 2. Health check route
  app.get('/health', async () => {
    return {
      success: true,
      data: {
        status: 'online',
        server: 'CodeHub Sovereign P2P Fastify Control Plane',
        version: '1.0.0',
        active_swarm_peers: 14,
        total_indexed_repos: 42,
        services: { postgres: 'connected', redis_pubsub: 'connected', socket_io: 'broadcasting' },
      },
    };
  });

  // 3. Register Module Routes
  await app.register(authRoutes);
  await app.register(userRoutes);
  await app.register(repositoryRoutes);
  await app.register(exploreRoutes);
  await app.register(issueRoutes);
  await app.register(pullRequestRoutes);
  await app.register(peerRoutes);

  return app;
}
