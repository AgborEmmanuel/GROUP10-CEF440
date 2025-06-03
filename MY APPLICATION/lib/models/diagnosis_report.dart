class DiagnosisReport {
  final String id;
  final DateTime timestamp;
  final String issueType;
  final String urgencyLevel;
  final String description;
  final String repairSuggestion;
  final String? youtubeLink;
  final double confidenceScore;
  bool hasNotification;

  DiagnosisReport({
    required this.id,
    required this.timestamp,
    required this.issueType,
    required this.urgencyLevel,
    required this.description,
    required this.repairSuggestion,
    this.youtubeLink,
    required this.confidenceScore,
    this.hasNotification = false,
  });
} 