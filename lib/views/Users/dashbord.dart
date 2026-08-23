import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../controllers/pandal_controller.dart';
import '../../core/services/location_service.dart';
import '../../core/utils/distance_helper.dart';
import '../../models/pandal_model.dart';
import '../admin/location_picker_screen.dart';
import '../admin/slider-image-post/controller/slider_controller.dart';
import '../widgets/shimmer.dart';
import '../../controllers/event_controller.dart';
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
  double _currentLatitude = 22.5726;
  double _currentLongitude = 88.3639;
  bool _hasSelectedLocation = false;

  late final PageController _sliderPageController;
  Timer? _sliderTimer;
  int _currentSliderPage = 0;

  final List<Map<String, dynamic>> categories = [
    {'icon': Icons.temple_hindu_outlined, 'title': 'Top\nPandals'},
    {'icon': Icons.account_balance_outlined, 'title': 'South\nKolkata'},
    {'icon': Icons.account_balance_outlined, 'title': 'North\nKolkata'},
    {'icon': Icons.celebration_outlined, 'title': 'Cultural\nEvents'},
    {'icon': Icons.restaurant_outlined, 'title': 'Food &\nFestivals'},
  ];

  // Loaded dynamically via EventController

  @override
  void initState() {
    super.initState();
    _sliderPageController = PageController();
    _loadCurrentLocation();
    _startSliderTimer();
  }

  void _startSliderTimer() {
    _sliderTimer?.cancel();
    _sliderTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!mounted) return;
      final sliderController = Provider.of<SliderController>(
        context,
        listen: false,
      );
      final activeSliders = sliderController.sliderPandals
          .where((s) => s.isActive)
          .toList();
      if (activeSliders.isEmpty) return;

      if (_sliderPageController.hasClients) {
        final nextPage = (_currentSliderPage + 1) % activeSliders.length;
        _sliderPageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOutCubic,
        );
      }
    });
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
        _currentLatitude = position.latitude;
        _currentLongitude = position.longitude;
        _hasSelectedLocation = true;
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

  Future<void> _showLocationOptions() async {
    final choice = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 22),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD6D2CF),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Choose location',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                _LocationChoiceTile(
                  icon: Icons.my_location_rounded,
                  title: 'Use current location',
                  subtitle: 'Update using your device GPS',
                  onTap: () => Navigator.of(sheetContext).pop('current'),
                ),
                _LocationChoiceTile(
                  icon: Icons.search_rounded,
                  title: 'Search another location',
                  subtitle: 'Choose an address, area, or city',
                  onTap: () => Navigator.of(sheetContext).pop('search'),
                ),
              ],
            ),
          ),
        );
      },
    );
    if (!mounted || choice == null) return;
    if (choice == 'current') {
      await _loadCurrentLocation();
      return;
    }
    final result = await Navigator.of(context).push<LocationPickerResult>(
      MaterialPageRoute<LocationPickerResult>(
        builder: (_) => LocationPickerScreen(
          initialLatitude: _currentLatitude,
          initialLongitude: _currentLongitude,
        ),
      ),
    );
    if (!mounted || result == null) return;
    setState(() {
      _currentLatitude = result.latitude;
      _currentLongitude = result.longitude;
      _hasSelectedLocation = true;
      _currentLocationLabel = result.area?.trim().isNotEmpty == true
          ? result.area!.trim()
          : result.city?.trim().isNotEmpty == true
          ? result.city!.trim()
          : result.address?.trim().isNotEmpty == true
          ? result.address!.trim()
          : '${result.latitude.toStringAsFixed(4)}, ${result.longitude.toStringAsFixed(4)}';
    });
  }

  @override
  void dispose() {
    _sliderTimer?.cancel();
    _sliderPageController.dispose();
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
      value:  SystemUiOverlayStyle(
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
                // gradient: LinearGradient(
                //   colors: [Color(0xFFD71319), Color(0xFFAA080D)],
                //   begin: Alignment.topCenter,
                //   end: Alignment.bottomCenter,
                // ),
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
      onTap: _showLocationOptions,
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
          if (query.isEmpty) ...[
            _buildBannerSlider(),
            const SizedBox(height: 24),
          ],
          _buildSectionHeader(
            title: query.isNotEmpty ? 'Search Results' : 'Featured Pandals',
            onSeeAll: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => LocationPandalsScreen(
                    userLatitude: _hasSelectedLocation
                        ? _currentLatitude
                        : null,
                    userLongitude: _hasSelectedLocation
                        ? _currentLongitude
                        : null,
                  ),
                ),
              );
            },
          ),
          // const SizedBox(height: 12),
          if (pandalController.isLoading && pandalController.pandals.isEmpty)
            _buildFeaturedPandalsShimmer()
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final double availableWidth = constraints.maxWidth;

        // -----------------------------
        // Responsive Grid Configuration
        // -----------------------------
        int crossAxisCount;
        double spacing;

        if (availableWidth >= 1100) {
          crossAxisCount = 4;
          spacing = 16;
        } else if (availableWidth >= 700) {
          crossAxisCount = 3;
          spacing = 14;
        } else {
          crossAxisCount = 2;
          spacing = availableWidth < 360 ? 8 : 12;
        }

        final double cardWidth =
            (availableWidth - ((crossAxisCount - 1) * spacing)) /
            crossAxisCount;

        // -----------------------------
        // Responsive Sizes
        // -----------------------------
        final bool isSmallCard = cardWidth < 170;
        final bool isLargeCard = cardWidth > 230;

        final double cardHeight = isSmallCard
            ? 270
            : isLargeCard
            ? 315
            : 290;

        final double borderRadius = isSmallCard ? 16 : 20;

        final double horizontalPadding = isSmallCard ? 9 : 12;
        final double verticalPadding = isSmallCard ? 8 : 11;

        final double titleFontSize = isSmallCard
            ? 12.5
            : isLargeCard
            ? 15
            : 14;

        final double metaFontSize = isSmallCard ? 9.5 : 11;

        final double metaIconSize = isSmallCard ? 12 : 14;

        final double bookmarkSize = isSmallCard ? 30 : 34;

        return GridView.builder(
          padding: const EdgeInsets.only(top: 12),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),

          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: spacing,
            mainAxisSpacing: spacing,

            // childAspectRatio-এর বদলে responsive fixed extent
            mainAxisExtent: cardHeight,
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

            final distanceKm = DistanceHelper.calculateDistanceInKm(
              _currentLatitude,
              _currentLongitude,
              pandal.latitude,
              pandal.longitude,
            );

            final distanceText = distanceKm < 1
                ? '${(distanceKm * 1000).round()} m away'
                : '${distanceKm.toStringAsFixed(1)} km away';

            final cardContent = Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(borderRadius),
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
                borderRadius: BorderRadius.circular(borderRadius),

                child: Material(
                  color: darkRed,

                  child: InkWell(
                    onTap: pandal.isActive
                        ? () => Get.toNamed('/pandal/${pandal.id}')
                        : null,

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        // ==============================
                        // IMAGE SECTION
                        // ==============================
                        SizedBox(
                          height: cardHeight * 0.53,
                          width: double.infinity,

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

                                      return const ShimmerPlaceholder(
                                        width: double.infinity,
                                        height: double.infinity,
                                        borderRadius: 0,
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
                                    child: Icon(
                                      Icons.temple_hindu_rounded,
                                      color: const Color(0xFFFFD889),
                                      size: isSmallCard ? 38 : 48,
                                    ),
                                  );
                                },
                              ),

                              // Golden Top Line
                              Positioned(
                                top: 0,
                                left: isSmallCard ? 12 : 18,
                                right: isSmallCard ? 12 : 18,
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

                              // ==============================
                              // FAVOURITE BUTTON
                              // ==============================
                              Positioned(
                                top: isSmallCard ? 7 : 9,
                                right: isSmallCard ? 7 : 9,

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
                                      width: bookmarkSize,
                                      height: bookmarkSize,
                                      padding: EdgeInsets.all(
                                        isSmallCard ? 5 : 6,
                                      ),

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
                                        size: isSmallCard ? 17 : 20,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // ==============================
                        // CONTENT SECTION
                        // ==============================
                        Expanded(
                          child: Container(
                            width: double.infinity,

                            padding: EdgeInsets.fromLTRB(
                              horizontalPadding,
                              verticalPadding,
                              horizontalPadding,
                              isSmallCard ? 7 : 10,
                            ),

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
                                // PANDAL NAME
                                Text(
                                  pandal.name,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,

                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: titleFontSize,
                                    height: 1.08,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.1,
                                  ),
                                ),

                                // ==============================
                                // DISTANCE
                                // ==============================
                                if (_hasSelectedLocation) ...[
                                  SizedBox(height: isSmallCard ? 4 : 6),

                                  Row(
                                    children: [
                                      Icon(
                                        Icons.near_me_rounded,
                                        color: const Color(0xFFFFD2C1),
                                        size: metaIconSize,
                                      ),

                                      const SizedBox(width: 3),

                                      Expanded(
                                        child: Text(
                                          distanceText,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,

                                          style: TextStyle(
                                            color: const Color(0xFFFFD2C1),
                                            fontSize: metaFontSize,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],

                                const Spacer(),

                                // ==============================
                                // RATING
                                // ==============================
                                Row(
                                  children: [
                                    Flexible(
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: isSmallCard ? 5 : 7,
                                          vertical: isSmallCard ? 3 : 4,
                                        ),

                                        decoration: BoxDecoration(
                                          color: const Color(0x22FFD889),
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                          border: Border.all(
                                            color: const Color(0x55FFD889),
                                            width: 0.8,
                                          ),
                                        ),

                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,

                                          children: [
                                            Icon(
                                              Icons.star_rounded,
                                              color: const Color(0xFFFFC34B),
                                              size: isSmallCard ? 13 : 15,
                                            ),

                                            const SizedBox(width: 2),

                                            Flexible(
                                              child: Text(
                                                pandal.averageRating
                                                    .toStringAsFixed(1),

                                                maxLines: 1,

                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: isSmallCard
                                                      ? 10
                                                      : 11.5,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),

                                    const Spacer(),

                                    Icon(
                                      Icons.arrow_forward_rounded,
                                      color: const Color(0xFFFFD2C1),
                                      size: isSmallCard ? 15 : 17,
                                    ),
                                  ],
                                ),

                                SizedBox(height: isSmallCard ? 5 : 8),

                                // ==============================
                                // LOCATION
                                // ==============================
                                Row(
                                  children: [
                                    Icon(
                                      Icons.location_on_rounded,
                                      color: const Color(0xFFFFD2C1),
                                      size: metaIconSize,
                                    ),

                                    const SizedBox(width: 3),

                                    Expanded(
                                      child: Text(
                                        pandal.area,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,

                                        style: TextStyle(
                                          color: const Color(0xFFFFD2C1),
                                          fontSize: metaFontSize,
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
                Opacity(opacity: 0.42, child: cardContent),
                Positioned.fill(
                  child: IgnorePointer(
                    child: Center(
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isSmallCard ? 10 : 14,
                          vertical: isSmallCard ? 6 : 8,
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
                        child: Text(
                          'Inactive',
                          style: TextStyle(
                            color: const Color(0xFFFF5252),
                            fontSize: isSmallCard ? 13 : 15,
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
          },
        );
      },
    );
  }

  // =========================================================
  // UPCOMING EVENTS
  // =========================================================

  Widget _buildUpcomingEvents() {
    final eventController = context.watch<EventController>();
    final activeEvents = eventController.events;

    if (eventController.isLoading && activeEvents.isEmpty) {
      return Column(
        children: List.generate(
          2,
          (index) => const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: ShimmerPlaceholder(
              width: double.infinity,
              height: 90,
              borderRadius: 16,
            ),
          ),
        ),
      );
    }

    if (activeEvents.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text(
            'No upcoming events scheduled',
            style: TextStyle(
              color: Color(0xFF746B66),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }

    return Column(
      children: List.generate(activeEvents.length, (index) {
        final event = activeEvents[index];

        return Container(
          margin: EdgeInsets.only(
            bottom: index == activeEvents.length - 1 ? 0 : 12,
          ),
          padding: const EdgeInsets.all(12),
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
              _buildEventDate(month: event.month, date: event.date),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      style: const TextStyle(
                        color: Color(0xFF3B3531),
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      event.subtitle,
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
                          event.time,
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

  Widget _buildBannerSlider() {
    final sliderController = context.watch<SliderController>();
    final activeSliders = sliderController.sliderPandals
        .where((s) => s.isActive)
        .toList();

    if (activeSliders.isEmpty) {
      if (sliderController.isLoading) {
        return const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: ShimmerPlaceholder(
            width: double.infinity,
            height: 160,
            borderRadius: 16,
          ),
        );
      }
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        SizedBox(
          height: 180,
          child: PageView.builder(
            controller: _sliderPageController,
            itemCount: activeSliders.length,
            onPageChanged: (index) {
              setState(() {
                _currentSliderPage = index;
              });
            },
            itemBuilder: (context, index) {
              final slider = activeSliders[index];
              return GestureDetector(
                onTap: () {
                  Get.toNamed('/pandal/${slider.id}?isSlider=true');
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: CachedNetworkImage(
                      imageUrl: slider.thumbnailUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: const Color(0xFFE9D8C6).withValues(alpha: 0.3),
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: primaryRed,
                            strokeWidth: 2,
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: const Color(0xFFE9D8C6).withValues(alpha: 0.3),
                        child: const Icon(
                          Icons.broken_image_rounded,
                          color: Colors.grey,
                          size: 40,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        // Dots Indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            activeSliders.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: _currentSliderPage == index ? 18 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: _currentSliderPage == index
                    ? primaryRed
                    : const Color(0xFFDFAC36).withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturedPandalsShimmer() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double availableWidth = constraints.maxWidth;
        int crossAxisCount = availableWidth >= 1100
            ? 4
            : (availableWidth >= 700 ? 3 : 2);
        double spacing = availableWidth >= 1100
            ? 16
            : (availableWidth >= 700 ? 14 : (availableWidth < 360 ? 8 : 12));
        final double cardWidth =
            (availableWidth - ((crossAxisCount - 1) * spacing)) /
            crossAxisCount;
        final double cardHeight = cardWidth < 170
            ? 270
            : (cardWidth > 230 ? 315 : 290);
        final double borderRadius = cardWidth < 170 ? 16 : 20;

        return GridView.builder(
          padding: const EdgeInsets.only(top: 12),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: spacing,
            mainAxisSpacing: spacing,
            mainAxisExtent: cardHeight,
          ),
          itemCount: 4,
          itemBuilder: (context, index) {
            return ShimmerPlaceholder(
              width: double.infinity,
              height: cardHeight,
              borderRadius: borderRadius,
            );
          },
        );
      },
    );
  }
}

class _LocationChoiceTile extends StatelessWidget {
  const _LocationChoiceTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      onTap: onTap,
      leading: Container(
        width: 42,
        height: 42,
        decoration: const BoxDecoration(
          color: Color(0xFFEAF1FF),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Color(0xFF2878F0), size: 22),
      ),
      title: Text(
        title,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 12, color: Color(0xFF625C58)),
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
