import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
                      offset: const Offset(0, -2),
                      child: _buildMainContent(),
                    ),
                  ],
                ),
              ),
            ),

            // _buildBottomNavigation(),
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
      padding: const EdgeInsets.fromLTRB(11, 8, 11, 17),
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
                    'Durga Puja Panel',
                    style: TextStyle(
                      color: Color(0xFFFFD17B),
                      fontSize: 16,
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

          const SizedBox(height: 4),

          _buildLocationButton(),

          const SizedBox(height: 10),

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
        padding: const EdgeInsets.all(4),
        child: Icon(icon, color: Colors.white, size: 23),
      ),
    );
  }

  Widget _buildLocationButton() {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(30),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFAF2),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: const Color(0xFFE9D8C6), width: 0.7),
          boxShadow: const [
            BoxShadow(
              color: Color(0x25000000),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.location_on, color: primaryRed, size: 16),
            SizedBox(width: 4),
            Text(
              'Kolkata, West Bengal',
              style: TextStyle(
                color: Color(0xFF443C38),
                fontSize: 9,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(width: 3),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Color(0xFF574E49),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 43,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBF5),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: const Color(0xFFE4C6B4), width: 0.8),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        cursorColor: primaryRed,
        style: const TextStyle(color: Color(0xFF333333), fontSize: 11),
        decoration: InputDecoration(
          hintText: 'Search pandals, areas, events...',
          hintStyle: const TextStyle(color: Color(0xFF8D8580), fontSize: 9.5),
          prefixIconConstraints: const BoxConstraints(minWidth: 42),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: primaryRed,
            size: 20,
          ),
          suffixIconConstraints: const BoxConstraints(minWidth: 42),
          suffixIcon: IconButton(
            onPressed: () {},
            padding: EdgeInsets.zero,
            icon: const Icon(Icons.tune_rounded, color: primaryRed, size: 19),
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 13),
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
      padding: const EdgeInsets.fromLTRB(9, 10, 9, 18),
      decoration: const BoxDecoration(
        color: creamColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(15),
          topRight: Radius.circular(15),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 7,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(title: 'Top Categories', onSeeAll: () {}),

          const SizedBox(height: 8),

          _buildCategories(),

          const SizedBox(height: 14),

          _buildSectionHeader(title: 'Featured Pandals', onSeeAll: () {}),

          const SizedBox(height: 8),

          _buildFeaturedPandals(),

          const SizedBox(height: 14),

          _buildSectionHeader(title: 'Upcoming Events', onSeeAll: () {}),

          const SizedBox(height: 8),

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
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: Color(0xFF36302D),
              fontSize: 12.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        InkWell(
          onTap: onSeeAll,
          borderRadius: BorderRadius.circular(10),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 3, vertical: 2),
            child: Text(
              'See All',
              style: TextStyle(
                color: primaryRed,
                fontSize: 9,
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
      children: List.generate(categories.length, (index) {
        final category = categories[index];

        return Expanded(
          child: Container(
            height: 68,
            margin: EdgeInsets.only(
              right: index == categories.length - 1 ? 0 : 5,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFCF6),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFF0DFCD), width: 0.7),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x10000000),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: InkWell(
              onTap: () {},
              borderRadius: BorderRadius.circular(10),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 5),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      category['icon'] as IconData,
                      color: const Color(0xFFC46A45),
                      size: 23,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      category['title'] as String,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      style: const TextStyle(
                        color: Color(0xFF514843),
                        fontSize: 7.5,
                        height: 1.05,
                        fontWeight: FontWeight.w600,
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

  Widget _buildFeaturedPandals() {
    return Row(
      children: List.generate(featuredPandals.length, (index) {
        final pandal = featuredPandals[index];

        return Expanded(
          child: Container(
            height: 158,
            margin: EdgeInsets.only(
              right: index == featuredPandals.length - 1 ? 0 : 7,
            ),
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: darkRed,
              borderRadius: BorderRadius.circular(10),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x30000000),
                  blurRadius: 5,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: InkWell(
              onTap: () {
                context.push('/Pandel_details', extra: pandal);
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 6,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.asset(
                          pandal['image']!,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (
                                BuildContext context,
                                Object error,
                                StackTrace? stackTrace,
                              ) {
                                return Container(
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Color(0xFFC06F39),
                                        Color(0xFF5C2516),
                                      ],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.temple_hindu,
                                    color: Color(0xFFFFD889),
                                    size: 42,
                                  ),
                                );
                              },
                        ),

                        const DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.transparent, Color(0x55000000)],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),

                        Positioned(
                          top: 5,
                          right: 5,
                          child: Container(
                            width: 21,
                            height: 21,
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.28),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.bookmark_border_rounded,
                              color: Colors.white,
                              size: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    flex: 5,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(6, 5, 5, 5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            pandal['title']!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 8.5,
                              height: 1.05,
                              fontWeight: FontWeight.w700,
                            ),
                          ),

                          const Spacer(),

                          Row(
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                color: Color(0xFFFFC34B),
                                size: 10,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                pandal['rating']!,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 7.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 2),

                          Row(
                            children: [
                              const Icon(
                                Icons.location_on,
                                color: Color(0xFFFFD2C1),
                                size: 9,
                              ),
                              const SizedBox(width: 2),
                              Expanded(
                                child: Text(
                                  pandal['location']!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Color(0xFFFFD2C1),
                                    fontSize: 7,
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
        );
      }),
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
          height: 63,
          margin: EdgeInsets.only(
            bottom: index == upcomingEvents.length - 1 ? 0 : 7,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFCF6),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFF0DFCC), width: 0.7),
            boxShadow: const [
              BoxShadow(
                color: Color(0x10000000),
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              _buildEventDate(month: event['month']!, date: event['date']!),

              const SizedBox(width: 9),

              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event['title']!,
                      style: const TextStyle(
                        color: Color(0xFF3B3531),
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      event['subtitle']!,
                      style: const TextStyle(
                        color: Color(0xFF746B66),
                        fontSize: 8,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      event['time']!,
                      style: const TextStyle(
                        color: Color(0xFF746B66),
                        fontSize: 8,
                      ),
                    ),
                  ],
                ),
              ),

              IconButton(
                onPressed: () {},
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
                icon: const Icon(
                  Icons.notifications_none_rounded,
                  color: primaryRed,
                  size: 19,
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
      width: 39,
      height: 49,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: const Color(0xFFE5D3BF), width: 0.8),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: 17,
            alignment: Alignment.center,
            color: primaryRed,
            child: Text(
              month,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 7,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),

          Expanded(
            child: Center(
              child: Text(
                date,
                style: const TextStyle(
                  color: primaryRed,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // BOTTOM NAVIGATION
  // =========================================================
}
