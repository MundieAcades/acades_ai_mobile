import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Required for FunctionResponse
import '../theme/app_theme.dart';
import '../models/chat_message.dart';
import '../widgets/shared_widgets.dart';
import '../widgets/add_file_sheet.dart';
import '../widgets/acades_drawer.dart';
import '../services/supabase_service.dart'; // Clean integration with your existing service
import '../providers/auth_provider.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String initialMessage;
  final String? sessionId;

  const ChatScreen({
    super.key,
    required this.initialMessage,
    this.sessionId,
  });

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  String _streamingText = '';
  bool _isStreaming = false;
  List<ChatHistory> _realHistory = [];

  // Tracks which chat_sessions row the current conversation belongs to.
  // Null until either an existing session is opened, or the first message
  // in a brand-new conversation has been sent.
  String? _activeSessionId;

  @override
  void initState() {
    super.initState();
    _loadChatHistory();

    if (widget.sessionId != null) {
      _activeSessionId = widget.sessionId;
      _loadMessagesForSession(widget.sessionId!);
    } else if (widget.initialMessage.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _sendMessage(widget.initialMessage);
      });
    }
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom({bool animated = true}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        if (animated) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        } else {
          _scrollController.jumpTo(
            _scrollController.position.maxScrollExtent,
          );
        }
      }
    });
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty || _isLoading) return;

    final userMsg = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text.trim(),
      isUser: true,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(userMsg);
      _isLoading = true;
      _streamingText = '';
      _isStreaming = false;
    });

    _inputController.clear();
    _scrollToBottom();

    // ──────────────────────────────────────────────────────────────
    // LIVE AI CONNECTION VIA SUPABASE EDGE FUNCTION
    // ──────────────────────────────────────────────────────────────
    String response = '';
    try {
      final FunctionResponse res =
          await SupabaseService.client.functions.invoke(
        'ai_chabot',
        body: {
          'user_question': text.trim(),
          'user_id': SupabaseService.currentUserId,
          // Reuse the same chat session across the conversation instead of
          // letting the edge function create a brand-new session per turn.
          if (_activeSessionId != null) 'session_id': _activeSessionId,
          // 'farm_id': 1 // (Optional) Link current farm identifier if needed
        },
      );

      if (res.status == 200) {
        final Map<String, dynamic> data = res.data;
        response =
            data['answer'] ?? 'Error occured try again!! (No answer received).';

        // Pick up the session id the backend used/created, so subsequent
        // messages in this screen continue the same conversation thread.
        final returnedSessionId = data['session_id']?.toString();
        if (returnedSessionId != null && returnedSessionId.isNotEmpty) {
          _activeSessionId = returnedSessionId;
        }
      } else {
        response = 'Error: Server returned status ${res.status}';
      }
    } catch (e) {
      response = 'Error: Failed to connect to server, try again: $e';
    }
    // ──────────────────────────────────────────────────────────────

    setState(() {
      _isLoading = false;
      _isStreaming = true;
      _streamingText = '';
    });

    // Stream text word by word (Your exact unchanged typewriter effect)
    final words = response.split(' ');
    for (int i = 0; i < words.length; i++) {
      await Future.delayed(const Duration(milliseconds: 28));
      if (!mounted) return;
      setState(() {
        _streamingText += (i == 0 ? '' : ' ') + words[i];
      });
      if (i % 8 == 0) _scrollToBottom();
    }

    final aiMsg = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: _streamingText,
      isUser: false,
      timestamp: DateTime.now(),
    );

    setState(() {
      _isStreaming = false;
      _streamingText = '';
      _messages.add(aiMsg);
    });

    _scrollToBottom();

    // Refresh the sidebar's session list so a brand-new conversation shows
    // up immediately without waiting for the next screen open.
    _loadChatHistory();
  }

  void _openAddFile() {
    AddFileBottomSheet.show(
      context,
      onCamera: () => _showSnack('Camera opened'),
      onDetection: () => _showSnack('Crop detection started'),
      onFiles: () => _showSnack('File picker opened'),
      onFarmRecords: () => _showSnack('Farm records opened'),
      onAgriTraining: () => _showSnack('Agri training opened'),
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

  Future<void> _loadChatHistory() async {
    try {
      final userId = SupabaseService.currentUserId;
      if (userId == null) return;

      final List<dynamic> data = await SupabaseService.client
          .from('chat_sessions')
          .select('id, title, topic, created_at')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      if (!mounted) return;

      setState(() {
        _realHistory = data.map((item) {
          return ChatHistory(
            id: item['id'].toString(),
            title: item['title'] ?? 'Zokhudza Ulimi',
            lastMessage: item['topic'] ?? 'Agriculture',
            updatedAt: DateTime.parse(item['created_at']),
          );
        }).toList();
      });
    } catch (e) {
      debugPrint('Error loading chat history: $e');
    }
  }

  Future<void> _loadMessagesForSession(String sessionId) async {
    setState(() {
      _isLoading = true;
      _messages.clear();
    });

    try {
      final List<dynamic> data = await SupabaseService.client
          .from('chat_messages')
          .select('id, role, content, created_at')
          .eq('session_id', sessionId)
          .order('created_at', ascending: true);

      if (!mounted) return;

      setState(() {
        for (final msg in data) {
          _messages.add(
            ChatMessage(
              id: msg['id'].toString(),
              text: msg['content'] ?? '',
              isUser: msg['role'] == 'user',
              timestamp: DateTime.parse(msg['created_at']),
            ),
          );
        }
        _activeSessionId = sessionId;
        _isLoading = false;
      });
      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showSnack('Failed to load messages: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      drawer: AcadesDrawer(
        chatHistory: _realHistory,
        onNewChat: () {
          Navigator.pop(context);
          setState(() {
            _messages.clear();
            _inputController.clear();
            _activeSessionId = null;
          });
        },
        onSearchChats: () => _showSnack('Search chats...'),
        onFarmRecords: () => _showSnack('Farm records...'),
        onWeatherAlerts: () => _showSnack('Weather alerts...'),
        onHistoryTap: (historyItem) {
          Navigator.pop(context);
          _loadMessagesForSession(historyItem.id);
        },
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            const Divider(height: 1),
            Expanded(
              child: _messages.isEmpty && !_isLoading && !_isStreaming
                  ? _buildEmptyState()
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      itemCount: _messages.length +
                          (_isLoading ? 1 : 0) +
                          (_isStreaming ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index < _messages.length) {
                          return _buildMessageItem(_messages[index]);
                        } else if (_isLoading) {
                          return _buildTypingIndicator();
                        } else if (_isStreaming) {
                          return _buildStreamingBubble();
                        }
                        return const SizedBox.shrink();
                      },
                    ),
            ),
            ChatInputBar(
              controller: _inputController,
              onSend: () => _sendMessage(_inputController.text),
              onAttach: _openAddFile,
              isLoading: _isLoading || _isStreaming,
            ),
          ],
        ),
      ),
    );
  }

  String _getInitials(String? primary, [String? secondary, String? tertiary]) {
    final parts = <String>[];
    if (primary != null && primary.trim().isNotEmpty) {
      parts.add(primary.trim());
    }
    if (secondary != null && secondary.trim().isNotEmpty) {
      parts.add(secondary.trim());
    }
    if (tertiary != null && tertiary.trim().isNotEmpty) {
      parts.add(tertiary.trim());
    }

    final source = parts.isNotEmpty ? parts.first : '';
    final words =
        source.split(RegExp(r'\s+')).where((word) => word.isNotEmpty).toList();

    if (words.isEmpty) {
      return 'U';
    }

    if (words.length == 1) {
      final value = words.first.replaceAll(RegExp(r'[^A-Za-z0-9]'), '');
      return value.isNotEmpty ? value.substring(0, 1).toUpperCase() : 'U';
    }

    return '${words.first.substring(0, 1).toUpperCase()}${words.last.substring(0, 1).toUpperCase()}';
  }

  Widget _buildAppBar(BuildContext context) {
    final userAsync = ref.watch(currentUserProvider);
    final initials = userAsync.when(
      data: (user) {
        if (user == null) {
          final supabaseUser = SupabaseService.currentUser;
          return _getInitials(
            supabaseUser?.userMetadata?['full_name']?.toString(),
            supabaseUser?.email,
            supabaseUser?.phone,
          );
        }

        return _getInitials(
          user.username,
          user.email,
          user.phoneNumber,
        );
      },
      loading: () => 'U',
      error: (_, __) => 'U',
    );

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
              child: Center(
                child: Text(
                  initials,
                  style: const TextStyle(
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

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.eco_outlined, size: 48, color: AppColors.primaryBorder),
          SizedBox(height: 12),
          Text(
            'Ask me anything about farming',
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageItem(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: message.isUser
          ? _UserBubble(message: message)
          : _AiBubble(
              message: message,
              onThumbUp: () => _showSnack('Feedback: helpful'),
              onThumbDown: () => _showSnack('Feedback: not helpful'),
              onSpeak: () => _showSnack('Text-to-speech started'),
              onRegenerate: () => _showSnack('Regenerating response...'),
            ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.primaryIcon,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primaryBorder, width: 0.5),
            ),
            child: const Icon(Icons.eco_outlined,
                color: AppColors.primary, size: 14),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: AppColors.aiBubble,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomRight: Radius.circular(16),
                bottomLeft: Radius.circular(4),
              ),
            ),
            child: const _TypingDots(),
          ),
        ],
      ),
    );
  }

  Widget _buildStreamingBubble() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.primaryIcon,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primaryBorder, width: 0.5),
            ),
            child: const Icon(Icons.eco_outlined,
                color: AppColors.primary, size: 14),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: AppColors.aiBubble,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                  bottomLeft: Radius.circular(4),
                ),
              ),
              child: _MarkdownText(text: _streamingText),
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Chat bubble widgets
// ──────────────────────────────────────────────

