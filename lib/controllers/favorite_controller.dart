import 'dart:async';

import 'package:flutter/foundation.dart';

import '../core/services/firestore_service.dart';

class FavoriteController extends ChangeNotifier {
  FavoriteController(this._firestoreService);

  final FirestoreService _firestoreService;

  StreamSubscription<List<String>>? _subscription;
  String? _boundUid;
  final Set<String> _favoriteIds = {};

  bool isLoading = false;
  String? errorMessage;

  List<String> get favoriteIds => _favoriteIds.toList(growable: false);

  bool isFavorite(String pandalId) => _favoriteIds.contains(pandalId);

  void bindUser(String? uid) {
    if (_boundUid == uid) {
      return;
    }
    _boundUid = uid;
    _subscription?.cancel();
    _favoriteIds.clear();

    if (uid == null) {
      notifyListeners();
      return;
    }

    _subscription = _firestoreService
        .watchFavoritePandalIds(uid)
        .listen(
          (ids) {
            _favoriteIds
              ..clear()
              ..addAll(ids);
            notifyListeners();
          },
          onError: (Object error) {
            errorMessage = error.toString();
            notifyListeners();
          },
        );
  }

  Future<void> toggleFavorite({
    required String uid,
    required String pandalId,
  }) async {
    final wasFavorite = _favoriteIds.contains(pandalId);
    if (wasFavorite) {
      _favoriteIds.remove(pandalId);
    } else {
      _favoriteIds.add(pandalId);
    }
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      if (wasFavorite) {
        await _firestoreService.removeFavorite(uid: uid, pandalId: pandalId);
      } else {
        await _firestoreService.addFavorite(uid: uid, pandalId: pandalId);
      }
    } catch (error) {
      if (wasFavorite) {
        _favoriteIds.add(pandalId);
      } else {
        _favoriteIds.remove(pandalId);
      }
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
