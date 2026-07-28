import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/theme_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../routes/route_names.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final themeController = context.watch<ThemeController>();
    final user = auth.user;
    final isDark = themeController.isDark;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: AppColors.deepRed.withValues(alpha: 0.15),
                    child: const Icon(Icons.person, size: 34, color: AppColors.deepRed),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.name ?? 'Guest visitor',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user?.email ?? 'Login to sync favorites',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  secondary: Icon(
                    isDark ? Icons.dark_mode : Icons.light_mode,
                    color: isDark ? AppColors.goldDark : AppColors.festiveOrange,
                  ),
                  title: const Text('Dark mode'),
                  subtitle: Text(isDark ? 'Dark theme is on' : 'Light theme is on'),
                  value: isDark,
                  onChanged: (_) => themeController.toggle(),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.deepRed, AppColors.vermilion],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.diamond, color: AppColors.premiumGold, size: 20),
                  ),
                  title: const Text('Upgrade to Premium'),
                  subtitle: const Text('Unlock exclusive features'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => context.pushNamed(RouteNames.premium),
                ),
                const Divider(height: 1),
                if (auth.isAdmin)
                  ListTile(
                    leading: const Icon(Icons.admin_panel_settings),
                    title: const Text('Admin dashboard'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => context.pushNamed(RouteNames.adminDashboard),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (auth.isLoggedIn)
            ListTile(
              leading: const Icon(Icons.logout, color: AppColors.danger),
              title: const Text('Logout', style: TextStyle(color: AppColors.danger)),
              onTap: () async {
                await context.read<AuthController>().logout();
                if (context.mounted) {
                  context.goNamed(RouteNames.onboarding);
                }
              },
            )
          else
            ListTile(
              leading: const Icon(Icons.login),
              title: const Text('Login'),
              onTap: () => context.pushNamed(RouteNames.login),
            ),
        ],
      ),
    );
  }
}
