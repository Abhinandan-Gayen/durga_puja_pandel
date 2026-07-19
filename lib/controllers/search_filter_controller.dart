import 'package:flutter/foundation.dart';

import '../core/constants/app_constants.dart';
import '../models/pandal_model.dart';

class SearchFilterController extends ChangeNotifier {
  String query = '';
  String city = AppConstants.defaultCity;
  String crowdLevel = 'Any';

  void setQuery(String value) {
    query = value;
    notifyListeners();
  }

  void setCity(String value) {
    city = value;
    notifyListeners();
  }

  void setCrowdLevel(String value) {
    crowdLevel = value;
    notifyListeners();
  }

  List<PandalModel> apply(List<PandalModel> pandals) {
    final normalizedQuery = query.trim().toLowerCase();
    return pandals.where((pandal) {
      final matchesQuery =
          normalizedQuery.isEmpty ||
          pandal.name.toLowerCase().contains(normalizedQuery) ||
          pandal.area.toLowerCase().contains(normalizedQuery) ||
          pandal.themeName.toLowerCase().contains(normalizedQuery) ||
          pandal.organizerName.toLowerCase().contains(normalizedQuery) ||
          pandal.nearbyTransport.any(
            (transport) => transport.toLowerCase().contains(normalizedQuery),
          );
      final matchesCity = city == 'All' || pandal.city == city;
      final matchesCrowd =
          crowdLevel == 'Any' || pandal.crowdLevel == crowdLevel;
      return matchesQuery && matchesCity && matchesCrowd;
    }).toList();
  }
}
