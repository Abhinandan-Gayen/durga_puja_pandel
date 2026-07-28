import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeScale;
  late final Animation<Offset> _slideUp;
  late final Animation<double> _badgePulse;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeScale = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOutBack),
    );
    _slideUp = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.2, 0.7, curve: Curves.easeOutCubic),
    ));
    _badgePulse = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.3), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 1.3, end: 1.0), weight: 1),
    ]).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.5, 0.8, curve: Curves.easeInOut),
    ));

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gradientStart = isDark
        ? AppColors.premiumDarkGradientStart
        : AppColors.premiumGradientStart;
    final gradientEnd = isDark
        ? AppColors.premiumDarkGradientEnd
        : AppColors.premiumGradientEnd;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [gradientStart, gradientEnd],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      _buildHeroSection(),
                      const SizedBox(height: 32),
                      _buildPlans(),
                      const SizedBox(height: 24),
                      _buildFeatures(),
                      const SizedBox(height: 32),
                      _buildCTA(),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => context.pop(),
          ),
          const Spacer(),
          FadeTransition(
            opacity: _controller.drive(
              CurveTween(curve: const Interval(0.3, 0.8)),
            ),
            child: ScaleTransition(
              scale: _badgePulse,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.premiumGold,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.premiumGold.withValues(alpha: 0.4),
                      blurRadius: 12,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: const Text(
                  'PREMIUM',
                  style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection() {
    return FadeTransition(
      opacity: _fadeScale,
      child: ScaleTransition(
        scale: _fadeScale,
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.15),
              ),
              child: const Icon(
                Icons.diamond,
                color: AppColors.premiumGold,
                size: 44,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Unlock Premium',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Elevate your Pujo experience with exclusive features',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.85),
                fontSize: 16,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlans() {
    return SlideTransition(
      position: _slideUp,
      child: Row(
        children: [
          Expanded(child: _PlanCard(title: 'Monthly', price: '₹99', per: '/mo')),
          const SizedBox(width: 16),
          Expanded(
            child: _PlanCard(
              title: 'Yearly',
              price: '₹499',
              per: '/yr',
              isPopular: true,
              badge: 'SAVE 58%',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatures() {
    const features = [
      (icon: Icons.notifications_active, title: 'Real-time Crowd Alerts', desc: 'Get notified when crowd levels change at your saved pandals'),
      (icon: Icons.route, title: 'AI-Powered Routes', desc: 'Smart route planning to avoid traffic and maximize pandal visits'),
      (icon: Icons.hd, title: 'HD Photo Downloads', desc: 'Download high-resolution pandal photos for your collection'),
      (icon: Icons.verified, title: 'Verified Badge', desc: 'Stand out with a premium verified badge on your profile'),
      (icon: Icons.auto_awesome, title: 'Ad-Free Experience', desc: 'Enjoy the app without any distractions or advertisements'),
      (icon: Icons.support_agent, title: 'Priority Support', desc: 'Get 24/7 priority customer support whenever you need help'),
    ];

    return FadeTransition(
      opacity: _controller.drive(
        CurveTween(curve: const Interval(0.4, 1.0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: Text(
              'Premium Features',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          for (final f in features) _FeatureTile(icon: f.icon, title: f.title, desc: f.desc),
        ],
      ),
    );
  }

  Widget _buildCTA() {
    return FadeTransition(
      opacity: _controller.drive(
        CurveTween(curve: const Interval(0.5, 1.0)),
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.premiumGold,
            foregroundColor: Colors.black87,
            minimumSize: const Size.fromHeight(56),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 6,
            shadowColor: AppColors.premiumGold.withValues(alpha: 0.5),
          ),
          child: const Text(
            'Upgrade to Premium',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
          ),
        ),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.title,
    required this.price,
    required this.per,
    this.isPopular = false,
    this.badge,
  });

  final String title;
  final String price;
  final String per;
  final bool isPopular;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          decoration: BoxDecoration(
            color: isPopular
                ? Colors.white
                : Colors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(16),
            border: isPopular
                ? Border.all(color: AppColors.premiumGold, width: 2)
                : null,
          ),
          child: Column(
            children: [
              Text(
                title,
                style: TextStyle(
                  color: isPopular ? AppColors.charcoal : Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                price,
                style: TextStyle(
                  color: isPopular ? AppColors.deepRed : Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                per,
                style: TextStyle(
                  color: isPopular ? AppColors.mutedText : Colors.white70,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        if (badge != null)
          Positioned(
            top: -12,
            right: -8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.premiumGold,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                badge!,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _FeatureTile extends StatelessWidget {
  const _FeatureTile({
    required this.icon,
    required this.title,
    required this.desc,
  });

  final IconData icon;
  final String title;
  final String desc;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.premiumGold.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.premiumGold, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  desc,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 12,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
