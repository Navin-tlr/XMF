// lib/screens/log_food_details_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:smart_calorie_flutter/app_theme.dart';
import 'package:smart_calorie_flutter/models/food_models.dart';
import 'package:smart_calorie_flutter/services/food_api_service.dart';

class LogFoodDetailsScreen extends StatefulWidget {
  final String foodId;
  final String meal;
  const LogFoodDetailsScreen({super.key, required this.foodId, required this.meal});

  @override
  State<LogFoodDetailsScreen> createState() => _LogFoodDetailsScreenState();
}

class _LogFoodDetailsScreenState extends State<LogFoodDetailsScreen> {
  Future<FoodItem>? _foodDetailsFuture;

  @override
  void initState() {
    super.initState();
    // Your logic remains unchanged
    _foodDetailsFuture = FoodApiService.getFoodDetails(widget.foodId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Log Food')),
      body: FutureBuilder<FoodItem>(
        future: _foodDetailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
          if (!snapshot.hasData) return const Center(child: Text('Food not found.'));

          return _LogFoodForm(food: snapshot.data!, meal: widget.meal);
        },
      ),
    );
  }
}

// The form part of the screen, now with updated UI
class _LogFoodForm extends StatefulWidget {
  final FoodItem food;
  final String meal;
  const _LogFoodForm({required this.food, required this.meal});

  @override
  State<_LogFoodForm> createState() => __LogFoodFormState();
}

class __LogFoodFormState extends State<_LogFoodForm> {
  late final TextEditingController _quantityController;
  Serving? _selectedServing;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _quantityController = TextEditingController(text: "1");
    _selectedServing = widget.food.servings.firstWhere(
      (s) => s.gramWeight == 100,
      orElse: () => widget.food.servings.first,
    );
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }
  
  int get _calculatedCalories {
    // Unchanged logic
    if (_selectedServing == null) return 0;
    final quantity = double.tryParse(_quantityController.text) ?? 1;
    final caloriesPerGram = widget.food.caloriesPer100g / 100;
    return (caloriesPerGram * _selectedServing!.gramWeight * quantity).round();
  }

  Future<void> _logFood() async {
    // Unchanged logic
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || _selectedServing == null) return;
    setState(() => _isLoading = true);
    try {
      final collection = FirebaseFirestore.instance.collection('users').doc(user.uid).collection('foodLog');
      await collection.add({
        'name': widget.food.name,
        'calories': _calculatedCalories,
        'meal': widget.meal,
        'timestamp': FieldValue.serverTimestamp(),
      });
      if (mounted) Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error logging food: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // The UI is now wrapped in a ListView for scrolling and styled
    // to match the "Canvas System" aesthetic.
    return ListView(
      padding: const EdgeInsets.all(20.0),
      children: [
        Text(widget.food.name, style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 8),
        Text(widget.food.description, style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 32),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              // REDESIGNED TEXTFIELD
              child: TextField(
                controller: _quantityController,
                decoration: InputDecoration(
                  labelText: 'Quantity',
                  filled: true,
                  fillColor: AppTheme.bgSecondary,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) => setState(() {}),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              // REDESIGNED DROPDOWN
              child: DropdownButtonFormField<Serving>(
                value: _selectedServing,
                items: widget.food.servings.map((serving) {
                  return DropdownMenuItem(
                    value: serving,
                    child: Text(serving.servingDescription, overflow: TextOverflow.ellipsis),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _selectedServing = value),
                decoration: InputDecoration(
                  labelText: 'Serving',
                  filled: true,
                  fillColor: AppTheme.bgSecondary,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        // REDESIGNED METRIC DISPLAY
        _CanvasBlock(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total Calories', style: Theme.of(context).textTheme.titleMedium),
              Text('$_calculatedCalories kcal', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        const SizedBox(height: 24),
        // REDESIGNED BUTTON
        FilledButton(
          onPressed: _isLoading ? null : _logFood,
          child: _isLoading 
            ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white)) 
            : const Text('Log Food'),
        )
      ],
    );
  }
}

// Reusable canvas block for consistency
class _CanvasBlock extends StatelessWidget {
  final Widget child;
  const _CanvasBlock({required this.child});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).colorScheme.outline, width: 1),
      ),
      child: child,
    );
  }
}