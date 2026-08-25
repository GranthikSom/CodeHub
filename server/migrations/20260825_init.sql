-- Initial PostgreSQL Database Schema for CodeHub Central Control Plane

CREATE TABLE IF NOT EXISTS users (
    id VARCHAR(64) PRIMARY KEY,
    username VARCHAR(64) UNIQUE NOT NULL,
    display_name VARCHAR(128),
    avatar_url TEXT,
    bio TEXT,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    peer_id VARCHAR(128) NOT NULL,
    role VARCHAR(32) DEFAULT 'developer',
    status VARCHAR(32) DEFAULT 'active',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS repositories (
    id VARCHAR(64) PRIMARY KEY,
    owner_id VARCHAR(64) NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR(128) NOT NULL,
    full_name VARCHAR(256) UNIQUE NOT NULL,
    description TEXT,
    visibility VARCHAR(32) DEFAULT 'public', -- 'public', 'private'
    discoverability VARCHAR(32) DEFAULT 'public', -- 'public', 'hidden', 'unlisted', 'private'
    default_branch VARCHAR(64) DEFAULT 'main',
    language VARCHAR(64) DEFAULT 'Rust',
    status VARCHAR(32) DEFAULT 'CREATING', -- 'CREATING', 'ACTIVE', 'SUSPENDED', 'ARCHIVED', 'DELETING', 'DELETED'
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    last_commit_hash VARCHAR(64),
    size_bytes BIGINT DEFAULT 0,
    object_count BIGINT DEFAULT 0,
    deleted_at TIMESTAMP WITH TIME ZONE NULL,
    CONSTRAINT unique_owner_repo UNIQUE(owner_id, name)
);

CREATE TABLE IF NOT EXISTS repository_stats (
    repository_id VARCHAR(64) PRIMARY KEY REFERENCES repositories(id) ON DELETE CASCADE,
    stars_count BIGINT DEFAULT 0,
    forks_count BIGINT DEFAULT 0,
    issues_open_count BIGINT DEFAULT 0,
    issues_total_count BIGINT DEFAULT 0,
    pull_requests_open_count BIGINT DEFAULT 0,
    peer_count BIGINT DEFAULT 1,
    replica_count BIGINT DEFAULT 1,
    object_count BIGINT DEFAULT 0,
    size_bytes BIGINT DEFAULT 0,
    views_count BIGINT DEFAULT 0,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS outbox_events (
    id VARCHAR(64) PRIMARY KEY,
    event_type VARCHAR(64) NOT NULL,
    payload JSONB NOT NULL,
    status VARCHAR(32) DEFAULT 'pending',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Index for high-performance public Explore index queries (strict ACTIVE filtering)
CREATE INDEX IF NOT EXISTS idx_explore_repositories 
ON repositories(visibility, discoverability, status) 
WHERE visibility = 'public' 
  AND discoverability = 'public' 
  AND status = 'ACTIVE' 
  AND deleted_at IS NULL;
