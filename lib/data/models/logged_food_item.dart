// lib/data/models/logged_food_item.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class LoggedFoodItem {
  final String name;
  final double calories;
  final String mealSlot;
  final DateTime timestamp;

  LoggedFoodItem({
    required this.name,
    required this.calories,
    required this.mealSlot,
    required this.timestamp,
  });

  factory LoggedFoodItem.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return LoggedFoodItem(
      name: data['name'] ?? 'Unknown Food',
      calories: (data['calories'] as num?)?.toDouble() ?? 0.0,
      mealSlot: data['mealSlot'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }
  
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'calories': calories,
      'mealSlot': mealSlot,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}