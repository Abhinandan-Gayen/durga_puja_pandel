import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../controllers/pandal_controller.dart';
import '../../core/services/location_service.dart';
import '../../models/pandal_model.dart';
import 'bottom-navigationBar/controller/botom_navigation_controller.dart';
import 'location_pandals_screen.dart';

class DurgaPujaHomeScreen extends StatefulWidget {
  const DurgaPujaHomeScreen({super.key, required this.onMenuTap});

  final VoidCallback onMenuTap;

  @override
  State<DurgaPujaHomeScreen> createState() => _DurgaPujaHomeScreenState();
}

class _DurgaPujaHomeScreenState extends State<DurgaPujaHomeScreen> {
  static const Color primaryRed = Color(0xFFE50914);
  static const Color darkRed = Color(0xFF8C1115);
  static const Color creamColor = Color(0xFFFFF8E9);
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _currentLocationLabel = 'Detecting location...';
  bool _isLoadingLocation = false;

  final List<Map<String, dynamic>> categories = [
    {'icon': Icons.temple_hindu_outlined, 'title': 'Top\nPandals'},
    {'icon': Icons.account_balance_outlined, 'title': 'South\nKolkata'},
    {'icon': Icons.account_balance_outlined, 'title': 'North\nKolkata'},
    {'icon': Icons.celebration_outlined, 'title': 'Cultural\nEvents'},
    {'icon': Icons.restaurant_outlined, 'title': 'Food &\nFestivals'},
  ];

  // ৪টি প্যান্ডেল দেখানোর জন্য আরও একটি যোগ করা হয়েছে
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
  void initState() {
    super.initState();
    _loadCurrentLocation();
  }

