// lib/features/food_log/food_search_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_calorie_flutter/app_theme.dart';
import 'package:smart_calorie_flutter/data/models/logged_food_item.dart';
import 'package:smart_calorie_flutter/providers/application_providers.dart';

class SearchResultItem {
  final String name;
  final double calories;
  SearchResultItem({required this.name, required this.calories});
}

class FoodSearchScreen extends ConsumerStatefulWidget {
  final String meal;
  const FoodSearchScreen({super.key, required this.meal});

  @override
  ConsumerState<FoodSearchScreen> createState() => _FoodSearchScreenState();
}

class _FoodSearchScreenState extends ConsumerState<FoodSearchScreen> {
  bool _isLoading = false;
  final _searchResults = [
    SearchResultItem(name: 'Scrambled Eggs', calories: 140),
    SearchResultItem(name: 'Slice of Toast', calories: 80),
    SearchResultItem(name: 'Avocado (half)', calories: 160),
    SearchResultItem(name: 'Chicken Breast (100g)', calories: 165),
    SearchResultItem(name: 'Paneer Tikka (1 serving)', calories: 250),
    SearchResultItem(name: 'Dal Tadka (1 bowl)', calories: 180),
  ];

  Future<void> _logFood(SearchResultItem foodItem) async {
    setState(() => _isLoading = true);
    final user = ref.read(firebaseAuthProvider).currentUser;
    if (user == null) return;

    final newLog = LoggedFoodItem(
      name: foodItem.name,
      calories: foodItem.calories,
      mealSlot: widget.meal,
      timestamp: DateTime.now().toUtc(),
    );

    try {
      await ref.read(healthRepositoryProvider(user.uid)).addFoodLogEntry(newLog);
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error logging food: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        height: MediaQuery.of(context).size.height * 0.9,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const TextField(
              decoration: InputDecoration(
                hintText: 'Search for a food...',
                prefixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  final item = _searchResults[index];
                  return ListTile(
                    title: Text(item.name),
                    subtitle: Text('${item.calories.round()} kcal'),
                    trailing: _isLoading
                        ? const CircularProgressIndicator()
                        : IconButton(
                            icon: const Icon(Icons.add_circle_outline, color: AppTheme.accentBlue),
                            onPressed: () => _logFood(item),
                          ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}