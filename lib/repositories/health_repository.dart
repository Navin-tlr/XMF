// lib/repositories/health_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class HealthRepository {
  final String userId;
  final FirebaseFirestore _firestore;

  HealthRepository({required this.userId}) : _firestore = FirebaseFirestore.instance;

  // Centralized method to get the user's profile/targets
  Stream<DocumentSnapshot> userProfileStream() {
    return _firestore.collection('users').doc(userId).snapshots();
  }

  // Centralized method to get today's food log
  Stream<QuerySnapshot> dailyFoodLogStream() {
    final now = DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day);
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('foodLog')
        .where('timestamp', isGreaterThanOrEqualTo: startOfToday)
        .snapshots();
  }
  
  // You can add all other Firestore methods here later,
  // such as logFood, saveWeight, deleteLog, etc.
}