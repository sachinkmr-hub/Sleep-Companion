import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:neend_companion/app/theme/app_colors.dart';
import 'package:neend_companion/features/onboarding/onboarding_controller.dart';
import 'package:neend_companion/data/repositories/user_repository.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late PageController _pageController;
  late OnboardingController _controller;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _controller = OnboardingController();
    _controller.addListener(_onControllerChange);
  }

  void _onControllerChange() {
    setState(() {});
  }

  @override
  void dispose() {
    _pageController.dispose();
    _controller.removeListener(_onControllerChange);
    _controller.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_controller.currentPage < 4) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  void _previousPage() {
    if (_controller.currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _finishOnboarding() async {
    await _controller.saveProfile();
    if (mounted) {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.nightBackground,
      body: SafeArea(
        child: Column(
          children: [
            if (_controller.currentPage > 0 && _controller.currentPage < 4)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: AppColors.nightTextMuted),
                      onPressed: _previousPage,
                    ),
                    TextButton(
                      onPressed: _nextPage,
                      child: const Text('Skip', style: TextStyle(color: AppColors.nightTextMuted)),
                    ),
                  ],
                ),
              )
            else if (_controller.currentPage == 4)
               Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: AppColors.nightTextMuted),
                      onPressed: _previousPage,
                    ),
                  ],
                ),
              )
            else
               const SizedBox(height: 64),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: _controller.setPage,
                children: [
                  _buildWelcomeStep(),
                  _buildGoalsStep(),
                  _buildStyleStep(),
                  _buildTimesStep(),
                  _buildCompleteStep(),
                ],
              ),
            ),
            _buildPageIndicators(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeStep() {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Neend',
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: AppColors.nightTextPrimary,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Your personal sleep & morning companion',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              color: AppColors.nightTextMuted,
            ),
          ),
          const SizedBox(height: 64),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.nightAccent,
              foregroundColor: AppColors.nightBackground,
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            onPressed: _nextPage,
            child: const Text('Get Started', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalsStep() {
    final goals = [
      'Sleep better',
      'Wake up better',
      'Relax after stressful days',
      'Build a morning routine',
      'Stay consistent with goals'
    ];

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'What do you want help with?',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.nightTextPrimary,
            ),
          ),
          const SizedBox(height: 32),
          Wrap(
            spacing: 12,
            runSpacing: 16,
            children: goals.map((goal) {
              final isSelected = _controller.selectedGoals.contains(goal);
              return ChoiceChip(
                label: Text(goal),
                selected: isSelected,
                onSelected: (_) => _controller.toggleGoal(goal),
                selectedColor: AppColors.nightAccent,
                backgroundColor: AppColors.nightSurface,
                labelStyle: TextStyle(
                  color: isSelected ? AppColors.nightBackground : AppColors.nightTextPrimary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              );
            }).toList(),
          ),
          const Spacer(),
          _buildNextButton(),
        ],
      ),
    );
  }

  Widget _buildStyleStep() {
    final styles = [
      {'name': 'Calm', 'icon': '🌊'},
      {'name': 'Warm', 'icon': '☀️'},
      {'name': 'Minimal', 'icon': '✨'},
      {'name': 'Motivating', 'icon': '🔥'},
    ];

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'What kind of experience do you prefer?',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.nightTextPrimary,
            ),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: styles.map((style) {
                final isSelected = _controller.selectedStyle == style['name'];
                return GestureDetector(
                  onTap: () => _controller.setStyle(style['name']!),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: AppColors.nightSurface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? AppColors.nightAccent : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(style['icon']!, style: const TextStyle(fontSize: 48)),
                        const SizedBox(height: 16),
                        Text(
                          style['name']!,
                          style: TextStyle(
                            color: isSelected ? AppColors.nightAccent : AppColors.nightTextPrimary,
                            fontSize: 18,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          _buildNextButton(),
        ],
      ),
    );
  }

  Widget _buildTimesStep() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'When do you usually sleep?',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.nightTextPrimary,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 120,
            child: CupertinoTheme(
              data: const CupertinoThemeData(
                textTheme: CupertinoTextThemeData(
                  pickerTextStyle: TextStyle(color: AppColors.nightTextPrimary, fontSize: 24),
                ),
              ),
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.time,
                initialDateTime: DateTime(2023, 1, 1, 23, 0),
                onDateTimeChanged: (DateTime newDateTime) {
                  final timeStr = "${newDateTime.hour > 12 ? newDateTime.hour - 12 : (newDateTime.hour == 0 ? 12 : newDateTime.hour)}:${newDateTime.minute.toString().padLeft(2, '0')} ${newDateTime.hour >= 12 ? 'PM' : 'AM'}";
                  _controller.setSleepTime(timeStr);
                },
              ),
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'When do you usually wake up?',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.nightTextPrimary,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 120,
            child: CupertinoTheme(
              data: const CupertinoThemeData(
                textTheme: CupertinoTextThemeData(
                  pickerTextStyle: TextStyle(color: AppColors.nightTextPrimary, fontSize: 24),
                ),
              ),
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.time,
                initialDateTime: DateTime(2023, 1, 1, 7, 0),
                onDateTimeChanged: (DateTime newDateTime) {
                  final timeStr = "${newDateTime.hour > 12 ? newDateTime.hour - 12 : (newDateTime.hour == 0 ? 12 : newDateTime.hour)}:${newDateTime.minute.toString().padLeft(2, '0')} ${newDateTime.hour >= 12 ? 'PM' : 'AM'}";
                  _controller.setWakeTime(timeStr);
                },
              ),
            ),
          ),
          const Spacer(),
          _buildNextButton(),
        ],
      ),
    );
  }

  Widget _buildCompleteStep() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'You\'re all set!',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: AppColors.nightTextPrimary,
            ),
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.nightSurface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                _buildSummaryRow(Icons.bedtime, 'Sleep', _controller.sleepTime),
                const SizedBox(height: 16),
                _buildSummaryRow(Icons.wb_sunny, 'Wake', _controller.wakeTime),
                const SizedBox(height: 16),
                _buildSummaryRow(Icons.color_lens, 'Style', _controller.selectedStyle ?? 'Calm'),
              ],
            ),
          ),
          const SizedBox(height: 64),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.nightAccent,
              foregroundColor: AppColors.nightBackground,
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              minimumSize: const Size(double.infinity, 56),
            ),
            onPressed: _finishOnboarding,
            child: const Text('Begin', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: AppColors.nightAccent),
        const SizedBox(width: 16),
        Text(label, style: const TextStyle(color: AppColors.nightTextMuted, fontSize: 16)),
        const Spacer(),
        Text(value, style: const TextStyle(color: AppColors.nightTextPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildNextButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.nightAccent,
          foregroundColor: AppColors.nightBackground,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        onPressed: _nextPage,
        child: const Text('Continue', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildPageIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        5,
        (index) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _controller.currentPage == index
                ? AppColors.nightAccent
                : AppColors.nightTextMuted.withOpacity(0.3),
          ),
        ),
      ),
    );
  }
}
