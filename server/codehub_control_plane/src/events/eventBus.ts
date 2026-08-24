import { redisPublisher } from '../config/redis.js';

export async function publishEvent(channel: string, payload: object) {
  try {
    await redisPublisher.publish(channel, JSON.stringify(payload));
  } catch (err) {
    console.error(`[EventBus] Publishing failed for ${channel}:`, err);
  }
}
