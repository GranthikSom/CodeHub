-- CodeHub PostgreSQL Database Schema Migration
-- Hybrid Control Plane Database

-- 1. users
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    username VARCHAR(64) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash TEXT NOT NULL,
    public_key TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 2. repositories
CREATE TABLE IF NOT EXISTS repositories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    owner_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR(128) NOT NULL,
    description TEXT,
    visibility VARCHAR(32) DEFAULT 'public', -- 'public', 'private'
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(owner_id, name)
);

-- 3. repository_members
CREATE TABLE IF NOT EXISTS repository_members (
    repository_id UUID REFERENCES repositories(id) ON DELETE CASCADE,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    role VARCHAR(32) DEFAULT 'read', -- 'owner', 'admin', 'write', 'read'
    PRIMARY KEY (repository_id, user_id)
);

-- 4. branches
CREATE TABLE IF NOT EXISTS branches (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    repository_id UUID REFERENCES repositories(id) ON DELETE CASCADE,
    name VARCHAR(128) NOT NULL,
    commit_hash VARCHAR(64) NOT NULL,
    UNIQUE(repository_id, name)
);

-- 5. peers
CREATE TABLE IF NOT EXISTS peers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    peer_id VARCHAR(128) UNIQUE NOT NULL, -- Base58 multihash starting with 12D3KooW...
    public_key TEXT NOT NULL,
    last_seen TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 6. peer_repositories
CREATE TABLE IF NOT EXISTS peer_repositories (
    peer_id VARCHAR(128) REFERENCES peers(peer_id) ON DELETE CASCADE,
    repository_id UUID REFERENCES repositories(id) ON DELETE CASCADE,
    storage_available BIGINT DEFAULT 2000000000,
    last_seen TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (peer_id, repository_id)
);

-- 7. issues
CREATE TABLE IF NOT EXISTS issues (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    repository_id UUID REFERENCES repositories(id) ON DELETE CASCADE,
    author_id UUID REFERENCES users(id) ON DELETE CASCADE,
    title VARCHAR(256) NOT NULL,
    body TEXT,
    status VARCHAR(32) DEFAULT 'open' -- 'open', 'closed'
);

-- 8. pull_requests
CREATE TABLE IF NOT EXISTS pull_requests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    repository_id UUID REFERENCES repositories(id) ON DELETE CASCADE,
    author_id UUID REFERENCES users(id) ON DELETE CASCADE,
    source_branch VARCHAR(128) NOT NULL,
    target_branch VARCHAR(128) NOT NULL,
    status VARCHAR(32) DEFAULT 'open' -- 'open', 'merged', 'closed'
);

-- Performance Indexes
CREATE INDEX IF NOT EXISTS idx_repositories_owner ON repositories(owner_id);
CREATE INDEX IF NOT EXISTS idx_branches_repo ON branches(repository_id);
CREATE INDEX IF NOT EXISTS idx_peers_user ON peers(user_id);
CREATE INDEX IF NOT EXISTS idx_peer_repos_repo ON peer_repositories(repository_id);
CREATE INDEX IF NOT EXISTS idx_issues_repo ON issues(repository_id);
CREATE INDEX IF NOT EXISTS idx_pulls_repo ON pull_requests(repository_id);
