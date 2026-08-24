-- CodeHub Database Migration: 0003_outbox_pattern.sql
-- Transactional Outbox Pattern for Guaranteed Real-Time Event Delivery

CREATE TABLE IF NOT EXISTS outbox_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    aggregate_type VARCHAR(64) NOT NULL,   -- 'repository', 'issue', 'pr', 'peer'
    aggregate_id VARCHAR(128) NOT NULL,
    event_type VARCHAR(64) NOT NULL,       -- 'repository.created', 'repository.updated', 'issue.created', etc.
    payload JSONB NOT NULL,
    status VARCHAR(32) DEFAULT 'PENDING',  -- 'PENDING', 'PROCESSED', 'FAILED'
    retry_count INT DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    processed_at TIMESTAMP WITH TIME ZONE
);

CREATE INDEX IF NOT EXISTS idx_outbox_pending ON outbox_events(status, created_at);
