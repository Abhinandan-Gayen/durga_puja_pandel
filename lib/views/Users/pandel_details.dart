import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../controllers/pandal_controller.dart';
import 'bottom-navigationBar/controller/botom_navigation_controller.dart';
import 'favourite_route_map_screen.dart';
import '../widgets/pandel.dart';
import '../widgets/pandal_media_slider.dart';
import '../widgets/shimmer.dart';

class PandalDetailScreen extends StatefulWidget {
  const PandalDetailScreen({super.key});

  @override
  State<PandalDetailScreen> createState() => _PandalDetailScreenState();
}

class _PandalDetailScreenState extends State<PandalDetailScreen> {
  bool _hasRated = false;
  bool _checkingRating = true;
  bool _shouldAllowPop = false;
  String _userId = '';

  @override
  void initState() {
    super.initState();
    _checkUserRatingStatus();
  }

  Future<String> _getOrGenerateUserId() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      return currentUser.uid;
    }
    final prefs = await SharedPreferences.getInstance();
    String? visitorId = prefs.getString('visitor_id');
    if (visitorId == null) {
      visitorId = 'visitor_${DateTime.now().microsecondsSinceEpoch}';
      await prefs.setString('visitor_id', visitorId);
    }
    return visitorId;
  }

  Future<void> _checkUserRatingStatus() async {
    final pandalId = Get.parameters['id'] ?? '';
    if (pandalId.isEmpty) return;

    try {
      final userId = await _getOrGenerateUserId();
      if (mounted) {
        setState(() => _userId = userId);
      }

      final prefs = await SharedPreferences.getInstance();
      final localRated = prefs.getBool('rated_$pandalId') ?? false;
      if (localRated) {
        if (mounted) {
          setState(() {
            _hasRated = true;
            _checkingRating = false;
          });
        }
        return;
      }

      final doc = await FirebaseFirestore.instance
          .collection('pandals')
          .doc(pandalId)
          .collection('ratings')
          .doc(userId)
          .get();

      if (doc.exists) {
        await prefs.setBool('rated_$pandalId', true);
        if (mounted) {
          setState(() {
            _hasRated = true;
          });
        }
      }
    } catch (e) {
      debugPrint('Error checking rating status: $e');
    } finally {
      if (mounted) {
        setState(() {
          _checkingRating = false;
        });
      }
    }
  }

  Future<bool> _submitRating(String pandalId, double ratingValue) async {
    try {
      final userId = _userId.isNotEmpty
          ? _userId
          : await _getOrGenerateUserId();
      final pandalRef = FirebaseFirestore.instance
          .collection('pandals')
          .doc(pandalId);
      final ratingRef = pandalRef.collection('ratings').doc(userId);

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final pandalSnapshot = await transaction.get(pandalRef);
        if (!pandalSnapshot.exists) return;

        final data = pandalSnapshot.data()!;
        final double currentTotalRating =
            (data['totalRating'] as num?)?.toDouble() ?? 0.0;
        final int currentTotalReviews =
            (data['totalReviews'] as num?)?.toInt() ?? 0;

        final double newTotalRating = currentTotalRating + ratingValue;
        final int newTotalReviews = currentTotalReviews + 1;
        final double newAverageRating = newTotalRating / newTotalReviews;

        transaction.set(ratingRef, {
          'userId': userId,
          'rating': ratingValue,
          'createdAt': FieldValue.serverTimestamp(),
        });

        transaction.update(pandalRef, {
          'totalRating': newTotalRating,
          'totalReviews': newTotalReviews,
          'averageRating': newAverageRating,
        });
      });

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('rated_$pandalId', true);

      if (mounted) {
        setState(() {
          _hasRated = true;
        });
      }

      Get.snackbar(
        'Thank You!',
        'Your rating has been submitted successfully.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF2E7D32),
        colorText: Colors.white,
      );
      return true;
    } catch (e) {
      debugPrint('Error submitting rating: $e');
      Get.snackbar(
        'Error',
        'Could not submit rating. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFC62828),
        colorText: Colors.white,
      );
      return false;
    }
  }

  Future<void> _showRatingDialog(BuildContext context, String pandalId) async {
    double selectedRating = 0;
    bool isSubmitting = false;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              backgroundColor: const Color(0xFFFFFBF2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: Color(0xFFFFD889), width: 1.5),
              ),
              title: const Center(
                child: Text(
                  'Rate this Pandal',
                  style: TextStyle(
                    color: Color(0xFF8C1115),
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Serif',
                  ),
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'How was your experience visiting this pandal?',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFF542111), fontSize: 14),
                  ),
                  const SizedBox(height: 20),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        final starValue = index + 1.0;
                        return GestureDetector(
                          onTap: isSubmitting
                              ? null
                              : () {
                                  setStateDialog(() {
                                    selectedRating = starValue;
                                  });
                                },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Icon(
                              selectedRating >= starValue
                                  ? Icons.star_rounded
                                  : Icons.star_border_rounded,
                              color: const Color(0xFFFFC34B),
                              size: 36,
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
              actionsAlignment: MainAxisAlignment.spaceBetween,
              actions: [
                TextButton(
                  onPressed: isSubmitting
                      ? null
                      : () {
                          Navigator.of(dialogContext).pop();
                        },
                  child: const Text(
                    'Maybe Later',
                    style: TextStyle(color: Color(0xFF8D8580)),
                  ),
                ),
                ElevatedButton(
                  onPressed: selectedRating == 0 || isSubmitting
                      ? null
                      : () async {
                          setStateDialog(() {
                            isSubmitting = true;
                          });
                          final success = await _submitRating(pandalId, selectedRating);
                          if (success) {
                            if (dialogContext.mounted) {
                              Navigator.of(dialogContext).pop();
                            }
                          } else {
                            setStateDialog(() {
                              isSubmitting = false;
                            });
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8C1115),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey.shade300,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('Submit'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _handleExit(String pandalId) async {
    if (_hasRated || _checkingRating) {
      setState(() => _shouldAllowPop = true);
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      } else {
        Get.offAllNamed('/home');
      }
      return;
    }

    await _showRatingDialog(context, pandalId);

    if (!mounted) return;
    setState(() => _shouldAllowPop = true);
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      Get.offAllNamed('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final pandalId = Get.parameters['id'] ?? '';
    final controller = context.watch<PandalController>();
    final pandal = controller.getPandalById(pandalId);
    if (pandal == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: controller.isLoading
              ? const CircularProgressIndicator()
              : const Text('Pandal not found'),
        ),
      );
    }
    final heroImages = <String>[
      if (pandal.thumbnailUrl.isNotEmpty) pandal.thumbnailUrl,
    ];
    final shellController = context.watch<AppShellController>();
    final pandalIndex = controller.pandals.indexWhere(
      (item) => item.id == pandal.id,
    );
    final isFavorite =
        pandalIndex >= 0 && shellController.saved.contains(pandalIndex);
    void toggleFavorite() {
      if (pandalIndex >= 0) shellController.toggleSaved(pandalIndex);
    }

    return PopScope(
      canPop: _shouldAllowPop,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await _handleExit(pandalId);
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFFAF6F0),
        body: Stack(
          children: [
            // Top Image Background Placeholder
            SizedBox(
              height: 350,
              width: double.infinity,
              child: PandalMediaSlider(
                images: heroImages,
                videos: const [],
                height: 350,
              ),
            ),

            // Top Action Buttons (Back, Bookmark, Share)

            // Scrollable Content
            SingleChildScrollView(
              child: Container(
                margin: const EdgeInsets.only(top: 280), // Overlaps the image
                decoration: const BoxDecoration(
                  color: Color(0xFFFAF6F0),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        pandal.name,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Serif',
                          color: Color(0xFF222222),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Ratings and Badge
                      Row(
                        children: [
                          const Icon(
                            Icons.star,
                            color: Colors.orange,
                            size: 20,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            pandal.averageRating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF333333),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '(${pandal.totalReviews} Ratings)',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(width: 16),
                          if (pandal.isFeatured)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.orange.shade200,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.emoji_events,
                                    color: Colors.orange.shade700,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Top Rated',
                                    style: TextStyle(
                                      color: Colors.orange.shade700,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Location
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            color: Colors.brown.shade400,
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              '${pandal.area} • ${pandal.address}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      const Text(
                        'About',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        pandal.description,
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                      if (pandal.images.isNotEmpty) ...[
                        const SizedBox(height: 28),
                        const Text(
                          'Photos',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF333333),
                          ),
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          height: 145,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: pandal.images.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(width: 12),
                            itemBuilder: (context, index) {
                              final imageUrl = pandal.images[index];
                              return GestureDetector(
                                onTap: () => _showImagePreview(
                                  context,
                                  index,
                                  pandal.images,
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: SizedBox(
                                    width: 210,
                                    child: Image.network(
                                      imageUrl,
                                      fit: BoxFit.cover,
                                      loadingBuilder:
                                          (context, child, progress) {
                                            if (progress == null) return child;
                                            return const ShimmerPlaceholder(
                                              width: double.infinity,
                                              height: double.infinity,
                                              borderRadius: 0,
                                            );
                                          },
                                      errorBuilder: (_, _, _) =>
                                          const ColoredBox(
                                            color: Color(0xFFFFE6BE),
                                            child: Icon(
                                              Icons.broken_image_outlined,
                                              size: 38,
                                            ),
                                          ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                      if (pandal.videos.isNotEmpty) ...[
                        const SizedBox(height: 28),
                        const Text(
                          'Videos',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF333333),
                          ),
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          height: 130,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: pandal.videos.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(width: 12),
                            itemBuilder: (context, index) {
                              final videoUrl = pandal.videos[index];
                              return GestureDetector(
                                onTap: () =>
                                    _showVideoPreview(context, videoUrl),
                                child: Container(
                                  width: 210,
                                  decoration: BoxDecoration(
                                    color: Colors.black87,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  clipBehavior: Clip.antiAlias,
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      IgnorePointer(
                                        child: PandalVideoPlayer(
                                          url: videoUrl,
                                          autoPlay: false,
                                          fit: BoxFit.cover,
                                          controlsEnabled: false,
                                        ),
                                      ),
                                      const ColoredBox(color: Colors.black26),
                                      const Center(
                                        child: Icon(
                                          Icons.play_circle_fill_rounded,
                                          color: Colors.white,
                                          size: 62,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                      const SizedBox(height: 28),
                      _buildRatingsList(pandalId),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildTopActionButton(
                        icon: Icons.arrow_back_rounded,
                        onTap: () => _handleExit(pandalId),
                      ),

                      _buildTopActionButton(
                        icon: isFavorite
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        onTap: toggleFavorite,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        bottomSheet: _buildBottomActionBar(
          onNavigate: () {
            final imageUrl = pandal.thumbnailUrl.isNotEmpty
                ? pandal.thumbnailUrl
                : pandal.images.isNotEmpty
                ? pandal.images.first
                : '';
            final navigationPandal = Pandal(
              pandal.name,
              pandal.name,
              pandal.area,
              '',
              pandal.averageRating.toStringAsFixed(1),
              pandal.crowdLevel,
              pandal.themeName,
              imageUrl,
              pandal.latitude,
              pandal.longitude,
            );
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) =>
                    FavouriteRouteMapScreen(pandal: navigationPandal),
              ),
            );
          },
          onFavorite: toggleFavorite,
          isFavorite: isFavorite,
        ),
      ),
    );
  }

  Future<void> _showImagePreview(
    BuildContext context,
    int initialIndex,
    List<String> imageUrls,
  ) async {
    await showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.92),
      builder: (dialogContext) {
        return _ImagePreviewDialog(
          imageUrls: imageUrls,
          initialIndex: initialIndex,
        );
      },
    );
  }

  Future<void> _showVideoPreview(BuildContext context, String videoUrl) async {
    await showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.92),
      builder: (dialogContext) {
        return Dialog.fullscreen(
          backgroundColor: Colors.black,
          child: SafeArea(
            child: Stack(
              children: [
                Positioned.fill(
                  child: PandalVideoPlayer(
                    url: videoUrl,
                    autoPlay: true,
                    fit: BoxFit.contain,
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Material(
                    color: Colors.black54,
                    shape: const CircleBorder(),
                    child: IconButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Helper for the top info cards
  Widget _buildInfoCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    Color? subtitleColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: iconColor, size: 14),
              const SizedBox(width: 4),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF444444),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: subtitleColor ?? Colors.grey.shade700,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Helper for the Highlights horizontal list
  Widget _buildHighlightsList() {
    final highlights = [
      {'icon': Icons.temple_hindu_outlined, 'label': 'Grand\nTheme'},
      {'icon': Icons.theater_comedy_outlined, 'label': 'Cultural\nShows'},
      {'icon': Icons.lightbulb_outline, 'label': 'Lighting &\nSound'},
      {'icon': Icons.storefront_outlined, 'label': 'Food Court'},
      {'icon': Icons.palette_outlined, 'label': 'Handicrafts'},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: highlights.map((highlight) {
          return Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Column(
              children: [
                Container(
                  height: 60,
                  width: 60,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.orange.shade100),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withValues(alpha: 0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    highlight['icon'] as IconData,
                    color: const Color(0xFF941212),
                    size: 26,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  highlight['label'] as String,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF555555),
                    height: 1.2,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // Helper for Address, Timings, etc.
  Widget _buildListTile({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Icon(icon, color: const Color(0xFF941212), size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: Colors.grey.shade400),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      color: Colors.grey.shade200,
      thickness: 1,
      height: 1,
      indent: 52, // Aligns with the text, skipping the icon
    );
  }

  // The fixed bottom action bar
  Widget _buildBottomActionBar({
    required VoidCallback onNavigate,
    required VoidCallback onFavorite,
    required bool isFavorite,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF6F0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              flex: 5,
              child: ElevatedButton.icon(
                onPressed: onNavigate,
                icon: const Icon(Icons.near_me, color: Colors.white, size: 18),
                label: const Text(
                  'Navigate',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF941212),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 4,
              child: OutlinedButton.icon(
                onPressed: onFavorite,
                icon: Icon(
                  isFavorite
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  color: Color(0xFF941212),
                  size: 18,
                ),
                label: Text(
                  isFavorite ? 'Saved' : 'Save',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF941212),
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF941212), width: 1.2),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopActionButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.black.withValues(alpha: 0.35),
      shape: const CircleBorder(),
      elevation: 1,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(icon, color: Colors.white, size: 22),
        ),
      ),
    );
  }

  Widget _buildRatingsList(String pandalId) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('pandals')
          .doc(pandalId)
          .collection('ratings')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'User Ratings',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
              SizedBox(height: 12),
              Text(
                'No ratings yet. Be the first to rate!',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ],
          );
        }

        final docs = snapshot.data!.docs;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'User Ratings',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
            ),
            // const SizedBox(height: 14),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: docs.length,
              separatorBuilder: (_, _) =>
                  const Divider(height: 20, color: Color(0xFFE5D5C5)),
              itemBuilder: (context, index) {
                final data = docs[index].data();
                final String userId = data['userId'] as String? ?? 'Anonymous';
                final double ratingVal =
                    (data['rating'] as num?)?.toDouble() ?? 0.0;
                final Timestamp? ts = data['createdAt'] as Timestamp?;
                final DateTime? dt = ts?.toDate();
                final String dateStr = dt != null
                    ? DateFormat('dd MMM yyyy').format(dt)
                    : 'Recent';

                final String displayId = userId.startsWith('visitor_')
                    ? 'Visitor (${userId.substring(userId.length - 6)})'
                    : userId.length > 10
                    ? 'User (${userId.substring(userId.length - 6)})'
                    : userId;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          displayId,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Color(0xFF542111),
                          ),
                        ),
                        Text(
                          dateStr,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: List.generate(5, (starIndex) {
                        return Icon(
                          starIndex < ratingVal
                              ? Icons.star_rounded
                              : Icons.star_border_rounded,
                          color: const Color(0xFFFFC34B),
                          size: 20,
                        );
                      }),
                    ),
                  ],
                );
              },
            ),
          ],
        );
      },
    );
  }
}

// -------------------------------------------------------------
// Image Preview Dialog with PageView and Interactive Zoom Panning
// -------------------------------------------------------------
class _ImagePreviewDialog extends StatefulWidget {
  final List<String> imageUrls;
  final int initialIndex;

  const _ImagePreviewDialog({
    required this.imageUrls,
    required this.initialIndex,
  });

  @override
  State<_ImagePreviewDialog> createState() => _ImagePreviewDialogState();
}

class _ImagePreviewDialogState extends State<_ImagePreviewDialog> {
  late final PageController _pageController;
  late int _currentPage;
  bool _canScroll = true;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      backgroundColor: Colors.black,
      child: SafeArea(
        child: Stack(
          children: [
            // PageView of images
            Positioned.fill(
              child: PageView.builder(
                controller: _pageController,
                itemCount: widget.imageUrls.length,
                onPageChanged: (page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                physics: _canScroll
                    ? const BouncingScrollPhysics()
                    : const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return _GestureZoomImage(
                    imageUrl: widget.imageUrls[index],
                    onZoomChanged: (zoomed) {
                      setState(() {
                        _canScroll = !zoomed;
                      });
                    },
                  );
                },
              ),
            ),
            // Close Button
            Positioned(
              top: 10,
              right: 10,
              child: Material(
                color: Colors.black54,
                shape: const CircleBorder(),
                child: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, color: Colors.white),
                ),
              ),
            ),
            // Page Indicator text at the bottom
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '${_currentPage + 1} of ${widget.imageUrls.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GestureZoomImage extends StatefulWidget {
  final String imageUrl;
  final ValueChanged<bool> onZoomChanged;

  const _GestureZoomImage({
    required this.imageUrl,
    required this.onZoomChanged,
  });

  @override
  State<_GestureZoomImage> createState() => _GestureZoomImageState();
}

class _GestureZoomImageState extends State<_GestureZoomImage> {
  final TransformationController _transformationController =
      TransformationController();
  TapDownDetails? _doubleTapDetails;

  void _handleDoubleTap() {
    if (_transformationController.value != Matrix4.identity()) {
      _transformationController.value = Matrix4.identity();
      widget.onZoomChanged(false);
    } else {
      final position = _doubleTapDetails!.localPosition;
      final Matrix4 matrix = Matrix4.identity();
      matrix.setEntry(0, 3, -position.dx * 1.5);
      matrix.setEntry(1, 3, -position.dy * 1.5);
      matrix.multiply(Matrix4.diagonal3Values(2.5, 2.5, 1.0));
      _transformationController.value = matrix;
      widget.onZoomChanged(true);
    }
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTapDown: (details) => _doubleTapDetails = details,
      onDoubleTap: _handleDoubleTap,
      child: InteractiveViewer(
        transformationController: _transformationController,
        minScale: 1.0,
        maxScale: 4.0,
        boundaryMargin: const EdgeInsets.all(20),
        onInteractionEnd: (details) {
          final scale = _transformationController.value.getMaxScaleOnAxis();
          widget.onZoomChanged(scale > 1.05);
        },
        child: Center(
          child: Image.network(
            widget.imageUrl,
            fit: BoxFit.contain,
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;
              return const Center(
                child: CircularProgressIndicator(color: Colors.white),
              );
            },
            errorBuilder: (_, _, _) => const Icon(
              Icons.broken_image_outlined,
              color: Colors.white70,
              size: 64,
            ),
          ),
        ),
      ),
    );
  }
}
