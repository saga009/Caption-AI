import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/app_strings.dart';
import '../models/caption_model.dart';

class GeminiService {
  static const String _apiUrl =
      'https://api.groq.com/openai/v1/chat/completions';

  static Future<CaptionModel> generateCaption({
    required String category,
    required String description,
  }) async {
    final prompt = _buildPrompt(category: category, description: description);

    final response = await http.post(
      Uri.parse(_apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${AppStrings.groqApiKey}',
      },
      body: jsonEncode({
        'model': AppStrings.groqModel,
        'messages': [
          {'role': 'user', 'content': prompt},
        ],
        'temperature': 0.9,
        'max_tokens': 1024,
        'response_format': {'type': 'json_object'},
      }),
    );

    if (response.statusCode != 200) {
      final error = jsonDecode(response.body);
      throw Exception(
        error['error']?['message'] ?? 'API error ${response.statusCode}',
      );
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final text =
        (data['choices'] as List).first['message']['content'] as String? ?? '';
    return _parseResponse(text);
  }

  static String _buildPrompt({
    required String category,
    required String description,
  }) {
    return '''
You are an expert Instagram caption writer. Generate viral, engaging captions for a $category photo/post.

Photo description: $description

Generate the following in JSON format ONLY (no markdown, no code block, just raw JSON):
{
  "short": "1 short punchy Instagram caption with 1-2 relevant emojis (max 15 words)",
  "long": "1 long emotional Instagram caption with emojis (3-5 sentences)",
  "emoji": "5-8 relevant emojis that represent this photo perfectly",
  "hashtags": ["hashtag1", "hashtag2", "hashtag3", "hashtag4", "hashtag5", "hashtag6", "hashtag7", "hashtag8", "hashtag9", "hashtag10"]
}

Rules:
- Make captions trendy and viral
- hashtags array should have exactly 10 items, no # symbol, all lowercase
- Match the tone to the $category category
- short caption should be punchy and catchy
- long caption should be emotional and engaging
''';
  }

  static CaptionModel _parseResponse(String text) {
    try {
      final cleanText = text.trim();
      final jsonStart = cleanText.indexOf('{');
      final jsonEnd = cleanText.lastIndexOf('}');
      if (jsonStart == -1 || jsonEnd == -1) {
        throw const FormatException('No JSON found in response');
      }
      final jsonStr = cleanText.substring(jsonStart, jsonEnd + 1);
      final json = jsonDecode(jsonStr) as Map<String, dynamic>;
      return CaptionModel.fromJson(json);
    } catch (_) {
      return CaptionModel(
        shortCaption: text.length > 100 ? text.substring(0, 100) : text,
        longCaption: text,
        emojiCaption: '✨📸❤️🌟💫',
        hashtags: ['instagram', 'viral', 'trending', 'caption', 'ai'],
      );
    }
  }
}
