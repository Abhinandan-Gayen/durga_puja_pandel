import 'package:durga_puja_pandel/views/Users/Explore.dart';
import 'package:durga_puja_pandel/views/Users/dashbord.dart';
import 'package:durga_puja_pandel/views/Users/favoutiry.dart';
import 'package:durga_puja_pandel/views/Users/map.dart';
import 'package:durga_puja_pandel/views/Users/bottom-navigationBar/controller/botom_navigation_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});
  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  @override
  Widget build(BuildContext context) {
    final shellController = context.watch<AppShellController>();
    final index = shellController.selectedIndex;
    final saved = shellController.saved;
    final screens = [
      const DurgaPujaHomeScreen(),
      ExploreScreen(saved: saved, onSaved: shellController.toggleSaved),
      const CardScreen(),
      FavouritesScreen(saved: saved, onSaved: shellController.toggleSaved),
    ];
    return Scaffold(
      extendBody: true, // Allows screen content to roll behind the floating bar
      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: IndexedStack(index: index, children: screens),
          ),
        ),
      ),
      bottomNavigationBar: _buildCustomBottomNavBar(shellController),
    );
  }

  Widget _buildCustomBottomNavBar(AppShellController shellController) {
    final index = shellController.selectedIndex;
    final saved = shellController.saved;
    final items = [
      {
        'image': "assets/bottom_navigation/Home_duotone@4x.png",
        'activeimage': "assets/bottom_navigation/Home_fill.png",
        'label': 'Home',
      },
      {
        'image': "assets/bottom_navigation/Compass@4x.png",
        'activeimage': "assets/bottom_navigation/Compass_fill@4x.png",
        'label': 'Explore',
      },
      {
        'image': "assets/bottom_navigation/Map.png",
        'activeimage': "assets/bottom_navigation/Map_fill.png",
        'label': 'Map',
      },
      {
        'image': "assets/bottom_navigation/Favorite.png",
        'activeimage': "assets/bottom_navigation/Favorite_fill@4x.png",
        'label': 'Saved',
      },
    ];

    final double width = MediaQuery.of(context).size.width;
    final double barWidth = width > 520 ? 520 : width;

    return Center(
      heightFactor: 1,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Container(
          height: 68,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 18),
          decoration: BoxDecoration(
            color: Colors.white, // Deep rich maroon black
            borderRadius: BorderRadius.circular(24),

            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Sliding Active Indicator Background Pill
              AnimatedAlign(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutBack,
                alignment: Alignment(
                  -1.0 + (index * (2.0 / (items.length - 1))),
                  0.0,
                ),
                child: Container(
                  width: (barWidth - 32) / items.length - 14,
                  height: 44,
                  margin: const EdgeInsets.symmetric(horizontal: 7),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDFAC36).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              // Tab Items Row
              Row(
                children: List.generate(items.length, (i) {
                  final item = items[i];
                  final bool isSelected = index == i;
                  return Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => shellController.setIndex(i),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AnimatedScale(
                            duration: const Duration(milliseconds: 250),
                            scale: isSelected ? 1.2 : 1.0,
                            curve: Curves.easeOutBack,
                            child: i == 3
                                ? Badge(
                                    isLabelVisible: saved.isNotEmpty,
                                    label: Text(
                                      '${saved.length}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 9,
                                      ),
                                    ),
                                    backgroundColor: const Color(0xFF9F1013),
                                    child: Image.asset(
                                      isSelected
                                          ? item['activeimage'] as String
                                          : item['image'] as String,
                                      width: 25,
                                      height: 25,
                                      fit: BoxFit.contain,
                                    ),
                                  )
                                : Image.asset(
                                    isSelected
                                        ? item['activeimage'] as String
                                        : item['image'] as String,
                                    width: 25,
                                    height: 25,
                                    fit: BoxFit.contain,
                                  ),
                          ),
                          const SizedBox(height: 4),
                          AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 200),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected
                                  ? FontWeight.w800
                                  : FontWeight.w500,
                              color: isSelected
                                  ? const Color(0xFFDFAC36)
                                  : Colors.black,
                              letterSpacing: 0.2,
                            ),
                            child: Text(item['label'] as String),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
