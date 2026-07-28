import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/location_controller.dart';
import '../../controllers/pandal_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../models/pandal_model.dart';
import '../../routes/route_names.dart';
import '../widgets/empty_widget.dart';
import '../widgets/loading_widget.dart';
import '../widgets/pandal_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedFilter = '';
  bool _hasLoadedNearby = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_hasLoadedNearby) {
      return;
    }
    _hasLoadedNearby = true;
    final position = context.read<LocationController>().currentPosition;
    context.read<PandalController>().fetchNearbyPandals(position);
  }

  @override
  Widget build(BuildContext context) {
    final location = context.watch<LocationController>().currentPosition;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pujo Pandal Guide'),
        actions: [
          IconButton(
            tooltip: 'Premium',
            onPressed: () => context.pushNamed(RouteNames.premium),
            icon: const Icon(Icons.diamond_outlined),
          ),
          IconButton(
            tooltip: 'Search',
            onPressed: () => context.pushNamed(RouteNames.search),
            icon: const Icon(Icons.search),
          ),
          IconButton(
            tooltip: 'Profile',
            onPressed: () => context.pushNamed(RouteNames.profile),
            icon: const Icon(Icons.person_outline),
          ),
        ],
      ),
      drawer: _MainDrawer(),
      body: Consumer<PandalController>(
        builder: (context, controller, _) {
          if (controller.isLoading && controller.activePandals.isEmpty) {
            return const LoadingWidget(message: 'Loading pandals');
          }
          if (controller.activePandals.isEmpty) {
            return const EmptyWidget(
              title: 'No pandals yet',
              message: 'Active pandals published by admins will appear here.',
            );
          }

          final filtered = _filteredHomePandals(controller, location);

          return RefreshIndicator(
            onRefresh: () async {
              await controller.fetchActivePandals();
              await controller.fetchFeaturedPandals();
              await controller.fetchPopularPandals();
              await controller.fetchNearbyPandals(location);
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const _HeroSearchBar(),
                const SizedBox(height: 16),
                _PremiumBanner(
                  onTap: () => context.pushNamed(RouteNames.premium),
                ),
                const SizedBox(height: 16),
                _FilterChips(
                  selectedFilter: _selectedFilter,
                  onSelected: (filter) {
                    setState(() {
                      _selectedFilter = _selectedFilter == filter ? '' : filter;
                    });
                  },
                ),
                if (_selectedFilter.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _AnimatedSectionHeader(
                    title: _selectedFilter,
                    onViewAll: () => context.pushNamed(RouteNames.pandalList),
                  ),
                  _HorizontalPandalList(
                    pandals: filtered,
                    controller: controller,
                    location: location,
                  ),
                ],
                const SizedBox(height: 20),
                _AnimatedSectionHeader(
                  title: 'Featured pandals',
                  onViewAll: () => context.pushNamed(RouteNames.pandalList),
                ),
                _HorizontalPandalList(
                  pandals: controller.featuredPandals,
                  controller: controller,
                  location: location,
                ),
                const SizedBox(height: 20),
                _AnimatedSectionHeader(
                  title: 'Nearby pandals',
                  onViewAll: () => context.pushNamed(RouteNames.map),
                ),
                _HorizontalPandalList(
                  pandals: controller.nearbyPandals.isEmpty
                      ? controller.activePandals.take(6).toList()
                      : controller.nearbyPandals,
                  controller: controller,
                  location: location,
                ),
                const SizedBox(height: 20),
                _AnimatedSectionHeader(
                  title: 'Popular pandals',
                  onViewAll: () => context.pushNamed(RouteNames.pandalList),
                ),
                _HorizontalPandalList(
                  pandals: controller.popularPandals.isEmpty
                      ? controller.activePandals
                      : controller.popularPandals,
                  controller: controller,
                  location: location,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  List<PandalModel> _filteredHomePandals(
    PandalController controller,
    dynamic location,
  ) {
    return switch (_selectedFilter) {
      'Nearby' => controller.nearbyPandals,
      'Featured' =>
        controller.activePandals.where((pandal) => pandal.isFeatured).toList(),
      'High Rated' =>
        controller.activePandals
            .where((pandal) => pandal.averageRating >= 4)
            .toList(),
      'Low Crowd' =>
        controller.activePandals
            .where((pandal) => pandal.crowdLevel == 'low')
            .toList(),
      'Open Now' =>
        controller.activePandals.where(controller.isOpenNow).toList(),
      _ => controller.activePandals,
    };
  }
}

class _HeroSearchBar extends StatefulWidget {
  const _HeroSearchBar();

  @override
  State<_HeroSearchBar> createState() => _HeroSearchBarState();
}

class _HeroSearchBarState extends State<_HeroSearchBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim;
  late final Animation<double> _fadeScale;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeScale = CurvedAnimation(parent: _anim, curve: Curves.easeOutBack);
    _anim.forward();
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeScale,
      child: ScaleTransition(
        scale: _fadeScale,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.deepRed, AppColors.vermilion],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.deepRed.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Find your next Pujo stop',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 14),
                InkWell(
                  onTap: () => context.pushNamed(RouteNames.search),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.search, color: AppColors.mutedText),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Search by pandal, area, city, theme',
                            style: TextStyle(
                              color: AppColors.mutedText,
                              fontSize: 15,
                            ),
                          ),
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
  }
}

class _PremiumBanner extends StatefulWidget {
  const _PremiumBanner({required this.onTap});

  final VoidCallback onTap;

  @override
  State<_PremiumBanner> createState() => _PremiumBannerState();
}

class _PremiumBannerState extends State<_PremiumBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim;
  late final Animation<double> _slide;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _slide = CurvedAnimation(
      parent: _anim,
      curve: const Interval(0.1, 1.0, curve: Curves.easeOutCubic),
    );
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _anim.forward();
    });
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizeTransition(
      sizeFactor: _slide,
      axisAlignment: -1,
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.premiumGold.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.diamond, color: AppColors.premiumGold, size: 26),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Go Premium',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Unlock exclusive features & ad-free experience',
                      style: TextStyle(color: Colors.white60, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: AppColors.premiumGold, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterChips extends StatelessWidget {
  const _FilterChips({required this.selectedFilter, required this.onSelected});

  final String selectedFilter;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    const filters = [
      'Nearby',
      'Featured',
      'High Rated',
      'Low Crowd',
      'Open Now',
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final filter in filters)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                selected: selectedFilter == filter,
                label: Text(filter),
                onSelected: (_) => onSelected(filter),
              ),
            ),
        ],
      ),
    );
  }
}

