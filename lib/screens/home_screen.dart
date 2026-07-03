import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';
import '../widgets/add_file_sheet.dart';
import '../widgets/acades_drawer.dart';
import '../models/chat_message.dart';
import 'chat_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _inputController = TextEditingController();

  final List<ChatHistory> _history = [
    ChatHistory(
      id: '1',
      title: 'Regional tracking containing...',
      lastMessage: '',
      updatedAt: DateTime.now(),
    ),
    ChatHistory(
      id: '2',
      title: 'Soya planting guide for Lilongwe',
      lastMessage: '',
      updatedAt: DateTime.now(),
    ),
    ChatHistory(
      id: '3',
      title: 'Pest detection results — maize',
      lastMessage: '',
      updatedAt: DateTime.now(),
    ),
    ChatHistory(
      id: '4',
      title: 'Weather forecast Lilongwe',
      lastMessage: '',
      updatedAt: DateTime.now(),
    ),
    ChatHistory(
      id: '5',
      title: 'How to apply Inoculum on soya',
      lastMessage: '',
      updatedAt: DateTime.now(),
    ),
  ];

  void _startChat(String initialMessage) {
    if (initialMessage.trim().isEmpty) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(initialMessage: initialMessage.trim()),
      ),
    );
    _inputController.clear();
  }

  void _openAddFile() {
    AddFileBottomSheet.show(
      context,
      onCamera: () => _showSnack('Opening camera...'),
      onDetection: () => _showSnack('Opening crop detection...'),
      onFiles: () => _showSnack('Opening file picker...'),
      onFarmRecords: () => _showSnack('Opening farm records...'),
      onAgriTraining: () => _showSnack('Opening agri training...'),
    );
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AcadesDrawer(
        chatHistory: _history,
        onNewChat: () => _startChat(''),
        onSearchChats: () => _showSnack('Search chats...'),
        onFarmRecords: () => _showSnack('Farm records...'),
        onWeatherAlerts: () => _showSnack('Weather alerts...'),
        onHistoryTap: (h) => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const ChatScreen(initialMessage: ''),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.homeGradient),
        child: SafeArea(
          child: Column(
            children: [
              // App bar
              _buildAppBar(context),

              // Body
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 60),
                      _buildHeroSection(),
                      const SizedBox(height: 36),
                      _buildQuickActions(),
                    ],
                  ),
                ),
              ),

              // Input bar
              _buildInputSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Row(
        children: [
          Builder(
            builder: (ctx) => IconButton(
              icon: const Icon(Icons.menu_rounded, size: 22),
              color: AppColors.textPrimary,
              onPressed: () => Scaffold.of(ctx).openDrawer(),
            ),
          ),
          const Expanded(
            child: Text(
              'Acades AI',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: Container(
              width: 34,
              height: 34,
              decoration: const BoxDecoration(
                color: Color(0xFF4CAF50),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text(
                  'MK',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          // Plant icon
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.primaryIcon,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.primaryBorder, width: 0.5),
            ),
            child: const Icon(
              Icons.eco_outlined,
              color: AppColors.primary,
              size: 34,
            ),
          ),
          const SizedBox(height: 24),
          RichText(
            textAlign: TextAlign.center,
            text: const TextSpan(
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w400,
                color: AppColors.textPrimary,
                height: 1.3,
                fontFamily: 'Roboto',
              ),
              children: [
                TextSpan(text: 'What can i\nhelp you with\n'),
                TextSpan(
                  text: 'today?',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              QuickActionChip(
                icon: Icons.cloud_outlined,
                label: 'Weather Advice',
                onTap: () =>
                    _startChat('Give me weather advice for farming today'),
              ),
              const SizedBox(width: 10),
              QuickActionChip(
                icon: Icons.assignment_outlined,
                label: 'Farm Records',
                onTap: () => _startChat('Help me manage my farm records'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () => _startChat('Teach me step by step farming techniques'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.primaryBorder, width: 0.5),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.menu_book_outlined,
                      size: 16, color: AppColors.primary),
                  SizedBox(width: 6),
                  Text(
                    'Learn Step by Step',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputSection() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.transparent,
      ),
      child: ChatInputBar(
        controller: _inputController,
        onSend: () => _startChat(_inputController.text),
        onAttach: _openAddFile,
      ),
    );
  }
}
