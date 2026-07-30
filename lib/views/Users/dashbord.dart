import 'package:flutter/material.dart';

class DurgaPujaHomePage extends StatelessWidget {
  const DurgaPujaHomePage({super.key});

  // Colors used in the UI
  final Color primaryRed = const Color(0xFFA10E14);
  final Color goldColor = const Color(0xFFF3C76F);
  final Color darkText = const Color(0xFF2C2C2C);
  final Color subText = const Color(0xFF757575);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFDF5E8),
      body: Stack(
        children: [
          _buildHeader(context),

          Positioned(
            top: 160,
            right: 0,
            left: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Color(0xffFDF5E8),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),

              child: Column(
                children: [
                  _buildFeaturedPandals(),
                  const SizedBox(height: 24),

                  // Upcoming events
                  _buildUpcomingEvents(),

                  // SizedBox(height: MediaQuery.of(context).padding.bottom + 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 1. Header Section (Red Background with Search)
  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        left: 16,
        right: 16,
        // bottom: 18,
      ),
      decoration: BoxDecoration(color: primaryRed),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.menu_rounded, color: Colors.white, size: 26),

              Expanded(
                child: Text(
                  'Durga Puja Panel',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: goldColor,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'serif',
                  ),
                ),
              ),

              Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(
                    Icons.notifications_none_rounded,
                    color: Colors.white,
                    size: 26,
                  ),
                  Positioned(
                    top: 1,
                    right: 1,
                    child: Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: Colors.orange,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.location_on_rounded, color: primaryRed, size: 17),
                const SizedBox(width: 5),
                Text(
                  'Kolkata, West Bengal',
                  style: TextStyle(
                    color: darkText,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: primaryRed,
                  size: 18,
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          Container(
            height: 46,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  Icons.search_rounded,
                  color: Colors.grey.shade500,
                  size: 21,
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    'Search pandals, areas, events...',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                  ),
                ),
                Icon(Icons.tune_rounded, color: primaryRed, size: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 2. Top Categories Section
  Widget _buildTopCategories() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: _buildSectionHeader('Top Categories'),
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              _buildCategoryItem(Icons.account_balance, 'Top\nPandals', true),
              _buildCategoryItem(Icons.map_outlined, 'South\nKolkata', false),
              _buildCategoryItem(
                Icons.explore_outlined,
                'North\nKolkata',
                false,
              ),
              _buildCategoryItem(
                Icons.festival_outlined,
                'Cultural\nEvents',
                false,
              ),
              _buildCategoryItem(
                Icons.restaurant_outlined,
                'Food &\nFestivals',
                false,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryItem(IconData icon, String title, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Column(
        children: [
          Container(
            height: 70,
            width: 70,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: isSelected
                  ? Border.all(color: primaryRed.withOpacity(0.2), width: 2)
                  : null,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(child: Icon(icon, color: primaryRed, size: 32)),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: darkText,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  // 3. Featured Pandals Section
  Widget _buildFeaturedPandals() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: _buildSectionHeader('Featured Pandals'),
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              _buildPandalCard(
                'Sreebhumi Sporting Club',
                '4.8',
                'Lake Town',
                'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcToCqLazlZe5ggFCO3xTnQcBhX3i8Yt4FRCw5vMeXRdIQ&s=10',
              ),
              _buildPandalCard(
                'Santosh Mitra Square',
                '4.7',
                'Entally',
                'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcToCqLazlZe5ggFCO3xTnQcBhX3i8Yt4FRCw5vMeXRdIQ&s=10',
              ),
              _buildPandalCard(
                'Kumartuli Park',
                '4.6',
                'Kumartuli',
                'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcToCqLazlZe5ggFCO3xTnQcBhX3i8Yt4FRCw5vMeXRdIQ&s=10',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPandalCard(
    String name,
    String rating,
    String location,
    String imageUrl,
  ) {
    return Container(
      width: 150,
      height: 220,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Background Image
            Image.network(
              imageUrl,
              height: 220,
              width: 150,
              fit: BoxFit.fill,
              errorBuilder: (context, error, stackTrace) => Icon(Icons.error),
            ),
            // Gradient Overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    primaryRed.withOpacity(0.9),
                    primaryRed,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.4, 0.8, 1.0],
                ),
              ),
            ),
            // Bookmark Icon
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  Icons.bookmark_border,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
            // Details
            Positioned(
              bottom: 12,
              left: 12,
              right: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        rating,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        color: Colors.white70,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          location,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 4. Upcoming Events Section
  Widget _buildUpcomingEvents() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Upcoming Events'),
          const SizedBox(height: 16),
          _buildEventCard(
            '28',
            'Maha Saptami',
            'Puja & Pushpanjali',
            '7:00 AM Onwards',
          ),
          const SizedBox(height: 12),
          _buildEventCard(
            '29',
            'Maha Ashtami',
            'Anjali & Bhog',
            '7:00 AM Onwards',
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(
    String date,
    String title,
    String subtitle,
    String time,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Date Widget
          Container(
            width: 55,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: primaryRed.withOpacity(0.2)),
            ),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    color: primaryRed,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(9),
                      topRight: Radius.circular(9),
                    ),
                  ),
                  child: const Text(
                    'SEP',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Text(
                    date,
                    style: TextStyle(
                      color: primaryRed,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),

          // Details Widget
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: darkText,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(subtitle, style: TextStyle(color: subText, fontSize: 13)),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                ),
              ],
            ),
          ),

          // Bell Icon
          Icon(Icons.notifications_none, color: primaryRed, size: 26),
        ],
      ),
    );
  }

  // Reusable Section Header
  Widget _buildSectionHeader(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            color: darkText,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          'See All',
          style: TextStyle(
            color: primaryRed,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
