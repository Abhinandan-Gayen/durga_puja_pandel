import 'package:flutter/material.dart';

class CardScreen extends StatefulWidget {
  const CardScreen({super.key});

  @override
  State<CardScreen> createState() => _CardScreenState();
}

class _CardScreenState extends State<CardScreen> {
  final PageController _pageController = PageController(viewportFraction: 0.88);

  int currentCardIndex = 0;

  final List<Map<String, dynamic>> pandals = [
    {
      'title': 'Sreebhumi Sporting Club',
      'location': 'Lake Town, Kolkata',
      'distance': '5.2 km',
      'rating': '4.8',
      'ratingCount': '2.3K',
      'crowd': 'High',
      'status': 'Open',
      'closingTime': 'Closes 11:30 PM',
      'eta': '18 min',
      'image':
          'https://images.unsplash.com/photo-1609766857041-ed402ea8069a?w=500',
    },
    {
      'title': 'Suruchi Sangha',
      'location': 'New Alipore, Kolkata',
      'distance': '2.4 km',
      'rating': '4.7',
      'ratingCount': '1.8K',
      'crowd': 'Moderate',
      'status': 'Open',
      'closingTime': 'Closes 12:00 AM',
      'eta': '12 min',
      'image':
          'https://images.unsplash.com/photo-1582510003544-4d00b7f74220?w=500',
    },
    {
      'title': 'Santosh Mitra Square',
      'location': 'Entally, Kolkata',
      'distance': '3.8 km',
      'rating': '4.9',
      'ratingCount': '3.1K',
      'crowd': 'Very High',
      'status': 'Open',
      'closingTime': 'Closes 1:00 AM',
      'eta': '22 min',
      'image':
          'https://images.unsplash.com/photo-1561361513-2d000a50f0dc?w=500',
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ================= MAP BACKGROUND =================
          Positioned.fill(
            child: Image.asset(
              'assets/images/map_background.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: const Color(0xFFF3EBDD),
                  child: CustomPaint(painter: MapBackgroundPainter()),
                );
              },
            ),
          ),

          // ================= MAP ROUTE =================
          Positioned.fill(
            child: IgnorePointer(child: CustomPaint(painter: RoutePainter())),
          ),

          // ================= MAP MARKERS =================
          const Positioned(top: 130, left: 65, child: MapMarker()),

          const Positioned(top: 180, right: 60, child: MapMarker()),

          const Positioned(top: 250, left: 125, child: MapMarker()),

          const Positioned(top: 330, right: 85, child: MapMarker()),

          const Positioned(top: 390, left: 80, child: CurrentLocationMarker()),

          // ================= TOP APP BAR =================
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Container(
                height: 58,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: const BoxDecoration(
                  color: Color(0xFFB91419),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x26000000),
                      blurRadius: 8,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.of(context).maybePop();
                      },
                      icon: const Icon(
                        Icons.arrow_back_rounded,
                        color: Colors.white,
                      ),
                    ),

                    const Expanded(
                      child: Text(
                        'Map & Locations',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),

                    IconButton(
                      onPressed: () {
                        debugPrint('Filter clicked');
                      },
                      icon: const Icon(
                        Icons.filter_alt_outlined,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ================= RIGHT MAP BUTTONS =================
          Positioned(
            right: 14,
            top: 170,
            child: Column(
              children: [
                _buildMapActionButton(
                  icon: Icons.my_location_rounded,
                  onTap: () {
                    debugPrint('Current location clicked');
                  },
                ),

                const SizedBox(height: 10),

                _buildMapActionButton(
                  icon: Icons.layers_outlined,
                  onTap: () {
                    debugPrint('Map layer clicked');
                  },
                ),
              ],
            ),
          ),

          // ================= HORIZONTAL CARDS =================
          Positioned(
            left: 0,
            right: 0,
            bottom: 28,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 200,
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: pandals.length,
                    physics: const BouncingScrollPhysics(),
                    onPageChanged: (value) {
                      setState(() {
                        currentCardIndex = value;
                      });
                    },
                    itemBuilder: (context, index) {
                      final pandal = pandals[index];

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 6,
                        ),
                        child: MapPandalCard(
                          title: pandal['title'],
                          location: pandal['location'],
                          distance: pandal['distance'],
                          rating: pandal['rating'],
                          ratingCount: pandal['ratingCount'],
                          crowd: pandal['crowd'],
                          status: pandal['status'],
                          closingTime: pandal['closingTime'],
                          eta: pandal['eta'],
                          imageUrl: pandal['image'],
                          onFavourite: () {
                            debugPrint('${pandal['title']} favourite clicked');
                          },
                          onDirection: () {
                            debugPrint('${pandal['title']} direction clicked');
                          },
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 8),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(pandals.length, (index) {
                    final bool isSelected = index == currentCardIndex;

                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: isSelected ? 18 : 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFFB91419)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(color: Color(0x33000000), blurRadius: 3),
                        ],
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapActionButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(icon, color: const Color(0xFF665D58), size: 22),
        ),
      ),
    );
  }
}

