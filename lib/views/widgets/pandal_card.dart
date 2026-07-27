import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../models/pandal_model.dart';
import '../../routes/route_names.dart';
import 'crowd_level_chip.dart';
import 'rating_widget.dart';

class PandalCard extends StatefulWidget {
  const PandalCard({
    super.key,
    required this.pandal,
    this.distanceKm,
    this.compact = false,
    this.isPremium = false,
  });

  final PandalModel pandal;
  final double? distanceKm;
  final bool compact;
  final bool isPremium;

  @override
  State<PandalCard> createState() => _PandalCardState();
}

class _PandalCardState extends State<PandalCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fadeScale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeScale = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = widget.pandal.thumbnailUrl.isNotEmpty
        ? widget.pandal.thumbnailUrl
        : widget.pandal.images.isEmpty
        ? null
        : widget.pandal.images.first;

    return ScaleTransition(
      scale: _fadeScale,
      child: FadeTransition(
        opacity: _fadeScale,
        child: Card(
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => context.pushNamed(
              RouteNames.pandalDetail,
              pathParameters: {'id': widget.pandal.id},
            ),
            child: widget.compact
                ? _CompactContent(
                    pandal: widget.pandal,
                    imageUrl: imageUrl,
                    distanceKm: widget.distanceKm,
                    isPremium: widget.isPremium,
                  )
                : _FullContent(
                    pandal: widget.pandal,
                    imageUrl: imageUrl,
                    distanceKm: widget.distanceKm,
                    isPremium: widget.isPremium,
                  ),
          ),
        ),
      ),
    );
  }
}

class _FullContent extends StatelessWidget {
  const _FullContent({
    required this.pandal,
    required this.imageUrl,
    required this.distanceKm,
    this.isPremium = false,
  });

  final PandalModel pandal;
  final String? imageUrl;
  final double? distanceKm;
  final bool isPremium;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _PandalImage(
          imageUrl: imageUrl,
          isFeatured: pandal.isFeatured,
          isPremium: isPremium,
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: _PandalDetails(pandal: pandal, distanceKm: distanceKm),
        ),
      ],
    );
  }
}

class _CompactContent extends StatelessWidget {
  const _CompactContent({
    required this.pandal,
    required this.imageUrl,
    required this.distanceKm,
    this.isPremium = false,
  });

  final PandalModel pandal;
  final String? imageUrl;
  final double? distanceKm;
  final bool isPremium;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 260,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PandalImage(
            imageUrl: imageUrl,
            isFeatured: pandal.isFeatured,
            isPremium: isPremium,
            height: 118,
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: _PandalDetails(
              pandal: pandal,
              distanceKm: distanceKm,
              dense: true,
            ),
          ),
        ],
      ),
    );
  }
}

class _PandalImage extends StatelessWidget {
  const _PandalImage({
    required this.imageUrl,
    required this.isFeatured,
    this.isPremium = false,
    this.height = 150,
  });

  final String? imageUrl;
  final bool isFeatured;
  final bool isPremium;
  final double height;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      child: Stack(
        children: [
          SizedBox(
            height: height,
            width: double.infinity,
            child: imageUrl == null
                ? const ColoredBox(
                    color: Color(0xFFFFE6BE),
                    child: Icon(Icons.temple_hindu, size: 48),
                  )
                : CachedNetworkImage(
                    imageUrl: imageUrl!,
                    fit: BoxFit.cover,
                    placeholder: (_, _) =>
                        const Center(child: CircularProgressIndicator()),
                    errorWidget: (_, _, _) => const Icon(Icons.broken_image),
                  ),
          ),
          if (isPremium)
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.premiumGold, Color(0xFFFFB300)],
                  ),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.premiumGold.withValues(alpha: 0.4),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.diamond, size: 12, color: Colors.black87),
                    SizedBox(width: 4),
                    Text(
                      'Premium',
                      style: TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.w800,
                        fontSize: 10,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (isFeatured)
            Positioned(
              top: 10,
              left: 10,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.gold,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star, size: 14, color: AppColors.deepRed),
                      SizedBox(width: 4),
                      Text(
                        'Featured',
                        style: TextStyle(
                          color: AppColors.deepRed,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _PandalDetails extends StatelessWidget {
  const _PandalDetails({
    required this.pandal,
    required this.distanceKm,
    this.dense = false,
  });

  final PandalModel pandal;
  final double? distanceKm;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          pandal.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 4),
        Text(
          '${pandal.area}, ${pandal.city}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        SizedBox(height: dense ? 6 : 10),
        Row(
          children: [
            RatingWidget(
              rating: pandal.averageRating,
              reviewCount: dense ? null : pandal.totalReviews,
            ),
            const Spacer(),
            CrowdLevelChip(level: pandal.crowdLevel),
          ],
        ),
        if (distanceKm != null) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.near_me_outlined, size: 16),
              const SizedBox(width: 4),
              Text('${distanceKm!.toStringAsFixed(1)} km away'),
            ],
          ),
        ],
      ],
    );
  }
}
