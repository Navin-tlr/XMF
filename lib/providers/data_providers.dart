// lib/providers/data_providers.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_calorie_flutter/repositories/health_repository.dart';

// This provider gives other providers access to the current user's ID.
final userIdProvider = Provider<String?>((ref) {
  return FirebaseAuth.instance.currentUser?.uid;
});

// This provider creates an instance of our repository.
// It will automatically update if the user logs in or out.
final healthRepositoryProvider = Provider<HealthRepository?>((ref) {
  final userId = ref.watch(userIdProvider);
  if (userId == null) return null;
  return HealthRepository(userId: userId);
});

// This provider exposes the user profile stream from the repository.
final userProfileStreamProvider = StreamProvider.autoDispose<DocumentSnapshot>((ref) {
  final repository = ref.watch(healthRepositoryProvider);
  if (repository == null) return const Stream.empty();
  return repository.userProfileStream();
});

// This provider exposes the daily food log stream from the repository.
final foodLogStreamProvider = StreamProvider.autoDispose<QuerySnapshot>((ref) {
  final repository = ref.watch(healthRepositoryProvider);
  if (repository == null) return const Stream.empty();
  return repository.dailyFoodLogStream();
});