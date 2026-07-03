import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

class WelcomeStep extends StatefulWidget {
  final VoidCallback onNext;
  const WelcomeStep({super.key, required this.onNext});

  @override
  State<WelcomeStep> createState() => _WelcomeStepState();
}

class _WelcomeStepState extends State<WelcomeStep>
    with TickerProviderStateMixin {
  late AnimationController _iconCtrl;
  late AnimationController _contentCtrl;
  late Animation<double> _iconScale;
  late Animation<double> _contentOpacity;
  late Animation<Offset> _contentSlide;

  @override
  void initState() {
    super.initState();
    _iconCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _contentCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _iconScale = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _iconCtrl, curve: Curves.elasticOut),
    );
    _contentOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _contentCtrl, curve: Curves.easeIn),
    );
    _contentSlide = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _contentCtrl, curve: Curves.easeOut));

    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _iconCtrl.forward();
    });
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _contentCtrl.forward();
    });
  }

  @override
  void dispose() {
    _iconCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.homeGradient),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          children: [
            const Spacer(flex: 2),

            // Big animated illustration
            AnimatedBuilder(
              animation: _iconScale,
              builder: (_, __) => Transform.scale(
                scale: _iconScale.value,
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.2),
                        blurRadius: 40,
                        offset: const Offset(0, 16),
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned(
                        bottom: 28,
                        child: Container(
                          width: 70,
                          height: 3,
                          decoration: BoxDecoration(
                            color: AppColors.primarySurface,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const Icon(Icons.eco_rounded,
                          color: AppColors.primary, size: 68),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),

            // Content
            SlideTransition(
              position: _contentSlide,
              child: FadeTransition(
                opacity: _contentOpacity,
                child: const Column(
                  children: [
                    Text(
                      'Welcome to\nAcades AI',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        height: 1.2,
                        letterSpacing: -0.5,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Your personal farming assistant.\nLet\'s learn a little about you so we can give you the best advice.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.textSecondary,
                        height: 1.6,
                      ),
                    ),
                    SizedBox(height: 12),

                    // Feature pills
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _FeaturePill(
                            icon: Icons.chat_bubble_outline_rounded,
                            label: 'AI Chat'),
                        _FeaturePill(
                            icon: Icons.document_scanner_outlined,
                            label: 'Crop Detection'),
                        _FeaturePill(
                            icon: Icons.cloud_outlined,
                            label: 'Weather Alerts'),
                        _FeaturePill(
                            icon: Icons.assignment_outlined,
                            label: 'Farm Records'),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const Spacer(flex: 3),

            // CTA button
            FadeTransition(
              opacity: _contentOpacity,
              child: _OnboardingButton(
                label: "Let's get started →",
                onTap: widget.onNext,
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _FeaturePill extends StatelessWidget {
  final IconData icon;
  final String label;
  const _FeaturePill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primaryBorder, width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primary),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Shared button used across all onboarding steps ──
class OnboardingButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool enabled;

  const OnboardingButton({
    super.key,
    required this.label,
    required this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) => _OnboardingButton(
        label: label,
        onTap: onTap,
        enabled: enabled,
      );
}

class _OnboardingButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool enabled;

  const _OnboardingButton({
    required this.label,
    required this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final active = onTap != null && enabled;
    return GestureDetector(
      onTap: active ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        height: 54,
        decoration: BoxDecoration(
          color: active ? AppColors.primary : AppColors.primaryBorder,
          borderRadius: BorderRadius.circular(16),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  )
                ]
              : [],
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ),
    );
  }
}
