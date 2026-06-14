import 'dart:async';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import '../config/mqtt_config.dart';
import '../models/toilet_device.dart';
import 'mqtt_service_base.dart';

class MqttService implements MqttServiceBase {
  MqttServerClient? _client;
  final StreamController<ToiletDevice> _deviceStatusController =
      StreamController<ToiletDevice>.broadcast();
  final StreamController<AppMqttState> _connectionStateController =
      StreamController<AppMqttState>.broadcast();

  AppMqttState _state = AppMqttState.disconnected;
  String? _host;
  int? _port;
  String? _deviceTopic;

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
    _host = host ?? MqttConfig.defaultBroker;
    _port = port ?? MqttConfig.defaultPort;
    _deviceTopic = MqttConfig.statusTopic(deviceId);

    _updateState(AppMqttState.connecting);

    _client = MqttServerClient(_host!, MqttConfig.clientIdPrefix + deviceId);
    _client!.port = _port!;
    _client!.keepAlivePeriod = 60;
    _client!.logging(on: false);
    _client!.autoReconnect = true;
    _client!.resubscribeOnAutoReconnect = true;

    final connMessage = MqttConnectMessage()
        .withClientIdentifier(MqttConfig.clientIdPrefix + deviceId)
        .startClean()
        .withWillQos(MqttQos.atLeastOnce);
    _client!.connectionMessage = connMessage;

    try {
      await _client!.connect();
    } catch (e) {
      _updateState(AppMqttState.disconnected);
      return false;
    }

    if (_client!.connectionStatus?.state == MqttConnectionState.connected) {
      _updateState(AppMqttState.connected);
      _subscribeToTopics(deviceId);
      _listenForMessages();
      return true;
    }

    _updateState(AppMqttState.disconnected);
    return false;
  }

  void _subscribeToTopics(String deviceId) {
    _client!.subscribe(MqttConfig.statusTopic(deviceId), MqttQos.atLeastOnce);
    _client!.subscribe(
      MqttConfig.telemetryTopic(deviceId),
      MqttQos.atLeastOnce,
    );
  }

  void _listenForMessages() {
    _client!.updates?.listen((List<MqttReceivedMessage<MqttMessage>> messages) {
      for (final msg in messages) {
        final topic = msg.topic;
        final payload =
            (msg.payload as MqttPublishMessage).payload.message as String;

        if (topic.contains('/status') || topic.contains('/telemetry')) {
          _handleDeviceMessage(payload);
        }
      }
    });
  }

  void _handleDeviceMessage(String payload) {
    try {
      final data = Uri.splitQueryString(
        payload.replaceAll('{', '').replaceAll('}', '').replaceAll('"', ''),
      );

      final device = ToiletDevice(
        id: data['id'] ?? _deviceTopic ?? 'unknown',
        name: data['name'] ?? 'Smart Toilet',
        mqttTopic: _deviceTopic ?? '',
        isOnline: true,
        seatTemperature: int.tryParse(data['seatTemp'] ?? '') ?? 25,
        waterTemperature: int.tryParse(data['waterTemp'] ?? '') ?? 30,
        ambientTemperature: int.tryParse(data['ambientTemp'] ?? '') ?? 20,
        isOccupied: data['occupied'] == 'true',
        nightLight: data['nightLight'] == 'true',
        deodorizer: data['deodorizer'] == 'true',
        lastSeen: DateTime.now(),
      );
      _deviceStatusController.add(device);
    } catch (_) {}
  }

  @override
  Future<void> publishCommand(
    String deviceId,
    Map<String, dynamic> command,
  ) async {
    if (_client == null ||
        _client!.connectionStatus?.state != MqttConnectionState.connected) {
      return;
    }
    final topic = MqttConfig.commandTopic(deviceId);
    final payload = command.entries
        .map((e) => '"${e.key}":"${e.value}"')
        .join(',');
    final builder = MqttClientPayloadBuilder();
    builder.addString('{$payload}');
    _client!.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);
  }

  void _updateState(AppMqttState newState) {
    _state = newState;
    _connectionStateController.add(newState);
  }

  @override
  void disconnect() {
    _client?.disconnect();
    _client = null;
    _updateState(AppMqttState.disconnected);
  }

  @override
  void dispose() {
    disconnect();
    _deviceStatusController.close();
    _connectionStateController.close();
  }
}
