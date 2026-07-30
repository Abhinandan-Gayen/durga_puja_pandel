
import 'package:durga_puja_pandel/core/theme/normal_color.dart';
import 'package:durga_puja_pandel/views/Users/Explore.dart';
import 'package:durga_puja_pandel/views/Users/dashbord.dart';
import 'package:durga_puja_pandel/views/Users/favoutiry.dart';
import 'package:durga_puja_pandel/views/Users/map.dart';
import 'package:durga_puja_pandel/views/Users/profile.dart';
import 'package:flutter/material.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});
  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int index = 0;
  final saved = <int>{0, 2};

  @override
  Widget build(BuildContext context) {
    final screens = [
      // HomeScreen(onExplore: () => setState(() => index = 1)),
      DurgaPujaHomePage(),
      ExploreScreen(saved: saved, onSaved: _toggleSaved),
      const MapScreen(),
      FavouritesScreen(saved: saved, onSaved: _toggleSaved),
      const ProfileScreen(),
    ];
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: IndexedStack(index: index, children: screens),
          ),
        ),
      ),
      bottomNavigationBar: Center(
        heightFactor: 1,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: NavigationBar(
            height: 72,
            backgroundColor: const Color(0xFF1A0908),
            indicatorColor: red.withValues(alpha: .25),
            selectedIndex: index,
            onDestinationSelected: (v) => setState(() => index = v),
            destinations: [
              const NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home),
                  label: 'Home'),
              const NavigationDestination(
                  icon: Icon(Icons.explore_outlined),
                  selectedIcon: Icon(Icons.explore),
                  label: 'Explore'),
              const NavigationDestination(
                  icon: Icon(Icons.map_outlined),
                  selectedIcon: Icon(Icons.map),
                  label: 'Map'),
              NavigationDestination(
                icon: Badge(
                    label: Text('${saved.length}'),
                    child: const Icon(Icons.favorite_border)),
                selectedIcon: Badge(
                    label: Text('${saved.length}'),
                    child: const Icon(Icons.favorite)),
                label: 'Favourites',
              ),
              const NavigationDestination(
                  icon: Icon(Icons.person_outline),
                  selectedIcon: Icon(Icons.person),
                  label: 'Profile'),
            ],
          ),
        ),
      ),
    );
  }

  void _toggleSaved(int value) => setState(() {
        saved.contains(value) ? saved.remove(value) : saved.add(value);
      });
}