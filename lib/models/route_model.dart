import 'package:cloud_firestore/cloud_firestore.dart';

import 'pandal_model.dart';

class RouteModel {
  const RouteModel({
    required this.selectedPandals,
    required this.totalDistance,
    this.createdAt,
  });

  final List<PandalModel> selectedPandals;
  final double totalDistance;
  final DateTime? createdAt;

  factory RouteModel.fromMap(Map<String, dynamic> map) {
    final pandals = (map['selectedPandals'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map((pandal) => PandalModel.fromMap(pandal))
        .toList();

    return RouteModel(
      selectedPandals: pandals,
      totalDistance: (map['totalDistance'] as num?)?.toDouble() ?? 0,
      createdAt: _dateFromValue(map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'selectedPandals': selectedPandals
          .map((pandal) => pandal.toMap())
          .toList(),
      'totalDistance': totalDistance,
      'createdAt': createdAt == null
          ? FieldValue.serverTimestamp()
          : Timestamp.fromDate(createdAt!),
    };
  }

  RouteModel copyWith({
    List<PandalModel>? selectedPandals,
    double? totalDistance,
    DateTime? createdAt,
  }) {
    return RouteModel(
      selectedPandals: selectedPandals ?? this.selectedPandals,
      totalDistance: totalDistance ?? this.totalDistance,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  static DateTime? _dateFromValue(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is DateTime) {
      return value;
    }
    return null;
  }
}
