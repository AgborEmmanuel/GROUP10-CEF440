from supabase import create_client, Client
import logging
from typing import Dict, Any, List, Optional, Tuple
import uuid
from datetime import datetime
import asyncio
import os

logger = logging.getLogger(__name__)

# Supabase Configuration
SUPABASE_URL = os.getenv("SUPABASE_URL")
SUPABASE_SERVICE_KEY = os.getenv("SUPABASE_SERVICE_KEY")

# Storage buckets
DASHBOARD_IMAGES_BUCKET = "dashboard-images"
ENGINE_SOUNDS_BUCKET = "engine-sounds"

class DatabaseService:
    def __init__(self):
        if not SUPABASE_URL or not SUPABASE_SERVICE_KEY:
            raise ValueError("SUPABASE_URL and SUPABASE_SERVICE_KEY environment variables are required")
        self.supabase: Client = create_client(SUPABASE_URL, SUPABASE_SERVICE_KEY)
    
    async def get_user_by_id(self, user_id: str) -> Optional[Dict[str, Any]]:
        """
        Get user by user_id from existing users table
        """
        try:
            result = await asyncio.to_thread(
                self.supabase.table("users").select("*").eq("user_id", user_id).execute
            )
            
            if result.data and len(result.data) > 0:
                return result.data[0]
            return None
            
        except Exception as e:
            logger.error(f"Error getting user by ID: {e}")
            return None
    
    async def save_diagnostic_record(self, diagnostic_data: Dict[str, Any]) -> str:
        """
        Save diagnostic record to existing diagnostic_records table
        """
        try:
            # Map to existing table structure
            record = {
                "user_id": diagnostic_data["user_id"],
                "diagnostic_type": diagnostic_data["diagnosis_type"],  # matches your schema
                "image_path": diagnostic_data.get("image_path"),
                "audio_path": diagnostic_data.get("audio_path"),
                "status": diagnostic_data.get("status", "completed"),
                "created_at": diagnostic_data.get("created_at", datetime.utcnow().isoformat())
            }
            
            result = await asyncio.to_thread(
                self.supabase.table("diagnostic_records").insert(record).execute
            )
            
            if result.data and len(result.data) > 0:
                diagnostic_id = str(result.data[0]["diagnostic_id"])
                logger.info(f"Diagnostic record saved: {diagnostic_id}")
                return diagnostic_id
            else:
                raise Exception("Failed to save diagnostic record")
                
        except Exception as e:
            logger.error(f"Error saving diagnostic record: {e}")
            raise
    
    async def save_diagnostic_result(self, result_data: Dict[str, Any]) -> bool:
        """
        Save diagnostic analysis results to existing diagnostic_results table
        """
        try:
            # Map to existing table structure
            result_record = {
                "diagnostic_id": result_data["diagnostic_id"],
                "detected_lights": result_data.get("detected_lights", []),
                "detected_sounds": result_data.get("detected_sounds", []),
                "confidence_score": result_data.get("confidence_score", 0.0),
                "urgency_level": self._map_urgency_level(result_data.get("urgency_level", "monitoring")),
                "analysis_results": result_data.get("analysis_results", {}),
                "recommendations": result_data.get("recommendations", []),
                "created_at": result_data.get("created_at", datetime.utcnow().isoformat())
            }
            
            result = await asyncio.to_thread(
                self.supabase.table("diagnostic_results").insert(result_record).execute
            )
            
            if result.data and len(result.data) > 0:
                logger.info(f"Diagnostic result saved: {result_data['diagnostic_id']}")
                return True
            else:
                raise Exception("Failed to save diagnostic result")
                
        except Exception as e:
            logger.error(f"Error saving diagnostic result: {e}")
            return False
    
    def _map_urgency_level(self, backend_urgency: str) -> str:
        """
        Map backend urgency levels to database urgency levels
        """
        mapping = {
            "low": "monitoring",
            "moderate": "soon", 
            "high": "soon",
            "critical": "immediate"
        }
        return mapping.get(backend_urgency, "monitoring")
    
    async def get_user_diagnosis_history(self, user_id: str, limit: int = 20) -> List[Dict[str, Any]]:
        """
        Get user's diagnosis history from existing tables
        """
        try:
            result = await asyncio.to_thread(
                self.supabase.table("diagnostic_records")
                .select("*, diagnostic_results(*)")
                .eq("user_id", user_id)
                .order("created_at", desc=True)
                .limit(limit)
                .execute
            )
            
            return result.data if result.data else []
            
        except Exception as e:
            logger.error(f"Error getting diagnosis history: {e}")
            return []
    
    async def get_diagnostic_details(self, diagnostic_id: str) -> Optional[Dict[str, Any]]:
        """
        Get detailed diagnostic information by ID
        """
        try:
            result = await asyncio.to_thread(
                self.supabase.table("diagnostic_records")
                .select("*, diagnostic_results(*)")
                .eq("diagnostic_id", diagnostic_id)
                .execute
            )
            
            if result.data and len(result.data) > 0:
                return result.data[0]
            return None
            
        except Exception as e:
            logger.error(f"Error getting diagnostic details: {e}")
            return None
    
    async def upload_dashboard_image(self, file_content: bytes, user_id: str, diagnostic_id: str) -> Tuple[str, str]:
        """
        Upload dashboard image to dashboard-images bucket
        """
        try:
            file_path = f"{user_id}/{diagnostic_id}.jpg"
            
            # Upload file to dashboard-images bucket
            result = await asyncio.to_thread(
                self.supabase.storage.from_(DASHBOARD_IMAGES_BUCKET).upload,
                file_path,
                file_content
            )
            
            if result:
                # Get public URL
                public_url = self.supabase.storage.from_(DASHBOARD_IMAGES_BUCKET).get_public_url(file_path)
                
                logger.info(f"Dashboard image uploaded successfully: {file_path}")
                return file_path, public_url
            else:
                raise Exception("Failed to upload dashboard image")
                
        except Exception as e:
            logger.error(f"Error uploading dashboard image: {e}")
            raise
    
    async def upload_engine_sound(self, file_content: bytes, user_id: str, diagnostic_id: str) -> Tuple[str, str]:
        """
        Upload engine sound to engine-sounds bucket
        """
        try:
            file_path = f"{user_id}/{diagnostic_id}.wav"
            
            # Upload file to engine-sounds bucket
            result = await asyncio.to_thread(
                self.supabase.storage.from_(ENGINE_SOUNDS_BUCKET).upload,
                file_path,
                file_content
            )
            
            if result:
                # Get public URL
                public_url = self.supabase.storage.from_(ENGINE_SOUNDS_BUCKET).get_public_url(file_path)
                
                logger.info(f"Engine sound uploaded successfully: {file_path}")
                return file_path, public_url
            else:
                raise Exception("Failed to upload engine sound")
                
        except Exception as e:
            logger.error(f"Error uploading engine sound: {e}")
            raise
    
    async def delete_diagnostic_record(self, diagnostic_id: str) -> bool:
        """
        Delete diagnostic record and associated results
        """
        try:
            # Delete diagnostic results first (foreign key constraint)
            await asyncio.to_thread(
                self.supabase.table("diagnostic_results")
                .delete()
                .eq("diagnostic_id", diagnostic_id)
                .execute
            )
            
            # Delete diagnostic record
            result = await asyncio.to_thread(
                self.supabase.table("diagnostic_records")
                .delete()
                .eq("diagnostic_id", diagnostic_id)
                .execute
            )
            
            return True
            
        except Exception as e:
            logger.error(f"Error deleting diagnostic record: {e}")
            return False

# Global database service instance
db = DatabaseService()
