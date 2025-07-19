// lib/features/dashboard/dashboard_viewmodel.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_calorie_flutter/data/models/logged_food_item.dart';
import 'package:smart_calorie_flutter/data/models/user_profile.dart';
import 'package:smart_calorie_flutter/features/dashboard/models/dashboard_block_models.dart';
import 'package:smart_calorie_flutter/providers/application_providers.dart';

final dashboardViewModelProvider =
    StateNotifierProvider<DashboardViewModel, AsyncValue<List<BaseBlockModel>>>((ref) {
  return DashboardViewModel(ref);
});

class DashboardViewModel extends StateNotifier<AsyncValue<List<BaseBlockModel>>> {
  final Ref _ref;
  StreamSubscription? _subscription;

  DashboardViewModel(this._ref) : super(const AsyncValue.loading()) {
    _init();
  }

  void _init() {
    _subscription = _ref.read(dashboardDataStreamProvider.stream).listen((data) {
      final userProfile = data.$1;
      final foodLog = data.$2;
      final blocks = _buildBlockModels(userProfile, foodLog);
      state = AsyncValue.data(blocks);
    }, onError: (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    });
  }

  List<BaseBlockModel> _buildBlockModels(
      UserProfile userProfile, List<LoggedFoodItem> foodLog) {
    final calorieGoal = 2200.0;
    final caloriesEaten = foodLog.fold<double>(0, (sum, item) => sum + item.calories);
    final caloriesLeft = calorieGoal - caloriesEaten;

    final breakfastItems = foodLog.where((i) => i.mealSlot == 'Breakfast').toList();
    final lunchItems = foodLog.where((i) => i.mealSlot == 'Lunch').toList();
    final dinnerItems = foodLog.where((i) => i.mealSlot == 'Dinner').toList();

    final breakfastCalories = breakfastItems.fold<double>(0, (sum, item) => sum + item.calories);
    final lunchCalories = lunchItems.fold<double>(0, (sum, item) => sum + item.calories);
    final dinnerCalories = dinnerItems.fold<double>(0, (sum, item) => sum + item.calories);

    return [
      CalorieSummaryModel(
        id: 'summary',
        caloriesLeft: caloriesLeft,
        caloriesEaten: caloriesEaten,
        caloriesBurned: 0,
        goal: calorieGoal,
      ),
      MacronutrientsModel(
        id: 'macros',
        carbsConsumed: 133, carbsGoal: 267,
        fatConsumed: 53, fatGoal: 107,
        proteinConsumed: 36, proteinGoal: 71,
      ),
      MealModel(
        id: 'breakfast',
        mealType: 'Breakfast',
        icon: Icons.free_breakfast, // <-- CORRECTED
        caloriesConsumed: breakfastCalories,
        calorieGoal: 437,
        foodItems: breakfastItems,
      ),
       MealModel(
        id: 'lunch',
        mealType: 'Lunch',
        icon: Icons.lunch_dining, // <-- CORRECTED
        caloriesConsumed: lunchCalories,
        calorieGoal: 500,
        foodItems: lunchItems,
      ),
      MealModel(
        id: 'dinner',
        mealType: 'Dinner',
        icon: Icons.dinner_dining, // <-- CORRECTED
        caloriesConsumed: dinnerCalories,
        calorieGoal: 600,
        foodItems: dinnerItems,
      ),
    ];
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}