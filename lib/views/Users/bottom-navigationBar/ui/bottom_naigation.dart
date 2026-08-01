import 'package:durga_puja_pandel/views/Users/Explore.dart';
import 'package:durga_puja_pandel/views/Users/bottom-navigationBar/controller/botom_navigation_controller.dart';
import 'package:durga_puja_pandel/views/Users/dashbord.dart';
import 'package:durga_puja_pandel/views/Users/favoutiry.dart';
import 'package:durga_puja_pandel/views/Users/map.dart';
import 'package:durga_puja_pandel/views/Users/profile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key});

  static const Color primaryRed = Color(0xFFB91419);

  @override
  Widget build(BuildContext context) {
    return Consumer<AppShellController>(
      builder: (context, controller, child) {
        final screens = [
          DurgaPujaHomeScreen(),
          ExploreScreen(
            saved: controller.saved,
            onSaved: controller.toggleSaved,
          ),
          const CardScreen(),
          FavouritesScreen(
            saved: controller.saved,
            onSaved: controller.toggleSaved,
          ),
          const ProfileScreen(),
        ];

        return Scaffold(
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: IndexedStack(
                  index: controller.selectedIndex,
                  children: screens,
                ),
              ),
            ),
          ),
          bottomNavigationBar: _buildBottomNavigation(controller),
        );
      },
    );
  }

  Widget _buildBottomNavigation(AppShellController controller) {
    final List<Map<String, dynamic>> items = [
      {
        'icon': Icons.home_outlined,
        'selectedIcon': Icons.home,
        'title': 'Home',
      },
      {
        'icon': Icons.near_me_outlined,
        'selectedIcon': Icons.near_me,
        'title': 'Nearby',
      },
      {'icon': Icons.map_outlined, 'selectedIcon': Icons.map, 'title': 'Map'},
      {
        'icon': Icons.favorite_border_rounded,
        'selectedIcon': Icons.favorite_rounded,
        'title': 'Saved',
      },
      {
        'icon': Icons.person_outline,
        'selectedIcon': Icons.person,
        'title': 'Profile',
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
          final bool isSelected = controller.selectedIndex == index;

          return Expanded(
            child: InkWell(
              onTap: () {
                controller.setIndex(index);
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