// =========================================================
// PANDAL CARD
// =========================================================

class MapPandalCard extends StatelessWidget {
  final String title;
  final String location;
  final String distance;
  final String rating;
  final String ratingCount;
  final String crowd;
  final String status;
  final String closingTime;
  final String eta;
  final String imageUrl;
  final VoidCallback onFavourite;
  final VoidCallback onDirection;

  const MapPandalCard({
    super.key,
    required this.title,
    required this.location,
    required this.distance,
    required this.rating,
    required this.ratingCount,
    required this.crowd,
    required this.status,
    required this.closingTime,
    required this.eta,
    required this.imageUrl,
    required this.onFavourite,
    required this.onDirection,
  });

  @override
  Widget build(BuildContext context) {
    const Color primaryRed = Color(0xFFB91419);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFCF7),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFEBDCCC)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.network(
                  imageUrl,
                  width: 82,
                  height: 90,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 82,
                      height: 90,
                      color: primaryRed,
                      child: const Icon(
                        Icons.temple_hindu,
                        color: Colors.white,
                        size: 42,
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(width: 12),

              // Information
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFF29231F),
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),

                        InkWell(
                          onTap: onFavourite,
                          borderRadius: BorderRadius.circular(20),
                          child: const Padding(
                            padding: EdgeInsets.all(3),
                            child: Icon(
                              Icons.bookmark_border_rounded,
                              color: primaryRed,
                              size: 21,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          color: Color(0xFFFFB300),
                          size: 16,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '$rating ($ratingCount)',
                          style: const TextStyle(
                            color: Color(0xFF625952),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const SizedBox(width: 8),

                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFEEE6),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.local_fire_department_outlined,
                                color: Color(0xFFE9673F),
                                size: 12,
                              ),
                              SizedBox(width: 3),
                              Text(
                                'Popular',
                                style: TextStyle(
                                  color: Color(0xFFE9673F),
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 7),

                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          color: Color(0xFF7E746E),
                          size: 15,
                        ),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            location,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFF746B65),
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 7),

                    Row(
                      children: [
                        const Icon(
                          Icons.circle,
                          color: Color(0xFF42A846),
                          size: 8,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          status,
                          style: const TextStyle(
                            color: Color(0xFF42A846),
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          '• $closingTime',
                          style: const TextStyle(
                            color: Color(0xFF6C625C),
                            fontSize: 9,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          // const SizedBox(height: 10),

          // Container(
          //   padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 12),
          //   decoration: BoxDecoration(
          //     color: const Color(0xFFFFF7EC),
          //     borderRadius: BorderRadius.circular(14),
          //     border: Border.all(color: const Color(0xFFF0E3D4)),
          //   ),
          //   child: Row(
          //     children: [
          //       Expanded(
          //         child: _buildInfoItem(
          //           icon: Icons.directions_car_outlined,
          //           label: 'ETA',
          //           value: eta,
          //           subValue: distance,
          //         ),
          //       ),

          //       Container(width: 1, height: 33, color: const Color(0xFFE7D9CA)),

          //       Expanded(
          //         child: _buildInfoItem(
          //           icon: Icons.groups_2_outlined,
          //           label: 'Crowd',
          //           value: crowd,
          //           valueColor: primaryRed,
          //           subValue: 'Expect Delay',
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
          const SizedBox(height: 10),

          SizedBox(
            width: double.infinity,
            height: 40,
            child: ElevatedButton.icon(
              onPressed: onDirection,
              icon: const Icon(
                Icons.near_me_outlined,
                color: Colors.white,
                size: 17,
              ),
              label: const Text(
                'Directions',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryRed,
                elevation: 3,
                shadowColor: primaryRed.withOpacity(0.35),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
    required String subValue,
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: const Color(0xFF5E554F), size: 21),

        const SizedBox(width: 8),

        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(color: Color(0xFF8A817A), fontSize: 9),
            ),
            Text(
              value,
              style: TextStyle(
                color: valueColor ?? const Color(0xFF332D29),
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              subValue,
              style: const TextStyle(color: Color(0xFF8A817A), fontSize: 8),
            ),
          ],
        ),
      ],
    );
  }
}

// =========================================================
// MAP MARKER
// =========================================================

class MapMarker extends StatelessWidget {
  const MapMarker({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 42,
      height: 52,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Icon(
            Icons.location_on,
            color: Color(0xFFB91419),
            size: 46,
            shadows: [
              Shadow(
                color: Colors.black38,
                blurRadius: 5,
                offset: Offset(0, 3),
              ),
            ],
          ),
          Positioned(
            top: 9,
            child: Icon(Icons.temple_hindu, color: Colors.white, size: 17),
          ),
        ],
      ),
    );
  }
}

