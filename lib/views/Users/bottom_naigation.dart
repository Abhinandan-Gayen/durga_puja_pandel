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
  int selectedBottomIndex = 0;

  final Set<int> saved = {0, 2};

  static const Color primaryRed = Color(0xFFB91419);

  void _toggleSaved(int value) {
    setState(() {
      if (saved.contains(value)) {
        saved.remove(value);
      } else {
        saved.add(value);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      const DurgaPujaHomeScreen(),

      ExploreScreen(
        saved: saved,
        onSaved: _toggleSaved,
      ),

      const MapScreen(),

      FavouritesScreen(
        saved: saved,
        onSaved: _toggleSaved,
      ),

      const ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E9),

      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: IndexedStack(
              index: selectedBottomIndex,
              children: screens,
            ),
          ),
        ),
      ),

      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildBottomNavigation() {
    final List<Map<String, dynamic>> items = [
      {
        'icon': Icons.home_outlined,
        'selectedIcon': Icons.home_rounded,
        'title': 'Home',
      },
      {
        'icon': Icons.explore_outlined,
        'selectedIcon': Icons.explore_rounded,
        'title': 'Explore',
      },
      {
        'icon': Icons.map_outlined,
        'selectedIcon': Icons.map_rounded,
        'title': 'Map',
      },
      {
        'icon': Icons.favorite_border_rounded,
        'selectedIcon': Icons.favorite_rounded,
        'title': 'Saved',
      },
      {
        'icon': Icons.person_outline_rounded,
        'selectedIcon': Icons.person_rounded,
        'title': 'Profile',
      },
    ];

    return SafeArea(
      top: false,
      child: Container(
        height: 66,
        margin: const EdgeInsets.fromLTRB(8, 0, 8, 7),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFCF5),
          borderRadius: BorderRadius.circular(21),
          border: Border.all(
            color: const Color(0xFFECDCC9),
            width: 0.8,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x25000000),
              blurRadius: 10,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: List.generate(items.length, (itemIndex) {
            final Map<String, dynamic> item = items[itemIndex];

            final bool isSelected =
                selectedBottomIndex == itemIndex;

            return Expanded(
              child: InkWell(
                onTap: () {
                  setState(() {
                    selectedBottomIndex = itemIndex;
                  });
                },
                borderRadius: BorderRadius.circular(20),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  padding: const EdgeInsets.symmetric(
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? primaryRed.withOpacity(0.08)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isSelected
                            ? item['selectedIcon'] as IconData
                            : item['icon'] as IconData,
                        color: isSelected
                            ? primaryRed
                            : const Color(0xFF746B66),
                        size: 21,
                      ),

                      const SizedBox(height: 3),

                      Text(
                        item['title'] as String,
                        style: TextStyle(
                          color: isSelected
                              ? primaryRed
                              : const Color(0xFF554D48),
                          fontSize: 8.5,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}