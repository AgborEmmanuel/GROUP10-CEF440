import librosa
import numpy as np
import logging
from typing import Dict, Any, List, Tuple
import io
import tempfile
import os
import asyncio
from scipy.signal import find_peaks
import warnings
warnings.filterwarnings('ignore')

logger = logging.getLogger(__name__)

class AudioAnalyzer:
    def __init__(self):
        logger.info("✅ Enhanced Audio analyzer service initialized")
        
        # Enhanced engine sound patterns with specific fault mapping
        self.engine_fault_patterns = {
            'spark_plug_misfire': {
                'frequency_range': (800, 2500),
                'characteristics': ['irregular', 'popping', 'intermittent'],
                'severity': 'warning',
                'urgency': 'warning',
                'keywords': ['spark plug misfire', 'engine misfire repair', 'ignition system fix']
            },
            'timing_chain_rattle': {
                'frequency_range': (1200, 4000),
                'characteristics': ['metallic', 'startup_noise', 'chain_rattle'],
                'severity': 'critical',
                'urgency': 'critical',
                'keywords': ['timing chain rattle', 'timing chain replacement', 'engine timing noise']
            },
            'worn_engine_bearings': {
                'frequency_range': (500, 2000),
                'characteristics': ['deep_knocking', 'load_dependent', 'metallic'],
                'severity': 'critical',
                'urgency': 'critical',
                'keywords': ['engine bearing noise', 'rod bearing replacement', 'engine rebuild']
            },
            'valve_lifter_noise': {
                'frequency_range': (1000, 3000),
                'characteristics': ['ticking', 'rhythmic', 'top_end'],
                'severity': 'warning',
                'urgency': 'warning',
                'keywords': ['valve lifter noise', 'hydraulic lifter repair', 'valve adjustment']
            },
            'serpentine_belt_squeal': {
                'frequency_range': (2000, 8000),
                'characteristics': ['high_pitched', 'continuous', 'belt_related'],
                'severity': 'warning',
                'urgency': 'warning',
                'keywords': ['serpentine belt squeal', 'belt replacement', 'belt tensioner repair']
            },
            'brake_pad_squeal': {
                'frequency_range': (3000, 10000),
                'characteristics': ['very_high_pitched', 'braking_only', 'metallic'],
                'severity': 'warning',
                'urgency': 'warning',
                'keywords': ['brake pad squeal', 'brake pad replacement', 'brake service']
            },
            'cv_joint_clicking': {
                'frequency_range': (1500, 5000),
                'characteristics': ['clicking', 'turning_only', 'rhythmic'],
                'severity': 'warning',
                'urgency': 'warning',
                'keywords': ['CV joint clicking', 'CV joint replacement', 'axle repair']
            },
            'exhaust_leak': {
                'frequency_range': (100, 1000),
                'characteristics': ['hissing', 'continuous', 'exhaust_related'],
                'severity': 'normal',
                'urgency': 'normal',
                'keywords': ['exhaust leak repair', 'muffler replacement', 'exhaust system fix']
            },
            'turbo_whistle': {
                'frequency_range': (4000, 12000),
                'characteristics': ['whistling', 'boost_dependent', 'high_pitched'],
                'severity': 'warning',
                'urgency': 'warning',
                'keywords': ['turbo whistle', 'turbocharger repair', 'boost leak fix']
            },
            'engine_knock': {
                'frequency_range': (1000, 4000),
                'characteristics': ['knocking', 'load_dependent', 'metallic'],
                'severity': 'critical',
                'urgency': 'critical',
                'keywords': ['engine knock repair', 'carbon cleaning', 'octane booster']
            }
        }
        
        # Audio file format validation
        self.supported_formats = {
            'audio/wav': ['.wav'],
            'audio/mpeg': ['.mp3'],
            'audio/mp4': ['.m4a'],
            'audio/x-m4a': ['.m4a'],
            'audio/ogg': ['.ogg'],
            'audio/flac': ['.flac']
        }
    
    def validate_audio_format(self, content_type: str, filename: str) -> Tuple[bool, str]:
        """Validate audio file format"""
        try:
            # Check content type
            if not content_type.startswith('audio/'):
                return False, "File must be an audio file"
            
            # Check if supported format
            if content_type not in self.supported_formats:
                supported_types = list(self.supported_formats.keys())
                return False, f"Unsupported audio format. Supported formats: {supported_types}"
            
            # Check file extension if filename provided
            if filename:
                file_ext = os.path.splitext(filename.lower())[1]
                expected_extensions = self.supported_formats[content_type]
                if file_ext not in expected_extensions:
                    return False, f"File extension {file_ext} doesn't match content type {content_type}"
            
            return True, "Valid audio format"
            
        except Exception as e:
            logger.error(f"Error validating audio format: {e}")
            return False, "Audio format validation failed"
    
    async def analyze_engine_sound(self, audio_data: bytes) -> Dict[str, Any]:
        """
        Enhanced engine sound analysis with specific fault detection
        """
        try:
            # Save audio data to temporary file
            with tempfile.NamedTemporaryFile(delete=False, suffix='.wav') as temp_file:
                temp_file.write(audio_data)
                temp_file_path = temp_file.name
            
            try:
                # Load audio file with error handling
                try:
                    y, sr = librosa.load(temp_file_path, sr=22050)
                except Exception as load_error:
                    logger.error(f"Failed to load audio file: {load_error}")
                    return self._create_failed_analysis("Audio file could not be loaded or is corrupted")
                
                if len(y) == 0:
                    return self._create_failed_analysis("Audio file is empty")
                
                # Comprehensive audio analysis
                logger.info("🎧 Starting comprehensive engine sound analysis...")
                
                # 1. Audio quality assessment
                audio_quality = await self._analyze_audio_quality(y, sr)
                
                # 2. Frequency spectrum analysis
                frequency_analysis = await self._analyze_frequency_spectrum(y, sr)
                
                # 3. Sound pattern detection
                sound_patterns = await self._detect_sound_patterns(y, sr)
                
                # 4. Specific engine fault detection
                detected_faults = await self._detect_engine_faults(y, sr, frequency_analysis, sound_patterns)
                
                # 5. Decibel level analysis
                decibel_analysis = await self._analyze_decibel_levels(y, sr)
                
                # 6. Anomaly duration analysis
                anomaly_analysis = await self._analyze_anomaly_duration(y, sr)
                
                # 7. Calculate overall confidence
                overall_confidence = self._calculate_enhanced_confidence(
                    detected_faults, audio_quality, frequency_analysis, sound_patterns
                )
                
                # 8. Determine urgency level
                urgency_level = self._determine_urgency_level(detected_faults)
                
                # Compile comprehensive analysis results
                analysis_result = {
                    "analysis_successful": True,
                    "detected_sounds": [fault['name'] for fault in detected_faults],
                    "detected_faults": detected_faults,
                    "sound_patterns": sound_patterns,
                    "frequency_analysis": frequency_analysis,
                    "decibel_analysis": decibel_analysis,
                    "anomaly_analysis": anomaly_analysis,
                    "audio_quality": audio_quality,
                    "overall_confidence": overall_confidence,
                    "urgency_level": urgency_level,
                    "repair_keywords": self._extract_repair_keywords(detected_faults),
                    "analysis_metadata": {
                        "duration_seconds": round(len(y) / sr, 2),
                        "sample_rate": sr,
                        "total_faults_detected": len(detected_faults),
                        "processing_successful": True,
                        "analysis_timestamp": asyncio.get_event_loop().time()
                    }
                }
                
                logger.info(f"✅ Enhanced engine sound analysis completed - detected {len(detected_faults)} specific faults")
                return analysis_result
                
            finally:
                # Clean up temporary file
                if os.path.exists(temp_file_path):
                    os.unlink(temp_file_path)
                    
        except Exception as e:
            logger.error(f"Critical error in engine sound analysis: {e}")
            return self._create_failed_analysis(f"Analysis failed: {str(e)}")
    
    async def _analyze_frequency_spectrum(self, y: np.ndarray, sr: int) -> Dict[str, Any]:
        """Enhanced frequency spectrum analysis"""
        try:
            # Compute Short-Time Fourier Transform
            stft = librosa.stft(y, hop_length=512, n_fft=2048)
            magnitude = np.abs(stft)
            
            # Compute power spectral density
            power_spectrum = np.mean(magnitude**2, axis=1)
            frequencies = librosa.fft_frequencies(sr=sr, n_fft=2048)
            
            # Find dominant frequencies
            dominant_freq_idx = np.argmax(power_spectrum)
            dominant_frequency = frequencies[dominant_freq_idx]
            
            # Enhanced frequency band analysis
            frequency_bands = {
                'sub_bass': (20, 60),        # Engine fundamentals
                'bass': (60, 250),           # Engine harmonics
                'low_mid': (250, 500),       # Engine mechanical
                'mid': (500, 2000),          # Valve/timing sounds
                'high_mid': (2000, 4000),    # Belt/accessory sounds
                'presence': (4000, 6000),    # Brake/metal sounds
                'brilliance': (6000, 20000) # Air leaks/whistles
            }
            
            band_energies = {}
            band_peaks = {}
            
            for band_name, (low, high) in frequency_bands.items():
                band_mask = (frequencies >= low) & (frequencies <= high)
                if np.any(band_mask):
                    band_power = power_spectrum[band_mask]
                    band_energies[band_name] = float(np.sum(band_power))
                    
                    # Find peaks in this band
                    if len(band_power) > 0:
                        band_freqs = frequencies[band_mask]
                        peaks, _ = find_peaks(band_power, height=np.max(band_power) * 0.3)
                        if len(peaks) > 0:
                            peak_freqs = [float(band_freqs[peak]) for peak in peaks[:3]]
                            band_peaks[band_name] = peak_freqs
                        else:
                            band_peaks[band_name] = []
                else:
                    band_energies[band_name] = 0.0
                    band_peaks[band_name] = []
            
            # Calculate spectral features
            spectral_centroid = float(np.mean(librosa.feature.spectral_centroid(y=y, sr=sr)))
            spectral_rolloff = float(np.mean(librosa.feature.spectral_rolloff(y=y, sr=sr)))
            spectral_bandwidth = float(np.mean(librosa.feature.spectral_bandwidth(y=y, sr=sr)))
            
            # Find overall peak frequencies
            peaks, properties = find_peaks(power_spectrum, height=np.max(power_spectrum) * 0.1, distance=10)
            peak_frequencies = [float(frequencies[peak]) for peak in peaks[:10]]
            peak_magnitudes = [float(power_spectrum[peak]) for peak in peaks[:10]]
            
            return {
                "dominant_frequency": float(dominant_frequency),
                "spectral_centroid": spectral_centroid,
                "spectral_rolloff": spectral_rolloff,
                "spectral_bandwidth": spectral_bandwidth,
                "frequency_bands": band_energies,
                "band_peaks": band_peaks,
                "peak_frequencies": peak_frequencies,
                "peak_magnitudes": peak_magnitudes,
                "frequency_distribution": {
                    "energy_distribution": band_energies,
                    "dominant_band": max(band_energies.items(), key=lambda x: x[1])[0],
                    "frequency_spread": float(np.std(frequencies[power_spectrum > np.max(power_spectrum) * 0.1]))
                }
            }
            
        except Exception as e:
            logger.error(f"Error in frequency spectrum analysis: {e}")
            return {"analysis_failed": True, "error": str(e)}
    
    async def _detect_sound_patterns(self, y: np.ndarray, sr: int) -> List[Dict[str, Any]]:
        """Enhanced sound pattern detection"""
        try:
            patterns = []
            
            # Compute audio features
            mfccs = librosa.feature.mfcc(y=y, sr=sr, n_mfcc=13)
            chroma = librosa.feature.chroma(y=y, sr=sr)
            tempo, beats = librosa.beat.beat_track(y=y, sr=sr)
            onset_frames = librosa.onset.onset_detect(y=y, sr=sr, units='frames')
            
            # 1. Rhythmic patterns (knocking, clicking, ticking)
            rhythmic_strength = self._analyze_rhythmic_patterns(y, sr, beats)
            if rhythmic_strength > 0.4:
                patterns.append({
                    "pattern_type": "rhythmic",
                    "strength": rhythmic_strength,
                    "tempo": float(tempo),
                    "beat_count": len(beats),
                    "characteristics": ["regular_intervals", "engine_related", "mechanical"]
                })
            
            # 2. Continuous patterns (grinding, squealing, hissing)
            continuity = self._analyze_continuity(y, sr)
            if continuity > 0.6:
                patterns.append({
                    "pattern_type": "continuous",
                    "strength": continuity,
                    "duration_ratio": continuity,
                    "characteristics": ["sustained", "mechanical", "wear_related"]
                })
            
            # 3. Impulsive patterns (popping, banging, backfire)
            impulsiveness = self._analyze_impulsiveness(y, sr, onset_frames)
            if impulsiveness > 0.3:
                patterns.append({
                    "pattern_type": "impulsive",
                    "strength": impulsiveness,
                    "onset_count": len(onset_frames),
                    "characteristics": ["sudden", "impact", "combustion_related"]
                })
            
            # 4. Harmonic patterns (engine fundamental frequencies)
            harmonic_strength = self._analyze_harmonic_content(chroma)
            if harmonic_strength > 0.3:
                patterns.append({
                    "pattern_type": "harmonic",
                    "strength": harmonic_strength,
                    "characteristics": ["tonal", "engine_fundamental", "rpm_related"]
                })
            
            # 5. Noise patterns (random, chaotic sounds)
            noise_level = self._analyze_noise_patterns(y, sr)
            if noise_level > 0.5:
                patterns.append({
                    "pattern_type": "noise",
                    "strength": noise_level,
                    "characteristics": ["random", "wear_related", "mechanical_stress"]
                })
            
            return patterns
            
        except Exception as e:
            logger.error(f"Error detecting sound patterns: {e}")
            return []
    
    async def _detect_engine_faults(self, y: np.ndarray, sr: int, frequency_analysis: Dict, sound_patterns: List[Dict]) -> List[Dict[str, Any]]:
        """Detect specific engine faults based on audio analysis"""
        try:
            detected_faults = []
            
            dominant_freq = frequency_analysis.get("dominant_frequency", 0)
            band_energies = frequency_analysis.get("frequency_bands", {})
            peak_frequencies = frequency_analysis.get("peak_frequencies", [])
            
            # Check each fault pattern
            for fault_name, fault_info in self.engine_fault_patterns.items():
                confidence = 0.0
                evidence = []
                
                # 1. Frequency range matching
                freq_range = fault_info['frequency_range']
                if freq_range[0] <= dominant_freq <= freq_range[1]:
                    confidence += 0.3
                    evidence.append(f"Dominant frequency {dominant_freq:.0f}Hz matches {fault_name}")
                
                # Check if any peak frequencies match
                matching_peaks = [f for f in peak_frequencies if freq_range[0] <= f <= freq_range[1]]
                if matching_peaks:
                    confidence += 0.2 * min(len(matching_peaks) / 3, 1.0)
                    evidence.append(f"Peak frequencies {matching_peaks} match {fault_name}")
                
                # 2. Frequency band energy analysis
                if fault_name in ['spark_plug_misfire', 'valve_lifter_noise']:
                    if band_energies.get('mid', 0) > band_energies.get('bass', 0):
                        confidence += 0.2
                        evidence.append("Mid-frequency energy dominance")
                
                elif fault_name in ['timing_chain_rattle', 'engine_knock']:
                    if band_energies.get('high_mid', 0) > band_energies.get('sub_bass', 0):
                        confidence += 0.2
                        evidence.append("High-mid frequency energy dominance")
                
                elif fault_name in ['serpentine_belt_squeal', 'brake_pad_squeal']:
                    if band_energies.get('presence', 0) > sum(band_energies.values()) * 0.3:
                        confidence += 0.3
                        evidence.append("High-frequency energy dominance")
                
                elif fault_name in ['worn_engine_bearings', 'exhaust_leak']:
                    if band_energies.get('bass', 0) > band_energies.get('presence', 0):
                        confidence += 0.2
                        evidence.append("Low-frequency energy dominance")
                
                # 3. Sound pattern matching
                for pattern in sound_patterns:
                    pattern_type = pattern.get('pattern_type', '')
                    pattern_strength = pattern.get('strength', 0)
                    
                    if fault_name in ['spark_plug_misfire'] and pattern_type == 'impulsive':
                        confidence += pattern_strength * 0.3
                        evidence.append(f"Impulsive pattern strength: {pattern_strength:.2f}")
                    
                    elif fault_name in ['timing_chain_rattle', 'valve_lifter_noise', 'cv_joint_clicking'] and pattern_type == 'rhythmic':
                        confidence += pattern_strength * 0.3
                        evidence.append(f"Rhythmic pattern strength: {pattern_strength:.2f}")
                    
                    elif fault_name in ['serpentine_belt_squeal', 'brake_pad_squeal', 'turbo_whistle'] and pattern_type == 'continuous':
                        confidence += pattern_strength * 0.3
                        evidence.append(f"Continuous pattern strength: {pattern_strength:.2f}")
                    
                    elif fault_name in ['worn_engine_bearings', 'engine_knock'] and pattern_type == 'noise':
                        confidence += pattern_strength * 0.2
                        evidence.append(f"Noise pattern strength: {pattern_strength:.2f}")
                
                # Add fault if confidence is sufficient
                if confidence > 0.4:  # Lower threshold for better detection
                    detected_faults.append({
                        "name": fault_name,
                        "display_name": fault_name.replace('_', ' ').title(),
                        "confidence": min(confidence, 1.0),
                        "severity": fault_info['severity'],
                        "urgency": fault_info['urgency'],
                        "keywords": fault_info['keywords'],
                        "evidence": evidence,
                        "frequency_range": fault_info['frequency_range'],
                        "characteristics": fault_info['characteristics']
                    })
            
            # Sort by confidence
            detected_faults.sort(key=lambda x: x['confidence'], reverse=True)
            
            return detected_faults
            
        except Exception as e:
            logger.error(f"Error detecting engine faults: {e}")
            return []
    
    async def _analyze_decibel_levels(self, y: np.ndarray, sr: int) -> Dict[str, Any]:
        """Analyze decibel levels in the audio"""
        try:
            # Calculate RMS energy
            rms = librosa.feature.rms(y=y, frame_length=2048, hop_length=512)[0]
            
            # Convert to decibels (reference: 1.0 = 0 dB)
            rms_db = 20 * np.log10(rms + 1e-10)  # Add small value to avoid log(0)
            
            # Calculate statistics
            max_db = float(np.max(rms_db))
            min_db = float(np.min(rms_db))
            mean_db = float(np.mean(rms_db))
            std_db = float(np.std(rms_db))
            
            # Analyze dynamic range
            dynamic_range = max_db - min_db
            
            # Categorize volume levels
            volume_category = "quiet"
            if mean_db > -20:
                volume_category = "very_loud"
            elif mean_db > -30:
                volume_category = "loud"
            elif mean_db > -40:
                volume_category = "moderate"
            elif mean_db > -50:
                volume_category = "quiet"
            else:
                volume_category = "very_quiet"
            
            return {
                "max_db": max_db,
                "min_db": min_db,
                "mean_db": mean_db,
                "std_db": std_db,
                "dynamic_range_db": dynamic_range,
                "volume_category": volume_category,
                "rms_values": rms_db.tolist()[:100]  # Limit for response size
            }
            
        except Exception as e:
            logger.error(f"Error analyzing decibel levels: {e}")
            return {"analysis_failed": True}
    
    async def _analyze_anomaly_duration(self, y: np.ndarray, sr: int) -> Dict[str, Any]:
        """Analyze duration and timing of anomalies"""
        try:
            # Calculate energy over time
            frame_length = 2048
            hop_length = 512
            rms = librosa.feature.rms(y=y, frame_length=frame_length, hop_length=hop_length)[0]
            
            # Find anomalous regions (high energy)
            energy_threshold = np.mean(rms) + 2 * np.std(rms)
            anomalous_frames = rms > energy_threshold
            
            # Calculate anomaly statistics
            total_frames = len(rms)
            anomalous_frame_count = np.sum(anomalous_frames)
            anomaly_percentage = (anomalous_frame_count / total_frames) * 100
            
            # Find continuous anomalous regions
            anomaly_regions = []
            in_anomaly = False
            start_frame = 0
            
            for i, is_anomalous in enumerate(anomalous_frames):
                if is_anomalous and not in_anomaly:
                    start_frame = i
                    in_anomaly = True
                elif not is_anomalous and in_anomaly:
                    duration = (i - start_frame) * hop_length / sr
                    anomaly_regions.append({
                        "start_time": start_frame * hop_length / sr,
                        "duration": duration,
                        "end_time": i * hop_length / sr
                    })
                    in_anomaly = False
            
            # Handle case where anomaly continues to end
            if in_anomaly:
                duration = (len(anomalous_frames) - start_frame) * hop_length / sr
                anomaly_regions.append({
                    "start_time": start_frame * hop_length / sr,
                    "duration": duration,
                    "end_time": len(y) / sr
                })
            
            # Calculate statistics
            if anomaly_regions:
                avg_duration = np.mean([region['duration'] for region in anomaly_regions])
                max_duration = max([region['duration'] for region in anomaly_regions])
                total_anomaly_time = sum([region['duration'] for region in anomaly_regions])
            else:
                avg_duration = 0
                max_duration = 0
                total_anomaly_time = 0
            
            return {
                "anomaly_percentage": round(anomaly_percentage, 2),
                "anomaly_count": len(anomaly_regions),
                "avg_anomaly_duration": round(avg_duration, 2),
                "max_anomaly_duration": round(max_duration, 2),
                "total_anomaly_time": round(total_anomaly_time, 2),
                "anomaly_regions": anomaly_regions[:10]  # Limit for response size
            }
            
        except Exception as e:
            logger.error(f"Error analyzing anomaly duration: {e}")
            return {"analysis_failed": True}
    
    def _determine_urgency_level(self, detected_faults: List[Dict]) -> str:
        """Determine urgency level based on detected faults"""
        if not detected_faults:
            return "normal"
        
        # Check for critical faults
        for fault in detected_faults:
            if fault.get('urgency') == 'critical':
                return "critical"
        
        # Check for warning faults
        for fault in detected_faults:
            if fault.get('urgency') == 'warning':
                return "warning"
        
        return "normal"
    
    def _extract_repair_keywords(self, detected_faults: List[Dict]) -> List[str]:
        """Extract repair keywords from detected faults"""
        keywords = []
        for fault in detected_faults:
            keywords.extend(fault.get('keywords', []))
        
        # Remove duplicates and limit
        return list(set(keywords))[:8]
    
    def _calculate_enhanced_confidence(self, detected_faults: List[Dict], audio_quality: Dict, 
                                     frequency_analysis: Dict, sound_patterns: List[Dict]) -> float:
        """Calculate enhanced confidence score"""
        confidence = 0.0
        
        # Base confidence from audio quality
        quality_score = audio_quality.get('score', 0.5)
        confidence += quality_score * 0.3
        
        # Confidence from detected faults
        if detected_faults:
            # Weight by fault confidence and severity
            fault_confidence = 0
            for fault in detected_faults:
                fault_conf = fault.get('confidence', 0)
                severity_weight = 1.0 if fault.get('severity') == 'critical' else 0.8
                fault_confidence += fault_conf * severity_weight
            
            # Average and normalize
            avg_fault_confidence = fault_confidence / len(detected_faults)
            confidence += avg_fault_confidence * 0.4
        else:
            confidence += 0.2  # Some confidence even without specific faults
        
        # Confidence from frequency analysis
        if frequency_analysis.get('dominant_frequency', 0) > 0:
            confidence += 0.2
        
        # Confidence from sound patterns
        if sound_patterns:
            pattern_confidence = np.mean([p.get('strength', 0) for p in sound_patterns])
            confidence += pattern_confidence * 0.1
        
        return min(confidence, 1.0)
    
    def _analyze_rhythmic_patterns(self, y: np.ndarray, sr: int, beats: np.ndarray) -> float:
        """Analyze rhythmic patterns in the audio"""
        try:
            if len(beats) < 3:
                return 0.0
            
            # Calculate beat intervals
            beat_intervals = np.diff(beats)
            
            # Check for regularity (low variance indicates regular rhythm)
            if len(beat_intervals) > 1:
                mean_interval = np.mean(beat_intervals)
                std_interval = np.std(beat_intervals)
                regularity = 1.0 / (1.0 + (std_interval / mean_interval)) if mean_interval > 0 else 0
                return min(regularity, 1.0)
            
            return 0.0
            
        except Exception:
            return 0.0
    
    def _analyze_continuity(self, y: np.ndarray, sr: int) -> float:
        """Analyze continuity of the sound"""
        try:
            # Calculate RMS energy over time
            frame_length = 2048
            hop_length = 512
            rms = librosa.feature.rms(y=y, frame_length=frame_length, hop_length=hop_length)[0]
            
            # Check for sustained energy (continuity)
            energy_threshold = np.max(rms) * 0.2
            sustained_frames = np.sum(rms > energy_threshold)
            continuity = sustained_frames / len(rms)
            
            return min(continuity, 1.0)
            
        except Exception:
            return 0.0
    
    def _analyze_impulsiveness(self, y: np.ndarray, sr: int, onset_frames: np.ndarray) -> float:
        """Analyze impulsive characteristics of the sound"""
        try:
            if len(onset_frames) == 0:
                return 0.0
            
            # Calculate onset density
            duration_frames = len(y) // 512  # Assuming hop_length=512
            onset_density = len(onset_frames) / duration_frames if duration_frames > 0 else 0
            
            # Normalize and return
            return min(onset_density * 5, 1.0)  # Scale factor for normalization
            
        except Exception:
            return 0.0
    
    def _analyze_harmonic_content(self, chroma: np.ndarray) -> float:
        """Analyze harmonic content of the sound"""
        try:
            # Calculate the strength of harmonic content
            harmonic_strength = np.mean(np.max(chroma, axis=0))
            return min(harmonic_strength, 1.0)
            
        except Exception:
            return 0.0
    
    def _analyze_noise_patterns(self, y: np.ndarray, sr: int) -> float:
        """Analyze noise patterns in the audio"""
        try:
            # Calculate spectral flatness (measure of noisiness)
            spectral_flatness = librosa.feature.spectral_flatness(y=y)[0]
            noise_level = np.mean(spectral_flatness)
            
            return min(noise_level, 1.0)
            
        except Exception:
            return 0.0
    
    async def _analyze_audio_quality(self, y: np.ndarray, sr: int) -> Dict[str, Any]:
        """Enhanced audio quality analysis"""
        try:
            # Calculate signal-to-noise ratio
            signal_power = np.mean(y**2)
            noise_floor = np.percentile(np.abs(y), 10)**2  # Estimate noise floor
            snr = 10 * np.log10(signal_power / noise_floor) if noise_floor > 0 else 50
            
            # Calculate dynamic range
            dynamic_range = 20 * np.log10(np.max(np.abs(y)) / (np.mean(np.abs(y)) + 1e-10))
            
            # Check for clipping
            clipping_ratio = np.sum(np.abs(y) > 0.95) / len(y)
            
            # Check for silence
            silence_threshold = 0.01
            silence_ratio = np.sum(np.abs(y) < silence_threshold) / len(y)
            
            # Overall quality score
            quality_score = (
                min(snr / 30, 1.0) * 0.3 +  # SNR component
                min(dynamic_range / 40, 1.0) * 0.3 +  # Dynamic range component
                (1.0 - clipping_ratio) * 0.2 +  # Anti-clipping component
                (1.0 - silence_ratio) * 0.2  # Anti-silence component
            )
            
            # Identify issues
            issues = []
            if snr < 15:
                issues.append("High background noise")
            if dynamic_range < 15:
                issues.append("Low dynamic range")
            if clipping_ratio > 0.01:
                issues.append("Audio clipping detected")
            if silence_ratio > 0.5:
                issues.append("Too much silence in recording")
            if len(y) / sr < 3:
                issues.append("Recording too short for reliable analysis")
            
            # Quality rating
            if quality_score > 0.8:
                quality_rating = "excellent"
            elif quality_score > 0.6:
                quality_rating = "good"
            elif quality_score > 0.4:
                quality_rating = "fair"
            else:
                quality_rating = "poor"
            
            return {
                "score": round(quality_score, 3),
                "rating": quality_rating,
                "snr_db": round(snr, 1),
                "dynamic_range_db": round(dynamic_range, 1),
                "clipping_ratio": round(clipping_ratio, 4),
                "silence_ratio": round(silence_ratio, 3),
                "duration_seconds": round(len(y) / sr, 2),
                "sample_rate": sr,
                "issues": issues,
                "recommendations": self._get_quality_recommendations(quality_score, issues)
            }
            
        except Exception as e:
            logger.error(f"Error analyzing audio quality: {e}")
            return {
                "score": 0.3,
                "rating": "poor",
                "issues": ["Quality analysis failed"],
                "recommendations": ["Re-record audio in quieter environment"]
            }
    
    def _get_quality_recommendations(self, quality_score: float, issues: List[str]) -> List[str]:
        """Get recommendations for improving audio quality"""
        recommendations = []
        
        if quality_score < 0.5:
            recommendations.append("Consider re-recording in a quieter environment")
        
        if "High background noise" in issues:
            recommendations.append("Record closer to engine with less background noise")
        
        if "Audio clipping detected" in issues:
            recommendations.append("Reduce recording volume to avoid distortion")
        
        if "Recording too short for reliable analysis" in issues:
            recommendations.append("Record for at least 5-10 seconds for better analysis")
        
        if "Too much silence in recording" in issues:
            recommendations.append("Ensure engine is running during recording")
        
        return recommendations
    
    def _create_failed_analysis(self, error_message: str) -> Dict[str, Any]:
        """Create a failed analysis response"""
        return {
            "analysis_successful": False,
            "analysis_failed": True,
            "error_message": error_message,
            "detected_sounds": [],
            "detected_faults": [],
            "sound_patterns": [],
            "frequency_analysis": {"analysis_failed": True},
            "decibel_analysis": {"analysis_failed": True},
            "anomaly_analysis": {"analysis_failed": True},
            "audio_quality": {
                "score": 0.0,
                "rating": "failed",
                "issues": [error_message]
            },
            "overall_confidence": 0.0,
            "urgency_level": "normal",
            "repair_keywords": ["audio analysis failed", "re-record audio"],
            "analysis_metadata": {
                "processing_successful": False,
                "error": error_message
            }
        }

# Global service instance
audio_analyzer = AudioAnalyzer()
