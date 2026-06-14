import 'package:flutter/material.dart';
import 'services/mqtt_service.dart';
import 'services/mock_mqtt_service.dart';
import 'services/mqtt_service_base.dart';
import 'services/database_service.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final databaseService = DatabaseService();
  await databaseService.database;

  // Set --dart-define=MOCK_MQTT=false to use real MQTT
  final MqttServiceBase mqttService =
      const bool.fromEnvironment('MOCK_MQTT', defaultValue: true)
      ? MockMqttService()
      : MqttService();

  runApp(
    SmartToiletApp(mqttService: mqttService, databaseService: databaseService),
  );
}
