import cv2
import numpy as np
import logging
from typing import Dict, Any, List, Tuple
import io
from PIL import Image
import asyncio

logger = logging.getLogger(__name__)

class ImageAnalyzer:
    def __init__(self):
        logger.info("✅ Image analyzer service initialized")
        
        # Color ranges for warning light detection (HSV)
        self.color_ranges = {
            'red': [
                (0, 50, 50), (10, 255, 255),    # Lower red range
                (170, 50, 50), (180, 255, 255)  # Upper red range
            ],
            'yellow': [(20, 50, 50), (30, 255, 255)],
            'orange': [(10, 50, 50), (20, 255, 255)],
            'green': [(40, 50, 50), (80, 255, 255)],
            'blue': [(100, 50, 50), (130, 255, 255)],
            'amber': [(15, 50, 50), (25, 255, 255)]
        }
    
    async def analyze_dashboard_image(self, image_data: bytes) -> Dict[str, Any]:
        """
        Analyze dashboard image to detect warning lights with improved accuracy
        """
        try:
            # Convert bytes to OpenCV image
            image_array = np.frombuffer(image_data, np.uint8)
            image = cv2.imdecode(image_array, cv2.IMREAD_COLOR)
            
            if image is None:
                raise ValueError("Could not decode image")
            
            # Detect dashboard area
            dashboard_detected = await self._detect_dashboard_area(image)
            
            # Detect warning lights
            detected_lights = await self._detect_warning_lights(image)
            
            # Analyze image quality
            image_quality = await self._analyze_image_quality(image)
            
            # Calculate overall confidence
            overall_confidence = self._calculate_overall_confidence(detected_lights, dashboard_detected, image_quality)
            
            analysis_result = {
                "dashboard_detected": dashboard_detected,
                "detected_lights": detected_lights,
                "image_quality": image_quality,
                "overall_confidence": overall_confidence,
                "analysis_metadata": {
                    "image_dimensions": f"{image.shape[1]}x{image.shape[0]}",
                    "total_lights_found": len(detected_lights),
                    "processing_successful": True
                }
            }
            
            logger.info(f"✅ Dashboard image analysis completed - found {len(detected_lights)} warning lights")
            return analysis_result
            
        except Exception as e:
            logger.error(f"Error analyzing dashboard image: {e}")
            return {
                "dashboard_detected": False,
                "detected_lights": [],
                "image_quality": {"score": 0.5, "issues": ["Analysis failed"]},
                "overall_confidence": 0.3,
                "analysis_metadata": {
                    "processing_successful": False,
                    "error": str(e)
                }
            }
    
    async def _detect_dashboard_area(self, image: np.ndarray) -> bool:
        """Detect if image contains a car dashboard"""
        try:
            # Convert to grayscale
            gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
            
            # Look for dashboard characteristics
            # 1. Horizontal lines (dashboard edge)
            horizontal_kernel = cv2.getStructuringElement(cv2.MORPH_RECT, (25, 1))
            horizontal_lines = cv2.morphologyEx(gray, cv2.MORPH_OPEN, horizontal_kernel)
            
            # 2. Circular shapes (gauges, warning lights)
            circles = cv2.HoughCircles(
                gray, cv2.HOUGH_GRADIENT, 1, 20,
                param1=50, param2=30, minRadius=5, maxRadius=50
            )
            
            # 3. Edge density (dashboards have many edges)
            edges = cv2.Canny(gray, 50, 150)
            edge_density = np.sum(edges > 0) / (edges.shape[0] * edges.shape[1])
            
            # Dashboard detection criteria
            has_horizontal_structure = np.sum(horizontal_lines > 0) > 100
            has_circular_elements = circles is not None and len(circles[0]) > 2
            has_good_edge_density = 0.05 < edge_density < 0.3
            
            dashboard_detected = has_horizontal_structure or has_circular_elements or has_good_edge_density
            
            logger.info(f"Dashboard detection: {dashboard_detected} (edges: {edge_density:.3f}, circles: {circles is not None})")
            return dashboard_detected
            
        except Exception as e:
            logger.error(f"Error detecting dashboard area: {e}")
            return False
    
    async def _detect_warning_lights(self, image: np.ndarray) -> List[Dict[str, Any]]:
        """Detect warning lights in the dashboard image"""
        try:
            detected_lights = []
            
            # Convert to HSV for better color detection
            hsv = cv2.cvtColor(image, cv2.COLOR_BGR2HSV)
            
            # Detect each color
            for color_name, ranges in self.color_ranges.items():
                lights = await self._detect_color_lights(hsv, color_name, ranges)
                detected_lights.extend(lights)
            
            # Remove overlapping detections
            detected_lights = self._remove_overlapping_lights(detected_lights)
            
            # Sort by confidence
            detected_lights.sort(key=lambda x: x.get('confidence', 0), reverse=True)
            
            return detected_lights
            
        except Exception as e:
            logger.error(f"Error detecting warning lights: {e}")
            return []
    
    async def _detect_color_lights(self, hsv_image: np.ndarray, color_name: str, color_ranges: List[Tuple]) -> List[Dict[str, Any]]:
        """Detect lights of a specific color"""
        try:
            # Create mask for the color
            if color_name == 'red':
                # Red has two ranges in HSV
                mask1 = cv2.inRange(hsv_image, color_ranges[0], color_ranges[1])
                mask2 = cv2.inRange(hsv_image, color_ranges[2], color_ranges[3])
                mask = cv2.bitwise_or(mask1, mask2)
            else:
                mask = cv2.inRange(hsv_image, color_ranges[0], color_ranges[1])
            
            # Find contours
            contours, _ = cv2.findContours(mask, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
            
            lights = []
            for contour in contours:
                # Filter by area
                area = cv2.contourArea(contour)
                if 20 < area < 2000:  # Reasonable size for warning lights
                    
                    # Get bounding rectangle
                    x, y, w, h = cv2.boundingRect(contour)
                    
                    # Calculate properties
                    aspect_ratio = w / h if h > 0 else 0
                    
                    # Get center point
                    center_x = x + w // 2
                    center_y = y + h // 2
                    
                    # Calculate brightness in the region
                    roi = hsv_image[y:y+h, x:x+w]
                    brightness = np.mean(roi[:, :, 2]) / 255.0  # V channel normalized
                    
                    # Calculate confidence based on shape and brightness
                    confidence = self._calculate_light_confidence(area, aspect_ratio, brightness)
                    
                    if confidence > 0.3:  # Minimum confidence threshold
                        light_info = {
                            "color": color_name,
                            "position": {"x": center_x, "y": center_y},
                            "bounding_box": {"x": x, "y": y, "width": w, "height": h},
                            "area": int(area),
                            "aspect_ratio": round(aspect_ratio, 2),
                            "brightness": round(brightness, 2),
                            "confidence": round(confidence, 2),
                            "severity": self._map_color_to_severity(color_name)
                        }
                        lights.append(light_info)
            
            return lights
            
        except Exception as e:
            logger.error(f"Error detecting {color_name} lights: {e}")
            return []
    
    def _calculate_light_confidence(self, area: float, aspect_ratio: float, brightness: float) -> float:
        """Calculate confidence score for a detected light"""
        confidence = 0.0
        
        # Area score (prefer medium-sized areas)
        if 50 < area < 500:
            confidence += 0.4
        elif 20 < area < 1000:
            confidence += 0.2
        
        # Aspect ratio score (prefer roughly circular/square shapes)
        if 0.5 < aspect_ratio < 2.0:
            confidence += 0.3
        elif 0.3 < aspect_ratio < 3.0:
            confidence += 0.1
        
        # Brightness score (warning lights should be reasonably bright)
        if brightness > 0.6:
            confidence += 0.3
        elif brightness > 0.4:
            confidence += 0.2
        elif brightness > 0.2:
            confidence += 0.1
        
        return min(confidence, 1.0)
    
    def _map_color_to_severity(self, color: str) -> str:
        """Map warning light color to severity level"""
        severity_map = {
            'red': 'critical',
            'orange': 'high',
            'amber': 'high',
            'yellow': 'medium',
            'blue': 'low',
            'green': 'low'
        }
        return severity_map.get(color, 'medium')
    
    def _remove_overlapping_lights(self, lights: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
        """Remove overlapping light detections"""
        if len(lights) <= 1:
            return lights
        
        # Sort by confidence (highest first)
        lights.sort(key=lambda x: x.get('confidence', 0), reverse=True)
        
        filtered_lights = []
        for light in lights:
            is_duplicate = False
            light_pos = light['position']
            
            for existing_light in filtered_lights:
                existing_pos = existing_light['position']
                
                # Calculate distance between centers
                distance = np.sqrt(
                    (light_pos['x'] - existing_pos['x'])**2 + 
                    (light_pos['y'] - existing_pos['y'])**2
                )
                
                # If too close, consider it a duplicate
                if distance < 30:  # 30 pixel threshold
                    is_duplicate = True
                    break
            
            if not is_duplicate:
                filtered_lights.append(light)
        
        return filtered_lights
    
    async def _analyze_image_quality(self, image: np.ndarray) -> Dict[str, Any]:
        """Analyze image quality for dashboard analysis"""
        try:
            # Convert to grayscale
            gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
            
            # Calculate sharpness (Laplacian variance)
            laplacian_var = cv2.Laplacian(gray, cv2.CV_64F).var()
            sharpness_score = min(laplacian_var / 1000, 1.0)  # Normalize
            
            # Calculate brightness
            brightness = np.mean(gray) / 255.0
            
            # Calculate contrast
            contrast = np.std(gray) / 255.0
            
            # Overall quality score
            quality_score = (sharpness_score * 0.4 + 
                           min(brightness * 2, 1.0) * 0.3 + 
                           contrast * 0.3)
            
            # Identify issues
            issues = []
            if sharpness_score < 0.3:
                issues.append("Image appears blurry")
            if brightness < 0.2:
                issues.append("Image too dark")
            elif brightness > 0.9:
                issues.append("Image overexposed")
            if contrast < 0.1:
                issues.append("Low contrast")
            
            return {
                "score": round(quality_score, 2),
                "sharpness": round(sharpness_score, 2),
                "brightness": round(brightness, 2),
                "contrast": round(contrast, 2),
                "issues": issues
            }
            
        except Exception as e:
            logger.error(f"Error analyzing image quality: {e}")
            return {
                "score": 0.5,
                "issues": ["Quality analysis failed"]
            }
    
    def _calculate_overall_confidence(self, detected_lights: List[Dict], dashboard_detected: bool, image_quality: Dict) -> float:
        """Calculate overall confidence in the analysis"""
        confidence = 0.0
        
        # Base confidence from dashboard detection
        if dashboard_detected:
            confidence += 0.3
        
        # Confidence from image quality
        quality_score = image_quality.get('score', 0.5)
        confidence += quality_score * 0.3
        
        # Confidence from detected lights
        if detected_lights:
            avg_light_confidence = np.mean([light.get('confidence', 0) for light in detected_lights])
            confidence += avg_light_confidence * 0.4
        else:
            confidence += 0.2  # Some confidence even if no lights detected
        
        return min(confidence, 1.0)

# Global service instance
image_analyzer = ImageAnalyzer()
