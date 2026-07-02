import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import 'step_shell.dart';

class GenderStep extends StatelessWidget {
  final String selected;
  final void Function(String) onChanged;
  final VoidCallback? onNext;

  const GenderStep({
    super.key,
    required this.selected,
    required this.onChanged,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return StepShell(
      emoji: '👤',
      question: 'Tell us a\nlittle about you',
      description:
          'This helps us understand our farming community better. Your data stays private.',
      onNext: selected.isNotEmpty ? onNext : null,
      choices: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _GenderCard(
                  emoji: '👨‍🌾',
                  label: 'Male',
                  selected: selected == 'Male',
                  onTap: () => onChanged('Male'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _GenderCard(
                  emoji: '👩‍🌾',
                  label: 'Female',
                  selected: selected == 'Female',
                  onTap: () => onChanged('Female'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _GenderCard(
            emoji: '🌾',
            label: 'Prefer not to say',
            selected: selected == 'Prefer not to say',
            onTap: () => onChanged('Prefer not to say'),
            wide: true,
          ),
          const SizedBox(height: 20),
          // Privacy note
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.primaryIcon,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primaryBorder, width: 0.5),
            ),
            child: const Row(
              children: [
                Icon(Icons.lock_outline_rounded,
                    color: AppColors.primary, size: 18),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Your personal information is never shared with third parties.',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
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

class _GenderCard extends StatefulWidget {
  final String emoji;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool wide;

  const _GenderCard({
    required this.emoji,
    required this.label,
    required this.selected,
    required this.onTap,
    this.wide = false,
  });

  @override
  State<_GenderCard> createState() => _GenderCardState();
}

class _GenderCardState extends State<_GenderCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onTap() async {
    _ctrl.forward().then((_) => _ctrl.reverse());
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          vertical: widget.wide ? 14 : 24,
          horizontal: 16,
        ),
        decoration: BoxDecoration(
          color: widget.selected ? AppColors.primary : AppColors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color:
                widget.selected ? AppColors.primary : AppColors.primaryBorder,
            width: widget.selected ? 1.5 : 0.5,
          ),
          boxShadow: widget.selected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.25),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  )
                ]
              : [],
        ),
        child: widget.wide
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(widget.emoji,
                      style: const TextStyle(fontSize: 24)),
                  const SizedBox(width: 10),
                  Text(
                    widget.label,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: widget.selected
                          ? Colors.white
                          : AppColors.textPrimary,
                    ),
                  ),
                  if (widget.selected) ...[
                    const SizedBox(width: 8),
                    const Icon(Icons.check_circle_rounded,
                        color: Colors.white, size: 18),
                  ],
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(widget.emoji,
                      style: const TextStyle(fontSize: 36)),
                  const SizedBox(height: 10),
                  Text(
                    widget.label,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: widget.selected
                          ? Colors.white
                          : AppColors.textPrimary,
                    ),
                  ),
                  if (widget.selected) ...[
                    const SizedBox(height: 6),
                    const Icon(Icons.check_circle_rounded,
                        color: Colors.white, size: 18),
                  ],
                ],
              ),
      ),
    );
  }
}
