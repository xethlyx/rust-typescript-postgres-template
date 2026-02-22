use std::env;

use anyhow::{Context as _, Result};
use refinery::embed_migrations;
use tracing_subscriber::prelude::*;
use tracing::*;

mod database;
use database::ConnectionPool;
mod routes;
embed_migrations!("migrations");

fn main() -> Result<()> {
    let tracing_layer = {
        if env::var("LOG_FORMAT").is_ok_and(|format| format == "json") {
            tracing_subscriber::fmt::layer().json().boxed()
        } else {
            tracing_subscriber::fmt::layer().boxed()
        }
    };

    tracing_subscriber::registry()
        .with(
            tracing_subscriber::EnvFilter::try_from_default_env().unwrap_or_else(|_| {
                format!("{}=debug,tower_http=debug", env!("CARGO_CRATE_NAME")).into()
            }),
        )
        .with(tracing_layer)
        .with(tracing_error::ErrorLayer::default())
        .init();

    tokio::runtime::Builder::new_multi_thread()
        .enable_all()
        .build()
        .unwrap()
        .block_on(async { init().await })
}

#[instrument]
async fn init() -> Result<()> {
    #[cfg(debug_assertions)]
    let postgres_url = &env::var("POSTGRES_URL").unwrap_or("postgres://postgres:postgres@localhost:5432".to_string());
    #[cfg(not(debug_assertions))]
    let postgres_url = &env::var("POSTGRES_URL").context("POSTGRES_URL not found")?;

    let manager = bb8_postgres::PostgresConnectionManager::new_from_stringlike(
        postgres_url,
        tokio_postgres::NoTls,
    )
    .context("could not initialize postgres connection manager")?;

    let pool = bb8::Pool::builder()
        .build(manager)
        .await
        .context("could not initialize postgres connection pool")?;

    migrations(&pool).await?;

    use axum::routing::*;
    use routes::*;

    let api = axum::Router::new()
        .route("/healthz", get(healthz))
        .with_state(pool.clone());

    let app = Router::new()
        .route("/healthz", get(healthz))
        .nest("/api", api)
        .fallback_service(
            tower_http::services::ServeDir::new("client")
                .not_found_service(tower_http::services::ServeFile::new("client/200.html"))
        )
        .with_state(pool)
        .layer(tower_http::trace::TraceLayer::new_for_http());

    let listener = tokio::net::TcpListener::bind(
        env::var("BIND_ADDR").unwrap_or_else(|_| "[::]:8080".to_string())
    ).await?;

    info!("listening to {}", listener.local_addr()?);

    axum::serve(listener, app)
        .with_graceful_shutdown(shutdown_signal())
        .await
        .context("could not start server")
}

async fn shutdown_signal() {
    let ctrl_c = async {
        tokio::signal::ctrl_c()
            .await
            .expect("failed to install Ctrl+C handler");
    };

    #[cfg(unix)]
    let terminate = async {
        tokio::signal::unix::signal(tokio::signal::unix::SignalKind::terminate())
            .expect("failed to install signal handler")
            .recv()
            .await;
    };

    #[cfg(not(unix))]
    let terminate = std::future::pending::<()>();

    tokio::select! {
        _ = ctrl_c => {},
        _ = terminate => {},
    }
}

#[instrument(skip_all)]
async fn migrations(pool: &ConnectionPool) -> Result<()> {
    info!("beginning migrations");
    let mut client = pool.dedicated_connection().await?;
    let migrations = migrations::runner().run_async(&mut client).await?;
    let applied_migrations = migrations.applied_migrations();
    info!(
        "performed {} migrations{}{}",
        applied_migrations.len(),
        if applied_migrations.is_empty() {
            ""
        } else {
            ": "
        },
        applied_migrations
            .iter()
            .map(|v| v.name())
            .collect::<Vec<_>>()
            .join(", ")
    );
    Ok(())
}
