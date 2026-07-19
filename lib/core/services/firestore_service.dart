import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/pandal_model.dart';
import '../../models/review_model.dart';
import '../../models/user_model.dart';
import '../constants/firebase_constants.dart';

class FirestoreService {
  FirestoreService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection(FirebaseConstants.usersCollection);

  CollectionReference<Map<String, dynamic>> get _pandals =>
      _firestore.collection(FirebaseConstants.pandalsCollection);

  CollectionReference<Map<String, dynamic>> get _reviews =>
      _firestore.collection(FirebaseConstants.reviewsCollection);

  CollectionReference<Map<String, dynamic>> _userFavorites(String uid) =>
      _firestore
          .collection(FirebaseConstants.favoritesCollection)
          .doc(uid)
          .collection(FirebaseConstants.userFavoritesCollection);

  CollectionReference<Map<String, dynamic>> _collection(String collectionPath) {
    return _firestore.collection(collectionPath);
  }

  Future<String> addDocument({
    required String collectionPath,
    required Map<String, dynamic> data,
    String? documentId,
  }) async {
    final doc = documentId == null
        ? _collection(collectionPath).doc()
        : _collection(collectionPath).doc(documentId);
    await doc.set({...data, 'id': doc.id}, SetOptions(merge: true));
    return doc.id;
  }

  Future<void> updateDocument({
    required String collectionPath,
    required String documentId,
    required Map<String, dynamic> data,
  }) {
    return _collection(
      collectionPath,
    ).doc(documentId).set(data, SetOptions(merge: true));
  }

  Future<void> deleteDocument({
    required String collectionPath,
    required String documentId,
  }) {
    return _collection(collectionPath).doc(documentId).delete();
  }

  Future<Map<String, dynamic>?> getDocument({
    required String collectionPath,
    required String documentId,
  }) async {
    final doc = await _collection(collectionPath).doc(documentId).get();
    return doc.data();
  }

  Future<List<Map<String, dynamic>>> getCollection({
    required String collectionPath,
  }) async {
    final snapshot = await _collection(collectionPath).get();
    return snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
  }

  Stream<List<Map<String, dynamic>>> streamCollection({
    required String collectionPath,
  }) {
    return _collection(collectionPath).snapshots().map(
      (snapshot) =>
          snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList(),
    );
  }

  Stream<UserModel?> watchUser(String uid) {
    return _users.doc(uid).snapshots().map((doc) {
      if (!doc.exists) {
        return null;
      }
      return UserModel.fromFirestore(doc);
    });
  }

  Future<UserModel?> fetchUser(String uid) async {
    final doc = await _users.doc(uid).get();
    if (!doc.exists) {
      return null;
    }
    return UserModel.fromFirestore(doc);
  }

  Future<void> createUserProfile(UserModel user) {
    return _users.doc(user.uid).set(user.toMap(), SetOptions(merge: true));
  }

  Stream<List<String>> watchFavoritePandalIds(String uid) {
    return _userFavorites(uid).snapshots().map(
      (snapshot) => snapshot.docs.map((doc) => doc.id).toList(),
    );
  }

  Future<void> addFavorite({required String uid, required String pandalId}) {
    return _userFavorites(uid).doc(pandalId).set({
      'pandalId': pandalId,
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> removeFavorite({required String uid, required String pandalId}) {
    return _userFavorites(uid).doc(pandalId).delete();
  }

  Stream<List<PandalModel>> watchPandals() {
    return _pandals
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map(PandalModel.fromFirestore).toList(),
        );
  }

  Stream<PandalModel?> watchPandal(String pandalId) {
    return _pandals.doc(pandalId).snapshots().map((doc) {
      if (!doc.exists) {
        return null;
      }
      return PandalModel.fromFirestore(doc);
    });
  }

  Future<String> createPandal(PandalModel pandal) async {
    final doc = _pandals.doc();
    await doc.set(pandal.copyWith(id: doc.id).toMap());
    return doc.id;
  }

  Future<void> updatePandal(PandalModel pandal) {
    return _pandals.doc(pandal.id).set(pandal.toMap(), SetOptions(merge: true));
  }

  Future<void> deletePandal(String pandalId) {
    return _pandals.doc(pandalId).delete();
  }

  Stream<List<ReviewModel>> watchReviews(String pandalId) {
    return _reviews
        .where('pandalId', isEqualTo: pandalId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map(ReviewModel.fromFirestore).toList(),
        );
  }

  Future<void> addReview(ReviewModel review) async {
    final doc = _reviews.doc();
    await doc.set(review.copyWith(id: doc.id).toMap());
  }
}
