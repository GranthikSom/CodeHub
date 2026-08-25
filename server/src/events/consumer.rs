//! Event Consumer module (Consuming Redis Streams & outbox events)

use tokio::sync::broadcast::Receiver;

pub struct EventConsumer {
    receiver: Receiver<String>,
}

impl EventConsumer {
    pub fn new(receiver: Receiver<String>) -> Self {
        Self { receiver }
    }

    pub async fn listen<F>(&mut self, mut callback: F)
    where
        F: FnMut(String),
    {
        while let Ok(msg) = self.receiver.recv().await {
            callback(msg);
        }
    }
}
