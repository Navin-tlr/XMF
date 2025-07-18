class Serving {
  final String servingDescription; // e.g., "1 cup" or "1 large"
  final double gramWeight;        // The weight of that serving in grams, e.g., 244.0

  Serving({
    required this.servingDescription,
    required this.gramWeight,
  });
}

class FoodItem {
  final String id;
  final String name;
  final String description; // This can be the brand or category

  // Base nutrition is almost always per 100g
  final int caloriesPer100g;
  final double proteinPer100g;
  final double carbsPer100g;
  final double fatPer100g;

  // A list of all available serving sizes for this food
  List<Serving> servings;

  FoodItem({
    required this.id,
    required this.name,
    required this.description,
    required this.caloriesPer100g,
    required this.proteinPer100g,
    required this.carbsPer100g,
    required this.fatPer100g,
    this.servings = const [], // Default to an empty list
  });
}