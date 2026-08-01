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
  int selectedBottomIndex = 0;
  static const Color primaryRed = Color(0xFFB91419);

  @override
  Widget build(BuildContext context) {
    final screens = [
      // HomeScreen(onExplore: () => setState(() => index = 1)),
      DurgaPujaHomeScreen(),
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
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  void _toggleSaved(int value) => setState(() {
    saved.contains(value) ? saved.remove(value) : saved.add(value);
  });

  Widget _buildBottomNavigation() {
    final List<Map<String, dynamic>> items = [
      {'icon': Icons.map_outlined, 'selectedIcon': Icons.map, 'title': 'Map'},
      {
        'icon': Icons.near_me_outlined,
        'selectedIcon': Icons.near_me,
        'title': 'Nearby',
      },
      {
        'icon': Icons.favorite_border_rounded,
        'selectedIcon': Icons.favorite_rounded,
        'title': 'Saved',
      },
      {
        'icon': Icons.route_outlined,
        'selectedIcon': Icons.route,
        'title': 'Routes',
      },
    ];

    return Container(
      height: 62,
      margin: const EdgeInsets.fromLTRB(8, 0, 8, 7),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFCF5),
        borderRadius: BorderRadius.circular(21),
        border: Border.all(color: const Color(0xFFECDCC9), width: 0.8),
        boxShadow: const [
          BoxShadow(
            color: Color(0x25000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: List.generate(items.length, (index) {
          final item = items[index];
          final bool isSelected = selectedBottomIndex == index;

          return Expanded(
            child: InkWell(
              onTap: () {
                setState(() {
                  selectedBottomIndex = index;
                });
              },
              borderRadius: BorderRadius.circular(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isSelected
                        ? item['selectedIcon'] as IconData
                        : item['icon'] as IconData,
                    color: isSelected ? primaryRed : const Color(0xFF746B66),
                    size: 20,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    item['title'] as String,
                    style: TextStyle(
                      color: isSelected ? primaryRed : const Color(0xFF554D48),
                      fontSize: 8,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
