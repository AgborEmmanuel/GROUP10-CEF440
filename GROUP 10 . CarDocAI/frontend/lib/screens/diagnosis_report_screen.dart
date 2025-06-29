import 'package:flutter/material.dart';
import 'package:cardocai/models/diagnosis_report.dart';

class DiagnosisReportScreen extends StatelessWidget {
  final DiagnosisReport report;

  const DiagnosisReportScreen({
    super.key,
    required this.report,
  });

  Color _getUrgencyColor(String urgency) {
    switch (urgency.toLowerCase()) {
      case 'immediate':
        return Colors.red;
      case 'soon':
        return Colors.orange;
      case 'monitoring':
        return Colors.yellow;
      default:
        return Colors.grey;
    }
  }

  String _getUrgencyDisplay(String urgency) {
    switch (urgency.toLowerCase()) {
      case 'immediate':
        return 'High';
      case 'soon':
        return 'Medium';
      case 'monitoring':
        return 'Low';
      default:
        return 'Unknown';
    }
  }

  Widget _buildInfoSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: TextStyle(
            fontSize: 15,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildRecommendationsList(List<String> recommendations) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recommendations',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        ...recommendations.map((recommendation) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('• ', style: TextStyle(fontSize: 15)),
              Expanded(
                child: Text(
                  recommendation,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey[700],
                  ),
                ),
              ),
            ],
          ),
        )),
        const SizedBox(height: 24),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final issueType = report.analysisResults['issue'] as String;
    final description = report.analysisResults['details'] as String;
    final urgencyDisplay = _getUrgencyDisplay(report.urgencyLevel);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Diagnosis Report'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            color: Colors.white70,
            onPressed: () {
              // TODO: Implement notification toggle with state management
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: _getUrgencyColor(report.urgencyLevel),
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    issueType,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: _getUrgencyColor(report.urgencyLevel).withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                'Urgency: $urgencyDisplay',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: _getUrgencyColor(report.urgencyLevel),
                ),
              ),
            ),
            const SizedBox(height: 32),
            _buildInfoSection(
              'Timestamp',
              '${report.timestamp.day}/${report.timestamp.month}/${report.timestamp.year} ${report.timestamp.hour}:${report.timestamp.minute}',
            ),
            _buildInfoSection('Issue Description', description),
            _buildRecommendationsList(report.recommendations),
            _buildInfoSection(
              'Confidence Score',
              '${(report.confidenceScore * 100).toStringAsFixed(1)}%',
            ),
            if (report.detectedLights.isNotEmpty) ...[
              _buildInfoSection(
                'Detected Warning Lights',
                report.detectedLights.join(', '),
              ),
            ],
            if (report.detectedSounds.isNotEmpty) ...[
              _buildInfoSection(
                'Detected Engine Sounds',
                report.detectedSounds.join(', '),
              ),
            ],
          ],
        ),
      ),
    );
  }
} 