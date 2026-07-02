import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import 'step_shell.dart';

class CropStep extends StatelessWidget {
  final List<String> selectedCrops;
  final void Function(List<String>) onChanged;
  final VoidCallback? onNext;

  const CropStep({
    super.key,
    required this.selectedCrops,
    required this.onChanged,
    required this.onNext,
  });

  static const _crops = [
    _Crop('🌽', 'Maize'),
    _Crop('🫘', 'Soya Beans'),
    _Crop('🥜', 'Ground Nuts'),
    _Crop('🌿', 'Tobacco'),
    _Crop('🍅', 'Tomatoes'),
    _Crop('🧅', 'Onions'),
    _Crop('🌾', 'Rice'),
    _Crop('🫑', 'Beans'),
    _Crop('🥔', 'Sweet Potato'),
    _Crop('🥦', 'Vegetables'),
    _Crop('🍌', 'Bananas'),
    _Crop('☕', 'Coffee'),
  ];

  void _toggle(String crop) {
    final updated = List<String>.from(selectedCrops);
    if (updated.contains(crop)) {
      updated.remove(crop);
    } else {
      updated.add(crop);
    }
    onChanged(updated);
  }

  @override
  Widget build(BuildContext context) {
    return StepShell(
      emoji: '🌱',
      question: 'What do you\ngrow on your farm?',
      description: 'Select all crops that apply — we\'ll personalise your advice.',
      onNext: selectedCrops.isNotEmpty ? onNext : null,
      buttonLabel: selectedCrops.isEmpty
          ? 'Select at least one crop'
          : 'Continue (${selectedCrops.length} selected)',
      choices: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: _crops.map((c) {
          final selected = selectedCrops.contains(c.name);
          return _CropCard(
            crop: c,
            selected: selected,
            onTap: () => _toggle(c.name),
          );
        }).toList(),
      ),
    );
  }
}

class _Crop {
  final String emoji;
  final String name;
  const _Crop(this.emoji, this.name);
}

class _CropCard extends StatefulWidget {
  final _Crop crop;
  final bool selected;
  final VoidCallback onTap;

  const _CropCard({
    required this.crop,
    required this.selected,
    required this.onTap,
  });

  @override
  State<_CropCard> createState() => _CropCardState();
}

class _CropCardState extends State<_CropCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.93).animate(
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
      builder: (_, child) => Transform.scale(
        scale: _scale.value,
        child: child,
      ),
      child: GestureDetector(
        onTap: _onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: widget.selected ? AppColors.primary : AppColors.white,
            borderRadius: BorderRadius.circular(14),
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
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ]
                : [],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(widget.crop.emoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(
                widget.crop.name,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: widget.selected ? Colors.white : AppColors.textPrimary,
                ),
              ),
              if (widget.selected) ...[
                const SizedBox(width: 6),
                const Icon(Icons.check_circle_rounded,
                    color: Colors.white, size: 16),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
