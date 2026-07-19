import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/location_controller.dart';
import '../../controllers/pandal_controller.dart';
import '../../core/constants/app_constants.dart';
import '../../models/pandal_model.dart';
import '../widgets/empty_widget.dart';
import '../widgets/pandal_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _queryController = TextEditingController();
  String _city = 'All';
  String _crowdLevel = 'any';

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<PandalController>();
    final location = context.watch<LocationController>().currentPosition;
    final pandals = _results(controller);

    return Scaffold(
      appBar: AppBar(title: const Text('Search pandals')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _queryController,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: 'Search by name, area, city, theme',
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _city,
                        decoration: const InputDecoration(labelText: 'City'),
                        items: ['All', ...AppConstants.supportedCities]
                            .map(
                              (city) => DropdownMenuItem(
                                value: city,
                                child: Text(city),
                              ),
                            )
                            .toList(),
                        onChanged: (value) =>
                            setState(() => _city = value ?? 'All'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _crowdLevel,
                        decoration: const InputDecoration(labelText: 'Crowd'),
                        items: ['any', ...AppConstants.crowdLevels]
                            .map(
                              (level) => DropdownMenuItem(
                                value: level,
                                child: Text(level),
                              ),
                            )
                            .toList(),
                        onChanged: (value) =>
                            setState(() => _crowdLevel = value ?? 'any'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: pandals.isEmpty
                ? const EmptyWidget(
                    title: 'No matching pandals',
                    message: 'Try another city, keyword, or crowd level.',
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    itemBuilder: (context, index) {
                      final pandal = pandals[index];
                      return PandalCard(
                        pandal: pandal,
                        distanceKm: location == null
                            ? null
                            : controller.calculateDistanceFromUser(
                                pandal,
                                location,
                              ),
                      );
                    },
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemCount: pandals.length,
                  ),
          ),
        ],
      ),
    );
  }

  List<PandalModel> _results(PandalController controller) {
    final query = _queryController.text.trim().toLowerCase();
    return controller.activePandals.where((pandal) {
      final matchesQuery =
          query.isEmpty ||
          pandal.name.toLowerCase().contains(query) ||
          pandal.area.toLowerCase().contains(query) ||
          pandal.city.toLowerCase().contains(query) ||
          pandal.themeName.toLowerCase().contains(query);
      final matchesCity = _city == 'All' || pandal.city == _city;
      final matchesCrowd =
          _crowdLevel == 'any' || pandal.crowdLevel == _crowdLevel;
      return matchesQuery && matchesCity && matchesCrowd;
    }).toList();
  }
}
