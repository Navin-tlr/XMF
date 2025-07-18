import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserProfileService {
  
  // --- Calculation Logic ---

  static double _calculateBmr(String gender, double weight, double height, int age) {
    if (gender == 'Male') return (10 * weight) + (6.25 * height) - (5 * age) + 5;
    return (10 * weight) + (6.25 * height) - (5 * age) - 161;
  }

  static double _calculateTdee(double bmr, String activityLevel) {
    double multiplier = 1.2;
    if (activityLevel == 'Lightly active') multiplier = 1.375;
    if (activityLevel == 'Active') multiplier = 1.55;
    if (activityLevel == 'Very active') multiplier = 1.725;
    return bmr * multiplier;
  }

  static double _calculateCalorieTarget(double tdee, String goal) {
    double adjustment = 0;
    if (goal == 'Cut') adjustment = -500;
    if (goal == 'Bulk') adjustment = 250;
    if (goal == 'Recomp') adjustment = -250;
    return tdee + adjustment;
  }
  
  // NEW: Calculates macronutrient targets in grams
  static Map<String, double> _calculateMacroTargets(double calorieTarget, double weightKg) {
    // Protein: 1.8g per kg of bodyweight (a common recommendation)
    final double proteinGrams = weightKg * 1.8;
    final double proteinCalories = proteinGrams * 4;

    // Fat: 25% of total calories
    final double fatCalories = calorieTarget * 0.25;
    final double fatGrams = fatCalories / 9;

    // Carbs: The remaining calories
    final double carbCalories = calorieTarget - proteinCalories - fatCalories;
    final double carbGrams = carbCalories / 4;

    return {
      'protein': proteinGrams,
      'carbs': carbGrams,
      'fat': fatGrams,
    };
  }
  
  // --- Firebase Interaction ---

  static Future<void> createAndSaveProfile(Map<String, dynamic> profileData) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final bmr = _calculateBmr(profileData['gender'], profileData['weightKg'], profileData['heightCm'], profileData['age']);
    final tdee = _calculateTdee(bmr, profileData['activityLevel']);
    final calorieTarget = _calculateCalorieTarget(tdee, profileData['goal']);
    // NEW: Calculate macros
    final macroTargets = _calculateMacroTargets(calorieTarget, profileData['weightKg']);

    final userData = {
      "email": user.email,
      "createdAt": FieldValue.serverTimestamp(),
      "profile": profileData,
      "targets": {
        "estimatedTdee": tdee.round(),
        "calorieTarget": calorieTarget.round(),
        // NEW: Save macro targets to Firebase
        "proteinTarget": macroTargets['protein']!.round(),
        "carbsTarget": macroTargets['carbs']!.round(),
        "fatTarget": macroTargets['fat']!.round(),
      }
    };

    await FirebaseFirestore.instance.collection('users').doc(user.uid).set(userData);
  }

  static Future<void> updateGoal(String newGoal) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userDocRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
    final doc = await userDocRef.get();
    
    if (!doc.exists) return;

    final profile = doc.data()?['profile'] as Map<String, dynamic>;
    final currentTdee = (doc.data()?['targets']?['estimatedTdee'] as num).toDouble();
    final weightKg = (profile['weightKg'] as num).toDouble();
    
    final newCalorieTarget = _calculateCalorieTarget(currentTdee, newGoal);
    // NEW: Recalculate macros when goal changes
    final newMacroTargets = _calculateMacroTargets(newCalorieTarget, weightKg);

    await userDocRef.update({
      'profile.goal': newGoal,
      'targets.calorieTarget': newCalorieTarget.round(),
      // NEW: Update macro targets in Firebase
      'targets.proteinTarget': newMacroTargets['protein']!.round(),
      'targets.carbsTarget': newMacroTargets['carbs']!.round(),
      'targets.fatTarget': newMacroTargets['fat']!.round(),
    });
  }
}