import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AddFileBottomSheet extends StatelessWidget {
  final VoidCallback onCamera;
  final VoidCallback onDetection;
  final VoidCallback onFiles;
  final VoidCallback onFarmRecords;
  final VoidCallback onAgriTraining;

  const AddFileBottomSheet({
    super.key,
    required this.onCamera,
    required this.onDetection,
    required this.onFiles,
    required this.onFarmRecords,
    required this.onAgriTraining,
  });

  static Future<void> show(
    BuildContext context, {
    required VoidCallback onCamera,
    required VoidCallback onDetection,
    required VoidCallback onFiles,
    required VoidCallback onFarmRecords,
    required VoidCallback onAgriTraining,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => AddFileBottomSheet(
        onCamera: onCamera,
        onDetection: onDetection,
        onFiles: onFiles,
        onFarmRecords: onFarmRecords,
        onAgriTraining: onAgriTraining,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(
        20, 12, 20, MediaQuery.of(context).padding.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          // Media buttons row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _MediaButton(
                icon: Icons.camera_alt_outlined,
                label: 'Camera',
                onTap: () {
                  Navigator.pop(context);
                  onCamera();
                },
              ),
              _MediaButton(
                icon: Icons.document_scanner_outlined,
                label: 'Detection',
                onTap: () {
                  Navigator.pop(context);
                  onDetection();
                },
              ),
              _MediaButton(
                icon: Icons.attach_file_rounded,
                label: 'Files',
                onTap: () {
                  Navigator.pop(context);
                  onFiles();
                },
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(height: 1),

          // Farm Records
          _MenuListItem(
            icon: Icons.assignment_outlined,
            title: 'Farm Records',
            subtitle: 'Create farm records',
            onTap: () {
              Navigator.pop(context);
              onFarmRecords();
            },
          ),

          const Divider(height: 1),

          // Agri Training
          _MenuListItem(
            icon: Icons.menu_book_outlined,
            title: 'Agri Training',
            subtitle: 'Get a step by step guide',
            onTap: () {
              Navigator.pop(context);
              onAgriTraining();
            },
          ),
        ],
      ),
    );
  }
}

class _MediaButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MediaButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: AppColors.primaryIcon,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primaryBorder, width: 0.5),
            ),
            child: Icon(icon, color: AppColors.primary, size: 26),
          ),
          const SizedBox(height: 6),
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

class _MenuListItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _MenuListItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primaryIcon,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primaryBorder, width: 0.5),
              ),
              child: Icon(icon, color: AppColors.primary, size: 22),
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
            const Spacer(),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textMuted,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
