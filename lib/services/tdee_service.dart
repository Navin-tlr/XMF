import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// --- Data Models for Input/Output ---

class WeightEntry {
  final DateTime date;
  final double weightKg;
  WeightEntry({required this.date, required this.weightKg});
}

class CalorieEntry {
  final DateTime date;
  final double calories;
  CalorieEntry({required this.date, required this.calories});
}

class AlgorithmOutput {
  final double estimatedTdee;
  final double weightTrendPerWeek;
  final double newCalorieTarget;
  final String adjustmentReasoning;

  AlgorithmOutput({
    required this.estimatedTdee,
    required this.weightTrendPerWeek,
    required this.newCalorieTarget,
    required this.adjustmentReasoning,
  });
}

// --- The Main Algorithm Class ---

class AdaptiveAlgorithm {
  static const double _emaAlpha = 0.2;
  static const int _kcalPerKg = 7700;

  static Future<AlgorithmOutput> runWeeklyUpdate() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('User not logged in');

    final firestore = FirebaseFirestore.instance;
    final userDocRef = firestore.collection('users').doc(user.uid);

    final endDate = DateTime.now();
    // We need at least 14 days of data for a stable EMA and trend
    final startDate = endDate.subtract(const Duration(days: 14));

    // Fetch weight and calorie logs
    final weightQuery = await userDocRef.collection('weightLog').where('timestamp', isGreaterThanOrEqualTo: startDate).orderBy('timestamp').get();
    final calorieQuery = await userDocRef.collection('foodLog').where('timestamp', isGreaterThanOrEqualTo: startDate).orderBy('timestamp').get();

    // Convert Firestore data to our local models
    final weightHistory = weightQuery.docs.map((doc) => WeightEntry(date: (doc['timestamp'] as Timestamp).toDate(), weightKg: (doc['weight'] as num).toDouble())).toList();
    
    // Group calories by day
    final Map<DateTime, double> dailyCalories = {};
    for (var doc in calorieQuery.docs) {
      final date = (doc['timestamp'] as Timestamp).toDate();
      final dayOnly = DateTime(date.year, date.month, date.day);
      final calories = (doc['calories'] as num).toDouble();
      dailyCalories.update(dayOnly, (value) => value + calories, ifAbsent: () => calories);
    }
    final calorieHistory = dailyCalories.entries.map((e) => CalorieEntry(date: e.key, calories: e.value)).toList();
    
    if (weightHistory.length < 7 || calorieHistory.length < 7) {
      // Check for at least 7 days of data in the period
      throw Exception("Not enough data to calculate targets. Please continue logging for at least another week.");
    }
    
    // --- Begin Algorithm Steps ---
    final smoothedWeights = _getSmoothedWeight(weightHistory);
    final last7DaysSmoothed = smoothedWeights.length > 7 ? smoothedWeights.sublist(smoothedWeights.length - 8) : smoothedWeights;
    final weightTrendPerWeek = last7DaysSmoothed.last - last7DaysSmoothed.first;

    final last7DaysCalories = calorieHistory.where((c) => c.date.isAfter(DateTime.now().subtract(const Duration(days: 8)))).toList();
    final avgCalories = last7DaysCalories.map((c) => c.calories).reduce((a, b) => a + b) / last7DaysCalories.length;
    
    final tdee = avgCalories - (weightTrendPerWeek * _kcalPerKg / 7);
    
    final userProfile = await userDocRef.get();
    final goal = userProfile.data()?['profile']?['goal'] ?? 'Maintain';
    
    return _calculateNewTarget(
      goal: goal,
      currentTdee: tdee,
      actualWeightTrend: weightTrendPerWeek
    );
  }

  static List<double> _getSmoothedWeight(List<WeightEntry> weights) {
    List<double> smoothed = [];
    if (weights.isEmpty) return smoothed;
    smoothed.add(weights.first.weightKg);
    for (int i = 1; i < weights.length; i++) {
      double newEma = (weights[i].weightKg * _emaAlpha) + (smoothed[i - 1] * (1 - _emaAlpha));
      smoothed.add(newEma);
    }
    return smoothed;
  }
  
  static AlgorithmOutput _calculateNewTarget({
    required String goal,
    required double currentTdee,
    required double actualWeightTrend,
  }) {
    double newTarget = currentTdee;
    String reasoning = "Your target is updated based on your TDEE of ${currentTdee.toStringAsFixed(0)} kcal.";

    switch (goal) {
      case 'Cut':
        newTarget = currentTdee - 500;
        if (actualWeightTrend >= 0) {
          newTarget -= 150;
          reasoning = "You're not losing weight as expected. We've adjusted your target down more aggressively.";
        }
        break;
      case 'Bulk':
        newTarget = currentTdee + 250;
        if (actualWeightTrend <= 0) {
          newTarget += 100;
          reasoning = "You're not gaining weight as expected. We've increased your calorie surplus.";
        }
        break;
      case 'Recomp':
        newTarget = currentTdee - 250;
        reasoning += " Your recomp target prioritizes fat loss while building muscle.";
        break;
      case 'Maintain':
      default:
        newTarget = currentTdee;
        break;
    }
    
    return AlgorithmOutput(
      estimatedTdee: currentTdee,
      weightTrendPerWeek: actualWeightTrend,
      newCalorieTarget: newTarget,
      adjustmentReasoning: reasoning,
    );
  }
}