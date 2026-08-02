import 'package:cloud_firestore/cloud_firestore.dart';

class SliderModel {
  const SliderModel({
    required this.id,
    required this.imageUrl,
    required this.isActive,
    this.createdAt,
  });

  final String id;
  final String imageUrl;
  final bool isActive;
  final DateTime? createdAt;

  factory SliderModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final Map<String, dynamic> data = document.data() ?? {};

    return SliderModel(
      id: document.id,
      imageUrl: data['imageUrl']?.toString() ?? '',
      isActive: data['isActive'] as bool? ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}