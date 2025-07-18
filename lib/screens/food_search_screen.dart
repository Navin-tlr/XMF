// lib/screens/food_search_screen.dart
import 'package:flutter/material.dart';
import 'package:smart_calorie_flutter/app_theme.dart';

// Dummy data model
class FoodBlockItem {
  final String id;
  final String emoji;
  final String name;
  final String portion;
  final int calories;
  final int protein;
  final int carbs;
  final int fat;

  FoodBlockItem({
    required this.id,
    required this.emoji,
    required this.name,
    required this.portion,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });
}

class FoodSearchScreen extends StatefulWidget {
  final String meal;
  const FoodSearchScreen({super.key, required this.meal});

  @override
  State<FoodSearchScreen> createState() => _FoodSearchScreenState();
}

class _FoodSearchScreenState extends State<FoodSearchScreen> {
  final List<FoodBlockItem> _foodLog = [
    FoodBlockItem(id: '1', emoji: '🍳', name: 'Eggs', portion: '2 large', calories: 156, protein: 12, carbs: 1, fat: 11),
    FoodBlockItem(id: '2', emoji: '🍞', name: 'Sourdough Toast', portion: '1 slice', calories: 75, protein: 2, carbs: 13, fat: 1),
    FoodBlockItem(id: '3', emoji: '🥑', name: 'Avocado', portion: '0.5 medium', calories: 161, protein: 2, carbs: 9, fat: 15),
  ];
  
  String? _editingItemId;

  @override
  Widget build(BuildContext context) {
    // THE FIX: Wrap the entire content in a Material widget.
    return Material(
      color: Colors.transparent, // The color is handled by the modal sheet itself.
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(color: AppTheme.textDisabled, borderRadius: BorderRadius.circular(10)),
            ),
            const SizedBox(height: 24),
            TextField(
              decoration: InputDecoration(
                hintText: "Search or add food...",
                prefixIcon: const Icon(Icons.search, color: AppTheme.textTertiary),
                filled: true,
                fillColor: AppTheme.bgPrimary,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView.separated(
                itemCount: _foodLog.length,
                itemBuilder: (context, index) {
                  final item = _foodLog[index];
                  return _FoodBlock(
                    item: item,
                    isEditing: _editingItemId == item.id,
                    onTap: () {
                      setState(() {
                        if (_editingItemId == item.id) {
                          _editingItemId = null;
                        } else {
                          _editingItemId = item.id;
                        }
                      });
                    },
                  );
                },
                separatorBuilder: (context, index) => const SizedBox(height: 8),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () {},
              style: FilledButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
              child: const Text("Log All Items"),
            )
          ],
        ),
      ),
    );
  }
}

class _FoodBlock extends StatelessWidget {
  final FoodBlockItem item;
  final bool isEditing;
  final VoidCallback onTap;

  const _FoodBlock({required this.item, required this.isEditing, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.bgElevated,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isEditing ? AppTheme.accentGreen : Theme.of(context).colorScheme.outline),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Text(item.emoji, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.name, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
                      Text(item.portion, style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Text("${item.calories} kcal", style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(width: 16),
                Text("[P:${item.protein}g | C:${item.carbs}g | F:${item.fat}g]", style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.textTertiary)),
              ],
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: isEditing ? _EditingControls() : const SizedBox(width: double.infinity),
            )
          ],
        ),
      ),
    );
  }
}

class _EditingControls extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Column(
        children: [
          Divider(height: 1, color: Theme.of(context).colorScheme.outline),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'Quantity',
                    filled: true,
                    fillColor: AppTheme.bgSecondary,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'Serving',
                    filled: true,
                    fillColor: AppTheme.bgSecondary,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}