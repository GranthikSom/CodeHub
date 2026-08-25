//! Swarm WebSocket Room and Topic Multiplexing

use std::collections::HashMap;
use std::sync::Mutex;

pub struct RoomManager {
    rooms: Mutex<HashMap<String, Vec<String>>>,
}

impl RoomManager {
    pub fn new() -> Self {
        Self {
            rooms: Mutex::new(HashMap::new()),
        }
    }

    pub fn join_room(&self, room: &str, peer_id: &str) {
        if let Ok(mut guard) = self.rooms.lock() {
            guard.entry(room.to_string()).or_default().push(peer_id.to_string());
        }
    }
}
