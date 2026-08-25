//! CodeHub Control Server Configuration Management

use serde::Deserialize;

#[derive(Debug, Clone, Deserialize)]
pub struct ServerConfig {
    pub host: String,
    pub port: u16,
    pub database_url: String,
    pub redis_url: String,
    pub jwt_secret: String,
    pub environment: String,
}

impl Default for ServerConfig {
    fn default() -> Self {
        Self {
            host: std::env::var("HOST").unwrap_or_else(|_| "0.0.0.0".to_string()),
            port: std::env::var("PORT").unwrap_or_else(|_| "8080".to_string()).parse().unwrap_or(8080),
            database_url: std::env::var("DATABASE_URL").unwrap_or_else(|_| "postgres://codehub:password@localhost:5432/codehub_db".to_string()),
            redis_url: std::env::var("REDIS_URL").unwrap_or_else(|_| "redis://127.0.0.1:6379".to_string()),
            jwt_secret: std::env::var("JWT_SECRET").unwrap_or_else(|_| "codehub_super_secret_argon2id_jwt_key_2026".to_string()),
            environment: std::env::var("APP_ENV").unwrap_or_else(|_| "development".to_string()),
        }
    }
}