class _AnimatedSectionHeader extends StatefulWidget {
  const _AnimatedSectionHeader({
    required this.title,
    required this.onViewAll,
  });

  final String title;
  final VoidCallback onViewAll;

  @override
  State<_AnimatedSectionHeader> createState() => _AnimatedSectionHeaderState();
}

class _AnimatedSectionHeaderState extends State<_AnimatedSectionHeader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: Row(
        children: [
          Expanded(
            child: Text(
              widget.title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          TextButton(
            onPressed: widget.onViewAll,
            child: const Text('View all'),
          ),
        ],
      ),
    );
  }
}

class _HorizontalPandalList extends StatelessWidget {
  const _HorizontalPandalList({
    required this.pandals,
    required this.controller,
    required this.location,
  });

  final List<PandalModel> pandals;
  final PandalController controller;
  final dynamic location;

  @override
  Widget build(BuildContext context) {
    final items = pandals.take(8).toList();
    if (items.isEmpty) {
      return const SizedBox(
        height: 80,
        child: Center(child: Text('No pandals in this section')),
      );
    }
    return SizedBox(
      height: 260,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final pandal = items[index];
          return PandalCard(
            pandal: pandal,
            compact: true,
            distanceKm: location == null
                ? null
                : controller.calculateDistanceFromUser(pandal, location),
          );
        },
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemCount: items.length,
      ),
    );
  }
}

class _MainDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final items = <({IconData icon, String label, String route})>[
      (icon: Icons.home_outlined, label: 'Home', route: RouteNames.home),
      (icon: Icons.list_alt, label: 'Pandals', route: RouteNames.pandalList),
      (icon: Icons.map_outlined, label: 'Map', route: RouteNames.map),
      (
        icon: Icons.route,
        label: 'Route planner',
        route: RouteNames.routePlanner,
      ),
      (
        icon: Icons.favorite_outline,
        label: 'Favorites',
        route: RouteNames.favorites,
      ),
      (icon: Icons.search, label: 'Search', route: RouteNames.search),
      (icon: Icons.person_outline, label: 'Profile', route: RouteNames.profile),
      (icon: Icons.diamond_outlined, label: 'Premium', route: RouteNames.premium),
      if (auth.isAdmin)
        (
          icon: Icons.admin_panel_settings,
          label: 'Admin',
          route: RouteNames.adminDashboard,
        ),
    ];

    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
                ],
              ),
            ),
            child: const Align(
              alignment: Alignment.bottomLeft,
              child: Text(
                'Pujo Pandal Guide',
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          for (final item in items)
            ListTile(
              leading: Icon(item.icon),
              title: Text(item.label),
              onTap: () {
                Navigator.of(context).pop();
                context.goNamed(item.route);
              },
            ),
        ],
      ),
    );
  }
}
