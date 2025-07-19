// lib/providers/application_providers.dart
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rxdart/rxdart.dart';
import 'package:smart_calorie_flutter/data/models/logged_food_item.dart';
import 'package:smart_calorie_flutter/data/models/user_profile.dart';
import 'package:smart_calorie_flutter/data/repositories/health_repository.dart';

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);

final authStateChangesProvider = StreamProvider<User?>((ref) => ref.watch(firebaseAuthProvider).authStateChanges());

enum AppUserState { unknown, unauthenticated, needsOnboarding, authenticated }

final authStateProvider = StateNotifierProvider<AuthStateNotifier, AppUserState>((ref) {
  return AuthStateNotifier(ref);
});

class AuthStateNotifier extends StateNotifier<AppUserState> {
  final Ref _ref;
  StreamSubscription? _profileSubscription;

  AuthStateNotifier(this._ref) : super(AppUserState.unknown) {
    _ref.listen<AsyncValue<User?>>(authStateChangesProvider, (previous, next) {
      final user = next.value;
      _profileSubscription?.cancel();
      if (user == null) {
        state = AppUserState.unauthenticated;
      } else {
        _checkForProfile(user.uid);
      }
    });
  }

  void _checkForProfile(String uid) {
    final repository = _ref.read(healthRepositoryProvider(uid));
    _profileSubscription = repository.userProfileStream().listen((profile) {
      if (profile.birthDate == null) {
        state = AppUserState.needsOnboarding;
      } else {
        state = AppUserState.authenticated;
      }
    }, onError: (error) {
      state = AppUserState.needsOnboarding;
    });
  }

  @override
  void dispose() {
    _profileSubscription?.cancel();
    super.dispose();
  }
}

final healthRepositoryProvider = Provider.family<HealthRepository, String>((ref, userId) {
  return HealthRepository(userId: userId);
});

final userProfileProvider = StreamProvider<UserProfile>((ref) {
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null) return Stream.error("User not authenticated");
  return ref.watch(healthRepositoryProvider(user.uid)).userProfileStream();
});

final foodLogProvider = StreamProvider<List<LoggedFoodItem>>((ref) {
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null) return Stream.error("User not authenticated");
  final today = DateTime.now();
  return ref.watch(healthRepositoryProvider(user.uid)).foodLogStreamForDate(today);
});

final dashboardDataStreamProvider = StreamProvider<(UserProfile, List<LoggedFoodItem>)>((ref) {
  final profileStream = ref.watch(userProfileProvider.stream);
  final foodLogStream = ref.watch(foodLogProvider.stream);
  return CombineLatestStream.combine2(
    profileStream,
    foodLogStream,
    (userProfile, foodLog) => (userProfile, foodLog),
  );
});