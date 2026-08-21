-- CodeHub PostgreSQL Central Control Server Database Schema
-- Includes Users, Repositories, Members, Swarm Peer Discovery Index, Issues, Comments, Labels, Milestones, and Pull Requests

CREATE TABLE IF NOT EXISTS users (
    id VARCHAR(64) PRIMARY KEY,
    username VARCHAR(100) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    public_key TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS repositories (
    id VARCHAR(64) PRIMARY KEY,
    owner_id VARCHAR(64) NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    topics TEXT[] DEFAULT '{}',
    primary_language VARCHAR(50) DEFAULT 'Rust',
    stars_count INT DEFAULT 0,
    forks_count INT DEFAULT 0,
    visibility VARCHAR(20) DEFAULT 'public', -- 'public' or 'private'
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    last_activity_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Full-Text Search GIN Index for fast repository search
CREATE INDEX IF NOT EXISTS idx_repos_fts ON repositories 
USING gin(to_tsvector('english', name || ' ' || coalesce(description, '') || ' ' || array_to_string(topics, ' ')));

CREATE TABLE IF NOT EXISTS repository_members (
    repository_id VARCHAR(64) REFERENCES repositories(id) ON DELETE CASCADE,
    user_id VARCHAR(64) REFERENCES users(id) ON DELETE CASCADE,
    role VARCHAR(20) DEFAULT 'contributor', -- 'owner', 'maintainer', 'contributor'
    PRIMARY KEY (repository_id, user_id)
);

CREATE TABLE IF NOT EXISTS branches (
    id VARCHAR(64) PRIMARY KEY,
    repository_id VARCHAR(64) REFERENCES repositories(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    commit_hash VARCHAR(64) NOT NULL,
    UNIQUE (repository_id, name)
);

CREATE TABLE IF NOT EXISTS peers (
    id VARCHAR(64) PRIMARY KEY,
    user_id VARCHAR(64) REFERENCES users(id) ON DELETE CASCADE,
    peer_id VARCHAR(128) UNIQUE NOT NULL,
    public_key TEXT NOT NULL,
    last_seen TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS peer_repositories (
    peer_id VARCHAR(128) REFERENCES peers(peer_id) ON DELETE CASCADE,
    repository_id VARCHAR(64) REFERENCES repositories(id) ON DELETE CASCADE,
    storage_available BIGINT DEFAULT 0,
    last_seen TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (peer_id, repository_id)
);

-- Issues Tracker Schema (Metadata)
CREATE TABLE IF NOT EXISTS issues (
    id VARCHAR(64) PRIMARY KEY,
    repository_id VARCHAR(64) REFERENCES repositories(id) ON DELETE CASCADE,
    author_id VARCHAR(64) REFERENCES users(id) ON DELETE CASCADE,
    issue_number INT NOT NULL,
    title VARCHAR(255) NOT NULL,
    body TEXT,
    status VARCHAR(20) DEFAULT 'OPEN', -- 'OPEN' or 'CLOSED'
    milestone VARCHAR(100),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (repository_id, issue_number)
);

CREATE TABLE IF NOT EXISTS issue_comments (
    id VARCHAR(64) PRIMARY KEY,
    issue_id VARCHAR(64) REFERENCES issues(id) ON DELETE CASCADE,
    author_id VARCHAR(64) REFERENCES users(id) ON DELETE CASCADE,
    body TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS issue_labels (
    issue_id VARCHAR(64) REFERENCES issues(id) ON DELETE CASCADE,
    label VARCHAR(50) NOT NULL,
    PRIMARY KEY (issue_id, label)
);

CREATE TABLE IF NOT EXISTS issue_assignees (
    issue_id VARCHAR(64) REFERENCES issues(id) ON DELETE CASCADE,
    assignee_user_id VARCHAR(64) REFERENCES users(id) ON DELETE CASCADE,
    PRIMARY KEY (issue_id, assignee_user_id)
);

-- Pull Requests Schema
CREATE TABLE IF NOT EXISTS pull_requests (
    id VARCHAR(64) PRIMARY KEY,
    repository_id VARCHAR(64) REFERENCES repositories(id) ON DELETE CASCADE,
    author_id VARCHAR(64) REFERENCES users(id) ON DELETE CASCADE,
    source_branch VARCHAR(100) NOT NULL,
    target_branch VARCHAR(100) NOT NULL,
    status VARCHAR(20) DEFAULT 'OPEN', -- 'OPEN', 'MERGED', 'CLOSED'
    head_commit_hash VARCHAR(64) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Social Metadata Schema (Stars, Followers, Watchers, Notifications)
CREATE TABLE IF NOT EXISTS repository_stars (
    user_id VARCHAR(64) REFERENCES users(id) ON DELETE CASCADE,
    repository_id VARCHAR(64) REFERENCES repositories(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id, repository_id)
);

CREATE TABLE IF NOT EXISTS user_followers (
    follower_id VARCHAR(64) REFERENCES users(id) ON DELETE CASCADE,
    following_id VARCHAR(64) REFERENCES users(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (follower_id, following_id)
);

CREATE TABLE IF NOT EXISTS repository_watchers (
    user_id VARCHAR(64) REFERENCES users(id) ON DELETE CASCADE,
    repository_id VARCHAR(64) REFERENCES repositories(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id, repository_id)
);

CREATE TABLE IF NOT EXISTS notifications (
    id VARCHAR(64) PRIMARY KEY,
    user_id VARCHAR(64) REFERENCES users(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    body TEXT NOT NULL,
    notification_type VARCHAR(50) DEFAULT 'star', -- 'star', 'follow', 'pr', 'issue', 'mention'
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);
