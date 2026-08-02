import 'package:cloud_firestore/cloud_firestore.dart';

class PandalModel {
  const PandalModel({
    required this.id,
    required this.name,
    required this.description,
    required this.area,
    required this.city,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.themeName,
    required this.organizerName,
    required this.openingTime,
    required this.closingTime,
    required this.entryFee,
    required this.crowdLevel,
    required this.isFeatured,
    required this.isActive,
    required this.averageRating,
    required this.totalReviews,
    required this.thumbnailUrl,
    required this.images,
    required this.videos,
    required this.nearbyTransport,
    required this.parkingAvailable,
    required this.createdBy,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String name;
  final String description;
  final String area;
  final String city;
  final String address;
  final double latitude;
  final double longitude;
  final String themeName;
  final String organizerName;
  final String openingTime;
  final String closingTime;
  final double entryFee;
  final String crowdLevel;
  final bool isFeatured;
  final bool isActive;
  final double averageRating;
  final int totalReviews;
  final String thumbnailUrl;
  final List<String> images;
  final List<String> videos;
  final List<String> nearbyTransport;
  final bool parkingAvailable;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String createdBy;

  factory PandalModel.empty() {
    return const PandalModel(
      id: '',
      name: '',
      description: '',
      area: '',
      city: 'Kolkata',
      address: '',
      latitude: 22.5726,
      longitude: 88.3639,
      themeName: '',
      organizerName: '',
      openingTime: '',
      closingTime: '',
      entryFee: 0,
      crowdLevel: 'medium',
      isFeatured: false,
      isActive: true,
      averageRating: 0,
      totalReviews: 0,
      thumbnailUrl: '',
      images: [],
      videos: [],
      nearbyTransport: [],
      parkingAvailable: false,
      createdBy: '',
    );
  }

  factory PandalModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    return PandalModel.fromMap(doc.data() ?? {}, id: doc.id);
  }

  factory PandalModel.fromMap(Map<String, dynamic> map, {String? id}) {
    return PandalModel(
      id: id ?? map['id'] as String? ?? '',
      name: map['name'] as String? ?? '',
      description: map['description'] as String? ?? '',
      area: map['area'] as String? ?? '',
      city: map['city'] as String? ?? map['area'] as String? ?? 'Kolkata',
      address: map['address'] as String? ?? '',
      latitude: (map['latitude'] as num?)?.toDouble() ?? 22.5726,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 88.3639,
      themeName: map['themeName'] as String? ?? '',
      organizerName: map['organizerName'] as String? ?? '',
      openingTime: map['openingTime'] as String? ?? '',
      closingTime: map['closingTime'] as String? ?? '',
      entryFee: (map['entryFee'] as num?)?.toDouble() ?? 0,
      crowdLevel: map['crowdLevel'] as String? ?? 'medium',
      isFeatured: map['isFeatured'] as bool? ?? false,
      isActive: map['isActive'] as bool? ?? true,
      averageRating: (map['averageRating'] as num?)?.toDouble() ?? 0,
      totalReviews: (map['totalReviews'] as num?)?.toInt() ?? 0,
      thumbnailUrl: map['thumbnailUrl'] as String? ?? '',
      images: List<String>.from(map['images'] as List<dynamic>? ?? const []),
      videos: List<String>.from(map['videos'] as List<dynamic>? ?? const []),
      nearbyTransport: List<String>.from(
        map['nearbyTransport'] as List<dynamic>? ?? const [],
      ),
      parkingAvailable: map['parkingAvailable'] as bool? ?? false,
      createdAt: _dateFromValue(map['createdAt']),
      updatedAt: _dateFromValue(map['updatedAt']),
      createdBy: map['createdBy'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'area': area,
      'city': city,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'themeName': themeName,
      'organizerName': organizerName,
      'openingTime': openingTime,
      'closingTime': closingTime,
      'entryFee': entryFee,
      'crowdLevel': crowdLevel,
      'isFeatured': isFeatured,
      'isActive': isActive,
      'averageRating': averageRating,
      'totalReviews': totalReviews,
      'thumbnailUrl': thumbnailUrl,
      'images': images,
      'videos': videos,
      'nearbyTransport': nearbyTransport,
      'parkingAvailable': parkingAvailable,
      'createdAt': createdAt == null
          ? FieldValue.serverTimestamp()
          : Timestamp.fromDate(createdAt!),
      'updatedAt': updatedAt == null
          ? FieldValue.serverTimestamp()
          : Timestamp.fromDate(updatedAt!),
      'createdBy': createdBy,
    };
  }

  PandalModel copyWith({
    String? id,
    String? name,
    String? description,
    String? area,
    String? city,
    String? address,
    double? latitude,
    double? longitude,
    String? themeName,
    String? organizerName,
    String? openingTime,
    String? closingTime,
    double? entryFee,
    String? crowdLevel,
    bool? isFeatured,
    bool? isActive,
    double? averageRating,
    int? totalReviews,
    String? thumbnailUrl,
    List<String>? images,
    List<String>? videos,
    List<String>? nearbyTransport,
    bool? parkingAvailable,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
  }) {
    return PandalModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      area: area ?? this.area,
      city: city ?? this.city,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      themeName: themeName ?? this.themeName,
      organizerName: organizerName ?? this.organizerName,
      openingTime: openingTime ?? this.openingTime,
      closingTime: closingTime ?? this.closingTime,
      entryFee: entryFee ?? this.entryFee,
      crowdLevel: crowdLevel ?? this.crowdLevel,
      isFeatured: isFeatured ?? this.isFeatured,
      isActive: isActive ?? this.isActive,
      averageRating: averageRating ?? this.averageRating,
      totalReviews: totalReviews ?? this.totalReviews,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      images: images ?? this.images,
      videos: videos ?? this.videos,
      nearbyTransport: nearbyTransport ?? this.nearbyTransport,
      parkingAvailable: parkingAvailable ?? this.parkingAvailable,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
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
