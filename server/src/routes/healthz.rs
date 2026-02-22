use axum::{http::StatusCode, response::IntoResponse};
use tracing::*;

use crate::database::DatabaseConnection;

pub async fn healthz(DatabaseConnection(conn): DatabaseConnection) -> impl IntoResponse {
    let row = conn.execute("select 1", &[]).await;
    if let Err(err) = row {
        warn!("error in health check: {err}");
        return (StatusCode::INTERNAL_SERVER_ERROR, "db failed");
    }
    (StatusCode::OK, "ok")
}