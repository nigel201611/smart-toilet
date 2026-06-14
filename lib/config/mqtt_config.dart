class MqttConfig {
  static const String defaultBroker = 'broker.emqx.io';
  static const int defaultPort = 1883;
  static const String clientIdPrefix = 'smart_toilet_';

  static String statusTopic(String deviceId) => 'toilet/$deviceId/status';
  static String commandTopic(String deviceId) => 'toilet/$deviceId/command';
  static String telemetryTopic(String deviceId) => 'toilet/$deviceId/telemetry';
}
