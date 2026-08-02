
import 'package:durga_puja_pandel/core/theme/normal_color.dart';
import 'package:durga_puja_pandel/core/utils/globa_data.dart';
import 'package:durga_puja_pandel/views/widgets/pandel.dart';
import 'package:durga_puja_pandel/views/widgets/satrtcard.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FavouritesScreen extends StatefulWidget {
  const FavouritesScreen(
      {super.key, required this.saved, required this.onSaved});
  final Set<int> saved;
  final ValueChanged<int> onSaved;

  @override
  State<FavouritesScreen> createState() => _FavouritesScreenState();
}


class _FavouritesScreenState extends State<FavouritesScreen> {
  
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: ListView(padding: const EdgeInsets.all(20), children: [
        const Text('My Favourites',
            style: TextStyle(fontSize: 27, fontWeight: FontWeight.w800)),
        const Text('আমার পছন্দের প্যান্ডেল', style: TextStyle(color: gold)),
        const SizedBox(height: 22),
        Row(children: [
          Expanded(child: StatCard('💛', '${widget.saved.length}', 'Saved')),
          const SizedBox(width: 10),
          Expanded(child: StatCard('🟢', '${widget.saved.length}', 'Open Now')),
          const SizedBox(width: 10),
          Expanded(
              child: StatCard(
                  '😊',
                  '${widget.saved.where((i) => pandals[i].crowd == 'Low').length}',
                  'Low Crowd')),
        ]),
        const SizedBox(height: 24),
        Row(children: [
          Text('${widget.saved.length} pandals saved',
              style: const TextStyle(color: gold)),
          const Spacer(),
          const Text('Sort by distance', style: TextStyle(color: muted)),
        ]),
        const SizedBox(height: 12),
        if (widget.saved.isEmpty)
          const Padding(
              padding: EdgeInsets.all(50),
              child: Center(child: Text('No favourites yet')))
        else
          ...widget.saved.map((i) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: PandalTile(
                    pandal: pandals[i], saved: true, onSaved: () => widget.onSaved(i)),
              ))
      ]),
    );
  }
}
