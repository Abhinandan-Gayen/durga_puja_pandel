import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/event_model.dart';

class EventController extends ChangeNotifier {
  EventController({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance {
    listenToEvents();
  }

  final FirebaseFirestore _firestore;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _eventSubscription;

  final List<EventModel> _events = [];
  List<EventModel> get events => List.unmodifiable(_events);

  bool isLoading = false;
  bool isUploading = false;
  String? errorMessage;
  bool _disposed = false;

  CollectionReference<Map<String, dynamic>> get _eventCollection {
    return _firestore.collection('events');
  }

  void listenToEvents() {
    isLoading = true;
    errorMessage = null;
    _safeNotifyListeners();

    _eventSubscription?.cancel();
    _eventSubscription = _eventCollection
        .orderBy('createdAt', descending: false)
        .snapshots()
        .listen(
      (QuerySnapshot<Map<String, dynamic>> snapshot) {
        final now = DateTime.now();
        final todayStart = DateTime(now.year, now.month, now.day);
        final List<EventModel> activeList = [];

        for (final doc in snapshot.docs) {
          final event = EventModel.fromFirestore(doc);
          final eventDate = event.eventDate ?? _reconstructEventDate(event);

          if (eventDate.isBefore(todayStart)) {
            // Delete expired event from database
            deleteEvent(event.id);
          } else {
            activeList.add(event);
          }
        }

        _events
          ..clear()
          ..addAll(activeList);
        isLoading = false;
        errorMessage = null;
        _safeNotifyListeners();
      },
      onError: (Object error) {
        isLoading = false;
        errorMessage = error.toString();
        debugPrint('Events listener error: $error');
        _safeNotifyListeners();
      },
    );
  }

  DateTime _reconstructEventDate(EventModel event) {
    final now = DateTime.now();
    const monthAbbreviations = [
      'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN',
      'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC',
    ];
    final monthIndex = monthAbbreviations.indexOf(event.month.toUpperCase());
    final month = monthIndex >= 0 ? monthIndex + 1 : now.month;
    final day = int.tryParse(event.date) ?? now.day;
    return DateTime(now.year, month, day);
  }

  Future<bool> addEvent({
    required String month,
    required String date,
    required String title,
    required String subtitle,
    required String time,
    required DateTime eventDate,
    bool notification = true,
  }) async {
    final String cleanMonth = month.trim();
    final String cleanDate = date.trim();
    final String cleanTitle = title.trim();

    if (cleanMonth.isEmpty || cleanDate.isEmpty || cleanTitle.isEmpty) {
      errorMessage = 'Month, Date and Title cannot be empty.';
      _safeNotifyListeners();
      return false;
    }

    isUploading = true;
    errorMessage = null;
    _safeNotifyListeners();

    try {
      await _eventCollection.add({
        'month': cleanMonth.toUpperCase(),
        'date': cleanDate,
        'title': cleanTitle,
        'subtitle': subtitle.trim(),
        'time': time.trim(),
        'notification': notification,
        'eventDate': Timestamp.fromDate(eventDate),
        'createdAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (error) {
      errorMessage = error.toString();
      return false;
    } finally {
      isUploading = false;
      _safeNotifyListeners();
    }
  }

  Future<bool> deleteEvent(String id) async {
    try {
      await _eventCollection.doc(id).delete();
      return true;
    } catch (error) {
      errorMessage = error.toString();
      _safeNotifyListeners();
      return false;
    }
  }

  Future<bool> updateEvent({
    required String id,
    required String month,
    required String date,
    required String title,
    required String subtitle,
    required String time,
    required bool notification,
    required DateTime eventDate,
  }) async {
    try {
      await _eventCollection.doc(id).update({
        'month': month.trim().toUpperCase(),
        'date': date.trim(),
        'title': title.trim(),
        'subtitle': subtitle.trim(),
        'time': time.trim(),
        'notification': notification,
        'eventDate': Timestamp.fromDate(eventDate),
      });
      return true;
    } catch (error) {
      errorMessage = error.toString();
      _safeNotifyListeners();
      return false;
    }
  }

  void _safeNotifyListeners() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _eventSubscription?.cancel();
    super.dispose();
  }
}
