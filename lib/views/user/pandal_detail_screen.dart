import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/favorite_controller.dart';
import '../../controllers/location_controller.dart';
import '../../controllers/map_controller.dart';
import '../../controllers/pandal_controller.dart';
import '../../controllers/review_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/snackbar_helper.dart';
import '../../models/pandal_model.dart';
import '../../models/review_model.dart';
import '../widgets/crowd_level_chip.dart';
import '../widgets/custom_button.dart';
import '../widgets/empty_widget.dart';
import '../widgets/pandal_media_slider.dart';
import '../widgets/rating_widget.dart';

class PandalDetailScreen extends StatelessWidget {
  const PandalDetailScreen({super.key, required this.pandalId});

  final String pandalId;

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<PandalController>();
    final pandal = controller.getPandalById(pandalId);
    final location = context.watch<LocationController>().currentPosition;

    if (pandal == null) {
      return const Scaffold(
        body: EmptyWidget(
          title: 'Pandal not found',
          message: 'The selected pandal is not available.',
        ),
      );
    }

    final distance = location == null
        ? null
        : controller.calculateDistanceFromUser(pandal, location);

    return Scaffold(
      appBar: AppBar(title: Text(pandal.name)),
      body: ListView(
        children: [
          _HeroThumbnail(pandal: pandal),
          PandalMediaSlider(images: pandal.images, videos: pandal.videos),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        pandal.name,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ),
                    CrowdLevelChip(level: pandal.crowdLevel),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    RatingWidget(
                      rating: pandal.averageRating,
                      reviewCount: pandal.totalReviews,
                    ),
                    if (pandal.isFeatured) ...[
                      const SizedBox(width: 12),
                      const Icon(Icons.star, color: AppColors.gold, size: 18),
                      const SizedBox(width: 4),
                      const Text('Featured'),
                    ],
                  ],
                ),
                if (distance != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.near_me_outlined, size: 18),
                      const SizedBox(width: 6),
                      Text('${distance.toStringAsFixed(1)} km from you'),
                    ],
                  ),
                ],
                const SizedBox(height: 16),
                Text(
                  pandal.description,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 20),
                _InfoGrid(pandal: pandal),
                const SizedBox(height: 20),
                _ActionButtons(pandal: pandal),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroThumbnail extends StatelessWidget {
  const _HeroThumbnail({required this.pandal});

  final PandalModel pandal;

  @override
  Widget build(BuildContext context) {
    final imageUrl = pandal.thumbnailUrl.isNotEmpty
        ? pandal.thumbnailUrl
        : pandal.images.isEmpty
        ? null
        : pandal.images.first;

    return SizedBox(
      height: 230,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (imageUrl == null)
            const ColoredBox(
              color: Color(0xFFFFE6BE),
              child: Icon(Icons.temple_hindu, size: 64),
            )
          else
            CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              placeholder: (_, _) =>
                  const Center(child: CircularProgressIndicator()),
              errorWidget: (_, _, _) => const Icon(Icons.broken_image),
            ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black54],
              ),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: Text(
              '${pandal.area}, ${pandal.city}',
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoGrid extends StatelessWidget {
  const _InfoGrid({required this.pandal});

  final PandalModel pandal;

  @override
  Widget build(BuildContext context) {
    final entryFee = pandal.entryFee <= 0
        ? 'Free'
        : 'Rs ${pandal.entryFee.toStringAsFixed(0)}';
    final transport = pandal.nearbyTransport.isEmpty
        ? 'Not added'
        : pandal.nearbyTransport.join(', ');

    return Column(
      children: [
        _InfoTile(
          icon: Icons.location_on_outlined,
          label: 'Address',
          value: pandal.address,
        ),
        _InfoTile(
          icon: Icons.palette_outlined,
          label: 'Theme',
          value: pandal.themeName,
        ),
        _InfoTile(
          icon: Icons.groups_outlined,
          label: 'Organizer',
          value: pandal.organizerName,
        ),
        _InfoTile(
          icon: Icons.schedule,
          label: 'Timing',
          value: '${pandal.openingTime} - ${pandal.closingTime}',
        ),
        _InfoTile(
          icon: Icons.confirmation_number_outlined,
          label: 'Entry fee',
          value: entryFee,
        ),
        _InfoTile(
          icon: Icons.train_outlined,
          label: 'Nearby transport',
          value: transport,
        ),
        _InfoTile(
          icon: Icons.local_parking,
          label: 'Parking',
          value: pandal.parkingAvailable ? 'Available' : 'Not available',
        ),
      ],
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: AppColors.deepRed),
        title: Text(label),
        subtitle: Text(value.isEmpty ? 'Not added' : value),
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({required this.pandal});

  final PandalModel pandal;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () =>
                    context.read<MapController>().openInMaps(pandal),
                icon: const Icon(Icons.map_outlined),
                label: const Text('Open in Maps'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: CustomButton(
                label: 'Get Direction',
                icon: Icons.directions,
                onPressed: () =>
                    context.read<MapController>().openDirections(pandal),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: Consumer2<AuthController, FavoriteController>(
                builder: (context, auth, favorites, _) {
                  final isFavorite = favorites.isFavorite(pandal.id);
                  return OutlinedButton.icon(
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                    ),
                    label: Text(
                      isFavorite ? 'Remove Favorite' : 'Add Favorite',
                    ),
                    onPressed: auth.firebaseUser == null
                        ? null
                        : () => favorites.toggleFavorite(
                            uid: auth.firebaseUser!.uid,
                            pandalId: pandal.id,
                          ),
                  );
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _sharePandal(context),
                icon: const Icon(Icons.share_outlined),
                label: const Text('Share Pandal'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _showReviewDialog(context),
            icon: const Icon(Icons.rate_review_outlined),
            label: const Text('Write Review'),
          ),
        ),
      ],
    );
  }

  Future<void> _sharePandal(BuildContext context) async {
    final text =
        '${pandal.name}\n${pandal.area}, ${pandal.city}\nTheme: ${pandal.themeName}\nLocation: ${pandal.latitude}, ${pandal.longitude}';
    await Clipboard.setData(ClipboardData(text: text));
    if (context.mounted) {
      SnackbarHelper.showSuccess(context, 'Pandal details copied to share');
    }
  }

  Future<void> _showReviewDialog(BuildContext context) async {
    final auth = context.read<AuthController>();
    if (auth.firebaseUser == null) {
      SnackbarHelper.showError(context, 'Login to write a review');
      return;
    }

    final commentController = TextEditingController();
    var rating = 5.0;
    final submitted = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Write review'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Slider(
                    min: 1,
                    max: 5,
                    divisions: 8,
                    value: rating,
                    label: rating.toStringAsFixed(1),
                    onChanged: (value) => setDialogState(() => rating = value),
                  ),
                  TextField(
                    controller: commentController,
                    maxLines: 3,
                    decoration: const InputDecoration(labelText: 'Comment'),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  child: const Text('Submit'),
                ),
              ],
            );
          },
        );
      },
    );

    if (submitted != true || !context.mounted) {
      commentController.dispose();
      return;
    }

    final user = auth.currentUserModel;
    await context.read<ReviewController>().addReview(
      ReviewModel(
        id: '',
        pandalId: pandal.id,
        userId: auth.firebaseUser!.uid,
        userName: user?.name ?? 'Visitor',
        rating: rating,
        comment: commentController.text.trim(),
      ),
    );
    commentController.dispose();
    if (context.mounted) {
      SnackbarHelper.showSuccess(context, 'Review submitted');
    }
  }
}
