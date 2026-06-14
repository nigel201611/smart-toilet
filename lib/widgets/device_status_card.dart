import 'package:flutter/material.dart';
import '../models/toilet_device.dart';

class DeviceStatusCard extends StatelessWidget {
  final ToiletDevice? device;

  const DeviceStatusCard({super.key, this.device});

  @override
  Widget build(BuildContext context) {
    if (device == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Center(
            child: Text('No device connected', style: TextStyle(fontSize: 16)),
          ),
        ),
      );
    }

    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  device!.isOnline ? Icons.wifi : Icons.wifi_off,
                  color: device!.isOnline ? Colors.green : Colors.grey,
                ),
                const SizedBox(width: 8),
                Text(device!.name, style: theme.textTheme.titleMedium),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: device!.isOccupied
                        ? Colors.orange.withValues(alpha: 0.2)
                        : Colors.green.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    device!.isOccupied ? 'In Use' : 'Idle',
                    style: TextStyle(
                      color: device!.isOccupied ? Colors.orange : Colors.green,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(),
            _buildInfoRow(
              Icons.thermostat,
              'Seat',
              '${device!.seatTemperature}°C',
            ),
            _buildInfoRow(
              Icons.water_drop,
              'Water',
              '${device!.waterTemperature}°C',
            ),
            _buildInfoRow(
              Icons.thermostat,
              'Ambient',
              '${device!.ambientTemperature}°C',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(color: Colors.grey)),
          const Spacer(),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
