import { publishEvent } from './eventBus.js';

export function emitRepositoryCreated(repo: any) {
  const event = {
    event: 'repository_created',
    type: 'repository.created',
    timestamp: Math.floor(Date.now() / 1000),
    repository: repo,
  };
  publishEvent('repository.events', event);
  return event;
}

export function emitRepositoryUpdated(repoId: string, changes: any) {
  const event = {
    event: 'repository_updated',
    type: 'repository.updated',
    timestamp: Math.floor(Date.now() / 1000),
    repository_id: repoId,
    changes,
  };
  publishEvent('repository.events', event);
  return event;
}

export function emitRepositoryDeleted(repoId: string) {
  const event = {
    event: 'repository_deleted',
    type: 'repository.deleted',
    timestamp: Math.floor(Date.now() / 1000),
    repository_id: repoId,
  };
  publishEvent('repository.events', event);
  return event;
}
