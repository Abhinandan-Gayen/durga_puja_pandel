import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../controllers/pandal_controller.dart';
import '../../core/theme/normal_color.dart';
import '../widgets/pandel.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key, required this.saved, required this.onSaved});

  final Set<int> saved;
  final ValueChanged<int> onSaved;

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<PandalController>();
    final query = _query.trim().toLowerCase();
    final result = controller.pandals.where((pandal) {
      if (query.isEmpty) return true;
      return pandal.name.toLowerCase().contains(query) ||
          pandal.area.toLowerCase().contains(query) ||
          pandal.city.toLowerCase().contains(query) ||
          pandal.address.toLowerCase().contains(query) ||
          pandal.description.toLowerCase().contains(query);
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E9),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE50914),
        elevation: 3,
        shadowColor: Colors.black.withValues(alpha: 0.15),
        centerTitle: true,
        title: const Text(
          'Explore Pandals',
          style: TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Color(0xFFE50914),
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
          systemNavigationBarColor: Colors.white,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
      ),
      body: RefreshIndicator(
        onRefresh: controller.fetchActivePandals,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 90),
          children: [
            TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _query = value),
              decoration: InputDecoration(
                hintText: 'Search pandal or area...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: query.isEmpty
                    ? null
                    : IconButton(
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _query = '');
                        },
                        icon: const Icon(Icons.close_rounded),
                      ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: const BorderSide(color: border),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('${result.length} pandals found'),
            const SizedBox(height: 12),
            if (controller.isLoading && controller.pandals.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 80),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (result.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 80),
                child: Center(child: Text('No matching pandal found')),
              )
            else
              ...result.map((pandal) {
                final index = controller.pandals.indexOf(pandal);
                final imageUrl = pandal.thumbnailUrl.isNotEmpty
                    ? pandal.thumbnailUrl
                    : pandal.images.isNotEmpty
                    ? pandal.images.first
                    : '';
                final tilePandal = Pandal(
                  pandal.name,
                  pandal.name,
                  pandal.area,
                  '',
                  pandal.averageRating.toStringAsFixed(1),
                  pandal.crowdLevel,
                  pandal.themeName,
                  imageUrl,
                  pandal.latitude,
                  pandal.longitude,
                );

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Opacity(
                    opacity: pandal.isActive ? 1 : 0.42,
                    child: IgnorePointer(
                      ignoring: !pandal.isActive,
                      child: GestureDetector(
                        onTap: () => Get.toNamed('/pandal/${pandal.id}'),
                        child: PandalTile(
                          pandal: tilePandal,
                          compact: true,
                          saved: widget.saved.contains(index),
                          onSaved: () => widget.onSaved(index),
                        ),
                      ),
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}
