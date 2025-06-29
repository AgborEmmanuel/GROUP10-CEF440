class MaintenanceRecord {
  final String maintenanceId;
  final String userId;
  final String? diagnosticId;
  final String maintenanceType;
  final DateTime? scheduledDate;
  final DateTime? completedDate;
  final String reminderStatus;
  final String? notes;
  final DateTime createdAt;

  MaintenanceRecord({
    required this.maintenanceId,
    required this.userId,
    this.diagnosticId,
    required this.maintenanceType,
    this.scheduledDate,
    this.completedDate,
    required this.reminderStatus,
    this.notes,
    required this.createdAt,
  });

  factory MaintenanceRecord.fromJson(Map<String, dynamic> json) {
    return MaintenanceRecord(
      maintenanceId: json['maintenance_id'],
      userId: json['user_id'],
      diagnosticId: json['diagnostic_id'],
      maintenanceType: json['maintenance_type'],
      scheduledDate: json['scheduled_date'] != null 
          ? DateTime.parse(json['scheduled_date'])
          : null,
      completedDate: json['completed_date'] != null 
          ? DateTime.parse(json['completed_date'])
          : null,
      reminderStatus: json['reminder_status'],
      notes: json['notes'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'maintenance_id': maintenanceId,
      'user_id': userId,
      'diagnostic_id': diagnosticId,
      'maintenance_type': maintenanceType,
      'scheduled_date': scheduledDate?.toIso8601String(),
      'completed_date': completedDate?.toIso8601String(),
      'reminder_status': reminderStatus,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
    };
  }
} 