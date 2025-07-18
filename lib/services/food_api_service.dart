import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:smart_calorie_flutter/models/food_models.dart';

class FoodApiService {
  static const String _usdaApiKey = 'NNGFPLwxR7VZ3s9FmxRUucdZKkhqKrCXX2dXLPCC';
  static const String _searchApiUrl = 'https://api.nal.usda.gov/fdc/v1/foods/search';
  static const String _detailsApiUrl = 'https://api.nal.usda.gov/fdc/v1/food/';

  static Future<List<FoodItem>> searchFood(String query) async {
    if (query.isEmpty) return [];

    final response = await http.get(
      Uri.parse('$_searchApiUrl?api_key=$_usdaApiKey&query=$query&pageSize=50'),
    );

    if (response.statusCode != 200) throw Exception('Failed to search for food');
    
    final data = json.decode(response.body);
    final List foods = data['foods'] ?? [];

    return foods.map((food) {
      return FoodItem(
        id: food['fdcId'].toString(),
        name: food['description'] ?? 'Unknown Food',
        description: food['brandName'] ?? food['foodCategory'] ?? 'USDA',
        caloriesPer100g: 0, 
        proteinPer100g: 0.0,
        carbsPer100g: 0.0,
        fatPer100g: 0.0,
      );
    }).toList();
  }

  static Future<FoodItem> getFoodDetails(String foodId) async {
    final response = await http.get(
      Uri.parse('$_detailsApiUrl$foodId?api_key=$_usdaApiKey'),
    );

    if (response.statusCode != 200) throw Exception('Failed to get food details');

    final foodData = json.decode(response.body);

    // UPDATED: This function now reliably finds nutrients by their official ID
    num getNutrientValue(int nutrientId) {
        final nutrient = (foodData['foodNutrients'] as List?)?.firstWhere(
          (n) => n['nutrient'] != null && n['nutrient']['id'] == nutrientId,
          orElse: () => {'amount': 0},
        );
        return nutrient?['amount'] ?? 0;
      }
    
    List<Serving> servings = [];
    if (foodData['foodPortions'] != null) {
      servings = (foodData['foodPortions'] as List).map((portion) {
        var description = portion['portionDescription'] ?? portion['modifier'] ?? 'Serving';
        return Serving(
          servingDescription: description,
          gramWeight: (portion['gramWeight'] as num? ?? 100.0).toDouble(),
        );
      }).toList();
    }
    if (servings.every((s) => s.gramWeight != 100)) {
        servings.add(Serving(servingDescription: '100g', gramWeight: 100));
    }

    return FoodItem(
      id: foodData['fdcId'].toString(),
      name: foodData['description'] ?? 'Unknown Food',
      description: foodData['brandName'] ?? foodData['foodCategory'] ?? 'USDA',
      // UPDATED: Now using the correct, permanent IDs for each nutrient
      caloriesPer100g: getNutrientValue(1008).round(),      // Energy
      proteinPer100g: getNutrientValue(1003).toDouble(),    // Protein
      carbsPer100g: getNutrientValue(1005).toDouble(),       // Carbs
      fatPer100g: getNutrientValue(1004).toDouble(),         // Fat
      servings: servings,
    );
  }
}