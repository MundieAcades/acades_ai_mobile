import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';
import '../widgets/acades_drawer.dart';
import '../models/chat_message.dart';

class FarmRecordsScreen extends StatelessWidget {
  FarmRecordsScreen({super.key});

  final List<_FarmRecord> _records = const [
    _FarmRecord(
      crop: 'Maize',
      field: 'Field A — 2.5 acres',
      date: 'Oct 15, 2024',
      status: 'Growing',
      statusColor: Color(0xFF5AAB28),
    ),
    _FarmRecord(
      crop: 'Soya Beans',
      field: 'Field B — 1.8 acres',
      date: 'Nov 2, 2024',
      status: 'Planted',
      statusColor: Color(0xFF2196F3),
    ),
    _FarmRecord(
      crop: 'Ground Nuts',
      field: 'Field C — 1.2 acres',
      date: 'Sep 28, 2024',
      status: 'Harvested',
      statusColor: Color(0xFFFF9800),
    ),
  ];

  final List<ChatHistory> _history = [
    ChatHistory(
      id: '1',
      title: 'Regional tracking containing...',
      lastMessage: '',
      updatedAt: DateTime(2024, 11, 2),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      drawer: AcadesDrawer(
        chatHistory: const [],
        onNewChat: () => Navigator.pop(context),
        onSearchChats: () {},
        onFarmRecords: () {},
        onWeatherAlerts: () {},
      ),
      body: SafeArea(
        child: Column(
          children: [
            AcadesAppBar(),
            const Divider(height: 1),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Farm Records',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          textStyle: const TextStyle(fontSize: 13),
                          elevation: 0,
                        ),
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('Add Record'),
                        onPressed: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ..._records.map((r) => _RecordCard(record: r)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FarmRecord {
  final String crop;
  final String field;
  final String date;
  final String status;
  final Color statusColor;

  const _FarmRecord({
    required this.crop,
    required this.field,
    required this.date,
    required this.status,
    required this.statusColor,
  });
}

class _RecordCard extends StatelessWidget {
  final _FarmRecord record;
  const _RecordCard({required this.record});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider, width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.primaryIcon,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primaryBorder, width: 0.5),
            ),
            child: const Icon(Icons.eco_outlined,
                color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.crop,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  record.field,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Planted: ${record.date}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: record.statusColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              record.status,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: record.statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
