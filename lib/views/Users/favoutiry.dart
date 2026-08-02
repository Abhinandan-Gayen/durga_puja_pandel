import 'package:durga_puja_pandel/core/theme/normal_color.dart';
import 'package:durga_puja_pandel/views/Users/favourite_route_map_screen.dart';
import 'package:durga_puja_pandel/views/widgets/pandel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../controllers/pandal_controller.dart';

class FavouritesScreen extends StatefulWidget {
  const FavouritesScreen({
    super.key,
    required this.saved,
    required this.onSaved,
  });
  final Set<int> saved;
  final ValueChanged<int> onSaved;

  @override
  State<FavouritesScreen> createState() => _FavouritesScreenState();
}

class _FavouritesScreenState extends State<FavouritesScreen> {
  @override
  Widget build(BuildContext context) {
    final firebasePandals = context.watch<PandalController>().pandals;
    final savedIndexes = widget.saved
        .where((index) => index >= 0 && index < firebasePandals.length)
        .toList();
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E9),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE50914),
        elevation: 3,
        shadowColor: Colors.black.withValues(alpha: 0.15),
        centerTitle: true,
        title: const Text(
          "My Wishlist",
          style: TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Color(0xFFE50914),
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
          systemNavigationBarColor: Colors.white,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          Container(
            height: 50, // হাইট বাড়ানো হয়েছে
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBF5),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: const Color(0xFFE4C6B4), width: 0.8),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x1A000000),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: TextField(
              cursorColor: const Color.fromARGB(255, 216, 113, 117),
              style: const TextStyle(color: Color(0xFF333333), fontSize: 15),
              decoration: InputDecoration(
                hintText: 'Search pandals, areas, events...',
                hintStyle: const TextStyle(
                  color: Color(0xFF8D8580),
                  fontSize: 14,
                ),
                prefixIconConstraints: const BoxConstraints(minWidth: 50),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: Color(0xFFE50914),
                  size: 24,
                ),
                suffixIconConstraints: const BoxConstraints(minWidth: 50),

                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Text(
                '${savedIndexes.length} pandals saved',
                style: const TextStyle(color: Colors.black, fontSize: 16),
              ),
              const Spacer(),
              const Text('Sort by distance', style: TextStyle(color: muted)),
            ],
          ),
          const SizedBox(height: 12),
          if (savedIndexes.isEmpty)
            const Padding(
              padding: EdgeInsets.all(50),
              child: Center(child: Text('No favourites yet')),
            )
          else
            ...savedIndexes.map((index) {
              final firebasePandal = firebasePandals[index];
              final imageUrl = firebasePandal.thumbnailUrl.isNotEmpty
                  ? firebasePandal.thumbnailUrl
                  : firebasePandal.images.isNotEmpty
                  ? firebasePandal.images.first
                  : '';
              final tilePandal = Pandal(
                firebasePandal.name,
                firebasePandal.name,
                firebasePandal.area,
                '',
                firebasePandal.averageRating.toStringAsFixed(1),
                firebasePandal.crowdLevel,
                firebasePandal.themeName,
                imageUrl,
                firebasePandal.latitude,
                firebasePandal.longitude,
              );

              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: PandalTile(
                  pandal: tilePandal,
                  saved: true,
                  onSaved: () => widget.onSaved(index),
                  onNavigate: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) =>
                            FavouriteRouteMapScreen(pandal: tilePandal),
                      ),
                    );
                  },
                ),
              );
            }),
          SizedBox(height: 60),
        ],
      ),
    );
  }
}
