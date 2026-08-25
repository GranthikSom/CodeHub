//! Event Publisher module (Publishing events to Redis / Broadcast channel)

use tokio::sync::broadcast::Sender;

pub struct EventPublisher {
    sender: Sender<String>,
}

impl EventPublisher {
    pub fn new(sender: Sender<String>) -> Self {
        Self { sender }
    }

    pub fn publish(&self, message: &str) {
        let _ = self.sender.send(message.to_string());
    }
}
