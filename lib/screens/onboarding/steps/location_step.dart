import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import 'step_shell.dart';

class LocationStep extends StatefulWidget {
  final String selected;
  final void Function(String) onChanged;
  final VoidCallback? onNext;

  const LocationStep({
    super.key,
    required this.selected,
    required this.onChanged,
    required this.onNext,
  });

  @override
  State<LocationStep> createState() => _LocationStepState();
}

class _LocationStepState extends State<LocationStep> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _filter = '';

  static const _districts = [
    _District('🏙️', 'Lilongwe', 'Central Region'),
    _District('🌆', 'Blantyre', 'Southern Region'),
    _District('🏘️', 'Mzuzu', 'Northern Region'),
    _District('🌿', 'Zomba', 'Southern Region'),
    _District('🌾', 'Kasungu', 'Central Region'),
    _District('🌊', 'Salima', 'Central Region'),
    _District('⛰️', 'Dedza', 'Central Region'),
    _District('🌳', 'Ntchisi', 'Central Region'),
    _District('🦁', 'Mchinji', 'Central Region'),
    _District('🌺', 'Chiradzulu', 'Southern Region'),
    _District('🐘', 'Mangochi', 'Southern Region'),
    _District('🌴', 'Nkhotakota', 'Central Region'),
    _District('🏔️', 'Rumphi', 'Northern Region'),
    _District('🌻', 'Dowa', 'Central Region'),
    _District('🎋', 'Thyolo', 'Southern Region'),
    _District('🍃', 'Mulanje', 'Southern Region'),
  ];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filter.isEmpty
        ? _districts
        : _districts
            .where((d) =>
                d.name.toLowerCase().contains(_filter.toLowerCase()) ||
                d.region.toLowerCase().contains(_filter.toLowerCase()))
            .toList();

    return StepShell(
      emoji: '📍',
      question: 'Where is your\nfarm located?',
      description: 'We\'ll use this to give you localised weather and planting advice.',
      onNext: widget.selected.isNotEmpty ? widget.onNext : null,
      choices: Column(
        children: [
          // Search box
          Container(
            decoration: BoxDecoration(
              color: AppColors.inputBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primaryBorder, width: 0.5),
            ),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _filter = v),
              style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
              decoration: const InputDecoration(
                hintText: 'Search district...',
                hintStyle:
                    TextStyle(fontSize: 14, color: AppColors.textHint),
                prefixIcon: Icon(Icons.search_rounded,
                    color: AppColors.textMuted, size: 20),
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 14),
          ...filtered.map((d) {
            final selected = widget.selected == d.name;
            return _DistrictTile(
              district: d,
              selected: selected,
              onTap: () => widget.onChanged(d.name),
            );
          }),
          if (filtered.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Text(
                'No districts found.\nTry a different search.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textMuted, fontSize: 14),
              ),
            ),
        ],
      ),
    );
  }
}

class _District {
  final String emoji;
  final String name;
  final String region;
  const _District(this.emoji, this.name, this.region);
}

class _DistrictTile extends StatelessWidget {
  final _District district;
  final bool selected;
  final VoidCallback onTap;

  const _DistrictTile({
    required this.district,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.primaryBorder,
            width: selected ? 1.5 : 0.5,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ]
              : [],
        ),
        child: Row(
          children: [
            Text(district.emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    district.name,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: selected ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    district.region,
                    style: TextStyle(
                      fontSize: 12,
                      color: selected
                          ? Colors.white.withOpacity(0.8)
                          : AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            if (selected)
              const Icon(Icons.check_circle_rounded,
                  color: Colors.white, size: 22)
            else
              const Icon(Icons.radio_button_unchecked_rounded,
                  color: AppColors.primaryBorder, size: 22),
          ],
        ),
      ),
    );
  }
}
