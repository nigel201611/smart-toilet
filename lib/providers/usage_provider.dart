import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../models/usage_record.dart';
import '../services/database_service.dart';

class UsageProvider extends ChangeNotifier {
  final DatabaseService _databaseService;

  List<UsageRecord> _records = [];
  Map<String, dynamic> _statistics = {};
  bool _isLoading = false;

  UsageProvider({required this._databaseService});

  List<UsageRecord> get records => _records;
  Map<String, dynamic> get statistics => _statistics;
  bool get isLoading => _isLoading;

  Future<void> loadRecords({String? deviceId}) async {
    _isLoading = true;
    notifyListeners();

    _records = await _databaseService.getUsageRecords(deviceId: deviceId);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadStatistics({
    String? deviceId,
    DateTime? from,
    DateTime? to,
  }) async {
    _statistics = await _databaseService.getStatistics(
      deviceId: deviceId,
      from: from,
      to: to,
    );
    notifyListeners();
  }

  Future<void> loadTodayStats(String deviceId) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    await loadStatistics(deviceId: deviceId, from: today, to: now);
  }

  Future<void> loadWeeklyStats(String deviceId) async {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    await loadStatistics(deviceId: deviceId, from: weekAgo, to: now);
  }

  Future<void> recordUsage(
    String deviceId, {
    int durationSeconds = 0,
    int waterUsageMl = 0,
    String mode = 'bidet',
  }) async {
    final record = UsageRecord(
      deviceId: deviceId,
      startTime: DateTime.now(),
      durationSeconds: durationSeconds,
      waterUsageMl: waterUsageMl,
      mode: mode,
    );
    await _databaseService.insertUsageRecord(record);
    _records.insert(0, record);
    notifyListeners();
  }

  List<Map<String, dynamic>> getDailyUsageChartData() {
    final Map<String, int> dayCounts = {};
    for (final record in _records) {
      final day = DateFormat('MM/dd').format(record.startTime);
      dayCounts[day] = (dayCounts[day] ?? 0) + 1;
    }
    return dayCounts.entries
        .map((e) => {'day': e.key, 'count': e.value})
        .toList()
      ..sort((a, b) => a['day'].toString().compareTo(b['day'].toString()));
  }

  List<Map<String, dynamic>> getWeeklyUsageChartData() {
    final now = DateTime.now();
    final data = <Map<String, dynamic>>[];
    for (int i = 6; i >= 0; i--) {
      final day = now.subtract(Duration(days: i));
      final dayStr = DateFormat('MM/dd').format(day);
      final dayStart = DateTime(day.year, day.month, day.day);
      final dayEnd = dayStart.add(
        const Duration(hours: 23, minutes: 59, seconds: 59),
      );

      final count = _records
          .where(
            (r) =>
                r.startTime.isAfter(dayStart) && r.startTime.isBefore(dayEnd),
          )
          .length;

      data.add({'day': dayStr, 'count': count});
    }
    return data;
  }

  Future<int> getTodayCount(String deviceId) async {
    return _databaseService.getTodayUsageCount(deviceId);
  }

  int get totalWaterUsage {
    int total = 0;
    for (final record in _records) {
      total += record.waterUsageMl;
    }
    return total;
  }
}
