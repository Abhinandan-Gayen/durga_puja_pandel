import 'package:flutter/foundation.dart';

import '../core/constants/firebase_constants.dart';
import '../core/services/cloudinary_service.dart';
import '../core/services/firestore_service.dart';
import '../models/media_model.dart';
import '../models/pandal_model.dart';

class AdminPandalController extends ChangeNotifier {
  AdminPandalController(this._firestoreService, this._cloudinaryService);

  final FirestoreService _firestoreService;
  final CloudinaryService _cloudinaryService;

  bool isLoading = false;
  String? errorMessage;
  MediaModel? lastUploadedMedia;
  List<PandalModel> adminPandals = [];

  bool _isFetching = false;

  int get totalPandals => adminPandals.length;
  int get activePandals =>
      adminPandals.where((pandal) => pandal.isActive).length;
  int get featuredPandals =>
      adminPandals.where((pandal) => pandal.isFeatured).length;
  int get totalReviews =>
      adminPandals.fold<int>(0, (sum, pandal) => sum + pandal.totalReviews);

  Future<String?> addPandal(PandalModel pandal) async {
    return _guardRun<String?>(() async {
      final id = await _firestoreService.addDocument(
        collectionPath: FirebaseConstants.pandalsCollection,
        data: pandal.toMap(),
      );
      await _fetchAll();
      return id;
    });
  }

  Future<void> updatePandal(PandalModel pandal) async {
    await _guardRun<void>(() async {
      await _firestoreService.updateDocument(
        collectionPath: FirebaseConstants.pandalsCollection,
        documentId: pandal.id,
        data: pandal.toMap(),
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

  Future<void> toggleActiveStatus(PandalModel pandal) async {
    await updatePandal(pandal.copyWith(isActive: !pandal.isActive));
  }

  Future<void> toggleFeaturedStatus(PandalModel pandal) async {
    await updatePandal(pandal.copyWith(isFeatured: !pandal.isFeatured));
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

  Future<T?> _guardRun<T>(Future<T> Function() action) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
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
