import 'package:flutter/material.dart';

class ControlPanel extends StatelessWidget {
  final bool isConnected;
  final bool nightLight;
  final bool deodorizer;
  final bool isFlushing;
  final VoidCallback? onNightLightToggle;
  final VoidCallback? onDeodorizerToggle;
  final VoidCallback? onFlush;

  const ControlPanel({
    super.key,
    required this.isConnected,
    required this.nightLight,
    required this.deodorizer,
    required this.isFlushing,
    this.onNightLightToggle,
    this.onDeodorizerToggle,
    this.onFlush,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Control',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildControlButton(
                  icon: Icons.nightlight_outlined,
                  label: 'Night Light',
                  active: nightLight,
                  onPressed: isConnected ? onNightLightToggle : null,
                ),
                _buildControlButton(
                  icon: Icons.air,
                  label: 'Deodorizer',
                  active: deodorizer,
                  onPressed: isConnected ? onDeodorizerToggle : null,
                ),
                _buildControlButton(
                  icon: Icons.water,
                  label: isFlushing ? 'Flushing' : 'Flush',
                  active: isFlushing,
                  color: isFlushing ? Colors.blue : null,
                  onPressed: isConnected && !isFlushing ? onFlush : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required bool active,
    required VoidCallback? onPressed,
    Color? color,
  }) {
    return Column(
      children: [
        IconButton(
          iconSize: 36,
          icon: Icon(icon),
          color: active ? (color ?? Colors.blue) : Colors.grey,
          onPressed: onPressed,
        ),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
