-- CodeHub Database Migration: 0002_explore_schema.sql
-- Database Schema for Explore Page & Repository Swarm Telemetry

-- 1. Extend users table
ALTER TABLE users ADD COLUMN IF NOT EXISTS display_name VARCHAR(128);
ALTER TABLE users ADD COLUMN IF NOT EXISTS avatar_url TEXT;

-- 2. Extend repositories table
ALTER TABLE repositories ADD COLUMN IF NOT EXISTS full_name VARCHAR(256) UNIQUE;
ALTER TABLE repositories ADD COLUMN IF NOT EXISTS default_branch VARCHAR(64) DEFAULT 'main';
ALTER TABLE repositories ADD COLUMN IF NOT EXISTS language VARCHAR(64) DEFAULT 'Rust';
ALTER TABLE repositories ADD COLUMN IF NOT EXISTS stars_count INT DEFAULT 0;
ALTER TABLE repositories ADD COLUMN IF NOT EXISTS forks_count INT DEFAULT 0;
ALTER TABLE repositories ADD COLUMN IF NOT EXISTS issues_count INT DEFAULT 0;
ALTER TABLE repositories ADD COLUMN IF NOT EXISTS size_bytes BIGINT DEFAULT 1024;
ALTER TABLE repositories ADD COLUMN IF NOT EXISTS object_count INT DEFAULT 1;
ALTER TABLE repositories ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP;
ALTER TABLE repositories ADD COLUMN IF NOT EXISTS last_commit_hash VARCHAR(64) DEFAULT 'a81c4e97d2f831b2c4d5e6f7a8b9c0d1e2f3a4b5';

-- 3. Create repository_tags table
CREATE TABLE IF NOT EXISTS repository_tags (
    repository_id VARCHAR(128) NOT NULL,
    tag VARCHAR(64) NOT NULL,
    PRIMARY KEY (repository_id, tag)
);

-- 4. Create repository_peers table
CREATE TABLE IF NOT EXISTS repository_peers (
    repository_id VARCHAR(128) NOT NULL,
    peer_id VARCHAR(128) NOT NULL,
    status VARCHAR(32) DEFAULT 'online', -- 'online', 'offline', 'seeding', 'leeching'
    last_seen TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    storage_bytes BIGINT DEFAULT 0,
    PRIMARY KEY (repository_id, peer_id)
);

-- Indexes for fast query resolution
CREATE INDEX IF NOT EXISTS idx_repositories_full_name ON repositories(full_name);
CREATE INDEX IF NOT EXISTS idx_repositories_language ON repositories(language);
CREATE INDEX IF NOT EXISTS idx_repositories_stars ON repositories(stars_count DESC);
CREATE INDEX IF NOT EXISTS idx_repository_tags_tag ON repository_tags(tag);
CREATE INDEX IF NOT EXISTS idx_repository_peers_repo ON repository_peers(repository_id);
