import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

import '../core/constants/firebase_constants.dart';
import '../core/services/firestore_service.dart';
import '../core/utils/distance_helper.dart';
import '../models/pandal_model.dart';

class PandalController extends ChangeNotifier {
  PandalController(this._firestoreService);

  final FirestoreService _firestoreService;
  StreamSubscription<List<PandalModel>>? _subscription;

  List<PandalModel> pandals = [];
  List<PandalModel> activePandals = [];
  List<PandalModel> featuredPandals = [];
  List<PandalModel> popularPandals = [];
  List<PandalModel> nearbyPandals = [];
  List<PandalModel> searchResults = [];
  List<PandalModel> filteredPandals = [];
  bool isLoading = true;
  String? errorMessage;

  void watchPandals() {
    _subscription?.cancel();
    isLoading = true;
    notifyListeners();

    _subscription = _firestoreService.watchPandals().listen(
      (items) {
        pandals = items;
        activePandals = _activeFrom(items);
        featuredPandals = _featuredFrom(activePandals);
        popularPandals = _popularFrom(activePandals);
        filteredPandals = activePandals;
        isLoading = false;
        errorMessage = null;
        notifyListeners();
      },
      onError: (Object error) {
        errorMessage = error.toString();
        isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<void> fetchActivePandals() async {
    await _run(() async {
      final data = await _firestoreService.getCollection(
        collectionPath: FirebaseConstants.pandalsCollection,
      );
      pandals = data.map(PandalModel.fromMap).toList();
      activePandals = _activeFrom(pandals);
      filteredPandals = activePandals;
    });
  }

  Future<void> fetchFeaturedPandals() async {
    await _run(() async {
      await _ensureActivePandalsLoaded();
      featuredPandals = _featuredFrom(activePandals);
    });
  }

  Future<void> fetchPopularPandals() async {
    await _run(() async {
      await _ensureActivePandalsLoaded();
      popularPandals = _popularFrom(activePandals);
    });
  }

  Future<void> fetchNearbyPandals(
    Position? userPosition, {
    double radiusKm = 10,
  }) async {
    await _run(() async {
      await _ensureActivePandalsLoaded();
      if (userPosition == null) {
        nearbyPandals = [];
        return;
      }
      nearbyPandals =
          [...activePandals]
              .where(
                (pandal) =>
                    calculateDistanceFromUser(pandal, userPosition) <= radiusKm,
              )
              .toList()
            ..sort(
              (a, b) => calculateDistanceFromUser(
                a,
                userPosition,
              ).compareTo(calculateDistanceFromUser(b, userPosition)),
            );
    });
  }

  List<PandalModel> searchPandals(String query) {
    final normalizedQuery = query.trim().toLowerCase();
    if (normalizedQuery.isEmpty) {
      searchResults = activePandals;
    } else {
      searchResults = activePandals.where((pandal) {
        return pandal.name.toLowerCase().contains(normalizedQuery) ||
            pandal.area.toLowerCase().contains(normalizedQuery) ||
            pandal.city.toLowerCase().contains(normalizedQuery) ||
            pandal.themeName.toLowerCase().contains(normalizedQuery);
      }).toList();
    }
    notifyListeners();
    return searchResults;
  }

  List<PandalModel> filterPandals({
    String? query,
    double? maxDistanceKm,
    double? minRating,
    String? crowdLevel,
    String? area,
    bool openNow = false,
    bool featured = false,
    String sortBy = 'newest',
    Position? userPosition,
  }) {
    var results = [...activePandals];
    final normalizedQuery = query?.trim().toLowerCase() ?? '';

    if (normalizedQuery.isNotEmpty) {
      results = results.where((pandal) {
        return pandal.name.toLowerCase().contains(normalizedQuery) ||
            pandal.area.toLowerCase().contains(normalizedQuery) ||
            pandal.city.toLowerCase().contains(normalizedQuery) ||
            pandal.themeName.toLowerCase().contains(normalizedQuery);
      }).toList();
    }
    if (maxDistanceKm != null && userPosition != null) {
      results = results
          .where(
            (pandal) =>
                calculateDistanceFromUser(pandal, userPosition) <=
                maxDistanceKm,
          )
          .toList();
    }
    if (minRating != null) {
      results = results
          .where((pandal) => pandal.averageRating >= minRating)
          .toList();
    }
    if (crowdLevel != null && crowdLevel.isNotEmpty && crowdLevel != 'any') {
      results = results
          .where((pandal) => pandal.crowdLevel == crowdLevel)
          .toList();
    }
    if (area != null && area.trim().isNotEmpty) {
      final normalizedArea = area.trim().toLowerCase();
      results = results
          .where((pandal) => pandal.area.toLowerCase().contains(normalizedArea))
          .toList();
    }
    if (openNow) {
      results = results.where(isOpenNow).toList();
    }
    if (featured) {
      results = results.where((pandal) => pandal.isFeatured).toList();
    }

    _sortPandals(results, sortBy, userPosition);
    filteredPandals = results;
    return filteredPandals;
  }

  PandalModel? getPandalById(String id) {
    for (final pandal in pandals) {
      if (pandal.id == id) {
        return pandal;
      }
    }
    return null;
  }

  PandalModel? findById(String id) => getPandalById(id);

  double calculateDistanceFromUser(PandalModel pandal, Position? userPosition) {
    if (userPosition == null) {
      return 0;
    }
    return DistanceHelper.distanceInKm(
      startLatitude: userPosition.latitude,
      startLongitude: userPosition.longitude,
      endLatitude: pandal.latitude,
      endLongitude: pandal.longitude,
    );
  }

  bool isOpenNow(PandalModel pandal) {
    final opening = _parseTime(pandal.openingTime);
    final closing = _parseTime(pandal.closingTime);
    if (opening == null || closing == null) {
      return false;
    }

    final now = DateTime.now();
    final start = DateTime(
      now.year,
      now.month,
      now.day,
      opening.hour,
      opening.minute,
    );
    var end = DateTime(
      now.year,
      now.month,
      now.day,
      closing.hour,
      closing.minute,
    );
    if (end.isBefore(start)) {
      end = end.add(const Duration(days: 1));
    }
    return now.isAfter(start) && now.isBefore(end);
  }

  Future<void> _ensureActivePandalsLoaded() async {
    if (activePandals.isNotEmpty || pandals.isNotEmpty) {
      activePandals = _activeFrom(pandals);
      return;
    }
    final data = await _firestoreService.getCollection(
      collectionPath: FirebaseConstants.pandalsCollection,
    );
    pandals = data.map(PandalModel.fromMap).toList();
    activePandals = _activeFrom(pandals);
  }

  List<PandalModel> _activeFrom(List<PandalModel> items) {
    return items.where((pandal) => pandal.isActive).toList();
  }

  List<PandalModel> _featuredFrom(List<PandalModel> items) {
    return items.where((pandal) => pandal.isFeatured).toList();
  }

  List<PandalModel> _popularFrom(List<PandalModel> items) {
    return [...items]..sort((a, b) {
      final ratingCompare = b.averageRating.compareTo(a.averageRating);
      if (ratingCompare != 0) {
        return ratingCompare;
      }
      return b.totalReviews.compareTo(a.totalReviews);
    });
  }

  void _sortPandals(
    List<PandalModel> results,
    String sortBy,
    Position? userPosition,
  ) {
    switch (sortBy) {
      case 'nearest':
        if (userPosition != null) {
          results.sort(
            (a, b) => calculateDistanceFromUser(
              a,
              userPosition,
            ).compareTo(calculateDistanceFromUser(b, userPosition)),
          );
        }
      case 'highest_rating':
        results.sort((a, b) => b.averageRating.compareTo(a.averageRating));
      case 'low_crowd':
        const crowdOrder = {'low': 0, 'medium': 1, 'high': 2};
        results.sort(
          (a, b) => (crowdOrder[a.crowdLevel] ?? 9).compareTo(
            crowdOrder[b.crowdLevel] ?? 9,
          ),
        );
      case 'newest':
      default:
        results.sort((a, b) {
          final aDate = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          final bDate = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          return bDate.compareTo(aDate);
        });
    }
  }

  _PandalTime? _parseTime(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return null;
    }

    for (final format in ['HH:mm', 'H:mm', 'h:mm a', 'h a']) {
      try {
        final parsed = DateFormat(format).parseStrict(trimmed.toUpperCase());
        return _PandalTime(parsed.hour, parsed.minute);
      } catch (_) {
        // Try the next common admin-entered time format.
      }
    }
    return null;
  }

  Future<void> _run(Future<void> Function() action) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      await action();
    } catch (error) {
      errorMessage = error.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

class _PandalTime {
  const _PandalTime(this.hour, this.minute);

  final int hour;
  final int minute;
}
