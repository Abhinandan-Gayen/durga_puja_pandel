import 'package:durga_puja_pandel/views/Users/bottom-navigationBar/controller/botom_navigation_controller.dart';
import 'package:durga_puja_pandel/views/admin/slider-image-post/controller/slider_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
import 'controllers/event_controller.dart';
import 'core/services/cloudinary_service.dart';
import 'core/services/firebase_auth_service.dart';
import 'core/services/firestore_service.dart';
import 'core/services/location_service.dart';
import 'core/services/map_service.dart';
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

  @override
  void initState() {
    super.initState();
    authController = AuthController(authService, firestoreService);

    // Setup listener to monitor auth state change and redirect using GetX
    authController.addListener(() {
      final route = Get.currentRoute;
      final isAdminPath = route.startsWith('/admin');
      final isAuthPath = {
        '/login',
        '/signup',
        '/forgot-password',
      }.contains(route);

      if (isAdminPath && !authController.isLoggedIn) {
        Get.offAllNamed('/login');
      } else if (isAdminPath && !authController.isAdmin) {
        Get.offAllNamed('/home');
      } else if (isAuthPath && authController.isLoggedIn) {
        Get.offAllNamed(authController.isAdmin ? '/admin' : '/home');
      }
    });

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
        ChangeNotifierProvider<AuthController>.value(value: authController),
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
        ChangeNotifierProvider(create: (_) => AppShellController()),
        ChangeNotifierProvider<SliderController>(
          create: (_) => SliderController(),
        ),
        ChangeNotifierProvider<EventController>(
          create: (_) => EventController(),
        ),
      ],
      child: Consumer<ThemeController>(
        builder: (context, themeController, _) {
          return GetMaterialApp(
            title: 'Pujo Pandal Guide',
            debugShowCheckedModeBanner: false,
            initialRoute: '/',
            getPages: AppRoutes.pages,
            // theme: AppTheme.lightTheme,
            // darkTheme: AppTheme.darkTheme,
            // themeMode: themeController.themeMode,

            // theme: ThemeData(
            //   brightness: Brightness.dark,
            //   scaffoldBackgroundColor: bg,
            //   colorScheme: const ColorScheme.dark(
            //     primary: gold,
            //     secondary: red,
            //   ),
            //   fontFamily: 'Arial',
            //   useMaterial3: true,
            // ),
          );
        },
      ),
    );
  }
}
