import { query } from '../config/database.js';
import { publishEvent } from '../events/eventBus.js';
import { getIO } from '../realtime/socket.js';

let isRunning = false;

export function startOutboxWorker(intervalMs = 1000) {
  if (isRunning) return;
  isRunning = true;
  console.log(`📦 Transactional Outbox Worker started (polling interval: ${intervalMs}ms)`);

  setInterval(async () => {
    try {
      await processPendingOutboxEvents();
    } catch (err) {
      console.warn('⚠️ Outbox Worker poll error:', err);
    }
  }, intervalMs);
}

export async function processPendingOutboxEvents() {
  try {
    const res = await query(
      `SELECT id, aggregate_type, aggregate_id, event_type, payload, retry_count
       FROM outbox_events
       WHERE status = 'PENDING' AND retry_count < 5
       ORDER BY created_at ASC
       LIMIT 50`
    );

    if (res.rows.length === 0) return;

    for (const row of res.rows) {
      const channel = row.aggregate_type === 'repository' ? 'repository.events' : 'swarm.events';
      const eventPayload = typeof row.payload === 'string' ? JSON.parse(row.payload) : row.payload;

      // 1. Publish to Redis Pub/Sub Event System
      await publishEvent(channel, eventPayload);

      // 2. Broadcast via Socket.IO Realtime Engine
      try {
        const io = getIO();
        io.emit(row.event_type, eventPayload);
        if (row.event_type.includes('.')) {
          io.emit(row.event_type.replace('.', '_'), eventPayload);
        }
      } catch (e) {}

      // 3. Mark Outbox Event as PROCESSED in PostgreSQL
      await query(
        `UPDATE outbox_events
         SET status = 'PROCESSED', processed_at = CURRENT_TIMESTAMP
         WHERE id = $1`,
        [row.id]
      );
    }
  } catch (err) {
    // Silent fallback if table not yet migrated locally
  }
}
