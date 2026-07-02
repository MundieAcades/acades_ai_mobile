import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import 'welcome_step.dart';

/// Consistent wrapper for every onboarding quiz step.
/// Handles the entrance animation, question, emoji, description, and CTA.
class StepShell extends StatefulWidget {
  final String emoji;
  final String question;
  final String description;
  final Widget choices;
  final String buttonLabel;
  final VoidCallback? onNext;

  const StepShell({
    super.key,
    required this.emoji,
    required this.question,
    required this.description,
    required this.choices,
    required this.onNext,
    this.buttonLabel = 'Continue',
  });

  @override
  State<StepShell> createState() => _StepShellState();
}

class _StepShellState extends State<StepShell>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();

    _fade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeIn),
    );
    _slide = Tween<Offset>(
      begin: const Offset(0.06, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slide,
      child: FadeTransition(
        opacity: _fade,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),

              // Emoji badge
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.primaryIcon,
                  borderRadius: BorderRadius.circular(18),
                  border:
                      Border.all(color: AppColors.primaryBorder, width: 0.5),
                ),
                child: Center(
                  child: Text(
                    widget.emoji,
                    style: const TextStyle(fontSize: 32),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Text(
                widget.question,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  height: 1.25,
                  letterSpacing: -0.3,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                widget.description,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textMuted,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 28),

              // Choice content
              Expanded(child: SingleChildScrollView(child: widget.choices)),

              const SizedBox(height: 16),

              // CTA
              OnboardingButton(
                label: widget.buttonLabel,
                onTap: widget.onNext,
              ),

              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
    );
  }
}
