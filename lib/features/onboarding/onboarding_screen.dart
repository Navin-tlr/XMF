// lib/features/onboarding/onboarding_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:smart_calorie_flutter/data/models/user_profile.dart';
import 'package:smart_calorie_flutter/providers/application_providers.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  DateTime _selectedDate = DateTime.now().subtract(const Duration(days: 365 * 25));
  String _selectedSex = 'male';
  bool _isLoading = false;

  Future<void> _completeOnboarding() async {
    setState(() => _isLoading = true);
    final user = ref.read(firebaseAuthProvider).currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Not signed in.')),
      );
      setState(() => _isLoading = false);
      return;
    }

    final profile = UserProfile(
      uid: user.uid,
      email: user.email ?? '',
      birthDate: _selectedDate,
      sex: _selectedSex,
      timeZone: DateTime.now().timeZoneName,
      goal: 'maintain',
    );

    try {
      await ref.read(healthRepositoryProvider(user.uid)).createUserProfile(profile);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save profile: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tell Us About Yourself'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('What is your date of birth?'),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () async {
                final pickedDate = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(1920),
                  lastDate: DateTime.now(),
                );
                if (pickedDate != null) {
                  setState(() => _selectedDate = pickedDate);
                }
              },
              child: Text(DateFormat.yMMMd().format(_selectedDate)),
            ),
            const SizedBox(height: 32),
            const Text('What is your sex?'),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'male', label: Text('Male')),
                ButtonSegment(value: 'female', label: Text('Female')),
              ],
              selected: {_selectedSex},
              onSelectionChanged: (newSelection) {
                setState(() => _selectedSex = newSelection.first);
              },
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _isLoading ? null : _completeOnboarding,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Complete Onboarding'),
            ),
          ],
        ),
      ),
    );
  }
}