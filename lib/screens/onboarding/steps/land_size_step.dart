import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import 'step_shell.dart';

class LandSizeStep extends StatelessWidget {
  final String selected;
  final void Function(String) onChanged;
  final VoidCallback? onNext;

  const LandSizeStep({
    super.key,
    required this.selected,
    required this.onChanged,
    required this.onNext,
  });

  static const _sizes = [
    _LandSize('🌱', 'Less than 1 acre', 'Small plot — subsistence farming'),
    _LandSize('🌿', '1 – 2 acres', 'Small farm — family use + small sales'),
    _LandSize('🌾', '2 – 5 acres', 'Medium farm — regular market sales'),
    _LandSize('🚜', '5 – 10 acres', 'Large farm — commercial production'),
    _LandSize('🏭', 'More than 10 acres', 'Commercial / estate farming'),
  ];

  @override
  Widget build(BuildContext context) {
    return StepShell(
      emoji: '📐',
      question: 'How big is\nyour land?',
      description: 'This helps us recommend the right amount of inputs and seeds.',
      onNext: selected.isNotEmpty ? onNext : null,
      choices: Column(
        children: _sizes.map((s) {
          final isSelected = selected == s.label;
          return _LandCard(
            size: s,
            selected: isSelected,
            onTap: () => onChanged(s.label),
          );
        }).toList(),
      ),
    );
  }
}

class _LandSize {
  final String emoji;
  final String label;
  final String subtitle;
  const _LandSize(this.emoji, this.label, this.subtitle);
}

class _LandCard extends StatefulWidget {
  final _LandSize size;
  final bool selected;
  final VoidCallback onTap;

  const _LandCard({
    required this.size,
    required this.selected,
    required this.onTap,
  });

  @override
  State<_LandCard> createState() => _LandCardState();
}

class _LandCardState extends State<_LandCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onTap() async {
    await _ctrl.forward();
    await _ctrl.reverse();
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scale,
      builder: (_, child) =>
          Transform.scale(scale: _scale.value, child: child),
      child: GestureDetector(
        onTap: _onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: widget.selected ? AppColors.primary : AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: widget.selected
                  ? AppColors.primary
                  : AppColors.primaryBorder,
              width: widget.selected ? 1.5 : 0.5,
            ),
            boxShadow: widget.selected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.22),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    )
                  ]
                : [],
          ),
          child: Row(
            children: [
              // Emoji in circle
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: widget.selected
                      ? Colors.white.withOpacity(0.2)
                      : AppColors.primaryIcon,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(widget.size.emoji,
                      style: const TextStyle(fontSize: 22)),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.size.label,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: widget.selected
                            ? Colors.white
                            : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.size.subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: widget.selected
                            ? Colors.white.withOpacity(0.78)
                            : AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              if (widget.selected)
                const Icon(Icons.check_circle_rounded,
                    color: Colors.white, size: 22)
              else
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: AppColors.primaryBorder, width: 1.5),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
