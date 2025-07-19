// lib/core/auth_gate.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_calorie_flutter/features/auth/login_screen.dart';
import 'package:smart_calorie_flutter/features/onboarding/onboarding_screen.dart';
import 'package:smart_calorie_flutter/providers/application_providers.dart';
import 'package:smart_calorie_flutter/shared/widgets/home_scaffold.dart';

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    switch (authState) {
      case AppUserState.authenticated:
        return const HomeScaffold();
      case AppUserState.needsOnboarding:
        return const OnboardingScreen();
      case AppUserState.unauthenticated:
        return const LoginScreen();
      case AppUserState.unknown:
      default:
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
    }
  }
}