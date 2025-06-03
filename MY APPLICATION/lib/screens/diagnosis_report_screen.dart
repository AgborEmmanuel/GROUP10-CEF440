import 'package:flutter/material.dart';
import 'package:cardocai/models/diagnosis_report.dart';
import 'package:url_launcher/url_launcher.dart';

class DiagnosisReportScreen extends StatelessWidget {
  final DiagnosisReport report;

  const DiagnosisReportScreen({
    super.key,
    required this.report,
  });

  Color _getUrgencyColor(String urgency) {
    switch (urgency.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.yellow;
      default:
        return Colors.grey;
    }
  }

  Future<void> _launchYoutubeUrl() async {
    if (report.youtubeLink == null) return;
    
    final Uri url = Uri.parse(report.youtubeLink!);
    if (!await launchUrl(url)) {
      throw Exception('Could not launch ${report.youtubeLink}');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Diagnosis Report'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: Icon(
              report.hasNotification
                  ? Icons.notifications_active
                  : Icons.notifications_none,
              color: report.hasNotification ? Colors.white : Colors.white70,
            ),
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
                    report.issueType,
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
                'Urgency: ${report.urgencyLevel}',
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
            _buildInfoSection('Issue Description', report.description),
            _buildInfoSection('Repair Suggestion', report.repairSuggestion),
            _buildInfoSection(
              'Confidence Score',
              '${(report.confidenceScore * 100).toStringAsFixed(1)}%',
            ),
            if (report.youtubeLink != null) ...[
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: _launchYoutubeUrl,
                icon: const Icon(Icons.play_circle_outline),
                label: const Text('Watch Tutorial Video'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
} 