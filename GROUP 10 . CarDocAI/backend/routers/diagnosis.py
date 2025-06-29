from fastapi import APIRouter, HTTPException, UploadFile, File, Form
import logging
import uuid
from datetime import datetime
from typing import Optional
import json

from models.schemas import DiagnosisResponse, DiagnosisType, DiagnosisStatus, UrgencyLevel
from services.gemini_service import gemini_service
from services.youtube_service import youtube_service
from services.audio_analyzer import audio_analyzer
from services.image_analyzer import image_analyzer
from utils.database import db

logger = logging.getLogger(__name__)

router = APIRouter()

def convert_numpy_types(obj):
    """Convert numpy types to native Python types for JSON serialization"""
    import numpy as np
    
    if isinstance(obj, dict):
        return {key: convert_numpy_types(value) for key, value in obj.items()}
    elif isinstance(obj, list):
        return [convert_numpy_types(item) for item in obj]
    elif isinstance(obj, np.bool_):
        return bool(obj)
    elif isinstance(obj, np.integer):
        return int(obj)
    elif isinstance(obj, np.floating):
        return float(obj)
    elif isinstance(obj, np.ndarray):
        return obj.tolist()
    else:
        return obj

# Simple user verification using Supabase user ID
async def verify_user_id(user_id: str) -> bool:
    """Verify user exists in Supabase"""
    try:
        user = await db.get_user_by_id(user_id)
        return user is not None
    except Exception as e:
        logger.error(f"Error verifying user: {e}")
        return False

@router.post("/diagnose/dashboard", response_model=DiagnosisResponse)
async def diagnose_dashboard_image(
    user_id: str = Form(...),
    image: UploadFile = File(...)
):
    """
    Analyze dashboard warning lights from uploaded image with enhanced fault detection
    """
    try:
        # Verify user exists
        if not await verify_user_id(user_id):
            raise HTTPException(
                status_code=404,
                detail="User not found"
            )
        
        # Validate image file
        if not image.content_type.startswith('image/'):
            raise HTTPException(
                status_code=400,
                detail="File must be an image"
            )
        
        # Read image data
        image_data = await image.read()
        
        # Generate diagnostic ID
        diagnostic_id = str(uuid.uuid4())
        
        # Upload image to dashboard-images bucket
        logger.info(f"Uploading dashboard image for user: {user_id}")
        image_path, image_url = await db.upload_dashboard_image(image_data, user_id, diagnostic_id)
        
        # Analyze image for warning lights with enhanced detection
        logger.info(f"Analyzing dashboard image for user: {user_id}")
        image_analysis = await image_analyzer.analyze_dashboard_image(image_data)
        
        # Convert numpy types to native Python types
        image_analysis = convert_numpy_types(image_analysis)
        
        # Get enhanced AI analysis from Gemini
        gemini_analysis = await gemini_service.analyze_dashboard_lights(image_analysis)
        
        # Convert numpy types in gemini analysis
        gemini_analysis = convert_numpy_types(gemini_analysis)
        
        # Use Gemini's specific keywords for YouTube search
        search_keywords = gemini_analysis.get("repair_keywords", ["dashboard warning light fix"])
        youtube_tutorials = await youtube_service.search_tutorials(search_keywords)
        
        # Save diagnostic record (matching your database schema)
        diagnostic_record = {
            "user_id": user_id,
            "diagnosis_type": "dashboard_scan",
            "image_path": image_path,
            "status": "completed",
            "created_at": datetime.utcnow().isoformat()
        }
        
        saved_diagnostic_id = await db.save_diagnostic_record(diagnostic_record)
        
        # Save diagnostic results with enhanced data
        diagnostic_result = {
            "diagnostic_id": saved_diagnostic_id,
            "detected_lights": [light["color"] for light in image_analysis.get("detected_lights", [])],
            "detected_sounds": [],  # Empty for dashboard analysis
            "confidence_score": gemini_analysis.get("confidence_score", 0.0),
            "urgency_level": gemini_analysis.get("urgency_level", "monitoring"),
            "analysis_results": {
                "image_analysis": image_analysis,
                "gemini_analysis": gemini_analysis,
                "youtube_tutorials": youtube_tutorials,
                "image_url": image_url,
                "safety_info": gemini_analysis.get("safety_info", {}),
                "detected_light_details": image_analysis.get("detected_lights", [])
            },
            "recommendations": gemini_analysis.get("recommendations", []),
            "created_at": datetime.utcnow().isoformat()
        }
        
        await db.save_diagnostic_result(diagnostic_result)
        
        # Map urgency level for response
        urgency_mapping = {
            "critical": UrgencyLevel.IMMEDIATE,
            "warning": UrgencyLevel.SOON,
            "normal": UrgencyLevel.MONITORING,
            "immediate": UrgencyLevel.IMMEDIATE,
            "soon": UrgencyLevel.SOON,
            "monitoring": UrgencyLevel.MONITORING
        }
        
        # Get confidence as decimal (0.0 to 1.0)
        confidence_score = float(gemini_analysis.get("confidence_score", 0.0))
        
        # Ensure confidence is within valid range
        confidence_score = max(0.0, min(1.0, confidence_score))
        
        # Create comprehensive response with converted data
        analysis_results = convert_numpy_types({
            "image_analysis": image_analysis,
            "gemini_analysis": gemini_analysis,
            "image_url": image_url,
            "safety_assessment": gemini_analysis.get("overall_assessment", {}),
            "detected_light_colors": [light["color"] for light in image_analysis.get("detected_lights", [])],
            "light_positions": [light.get("position", {}) for light in image_analysis.get("detected_lights", [])],
            "analysis_confidence": confidence_score,
            "safe_to_drive": bool(gemini_analysis.get("overall_assessment", {}).get("safe_to_drive", True)),
            "immediate_action_required": bool(gemini_analysis.get("overall_assessment", {}).get("immediate_action_required", False))
        })
        
        response = DiagnosisResponse(
            diagnostic_id=saved_diagnostic_id,
            user_id=user_id,
            diagnosis_type=DiagnosisType.DASHBOARD_SCAN,
            status=DiagnosisStatus.COMPLETED,
            detected_issues=gemini_analysis.get("detected_issues", ["Dashboard analysis completed"]),
            confidence_score=round(confidence_score, 3),  # Keep as decimal 0.0-1.0
            urgency_level=urgency_mapping.get(gemini_analysis.get("urgency_level", "monitoring"), UrgencyLevel.MONITORING),
            analysis_results=analysis_results,
            recommendations=gemini_analysis.get("recommendations", ["Consult vehicle manual for warning light meanings"]),
            youtube_tutorials=youtube_tutorials,
            created_at=datetime.utcnow()
        )
        
        logger.info(f"Dashboard diagnosis completed for user: {user_id}")
        return response
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error in dashboard diagnosis: {e}")
        raise HTTPException(
            status_code=500,
            detail=f"Dashboard diagnosis failed: {str(e)}"
        )

