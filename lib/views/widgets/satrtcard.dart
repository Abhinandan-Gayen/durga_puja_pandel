
import 'package:durga_puja_pandel/core/theme/normal_color.dart';
import 'package:flutter/material.dart';

class StatCard extends StatelessWidget {
  const StatCard(this.icon, this.value, this.label, {super.key});
  final String icon, value, label;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
        decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(17),
            border: Border.all(color: border)),
        child: Column(children: [
          Text(icon),
          Text(value,
              style: const TextStyle(
                  fontSize: 22, fontWeight: FontWeight.w900, color: gold)),
          Text(label,
              textAlign: TextAlign.center,
              style: const TextStyle(color: muted, fontSize: 10))
        ]),
      );
}