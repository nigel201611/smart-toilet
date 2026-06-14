import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/device_provider.dart';
import '../providers/usage_provider.dart';
import '../widgets/device_status_card.dart';
import '../widgets/control_panel.dart';
import 'control_screen.dart';
import 'statistics_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _deviceIdController = TextEditingController(text: 'toilet_001');
  final _hostController = TextEditingController(text: 'broker.emqx.io');

  @override
  void dispose() {
    _deviceIdController.dispose();
    _hostController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final deviceProvider = context.watch<DeviceProvider>();
    final usageProvider = context.watch<UsageProvider>();
    final device = deviceProvider.device;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Toilet'),
        actions: [
          if (deviceProvider.isConnected)
            IconButton(
              icon: const Icon(Icons.bar_chart),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChangeNotifierProvider.value(
                    value: usageProvider,
                    child: const StatisticsScreen(),
                  ),
                ),
              ),
            ),
          if (deviceProvider.isConnected)
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChangeNotifierProvider.value(
                    value: deviceProvider,
                    child: const ControlScreen(),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          if (device != null) {
            await usageProvider.loadTodayStats(device.id);
          }
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (!deviceProvider.isConnected) _buildConnectPanel(deviceProvider),
            DeviceStatusCard(device: device),
            if (deviceProvider.isConnected) ...[
              const SizedBox(height: 16),
              ControlPanel(
                isConnected: deviceProvider.isConnected,
                nightLight: device?.nightLight ?? false,
                deodorizer: device?.deodorizer ?? false,
                isFlushing: device?.isFlushing ?? false,
                onNightLightToggle: deviceProvider.toggleNightLight,
                onDeodorizerToggle: deviceProvider.toggleDeodorizer,
                onFlush: deviceProvider.flush,
              ),
              const SizedBox(height: 16),
              _buildTodaySummary(usageProvider, device?.id ?? ''),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildConnectPanel(DeviceProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Connect Device',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _deviceIdController,
              decoration: const InputDecoration(
                labelText: 'Device ID',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.perm_device_info),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _hostController,
              decoration: const InputDecoration(
                labelText: 'MQTT Server',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.dns),
              ),
            ),
            const SizedBox(height: 12),
            if (provider.error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  provider.error!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            FilledButton.icon(
              onPressed: provider.isConnecting
                  ? null
                  : () => provider.connect(
                      _deviceIdController.text.trim(),
                      host: _hostController.text.trim(),
                    ),
              icon: provider.isConnecting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.link),
              label: Text(provider.isConnecting ? 'Connecting...' : 'Connect'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodaySummary(UsageProvider provider, String deviceId) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Today Overview',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            FutureBuilder<int>(
              future: provider.getTodayCount(deviceId),
              initialData: 0,
              builder: (context, snapshot) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(
                      Icons.numbers,
                      'Usage Count',
                      '${snapshot.data ?? 0}',
                    ),
                    _buildStatItem(
                      Icons.water_drop,
                      'Water Usage',
                      '${provider.totalWaterUsage}ml',
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: Colors.blue),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}
