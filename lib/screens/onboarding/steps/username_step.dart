import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import 'step_shell.dart';

class UsernameStep extends StatefulWidget {
  final String username;
  final void Function(String) onChanged;
  final VoidCallback? onNext;

  const UsernameStep({
    super.key,
    required this.username,
    required this.onChanged,
    required this.onNext,
  });

  @override
  State<UsernameStep> createState() => _UsernameStepState();
}

class _UsernameStepState extends State<UsernameStep> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.username);
    _controller.addListener(() {
      widget.onChanged(_controller.text);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StepShell(
      emoji: '👤',
      question: 'What\'s your\nname?',
      description: 'This helps us personalise your experience on the platform.',
      onNext: _controller.text.trim().isNotEmpty ? widget.onNext : null,
      buttonLabel:
          _controller.text.trim().isEmpty ? 'Enter your name' : 'Continue',
      choices: Column(
        children: [
          TextField(
            controller: _controller,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) {
              if (_controller.text.trim().isNotEmpty) {
                widget.onNext?.call();
              }
            },
            style: const TextStyle(
              fontSize: 16,
              color: Colors.back,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: 'Enter your full name',
              hintStyle: const TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w400,
              ),
              filled: true,
              fillColor: AppColors.primaryIcon,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.primaryBorder,
                  width: 0.5,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.primaryBorder,
                  width: 0.5,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 1.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.primaryIcon,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primaryBorder, width: 0.5),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline_rounded,
                    color: AppColors.primary, size: 18),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Your name will be used to personalise recommendations and farm records.',
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