class CurrentLocationMarker extends StatelessWidget {
  const CurrentLocationMarker({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: const Color(0xFF1689E8),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 4),
        boxShadow: const [BoxShadow(color: Color(0x55000000), blurRadius: 6)],
      ),
    );
  }
}

// =========================================================
// DUMMY MAP BACKGROUND PAINTER
// =========================================================

class MapBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final roadPaint = Paint()
      ..color = Colors.white.withOpacity(0.9)
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke;

    final smallRoadPaint = Paint()
      ..color = Colors.white.withOpacity(0.65)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    for (double y = 70; y < size.height; y += 90) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y + 40), roadPaint);
    }

    for (double x = 30; x < size.width; x += 80) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x + 30, size.height),
        smallRoadPaint,
      );
    }

    final riverPaint = Paint()
      ..color = const Color(0xFF8ED5EE)
      ..strokeWidth = 38
      ..style = PaintingStyle.stroke;

    final riverPath = Path()
      ..moveTo(size.width * 0.75, 0)
      ..cubicTo(
        size.width * 0.55,
        size.height * 0.3,
        size.width * 0.95,
        size.height * 0.5,
        size.width * 0.62,
        size.height,
      );

    canvas.drawPath(riverPath, riverPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

// =========================================================
// ROUTE PAINTER
// =========================================================

class RoutePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint routePaint = Paint()
      ..color = const Color(0xFFD52B2F)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final Path routePath = Path()
      ..moveTo(size.width * 0.23, size.height * 0.46)
      ..cubicTo(
        size.width * 0.30,
        size.height * 0.40,
        size.width * 0.38,
        size.height * 0.48,
        size.width * 0.48,
        size.height * 0.39,
      )
      ..cubicTo(
        size.width * 0.58,
        size.height * 0.30,
        size.width * 0.66,
        size.height * 0.36,
        size.width * 0.74,
        size.height * 0.25,
      );

    canvas.drawPath(routePath, routePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
