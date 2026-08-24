import { Redis } from 'ioredis';
import { config } from './env.js';

export const redisPublisher = new Redis(config.redisUrl, {
  lazyConnect: true,
  maxRetriesPerRequest: 1,
  enableOfflineQueue: false,
});

export const redisSubscriber = new Redis(config.redisUrl, {
  lazyConnect: true,
  maxRetriesPerRequest: 1,
  enableOfflineQueue: false,
});

redisPublisher.on('error', () => {});
redisSubscriber.on('error', () => {});
