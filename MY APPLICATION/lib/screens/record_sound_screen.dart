import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:cardocai/screens/sound_diagnosis_result_screen.dart';
import 'package:cardocai/screens/home_screen.dart';

class RecordSoundScreen extends StatefulWidget {
  const RecordSoundScreen({super.key});

  @override
  State<RecordSoundScreen> createState() => _RecordSoundScreenState();
}

class _RecordSoundScreenState extends State<RecordSoundScreen> {
  final _audioRecorder = Record();
  final _audioPlayer = AudioPlayer();
  String? _recordedFilePath;
  bool _isRecording = false;
  bool _isPlaying = false;
  bool _hasRecording = false;
  bool _isAnalyzing = false;
  bool _showResults = false;
  Timer? _recordingTimer;
  int _recordingDuration = 0;
  final int _maxRecordingDuration = 10; // Maximum recording duration in seconds
  final int _minRecordingDuration = 5; // Minimum recording duration in seconds

  @override
  void dispose() {
    _audioRecorder.dispose();
    _audioPlayer.dispose();
    _recordingTimer?.cancel();
    super.dispose();
  }

  Future<void> _requestPermissions() async {
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Microphone permission is required to record audio'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _startRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        final directory = await getApplicationDocumentsDirectory();
        final filePath = '${directory.path}/engine_sound.m4a';

        await _audioRecorder.start(path: filePath);
        
        setState(() {
          _isRecording = true;
          _hasRecording = false;
          _recordingDuration = 0;
          _recordedFilePath = filePath;
        });

        _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
          setState(() {
            _recordingDuration++;
          });

          if (_recordingDuration >= _maxRecordingDuration) {
            _stopRecording();
          }
        });
      }
    } catch (e) {
      debugPrint('Error starting recording: $e');
    }
  }

  Future<void> _stopRecording() async {
    _recordingTimer?.cancel();
    await _audioRecorder.stop();
    
    setState(() {
      _isRecording = false;
      if (_recordingDuration >= _minRecordingDuration) {
        _hasRecording = true;
      } else {
        _hasRecording = false;
        // Show warning message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Please record for at least $_minRecordingDuration seconds for accurate analysis',
              style: const TextStyle(fontSize: 16),
            ),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    });
  }

  Future<void> _playRecording() async {
    if (_recordedFilePath == null) return;

    if (_isPlaying) {
      await _audioPlayer.stop();
      setState(() => _isPlaying = false);
      return;
    }

    try {
      await _audioPlayer.play(DeviceFileSource(_recordedFilePath!));
      setState(() => _isPlaying = true);

      _audioPlayer.onPlayerComplete.listen((event) {
        setState(() => _isPlaying = false);
      });
    } catch (e) {
      debugPrint('Error playing recording: $e');
    }
  }

  Future<void> _analyzeRecording() async {
    setState(() => _isAnalyzing = true);

    // Simulated analysis delay
    await Future.delayed(const Duration(seconds: 3));

    // Simulated diagnosis result
    final diagnosisResult = {
      'primaryIssue': 'Engine Misfire',
      'confidence': 0.85,
      'description': 'High probability of cylinder 2 misfire detected from engine sound analysis. The irregular sound pattern indicates combustion issues in one or more cylinders.',
      'recommendations': [
        'Check and replace spark plugs in cylinder 2',
        'Inspect fuel injector performance',
        'Test compression in affected cylinder',
        'Consider professional diagnostic scan',
      ],
      'youtubeLink': 'https://www.youtube.com/watch?v=PFU4DwgUF3g',
    };

    setState(() => _isAnalyzing = false);

    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SoundDiagnosisResultScreen(
            diagnosisResult: diagnosisResult,
          ),
        ),
      );
    }
  }

  Widget _buildRecordingTimer() {
    final remainingTime = _minRecordingDuration - _recordingDuration;
    return Column(
      children: [
        Text(
          'Recording: ${_recordingDuration}s / ${_maxRecordingDuration}s',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.red,
          ),
        ),
        if (remainingTime > 0) ...[
          const SizedBox(height: 8),
          Text(
            'Record for $remainingTime more seconds for analysis',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildAnalysisResults() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Diagnosis Results',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          _buildResultItem(
            'Engine Misfire',
            'High probability of cylinder 2 misfire',
            0.85,
            Colors.red,
          ),
          const SizedBox(height: 12),
          _buildResultItem(
            'Timing Belt',
            'Normal operation detected',
            0.95,
            Colors.green,
          ),
          const SizedBox(height: 12),
          _buildResultItem(
            'Fuel Injection',
            'Possible irregular fuel delivery',
            0.75,
            Colors.orange,
          ),
          const SizedBox(height: 24),
          const Text(
            'Recommended Actions:',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          _buildRecommendation(
            '1. Check spark plugs in cylinder 2',
            'High Priority',
          ),
          _buildRecommendation(
            '2. Inspect fuel injector performance',
            'Medium Priority',
          ),
          _buildRecommendation(
            '3. Schedule professional diagnostic',
            'Recommended',
          ),
        ],
      ),
    );
  }

  Widget _buildResultItem(
    String title,
    String description,
    double confidence,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const Spacer(),
            Text(
              '${(confidence * 100).toInt()}%',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          description,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: confidence,
          backgroundColor: Colors.grey[200],
          color: color,
        ),
      ],
    );
  }

  Widget _buildRecommendation(String text, String priority) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.arrow_right,
            color: Colors.blue,
            size: 20,
          ),
          const SizedBox(width: 4),
          Expanded(
            child: RichText(
              text: TextSpan(
                text: text,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
                children: [
                  TextSpan(
                    text: ' ($priority)',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Record Engine Sound'),
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Record Your Engine Sound',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Tap the record button to start recording your engine sound',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 48),
              if (_isRecording) _buildRecordingTimer(),
              const SizedBox(height: 24),
              InkWell(
                onTap: _isRecording ? _stopRecording : _startRecording,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isRecording ? Colors.red : Colors.blue,
                    boxShadow: [
                      BoxShadow(
                        color: (_isRecording ? Colors.red : Colors.blue).withOpacity(0.3),
                        spreadRadius: 8,
                        blurRadius: 12,
                      ),
                    ],
                  ),
                  child: Icon(
                    _isRecording ? Icons.stop : Icons.mic,
                    size: 48,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 48),
              if (_hasRecording && !_isRecording) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _playRecording,
                      icon: Icon(_isPlaying ? Icons.stop : Icons.play_arrow),
                      label: Text(_isPlaying ? 'Stop' : 'Play'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[200],
                        foregroundColor: Colors.black87,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: _analyzeRecording,
                      icon: const Icon(Icons.analytics),
                      label: const Text('Analyze'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              if (_isAnalyzing) ...[
                const SizedBox(height: 32),
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                const Text(
                  'Analyzing engine sound...',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
} 