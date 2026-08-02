import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../controllers/pandal_controller.dart';
import '../widgets/pandal_media_slider.dart';

class PandalDetailScreen extends StatelessWidget {
  const PandalDetailScreen({super.key});

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

    return Scaffold(
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
                        const Icon(Icons.star, color: Colors.orange, size: 20),
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
                              border: Border.all(color: Colors.orange.shade200),
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
                          separatorBuilder: (_, _) => const SizedBox(width: 12),
                          itemBuilder: (context, index) {
                            final imageUrl = pandal.images[index];
                            return GestureDetector(
                              onTap: () => _showImagePreview(context, imageUrl),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: SizedBox(
                                  width: 210,
                                  child: Image.network(
                                    imageUrl,
                                    fit: BoxFit.cover,
                                    loadingBuilder: (context, child, progress) {
                                      if (progress == null) return child;
                                      return const ColoredBox(
                                        color: Color(0xFFFFE6BE),
                                        child: Center(
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.5,
                                          ),
                                        ),
                                      );
                                    },
                                    errorBuilder: (_, _, _) => const ColoredBox(
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
                          separatorBuilder: (_, _) => const SizedBox(width: 12),
                          itemBuilder: (context, index) {
                            final videoUrl = pandal.videos[index];
                            return GestureDetector(
                              onTap: () => _showVideoPreview(context, videoUrl),
                              child: Container(
                                width: 210,
                                decoration: BoxDecoration(
                                  color: Colors.black87,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.play_circle_fill_rounded,
                                    color: Colors.white,
                                    size: 62,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                    const SizedBox(height: 28),

                    // Address, Timings, Puja Time List
                    // _buildListTile(
                    //   icon: Icons.map_outlined,
                    //   title: 'Address',
                    //   subtitle: pandal.address,
                    // ),
                    // _buildDivider(),
                    // _buildListTile(
                    //   icon: Icons.schedule,
                    //   title: 'Timings',
                    //   subtitle:
                    //       '${pandal.openingTime.isEmpty ? 'Not specified' : pandal.openingTime} – ${pandal.closingTime.isEmpty ? 'Not specified' : pandal.closingTime}',
                    // ),
                    // _buildDivider(),
                    // _buildListTile(
                    //   icon: Icons.notifications_active_outlined,
                    //   title: 'Coordinates',
                    //   subtitle: '${pandal.latitude}, ${pandal.longitude}',
                    // ),

                    // Extra space at bottom for the fixed action bar
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
                      onTap: () {
                        debugPrint('BACK BUTTON CLICKED');

                        if (Navigator.of(context).canPop()) {
                          Navigator.of(context).pop();
                        } else {
                          Get.offAllNamed('/home');
                        }
                      },
                    ),

                    Row(
                      children: [
                        _buildTopActionButton(
                          icon: Icons.bookmark_border_rounded,
                          onTap: () {
                            debugPrint('BOOKMARK BUTTON CLICKED');
                          },
                        ),

                        const SizedBox(width: 8),

                        _buildTopActionButton(
                          icon: Icons.share_outlined,
                          onTap: () {
                            debugPrint('SHARE BUTTON CLICKED');
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomSheet: _buildBottomActionBar(),
    );
  }

  Future<void> _showImagePreview(BuildContext context, String imageUrl) async {
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
                  child: InteractiveViewer(
                    minScale: 1,
                    maxScale: 5,
                    boundaryMargin: const EdgeInsets.all(80),
                    child: Center(
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.contain,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
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
  Widget _buildBottomActionBar() {
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
                onPressed: () {},
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
                onPressed: () {},
                icon: const Icon(
                  Icons.bookmark_border,
                  color: Color(0xFF941212),
                  size: 18,
                ),
                label: const Text(
                  'Save',
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
            const SizedBox(width: 12),
            Expanded(
              flex: 4,
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(
                  Icons.share_outlined,
                  color: Color(0xFF941212),
                  size: 18,
                ),
                label: const Text(
                  'Share',
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
}
