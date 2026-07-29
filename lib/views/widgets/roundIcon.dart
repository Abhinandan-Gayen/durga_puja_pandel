
import 'package:durga_puja_pandel/core/theme/normal_color.dart';
import 'package:flutter/material.dart';

Widget roundIcon(IconData icon) => Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
          color: surface,
          shape: BoxShape.circle,
          border: Border.all(color: border)),
      child: Icon(icon, color: gold),
    );