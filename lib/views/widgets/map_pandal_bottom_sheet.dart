import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../controllers/map_controller.dart';
import '../../models/pandal_model.dart';
import 'crowd_level_chip.dart';
import 'rating_widget.dart';

class MapPandalBottomSheet extends StatelessWidget {
  const MapPandalBottomSheet({super.key, required this.pandal});

  final PandalModel pandal;

  @override
  Widget build(BuildContext context) {
    final mapController = context.watch<MapController>();
    final distance = mapController.distanceTo(pandal);
    final imageUrl = pandal.thumbnailUrl.isNotEmpty
        ? pandal.thumbnailUrl
        : pandal.images.isEmpty
        ? null
        : pandal.images.first;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: 84,
                    height: 84,
                    child: imageUrl == null
                        ? const ColoredBox(
                            color: Color(0xFFFFE6BE),
                            child: Icon(Icons.temple_hindu),
                          )
                        : CachedNetworkImage(
                            imageUrl: imageUrl,
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pandal.name,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 4),
                      Text('${pandal.area}, ${pandal.city}'),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          CrowdLevelChip(level: pandal.crowdLevel),
                          RatingWidget(rating: pandal.averageRating),
                          if (distance != null)
                            Text('${distance.toStringAsFixed(1)} km away'),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.info_outline),
                    label: const Text('View Details'),
                    onPressed: () {
                      Navigator.of(context).pop();
                      Get.toNamed('/pandal/${pandal.id}');
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: PopupMenuButton<String>(
                    onSelected: (mode) => context
                        .read<MapController>()
                        .openDirectionToPandal(pandal, travelMode: mode),
                    itemBuilder: (context) => const [
                      PopupMenuItem(
                        value: 'driving',
                        child: Text('Driving direction'),
                      ),
                      PopupMenuItem(
                        value: 'walking',
                        child: Text('Walking direction'),
                      ),
                    ],
                    child: Container(
                      height: 48,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.directions, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            'Direction',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
