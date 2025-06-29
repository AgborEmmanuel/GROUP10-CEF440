import 'package:cardocai/models/diagnosis_report.dart';
import 'base_repository.dart';

class DiagnosisRepository extends BaseRepository {
  @override
  String get tableName => 'diagnostic_records';

  // Create a new diagnosis with results
  Future<DiagnosisReport> createDiagnosis(DiagnosisReport report) async {
    try {
      // First, create the diagnostic record
      final recordResponse = await client
          .from(tableName)
          .insert({
            'user_id': report.userId,
            'diagnostic_type': report.diagnosticType,
            'timestamp': report.timestamp.toIso8601String(),
            'image_path': report.imagePath,
            'audio_path': report.audioPath,
            'status': report.status,
            'created_at': report.createdAt.toIso8601String(),
          })
          .select()
          .single()
          .execute();

      final diagnosticRecord = recordResponse.data as Map<String, dynamic>;
      
      // Then, create the diagnostic result
      final resultResponse = await client
          .from('diagnostic_results')
          .insert({
            'diagnostic_id': diagnosticRecord['diagnostic_id'],
            'detected_lights': report.detectedLights,
            'detected_sounds': report.detectedSounds,
            'confidence_score': report.confidenceScore,
            'urgency_level': report.urgencyLevel,
            'analysis_results': report.analysisResults,
            'recommendations': report.recommendations,
            'created_at': report.resultCreatedAt.toIso8601String(),
          })
          .select()
          .single()
          .execute();

      final diagnosticResult = resultResponse.data as Map<String, dynamic>;
      
      // Combine the records and return
      return DiagnosisReport(
        diagnosticId: diagnosticRecord['diagnostic_id'],
        userId: diagnosticRecord['user_id'],
        diagnosticType: diagnosticRecord['diagnostic_type'],
        timestamp: DateTime.parse(diagnosticRecord['timestamp']),
        imagePath: diagnosticRecord['image_path'],
        audioPath: diagnosticRecord['audio_path'],
        status: diagnosticRecord['status'],
        createdAt: DateTime.parse(diagnosticRecord['created_at']),
        resultId: diagnosticResult['result_id'],
        detectedLights: List<String>.from(diagnosticResult['detected_lights']),
        detectedSounds: List<String>.from(diagnosticResult['detected_sounds']),
        confidenceScore: diagnosticResult['confidence_score'],
        urgencyLevel: diagnosticResult['urgency_level'],
        analysisResults: diagnosticResult['analysis_results'],
        recommendations: List<String>.from(diagnosticResult['recommendations']),
        resultCreatedAt: DateTime.parse(diagnosticResult['created_at']),
      );
    } catch (error) {
      SupabaseService.instance.handleError(error);
      rethrow;
    }
  }

  // Get diagnosis with results by ID
  Future<DiagnosisReport> getDiagnosisById(String diagnosticId) async {
    try {
      final response = await client
          .from(tableName)
          .select('''
            *,
            diagnostic_results (*)
          ''')
          .eq('diagnostic_id', diagnosticId)
          .single()
          .execute();

      final data = response.data as Map<String, dynamic>;
      final result = data['diagnostic_results'][0] as Map<String, dynamic>;

      return DiagnosisReport(
        diagnosticId: data['diagnostic_id'],
        userId: data['user_id'],
        diagnosticType: data['diagnostic_type'],
        timestamp: DateTime.parse(data['timestamp']),
        imagePath: data['image_path'],
        audioPath: data['audio_path'],
        status: data['status'],
        createdAt: DateTime.parse(data['created_at']),
        resultId: result['result_id'],
        detectedLights: List<String>.from(result['detected_lights']),
        detectedSounds: List<String>.from(result['detected_sounds']),
        confidenceScore: result['confidence_score'],
        urgencyLevel: result['urgency_level'],
        analysisResults: result['analysis_results'],
        recommendations: List<String>.from(result['recommendations']),
        resultCreatedAt: DateTime.parse(result['created_at']),
      );
    } catch (error) {
      SupabaseService.instance.handleError(error);
      rethrow;
    }
  }

  // Get all diagnoses for a user
  Future<List<DiagnosisReport>> getUserDiagnoses(String userId) async {
    try {
      final response = await client
          .from(tableName)
          .select('''
            *,
            diagnostic_results (*)
          ''')
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .execute();

      return (response.data as List).map((data) {
        final result = data['diagnostic_results'][0] as Map<String, dynamic>;
        
        return DiagnosisReport(
          diagnosticId: data['diagnostic_id'],
          userId: data['user_id'],
          diagnosticType: data['diagnostic_type'],
          timestamp: DateTime.parse(data['timestamp']),
          imagePath: data['image_path'],
          audioPath: data['audio_path'],
          status: data['status'],
          createdAt: DateTime.parse(data['created_at']),
          resultId: result['result_id'],
          detectedLights: List<String>.from(result['detected_lights']),
          detectedSounds: List<String>.from(result['detected_sounds']),
          confidenceScore: result['confidence_score'],
          urgencyLevel: result['urgency_level'],
          analysisResults: result['analysis_results'],
          recommendations: List<String>.from(result['recommendations']),
          resultCreatedAt: DateTime.parse(result['created_at']),
        );
      }).toList();
    } catch (error) {
      SupabaseService.instance.handleError(error);
      rethrow;
    }
  }

  // Update diagnosis status
  Future<void> updateDiagnosisStatus(String diagnosticId, String status) async {
    try {
      await client
          .from(tableName)
          .update({'status': status})
          .eq('diagnostic_id', diagnosticId)
          .execute();
    } catch (error) {
      SupabaseService.instance.handleError(error);
      rethrow;
    }
  }

  // Delete diagnosis and its results
  Future<void> deleteDiagnosis(String diagnosticId) async {
    try {
      // Delete diagnostic results first (due to foreign key constraint)
      await client
          .from('diagnostic_results')
          .delete()
          .eq('diagnostic_id', diagnosticId)
          .execute();

      // Then delete the diagnostic record
      await client
          .from(tableName)
          .delete()
          .eq('diagnostic_id', diagnosticId)
          .execute();
    } catch (error) {
      SupabaseService.instance.handleError(error);
      rethrow;
    }
  }

  // Get recent diagnoses with high urgency
  Future<List<DiagnosisReport>> getRecentUrgentDiagnoses() async {
    try {
      final response = await client
          .from(tableName)
          .select('''
            *,
            diagnostic_results (*)
          ''')
          .eq('status', 'completed')
          .eq('diagnostic_results.urgency_level', 'immediate')
          .order('created_at', ascending: false)
          .limit(10)
          .execute();

      return (response.data as List).map((data) {
        final result = data['diagnostic_results'][0] as Map<String, dynamic>;
        
        return DiagnosisReport(
          diagnosticId: data['diagnostic_id'],
          userId: data['user_id'],
          diagnosticType: data['diagnostic_type'],
          timestamp: DateTime.parse(data['timestamp']),
          imagePath: data['image_path'],
          audioPath: data['audio_path'],
          status: data['status'],
          createdAt: DateTime.parse(data['created_at']),
          resultId: result['result_id'],
          detectedLights: List<String>.from(result['detected_lights']),
          detectedSounds: List<String>.from(result['detected_sounds']),
          confidenceScore: result['confidence_score'],
          urgencyLevel: result['urgency_level'],
          analysisResults: result['analysis_results'],
          recommendations: List<String>.from(result['recommendations']),
          resultCreatedAt: DateTime.parse(result['created_at']),
        );
      }).toList();
    } catch (error) {
      SupabaseService.instance.handleError(error);
      rethrow;
    }
  }
} 