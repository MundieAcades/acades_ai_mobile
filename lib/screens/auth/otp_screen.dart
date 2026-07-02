import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';
import '../onboarding/onboarding_flow.dart';
import '../home_screen.dart';

class OtpScreen extends StatefulWidget {
  final String phone;
  final FarmerProfile profile;

  const OtpScreen({
    super.key,
    required this.phone,
    required this.profile,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> with TickerProviderStateMixin {
  final List<TextEditingController> _ctrls =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _nodes = List.generate(6, (_) => FocusNode());

  int _secondsLeft = 60;
  Timer? _timer;
  bool _isVerifying = false;
  bool _hasError = false;
  String _errorMsg = '';

  late AnimationController _shakeCtrl;
  late Animation<double> _shakeAnim;
  late AnimationController _successCtrl;
  late Animation<double> _successScale;

  @override
  void initState() {
    super.initState();

    _shakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _shakeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shakeCtrl, curve: Curves.elasticIn),
    );

    _successCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _successScale = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _successCtrl, curve: Curves.elasticOut),
    );

    _startTimer();
    // Auto-focus first box
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _nodes[0].requestFocus();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _ctrls) c.dispose();
    for (final n in _nodes) n.dispose();
    _shakeCtrl.dispose();
    _successCtrl.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _secondsLeft = 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsLeft == 0) {
        t.cancel();
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  String get _otp => _ctrls.map((c) => c.text).join();

  void _onDigitChanged(int index, String val) {
    setState(() => _hasError = false);
    if (val.length > 1) {
      // Handle paste
      final digits = val.replaceAll(RegExp(r'\D'), '');
      for (int i = 0; i < digits.length && i + index < 6; i++) {
        _ctrls[index + i].text = digits[i];
      }
      final next = (index + digits.length).clamp(0, 5);
      _nodes[next].requestFocus();
    } else if (val.isNotEmpty) {
      if (index < 5) _nodes[index + 1].requestFocus();
    }
    if (_otp.length == 6) _verify();
  }

  void _onKeyEvent(int index, RawKeyEvent event) {
    if (event is RawKeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        _ctrls[index].text.isEmpty &&
        index > 0) {
      _nodes[index - 1].requestFocus();
    }
  }

  Future<void> _verify() async {
    if (_isVerifying) return;
    setState(() {
      _isVerifying = true;
      _hasError = false;
    });
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;

    // Demo: "123456" succeeds, anything else fails
    if (_otp == '123456') {
      _successCtrl.forward();
      await Future.delayed(const Duration(milliseconds: 800));
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const HomeScreen(),
          transitionsBuilder: (_, anim, __, child) =>
              FadeTransition(opacity: anim, child: child),
          transitionDuration: const Duration(milliseconds: 500),
        ),
        (_) => false,
      );
    } else {
      setState(() {
        _isVerifying = false;
        _hasError = true;
        _errorMsg = 'Incorrect code. Please try again.';
      });
      _shakeCtrl.forward(from: 0);
      for (final c in _ctrls) c.clear();
      _nodes[0].requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          color: AppColors.textPrimary,
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _successScale,
          builder: (_, child) {
            if (_successCtrl.value > 0.1) {
              return _SuccessOverlay(scale: _successScale.value);
            }
            return child!;
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),

                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.primaryIcon,
                    borderRadius: BorderRadius.circular(16),
                    border:
                        Border.all(color: AppColors.primaryBorder, width: 0.5),
                  ),
                  child: const Center(
                    child: Text('📱', style: TextStyle(fontSize: 26)),
                  ),
                ),
                const SizedBox(height: 20),

                const Text(
                  'Check your\nmessages',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    height: 1.2,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 10),
                RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 15,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                    children: [
                      const TextSpan(text: 'We sent a 6-digit code to '),
                      TextSpan(
                        text: widget.phone,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 36),

                // OTP boxes
                AnimatedBuilder(
                  animation: _shakeAnim,
                  builder: (_, child) => Transform.translate(
                    offset: Offset(
                      _hasError
                          ? 6 *
                              (0.5 - (_shakeAnim.value - 0.5).abs()) *
                              (_shakeAnim.value > 0.5 ? 1 : -1)
                          : 0,
                      0,
                    ),
                    child: child,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(6, (i) {
                      return _OtpBox(
                        controller: _ctrls[i],
                        focusNode: _nodes[i],
                        hasError: _hasError,
                        isVerifying: _isVerifying,
                        onChanged: (v) => _onDigitChanged(i, v),
                        onKey: (e) => _onKeyEvent(i, e),
                      );
                    }),
                  ),
                ),

                const SizedBox(height: 16),

                // Error message
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: _hasError
                      ? Row(
                          key: const ValueKey('error'),
                          children: [
                            const Icon(Icons.error_outline_rounded,
                                color: Colors.red, size: 16),
                            const SizedBox(width: 6),
                            Text(
                              _errorMsg,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.red,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        )
                      : const SizedBox.shrink(key: ValueKey('no_error')),
                ),

                const SizedBox(height: 32),

                // Verify button
                _VerifyButton(
                  enabled: _otp.length == 6 && !_isVerifying,
                  isLoading: _isVerifying,
                  onTap: _verify,
                ),

                const SizedBox(height: 28),

                // Resend / timer
                Center(
                  child: _secondsLeft > 0
                      ? RichText(
                          text: TextSpan(
                            style: const TextStyle(
                                fontSize: 14, color: AppColors.textMuted),
                            children: [
                              const TextSpan(text: 'Resend code in '),
                              TextSpan(
                                text: '${_secondsLeft}s',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        )
                      : GestureDetector(
                          onTap: _startTimer,
                          child: const Text(
                            'Resend code',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                              decoration: TextDecoration.underline,
                              decorationColor: AppColors.primary,
                            ),
                          ),
                        ),
                ),

                const SizedBox(height: 16),
                Center(
                  child: const Text(
                    'Hint: use 123456 to demo login',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textMuted,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OtpBox extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool hasError;
  final bool isVerifying;
  final void Function(String) onChanged;
  final void Function(RawKeyEvent) onKey;

  const _OtpBox({
    required this.controller,
    required this.focusNode,
    required this.hasError,
    required this.isVerifying,
    required this.onChanged,
    required this.onKey,
  });

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      focusNode: FocusNode(),
      onKey: onKey,
      child: ValueListenableBuilder<TextEditingValue>(
        valueListenable: controller,
        builder: (_, val, __) {
          final filled = val.text.isNotEmpty;
          final Color border = hasError
              ? Colors.red.withOpacity(0.7)
              : filled
                  ? AppColors.primary
                  : AppColors.primaryBorder;
          final Color bg = hasError
              ? Colors.red.withOpacity(0.06)
              : filled
                  ? AppColors.primaryIcon
                  : AppColors.inputBg;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 48,
            height: 58,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: border, width: filled ? 1.5 : 0.5),
              boxShadow: filled && !hasError
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      )
                    ]
                  : [],
            ),
            child: Center(
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                maxLength: 1,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: hasError ? Colors.red : AppColors.textPrimary,
                ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  counterText: '',
                  contentPadding: EdgeInsets.zero,
                ),
                onChanged: onChanged,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _VerifyButton extends StatelessWidget {
  final bool enabled;
  final bool isLoading;
  final VoidCallback onTap;

  const _VerifyButton({
    required this.enabled,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: enabled ? AppColors.primary : AppColors.primaryBorder,
          borderRadius: BorderRadius.circular(16),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  )
                ]
              : [],
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
              : const Text(
                  'Verify & continue',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ),
    );
  }
}

class _SuccessOverlay extends StatelessWidget {
  final double scale;
  const _SuccessOverlay({required this.scale});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Transform.scale(
        scale: scale,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.primaryIcon,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primaryBorder, width: 1),
              ),
              child: const Center(
                child: Text('✅', style: TextStyle(fontSize: 48)),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Verified!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Taking you to your farm...',
              style: TextStyle(
                fontSize: 15,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
