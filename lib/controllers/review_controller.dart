import 'package:flutter/foundation.dart';

import '../core/services/firestore_service.dart';
import '../models/review_model.dart';

class ReviewController extends ChangeNotifier {
  ReviewController(this._firestoreService);

  final FirestoreService _firestoreService;

  bool isLoading = false;
  String? errorMessage;

  Stream<List<ReviewModel>> reviewsForPandal(String pandalId) {
    return _firestoreService.watchReviews(pandalId);
  }

  Future<void> addReview(ReviewModel review) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      await _firestoreService.addReview(review);
    } catch (error) {
      errorMessage = error.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
