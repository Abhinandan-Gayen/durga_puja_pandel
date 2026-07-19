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
                _HeroSearchBar(
                  onTap: () => context.pushNamed(RouteNames.search),
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
                  _SectionHeader(
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
                _SectionHeader(
                  title: 'Featured pandals',
                  onViewAll: () => context.pushNamed(RouteNames.pandalList),
                ),
                _HorizontalPandalList(
                  pandals: controller.featuredPandals,
                  controller: controller,
                  location: location,
                ),
                const SizedBox(height: 20),
                _SectionHeader(
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
                _SectionHeader(
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

class _HeroSearchBar extends StatelessWidget {
  const _HeroSearchBar({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.deepRed,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Find your next Pujo stop',
              style: TextStyle(
                color: AppColors.white,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 13,
                ),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.search, color: AppColors.mutedText),
                    SizedBox(width: 8),
                    Text('Search by pandal, area, city, theme'),
                  ],
                ),
              ),
            ),
          ],
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

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.onViewAll});

  final String title;
  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(title, style: Theme.of(context).textTheme.titleLarge),
        ),
        TextButton(onPressed: onViewAll, child: const Text('View all')),
      ],
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
      height: 250,
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
          const DrawerHeader(
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Text('Pujo Pandal Guide'),
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
