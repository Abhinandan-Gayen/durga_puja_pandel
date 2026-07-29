import 'package:durga_puja_pandel/core/theme/normal_color.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'controllers/admin_pandal_controller.dart';
import 'controllers/auth_controller.dart';
import 'controllers/favorite_controller.dart';
import 'controllers/location_controller.dart';
import 'controllers/map_controller.dart';
import 'controllers/pandal_controller.dart';
import 'controllers/review_controller.dart';
import 'controllers/search_filter_controller.dart';
import 'controllers/theme_controller.dart';
import 'core/services/cloudinary_service.dart';
import 'core/services/firebase_auth_service.dart';
import 'core/services/firestore_service.dart';
import 'core/services/location_service.dart';
import 'core/services/map_service.dart';
import 'core/theme/app_theme.dart';
import 'routes/app_routes.dart';

class PujoPandalGuideApp extends StatefulWidget {
  const PujoPandalGuideApp({super.key});

  @override
  State<PujoPandalGuideApp> createState() => _PujoPandalGuideAppState();
}

// class _PujoPandalGuideAppState extends State<PujoPandalGuideApp> {
//   late final ThemeController _themeController;

//   @override
//   void initState() {
//     super.initState();
//     _themeController = ThemeController();
//     _themeController.load();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final firestoreService = FirestoreService();
//     final authService = FirebaseAuthService();
//     final cloudinaryService = CloudinaryService();
//     final locationService = LocationService();
//     final mapService = MapService();

class _PujoPandalGuideAppState extends State<PujoPandalGuideApp> {
  late final ThemeController _themeController;
  final firestoreService = FirestoreService();
  final authService = FirebaseAuthService();
  final cloudinaryService = CloudinaryService();
  final locationService = LocationService();
  final mapService = MapService();

  late final AuthController authController;
  late final GoRouter router;

  @override
  void initState() {
    super.initState();
    authController = AuthController(authService, firestoreService);
    router = AppRoutes.createRouter(authController);
    _themeController = ThemeController();
    _themeController.load();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<FirebaseAuthService>.value(value: authService),
        Provider<FirestoreService>.value(value: firestoreService),
        Provider<CloudinaryService>.value(value: cloudinaryService),
        Provider<LocationService>.value(value: locationService),
        Provider<MapService>.value(value: mapService),
        ChangeNotifierProvider<ThemeController>.value(value: _themeController),
        ChangeNotifierProvider(
          create: (_) => AuthController(authService, firestoreService),
        ),
        ChangeNotifierProvider(
          create: (_) => PandalController(firestoreService)..watchPandals(),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              AdminPandalController(firestoreService, cloudinaryService),
        ),
        ChangeNotifierProvider(
          create: (_) => LocationController(locationService)..loadLocation(),
        ),
        ChangeNotifierProvider(
          create: (_) => ReviewController(firestoreService),
        ),
        ChangeNotifierProxyProvider<AuthController, FavoriteController>(
          create: (_) => FavoriteController(firestoreService),
          update: (_, auth, favoriteController) {
            final controller =
                favoriteController ?? FavoriteController(firestoreService);
            controller.bindUser(auth.firebaseUser?.uid);
            return controller;
          },
        ),
        ChangeNotifierProvider(create: (_) => SearchFilterController()),
        ChangeNotifierProvider(
          create: (_) => MapController(mapService, locationService),
        ),
      ],
      child: Consumer2<AuthController, ThemeController>(
        builder: (context, authController, themeController, _) {
          final router = AppRoutes.createRouter(authController);

          return MaterialApp.router(
            title: 'Pujo Pandal Guide',
            debugShowCheckedModeBanner: false,
            // theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeController.themeMode,
            routerConfig: router,

            theme: ThemeData(
              brightness: Brightness.dark,
              scaffoldBackgroundColor: bg,
              colorScheme: const ColorScheme.dark(
                primary: gold,
                secondary: red,
              ),
              fontFamily: 'Arial',
              useMaterial3: true,
            ),
          );
        },
      ),
    );
  }
}
