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
    final AppShellController shellController = context
        .watch<AppShellController>();

    final int index = shellController.selectedIndex;
    final Set<int> saved = shellController.saved;

    final List<Widget> screens = [
      const DurgaPujaHomeScreen(),

      ExploreScreen(saved: saved, onSaved: shellController.toggleSaved),

      const CardScreen(),

      FavouritesScreen(saved: saved, onSaved: shellController.toggleSaved),
    ];

    return Scaffold(
      extendBody: true,
      backgroundColor: index == 0
          ? const Color(0xFFE50914)
          : (index == 2 ? const Color(0xFFB91419) : const Color(0xFFFFF8E9)),
      body: SafeArea(
        top: index != 0,
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
    final int index = shellController.selectedIndex;
    final Set<int> saved = shellController.saved;

    final List<Map<String, String>> items = [
      {
        'outline': 'assets/bottom_navigation/Home_light@4x.png',
        'filled': 'assets/bottom_navigation/Home_fill.png',
        'label': 'Home',
      },
      {
        'outline': 'assets/bottom_navigation/Compass_light@4x.png',
        'filled': 'assets/bottom_navigation/Compass_fill@4x.png',
        'label': 'Explore',
      },
      {
        'outline': 'assets/bottom_navigation/Pin_alt_light.png',
        'filled': 'assets/bottom_navigation/Pin_alt_fill@4x.png',
        'label': 'Map',
      },
      {
        'outline': 'assets/bottom_navigation/Favorite_light@4x.png',
        'filled': 'assets/bottom_navigation/Favorite_fill@4x.png',
        'label': 'Saved',
      },
    ];

    return SafeArea(
      top: false,
      minimum: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
      child: Center(
        heightFactor: 1,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Container(
            height: 62,
            padding: const EdgeInsets.symmetric(horizontal: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFCF8),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: const Color(0xFFEBDCCE), width: 1),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x26000000),
                  blurRadius: 18,
                  offset: Offset(0, 8),
                ),
                BoxShadow(
                  color: Color(0x12B91419),
                  blurRadius: 12,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final double itemWidth = constraints.maxWidth / items.length;

                return Stack(
                  alignment: Alignment.centerLeft,
                  children: [
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOutCubic,
                      left: index * itemWidth + 4,
                      top: 5,
                      child: Container(
                        width: itemWidth - 8,
                        height: 34,
                        decoration: BoxDecoration(
                          color: const Color(0xFF8C1115),
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x358C1115),
                              blurRadius: 8,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                      ),
                    ),

                    Row(
                      children: List.generate(items.length, (int i) {
                        final Map<String, String> item = items[i];
                        final bool isSelected = index == i;

                        return Expanded(
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
                              if (index != i) {
                                shellController.setIndex(i);
                              }
                            },
                            child: SizedBox(
                              height: double.infinity,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    height: 34,
                                    child: Center(
                                      child: i == 3
                                          ? Badge(
                                              isLabelVisible: saved.isNotEmpty,
                                              label: Text(
                                                '${saved.length}',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 8,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                              backgroundColor: const Color(
                                                0xFFD4A02C,
                                              ),
                                              offset: const Offset(4, -3),
                                              child: _buildBottomNavImage(
                                                outlineImage: item['outline']!,
                                                filledImage: item['filled']!,
                                                isSelected: isSelected,
                                              ),
                                            )
                                          : _buildBottomNavImage(
                                              outlineImage: item['outline']!,
                                              filledImage: item['filled']!,
                                              isSelected: isSelected,
                                            ),
                                    ),
                                  ),

                                  const SizedBox(height: 3),

                                  AnimatedDefaultTextStyle(
                                    duration: const Duration(milliseconds: 180),
                                    curve: Curves.easeOut,
                                    style: TextStyle(
                                      fontSize: 10.5,
                                      height: 1,
                                      fontWeight: isSelected
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                      color: isSelected
                                          ? const Color(0xFF8C1115)
                                          : const Color(0xFF655D58),
                                    ),
                                    child: Text(
                                      item['label']!,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavImage({
    required String outlineImage,
    required String filledImage,
    required bool isSelected,
  }) {
    final String currentImage = isSelected ? filledImage : outlineImage;

    return SizedBox(
      width: 24,
      height: 24,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 180),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.85, end: 1).animate(animation),
              child: child,
            ),
          );
        },
        child: Image.asset(
          currentImage,
          key: ValueKey<String>(currentImage),
          width: 24,
          height: 24,
          fit: BoxFit.contain,
          color: isSelected ? Colors.white : const Color(0xFF655D58),
          colorBlendMode: BlendMode.srcIn,
          gaplessPlayback: true,
          errorBuilder:
              (BuildContext context, Object error, StackTrace? stackTrace) {
                return Icon(
                  isSelected ? Icons.circle : Icons.circle_outlined,
                  key: ValueKey<String>('error-$currentImage'),
                  size: 22,
                  color: isSelected ? Colors.white : const Color(0xFF655D58),
                );
              },
        ),
      ),
    );
  }
}
