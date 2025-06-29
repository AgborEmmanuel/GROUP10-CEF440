import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';

class DiagnosisService {
  static const String _baseUrl = AppConstants.baseUrl;
  
  // Check network connectivity
  Future<bool> checkConnectivity() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/health'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
  
  // Diagnose dashboard image
  Future<Map<String, dynamic>> diagnoseDashboardImage({
    required String userId,
    required File imageFile,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl${AppConstants.dashboardDiagnosisEndpoint}');
      final request = http.MultipartRequest('POST', uri);
      
      // Add user_id field
      request.fields['user_id'] = userId;
      
      // Add image file
      final imageStream = http.ByteStream(imageFile.openRead());
      final imageLength = await imageFile.length();
      final multipartFile = http.MultipartFile(
        'image',
        imageStream,
        imageLength,
        filename: 'dashboard_image.jpg',
      );
      request.files.add(multipartFile);
      
      // Set headers
      request.headers.addAll({
        'Accept': 'application/json',
      });
      
      // Send request
      final streamedResponse = await request.send().timeout(
        Duration(milliseconds: AppConstants.receiveTimeout),
      );
      
      final response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        final errorBody = json.decode(response.body);
        throw Exception(errorBody['detail'] ?? 'Dashboard diagnosis failed');
      }
    } on SocketException {
      throw Exception(AppConstants.networkErrorMessage);
    } on http.ClientException {
      throw Exception(AppConstants.networkErrorMessage);
    } catch (e) {
      throw Exception('Dashboard diagnosis failed: ${e.toString()}');
    }
  }
  
  // Diagnose engine sound
  Future<Map<String, dynamic>> diagnoseEngineSound({
    required String userId,
    required File audioFile,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl${AppConstants.engineSoundDiagnosisEndpoint}');
      final request = http.MultipartRequest('POST', uri);
      
      // Add user_id field
      request.fields['user_id'] = userId;
      
      // Add audio file
      final audioStream = http.ByteStream(audioFile.openRead());
      final audioLength = await audioFile.length();
      final multipartFile = http.MultipartFile(
        'audio',
        audioStream,
        audioLength,
        filename: 'engine_sound.m4a',
      );
      request.files.add(multipartFile);
      
      // Set headers
      request.headers.addAll({
        'Accept': 'application/json',
      });
      
      // Send request
      final streamedResponse = await request.send().timeout(
        Duration(milliseconds: AppConstants.receiveTimeout),
      );
      
      final response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        final errorBody = json.decode(response.body);
        throw Exception(errorBody['detail'] ?? 'Engine sound diagnosis failed');
      }
    } on SocketException {
      throw Exception(AppConstants.networkErrorMessage);
    } on http.ClientException {
      throw Exception(AppConstants.networkErrorMessage);
    } catch (e) {
      throw Exception('Engine sound diagnosis failed: ${e.toString()}');
    }
  }
  
  // Get diagnosis history
  Future<List<Map<String, dynamic>>> getDiagnosisHistory(String userId) async {
    try {
      final uri = Uri.parse('$_baseUrl${AppConstants.diagnosisHistoryEndpoint}/$userId');
      
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(Duration(milliseconds: AppConstants.connectionTimeout));
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        final errorBody = json.decode(response.body);
        throw Exception(errorBody['detail'] ?? 'Failed to fetch diagnosis history');
      }
    } on SocketException {
      throw Exception(AppConstants.networkErrorMessage);
    } on http.ClientException {
      throw Exception(AppConstants.networkErrorMessage);
    } catch (e) {
      throw Exception('Failed to fetch diagnosis history: ${e.toString()}');
    }
  }
}
