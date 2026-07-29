import 'package:durga_puja_pandel/core/theme/normal_color.dart';
import 'package:durga_puja_pandel/core/utils/globa_data.dart';
import 'package:durga_puja_pandel/views/widgets/pandel.dart';
import 'package:flutter/material.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(child: CustomPaint(painter: MapPainter())),
        const Positioned(
          top: 22,
          left: 20,
          child: Text(
            'Pandal Map · Kolkata',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
          ),
        ),
        Positioned(
          top: 62,
          left: 16,
          right: 16,
          child: Row(
            children: [
              _mapMode('Standard', true),
              _mapMode('Satellite', false),
              _mapMode('Crowd Heat', false),
            ],
          ),
        ),
        const Positioned(left: 52, top: 170, child: MapPin('Bagbazar')),
        const Positioned(right: 52, top: 220, child: MapPin('Sreebhumi')),
        const Positioned(
          left: 92,
          top: 300,
          child: MapPin('Suruchi', active: true),
        ),
        const Positioned(right: 100, top: 410, child: MapPin('Ali Park')),
        const Positioned(left: 60, top: 500, child: MapPin('Deshapriya')),
        const Positioned(right: 46, top: 530, child: MapPin('Ballygunge')),
        Positioned(
          left: 18,
          right: 18,
          bottom: 18,
          child: PandalTile(pandal: pandals.first, compact: true),
        ),
      ],
    );
  }
}

class MapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFF1A0909),
    );
    final grid = Paint()
      ..color = border.withValues(alpha: .42)
      ..strokeWidth = 1;
    for (double x = 0; x < size.width; x += 44) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid);
    }
    for (double y = 0; y < size.height; y += 44) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }
    final road = Paint()
      ..color = const Color(0xFF67451A)
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke;
    final p = Path()
      ..moveTo(0, size.height * .42)
      ..cubicTo(
        size.width * .3,
        size.height * .34,
        size.width * .55,
        size.height * .52,
        size.width,
        size.height * .4,
      );
    canvas.drawPath(p, road);
    canvas.drawLine(
      Offset(size.width * .33, 0),
      Offset(size.width * .32, size.height),
      road,
    );
    canvas.drawLine(
      Offset(size.width * .7, 0),
      Offset(size.width * .65, size.height),
      road,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

Widget _mapMode(String text, bool active) => Padding(
  padding: const EdgeInsets.only(right: 7),
  child: Chip(
    backgroundColor: active ? gold : surface,
    label: Text(text, style: TextStyle(color: active ? bg : Colors.white)),
  ),
);


class MapPin extends StatelessWidget {
  const MapPin(this.label, {super.key, this.active = false});
  final String label;
  final bool active;
  @override
  Widget build(BuildContext context) => Column(children: [
        Container(
          width: active ? 48 : 38,
          height: active ? 48 : 38,
          alignment: Alignment.center,
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: active ? gold : red,
              boxShadow: [
                if (active)
                  BoxShadow(
                      color: gold.withValues(alpha: .35),
                      blurRadius: 24,
                      spreadRadius: 15)
              ]),
          child: const Text('🛕'),
        ),
        Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
                color: bg, borderRadius: BorderRadius.circular(7)),
            child:
                Text(label, style: const TextStyle(color: gold, fontSize: 9))),
      ]);
}





