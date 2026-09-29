from fastapi import FastAPI
from fastapi.responses import JSONResponse
import os
import socket

app = FastAPI(title="demo-api", version=os.getenv("APP_VERSION", "0.1.0"))


@app.get("/")
def root():
    return {
        "service": "demo-api",
        "version": os.getenv("APP_VERSION", "0.1.0"),
        "environment": os.getenv("APP_ENV", "local"),
        "host": socket.gethostname(),
    }


@app.get("/healthz")
def healthz():
    return JSONResponse({"status": "ok"})


@app.get("/readyz")
def readyz():
    return JSONResponse({"status": "ready"})
