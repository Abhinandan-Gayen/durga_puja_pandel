import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/favorite_controller.dart';
import '../../controllers/pandal_controller.dart';
import '../widgets/empty_widget.dart';
import '../widgets/pandal_card.dart';

class FavoriteScreen extends StatelessWidget {
  const FavoriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final favorites = context.watch<FavoriteController>();
    final pandals = context
        .watch<PandalController>()
        .pandals
        .where((pandal) => favorites.isFavorite(pandal.id))
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Favorites')),
      body: pandals.isEmpty
          ? const EmptyWidget(
              title: 'No favorites',
              message: 'Save pandals you want to revisit quickly.',
              icon: Icons.favorite_border,
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) =>
                  PandalCard(pandal: pandals[index]),
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemCount: pandals.length,
            ),
    );
  }
}
