export const SOCKET_ROOMS = {
  EXPLORE: 'room:explore',
  SWARM: 'room:swarm',
  REPO: (id: string) => `room:repo:${id}`,
};

export const SOCKET_EVENTS = {
  REPOSITORY_CREATED: 'repository.created',
  REPOSITORY_UPDATED: 'repository.updated',
  REPOSITORY_DELETED: 'repository.deleted',
  ISSUE_CREATED: 'issue.created',
  PR_CREATED: 'pr.created',
  PEER_ONLINE: 'peer.online',
  PEER_OFFLINE: 'peer.offline',
  REPLICATION_UPDATED: 'replication.updated',
  TRANSFER_PROGRESS: 'transfer.progress',
  NOTIFICATION_RECEIVED: 'notification.received',
};
