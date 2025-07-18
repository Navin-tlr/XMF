// lib/screens/dashboard_screen.dart
// NOW WITH INTERACTIVE MACROS TILE

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:smart_calorie_flutter/app_theme.dart';
import 'package:smart_calorie_flutter/screens/food_search_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    void handleSwipeUp() {
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
            child: const FoodSearchScreen(meal: 'Dinner'),
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const Padding(padding: EdgeInsets.all(16.0), child: Icon(Icons.menu)),
        title: const Text('Dashboard'),
        actions: const [Padding(padding: EdgeInsets.all(16.0), child: CircleAvatar(radius: 18))],
      ),
      body: GestureDetector(
        onVerticalDragEnd: (details) {
          if (details.primaryVelocity != null && details.primaryVelocity! < -250) {
            handleSwipeUp();
          }
        },
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: StaggeredGrid.count(
              crossAxisCount: 4,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: const [
                StaggeredGridTile.count(
                  crossAxisCellCount: 4,
                  mainAxisCellCount: 2,
                  child: _CaloriesTile(consumed: 1345, goal: 2500),
                ),
                StaggeredGridTile.count(
                  crossAxisCellCount: 4,
                  mainAxisCellCount: 2,
                  child: _RecentMealsTile(),
                ),
                // This tile is now interactive
                StaggeredGridTile.count(
                  crossAxisCellCount: 2,
                  mainAxisCellCount: 2,
                  child: _MacrosTile(),
                ),
                StaggeredGridTile.count(
                  crossAxisCellCount: 2,
                  mainAxisCellCount: 1,
                  child: _WeightChangeTile(change: "+0.3 kg"),
                ),
                StaggeredGridTile.count(
                  crossAxisCellCount: 1,
                  mainAxisCellCount: 1,
                  child: _StatusTile(title: "Engine", metric: "No Change", icon: Icons.sync_alt),
                ),
                StaggeredGridTile.count(
                  crossAxisCellCount: 1,
                  mainAxisCellCount: 1,
                  child: _AddWidgetTile(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// === Modular Tile Widgets ===

class _BaseTile extends StatelessWidget {
  final Widget child;
  final Color? color;
  const _BaseTile({required this.child, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color ?? AppTheme.bgElevated,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _CaloriesTile extends StatelessWidget {
  final int consumed;
  final int goal;
  const _CaloriesTile({required this.consumed, required this.goal});

  @override
  Widget build(BuildContext context) {
    return _BaseTile(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("CALORIES TODAY", style: Theme.of(context).textTheme.bodySmall),
          const Spacer(),
          Text("$consumed", style: Theme.of(context).textTheme.displayMedium),
          Text("/ $goal kcal", style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppTheme.textTertiary)),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: consumed / goal,
            backgroundColor: Theme.of(context).colorScheme.outline,
            color: AppTheme.accentGreen,
            minHeight: 6,
            borderRadius: const BorderRadius.all(Radius.circular(6)),
          ),
        ],
      ),
    );
  }
}

// NEW: Interactive Macros Tile
class _MacrosTile extends StatelessWidget {
  const _MacrosTile();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: AppTheme.bgSecondary,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (context) {
            return SizedBox(
              height: MediaQuery.of(context).size.height * 0.9,
              child: const _MacrosDetailSheet(),
            );
          },
        );
      },
      child: _BaseTile(
        color: AppTheme.accentPurple.withOpacity(0.1),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("MACROS", style: Theme.of(context).textTheme.bodySmall),
            const Expanded(
              child: Center(
                child: Icon(Icons.pie_chart_outline_rounded, size: 64, color: AppTheme.accentPurple),
              ),
            ),
            Text("Tap to see breakdown", style: Theme.of(context).textTheme.bodySmall)
          ],
        ),
      ),
    );
  }
}

// Other tiles like _WeightChangeTile, _RecentMealsTile, etc. remain here...
class _RecentMealsTile extends StatelessWidget {
  const _RecentMealsTile();

