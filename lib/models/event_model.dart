import 'package:cloud_firestore/cloud_firestore.dart';

class EventModel {
  final String id;
  final String month;
  final String date;
  final String title;
  final String subtitle;
  final String time;
  final DateTime? createdAt;

  EventModel({
    required this.id,
    required this.month,
    required this.date,
    required this.title,
    required this.subtitle,
    required this.time,
    this.createdAt,
  });

  factory EventModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return EventModel(
      id: doc.id,
      month: data['month'] ?? '',
      date: data['date'] ?? '',
      title: data['title'] ?? '',
      subtitle: data['subtitle'] ?? '',
      time: data['time'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'month': month,
      'date': date,
      'title': title,
      'subtitle': subtitle,
      'time': time,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
    };
  }
}
