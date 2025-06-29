class WarningLight {
  final String lightId;
  final String symbolName;
  final String? iconPath;
  final String? manufacturer;
  final String? description;
  final String severity;
  final List<String> commonCauses;
  final List<String> repairSuggestions;
  final DateTime createdAt;

  WarningLight({
    required this.lightId,
    required this.symbolName,
    this.iconPath,
    this.manufacturer,
    this.description,
    required this.severity,
    required this.commonCauses,
    required this.repairSuggestions,
    required this.createdAt,
  });

  factory WarningLight.fromJson(Map<String, dynamic> json) {
    return WarningLight(
      lightId: json['light_id'],
      symbolName: json['symbol_name'],
      iconPath: json['icon_path'],
      manufacturer: json['manufacturer'],
      description: json['description'],
      severity: json['severity'],
      commonCauses: List<String>.from(json['common_causes'] ?? []),
      repairSuggestions: List<String>.from(json['repair_suggestions'] ?? []),
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'light_id': lightId,
      'symbol_name': symbolName,
      'icon_path': iconPath,
      'manufacturer': manufacturer,
      'description': description,
      'severity': severity,
      'common_causes': commonCauses,
      'repair_suggestions': repairSuggestions,
      'created_at': createdAt.toIso8601String(),
    };
  }
} 