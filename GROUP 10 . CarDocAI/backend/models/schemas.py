from pydantic import BaseModel, Field
from typing import List, Dict, Any, Optional
from datetime import datetime
from enum import Enum

# Enums matching your database schema
class DiagnosisType(str, Enum):
    DASHBOARD_SCAN = "dashboard_scan"
    ENGINE_SOUND = "engine_sound"
    COMBINED = "combined"

class UrgencyLevel(str, Enum):
    IMMEDIATE = "immediate"
    SOON = "soon"
    MONITORING = "monitoring"

class DiagnosisStatus(str, Enum):
    COMPLETED = "completed"
    IN_PROGRESS = "in_progress"
    FAILED = "failed"

# YouTube Tutorial Schema
class YouTubeTutorial(BaseModel):
    title: str
    url: str
    thumbnail: str
    channel: str
    description: Optional[str] = None
    published_at: Optional[str] = None

# Request Schemas
class DiagnosisRequest(BaseModel):
    user_id: str
    diagnosis_type: DiagnosisType

# Response Schemas
class DiagnosisResponse(BaseModel):
    diagnostic_id: str
    user_id: str
    diagnosis_type: DiagnosisType
    status: DiagnosisStatus
    detected_issues: List[str]
    confidence_score: float = Field(ge=0.0, le=1.0)
    urgency_level: UrgencyLevel
    analysis_results: Dict[str, Any]
    recommendations: List[str]
    youtube_tutorials: List[YouTubeTutorial]
    created_at: datetime

class ErrorResponse(BaseModel):
    error: str
    detail: str
    timestamp: datetime

# Health Check Schemas
class HealthCheck(BaseModel):
    status: str
    timestamp: datetime
    version: str
    services: Dict[str, str]

class SystemStatus(BaseModel):
    api_status: str
    database_status: str
    gemini_api_status: str
    youtube_api_status: str
    storage_status: str
    uptime: str

# History Response Schema
class DiagnosisHistory(BaseModel):
    user_id: str
    total_diagnoses: int
    diagnoses: List[Dict[str, Any]]
