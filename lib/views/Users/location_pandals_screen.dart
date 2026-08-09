import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../controllers/pandal_controller.dart';
import '../../core/utils/distance_helper.dart';
import '../../models/pandal_model.dart';
import 'bottom-navigationBar/controller/botom_navigation_controller.dart';

class LocationPandalsScreen extends StatelessWidget {
  const LocationPandalsScreen({
    super.key,
    this.area,
    this.userLatitude,
    this.userLongitude,
  });

  final String? area;
  final double? userLatitude;
  final double? userLongitude;

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<PandalController>();
    final shellController = context.watch<AppShellController>();
    final normalizedArea = area?.trim().toLowerCase();
    final pandals = controller.pandals.where((pandal) {
      if (!pandal.isFeatured) return false;
      if (normalizedArea == null || normalizedArea.isEmpty) return true;
      return pandal.area.trim().toLowerCase() == normalizedArea;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E9),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE50914),
        foregroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          area == null ? 'Featured Pandals' : '$area Featured Pandals',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
      ),
      body: controller.isLoading && controller.pandals.isEmpty
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFE50914)),
            )
          : pandals.isEmpty
          ? const Center(
              child: Text(
                'No pandals found',
                style: TextStyle(
                  color: Color(0xFF8D8580),
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 30),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                // mainAxisExtent: 300,
                childAspectRatio: 0.70,
              ),
              itemCount: pandals.length,
              itemBuilder: (context, index) {
                final pandal = pandals[index];
                final firebaseIndex = controller.pandals.indexWhere(
                  (item) => item.id == pandal.id,
                );
                final distanceKm = userLatitude == null || userLongitude == null
                    ? null
                    : DistanceHelper.calculateDistanceInKm(
                        userLatitude!,
                        userLongitude!,
                        pandal.latitude,
                        pandal.longitude,
                      );
                final distanceText = distanceKm == null
                    ? null
                    : distanceKm < 1
                    ? '${(distanceKm * 1000).round()} m away'
                    : '${distanceKm.toStringAsFixed(1)} km away';
                return _DashboardStylePandalCard(
                  pandal: pandal,
                  distanceText: distanceText,
                  isFavorite:
                      firebaseIndex >= 0 &&
                      shellController.saved.contains(firebaseIndex),
                  onFavorite: firebaseIndex < 0
                      ? null
                      : () => shellController.toggleSaved(firebaseIndex),
                );
              },
            ),
    );
  }
}

class _DashboardStylePandalCard extends StatelessWidget {
  const _DashboardStylePandalCard({
    required this.pandal,
    required this.distanceText,
    required this.isFavorite,
    required this.onFavorite,
  });

  final PandalModel pandal;
  final String? distanceText;
  final bool isFavorite;
  final VoidCallback? onFavorite;

  @override
  Widget build(BuildContext context) {
    final imageUrl = pandal.thumbnailUrl.isNotEmpty
        ? pandal.thumbnailUrl
        : pandal.images.isNotEmpty
        ? pandal.images.first
        : '';

    final cardContent = Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Color(0x33000000),
                blurRadius: 16,
                spreadRadius: 1,
                offset: Offset(0, 8),
              ),
              BoxShadow(
                color: Color(0x18FFD889),
                blurRadius: 12,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Material(
              color: const Color(0xFF8C1115),
              child: InkWell(
                onTap: () => Get.toNamed('/pandal/${pandal.id}'),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 5,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, progress) {
                              if (progress == null) return child;
                              return const ColoredBox(
                                color: Color(0xFF5C2516),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    color: Color(0xFFFFD889),
                                    strokeWidth: 2.5,
                                  ),
                                ),
                              );
                            },
                            errorBuilder: (_, _, _) => const ColoredBox(
                              color: Color(0xFF5C2516),
                              child: Icon(
                                Icons.temple_hindu_rounded,
                                color: Color(0xFFFFD889),
                                size: 48,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 9,
                            right: 9,
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: onFavorite,
                                customBorder: const CircleBorder(),
                                child: Container(
                                  width: 34,
                                  height: 34,
                                  decoration: BoxDecoration(
                                    color: const Color(0xCC542111),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: const Color(0x66FFD889),
                                    ),
                                  ),
                                  child: Icon(
                                    isFavorite
                                        ? Icons.favorite_rounded
                                        : Icons.favorite_border_rounded,
                                    color: Colors.white,
                                    size: 22,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(12, 11, 12, 10),
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFFB31118), Color(0xFF8C1115)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              pandal.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14.5,
                                height: 1.08,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            if (distanceText != null) ...[
                              const SizedBox(height: 7),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.near_me_rounded,
                                    color: Color(0xFFFFD2C1),
                                    size: 14,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      distanceText!,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Color(0xFFFFD2C1),
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],

                            Row(
                              children: [
                                const Icon(
                                  Icons.star_rounded,
                                  color: Color(0xFFFFC34B),
                                  size: 15,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  pandal.averageRating.toStringAsFixed(1),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const Spacer(),
                                const Icon(
                                  Icons.arrow_forward_rounded,
                                  color: Color(0xFFFFD2C1),
                                  size: 17,
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_on_rounded,
                                  color: Color(0xFFFFD2C1),
                                  size: 14,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    pandal.area,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Color(0xFFFFD2C1),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

      if (pandal.isActive) {
        return cardContent;
      }

      return Stack(
        children: [
          Opacity(
            opacity: 0.42,
            child: cardContent,
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.75),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color(0xFFFF5252),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF5252).withOpacity(0.4),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: const Text(
                    'Inactive',
                    style: TextStyle(
                      color: Color(0xFFFF5252),
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
  }
}
