// lib/screens/onboarding/onboarding_screen.dart
import 'package:flutter/material.dart';
import 'package:smart_calorie_flutter/app_theme.dart'; // Import added
import 'package:smart_calorie_flutter/home_scaffold.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  String _selectedGoal = 'Get Fitter';
  int _selectedAge = 31;

  void _onNextStep() {
    if (_currentPage < 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScaffold()),
      );
    }
  }

  void _onPreviousStep() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      if (_pageController.page?.round() != _currentPage) {
        setState(() {
          _currentPage = _pageController.page?.round() ?? 0;
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final buttonText = _currentPage < 1 ? 'Next step' : 'Finish';
    return Scaffold(
      backgroundColor: AppTheme.bgElevated,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
              child: Row(
                children: List.generate(2, (index) {
                  return Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      height: 4,
                      decoration: BoxDecoration(
                        color: index <= _currentPage
                            ? AppTheme.textPrimary
                            : Theme.of(context).colorScheme.outline,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  );
                }),
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _GoalSelectionStep(
                    selectedGoal: _selectedGoal,
                    onGoalSelected: (goal) => setState(() => _selectedGoal = goal),
                  ),
                  _AgeSelectionStep(
                    initialAge: _selectedAge,
                    onAgeChanged: (age) => setState(() => _selectedAge = age),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  FilledButton(
                    onPressed: _onNextStep,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      backgroundColor: AppTheme.textPrimary,
                      foregroundColor: AppTheme.bgElevated,
                    ),
                    child: Text(buttonText),
                  ),
                  SizedBox(
                    height: 48,
                    child: _currentPage > 0
                        ? TextButton(
                            onPressed: _onPreviousStep,
                            child: Text('Previous step', style: Theme.of(context).textTheme.bodyMedium),
                          )
                        : null,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GoalSelectionStep extends StatelessWidget {
  final String selectedGoal;
  final ValueChanged<String> onGoalSelected;
  const _GoalSelectionStep({required this.selectedGoal, required this.onGoalSelected});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("What's your goal?", style: Theme.of(context).textTheme.headlineLarge),
          const SizedBox(height: 32),
          _GoalOption(
            title: 'Get Fitter',
            subtitle: 'Tone up & feel healthy',
            icon: Icons.fullscreen_exit_rounded,
            isSelected: selectedGoal == 'Get Fitter',
            onTap: () => onGoalSelected('Get Fitter'),
          ),
          const SizedBox(height: 12),
          _GoalOption(
            title: 'Lose Weight',
            subtitle: 'Burn fat & get lean',
            icon: Icons.format_list_bulleted_rounded,
            isSelected: selectedGoal == 'Lose Weight',
            onTap: () => onGoalSelected('Lose Weight'),
          ),
          const SizedBox(height: 12),
          _GoalOption(
            title: 'Gain Muscle',
            subtitle: 'Build mass & strength',
            icon: Icons.fitness_center_rounded,
            isSelected: selectedGoal == 'Gain Muscle',
            onTap: () => onGoalSelected('Gain Muscle'),
          ),
        ],
      ),
    );
  }
}

class _GoalOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _GoalOption({required this.title, required this.subtitle, required this.icon, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.textPrimary : AppTheme.bgSecondary,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(color: isSelected ? AppTheme.bgElevated : AppTheme.textPrimary)),
                  Text(subtitle, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: isSelected ? AppTheme.bgElevated.withOpacity(0.8) : AppTheme.textTertiary)),
                ],
              ),
            ),
            Icon(icon, color: isSelected ? AppTheme.bgElevated : AppTheme.textPrimary),
          ],
        ),
      ),
    );
  }
}

class _AgeSelectionStep extends StatelessWidget {
  final int initialAge;
  final ValueChanged<int> onAgeChanged;
  const _AgeSelectionStep({required this.initialAge, required this.onAgeChanged});

  @override
  Widget build(BuildContext context) {
    final scrollController = FixedExtentScrollController(initialItem: initialAge - 18);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("How old are you?", style: Theme.of(context).textTheme.headlineLarge),
          const SizedBox(height: 32),
          Expanded(
            child: ListWheelScrollView.useDelegate(
              controller: scrollController,
              itemExtent: 70,
              perspective: 0.005,
              diameterRatio: 1.2,
              physics: const FixedExtentScrollPhysics(),
              onSelectedItemChanged: (index) => onAgeChanged(index + 18),
              childDelegate: ListWheelChildBuilderDelegate(
                childCount: 80,
                builder: (context, index) {
                  final age = index + 18;
                  return Center(
                    child: Text(
                      '$age',
                      style: Theme.of(context).textTheme.displayMedium,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}