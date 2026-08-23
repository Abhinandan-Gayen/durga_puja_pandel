import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../controllers/admin_pandal_controller.dart';
import '../../models/pandal_model.dart';
import '../widgets/empty_widget.dart';
import '../widgets/loading_widget.dart';

class ManageSlidersScreen extends StatefulWidget {
  const ManageSlidersScreen({super.key});

  @override
  State<ManageSlidersScreen> createState() => _ManageSlidersScreenState();
}

class _ManageSlidersScreenState extends State<ManageSlidersScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  bool _hasRequestedData = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_hasRequestedData) return;
    _hasRequestedData = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<AdminPandalController>().fetchAllSliderPandals();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage slider pandals')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed('/admin/add-slider-pandal'),
        child: const Icon(Icons.add),
      ),
      body: Consumer<AdminPandalController>(
        builder: (context, admin, _) {
          final pandals = _filteredPandals(admin.adminSliders);

          if (admin.isLoading && admin.adminSliders.isEmpty) {
            return const LoadingWidget(message: 'Loading slider pandals');
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: 'Search by name, area, city',
                  ),
                  onChanged: (value) => setState(() => _query = value),
                ),
              ),
              if (admin.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: Text(
                    admin.errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              Expanded(
                child: pandals.isEmpty
                    ? const EmptyWidget(
                        title: 'No slider pandals',
                        message: 'Create or search for another slider pandal listing.',
                      )
                    : RefreshIndicator(
                        onRefresh: admin.fetchAllSliderPandals,
                        child: ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 88),
                          itemBuilder: (context, index) {
                            final pandal = pandals[index];
                            return _AdminSliderTile(pandal: pandal);
                          },
                          separatorBuilder: (_, _) => const SizedBox(height: 8),
                          itemCount: pandals.length,
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  List<PandalModel> _filteredPandals(List<PandalModel> pandals) {
    final normalizedQuery = _query.trim().toLowerCase();
    if (normalizedQuery.isEmpty) {
      return pandals;
    }
    return pandals.where((pandal) {
      return pandal.name.toLowerCase().contains(normalizedQuery) ||
          pandal.area.toLowerCase().contains(normalizedQuery) ||
          pandal.city.toLowerCase().contains(normalizedQuery);
    }).toList();
  }
}

class _AdminSliderTile extends StatelessWidget {
  const _AdminSliderTile({required this.pandal});

  final PandalModel pandal;

  @override
  Widget build(BuildContext context) {
    final admin = context.read<AdminPandalController>();
    final isUpdatingActive = admin.isUpdatingActive(pandal.id);
    final isUpdatingFeatured = admin.isUpdatingFeatured(pandal.id);
    final isUpdatingStatus = isUpdatingActive || isUpdatingFeatured;

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          children: [
            ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox.square(
                  dimension: 58,
                  child: pandal.thumbnailUrl.trim().isEmpty
                      ? Container(color: Colors.grey.shade300, child: const Icon(Icons.image))
                      : Image.network(
                          pandal.thumbnailUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Container(color: Colors.grey.shade300, child: const Icon(Icons.image)),
                        ),
                ),
              ),
              title: Text(pandal.name),
              subtitle: Text('${pandal.area}, ${pandal.city}'),
              trailing: Wrap(
                spacing: 4,
                children: [
                  IconButton(
                    tooltip: 'Edit',
                    onPressed: () => Get.toNamed(
                      '/admin/edit-slider-pandal/${pandal.id}',
                    ),
                    icon: const Icon(Icons.edit_outlined),
                  ),
                  IconButton(
                    tooltip: 'Delete',
                    onPressed: () => _confirmDelete(context, admin, pandal),
                    icon: const Icon(Icons.delete_outline),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            SwitchListTile(
              value: pandal.isActive,
              title: Text(pandal.isActive ? 'Active' : 'Inactive'),
              secondary: isUpdatingActive
                  ? const SizedBox.square(
                      dimension: 22,
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    )
                  : const Icon(Icons.power_settings_new),
              onChanged: isUpdatingStatus
                  ? null
                  : (value) => admin.toggleSliderActiveStatus(pandal, value),
            ),
            SwitchListTile(
              value: pandal.isFeatured,
              title: Text(pandal.isFeatured ? 'Featured' : 'Not featured'),
              secondary: isUpdatingFeatured
                  ? const SizedBox.square(
                      dimension: 22,
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    )
                  : const Icon(Icons.star_border),
              onChanged: isUpdatingStatus
                  ? null
                  : (value) => admin.toggleSliderFeaturedStatus(pandal, value),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, AdminPandalController admin, PandalModel pandal) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Slider Pandal'),
          content: Text('Are you sure you want to delete "${pandal.name}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await admin.deleteSliderPandal(pandal.id);
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
