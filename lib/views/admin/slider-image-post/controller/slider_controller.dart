import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:durga_puja_pandel/models/pandal_model.dart';
import 'package:durga_puja_pandel/views/admin/slider-image-post/model/slider_model.dart';
import 'package:flutter/foundation.dart';

class SliderController extends ChangeNotifier {
  SliderController({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance {
    listenToSliders();
    listenToSliderPandals();
  }

  final FirebaseFirestore _firestore;

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _sliderSubscription;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _sliderPandalSubscription;

  final List<SliderModel> _sliders = [];
  final List<PandalModel> _sliderPandals = [];

  List<SliderModel> get sliders => List.unmodifiable(_sliders);
  List<PandalModel> get sliderPandals => List.unmodifiable(_sliderPandals);

  bool isLoading = false;
  bool isUploading = false;

  String? errorMessage;
  String? lastUploadedUrl;

  bool _disposed = false;

  CollectionReference<Map<String, dynamic>> get _sliderCollection {
    return _firestore.collection('slider');
  }

  void listenToSliders() {
    isLoading = true;
    errorMessage = null;
    _safeNotifyListeners();

    _sliderSubscription?.cancel();

    _sliderSubscription = _sliderCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen(
          (QuerySnapshot<Map<String, dynamic>> snapshot) {
            _sliders
              ..clear()
              ..addAll(
                snapshot.docs
                    .map(SliderModel.fromFirestore)
                    .where(
                      (SliderModel slider) => slider.imageUrl.trim().isNotEmpty,
                    ),
              );

            isLoading = false;
            errorMessage = null;
            _safeNotifyListeners();
          },
          onError: (Object error) {
            isLoading = false;
            errorMessage = _getFirebaseErrorMessage(error);

            debugPrint('Slider listener error: $error');

            _safeNotifyListeners();
          },
        );
  }

  Future<bool> addSliderImage(String imageUrl) async {
    if (isUploading) {
      return false;
    }

    final String inputUrl = imageUrl.trim();

    if (inputUrl.isEmpty) {
      errorMessage = 'Image URL লিখুন।';
      _safeNotifyListeners();
      return false;
    }

    final Uri? inputUri = Uri.tryParse(inputUrl);

    if (inputUri == null ||
        !inputUri.isAbsolute ||
        !(inputUri.scheme == 'http' || inputUri.scheme == 'https')) {
      errorMessage = 'একটি valid HTTP অথবা HTTPS image URL দিন।';
      _safeNotifyListeners();
      return false;
    }

    // Google Drive share URL হলে thumbnail URL-এ convert হবে।
    final String convertedUrl = convertGoogleDriveUrl(
      inputUrl,
      imageWidth: 1600,
    );

    final Uri? convertedUri = Uri.tryParse(convertedUrl);

    if (convertedUri == null ||
        !convertedUri.isAbsolute ||
        !(convertedUri.scheme == 'http' || convertedUri.scheme == 'https')) {
      errorMessage = 'Image URL convert করা যায়নি।';
      _safeNotifyListeners();
      return false;
    }

    isUploading = true;
    errorMessage = null;
    lastUploadedUrl = null;
    _safeNotifyListeners();

    try {
      await _sliderCollection.add({
        'imageUrl': convertedUrl,
        'originalUrl': inputUrl,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      });

      lastUploadedUrl = convertedUrl;

      debugPrint('Slider image added successfully: $convertedUrl');

      return true;
    } on FirebaseException catch (error) {
      errorMessage = _getFirebaseErrorMessage(error);

      debugPrint(
        'Slider upload Firebase error: '
        '${error.code} - ${error.message}',
      );

      return false;
    } catch (error, stackTrace) {
      errorMessage = 'Slider image add করা যায়নি।';

      debugPrint('Slider upload error: $error');
      debugPrintStack(stackTrace: stackTrace);

      return false;
    } finally {
      isUploading = false;
      _safeNotifyListeners();
    }
  }

  String convertGoogleDriveUrl(String url, {int imageWidth = 1000}) {
    final String cleanUrl = url.trim();

    final Uri? uri = Uri.tryParse(cleanUrl);

    if (uri == null) {
      return cleanUrl;
    }

    // Google Drive URL না হলে original URL-ই return করবে।
    final bool isGoogleDriveUrl =
        uri.host.contains('drive.google.com') ||
        uri.host.contains('docs.google.com');

    if (!isGoogleDriveUrl) {
      return cleanUrl;
    }

    String? fileId;

    // Example:
    // https://drive.google.com/file/d/FILE_ID/view
    final RegExp filePattern = RegExp(r'/file/d/([^/?]+)');

    final RegExpMatch? fileMatch = filePattern.firstMatch(cleanUrl);

    if (fileMatch != null) {
      fileId = fileMatch.group(1);
    }

    // Example:
    // https://drive.google.com/open?id=FILE_ID
    // https://drive.google.com/uc?id=FILE_ID
    // https://drive.google.com/thumbnail?id=FILE_ID
    fileId ??= uri.queryParameters['id'];

    if (fileId == null || fileId.trim().isEmpty) {
      return cleanUrl;
    }

    return 'https://drive.google.com/thumbnail'
        '?id=${Uri.encodeQueryComponent(fileId.trim())}'
        '&sz=w$imageWidth';
  }

  Future<bool> deleteSlider(String documentId) async {
    if (documentId.trim().isEmpty) {
      errorMessage = 'Slider document ID পাওয়া যায়নি।';
      _safeNotifyListeners();
      return false;
    }

    errorMessage = null;
    _safeNotifyListeners();

    try {
      await _sliderCollection.doc(documentId).delete();

      if (lastUploadedUrl != null) {
        final bool stillAvailable = _sliders.any(
          (SliderModel slider) => slider.imageUrl == lastUploadedUrl,
        );

        if (!stillAvailable) {
          lastUploadedUrl = null;
        }
      }

      return true;
    } on FirebaseException catch (error) {
      errorMessage = _getFirebaseErrorMessage(error);
      return false;
    } catch (error) {
      errorMessage = 'Slider delete করা যায়নি।';
      return false;
    } finally {
      _safeNotifyListeners();
    }
  }

  Future<bool> updateSliderStatus({
    required String documentId,
    required bool isActive,
  }) async {
    if (documentId.trim().isEmpty) {
      errorMessage = 'Slider document ID পাওয়া যায়নি।';
      _safeNotifyListeners();
      return false;
    }

    errorMessage = null;
    _safeNotifyListeners();

    try {
      await _sliderCollection.doc(documentId).update({
        'isActive': isActive,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return true;
    } on FirebaseException catch (error) {
      errorMessage = _getFirebaseErrorMessage(error);
      return false;
    } catch (error) {
      errorMessage = 'Slider status update করা যায়নি।';
      return false;
    } finally {
      _safeNotifyListeners();
    }
  }

  void clearError() {
    errorMessage = null;
    _safeNotifyListeners();
  }

  String _getFirebaseErrorMessage(Object error) {
    if (error is FirebaseException) {
      switch (error.code) {
        case 'permission-denied':
          return 'Firestore permission denied. '
              'Security Rules check করুন।';

        case 'unavailable':
          return 'Firebase server unavailable। '
              'Internet check করুন।';

        case 'not-found':
          return 'Slider document পাওয়া যায়নি।';

        case 'failed-precondition':
          return 'Firestore query-এর জন্য '
              'index প্রয়োজন হতে পারে.';

        default:
          return error.message ?? 'Firebase operation failed.';
      }
    }

    return 'কোনো সমস্যা হয়েছে। আবার চেষ্টা করুন।';
  }

  void _safeNotifyListeners() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  void listenToSliderPandals() {
    _sliderPandalSubscription?.cancel();
    _sliderPandalSubscription = _firestore
        .collection('slider_pandals')
        .snapshots()
        .listen(
          (QuerySnapshot<Map<String, dynamic>> snapshot) {
            _sliderPandals
              ..clear()
              ..addAll(snapshot.docs.map(PandalModel.fromFirestore));
            _safeNotifyListeners();
          },
          onError: (Object error) {
            debugPrint('Slider pandals listener error: $error');
          },
        );
  }

  @override
  void dispose() {
    _disposed = true;
    _sliderSubscription?.cancel();
    _sliderPandalSubscription?.cancel();
    super.dispose();
  }
}
