import 'dart:convert';

class DiagnosisReport {
  final String diagnosticId;
  final String userId;
  final String diagnosticType;
  final DateTime timestamp;
  final String? imagePath;
  final String? audioPath;
  final String status;
  final DateTime createdAt;
  
  // Results
  final String resultId;
  final List<String> detectedLights;
  final List<String> detectedSounds;
  final double confidenceScore;
  final String urgencyLevel;
  final Map<String, dynamic> analysisResults;
  final List<String> recommendations;
  final DateTime resultCreatedAt;

  DiagnosisReport({
    required this.diagnosticId,
    required this.userId,
    required this.diagnosticType,
    required this.timestamp,
    this.imagePath,
    this.audioPath,
    required this.status,
    required this.createdAt,
    required this.resultId,
    required this.detectedLights,
    required this.detectedSounds,
    required this.confidenceScore,
    required this.urgencyLevel,
    required this.analysisResults,
    required this.recommendations,
    required this.resultCreatedAt,
  });

  factory DiagnosisReport.fromJson(Map<String, dynamic> json) {
    return DiagnosisReport(
      diagnosticId: json['diagnostic_id'],
      userId: json['user_id'],
      diagnosticType: json['diagnostic_type'],
      timestamp: DateTime.parse(json['timestamp']),
      imagePath: json['image_path'],
      audioPath: json['audio_path'],
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
      resultId: json['result_id'],
      detectedLights: List<String>.from(json['detected_lights'] ?? []),
      detectedSounds: List<String>.from(json['detected_sounds'] ?? []),
      confidenceScore: json['confidence_score'].toDouble(),
      urgencyLevel: json['urgency_level'],
      analysisResults: jsonDecode(json['analysis_results']),
      recommendations: List<String>.from(json['recommendations'] ?? []),
      resultCreatedAt: DateTime.parse(json['result_created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'diagnostic_id': diagnosticId,
      'user_id': userId,
      'diagnostic_type': diagnosticType,
      'timestamp': timestamp.toIso8601String(),
      'image_path': imagePath,
      'audio_path': audioPath,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'result_id': resultId,
      'detected_lights': detectedLights,
      'detected_sounds': detectedSounds,
      'confidence_score': confidenceScore,
      'urgency_level': urgencyLevel,
      'analysis_results': jsonEncode(analysisResults),
      'recommendations': recommendations,
      'result_created_at': resultCreatedAt.toIso8601String(),
    };
  }
} 