from fastapi import FastAPI

from di2vibe.api import health


def create_app() -> FastAPI:
    app = FastAPI(title="di2vibe", version="0.0.1")
    app.include_router(health.router)
    return app


app = create_app()
