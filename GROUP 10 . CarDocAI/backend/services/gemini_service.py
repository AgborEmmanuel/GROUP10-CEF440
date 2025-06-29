import google.generativeai as genai
import os
import logging
import json
from typing import Dict, Any, List
import asyncio

logger = logging.getLogger(__name__)

class GeminiService:
    def __init__(self):
        api_key = os.getenv("GEMINI_API_KEY")
        if not api_key:
            raise ValueError("GEMINI_API_KEY environment variable is required")
        
        genai.configure(api_key=api_key)
        self.model = genai.GenerativeModel('gemini-1.5-flash')
        logger.info("✅ Enhanced Gemini AI service initialized")
    
    async def analyze_dashboard_lights(self, image_analysis: Dict[str, Any]) -> Dict[str, Any]:
        """
        Analyze dashboard warning lights using Gemini AI with improved fault detection
        """
        try:
            detected_lights = image_analysis.get("detected_lights", [])
            
            # Create detailed context about detected lights
            lights_context = ""
            if detected_lights:
                for light in detected_lights:
                    color = light.get("color", "unknown")
                    position = light.get("position", {})
                    brightness = light.get("brightness", 0)
                    lights_context += f"- {color.upper()} warning light detected at position {position} with brightness {brightness}\n"
            else:
                lights_context = "No specific warning lights detected in image analysis"
            
            prompt = f"""
            You are an expert automotive diagnostic AI with 20+ years of experience. Analyze this car dashboard image and provide a precise, actionable diagnosis.

            DETECTED WARNING LIGHTS:
            {lights_context}

            IMAGE ANALYSIS DATA:
            {json.dumps(image_analysis, indent=2)}

            CRITICAL INSTRUCTIONS:
            1. Identify SPECIFIC car problems, not generic issues
            2. Map light colors to urgency: RED=critical, YELLOW/ORANGE=warning, GREEN/BLUE=normal
            3. Provide ACTIONABLE repair recommendations
            4. Generate SPECIFIC YouTube search keywords
            5. Give clear safety assessment

            Respond with ONLY this JSON format (no markdown, no extra text):
            {{
                "detected_issues": ["Specific fault name like 'Brake Fluid Low' or 'Engine Oil Pressure Warning'"],
                "confidence_score": 0.85,
                "urgency_level": "critical|warning|normal",
                "overall_assessment": {{
                    "severity": "critical|warning|normal",
                    "safe_to_drive": true/false,
                    "immediate_action_required": true/false,
                    "estimated_repair_cost": "$50-200"
                }},
                "recommendations": [
                    "Check brake fluid reservoir level",
                    "Add DOT 3 brake fluid if low",
                    "Visit mechanic if fluid is full but light persists"
                ],
                "repair_keywords": [
                    "brake fluid warning light fix",
                    "how to add brake fluid",
                    "brake fluid reservoir location"
                ],
                "safety_info": {{
                    "driving_safety": "Safe for short distances at low speeds",
                    "immediate_actions": "Check brake pedal feel before driving",
                    "warning_signs": "Soft brake pedal, grinding noises"
                }}
            }}

            FAULT IDENTIFICATION RULES:
            - Red brake light = "Brake System Warning" or "Brake Fluid Low"
            - Red oil light = "Engine Oil Pressure Critical"
            - Yellow engine light = "Check Engine System"
            - Red temperature light = "Engine Overheating Critical"
            - Yellow ABS light = "ABS System Malfunction"
            - Red battery light = "Charging System Failure"
            
            Be SPECIFIC with fault names and PRACTICAL with recommendations.
            """
            
            response = await asyncio.to_thread(
                self.model.generate_content, prompt
            )
            
            # Clean and parse JSON response
            try:
                response_text = response.text.strip()
                # Remove markdown formatting if present
                if response_text.startswith('```json'):
                    response_text = response_text[7:]
                if response_text.endswith('```'):
                    response_text = response_text[:-3]
                
                analysis = json.loads(response_text)
                
                # Validate and enhance the response
                analysis = self._validate_and_enhance_dashboard_analysis(analysis, detected_lights)
                
                logger.info("✅ Dashboard analysis completed with specific fault detection")
                return analysis
                
            except json.JSONDecodeError as e:
                logger.warning(f"⚠️ Failed to parse Gemini JSON response: {e}")
                return self._create_enhanced_fallback_dashboard_analysis(detected_lights)
                
        except Exception as e:
            logger.error(f"Error in Gemini dashboard analysis: {e}")
            return self._create_enhanced_fallback_dashboard_analysis(detected_lights)
    
    async def analyze_engine_sound(self, audio_analysis: Dict[str, Any]) -> Dict[str, Any]:
        """
        Enhanced engine sound analysis using Gemini AI with structured audio data
        """
        try:
            detected_faults = audio_analysis.get("detected_faults", [])
            frequency_analysis = audio_analysis.get("frequency_analysis", {})
            decibel_analysis = audio_analysis.get("decibel_analysis", {})
            anomaly_analysis = audio_analysis.get("anomaly_analysis", {})
            audio_quality = audio_analysis.get("audio_quality", {})
            
            # Create structured context for Gemini
            audio_context = f"""
            DETECTED ENGINE FAULTS:
            {json.dumps([f["display_name"] for f in detected_faults], indent=2)}
            
            FREQUENCY ANALYSIS:
            - Dominant Frequency: {frequency_analysis.get('dominant_frequency', 0):.1f} Hz
            - Spectral Centroid: {frequency_analysis.get('spectral_centroid', 0):.1f} Hz
            - Peak Frequencies: {frequency_analysis.get('peak_frequencies', [])[:5]}
            - Frequency Band Distribution: {frequency_analysis.get('frequency_bands', {})}
            
            DECIBEL ANALYSIS:
            - Average Level: {decibel_analysis.get('mean_db', 0):.1f} dB
            - Maximum Level: {decibel_analysis.get('max_db', 0):.1f} dB
            - Dynamic Range: {decibel_analysis.get('dynamic_range_db', 0):.1f} dB
            - Volume Category: {decibel_analysis.get('volume_category', 'unknown')}
            
            ANOMALY ANALYSIS:
            - Anomaly Percentage: {anomaly_analysis.get('anomaly_percentage', 0):.1f}%
            - Anomaly Count: {anomaly_analysis.get('anomaly_count', 0)}
            - Average Anomaly Duration: {anomaly_analysis.get('avg_anomaly_duration', 0):.2f} seconds
            
            AUDIO QUALITY:
            - Quality Score: {audio_quality.get('score', 0):.2f}
            - Quality Rating: {audio_quality.get('rating', 'unknown')}
            - Signal-to-Noise Ratio: {audio_quality.get('snr_db', 0):.1f} dB
            """
            
            prompt = f"""
            You are an expert automotive sound diagnostic AI with 25+ years of experience in engine fault detection through audio analysis.

            COMPREHENSIVE AUDIO ANALYSIS:
            {audio_context}

            DETECTED FAULT DETAILS:
            {json.dumps(detected_faults, indent=2)}

            CRITICAL INSTRUCTIONS:
            1. Analyze the structured audio data to identify SPECIFIC engine problems
            2. Consider frequency patterns, decibel levels, and anomaly durations
            3. Map detected faults to urgency levels: CRITICAL (immediate stop), WARNING (schedule repair), NORMAL (monitor)
            4. Provide SPECIFIC repair recommendations based on detected faults
            5. Generate TARGETED YouTube search keywords for each detected issue
            6. Give clear safety assessment based on fault severity

            Respond with ONLY this JSON format (no markdown, no extra text):
            {{
                "detected_issues": ["Specific engine fault like 'Timing Chain Rattle' or 'Worn Engine Bearings'"],
                "confidence_score": 0.80,
                "urgency_level": "critical|warning|normal",
                "overall_assessment": {{
                    "severity": "critical|warning|normal",
                    "safe_to_drive": true/false,
                    "immediate_action_required": true/false,
                    "estimated_repair_cost": "$200-800"
                }},
                "recommendations": [
                    "Check engine oil level and quality immediately",
                    "Inspect timing chain tensioner for wear",
                    "Schedule comprehensive engine diagnostic"
                ],
                "repair_keywords": [
                    "timing chain rattle repair",
                    "engine bearing noise fix",
                    "engine oil change procedure"
                ],
                "safety_info": {{
                    "driving_safety": "Avoid high RPM and long trips",
                    "immediate_actions": "Check oil level before driving",
                    "warning_signs": "Metal grinding, loss of power, smoke"
                }}
            }}

            FAULT SEVERITY MAPPING:
            - Engine Knock, Worn Bearings, Timing Chain Issues = CRITICAL
            - Belt Squeal, Valve Noise, CV Joint Clicking = WARNING  
            - Exhaust Noise, Minor Ticking = NORMAL
            
            Use the frequency data and decibel levels to determine fault confidence.
            Higher frequencies (>4000Hz) + high dB = Belt/Brake issues
            Mid frequencies (1000-4000Hz) + rhythmic = Timing/Valve issues
            Low frequencies (<1000Hz) + high dB = Bearing/Knock issues
            """
            
            response = await asyncio.to_thread(
                self.model.generate_content, prompt
            )
            
            # Clean and parse JSON response
            try:
                response_text = response.text.strip()
                # Remove markdown formatting if present
                if response_text.startswith('```json'):
                    response_text = response_text[7:]
                if response_text.endswith('```'):
                    response_text = response_text[:-3]
                
                analysis = json.loads(response_text)
                
                # Validate and enhance the response
                analysis = self._validate_and_enhance_engine_analysis(analysis, detected_faults, audio_analysis)
                
                logger.info("✅ Enhanced engine sound analysis completed with specific fault detection")
                return analysis
                
            except json.JSONDecodeError as e:
                logger.warning(f"⚠️ Failed to parse Gemini JSON response: {e}")
                return self._create_enhanced_fallback_engine_analysis(detected_faults, audio_analysis)
                
        except Exception as e:
            logger.error(f"Error in Gemini engine sound analysis: {e}")
            return self._create_enhanced_fallback_engine_analysis(detected_faults, audio_analysis)
    
    def _validate_and_enhance_dashboard_analysis(self, analysis: Dict[str, Any], detected_lights: List[Dict]) -> Dict[str, Any]:
        """Validate and enhance dashboard analysis results"""
        
        # Map light colors to urgency levels
        if detected_lights:
            max_urgency = "normal"
            for light in detected_lights:
                color = light.get("color", "").lower()
                if color in ["red"]:
                    max_urgency = "critical"
                    break
                elif color in ["yellow", "orange", "amber"]:
                    max_urgency = "warning"
                elif color in ["green", "blue"]:
                    max_urgency = "normal"
            
            # Override urgency if detected from lights
            analysis["urgency_level"] = max_urgency
        
        # Ensure confidence score is reasonable
        if "confidence_score" not in analysis or analysis["confidence_score"] < 0.6:
            analysis["confidence_score"] = 0.75
        
        # Ensure we have specific issues
        if not analysis.get("detected_issues") or analysis["detected_issues"] == ["Unable to analyze dashboard"]:
            if detected_lights:
                analysis["detected_issues"] = [f"{light.get('color', 'Unknown').title()} Warning Light Active" for light in detected_lights]
            else:
                analysis["detected_issues"] = ["Dashboard Warning System Check Required"]
        
        # Ensure we have repair keywords
        if not analysis.get("repair_keywords"):
            analysis["repair_keywords"] = ["dashboard warning light fix", "car diagnostic scan", "warning light meaning"]
        
        return analysis
    
    def _validate_and_enhance_engine_analysis(self, analysis: Dict[str, Any], detected_faults: List[Dict], audio_analysis: Dict) -> Dict[str, Any]:
        """Validate and enhance engine analysis results"""
        
        # Map detected faults to urgency levels
        if detected_faults:
            max_urgency = "normal"
            for fault in detected_faults:
                fault_urgency = fault.get('urgency', 'normal')
                if fault_urgency == 'critical':
                    max_urgency = "critical"
                    break
                elif fault_urgency == 'warning' and max_urgency != 'critical':
                    max_urgency = "warning"
            
            # Override urgency if detected from faults
            analysis["urgency_level"] = max_urgency
        
        # Ensure confidence score is reasonable based on audio quality
        audio_quality_score = audio_analysis.get("audio_quality", {}).get("score", 0.5)
        if "confidence_score" not in analysis or analysis["confidence_score"] < 0.5:
            # Base confidence on audio quality and number of detected faults
            base_confidence = audio_quality_score * 0.6
            if detected_faults:
                fault_confidence = sum([f.get('confidence', 0) for f in detected_faults]) / len(detected_faults)
                analysis["confidence_score"] = min((base_confidence + fault_confidence * 0.4), 0.95)
            else:
                analysis["confidence_score"] = base_confidence
        
        # Ensure we have specific issues
        if not analysis.get("detected_issues") or analysis["detected_issues"] == ["Unable to analyze engine sound"]:
            if detected_faults:
                analysis["detected_issues"] = [fault.get('display_name', fault.get('name', 'Unknown Fault')) for fault in detected_faults]
            else:
                analysis["detected_issues"] = ["Engine Sound Analysis Completed - No Critical Issues Detected"]
        
        # Ensure we have repair keywords
        if not analysis.get("repair_keywords"):
            if detected_faults:
                keywords = []
                for fault in detected_faults:
                    keywords.extend(fault.get('keywords', []))
                analysis["repair_keywords"] = list(set(keywords))[:6]  # Remove duplicates, limit to 6
            else:
                analysis["repair_keywords"] = ["engine maintenance", "engine diagnostic", "car engine inspection"]
        
        return analysis
    
    def _create_enhanced_fallback_dashboard_analysis(self, detected_lights: List[Dict]) -> Dict[str, Any]:
        """Create enhanced fallback analysis for dashboard when Gemini fails"""
        
        if not detected_lights:
            return {
                "detected_issues": ["Dashboard System Check Required"],
                "confidence_score": 0.70,
                "urgency_level": "normal",
                "overall_assessment": {
                    "severity": "normal",
                    "safe_to_drive": True,
                    "immediate_action_required": False,
                    "estimated_repair_cost": "$0-50"
                },
                "recommendations": [
                    "Perform visual dashboard inspection",
                    "Check owner's manual for warning light meanings",
                    "Schedule routine diagnostic if concerned"
                ],
                "repair_keywords": [
                    "dashboard warning lights guide",
                    "car warning lights meaning",
                    "dashboard diagnostic check"
                ],
                "safety_info": {
                    "driving_safety": "Safe to drive normally",
                    "immediate_actions": "Monitor dashboard for any new lights",
                    "warning_signs": "New warning lights appearing"
                }
            }
        
        # Analyze detected lights for fallback
        urgency_level = "normal"
        issues = []
        keywords = []
        
        for light in detected_lights:
            color = light.get("color", "unknown").lower()
            
            if color == "red":
                urgency_level = "critical"
                issues.append(f"Critical {color.title()} Warning Light")
                keywords.extend([f"{color} warning light fix", f"{color} dashboard light repair"])
            elif color in ["yellow", "orange", "amber"]:
                if urgency_level != "critical":
                    urgency_level = "warning"
                issues.append(f"{color.title()} Caution Light Active")
                keywords.extend([f"{color} warning light meaning", f"{color} dashboard light fix"])
            else:
                issues.append(f"{color.title()} Indicator Light")
                keywords.extend([f"{color} light meaning", "dashboard indicator"])
        
        return {
            "detected_issues": issues,
            "confidence_score": 0.75,
            "urgency_level": urgency_level,
            "overall_assessment": {
                "severity": urgency_level,
                "safe_to_drive": urgency_level != "critical",
                "immediate_action_required": urgency_level == "critical",
                "estimated_repair_cost": "$50-300" if urgency_level == "critical" else "$25-150"
            },
            "recommendations": [
                "Identify specific warning light meanings",
                "Check vehicle owner's manual",
                "Schedule diagnostic scan if multiple lights active",
                "Do not ignore red warning lights"
            ],
            "repair_keywords": list(set(keywords))[:5],  # Remove duplicates and limit
            "safety_info": {
                "driving_safety": "Exercise caution" if urgency_level == "critical" else "Safe for normal driving",
                "immediate_actions": "Stop and check if red lights are flashing",
                "warning_signs": "Multiple warning lights, unusual vehicle behavior"
            }
        }
    
    def _create_enhanced_fallback_engine_analysis(self, detected_faults: List[Dict], audio_analysis: Dict) -> Dict[str, Any]:
        """Create enhanced fallback analysis for engine when Gemini fails"""
        
        if not detected_faults:
            audio_quality = audio_analysis.get("audio_quality", {})
            quality_score = audio_quality.get("score", 0.5)
            
            return {
                "detected_issues": ["Engine Sound Analysis Completed"],
                "confidence_score": quality_score,
                "urgency_level": "normal",
                "overall_assessment": {
                    "severity": "normal",
                    "safe_to_drive": True,
                    "immediate_action_required": False,
                    "estimated_repair_cost": "$0-100"
                },
                "recommendations": [
                    "Continue monitoring engine sounds during operation",
                    "Perform regular engine maintenance",
                    "Schedule routine engine inspection if concerned"
                ],
                "repair_keywords": [
                    "engine maintenance guide",
                    "engine sound diagnosis",
                    "preventive car maintenance"
                ],
                "safety_info": {
                    "driving_safety": "Safe to drive normally",
                    "immediate_actions": "Monitor engine performance",
                    "warning_signs": "Unusual noises, performance changes"
                }
            }
        
        # Analyze detected faults for fallback
        urgency_level = "normal"
        issues = []
        keywords = []
        
        for fault in detected_faults:
            fault_urgency = fault.get('urgency', 'normal')
            fault_name = fault.get('display_name', fault.get('name', 'Unknown Fault'))
            fault_keywords = fault.get('keywords', [])
            
            if fault_urgency == 'critical':
                urgency_level = "critical"
                issues.append(f"{fault_name} - Critical Issue")
            elif fault_urgency == 'warning' and urgency_level != 'critical':
                urgency_level = "warning"
                issues.append(f"{fault_name} - Needs Attention")
            else:
                issues.append(f"{fault_name} Detected")
            
            keywords.extend(fault_keywords)
        
        return {
            "detected_issues": issues,
            "confidence_score": 0.75,
            "urgency_level": urgency_level,
            "overall_assessment": {
                "severity": urgency_level,
                "safe_to_drive": urgency_level != "critical",
                "immediate_action_required": urgency_level == "critical",
                "estimated_repair_cost": "$200-1000" if urgency_level == "critical" else "$100-500"
            },
            "recommendations": [
                "Have engine inspected by qualified mechanic",
                "Check engine oil level and condition",
                "Avoid high RPM operation until diagnosed" if urgency_level == "critical" else "Monitor engine performance",
                "Schedule repair appointment soon" if urgency_level != "normal" else "Continue regular maintenance"
            ],
            "repair_keywords": list(set(keywords))[:6],  # Remove duplicates and limit
            "safety_info": {
                "driving_safety": "Avoid aggressive driving" if urgency_level == "critical" else "Drive with normal caution",
                "immediate_actions": "Check oil level and coolant before driving",
                "warning_signs": "Loss of power, unusual vibrations, smoke, overheating"
            }
        }

# Global service instance
gemini_service = GeminiService()
