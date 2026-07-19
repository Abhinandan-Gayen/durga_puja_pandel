import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../controllers/admin_pandal_controller.dart';
import '../../routes/route_names.dart';
import '../widgets/loading_widget.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  bool _hasRequestedData = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_hasRequestedData) {
      return;
    }
    _hasRequestedData = true;
    context.read<AdminPandalController>().fetchAllPandalsForAdmin();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin dashboard')),
      body: Consumer<AdminPandalController>(
        builder: (context, admin, _) {
          if (admin.isLoading && admin.adminPandals.isEmpty) {
            return const LoadingWidget(message: 'Loading admin dashboard');
          }

          return RefreshIndicator(
            onRefresh: admin.fetchAllPandalsForAdmin,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (admin.errorMessage != null) ...[
                  _ErrorBanner(message: admin.errorMessage!),
                  const SizedBox(height: 12),
                ],
                GridView.count(
                  crossAxisCount: MediaQuery.sizeOf(context).width > 700
                      ? 4
                      : 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.35,
                  children: [
                    _StatCard(
                      icon: Icons.temple_hindu,
                      label: 'Total pandals',
                      value: '${admin.totalPandals}',
                    ),
                    _StatCard(
                      icon: Icons.check_circle_outline,
                      label: 'Active pandals',
                      value: '${admin.activePandals}',
                    ),
                    _StatCard(
                      icon: Icons.star_border,
                      label: 'Featured pandals',
                      value: '${admin.featuredPandals}',
                    ),
                    _StatCard(
                      icon: Icons.rate_review_outlined,
                      label: 'Total reviews',
                      value: '${admin.totalReviews}',
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  'Quick actions',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                _QuickAction(
                  icon: Icons.add_location_alt,
                  label: 'Add Pandal',
                  onTap: () => context.pushNamed(RouteNames.addPandal),
                ),
                _QuickAction(
                  icon: Icons.edit_location_alt,
                  label: 'Manage Pandals',
                  onTap: () => context.pushNamed(RouteNames.managePandals),
                ),
                _QuickAction(
                  icon: Icons.map_outlined,
                  label: 'View Map',
                  onTap: () => context.pushNamed(RouteNames.map),
                ),
                _QuickAction(
                  icon: Icons.cloud_upload_outlined,
                  label: 'Upload Media',
                  onTap: () => context.pushNamed(RouteNames.uploadMedia),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            Text(value, style: Theme.of(context).textTheme.headlineSmall),
            Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(label),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
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
