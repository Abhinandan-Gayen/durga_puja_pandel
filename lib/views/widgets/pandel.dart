import 'package:durga_puja_pandel/core/theme/normal_color.dart';
import 'package:flutter/material.dart';

class Pandal {
  const Pandal(
    this.bn,
    this.en,
    this.area,
    this.distance,
    this.rating,
    this.crowd,
    this.theme,
    this.image,
    this.latitude,
    this.longitude,
  );
  final String bn, en, area, distance, rating, crowd, theme, image;
  final double latitude, longitude;
}

class PandalTile extends StatelessWidget {
  const PandalTile({
    super.key,
    required this.pandal,
    this.compact = false,
    this.saved = false,
    this.onSaved,
    this.onNavigate,
  });
  final Pandal pandal;
  final bool compact, saved;
  final VoidCallback? onSaved;
  final VoidCallback? onNavigate;
  @override
  Widget build(BuildContext context) {
    final crowdColor = pandal.crowd == 'Low'
        ? Colors.green
        : pandal.crowd == 'High'
        ? Colors.redAccent
        : gold;
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Color(0xFFFFFCF6),
        // color: Colors.red,
        borderRadius: BorderRadius.circular(20),
        // border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .05),
            blurRadius: 5,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: compact
          ? Padding(
              padding: const EdgeInsets.all(11),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(13),
                    child: Image.network(
                      pandal.image,
                      width: 88,
                      height: 88,
                      fit: BoxFit.cover,
                      errorBuilder: errorImage,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _PandalInfo(pandal: pandal, crowdColor: crowdColor),
                  ),
                  IconButton(
                    onPressed: onSaved,
                    icon: Icon(
                      saved ? Icons.favorite : Icons.favorite_border,
                      color: !saved ? null : Colors.red,
                    ),
                  ),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(11),
              child: Column(
                children: [
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(13),
                        child: Image.network(
                          pandal.image,
                          width: 88,
                          height: 88,
                          fit: BoxFit.cover,
                          errorBuilder: errorImage,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _PandalInfo(
                          pandal: pandal,
                          crowdColor: crowdColor,
                        ),
                      ),
                      IconButton(
                        onPressed: onSaved,
                        icon: Icon(
                          saved ? Icons.favorite : Icons.favorite_border,
                          color: !saved ? null : Colors.red,
                          size: 30,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFB91419),
                      ),
                      onPressed: onNavigate ?? () {},
                      icon: const Image(
                        image: AssetImage("assets/Send_light@4x.png"),
                        color: Colors.white,
                        height: 30,
                      ),
                      label: const Text('Navigate'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

Widget errorImage(BuildContext context, Object error, StackTrace? stack) =>
    Container(
      color: surface2,
      alignment: Alignment.center,
      child: const Text('🛕', style: TextStyle(fontSize: 38)),
    );

class _PandalInfo extends StatelessWidget {
  const _PandalInfo({required this.pandal, required this.crowdColor});
  final Pandal pandal;
  final Color crowdColor;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        pandal.bn,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 4),
      Text(
        '${pandal.area} · ${pandal.distance}',
        style: const TextStyle(color: muted, fontSize: 12),
      ),
      const SizedBox(height: 7),
      Wrap(
        spacing: 8,
        children: [
          Text(
            '⭐ ${pandal.rating}',
            style: const TextStyle(color: gold, fontSize: 12),
          ),
        ],
      ),
    ],
  );
}

class OpenPill extends StatelessWidget {
  const OpenPill({super.key});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: const Color(0xCC073E21),
      borderRadius: BorderRadius.circular(20),
    ),
    child: const Text(
      '● Open',
      style: TextStyle(color: Colors.greenAccent, fontSize: 11),
    ),
  );
}
