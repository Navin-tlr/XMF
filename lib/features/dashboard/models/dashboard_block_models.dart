// lib/features/dashboard/models/dashboard_block_models.dart
import 'package:flutter/material.dart'; // <-- CORRECTED: Added this import
import 'package:smart_calorie_flutter/data/models/logged_food_item.dart';

abstract class BaseBlockModel {
  final String id;
  BaseBlockModel({required this.id});
}

class CalorieSummaryModel extends BaseBlockModel {
  final double caloriesLeft;
  final double caloriesEaten;
  final double caloriesBurned;
  final double goal;
  double get progress => (goal > 0) ? caloriesEaten / goal : 0.0;

  CalorieSummaryModel({
    required super.id,
    required this.caloriesLeft,
    required this.caloriesEaten,
    required this.caloriesBurned,
    required this.goal,
  });
}

class MacronutrientsModel extends BaseBlockModel {
  final double carbsConsumed, carbsGoal;
  final double fatConsumed, fatGoal;
  final double proteinConsumed, proteinGoal;

  double get carbsProgress => (carbsGoal > 0) ? carbsConsumed / carbsGoal : 0.0;
  double get fatProgress => (fatGoal > 0) ? fatConsumed / fatGoal : 0.0;
  double get proteinProgress => (proteinGoal > 0) ? proteinConsumed / proteinGoal : 0.0;

  MacronutrientsModel({
    required super.id,
    required this.carbsConsumed, required this.carbsGoal,
    required this.fatConsumed, required this.fatGoal,
    required this.proteinConsumed, required this.proteinGoal,
  });
}

class MealModel extends BaseBlockModel {
  final String mealType;
  final IconData icon;
  final double caloriesConsumed;
  final double calorieGoal;
  final List<LoggedFoodItem> foodItems;

  MealModel({
    required super.id,
    required this.mealType,
    required this.icon,
    required this.caloriesConsumed,
    required this.calorieGoal,
    required this.foodItems,
  });
}