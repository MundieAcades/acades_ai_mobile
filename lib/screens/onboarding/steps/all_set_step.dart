import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../onboarding_flow.dart';
import 'welcome_step.dart';

class AllSetStep extends StatefulWidget {
  final FarmerProfile profile;
  final VoidCallback onContinue;

  const AllSetStep({
    super.key,
    required this.profile,
    required this.onContinue,
  });

  @override
  State<AllSetStep> createState() => _AllSetStepState();
}

class _AllSetStepState extends State<AllSetStep>
    with TickerProviderStateMixin {
  late AnimationController _celebCtrl;
  late AnimationController _cardCtrl;
  late Animation<double> _celebScale;
  late Animation<double> _cardFade;
  late Animation<Offset> _cardSlide;

  @override
  void initState() {
    super.initState();

    _celebCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _cardCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _celebScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _celebCtrl, curve: Curves.elasticOut),
    );
    _cardFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _cardCtrl, curve: Curves.easeIn),
    );
    _cardSlide = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _cardCtrl, curve: Curves.easeOut));

    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _celebCtrl.forward();
    });
    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) _cardCtrl.forward();
    });
  }

  @override
  void dispose() {
    _celebCtrl.dispose();
    _cardCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 32),
          // Celebration icon
          AnimatedBuilder(
            animation: _celebScale,
            builder: (_, __) => Transform.scale(
              scale: _celebScale.value,
              child: Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.primaryLight, AppColors.primary],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 30,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text('🎉', style: TextStyle(fontSize: 52)),
                ),
              ),
            ),
          ),
          const SizedBox(height: 28),
          const Text(
            "You're all set!",
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Here's what we know about your farm:",
            style: TextStyle(
              fontSize: 15,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 24),

          // Profile summary card
          SlideTransition(
            position: _cardSlide,
            child: FadeTransition(
              opacity: _cardFade,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(20),
                  border:
                      Border.all(color: AppColors.primaryBorder, width: 0.5),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _ProfileRow(
                      icon: '🌱',
                      label: 'Crops',
                      value: widget.profile.crops.isEmpty
                          ? 'None selected'
                          : widget.profile.crops.take(3).join(', ') +
                              (widget.profile.crops.length > 3
                                  ? ' +${widget.profile.crops.length - 3} more'
                                  : ''),
                    ),
                    const Divider(height: 20),
                    _ProfileRow(
                      icon: '📍',
                      label: 'District',
                      value: widget.profile.district.isEmpty
                          ? 'Not set'
                          : widget.profile.district,
                    ),
                    const Divider(height: 20),
                    _ProfileRow(
                      icon: '📐',
                      label: 'Land size',
                      value: widget.profile.landSize.isEmpty
                          ? 'Not set'
                          : widget.profile.landSize,
                    ),
                    const Divider(height: 20),
                    _ProfileRow(
                      icon: '👤',
                      label: 'Gender',
                      value: widget.profile.gender.isEmpty
                          ? 'Not set'
                          : widget.profile.gender,
                    ),
                  ],
                ),
              ),
            ),
          ),

          const Spacer(),

          FadeTransition(
            opacity: _cardFade,
            child: OnboardingButton(
              label: 'Create my account →',
              onTap: widget.onContinue,
            ),
          ),
          const SizedBox(height: 28),
        ],
      ),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  final String icon;
  final String label;
  final String value;

  const _ProfileRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(icon, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textMuted,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
        ),
      ],
    );
  }
}
