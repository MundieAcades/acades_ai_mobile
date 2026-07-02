import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';
import '../onboarding/onboarding_flow.dart';
import 'otp_screen.dart';
import 'terms_screen.dart';

class PhoneAuthScreen extends StatefulWidget {
  final FarmerProfile profile;
  const PhoneAuthScreen({super.key, required this.profile});

  @override
  State<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _phoneCtrl = TextEditingController();
  bool _agreedToTerms = false;
  bool _isLoading = false;
  String _selectedCode = '+265';

  late AnimationController _fadeCtrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  static const _countryCodes = ['+265', '+27', '+254', '+255', '+256', '+260'];

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();
    _fade = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeIn));
    _slide = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero)
        .animate(CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  bool get _canProceed =>
      _phoneCtrl.text.length >= 7 && _agreedToTerms && !_isLoading;

  Future<void> _sendOtp() async {
    if (!_canProceed) return;
    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    // Simulate network call
    await Future.delayed(const Duration(milliseconds: 1400));

    if (!mounted) return;
    setState(() => _isLoading = false);

    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => OtpScreen(
          phone: '$_selectedCode ${_phoneCtrl.text}',
          profile: widget.profile,
        ),
        transitionsBuilder: (_, anim, __, child) => SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 350),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fade,
          child: SlideTransition(
            position: _slide,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),

                  // Logo mark
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.primaryIcon,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: AppColors.primaryBorder, width: 0.5),
                    ),
                    child: const Icon(Icons.eco_rounded,
                        color: AppColors.primary, size: 28),
                  ),
                  const SizedBox(height: 24),

                  const Text(
                    'Enter your\nphone number',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      height: 1.2,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "We'll send you a one-time code to verify it's really you.",
                    style: TextStyle(
                      fontSize: 15,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 36),

                  // Phone input
                  const Text(
                    'MOBILE NUMBER',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textMuted,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.inputBg,
                      borderRadius: BorderRadius.circular(16),
                      border:
                          Border.all(color: AppColors.primaryBorder, width: 0.5),
                    ),
                    child: Row(
                      children: [
                        // Country code picker
                        GestureDetector(
                          onTap: _showCodePicker,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 16),
                            decoration: const BoxDecoration(
                              border: Border(
                                right: BorderSide(
                                    color: AppColors.primaryBorder, width: 0.5),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Text('🇲🇼',
                                    style: TextStyle(fontSize: 18)),
                                const SizedBox(width: 6),
                                Text(
                                  _selectedCode,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(Icons.keyboard_arrow_down_rounded,
                                    size: 18, color: AppColors.textMuted),
                              ],
                            ),
                          ),
                        ),
                        // Number input
                        Expanded(
                          child: TextField(
                            controller: _phoneCtrl,
                            keyboardType: TextInputType.phone,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(12),
                            ],
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textPrimary,
                              letterSpacing: 1.5,
                            ),
                            decoration: const InputDecoration(
                              hintText: '0888 000 000',
                              hintStyle: TextStyle(
                                fontSize: 16,
                                color: AppColors.textHint,
                                letterSpacing: 1.0,
                                fontWeight: FontWeight.w400,
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 16),
                            ),
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                        if (_phoneCtrl.text.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: GestureDetector(
                              onTap: () {
                                _phoneCtrl.clear();
                                setState(() {});
                              },
                              child: const Icon(Icons.cancel_rounded,
                                  color: AppColors.textMuted, size: 20),
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Terms & conditions row
                  GestureDetector(
                    onTap: () => setState(() => _agreedToTerms = !_agreedToTerms),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            color: _agreedToTerms
                                ? AppColors.primary
                                : AppColors.white,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: _agreedToTerms
                                  ? AppColors.primary
                                  : AppColors.primaryBorder,
                              width: 1.5,
                            ),
                          ),
                          child: _agreedToTerms
                              ? const Icon(Icons.check_rounded,
                                  color: Colors.white, size: 14)
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                                height: 1.5,
                              ),
                              children: [
                                const TextSpan(text: 'I agree to the '),
                                WidgetSpan(
                                  child: GestureDetector(
                                    onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const TermsScreen(),
                                      ),
                                    ),
                                    child: const Text(
                                      'Terms of Service',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w600,
                                        decoration: TextDecoration.underline,
                                        decorationColor: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                ),
                                const TextSpan(text: ' and '),
                                WidgetSpan(
                                  child: GestureDetector(
                                    onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const TermsScreen(showPrivacy: true),
                                      ),
                                    ),
                                    child: const Text(
                                      'Privacy Policy',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w600,
                                        decoration: TextDecoration.underline,
                                        decorationColor: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                ),
                                const TextSpan(
                                    text:
                                        '. Acades AI will never share your data with advertisers.'),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Send OTP button
                  _SendButton(
                    enabled: _canProceed,
                    isLoading: _isLoading,
                    onTap: _sendOtp,
                  ),

                  const SizedBox(height: 24),

                  // Secure note
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.shield_outlined,
                          color: AppColors.textMuted, size: 14),
                      SizedBox(width: 6),
                      Text(
                        'Verified with a one-time SMS code',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showCodePicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.primaryBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Select country code',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            ..._countryCodes.map((code) => ListTile(
                  title: Text(code,
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w500)),
                  trailing: _selectedCode == code
                      ? const Icon(Icons.check_rounded, color: AppColors.primary)
                      : null,
                  onTap: () {
                    setState(() => _selectedCode = code);
                    Navigator.pop(context);
                  },
                )),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class _SendButton extends StatelessWidget {
  final bool enabled;
  final bool isLoading;
  final VoidCallback onTap;

  const _SendButton({
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
                  'Send verification code',
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
