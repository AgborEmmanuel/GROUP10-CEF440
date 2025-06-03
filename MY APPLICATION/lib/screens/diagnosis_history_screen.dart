import 'package:flutter/material.dart';
import 'package:cardocai/models/diagnosis_report.dart';
import 'package:cardocai/screens/diagnosis_report_screen.dart';

class DiagnosisHistoryScreen extends StatefulWidget {
  const DiagnosisHistoryScreen({super.key});

  @override
  State<DiagnosisHistoryScreen> createState() => _DiagnosisHistoryScreenState();
}

class _DiagnosisHistoryScreenState extends State<DiagnosisHistoryScreen> {
  // Simulated diagnosis history data
  final List<DiagnosisReport> _diagnosisHistory = [
    DiagnosisReport(
      id: '1',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      issueType: 'Engine Misfire',
      urgencyLevel: 'High',
      description: 'High probability of cylinder 2 misfire detected from engine sound analysis.',
      repairSuggestion: 'Check and replace spark plugs in cylinder 2. Inspect fuel injector performance.',
      youtubeLink: 'https://youtube.com/watch?v=example1',
      confidenceScore: 0.85,
    ),
    DiagnosisReport(
      id: '2',
      timestamp: DateTime.now().subtract(const Duration(days: 3)),
      issueType: 'ABS Warning',
      urgencyLevel: 'Medium',
      description: 'ABS warning light indicates potential sensor or system malfunction.',
      repairSuggestion: 'Inspect ABS sensors and wiring. Check brake fluid level.',
      youtubeLink: 'https://youtube.com/watch?v=example2',
      confidenceScore: 0.92,
    ),
    DiagnosisReport(
      id: '3',
      timestamp: DateTime.now().subtract(const Duration(days: 7)),
      issueType: 'Battery Alert',
      urgencyLevel: 'Low',
      description: 'Battery voltage reading below normal operating range.',
      repairSuggestion: 'Test battery condition and charging system.',
      youtubeLink: 'https://youtube.com/watch?v=example3',
      confidenceScore: 0.78,
    ),
  ];

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Diagnosis History'),
        backgroundColor: Colors.blue,
      ),
      body: _diagnosisHistory.isEmpty
          ? const Center(
              child: Text(
                'No diagnosis history yet',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _diagnosisHistory.length,
              itemBuilder: (context, index) {
                final report = _diagnosisHistory[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DiagnosisReportScreen(report: report),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.warning_amber_rounded,
                                color: _getUrgencyColor(report.urgencyLevel),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  report.issueType,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  report.hasNotification
                                      ? Icons.notifications_active
                                      : Icons.notifications_none,
                                  color: report.hasNotification
                                      ? Colors.blue
                                      : Colors.grey,
                                ),
                                onPressed: () {
                                  setState(() {
                                    report.hasNotification = !report.hasNotification;
                                  });
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            report.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${report.timestamp.day}/${report.timestamp.month}/${report.timestamp.year}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[500],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _getUrgencyColor(report.urgencyLevel)
                                      .withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  report.urgencyLevel,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: _getUrgencyColor(report.urgencyLevel),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
} 