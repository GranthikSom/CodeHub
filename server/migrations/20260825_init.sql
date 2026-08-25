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

CREATE TABLE IF NOT EXISTS repository_tags (
    repository_id VARCHAR(64) NOT NULL REFERENCES repositories(id) ON DELETE CASCADE,
    tag VARCHAR(64) NOT NULL,
    PRIMARY KEY (repository_id, tag)
);

CREATE TABLE IF NOT EXISTS repository_peers (
    repository_id VARCHAR(64) NOT NULL REFERENCES repositories(id) ON DELETE CASCADE,
    peer_id VARCHAR(128) NOT NULL,
    status VARCHAR(32) DEFAULT 'online', -- 'online', 'offline', 'unreachable'
    last_seen TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    storage_bytes BIGINT DEFAULT 0,
    object_count BIGINT DEFAULT 0,
    is_seeding BOOLEAN DEFAULT TRUE,
    replication_role VARCHAR(32) DEFAULT 'seed', -- 'primary', 'seed', 'cache'
    PRIMARY KEY (repository_id, peer_id)
);

CREATE TABLE IF NOT EXISTS outbox_events (
    id VARCHAR(64) PRIMARY KEY,
    event_type VARCHAR(64) NOT NULL,
    payload JSONB NOT NULL,
    status VARCHAR(32) DEFAULT 'pending',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Production Indexes for High Performance Queries

-- Single-column indexes for repositories
CREATE INDEX IF NOT EXISTS idx_repositories_owner_id ON repositories(owner_id);
CREATE INDEX IF NOT EXISTS idx_repositories_created_at ON repositories(created_at);
CREATE INDEX IF NOT EXISTS idx_repositories_updated_at ON repositories(updated_at);
CREATE INDEX IF NOT EXISTS idx_repositories_visibility ON repositories(visibility);
CREATE INDEX IF NOT EXISTS idx_repositories_discoverability ON repositories(discoverability);
CREATE INDEX IF NOT EXISTS idx_repositories_status ON repositories(status);
CREATE INDEX IF NOT EXISTS idx_repositories_language ON repositories(language);
CREATE INDEX IF NOT EXISTS idx_repositories_full_name ON repositories(full_name);

-- Optimized Composite Index for Explore Queries (public + discoverable + active + timestamp)
CREATE INDEX IF NOT EXISTS idx_repositories_explore_composite 
ON repositories(visibility, discoverability, status, created_at DESC);

-- Fast Tag and Swarm Peer Indexes
CREATE INDEX IF NOT EXISTS idx_repository_tags_tag ON repository_tags(tag);
CREATE INDEX IF NOT EXISTS idx_repository_peers_repo ON repository_peers(repository_id, is_seeding);
