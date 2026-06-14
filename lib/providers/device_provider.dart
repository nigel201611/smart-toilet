import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/toilet_device.dart';
import '../services/mqtt_service_base.dart';

class DeviceProvider extends ChangeNotifier {
  final MqttServiceBase _mqttService;

  ToiletDevice? _device;
  bool _isConnecting = false;
  String? _error;
  StreamSubscription? _statusSub;
  StreamSubscription? _connectionSub;

  DeviceProvider({required this._mqttService});

  ToiletDevice? get device => _device;
  bool get isConnecting => _isConnecting;
  String? get error => _error;
  bool get isConnected => _mqttService.state == AppMqttState.connected;
  AppMqttState get connectionState => _mqttService.state;

  Future<void> connect(String deviceId, {String? host, int? port}) async {
    _isConnecting = true;
    _error = null;
    notifyListeners();

    _statusSub?.cancel();
    _connectionSub?.cancel();

    _statusSub = _mqttService.deviceStatusStream.listen((device) {
      _device = device;
      _error = null;
      notifyListeners();
    });

    _connectionSub = _mqttService.connectionStateStream.listen((state) {
      if (state == AppMqttState.disconnected && _device != null) {
        _device!.isOnline = false;
        notifyListeners();
      }
    });

    final success = await _mqttService.connect(
      host: host,
      port: port,
      deviceId: deviceId,
    );

    _isConnecting = false;
    if (!success) {
      _error = 'Connection failed. Please check network and configuration.';
    }
    notifyListeners();
  }

  Future<void> sendCommand(String command, {String? value}) async {
    if (_device == null) return;
    await _mqttService.publishCommand(_device!.id, {
      command: value ?? 'toggle',
    });
  }

  Future<void> setSeatTemperature(int temp) async {
    await sendCommand('seatTemp', value: temp.toString());
    _device?.seatTemperature = temp;
    notifyListeners();
  }

  Future<void> setWaterTemperature(int temp) async {
    await sendCommand('waterTemp', value: temp.toString());
    _device?.waterTemperature = temp;
    notifyListeners();
  }

  Future<void> toggleNightLight() async {
    final newValue = !(_device?.nightLight ?? false);
    await sendCommand('nightLight', value: newValue.toString());
    _device?.nightLight = newValue;
    notifyListeners();
  }

  Future<void> toggleDeodorizer() async {
    final newValue = !(_device?.deodorizer ?? false);
    await sendCommand('deodorizer', value: newValue.toString());
    _device?.deodorizer = newValue;
    notifyListeners();
  }

  Future<void> flush() async {
    if (_device == null) return;
    await sendCommand('flush');
    _device?.isFlushing = true;
    notifyListeners();
    Future.delayed(const Duration(seconds: 3), () {
      _device?.isFlushing = false;
      notifyListeners();
    });
  }

  Future<void> disconnect() async {
    _statusSub?.cancel();
    _connectionSub?.cancel();
    _mqttService.disconnect();
    _device = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _statusSub?.cancel();
    _connectionSub?.cancel();
    super.dispose();
  }
}
