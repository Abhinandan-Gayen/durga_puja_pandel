import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../controllers/admin_pandal_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../routes/route_names.dart';
import '../widgets/loading_widget.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  bool _hasRequestedData = false;
  late final AnimationController _animController;
  late final Animation<double> _fadeSlide;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeSlide = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_hasRequestedData) return;
    _hasRequestedData = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<AdminPandalController>().fetchAllPandalsForAdmin();
      _animController.forward();
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        elevation: 0,
        scrolledUnderElevation: 1,
      ),
      body: Consumer<AdminPandalController>(
        builder: (context, admin, _) {
          if (_animController.status != AnimationStatus.forward &&
              _animController.status != AnimationStatus.completed &&
              admin.adminPandals.isNotEmpty) {
            _animController.forward();
          }

          if (admin.isLoading && admin.adminPandals.isEmpty) {
            return const LoadingWidget(message: 'Loading dashboard');
          }

          return RefreshIndicator(
            onRefresh: admin.fetchAllPandalsForAdmin,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                _WelcomeHeader(
                  anim: _fadeSlide,
                  totalPandals: admin.totalPandals,
                ),
                const SizedBox(height: 20),
                if (admin.errorMessage != null) ...[
                  _ErrorBanner(message: admin.errorMessage!),
                  const SizedBox(height: 12),
                ],
                _StatGrid(
                  anim: _fadeSlide,
                  admin: admin,
                ),
                const SizedBox(height: 28),
                FadeTransition(
                  opacity: _fadeSlide,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.15),
                      end: Offset.zero,
                    ).animate(_fadeSlide),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 4, bottom: 12),
                          child: Text(
                            'Quick Actions',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        _QuickActionTile(
                          icon: Icons.add_location_alt_outlined,
                          label: 'Add New Pandal',
                          subtitle: 'Create a new pandal listing',
                          color: AppColors.deepRed,
                          onTap: () => context.pushNamed(RouteNames.addPandal),
                        ),
                        const SizedBox(height: 10),
                        _QuickActionTile(
                          icon: Icons.edit_note,
                          label: 'Manage Pandals',
                          subtitle: 'Edit, activate or feature listings',
                          color: AppColors.festiveOrange,
                          onTap: () => context.pushNamed(RouteNames.managePandals),
                        ),
                        const SizedBox(height: 10),
                        _QuickActionTile(
                          icon: Icons.explore_outlined,
                          label: 'View Map',
                          subtitle: 'Browse pandals on the map',
                          color: const Color(0xFF1565C0),
                          onTap: () => context.pushNamed(RouteNames.map),
                        ),
                        const SizedBox(height: 10),
                        _QuickActionTile(
                          icon: Icons.cloud_upload_outlined,
                          label: 'Upload Media',
                          subtitle: 'Upload images and videos to Cloudinary',
                          color: const Color(0xFF6A1B9A),
                          onTap: () => context.pushNamed(RouteNames.uploadMedia),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _WelcomeHeader extends StatelessWidget {
  const _WelcomeHeader({required this.anim, required this.totalPandals});

  final Animation<double> anim;
  final int totalPandals;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return FadeTransition(
      opacity: anim,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, -0.1),
          end: Offset.zero,
        ).animate(anim),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [AppColors.premiumDarkGradientStart, AppColors.premiumDarkGradientEnd]
                  : [AppColors.deepRed, AppColors.vermilion],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: (isDark ? AppColors.premiumDarkGradientStart : AppColors.deepRed)
                    .withValues(alpha: 0.35),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.admin_panel_settings_rounded,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome back,',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          auth.user?.name ?? 'Admin',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.temple_hindu, color: Colors.white, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      '$totalPandals pandals managed',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatGrid extends StatelessWidget {
  const _StatGrid({required this.anim, required this.admin});

  final Animation<double> anim;
  final AdminPandalController admin;

  @override
  Widget build(BuildContext context) {
    final stats = [
      (
        icon: Icons.temple_hindu_rounded,
        label: 'Total',
        value: '${admin.totalPandals}',
        gradient: [const Color(0xFF5C6BC0), const Color(0xFF3949AB)],
      ),
      (
        icon: Icons.check_circle_rounded,
        label: 'Active',
        value: '${admin.activePandals}',
        gradient: [const Color(0xFF43A047), const Color(0xFF2E7D32)],
      ),
      (
        icon: Icons.star_rounded,
        label: 'Featured',
        value: '${admin.featuredPandals}',
        gradient: [const Color(0xFFFFB300), const Color(0xFFF57C00)],
      ),
      (
        icon: Icons.rate_review_rounded,
        label: 'Reviews',
        value: '${admin.totalReviews}',
        gradient: [const Color(0xFFEC407A), const Color(0xFFC2185B)],
      ),
    ];

    final crossAxisCount = MediaQuery.sizeOf(context).width > 700 ? 4 : 2;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.25,
      ),
      itemCount: stats.length,
      itemBuilder: (context, index) {
        final delay = Duration(milliseconds: 200 + (index * 100));
        return _AnimatedStatCard(
          anim: anim,
          delay: delay,
          icon: stats[index].icon,
          label: stats[index].label,
          value: stats[index].value,
          gradient: stats[index].gradient,
        );
      },
    );
  }
}

class _AnimatedStatCard extends StatefulWidget {
  const _AnimatedStatCard({
    required this.anim,
    required this.delay,
    required this.icon,
    required this.label,
    required this.value,
    required this.gradient,
  });

  final Animation<double> anim;
  final Duration delay;
  final IconData icon;
  final String label;
  final String value;
  final List<Color> gradient;

  @override
  State<_AnimatedStatCard> createState() => _AnimatedStatCardState();
}

class _AnimatedStatCardState extends State<_AnimatedStatCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _scale = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack);
    Future.delayed(widget.delay, () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ScaleTransition(
      scale: _scale,
      child: FadeTransition(
        opacity: _scale,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: widget.gradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: widget.gradient.first.withValues(alpha: 0.3),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(widget.icon, color: Colors.white, size: 22),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      widget.value,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        height: 1.0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.label,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  const _QuickActionTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(14),
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Theme.of(context).dividerColor.withValues(alpha: 0.5),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
              ),
            ],
          ),
        ),
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
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: Theme.of(context).colorScheme.onErrorContainer,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onErrorContainer,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
