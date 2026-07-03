import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/chat_message.dart';

class AcadesDrawer extends StatelessWidget {
  final List<ChatHistory> chatHistory;
  final VoidCallback onNewChat;
  final VoidCallback onSearchChats;
  final VoidCallback onFarmRecords;
  final VoidCallback onWeatherAlerts;
  final void Function(ChatHistory)? onHistoryTap;

  const AcadesDrawer({
    super.key,
    required this.chatHistory,
    required this.onNewChat,
    required this.onSearchChats,
    required this.onFarmRecords,
    required this.onWeatherAlerts,
    this.onHistoryTap,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.white,
      width: 280,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Logo + close
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 16, 8),
              child: Row(
                children: [
                  const Text(
                    'Acades AI',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20),
                    color: AppColors.textMuted,
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(),
            const SizedBox(height: 4),

            // Main nav items
            _DrawerItem(
              icon: Icons.add_comment_outlined,
              label: 'New Chat',
              onTap: () {
                Navigator.pop(context);
                onNewChat();
              },
            ),
            _DrawerItem(
              icon: Icons.search_rounded,
              label: 'Search Chats',
              onTap: () {
                Navigator.pop(context);
                onSearchChats();
              },
            ),
            _DrawerItem(
              icon: Icons.assignment_outlined,
              label: 'Farm Records',
              onTap: () {
                Navigator.pop(context);
                onFarmRecords();
              },
            ),
            _DrawerItem(
              icon: Icons.cloud_outlined,
              label: 'Weather Alerts',
              onTap: () {
                Navigator.pop(context);
                onWeatherAlerts();
              },
            ),

            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'CHAT HISTORY',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textMuted,
                  letterSpacing: 0.8,
                ),
              ),
            ),
            const SizedBox(height: 6),

            // Chat history list
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: chatHistory.length,
                itemBuilder: (context, index) {
                  final item = chatHistory[index];
                  return _HistoryItem(
                    item: item,
                    onTap: () {
                      Navigator.pop(context);
                      onHistoryTap?.call(item);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppColors.primary),
            const SizedBox(width: 14),
            Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryItem extends StatelessWidget {
  final ChatHistory item;
  final VoidCallback onTap;

  const _HistoryItem({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppColors.divider, width: 0.5),
          ),
        ),
        child: Text(
          item.title,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      ),
    );
  }
}