class _UserBubble extends StatelessWidget {
  final ChatMessage message;
  const _UserBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Flexible(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: const BoxDecoration(
              color: AppColors.userBubble,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(4),
              ),
            ),
            child: Text(
              message.text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14.5,
                height: 1.45,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _AiBubble extends StatelessWidget {
  final ChatMessage message;
  final VoidCallback onThumbUp;
  final VoidCallback onThumbDown;
  final VoidCallback onSpeak;
  final VoidCallback onRegenerate;

  const _AiBubble({
    required this.message,
    required this.onThumbUp,
    required this.onThumbDown,
    required this.onSpeak,
    required this.onRegenerate,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: AppColors.primaryIcon,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primaryBorder, width: 0.5),
          ),
          child: const Icon(Icons.eco_outlined,
              color: AppColors.primary, size: 14),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: AppColors.aiBubble,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                    bottomLeft: Radius.circular(4),
                  ),
                ),
                child: _MarkdownText(text: message.text),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  _ActionIcon(
                    icon: Icons.thumb_up_outlined,
                    onTap: onThumbUp,
                  ),
                  const SizedBox(width: 10),
                  _ActionIcon(
                    icon: Icons.thumb_down_outlined,
                    onTap: onThumbDown,
                  ),
                  const SizedBox(width: 10),
                  _ActionIcon(
                    icon: Icons.volume_up_outlined,
                    onTap: onSpeak,
                  ),
                  const Spacer(),
                  _ActionIcon(
                    icon: Icons.refresh_rounded,
                    onTap: onRegenerate,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ActionIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _ActionIcon({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(icon, size: 18, color: AppColors.textMuted),
    );
  }
}

/// Simple inline markdown-style text renderer
class _MarkdownText extends StatelessWidget {
  final String text;
  const _MarkdownText({required this.text});

