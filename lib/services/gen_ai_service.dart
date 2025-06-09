// services/gen_ai_service.dart

import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:logger/logger.dart';
import '../models/food_item.dart'; // Adjust the import path

class GeminiAiService {
  // Define the function declaration using your OpenAPI schema
  static final _logFoodItemFunction = FunctionDeclaration(
    'logFoodItem', // The name the model will call
    'Logs the nutritional information of a food item found in an image.',
    // The schema defining the parameters
    Schema(
      SchemaType.object,
      properties: {
        'barcode': Schema(
          SchemaType.string,
          description:
              "The barcode (EAN/UPC) of the food item, if visible. Otherwise, use 'N/A'.",
        ),
        'name': Schema(
          SchemaType.string,
          description: 'The name of the food product.',
        ),
        'calories': Schema(
          SchemaType.number,
          description:
              'The estimated amount of calories per serving size (in kcal).',
        ),
        'protein': Schema(
          SchemaType.number,
          description:
              'The estimated amount of protein per serving size (in grams).',
        ),
        'carbohydrates': Schema(
          SchemaType.number,
          description:
              'The estimated total amount of carbohydrates per serving size (in grams).',
        ),
        'sugars': Schema(
          SchemaType.number,
          description:
              'The estimated amount of sugars within the carbohydrates per serving size (in grams).',
        ),
        'fat': Schema(
          SchemaType.number,
          description:
              'The estimated total amount of fat per serving size (in grams).',
        ),
        'saturatedFat': Schema(
          SchemaType.number,
          description:
              'The estimated amount of saturated fat within the total fat per serving size (in grams).',
        ),
        'servingSize': Schema(
          SchemaType.string,
          description:
              "The serving size for which the nutritional information is provided (e.g., 'per 100g', '1 apple').",
        ),
      },
      // Specify which properties are required
      requiredProperties: [
        'name',
        'calories',
        'protein',
        'carbohydrates',
        'sugars',
        'fat',
        'saturatedFat',
        'servingSize',
      ],
    ),
  );

  // Wrap the function in a Tool object
  static final _foodTool = Tool(functionDeclarations: [_logFoodItemFunction]);

  final GenerativeModel _model;

  GeminiAiService()
    : _model = GenerativeModel(
        // Use a model that supports tool use, like Gemini 2.5 Pro
        model: 'gemini-2.5-flash-preview-05-20',
        apiKey: dotenv.env['GEMINI_API_KEY']!,
        // Pass the tool configuration to the model
        tools: [_foodTool],
      );

  Future<FoodItem?> getFoodDataFromImage(File imageFile) async {
    try {
      final prompt = TextPart(
        "Analyze the food item in this image. Based on what you see, call the logFoodItem function with the estimated nutritional information. Use a standard serving size like 'per 100g' or describe the item (e.g., '1 medium apple').",
      );
      final imageBytes = await imageFile.readAsBytes();
      final imagePart = DataPart('image/jpeg', imageBytes);

      final response = await _model.generateContent([
        Content.multi([prompt, imagePart]),
      ]);

      // Check if the model responded with a function call
      final functionCall = response.functionCalls.firstOrNull;
      if (functionCall != null) {
        // The model returned the structured data we wanted
        Logger().i("Function call received: ${functionCall.name}");
        Logger().d("Arguments: ${functionCall.args}");

        // Use our fromJson factory to parse the arguments
        return FoodItem.fromJson(functionCall.args);
      } else {
        // The model responded with text instead of a function call
        Logger().w("No function call from model. Response: ${response.text}");
        return null;
      }
    } catch (e) {
      Logger().e("An error occurred: $e");
      return null;
    }
  }
}
