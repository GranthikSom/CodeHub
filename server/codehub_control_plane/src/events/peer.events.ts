import { publishEvent } from './eventBus.js';

export function emitPeerOnline(peer: any) {
  const event = {
    event: 'peer.online',
    type: 'peer.online',
    timestamp: Math.floor(Date.now() / 1000),
    peer,
  };
  publishEvent('swarm.events', event);
  return event;
}

export function emitPeerOffline(peerId: string) {
  const event = {
    event: 'peer.offline',
    type: 'peer.offline',
    timestamp: Math.floor(Date.now() / 1000),
    peer_id: peerId,
  };
  publishEvent('swarm.events', event);
  return event;
}
