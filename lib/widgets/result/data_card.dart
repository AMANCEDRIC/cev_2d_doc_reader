import 'package:flutter/material.dart';
import '../glass_container.dart';

class DataCard extends StatelessWidget {
  final List<Widget> children;

  const DataCard({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      opacity: 0.05,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: children,
      ),
    );
  }
}
