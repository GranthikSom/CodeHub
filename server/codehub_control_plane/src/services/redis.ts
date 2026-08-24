import { Redis } from 'ioredis';

const redisUrl = process.env.REDIS_URL || 'redis://localhost:6379';

export const redisPublisher = new Redis(redisUrl, {
  lazyConnect: true,
  maxRetriesPerRequest: 1,
  enableOfflineQueue: false,
});

export const redisSubscriber = new Redis(redisUrl, {
  lazyConnect: true,
  maxRetriesPerRequest: 1,
  enableOfflineQueue: false,
});

redisPublisher.on('error', (err) => {
  // Silent fallback when Redis container is not active locally
});

redisSubscriber.on('error', (err) => {
  // Silent fallback when Redis container is not active locally
});


export async function publishEvent(channel: string, eventPayload: object) {
  try {
    const payloadStr = JSON.stringify(eventPayload);
    await redisPublisher.publish(channel, payloadStr);
  } catch (err) {
    console.error(`[Redis PubSub] Failed to publish event to ${channel}:`, err);
  }
}
