import 'package:flutter/material.dart';

class DurgaPujaHomeScreen extends StatefulWidget {
  const DurgaPujaHomeScreen({super.key});

  @override
  State<DurgaPujaHomeScreen> createState() => _DurgaPujaHomeScreenState();
}

class _DurgaPujaHomeScreenState extends State<DurgaPujaHomeScreen> {
  static const Color primaryRed = Color(0xFFB91419);
  static const Color darkRed = Color(0xFF8C1115);
  static const Color creamColor = Color(0xFFFFF8E9);

  final List<Map<String, dynamic>> categories = [
    {'icon': Icons.temple_hindu_outlined, 'title': 'Top\nPandals'},
    {'icon': Icons.account_balance_outlined, 'title': 'South\nKolkata'},
    {'icon': Icons.account_balance_outlined, 'title': 'North\nKolkata'},
    {'icon': Icons.celebration_outlined, 'title': 'Cultural\nEvents'},
    {'icon': Icons.restaurant_outlined, 'title': 'Food &\nFestivals'},
  ];

  // ৪টি প্যান্ডেল দেখানোর জন্য আরও একটি যোগ করা হয়েছে
  final List<Map<String, String>> featuredPandals = [
    {
      'title': 'Sreebhumi\nSporting Club',
      'rating': '4.8',
      'location': 'Lake Town',
      'image': 'assets/images/pandal_1.jpg',
    },
    {
      'title': 'Santosh Mitra\nSquare',
      'rating': '4.7',
      'location': 'Entally',
      'image': 'assets/images/pandal_2.jpg',
    },
    {
      'title': 'Kumartuli\nPark',
      'rating': '4.6',
      'location': 'Kumartuli',
      'image': 'assets/images/pandal_3.jpg',
    },
    {
      'title': 'Bosepukur\nSitala Mandir',
      'rating': '4.5',
      'location': 'Kasba',
      'image': 'assets/images/pandal_4.jpg',
    },
  ];

