import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/mqtt_service_base.dart';
import 'services/database_service.dart';
import 'providers/device_provider.dart';
import 'providers/usage_provider.dart';
import 'screens/home_screen.dart';

class SmartToiletApp extends StatelessWidget {
  final MqttServiceBase mqttService;
  final DatabaseService databaseService;

  const SmartToiletApp({
    super.key,
    required this.mqttService,
    required this.databaseService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => DeviceProvider(mqttService: mqttService),
        ),
        ChangeNotifierProvider(
          create: (_) => UsageProvider(databaseService: databaseService),
        ),
      ],
      child: MaterialApp(
        title: 'Smart Toilet',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(centerTitle: true),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
