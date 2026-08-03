import 'package:flutter/foundation.dart';

import '../core/constants/firebase_constants.dart';
import '../core/services/cloudinary_service.dart';
import '../core/services/firestore_service.dart';
import '../models/media_model.dart';
import '../models/pandal_model.dart';
import '../services/pandal_api_service.dart';

class AdminPandalController extends ChangeNotifier {
  AdminPandalController(this._firestoreService, this._cloudinaryService);

  final FirestoreService _firestoreService;
  final CloudinaryService _cloudinaryService;

  bool isLoading = false;
  String? errorMessage;
  MediaModel? lastUploadedMedia;
  List<PandalModel> adminPandals = [];
  String? _updatingPandalId;
  String? _updatingStatusField;

  bool _isFetching = false;

  int get totalPandals => adminPandals.length;
  int get activePandals =>
      adminPandals.where((pandal) => pandal.isActive).length;
  int get featuredPandals =>
      adminPandals.where((pandal) => pandal.isFeatured).length;
  int get totalReviews =>
      adminPandals.fold<int>(0, (sum, pandal) => sum + pandal.totalReviews);

  bool isUpdatingActive(String pandalId) =>
      _updatingPandalId == pandalId && _updatingStatusField == 'isActive';

  bool isUpdatingFeatured(String pandalId) =>
      _updatingPandalId == pandalId && _updatingStatusField == 'isFeatured';

  Future<String?> addPandal(PandalModel pandal) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      final response = await PandalApiService.createPandal(
        name: pandal.name,
        description: pandal.description,
        district: pandal.city,
        address: pandal.address,
        imageUrl: pandal.thumbnailUrl,
        latitude: pandal.latitude != 0.0 ? pandal.latitude : null,
        longitude: pandal.longitude != 0.0 ? pandal.longitude : null,
      );
      await _fetchAll();
      return response['data']?['id'] as String?;
    } catch (error) {
      errorMessage = error.toString();
      return null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> createPandal({
    required String name,
    required String description,
    required String district,
    required String address,
    required String imageUrl,
    double? latitude,
    double? longitude,
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final response = await PandalApiService.createPandal(
        name: name,
        description: description,
        district: district,
        address: address,
        imageUrl: imageUrl,
        latitude: latitude,
        longitude: longitude,
      );

      await _fetchAll();

      return response;
    } catch (error) {
      errorMessage = error.toString();
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updatePandal(PandalModel pandal) async {
    await _guardRun<void>(() async {
      await _firestoreService.updateDocument(
        collectionPath: FirebaseConstants.pandalsCollection,
        documentId: pandal.id,
        data: _visibleFormFields(pandal),
      );
      await _fetchAll();
    });
  }

  Future<void> deletePandal(String pandalId) async {
    await _guardRun<void>(() async {
      await _firestoreService.deleteDocument(
        collectionPath: FirebaseConstants.pandalsCollection,
        documentId: pandalId,
      );
      adminPandals.removeWhere((pandal) => pandal.id == pandalId);
      notifyListeners();
    });
  }

  Future<void> fetchAllPandalsForAdmin() async {
    if (_isFetching) return;
    await _guardRun<void>(() => _fetchAll());
  }

  Future<void> toggleActiveStatus(PandalModel pandal, bool isActive) async {
    _setUpdatingStatus(pandal.id, 'isActive');
    try {
      await _guardRun<void>(() async {
        await _firestoreService.updateDocument(
          collectionPath: FirebaseConstants.pandalsCollection,
          documentId: pandal.id,
          data: {'isActive': isActive},
        );
        await _fetchAll();
      });
    } finally {
      _clearUpdatingStatus();
    }
  }

  Future<void> toggleFeaturedStatus(
    PandalModel pandal,
    bool isFeatured,
  ) async {
    _setUpdatingStatus(pandal.id, 'isFeatured');
    try {
      await _guardRun<void>(() async {
        await _firestoreService.updateDocument(
          collectionPath: FirebaseConstants.pandalsCollection,
          documentId: pandal.id,
          data: {'isFeatured': isFeatured},
        );
        await _fetchAll();
      });
    } finally {
      _clearUpdatingStatus();
    }
  }

  void _setUpdatingStatus(String pandalId, String field) {
    _updatingPandalId = pandalId;
    _updatingStatusField = field;
    notifyListeners();
  }

  void _clearUpdatingStatus() {
    _updatingPandalId = null;
    _updatingStatusField = null;
    notifyListeners();
  }

  Future<MediaModel?> uploadMedia({
    required Uint8List bytes,
    required String fileName,
    required String mediaType,
  }) async {
    return _guardRun<MediaModel?>(
      () => _uploadSingle(bytes: bytes, fileName: fileName, mediaType: mediaType),
    );
  }

  Future<String?> savePandal(PandalModel pandal) async {
    if (pandal.id.isEmpty) {
      return addPandal(pandal);
    }
    await updatePandal(pandal);
    return pandal.id;
  }

  Future<MediaModel> _uploadSingle({
    required Uint8List bytes,
    required String fileName,
    required String mediaType,
  }) async {
    final media = await _cloudinaryService.uploadMedia(
      bytes: bytes,
      fileName: fileName,
      mediaType: mediaType,
    );
    lastUploadedMedia = media;
    return media;
  }

  Future<void> _fetchAll() async {
    _isFetching = true;
    final data = await _firestoreService.getCollection(
      collectionPath: FirebaseConstants.pandalsCollection,
    );
    adminPandals = data.map(PandalModel.fromMap).toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    _isFetching = false;
  }

  Map<String, dynamic> _visibleFormFields(
    PandalModel pandal, {
    bool isCreating = false,
  }) {
    return {
      'name': pandal.name,
      'description': pandal.description,
      'area': pandal.city,
      'address': pandal.address,
      'latitude': pandal.latitude,
      'longitude': pandal.longitude,
      'thumbnailUrl': pandal.thumbnailUrl,
      'images': pandal.images,
      'videos': pandal.videos,
      'isActive': isCreating ? true : pandal.isActive,
      'isFeatured': isCreating ? false : pandal.isFeatured,
    };
  }

  Future<T?> _guardRun<T>(Future<T> Function() action) async {
    isLoading = true;
    errorMessage = null;
    Future.microtask(notifyListeners);
    try {
      return await action();
    } catch (error) {
      errorMessage = error.toString();
      return null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
