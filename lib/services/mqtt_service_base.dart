import 'dart:async';
import '../models/toilet_device.dart';

enum AppMqttState { disconnected, connecting, connected }

abstract class MqttServiceBase {
  Stream<ToiletDevice> get deviceStatusStream;
  Stream<AppMqttState> get connectionStateStream;
  AppMqttState get state;

  Future<bool> connect({String? host, int? port, required String deviceId});
  Future<void> publishCommand(String deviceId, Map<String, dynamic> command);
  void disconnect();
  void dispose();
}
