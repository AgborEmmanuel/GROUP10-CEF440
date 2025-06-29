import os
from dotenv import load_dotenv

# ✅ Load environment variables before importing anything else
load_dotenv()

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from contextlib import asynccontextmanager
import logging
import time
from datetime import datetime

# Import routers and schemas (after loading env)
from routers.diagnosis import router as diagnosis_router
from models.schemas import HealthCheck, SystemStatus

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# Application startup time
startup_time = datetime.now()

@asynccontextmanager
async def lifespan(app: FastAPI):
    """Application lifespan manager"""
    logger.info("🚀 CarDoc AI Backend starting up...")
    try:
        # Verify required env variables
        required_env_vars = [
            "GEMINI_API_KEY",
            "YOUTUBE_API_KEY", 
            "SUPABASE_URL",
            "SUPABASE_SERVICE_KEY"
        ]
        missing_vars = [var for var in required_env_vars if not os.getenv(var)]
        if missing_vars:
            logger.error(f"❌ Missing environment variables: {missing_vars}")
            raise Exception(f"Missing required environment variables: {missing_vars}")
        logger.info("✅ Environment variables verified")
        logger.info("✅ CarDoc AI Backend started successfully")
    except Exception as e:
        logger.error(f"❌ Startup failed: {e}")
        raise
    yield
    logger.info("🛑 CarDoc AI Backend shutting down...")

# Create FastAPI app
app = FastAPI(
    title="CarDoc AI Backend",
    description="Advanced AI-powered car diagnostic system with dashboard image analysis and engine sound analysis",
    version="1.0.0",
    docs_url="/docs",
    redoc_url="/redoc",
    lifespan=lifespan
)

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Adjust for production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Request logging middleware
@app.middleware("http")
async def log_requests(request, call_next):
    start_time = time.time()
    logger.info(f"📥 {request.method} {request.url.path}")
    response = await call_next(request)
    process_time = time.time() - start_time
    logger.info(f"📤 {request.method} {request.url.path} - {response.status_code} - {process_time:.3f}s")
    return response

# Include routers
app.include_router(diagnosis_router, prefix="/diagnosis", tags=["Diagnosis"])

# Health check endpoint
@app.get("/health", response_model=HealthCheck)
async def health_check():
    return HealthCheck(
        status="healthy",
        timestamp=datetime.now(),
        version="1.0.0",
        services={
            "api": "healthy",
            "database": "healthy",
            "ai_services": "healthy"
        }
    )

# System status endpoint
@app.get("/status", response_model=SystemStatus)
async def system_status():
    uptime = datetime.now() - startup_time
    uptime_str = f"{uptime.days}d {uptime.seconds//3600}h {(uptime.seconds//60)%60}m"
    return SystemStatus(
        api_status="operational",
        database_status="connected",
        gemini_api_status="available",
        youtube_api_status="available",
        storage_status="operational",
        uptime=uptime_str
    )

# Root endpoint
@app.get("/")
async def root():
    return {
        "message": "🚗 CarDoc AI Backend API",
        "version": "1.0.0",
        "status": "operational",
        "docs": "/docs",
        "health": "/health",
        "endpoints": {
            "diagnosis": "/diagnosis"
        },
        "features": [
            "Dashboard Warning Light Analysis",
            "Engine Sound Analysis",
            "AI-Powered Fault Detection",
            "YouTube Tutorial Integration",
            "Diagnosis History Tracking"
        ]
    }

# Error handlers
@app.exception_handler(HTTPException)
async def http_exception_handler(request, exc):
    logger.error(f"HTTP Exception: {exc.status_code} - {exc.detail}")
    return JSONResponse(
        status_code=exc.status_code,
        content={
            "error": "HTTP Exception",
            "status_code": exc.status_code,
            "detail": exc.detail,
            "timestamp": datetime.now().isoformat()
        }
    )

@app.exception_handler(Exception)
async def general_exception_handler(request, exc):
    logger.error(f"Unhandled Exception: {str(exc)}")
    return JSONResponse(
        status_code=500,
        content={
            "error": "Internal Server Error",
            "detail": "An unexpected error occurred",
            "timestamp": datetime.now().isoformat()
        }
    )

# Entry point
if __name__ == "__main__":
    import uvicorn
    logger.info("🚀 Starting CarDoc AI Backend Server...")
    logger.info("📚 API Documentation: http://127.0.0.1:8000/docs")
    logger.info("🔍 Health Check: http://127.0.0.1:8000/health")
    uvicorn.run(
        "main:app",
        host="127.0.0.1",
        port=8000,
        reload=True,
        log_level="info"
    )