  final List<Map<String, String>> upcomingEvents = [
    {
      'month': 'SEP',
      'date': '28',
      'title': 'Maha Saptami',
      'subtitle': 'Puja & Pushpanjali',
      'time': '7:00 AM Onwards',
    },
    {
      'month': 'SEP',
      'date': '29',
      'title': 'Maha Ashtami',
      'subtitle': 'Anjali & Bhog',
      'time': '7:00 AM Onwards',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: creamColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    _buildHeader(),
                    Transform.translate(
                      offset: const Offset(
                        0,
                        -15,
                      ), // একটু উপরে তুলে প্রিমিয়াম লুক দেওয়া হয়েছে
                      child: _buildMainContent(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // HEADER
  // =========================================================

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        16,
        12,
        16,
        35,
      ), // প্যাডিং বাড়ানো হয়েছে
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFD71319), Color(0xFFAA080D)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _buildHeaderIcon(icon: Icons.menu_rounded, onTap: () {}),
              const Expanded(
                child: Center(
                  child: Text(
                    'Durga Puja Pandal',
                    style: TextStyle(
                      color: Color(0xFFFFD17B),
                      fontSize: 20, // ফন্ট সাইজ বাড়ানো হয়েছে
                      fontWeight: FontWeight.w700,
                      fontFamily: 'serif',
                    ),
                  ),
                ),
              ),
              _buildHeaderIcon(
                icon: Icons.notifications_none_rounded,
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildLocationButton(),
          const SizedBox(height: 16),
          _buildSearchBar(),
        ],
      ),
    );
  }

  Widget _buildHeaderIcon({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Icon(
          icon,
          color: Colors.white,
          size: 28,
        ), // আইকন সাইজ বড় করা হয়েছে
      ),
    );
  }

  Widget _buildLocationButton() {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(30),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFAF2),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: const Color(0xFFE9D8C6), width: 0.7),
          boxShadow: const [
            BoxShadow(
              color: Color(0x25000000),
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.location_on, color: primaryRed, size: 20),
            SizedBox(width: 6),
            Text(
              'Kolkata, West Bengal',
              style: TextStyle(
                color: Color(0xFF443C38),
                fontSize: 13, // সাইজ স্ট্যান্ডার্ড করা হয়েছে
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Color(0xFF574E49),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
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
        cursorColor: primaryRed,
        style: const TextStyle(color: Color(0xFF333333), fontSize: 15),
        decoration: InputDecoration(
          hintText: 'Search pandals, areas, events...',
          hintStyle: const TextStyle(color: Color(0xFF8D8580), fontSize: 14),
          prefixIconConstraints: const BoxConstraints(minWidth: 50),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: primaryRed,
            size: 24, // আইকন বড় করা হয়েছে
          ),
          suffixIconConstraints: const BoxConstraints(minWidth: 50),
          suffixIcon: IconButton(
            onPressed: () {},
            padding: EdgeInsets.zero,
            icon: const Icon(Icons.tune_rounded, color: primaryRed, size: 22),
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  // =========================================================
  // CREAM MAIN CONTENT
  // =========================================================

  Widget _buildMainContent() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        16,
        20,
        16,
        24,
      ), // প্যাডিং স্ট্যান্ডার্ড করা হয়েছে
      decoration: const BoxDecoration(
        color: creamColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x15000000),
            blurRadius: 10,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(title: 'Top Categories', onSeeAll: () {}),
          const SizedBox(height: 12),
          _buildCategories(),

          const SizedBox(height: 24),

          _buildSectionHeader(title: 'Featured Pandals', onSeeAll: () {}),
          const SizedBox(height: 12),
          _buildFeaturedPandalsGrid(), // গ্রিড ভিউ মেথড কল করা হয়েছে

          const SizedBox(height: 24),

          _buildSectionHeader(title: 'Upcoming Events', onSeeAll: () {}),
          const SizedBox(height: 12),
          _buildUpcomingEvents(),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required VoidCallback onSeeAll,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF36302D),
            fontSize: 18, // ফন্ট সাইজ বড় করা হয়েছে
            fontWeight: FontWeight.w800,
          ),
        ),
        InkWell(
          onTap: onSeeAll,
          borderRadius: BorderRadius.circular(10),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Text(
              'See All',
              style: TextStyle(
                color: primaryRed,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // =========================================================
  // CATEGORIES
  // =========================================================

  Widget _buildCategories() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(categories.length, (index) {
        final category = categories[index];

        return Expanded(
          child: Container(
            height: 95,
            margin: EdgeInsets.only(
              right: index == categories.length - 1 ? 0 : 8,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFCF6),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFF0DFCD), width: 1),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0C000000),
                  blurRadius: 6,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: InkWell(
              onTap: () {},
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      category['icon'] as IconData,
                      color: const Color(0xFFC46A45),
                      size: 32,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      category['title'] as String,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      style: const TextStyle(
                        color: Color(0xFF514843),
                        fontSize: 10.5,
                        height: 1.2,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  // =========================================================
  // FEATURED PANDALS
  // =========================================================

  Widget _buildFeaturedPandalsGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.75,
      ),
      itemCount: featuredPandals.length,
      itemBuilder: (context, index) {
        final pandal = featuredPandals[index];

        return Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: darkRed,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Color(0x25000000),
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: InkWell(
            onTap: () {},
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 5,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(
                        pandal['image']!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xFFC06F39), Color(0xFF5C2516)],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                            child: const Icon(
                              Icons.temple_hindu,
                              color: Color(0xFFFFD889),
                              size: 45,
                            ),
                          );
                        },
                      ),
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.transparent, Color(0x66000000)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.35),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.bookmark_border_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(10), // প্যাডিং বড় করা হয়েছে
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          pandal['title']!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14, // ফন্ট সাইজ বড়
                            height: 1.1,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              color: Color(0xFFFFC34B),
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              pandal['rating']!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              color: Color(0xFFFFD2C1),
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                pandal['location']!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Color(0xFFFFD2C1),
                                  fontSize: 11,
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
        );
      },
    );
  }

  // =========================================================
  // UPCOMING EVENTS
  // =========================================================

  Widget _buildUpcomingEvents() {
    return Column(
      children: List.generate(upcomingEvents.length, (index) {
        final event = upcomingEvents[index];

        return Container(
          margin: EdgeInsets.only(
            bottom: index == upcomingEvents.length - 1 ? 0 : 12,
          ),
          padding: const EdgeInsets.all(
            12,
          ), // ফিক্সড হাইট সরিয়ে প্যাডিং দেওয়া হয়েছে
          decoration: BoxDecoration(
            color: const Color(0xFFFFFCF6),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFF0DFCC), width: 1),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0C000000),
                blurRadius: 8,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildEventDate(month: event['month']!, date: event['date']!),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event['title']!,
                      style: const TextStyle(
                        color: Color(0xFF3B3531),
                        fontSize: 16, // সাইজ স্ট্যান্ডার্ড
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      event['subtitle']!,
                      style: const TextStyle(
                        color: Color(0xFF746B66),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time_rounded,
                          size: 14,
                          color: primaryRed,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          event['time']!,
                          style: const TextStyle(
                            color: Color(0xFF746B66),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.notifications_none_rounded,
                  color: primaryRed,
                  size: 26,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildEventDate({required String month, required String date}) {
    return Container(
      width: 55, // সাইজ স্ট্যান্ডার্ড করা হয়েছে
      height: 65,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5D3BF), width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 4),
            alignment: Alignment.center,
            color: primaryRed,
            child: Text(
              month,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                date,
                style: const TextStyle(
                  color: primaryRed,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
