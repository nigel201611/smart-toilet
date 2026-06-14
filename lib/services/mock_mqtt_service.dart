import 'dart:async';
import 'dart:math';
import '../models/toilet_device.dart';
import 'mqtt_service_base.dart';

class MockMqttService implements MqttServiceBase {
  final _deviceStatusController = StreamController<ToiletDevice>.broadcast();
  final _connectionStateController = StreamController<AppMqttState>.broadcast();

  AppMqttState _state = AppMqttState.disconnected;
  Timer? _statusTimer;
  Timer? _occupancyTimer;

  ToiletDevice? _device;
  final _random = Random();

  @override
  Stream<ToiletDevice> get deviceStatusStream => _deviceStatusController.stream;
  @override
  Stream<AppMqttState> get connectionStateStream =>
      _connectionStateController.stream;
  @override
  AppMqttState get state => _state;

  @override
  Future<bool> connect({
    String? host,
    int? port,
    required String deviceId,
  }) async {
    _updateState(AppMqttState.connecting);

    // Simulate connection delay
    await Future.delayed(const Duration(seconds: 1));

    _device = ToiletDevice(
      id: deviceId,
      name: 'Mock Device',
      mqttTopic: 'mock/toilet/$deviceId',
      isOnline: true,
      seatTemperature: 28,
      waterTemperature: 35,
      ambientTemperature: 22,
      isOccupied: false,
      nightLight: false,
      deodorizer: false,
    );

    _updateState(AppMqttState.connected);
    _deviceStatusController.add(_device!);

    // Simulate periodic status updates
    _statusTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      _simulateStatusUpdate();
    });

    // Simulate random occupancy changes
    _occupancyTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      _simulateOccupancyChange();
    });

    return true;
  }

  @override
  Future<void> publishCommand(
    String deviceId,
    Map<String, dynamic> command,
  ) async {
    if (_device == null || state != AppMqttState.connected) return;

    for (final entry in command.entries) {
      switch (entry.key) {
        case 'seatTemp':
          _device!.seatTemperature =
              int.tryParse(entry.value) ?? _device!.seatTemperature;
        case 'waterTemp':
          _device!.waterTemperature =
              int.tryParse(entry.value) ?? _device!.waterTemperature;
        case 'nightLight':
          _device!.nightLight = entry.value == 'true';
        case 'deodorizer':
          _device!.deodorizer = entry.value == 'true';
        case 'flush':
          _device!.isFlushing = true;
          _deviceStatusController.add(_device!);
          Future.delayed(const Duration(seconds: 3), () {
            _device!.isFlushing = false;
            _deviceStatusController.add(_device!);
          });
          return;
      }
    }
    _deviceStatusController.add(_device!);
  }

  void _simulateStatusUpdate() {
    if (_device == null) return;
    _device!.ambientTemperature = 20 + _random.nextInt(5);
    _device!.lastSeen = DateTime.now();
    _deviceStatusController.add(_device!);
  }

  void _simulateOccupancyChange() {
    if (_device == null) return;
    _device!.isOccupied = _random.nextBool();
    _deviceStatusController.add(_device!);
  }

  void _updateState(AppMqttState newState) {
    _state = newState;
    _connectionStateController.add(newState);
  }

  @override
  void disconnect() {
    _statusTimer?.cancel();
    _occupancyTimer?.cancel();
    _device = null;
    _updateState(AppMqttState.disconnected);
  }

  @override
  void dispose() {
    disconnect();
    _deviceStatusController.close();
    _connectionStateController.close();
  }
}
