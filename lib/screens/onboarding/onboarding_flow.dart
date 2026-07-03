import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../auth/phone_auth_screen.dart';
import 'steps/welcome_step.dart';
import 'steps/username_step.dart';
import 'steps/crop_step.dart';
import 'steps/location_step.dart';
import 'steps/land_size_step.dart';
import 'steps/gender_step.dart';
import 'steps/all_set_step.dart';

/// Holds all the farmer data collected during onboarding
class FarmerProfile {
  String username;
  List<String> crops;
  String district;
  String landSize;
  String gender;

  FarmerProfile({
    this.username = '',
    this.crops = const [],
    this.district = '',
    this.landSize = '',
    this.gender = '',
  });

  FarmerProfile copyWith({
    String? username,
    List<String>? crops,
    String? district,
    String? landSize,
    String? gender,
  }) {
    return FarmerProfile(
      username: username ?? this.username,
      crops: crops ?? this.crops,
      district: district ?? this.district,
      landSize: landSize ?? this.landSize,
      gender: gender ?? this.gender,
    );
  }
}

class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({super.key});

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  FarmerProfile _profile = FarmerProfile();

  // Steps: 0=welcome, 1=username, 2=crops, 3=location, 4=landsize, 5=gender, 6=allset
  static const int _totalSteps = 7;
  // Progress bar covers steps 1–5 (the quiz steps)
  static const int _quizSteps = 5;

  late AnimationController _progressController;
  late Animation<double> _progressAnim;
  double _targetProgress = 0;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _progressAnim = Tween<double>(begin: 0, end: 0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  void _animateProgress(double target) {
    final double from = _progressAnim.value;
    _progressAnim = Tween<double>(begin: from, end: target).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );
    _progressController
      ..reset()
      ..forward();
    _targetProgress = target;
  }

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      setState(() => _currentStep++);
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
      // Update progress for quiz steps 1–5
      if (_currentStep >= 1 && _currentStep <= _quizSteps) {
        _animateProgress(_currentStep / _quizSteps);
      } else if (_currentStep > _quizSteps) {
        _animateProgress(1.0);
      }
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
      if (_currentStep >= 1 && _currentStep <= _quizSteps) {
        _animateProgress((_currentStep) / _quizSteps);
      } else if (_currentStep == 0) {
        _animateProgress(0);
      }
    }
  }

  void _goToAuth() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => PhoneAuthScreen(profile: _profile),
        transitionsBuilder: (_, anim, __, child) => SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  bool get _showProgressBar =>
      _currentStep >= 1 && _currentStep <= _quizSteps + 1;
  bool get _showBackButton =>
      _currentStep > 0 && _currentStep < _totalSteps - 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header: back + progress bar + step label ──
            if (_showProgressBar) _buildHeader(),

            // ── Page content ──
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  // Step 0: Welcome
                  WelcomeStep(onNext: _nextStep),

                  // Step 1: What's your name?
                  UsernameStep(
                    username: _profile.username,
                    onChanged: (u) => setState(
                        () => _profile = _profile.copyWith(username: u)),
                    onNext:
                        _profile.username.trim().isNotEmpty ? _nextStep : null,
                  ),

                  // Step 2: What do you grow?
                  CropStep(
                    selectedCrops: _profile.crops,
                    onChanged: (crops) => setState(
                        () => _profile = _profile.copyWith(crops: crops)),
                    onNext: _profile.crops.isNotEmpty ? _nextStep : null,
                  ),

                  // Step 3: Where are you located?
                  LocationStep(
                    selected: _profile.district,
                    onChanged: (d) => setState(
                        () => _profile = _profile.copyWith(district: d)),
                    onNext: _profile.district.isNotEmpty ? _nextStep : null,
                  ),

                  // Step 4: How big is your land?
                  LandSizeStep(
                    selected: _profile.landSize,
                    onChanged: (s) => setState(
                        () => _profile = _profile.copyWith(landSize: s)),
                    onNext: _profile.landSize.isNotEmpty ? _nextStep : null,
                  ),

                  // Step 5: Gender
                  GenderStep(
                    selected: _profile.gender,
                    onChanged: (g) =>
                        setState(() => _profile = _profile.copyWith(gender: g)),
                    onNext: _profile.gender.isNotEmpty ? _nextStep : null,
                  ),

                  // Step 6: All set!
                  AllSetStep(
                    profile: _profile,
                    onContinue: _goToAuth,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final quizStep = (_currentStep - 1).clamp(0, _quizSteps);
    final labels = [
      'Your name',
      'What you grow',
      'Your location',
      'Land size',
      'About you'
    ];
    final label = quizStep < labels.length ? labels[quizStep] : 'Almost done!';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (_showBackButton)
                GestureDetector(
                  onTap: _prevStep,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.primaryIcon,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: AppColors.primaryBorder, width: 0.5),
                    ),
                    child: const Icon(Icons.arrow_back_ios_new_rounded,
                        size: 16, color: AppColors.primary),
                  ),
                )
              else
                const SizedBox(width: 36),
              const SizedBox(width: 12),
              // Progress bar
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: AnimatedBuilder(
                    animation: _progressAnim,
                    builder: (_, __) => LinearProgressIndicator(
                      value: _progressAnim.value,
                      minHeight: 10,
                      backgroundColor: AppColors.primaryIcon,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.primary),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Step counter pill
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryIcon,
                  borderRadius: BorderRadius.circular(12),
                  border:
                      Border.all(color: AppColors.primaryBorder, width: 0.5),
                ),
                child: Text(
                  '${_currentStep > _quizSteps ? _quizSteps : _currentStep}/$_quizSteps',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          if (_currentStep <= _quizSteps) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 48),
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
