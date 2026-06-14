import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/device_provider.dart';

class ControlScreen extends StatelessWidget {
  const ControlScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DeviceProvider>();
    final device = provider.device;

    return Scaffold(
      appBar: AppBar(title: const Text('Detailed Control')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildTemperatureSlider(
            context,
            icon: Icons.thermostat,
            label: 'Seat Temp',
            value: device?.seatTemperature ?? 25,
            min: 20,
            max: 40,
            onChanged: (v) => provider.setSeatTemperature(v.toInt()),
          ),
          const SizedBox(height: 16),
          _buildTemperatureSlider(
            context,
            icon: Icons.water_drop,
            label: 'Water Temp',
            value: device?.waterTemperature ?? 30,
            min: 25,
            max: 45,
            onChanged: (v) => provider.setWaterTemperature(v.toInt()),
          ),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Night Light'),
                  subtitle: const Text('Auto night lighting'),
                  value: device?.nightLight ?? false,
                  onChanged: (_) => provider.toggleNightLight(),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Deodorizer'),
                  subtitle: const Text('Auto deodorizing'),
                  value: device?.deodorizer ?? false,
                  onChanged: (_) => provider.toggleDeodorizer(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTemperatureSlider(
    BuildContext context, {
    required IconData icon,
    required String label,
    required int value,
    required int min,
    required int max,
    required ValueChanged<double> onChanged,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon),
                const SizedBox(width: 8),
                Text(label),
                const Spacer(),
                Text(
                  '$value°C',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Slider(
              value: value.toDouble(),
              min: min.toDouble(),
              max: max.toDouble(),
              divisions: (max - min),
              label: '$value°C',
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }
}
