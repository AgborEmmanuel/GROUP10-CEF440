class EngineSound {
  final String soundId;
  final String soundType;
  final String? description;
  final String? frequencyRange;
  final String severityLevel;
  final List<String> commonCauses;
  final List<String> repairSuggestions;
  final DateTime createdAt;

  EngineSound({
    required this.soundId,
    required this.soundType,
    this.description,
    this.frequencyRange,
    required this.severityLevel,
    required this.commonCauses,
    required this.repairSuggestions,
    required this.createdAt,
  });

  factory EngineSound.fromJson(Map<String, dynamic> json) {
    return EngineSound(
      soundId: json['sound_id'],
      soundType: json['sound_type'],
      description: json['description'],
      frequencyRange: json['frequency_range'],
      severityLevel: json['severity_level'],
      commonCauses: List<String>.from(json['common_causes'] ?? []),
      repairSuggestions: List<String>.from(json['repair_suggestions'] ?? []),
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sound_id': soundId,
      'sound_type': soundType,
      'description': description,
      'frequency_range': frequencyRange,
      'severity_level': severityLevel,
      'common_causes': commonCauses,
      'repair_suggestions': repairSuggestions,
      'created_at': createdAt.toIso8601String(),
    };
  }
} 