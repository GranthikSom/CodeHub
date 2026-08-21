-- CodeHub Central Control Plane PostgreSQL Database Migration Schema
-- Hybrid Architecture: Central Server handles Auth, Permissions, Metadata, Issues & PRs

CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    username VARCHAR(64) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    public_key TEXT NOT NULL,
    avatar_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS repositories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(128) NOT NULL,
    owner_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    description TEXT,
    default_branch VARCHAR(64) DEFAULT 'main',
    root_commit_hash VARCHAR(64) NOT NULL,
    total_size_mb DOUBLE PRECISION DEFAULT 0.0,
    total_objects BIGINT DEFAULT 0,
    stars_count INT DEFAULT 0,
    forks_count INT DEFAULT 0,
    is_private BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(owner_id, name)
);

CREATE TABLE IF NOT EXISTS repository_members (
    repo_id UUID REFERENCES repositories(id) ON DELETE CASCADE,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    role VARCHAR(32) DEFAULT 'read', -- 'owner', 'maintainer', 'write', 'read'
    granted_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (repo_id, user_id)
);

CREATE TABLE IF NOT EXISTS branches (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    repo_id UUID REFERENCES repositories(id) ON DELETE CASCADE,
    name VARCHAR(128) NOT NULL,
    head_commit_hash VARCHAR(64) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(repo_id, name)
);

CREATE TABLE IF NOT EXISTS issues (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    repo_id UUID REFERENCES repositories(id) ON DELETE CASCADE,
    author_id UUID REFERENCES users(id) ON DELETE CASCADE,
    issue_number INT NOT NULL,
    title VARCHAR(256) NOT NULL,
    body TEXT,
    status VARCHAR(32) DEFAULT 'open', -- 'open', 'closed'
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(repo_id, issue_number)
);

CREATE TABLE IF NOT EXISTS pull_requests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    repo_id UUID REFERENCES repositories(id) ON DELETE CASCADE,
    author_id UUID REFERENCES users(id) ON DELETE CASCADE,
    pr_number INT NOT NULL,
    title VARCHAR(256) NOT NULL,
    description TEXT,
    source_branch VARCHAR(128) NOT NULL,
    target_branch VARCHAR(128) NOT NULL,
    status VARCHAR(32) DEFAULT 'open', -- 'open', 'merged', 'closed'
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(repo_id, pr_number)
);

CREATE TABLE IF NOT EXISTS comments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    author_id UUID REFERENCES users(id) ON DELETE CASCADE,
    issue_id UUID REFERENCES issues(id) ON DELETE CASCADE,
    pull_request_id UUID REFERENCES pull_requests(id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    message TEXT NOT NULL,
    is_read BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS peer_nodes (
    node_id VARCHAR(128) PRIMARY KEY,
    ip_address VARCHAR(64) NOT NULL,
    multiaddr TEXT NOT NULL,
    node_type VARCHAR(32) DEFAULT 'peer',
    allocated_storage_gb DOUBLE PRECISION DEFAULT 20.0,
    used_storage_gb DOUBLE PRECISION DEFAULT 0.0,
    last_seen TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS repo_seeds (
    repo_id UUID REFERENCES repositories(id) ON DELETE CASCADE,
    node_id VARCHAR(128) REFERENCES peer_nodes(node_id) ON DELETE CASCADE,
    replication_progress DOUBLE PRECISION DEFAULT 1.0,
    pinned_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (repo_id, node_id)
);
