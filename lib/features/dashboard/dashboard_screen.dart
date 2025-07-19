// lib/features/dashboard/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:smart_calorie_flutter/app_theme.dart';
import 'package:smart_calorie_flutter/features/dashboard/dashboard_viewmodel.dart';
import 'package:smart_calorie_flutter/features/dashboard/models/dashboard_block_models.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncBlocks = ref.watch(dashboardViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Today'),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.edit_outlined)),
        ],
      ),
      body: asyncBlocks.when(
        data: (blocks) => ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          itemCount: blocks.length,
          itemBuilder: (context, index) {
            return _BlockRenderer(model: blocks[index]);
          },
        ),
        error: (err, stack) => Center(child: Text('Error: $err')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

class _BlockRenderer extends StatelessWidget {
  final BaseBlockModel model;
  const _BlockRenderer({required this.model});

  @override
  Widget build(BuildContext context) {
    switch (model.runtimeType) {
      case CalorieSummaryModel:
        return _CalorieSummaryWidget(model: model as CalorieSummaryModel);
      case MacronutrientsModel:
        return _MacronutrientsWidget(model: model as MacronutrientsModel);
      case MealModel:
        return _MealWidget(model: model as MealModel);
      default:
        return const SizedBox.shrink();
    }
  }
}

class _CalorieSummaryWidget extends StatelessWidget {
  final CalorieSummaryModel model;
  const _CalorieSummaryWidget({required this.model});

  @override
  Widget build(BuildContext context) {
    final numberFormat = NumberFormat.decimalPattern('en_US');
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        children: [
          Text(
            '${numberFormat.format(model.caloriesLeft.round())} left',
            style: Theme.of(context).textTheme.displaySmall,
          ),
          Text('(KCAL)', style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${model.caloriesEaten.round()} EATEN', style: Theme.of(context).textTheme.bodyMedium),
              Text('${model.caloriesBurned.round()} BURNED', style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
          const SizedBox(height: 4),
          LinearPercentIndicator(
            percent: model.progress.clamp(0.0, 1.0),
            lineHeight: 8.0,
            backgroundColor: AppTheme.lightBorder,
            progressColor: AppTheme.accentGreen,
            barRadius: const Radius.circular(4),
          ),
        ],
      ),
    );
  }
}

class _MacronutrientsWidget extends StatelessWidget {
  final MacronutrientsModel model;
  const _MacronutrientsWidget({required this.model});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('MACRONUTRIENTS', style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 16),
          _MacroBar(
            label: 'Carbs',
            consumed: model.carbsConsumed,
            goal: model.carbsGoal,
            progress: model.carbsProgress,
            color: AppTheme.accentBlue,
          ),
          const SizedBox(height: 8),
          _MacroBar(
            label: 'Fat',
            consumed: model.fatConsumed,
            goal: model.fatGoal,
            progress: model.fatProgress,
            color: AppTheme.accentOrange, // <-- CORRECTED
          ),
          const SizedBox(height: 8),
          _MacroBar(
            label: 'Protein',
            consumed: model.proteinConsumed,
            goal: model.proteinGoal,
            progress: model.proteinProgress,
            color: AppTheme.accentRed, // <-- CORRECTED
          ),
        ],
      ),
    );
  }
}

class _MacroBar extends StatelessWidget {
  final String label;
  final double consumed, goal, progress;
  final Color color;

  const _MacroBar({
    required this.label,
    required this.consumed,
    required this.goal,
    required this.progress,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 60,
          child: Text(label, style: Theme.of(context).textTheme.labelLarge),
        ),
        Expanded(
          child: LinearPercentIndicator(
            percent: progress.clamp(0.0, 1.0),
            lineHeight: 4.0,
            backgroundColor: AppTheme.lightBorder,
            progressColor: color,
            barRadius: const Radius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 80,
          child: Text(
            '${consumed.round()} / ${goal.round()} g',
            textAlign: TextAlign.right,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}

class _MealWidget extends StatelessWidget {
  final MealModel model;
  const _MealWidget({required this.model});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        children: [
          Row(
            children: [
              Icon(model.icon, color: AppTheme.accentOrange),
              const SizedBox(width: 8),
              Text(model.mealType, style: Theme.of(context).textTheme.titleMedium),
              const Spacer(),
              Text(
                '${model.caloriesConsumed.round()} / ${model.calorieGoal.round()} kcal',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.accentGreen),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.more_horiz, color: AppTheme.textSecondary),
            ],
          ),
          const SizedBox(height: 8),
          if (model.foodItems.isEmpty)
            const Text('No food logged yet.')
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: model.foodItems.length,
              itemBuilder: (context, index) {
                final item = model.foodItems[index];
                return ListTile(
                  title: Text(item.name),
                  trailing: Text('${item.calories.round()} kcal'),
                  contentPadding: EdgeInsets.zero,
                );
              },
            ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add),
            label: const Text('Add food'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentGreen,
              foregroundColor: Colors.white,
              shape: const StadiumBorder(),
            ),
          )
        ],
      ),
    );
  }
}