@router.post("/diagnose/engine-sound", response_model=DiagnosisResponse)
async def diagnose_engine_sound(
    user_id: str = Form(...),
    audio: UploadFile = File(...)
):
    """
    Analyze engine sounds from uploaded audio with enhanced fault detection
    """
    try:
        # Verify user exists
        if not await verify_user_id(user_id):
            raise HTTPException(
                status_code=404,
                detail="User not found"
            )
        
        # Enhanced audio format validation
        is_valid, validation_message = audio_analyzer.validate_audio_format(
            audio.content_type, audio.filename
        )
        
        if not is_valid:
            raise HTTPException(
                status_code=400,
                detail=validation_message
            )
        
        # Read audio data
        audio_data = await audio.read()
        
        # Generate diagnostic ID
        diagnostic_id = str(uuid.uuid4())
        
        # Upload audio to engine-sounds bucket
        logger.info(f"Uploading engine sound for user: {user_id}")
        audio_path, audio_url = await db.upload_engine_sound(audio_data, user_id, diagnostic_id)
        
        # Enhanced audio analysis with specific fault detection
        logger.info(f"Analyzing engine sound for user: {user_id}")
        audio_analysis = await audio_analyzer.analyze_engine_sound(audio_data)
        
        # Convert numpy types to native Python types
        audio_analysis = convert_numpy_types(audio_analysis)
        
        # Check if analysis failed
        if audio_analysis.get("analysis_failed", False):
            raise HTTPException(
                status_code=400,
                detail=f"Audio analysis failed: {audio_analysis.get('error_message', 'Unknown error')}"
            )
        
        # Get enhanced AI analysis from Gemini with structured audio data
        gemini_analysis = await gemini_service.analyze_engine_sound(audio_analysis)
        
        # Convert numpy types in gemini analysis
        gemini_analysis = convert_numpy_types(gemini_analysis)
        
        # Use Gemini's specific keywords for YouTube search
        search_keywords = gemini_analysis.get("repair_keywords", ["engine diagnostic repair"])
        youtube_tutorials = await youtube_service.search_tutorials(search_keywords)
        
        # Save diagnostic record
        diagnostic_record = {
            "user_id": user_id,
            "diagnosis_type": "engine_sound",
            "audio_path": audio_path,
            "status": "completed",
            "created_at": datetime.utcnow().isoformat()
        }
        
        saved_diagnostic_id = await db.save_diagnostic_record(diagnostic_record)
        
        # Save comprehensive diagnostic results
        diagnostic_result = {
            "diagnostic_id": saved_diagnostic_id,
            "detected_lights": [],  # Empty for audio analysis
            "detected_sounds": [fault["name"] for fault in audio_analysis.get("detected_faults", [])],
            "confidence_score": gemini_analysis.get("confidence_score", 0.0),
            "urgency_level": gemini_analysis.get("urgency_level", "normal"),
            "analysis_results": {
                "audio_analysis": audio_analysis,
                "gemini_analysis": gemini_analysis,
                "youtube_tutorials": youtube_tutorials,
                "audio_url": audio_url,
                "safety_info": gemini_analysis.get("safety_info", {}),
                "detected_fault_details": audio_analysis.get("detected_faults", []),
                "frequency_analysis": audio_analysis.get("frequency_analysis", {}),
                "decibel_analysis": audio_analysis.get("decibel_analysis", {}),
                "audio_quality": audio_analysis.get("audio_quality", {})
            },
            "recommendations": gemini_analysis.get("recommendations", []),
            "created_at": datetime.utcnow().isoformat()
        }
        
        await db.save_diagnostic_result(diagnostic_result)
        
        # Map urgency level for response
        urgency_mapping = {
            "critical": UrgencyLevel.IMMEDIATE,
            "warning": UrgencyLevel.SOON,
            "normal": UrgencyLevel.MONITORING
        }
        
        # Get confidence as decimal (0.0 to 1.0)
        confidence_score = float(gemini_analysis.get("confidence_score", 0.0))
        
        # Ensure confidence is within valid range
        confidence_score = max(0.0, min(1.0, confidence_score))
        
        # Create comprehensive response with converted data
        analysis_results = convert_numpy_types({
            "audio_analysis": audio_analysis,
            "gemini_analysis": gemini_analysis,
            "audio_url": audio_url,
            "safety_assessment": gemini_analysis.get("overall_assessment", {}),
            "detected_fault_names": [fault["display_name"] for fault in audio_analysis.get("detected_faults", [])],
            "fault_severities": [fault["severity"] for fault in audio_analysis.get("detected_faults", [])],
            "frequency_data": audio_analysis.get("frequency_analysis", {}),
            "decibel_data": audio_analysis.get("decibel_analysis", {}),
            "audio_quality_score": float(audio_analysis.get("audio_quality", {}).get("score", 0)),
            "analysis_confidence": confidence_score,
            "safe_to_drive": bool(gemini_analysis.get("overall_assessment", {}).get("safe_to_drive", True)),
            "immediate_action_required": bool(gemini_analysis.get("overall_assessment", {}).get("immediate_action_required", False))
        })
        
        response = DiagnosisResponse(
            diagnostic_id=saved_diagnostic_id,
            user_id=user_id,
            diagnosis_type=DiagnosisType.ENGINE_SOUND,
            status=DiagnosisStatus.COMPLETED,
            detected_issues=gemini_analysis.get("detected_issues", ["Engine sound analysis completed"]),
            confidence_score=round(confidence_score, 3),  # Keep as decimal 0.0-1.0
            urgency_level=urgency_mapping.get(gemini_analysis.get("urgency_level", "normal"), UrgencyLevel.MONITORING),
            analysis_results=analysis_results,
            recommendations=gemini_analysis.get("recommendations", ["Continue monitoring engine performance"]),
            youtube_tutorials=youtube_tutorials,
            created_at=datetime.utcnow()
        )
        
        logger.info(f"Engine sound diagnosis completed for user: {user_id}")
        return response
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error in engine sound diagnosis: {e}")
        raise HTTPException(
            status_code=500,
            detail=f"Engine sound diagnosis failed: {str(e)}"
        )

@router.get("/history/{user_id}")
async def get_diagnosis_history(user_id: str):
    """Get diagnosis history for a user"""
    try:
        # Verify user exists
        if not await verify_user_id(user_id):
            raise HTTPException(
                status_code=404,
                detail="User not found"
            )
        
        history = await db.get_diagnosis_history(user_id)
        return {"user_id": user_id, "history": history}
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error getting diagnosis history: {e}")
        raise HTTPException(
            status_code=500,
            detail=f"Failed to get diagnosis history: {str(e)}"
        )

@router.get("/result/{diagnostic_id}")
async def get_diagnosis_result(diagnostic_id: str):
    """Get specific diagnosis result"""
    try:
        result = await db.get_diagnosis_result(diagnostic_id)
        if not result:
            raise HTTPException(
                status_code=404,
                detail="Diagnosis result not found"
            )
        
        return result
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error getting diagnosis result: {e}")
        raise HTTPException(
            status_code=500,
            detail=f"Failed to get diagnosis result: {str(e)}"
        )