  @override
  Widget build(BuildContext context) {
    final recentMeals = [
      {'name': 'Scrambled Eggs & Toast', 'kcal': 450},
      {'name': 'Grilled Chicken Salad', 'kcal': 620},
      {'name': 'Overnight Oats', 'kcal': 380},
    ];

    return _BaseTile(
      color: AppTheme.bgSecondary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("RECENT MEALS", style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 8),
          if (recentMeals.isEmpty)
            Expanded(
              child: Center(
                child: Text(
                  "Log your first bite to see it here.",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            )
          else
            Expanded(
              child: ListView.separated(
                itemCount: recentMeals.length,
                separatorBuilder: (_, __) => Divider(color: AppTheme.lightBorder, height: 1),
                itemBuilder: (context, index) {
                  final meal = recentMeals[index];
                  return _MealRow(name: meal['name'] as String, kcal: meal['kcal'] as int);
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _MealRow extends StatelessWidget {
  final String name;
  final int kcal;
  const _MealRow({required this.name, required this.kcal});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
                Text("$kcal kcal", style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.refresh, color: AppTheme.textTertiary),
          )
        ],
      ),
    );
  }
}


class _WeightChangeTile extends StatelessWidget {
  final String change;
  const _WeightChangeTile({required this.change});

  @override
  Widget build(BuildContext context) {
    return _BaseTile(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("7-DAY CHANGE", style: Theme.of(context).textTheme.bodySmall),
          const Spacer(),
          Text(change, style: Theme.of(context).textTheme.titleLarge),
        ],
      ),
    );
  }
}

class _StatusTile extends StatelessWidget {
  final String title;
  final String metric;
  final IconData icon;
  final Color? color;

  const _StatusTile({required this.title, required this.metric, required this.icon, this.color});
  @override
  Widget build(BuildContext context) {
    return _BaseTile(
      color: color?.withOpacity(0.1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 28, color: color ?? AppTheme.textSecondary),
          const Spacer(),
          Text(title, style: Theme.of(context).textTheme.bodyMedium),
          Text(metric, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 28)),
        ],
      ),
    );
  }
}

class _AddWidgetTile extends StatelessWidget {
  const _AddWidgetTile();
  @override
  Widget build(BuildContext context) {
    return DashedBorderContainer(
      child: Center(
        child: Icon(
          Icons.add,
          color: Theme.of(context).textTheme.bodyMedium?.color,
          size: 28,
        ),
      ),
    );
  }
}

class DashedBorderContainer extends StatelessWidget {
  final Widget child;
  const DashedBorderContainer({super.key, required this.child});
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedBorderPainter(Theme.of(context).colorScheme.outline),
      child: child,
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  _DashedBorderPainter(this.color);
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    final path = Path();
    path.addRRect(RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, size.width, size.height), const Radius.circular(20)));
    final dashPath = Path();
    const dashWidth = 5.0;
    const dashSpace = 5.0;
    for (final metric in path.computeMetrics()) {
      double distance = 0.0;
      while (distance < metric.length) {
        dashPath.addPath(metric.extractPath(distance, distance + dashWidth), Offset.zero);
        distance += dashWidth + dashSpace;
      }
    }
    canvas.drawPath(dashPath, paint);
  }
  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}


// === NEW WIDGET: The Drill-Down Sheet for Macros ===
class _MacrosDetailSheet extends StatelessWidget {
  const _MacrosDetailSheet();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: AppTheme.textDisabled,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text("Macronutrient Breakdown", style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 24),
          // Dummy data for breakdown
          _BreakdownRow(meal: 'Breakfast', p: '40g', c: '60g', f: '20g'),
          _BreakdownRow(meal: 'Lunch', p: '50g', c: '80g', f: '25g'),
          _BreakdownRow(meal: 'Dinner', p: '30g', c: '60g', f: '15g'),
        ],
      ),
    );
  }
}

class _BreakdownRow extends StatelessWidget {
  final String meal;
  final String p, c, f;
  const _BreakdownRow({required this.meal, required this.p, required this.c, required this.f});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(meal, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Protein: $p", style: Theme.of(context).textTheme.bodyMedium),
              Text("Carbs: $c", style: Theme.of(context).textTheme.bodyMedium),
              Text("Fat: $f", style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ],
      ),
    );
  }
}