  @override
  Widget build(BuildContext context) {
    final spans = <InlineSpan>[];
    final lines = text.split('\n');

    for (int li = 0; li < lines.length; li++) {
      final line = lines[li];

      if (li > 0) spans.add(const TextSpan(text: '\n'));

      if (line.startsWith('**') && line.endsWith('**') && line.length > 4) {
        spans.add(TextSpan(
          text: line.substring(2, line.length - 2),
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
            fontSize: 13,
          ),
        ));
      } else if (line.startsWith('• ')) {
        spans.add(const TextSpan(
          text: '• ',
          style:
              TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700),
        ));
        spans.addAll(_parseInlineBold(line.substring(2)));
      } else {
        spans.addAll(_parseInlineBold(line));
      }
    }

    return RichText(
      text: TextSpan(
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 13.5,
          height: 1.55,
          fontFamily: 'Roboto',
        ),
        children: spans,
      ),
    );
  }

  List<InlineSpan> _parseInlineBold(String text) {
    final spans = <InlineSpan>[];
    final regex = RegExp(r'\*\*(.*?)\*\*');
    int last = 0;
    for (final match in regex.allMatches(text)) {
      if (match.start > last) {
        spans.add(TextSpan(text: text.substring(last, match.start)));
      }
      spans.add(TextSpan(
        text: match.group(1),
        style: const TextStyle(fontWeight: FontWeight.w700),
      ));
      last = match.end;
    }
    if (last < text.length) {
      spans.add(TextSpan(text: text.substring(last)));
    }
    return spans;
  }
}

class _TypingDots extends StatefulWidget {
  const _TypingDots();

  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _anims;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      3,
      (i) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 600),
      )..repeat(reverse: true),
    );
    _anims = _controllers
        .asMap()
        .entries
        .map((e) => Tween<double>(begin: 0, end: -6).animate(
              CurvedAnimation(
                parent: e.value,
                curve: Interval(e.key * 0.2, 1.0, curve: Curves.easeInOut),
              ),
            ))
        .toList();

    for (int i = 0; i < _controllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 180), () {
        if (mounted) _controllers[i].repeat(reverse: true);
      });
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        return AnimatedBuilder(
          animation: _anims[i],
          builder: (_, __) => Transform.translate(
            offset: Offset(0, _anims[i].value),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: 7,
              height: 7,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
      }),
    );
  }
}
