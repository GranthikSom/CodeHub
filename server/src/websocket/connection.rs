//! WebSocket Connection Handling

use axum::extract::ws::{WebSocket, Message};

pub async fn handle_connection(mut socket: WebSocket, mut event_rx: tokio::sync::broadcast::Receiver<String>) {
    while let Ok(msg) = event_rx.recv().await {
        if socket.send(Message::Text(msg)).await.is_err() {
            break;
        }
    }
}
