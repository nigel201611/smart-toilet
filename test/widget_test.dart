import 'package:flutter_test/flutter_test.dart';
import 'package:smart_toilet/app.dart';
import 'package:smart_toilet/services/mqtt_service.dart';
import 'package:smart_toilet/services/database_service.dart';

void main() {
  testWidgets('app renders home screen', (WidgetTester tester) async {
    final databaseService = DatabaseService();
    final mqttService = MqttService();

    await tester.pumpWidget(
      SmartToiletApp(
        mqttService: mqttService,
        databaseService: databaseService,
      ),
    );

    expect(find.text('Smart Toilet'), findsOneWidget);
  });
}
