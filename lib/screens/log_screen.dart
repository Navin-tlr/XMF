// lib/screens/log_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:smart_calorie_flutter/app_theme.dart';
import 'package:smart_calorie_flutter/screens/food_search_screen.dart';

class LogScreen extends StatelessWidget {
  const LogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Food Log'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: const [
          _MealSection(meal: 'Breakfast', icon: Icons.free_breakfast_outlined),
          _MealSection(meal: 'Lunch', icon: Icons.lunch_dining_outlined),
          _MealSection(meal: 'Dinner', icon: Icons.dinner_dining_outlined),
          _MealSection(meal: 'Snacks', icon: Icons.fastfood_outlined),
        ],
      ),
    );
  }
}

class _MealSection extends StatelessWidget {
  final String meal;
  final IconData icon;

  const _MealSection({required this.meal, required this.icon});

  @override
  Widget build(BuildContext context) {
    // This widget now uses dummy data for consistency with the prototype
    int totalCalories = 550;
    final documents = [1, 2]; // Dummy list to show items

    return _BaseTile(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _MealHeader(
            meal: meal,
            icon: icon,
            totalCalories: totalCalories,
          ),
          const Divider(height: 24),
          if (documents.isEmpty)
            const Center(child: Text('No food logged yet'))
          else
            Column(
              children: const [
                _FoodListItem(name: 'Scrambled Eggs', kcal: '320 kcal'),
                _FoodListItem(name: 'Toast with Avocado', kcal: '230 kcal'),
              ],
            ),
        ],
      ),
    );
  }
}

class _MealHeader extends StatelessWidget {
  final String meal;
  final IconData icon;
  final int totalCalories;

  const _MealHeader({required this.meal, required this.icon, required this.totalCalories});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Theme.of(context).textTheme.bodyMedium?.color),
        const SizedBox(width: 12),
        Text(meal, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(width: 12),
        Text('$totalCalories kcal', style: Theme.of(context).textTheme.bodyMedium),
        const Spacer(),
        IconButton(
          onPressed: () {
            // THE FIX: Use showModalBottomSheet for a consistent UX
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: AppTheme.bgSecondary,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              builder: (context) {
                return SizedBox(
                  height: MediaQuery.of(context).size.height * 0.85,
                  child: FoodSearchScreen(meal: meal),
                );
              },
            );
          },
          icon: const Icon(Icons.add_circle_outline, color: AppTheme.accentGreen),
        ),
      ],
    );
  }
}

class _FoodListItem extends StatelessWidget {
  final String name;
  final String kcal;
  const _FoodListItem({required this.name, required this.kcal});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(name, style: Theme.of(context).textTheme.bodyLarge),
          Text(kcal, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}


class _BaseTile extends StatelessWidget {
  final Widget child;
  const _BaseTile({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.bgElevated,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).colorScheme.outline)
      ),
      child: child,
    );
  }
}