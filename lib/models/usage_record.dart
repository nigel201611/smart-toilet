class UsageRecord {
  final int? id;
  final String deviceId;
  final DateTime startTime;
  final DateTime? endTime;
  final int durationSeconds;
  final int waterUsageMl;
  final String mode;

  UsageRecord({
    this.id,
    required this.deviceId,
    required this.startTime,
    this.endTime,
    this.durationSeconds = 0,
    this.waterUsageMl = 0,
    this.mode = 'bidet',
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'deviceId': deviceId,
    'startTime': startTime.toIso8601String(),
    'endTime': endTime?.toIso8601String(),
    'durationSeconds': durationSeconds,
    'waterUsageMl': waterUsageMl,
    'mode': mode,
  };

  factory UsageRecord.fromMap(Map<String, dynamic> map) => UsageRecord(
    id: map['id'] as int?,
    deviceId: map['deviceId'] as String,
    startTime: DateTime.parse(map['startTime'] as String),
    endTime: map['endTime'] != null
        ? DateTime.parse(map['endTime'] as String)
        : null,
    durationSeconds: map['durationSeconds'] as int? ?? 0,
    waterUsageMl: map['waterUsageMl'] as int? ?? 0,
    mode: map['mode'] as String? ?? 'bidet',
  );
}
