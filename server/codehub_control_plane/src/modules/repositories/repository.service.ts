import { pool, query } from '../../config/database.js';
import { CreateRepositoryInput } from './repository.schema.js';

export async function createRepositoryService(username: string, input: CreateRepositoryInput) {
  const repoName = input.name.trim();
  const description = input.description || 'Decentralized P2P Git application';
  const visibility = input.visibility || 'public';
  const defaultBranch = input.defaultBranch || input.default_branch || 'main';
  const fullName = `${username}/${repoName}`;

  // 1. Check Uniqueness
  const existingCheck = await query('SELECT id FROM repositories WHERE full_name = $1', [fullName]);
  if (existingCheck.rows.length > 0) {
    const error = new Error(`Repository '${fullName}' already exists for user '${username}'`);
    (error as any).statusCode = 409;
    throw error;
  }

  const client = await pool.connect();
  const repoId = `repo_${Date.now()}`;
  const initialCommitHash = `sha256_${Math.random().toString(36).substring(2, 18)}`;
  let ownerId: string;

  const repositoryPayload = {
    id: repoId,
    owner_id: '',
    owner: username,
    name: repoName,
    full_name: fullName,
    description,
    visibility,
    default_branch: defaultBranch,
    language: 'Rust',
    stars_count: 1,
    forks_count: 0,
    issues_count: 0,
    size_bytes: 1024,
    object_count: 1,
    created_at: new Date().toISOString(),
    updated_at: new Date().toISOString(),
    last_commit_hash: initialCommitHash,
  };

  const eventPayload = {
    event: 'repository_created',
    type: 'repository.created',
    timestamp: Math.floor(Date.now() / 1000),
    repository: repositoryPayload,
  };

  // 2. ATOMIC POSTGRESQL TRANSACTION (Repository + Default Branch + Outbox Event)
  try {
    await client.query('BEGIN');

    // Get or Create User
    let userRes = await client.query('SELECT id FROM users WHERE username = $1', [username]);
    if (userRes.rows.length === 0) {
      const newUser = await client.query(
        'INSERT INTO users (username, email, password_hash, public_key, display_name) VALUES ($1, $2, $3, $4, $5) RETURNING id',
        [username, `${username.toLowerCase()}@codehub.p2p`, 'hash_placeholder', `ed25519_pk_${Date.now()}`, username]
      );
      ownerId = newUser.rows[0].id;
    } else {
      ownerId = userRes.rows[0].id;
    }

    repositoryPayload.owner_id = ownerId;

    // Insert Repository Record
    await client.query(
      `INSERT INTO repositories
        (id, owner_id, name, full_name, description, visibility, default_branch, language, stars_count, forks_count, issues_count, size_bytes, object_count, last_commit_hash)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14)`,
      [
        repoId,
        ownerId,
        repoName,
        fullName,
        description,
        visibility,
        defaultBranch,
        'Rust',
        1,
        0,
        0,
        1024,
        1,
        initialCommitHash,
      ]
    );

    // Insert Default Branch Metadata
    await client.query(
      `INSERT INTO branches (repository_id, name, commit_hash) VALUES ($1, $2, $3) ON CONFLICT DO NOTHING`,
      [repoId, defaultBranch, initialCommitHash]
    );

    // INSERT OUTBOX EVENT ATOMICALLY INSIDE SAME TRANSACTION
    await client.query(
      `INSERT INTO outbox_events (aggregate_type, aggregate_id, event_type, payload, status)
       VALUES ($1, $2, $3, $4, $5)`,
      ['repository', repoId, 'repository.created', JSON.stringify(eventPayload), 'PENDING']
    );

    await client.query('COMMIT');
  } catch (err) {
    await client.query('ROLLBACK');
    throw err;
  } finally {
    client.release();
  }

  return repositoryPayload;
}
