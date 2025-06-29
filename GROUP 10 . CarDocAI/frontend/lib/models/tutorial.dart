class Tutorial {
  final String tutorialId;
  final String title;
  final String? description;
  final String? youtubeUrl;
  final int? duration;
  final String difficultyLevel;
  final int viewCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> relatedWarningLights;
  final List<String> relatedEngineSounds;

  Tutorial({
    required this.tutorialId,
    required this.title,
    this.description,
    this.youtubeUrl,
    this.duration,
    required this.difficultyLevel,
    required this.viewCount,
    required this.createdAt,
    required this.updatedAt,
    required this.relatedWarningLights,
    required this.relatedEngineSounds,
  });

  factory Tutorial.fromJson(Map<String, dynamic> json) {
    return Tutorial(
      tutorialId: json['tutorial_id'],
      title: json['title'],
      description: json['description'],
      youtubeUrl: json['youtube_url'],
      duration: json['duration'],
      difficultyLevel: json['difficulty_level'],
      viewCount: json['view_count'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      relatedWarningLights: List<String>.from(json['related_warning_lights'] ?? []),
      relatedEngineSounds: List<String>.from(json['related_engine_sounds'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tutorial_id': tutorialId,
      'title': title,
      'description': description,
      'youtube_url': youtubeUrl,
      'duration': duration,
      'difficulty_level': difficultyLevel,
      'view_count': viewCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'related_warning_lights': relatedWarningLights,
      'related_engine_sounds': relatedEngineSounds,
    };
  }
} 