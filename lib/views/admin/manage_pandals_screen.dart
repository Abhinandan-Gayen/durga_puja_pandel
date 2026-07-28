import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../controllers/admin_pandal_controller.dart';
import '../../models/pandal_model.dart';
import '../../routes/route_names.dart';
import '../widgets/empty_widget.dart';
import '../widgets/loading_widget.dart';

class ManagePandalsScreen extends StatefulWidget {
  const ManagePandalsScreen({super.key});

  @override
  State<ManagePandalsScreen> createState() => _ManagePandalsScreenState();
}

class _ManagePandalsScreenState extends State<ManagePandalsScreen> {
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
      context.read<AdminPandalController>().fetchAllPandalsForAdmin();
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
      appBar: AppBar(title: const Text('Manage pandals')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.pushNamed(RouteNames.addPandal),
        child: const Icon(Icons.add),
      ),
      body: Consumer<AdminPandalController>(
        builder: (context, admin, _) {
          final pandals = _filteredPandals(admin.adminPandals);

          if (admin.isLoading && admin.adminPandals.isEmpty) {
            return const LoadingWidget(message: 'Loading pandals');
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
                  child: _ErrorBanner(message: admin.errorMessage!),
                ),
              Expanded(
                child: pandals.isEmpty
                    ? const EmptyWidget(
                        title: 'No pandals',
                        message: 'Create or search for another pandal listing.',
                      )
                    : RefreshIndicator(
                        onRefresh: admin.fetchAllPandalsForAdmin,
                        child: ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 88),
                          itemBuilder: (context, index) {
                            final pandal = pandals[index];
                            return _AdminPandalTile(pandal: pandal);
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

class _AdminPandalTile extends StatelessWidget {
  const _AdminPandalTile({required this.pandal});

  final PandalModel pandal;

  @override
  Widget build(BuildContext context) {
    final admin = context.read<AdminPandalController>();

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          children: [
            ListTile(
              title: Text(pandal.name),
              subtitle: Text('${pandal.area}, ${pandal.city}'),
              trailing: Wrap(
                spacing: 4,
                children: [
                  IconButton(
                    tooltip: 'Edit',
                    onPressed: () => context.pushNamed(
                      RouteNames.editPandal,
                      pathParameters: {'id': pandal.id},
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
              secondary: const Icon(Icons.power_settings_new),
              onChanged: (_) => admin.toggleActiveStatus(pandal),
            ),
            SwitchListTile(
              value: pandal.isFeatured,
              title: Text(pandal.isFeatured ? 'Featured' : 'Not featured'),
              secondary: const Icon(Icons.star_border),
              onChanged: (_) => admin.toggleFeaturedStatus(pandal),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    AdminPandalController admin,
    PandalModel pandal,
  ) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete pandal?'),
          content: Text('This will remove ${pandal.name}.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
    if (shouldDelete == true) {
      await admin.deletePandal(pandal.id);
    }
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.errorContainer,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Text(
          message,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onErrorContainer,
          ),
        ),
      ),
    );
  }
}