  Future<void> _loadCurrentLocation() async {
    if (_isLoadingLocation) return;
    setState(() {
      _isLoadingLocation = true;
      _currentLocationLabel = 'Detecting location...';
    });
    try {
      final position = await LocationService().getCurrentPosition();
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      final place = placemarks.isEmpty ? null : placemarks.first;
      final parts = <String>[
        if (place?.subLocality?.trim().isNotEmpty == true) place!.subLocality!,
        if (place?.locality?.trim().isNotEmpty == true) place!.locality!,
      ].map((part) => part.trim()).toSet().toList();
      if (!mounted) return;
      setState(() {
        _currentLocationLabel = parts.isEmpty
            ? '${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}'
            : parts.join(', ');
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _currentLocationLabel = 'Tap to get location');
    } finally {
      if (mounted) setState(() => _isLoadingLocation = false);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Color(0xFFE50914),
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Color(0xFFE50914),
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: primaryRed,
        body: CustomScrollView(
          slivers: [
            _buildPremiumSliverAppBar(),
            SliverToBoxAdapter(child: _buildMainContent()),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // PREMIUM SLIVER APP BAR
  // =========================================================

  Widget _buildPremiumSliverAppBar() {
    const double expandedHeight = 220;
    const double collapsedHeight = 72;

    return SliverAppBar(
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Color(0xFFE50914),
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      pinned: true,
      floating: false,
      snap: false,
      stretch: true,
      expandedHeight: expandedHeight,
      collapsedHeight: collapsedHeight,
      toolbarHeight: collapsedHeight,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: primaryRed,
      surfaceTintColor: Colors.transparent,
      automaticallyImplyLeading: false,
      leadingWidth: 64,
      leading: Padding(
        padding: const EdgeInsets.only(left: 12),
        child: _buildAppBarCircleButton(
          image: true,
          onTap: widget.onMenuTap,
          imageurl: "assets/Sort.png",
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: _buildAppBarCircleButton(
            icon: Icons.notifications_none_rounded,
            onTap: () {},
            image: false,
          ),
        ),
      ],
      centerTitle: true,
      title: Image.asset(
        'assets/background-image.webp',
        height: 90,
        fit: BoxFit.contain,
      ),
      flexibleSpace: LayoutBuilder(
        builder: (context, constraints) {
          final double currentHeight = constraints.biggest.height;
          final double progress =
              ((currentHeight - collapsedHeight) /
                      (expandedHeight - collapsedHeight))
                  .clamp(0.0, 1.0);

          return FlexibleSpaceBar(
            collapseMode: CollapseMode.parallax,
            background: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFD71319), Color(0xFFAA080D)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 78, 16, 28),
                  child: IgnorePointer(
                    ignoring: progress < 0.35,
                    child: Opacity(
                      opacity: progress,
                      child: Transform.translate(
                        offset: Offset(0, 12 * (1 - progress)),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            _buildLocationButton(),
                            const SizedBox(height: 14),
                            _buildSearchBar(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAppBarCircleButton({
    IconData? icon,
    required VoidCallback onTap,
    required bool image,
    String? imageurl,
  }) {
    return Center(
      child: Material(
        color: Colors.white.withValues(alpha: 0.14),
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Container(
            width: 42,
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
            ),
            child: image
                ? Image(image: AssetImage(imageurl as String), height: 30)
                : Icon(icon, color: Colors.white, size: 24),
          ),
        ),
      ),
    );
  }

  Widget _buildLocationButton() {
    return InkWell(
      onTap: _loadCurrentLocation,
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
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.location_on, color: primaryRed, size: 20),
            const SizedBox(width: 6),
            Text(
              _currentLocationLabel,
              style: const TextStyle(
                color: Color(0xFF443C38),
                fontSize: 13, // সাইজ স্ট্যান্ডার্ড করা হয়েছে
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 4),
            if (_isLoadingLocation)
              const SizedBox.square(
                dimension: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: primaryRed,
                ),
              )
            else
              const Icon(
                Icons.my_location_rounded,
                color: Color(0xFF574E49),
                size: 18,
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
        controller: _searchController,
        onChanged: (value) => setState(() => _searchQuery = value),
        cursorColor: const Color.fromARGB(255, 216, 113, 117),
        style: const TextStyle(color: Color(0xFF333333), fontSize: 15),
        decoration: InputDecoration(
          hintText: 'Search pandals or areas...',
          hintStyle: const TextStyle(color: Color(0xFF8D8580), fontSize: 14),
          prefixIconConstraints: const BoxConstraints(minWidth: 50),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: primaryRed,
            size: 24,
          ),
          suffixIconConstraints: const BoxConstraints(minWidth: 50),
          suffixIcon: IconButton(
            onPressed: _searchQuery.trim().isEmpty
                ? null
                : () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
            padding: EdgeInsets.zero,
            icon: Icon(
              _searchQuery.trim().isEmpty
                  ? Icons.tune_rounded
                  : Icons.close_rounded,
              color: primaryRed,
              size: 22,
            ),
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
    final pandalController = context.watch<PandalController>();
    final query = _searchQuery.trim().toLowerCase();
    final displayedPandals = pandalController.pandals.where((pandal) {
      if (query.isEmpty) return pandal.isFeatured;
      return pandal.name.toLowerCase().contains(query) ||
          pandal.area.toLowerCase().contains(query) ||
          pandal.city.toLowerCase().contains(query) ||
          pandal.address.toLowerCase().contains(query) ||
          pandal.description.toLowerCase().contains(query);
    }).toList();
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        minHeight: MediaQuery.sizeOf(context).height - 170,
      ),
      padding: const EdgeInsets.fromLTRB(16, 26, 16, 30),
      decoration: const BoxDecoration(
        color: Color(0xFFFFF8E9),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x26000000),
            blurRadius: 24,
            spreadRadius: 1,
            offset: Offset(0, -8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // const SizedBox(height: 20),
          // _buildSectionHeader(title: 'Top Categories', onSeeAll: () {}),
          // const SizedBox(height: 12),
          // _buildCategories(),
          // const SizedBox(height: 15),
          _buildSectionHeader(
            title: query.isNotEmpty ? 'Search Results' : 'Featured Pandals',
            onSeeAll: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const LocationPandalsScreen(),
                ),
              );
            },
          ),
          // const SizedBox(height: 12),
          if (pandalController.isLoading && pandalController.pandals.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 70),
              child: Center(
                child: CircularProgressIndicator(color: Color(0xFFE50914)),
              ),
            )
          else
            _buildFeaturedPandalsGrid(displayedPandals),

          const SizedBox(height: 24),

          _buildSectionHeader(title: 'Upcoming Events', onSeeAll: () {}),
          const SizedBox(height: 12),
          _buildUpcomingEvents(),
          const SizedBox(height: 50),
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

  Widget _buildFeaturedPandalsGrid(List<PandalModel> featuredPandals) {
    final pandalController = context.read<PandalController>();
    final shellController = context.watch<AppShellController>();
    if (featuredPandals.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 34),
        child: Center(
          child: Text(
            'No matching pandal found',
            style: TextStyle(
              color: Color(0xFF8D8580),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }
    return GridView.builder(
      padding: const EdgeInsets.only(top: 12),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.65,
      ),
      itemCount: featuredPandals.length,
      itemBuilder: (context, index) {
        final pandal = featuredPandals[index];
        final pandalIndex = pandalController.pandals.indexWhere(
          (item) => item.id == pandal.id,
        );
        final isFavorite =
            pandalIndex >= 0 && shellController.saved.contains(pandalIndex);
        final imageUrl = pandal.thumbnailUrl.trim().isNotEmpty
            ? pandal.thumbnailUrl
            : pandal.images.isNotEmpty
            ? pandal.images.first
            : '';

        return Opacity(
          opacity: pandal.isActive ? 1 : 0.42,
          child: Container(
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
                  spreadRadius: 0,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Material(
                color: darkRed,
                child: InkWell(
                  onTap: pandal.isActive
                      ? () => Get.toNamed('/pandal/${pandal.id}')
                      : null,
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
                              width: double.infinity,
                              height: double.infinity,

                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                    if (loadingProgress == null) {
                                      return child;
                                    }

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
                                      alignment: Alignment.center,
                                      child: const CircularProgressIndicator(
                                        color: Color(0xFFFFD889),
                                        strokeWidth: 2.5,
                                      ),
                                    );
                                  },

                              errorBuilder: (context, error, stackTrace) {
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
                                  alignment: Alignment.center,
                                  child: const Icon(
                                    Icons.temple_hindu_rounded,
                                    color: Color(0xFFFFD889),
                                    size: 48,
                                  ),
                                );
                              },
                            ),
                            // Premium image overlay
                            // const DecoratedBox(
                            //   decoration: BoxDecoration(
                            //     gradient: LinearGradient(
                            //       colors: [
                            //         Color(0x12000000),
                            //         Colors.transparent,
                            //         Color(0x7A000000),
                            //       ],
                            //       stops: [0.0, 0.48, 1.0],
                            //       begin: Alignment.topCenter,
                            //       end: Alignment.bottomCenter,
                            //     ),
                            //   ),
                            // ),

                            // Subtle golden top border
                            Positioned(
                              top: 0,
                              left: 18,
                              right: 18,
                              child: Container(
                                height: 2,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  gradient: const LinearGradient(
                                    colors: [
                                      Colors.transparent,
                                      Color(0xFFFFD889),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            // Premium label
                            // Positioned(
                            //   top: 10,
                            //   left: 10,
                            //   child: Container(
                            //     padding: const EdgeInsets.symmetric(
                            //       horizontal: 9,
                            //       vertical: 5,
                            //     ),
                            //     decoration: BoxDecoration(
                            //       color: const Color(0xCC5C2516),
                            //       borderRadius: BorderRadius.circular(20),
                            //       border: Border.all(
                            //         color: const Color(0x66FFD889),
                            //         width: 0.8,
                            //       ),
                            //     ),
                            //     child: const Row(
                            //       mainAxisSize: MainAxisSize.min,
                            //       children: [
                            //         Icon(
                            //           Icons.workspace_premium_rounded,
                            //           color: Color(0xFFFFD889),
                            //           size: 13,
                            //         ),
                            //         SizedBox(width: 4),
                            //         Text(
                            //           'FEATURED',
                            //           style: TextStyle(
                            //             color: Color(0xFFFFE2A6),
                            //             fontSize: 8.5,
                            //             fontWeight: FontWeight.w800,
                            //             letterSpacing: 0.7,
                            //           ),
                            //         ),
                            //       ],
                            //     ),
                            //   ),
                            // ),

                            // Bookmark button
                            Positioned(
                              top: 9,
                              right: 9,
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: !pandal.isActive || pandalIndex < 0
                                      ? null
                                      : () => shellController.toggleSaved(
                                          pandalIndex,
                                        ),
                                  customBorder: const CircleBorder(),
                                  child: Container(
                                    width: 34,
                                    height: 34,
                                    padding: EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                      color: const Color(0xCC542111),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: const Color(0x66FFD889),
                                        width: 1,
                                      ),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Color(0x40000000),
                                          blurRadius: 8,
                                          offset: Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      isFavorite
                                          ? Icons.favorite_rounded
                                          : Icons.favorite_border_rounded,
                                      color: Colors.white,
                                      size: 20,
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
                                  letterSpacing: 0.1,
                                ),
                              ),

                              const Spacer(),

                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 7,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0x22FFD889),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: const Color(0x55FFD889),
                                        width: 0.8,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.star_rounded,
                                          color: Color(0xFFFFC34B),
                                          size: 15,
                                        ),
                                        const SizedBox(width: 3),
                                        Text(
                                          pandal.averageRating.toStringAsFixed(
                                            1,
                                          ),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 11.5,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
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

class _LocationMenuItem extends StatelessWidget {
  const _LocationMenuItem({
    required this.label,
    required this.icon,
    required this.isSelected,
  });

  final String label;
  final IconData icon;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected
            ? const Color(0xFFE50914).withValues(alpha: 0.09)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFFE50914)
                  : const Color(0xFFFFE5D8),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 17,
              color: isSelected ? Colors.white : const Color(0xFFE50914),
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: const Color(0xFF443C38),
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
          ),
          if (isSelected) ...[
            const SizedBox(width: 8),
            const Icon(
              Icons.check_circle_rounded,
              color: Color(0xFFE50914),
              size: 20,
            ),
          ],
        ],
      ),
    );
  }
}

class PremiumWishlistCardClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    const double cardRadius = 10;

    final Path path = Path();

    // Top-left corner
    path.moveTo(cardRadius, 0);

    // Top edge
    path.lineTo(size.width - 64, 0);

    // 1. Smooth entry (টপ এজ থেকে কাটআউটের শুরু)
    path.cubicTo(size.width - 60, 0, size.width - 50, 4, size.width - 50, 16);

    // 2. Main shallow bowl (আসল কাটআউট - এখন অনেক স্মুথ এবং মাপে ছোট)
    path.cubicTo(size.width - 50, 45, size.width - 38, 52, size.width - 16, 51);

    // 3. Smooth exit (কাটআউট থেকে রাইট এজে মেশা)
    path.cubicTo(size.width - 10, 50, size.width, 54, size.width, 64);

    // Right edge
    path.lineTo(size.width, size.height - cardRadius);

    // Bottom-right corner
    path.quadraticBezierTo(
      size.width,
      size.height,
      size.width - cardRadius,
      size.height,
    );

    // Bottom edge
    path.lineTo(cardRadius, size.height);

    // Bottom-left corner
    path.quadraticBezierTo(0, size.height, 0, size.height - cardRadius);

    // Left edge
    path.lineTo(0, cardRadius);

    // Top-left curve
    path.quadraticBezierTo(0, 0, cardRadius, 0);

    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return true; // Reclip enabled so you can see changes on hot reload
  }
}
