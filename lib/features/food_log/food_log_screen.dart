// lib/features/food_log/food_log_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_calorie_flutter/providers/application_providers.dart';

class FoodLogScreen extends ConsumerWidget {
  const FoodLogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final foodLogAsync = ref.watch(foodLogProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Today\'s Log'),
      ),
      body: foodLogAsync.when(
        data: (foodItems) {
          if (foodItems.isEmpty) {
            return const Center(child: Text('No food logged yet for today.'));
          }
          return ListView.builder(
            itemCount: foodItems.length,
            itemBuilder: (context, index) {
              final item = foodItems[index];
              return ListTile(
                title: Text(item.name),
                subtitle: Text(item.mealSlot),
                trailing: Text('${item.calories.round()} kcal'),
              );
            },
          );
        },
        error: (err, stack) => Center(child: Text('Error: $err')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}