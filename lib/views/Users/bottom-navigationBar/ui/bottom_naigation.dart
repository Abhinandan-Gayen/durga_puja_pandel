import 'package:durga_puja_pandel/views/Users/Explore.dart';
import 'package:durga_puja_pandel/views/Users/dashbord.dart';
import 'package:durga_puja_pandel/views/Users/favoutiry.dart';
import 'package:durga_puja_pandel/views/Users/map.dart';
import 'package:durga_puja_pandel/views/Users/bottom-navigationBar/controller/botom_navigation_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final AppShellController shellController = context
        .watch<AppShellController>();

    final int index = shellController.selectedIndex;
    final Set<int> saved = shellController.saved;

    final List<Widget> screens = [
      DurgaPujaHomeScreen(
        onMenuTap: () => _scaffoldKey.currentState?.openDrawer(),
      ),

      ExploreScreen(saved: saved, onSaved: shellController.toggleSaved),

      const CardScreen(),

      FavouritesScreen(saved: saved, onSaved: shellController.toggleSaved),
    ];

    return Scaffold(
      key: _scaffoldKey,
      extendBody: true,
      drawer: _buildDrawer(shellController),
      backgroundColor: const Color(0xFFE50914),
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

  Widget _buildDrawer(AppShellController shellController) {
    const Color primaryRed = Color(0xFFE50914);
    const Color cream = Color(0xFFFFF8E9);
    final double drawerWidth = (MediaQuery.sizeOf(context).width * 0.80).clamp(
      280.0,
      360.0,
    );
    final items = <({IconData icon, String label, int index})>[
      (icon: Icons.home_rounded, label: 'Home', index: 0),
      (icon: Icons.explore_rounded, label: 'Explore', index: 1),
      (icon: Icons.map_rounded, label: 'Map', index: 2),
      (icon: Icons.bookmark_rounded, label: 'Saved', index: 3),
    ];

    return Drawer(
      width: drawerWidth,
      backgroundColor: cream,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(28)),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(22, 26, 22, 24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFD71319), Color(0xFF8C1115)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 27,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.temple_hindu_rounded,
                      color: primaryRed,
                      size: 31,
                    ),
                  ),
                  SizedBox(height: 14),
                  Text(
                    'Durga Puja Pandal',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'Explore Kolkata’s best pandals',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            ...items.map((item) {
              final bool selected = shellController.selectedIndex == item.index;
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 3,
                ),
                child: ListTile(
                  selected: selected,
                  selectedTileColor: primaryRed.withValues(alpha: 0.10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  leading: Icon(
                    item.icon,
                    color: selected ? primaryRed : const Color(0xFF554A45),
                  ),
                  title: Text(
                    item.label,
                    style: TextStyle(
                      color: selected ? primaryRed : const Color(0xFF362F2B),
                      fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                    ),
                  ),
                  trailing: selected
                      ? const Icon(Icons.circle, color: primaryRed, size: 8)
                      : null,
                  onTap: () {
                    Navigator.of(context).pop();
                    shellController.setIndex(item.index);
                  },
                ),
              );
            }),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Divider(color: Color(0xFFE5D4C5)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                leading: const Icon(
                  Icons.admin_panel_settings_rounded,
                  color: primaryRed,
                ),
                title: const Text(
                  'Admin',
                  style: TextStyle(
                    color: primaryRed,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                trailing: const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: primaryRed,
                  size: 15,
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  Get.toNamed('/login');
                },
              ),
            ),
            const Spacer(),
            const Padding(
              padding: EdgeInsets.only(bottom: 24),
              child: Text(
                'Durga Puja Pandal Guide',
                style: TextStyle(color: Color(0xFF93847C), fontSize: 11),
              ),
            ),
          ],
        ),
      ),
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
