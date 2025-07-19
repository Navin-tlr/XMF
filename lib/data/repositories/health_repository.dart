// lib/data/repositories/health_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_calorie_flutter/data/models/logged_food_item.dart';
import 'package:smart_calorie_flutter/data/models/user_profile.dart';

class HealthRepository {
  final String userId;
  final FirebaseFirestore _firestore;

  HealthRepository({required this.userId}) : _firestore = FirebaseFirestore.instance;

  Future<void> createUserProfile(UserProfile profile) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .set(profile.toFirestore());
  }
  
  Future<void> addFoodLogEntry(LoggedFoodItem item) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('foodLog')
        .add(item.toFirestore());
  }

  Stream<UserProfile> userProfileStream() {
    return _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) {
        throw Exception('User profile does not exist.');
      }
      return UserProfile.fromFirestore(snapshot);
    });
  }

  Stream<List<LoggedFoodItem>> foodLogStreamForDate(DateTime date) {
    final startOfDay = DateTime.utc(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return _firestore
        .collection('users')
        .doc(userId)
        .collection('foodLog')
        .where('timestamp', isGreaterThanOrEqualTo: startOfDay)
        .where('timestamp', isLessThan: endOfDay)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => LoggedFoodItem.fromFirestore(doc))
            .toList());
  }
}