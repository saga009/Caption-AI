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
    String tone = 'Confident',
    String length = 'Medium',
    String emojiLevel = 'Medium',
  }) async {
    final prompt = _buildPrompt(
      category: category,
      description: description,
      tone: tone,
      length: length,
      emojiLevel: emojiLevel,
    );

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
    required String tone,
    required String length,
    required String emojiLevel,
  }) {
    return '''
You are an expert Instagram caption writer. Generate viral, engaging captions for a $category photo/post.

Photo description: $description

Style preferences:
- Tone: $tone
- Caption length preference: $length
- Emoji usage: $emojiLevel

Generate the following in JSON format ONLY (no markdown, no code block, just raw JSON):
{
  "short": "1 short punchy Instagram caption with emojis matching the requested emoji usage (max 15 words)",
  "long": "1 long caption with emojis matching the requested emoji usage, following the requested length preference",
  "emoji": "5-8 relevant emojis as a single string (not an array), e.g. ✨📸❤️",
  "hashtags": ["hashtag1", "hashtag2", "hashtag3", "hashtag4", "hashtag5", "hashtag6", "hashtag7", "hashtag8", "hashtag9", "hashtag10"]
}

Rules:
- Make captions trendy and viral
- hashtags array should have exactly 10 items, no # symbol, all lowercase
- Match the tone to the $category category and the requested "$tone" tone
- short caption should be punchy and catchy
- long caption should follow the "$length" length preference and be engaging
- if emoji usage is "None", do not include any emojis in short/long captions
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
      final jsonStr = _sanitizeJsonStrings(cleanText.substring(jsonStart, jsonEnd + 1));
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

  // Groq occasionally emits raw newlines/tabs inside JSON string values instead of
  // escaping them, which makes jsonDecode throw. Escape control characters, but only
  // while inside a string literal, so structural JSON whitespace is left untouched.
  static String _sanitizeJsonStrings(String input) {
    final buffer = StringBuffer();
    var inString = false;
    var escaped = false;
    for (final rune in input.runes) {
      final ch = String.fromCharCode(rune);
      if (inString) {
        if (escaped) {
          buffer.write(ch);
          escaped = false;
        } else if (ch == '\\') {
          buffer.write(ch);
          escaped = true;
        } else if (ch == '"') {
          buffer.write(ch);
          inString = false;
        } else if (ch == '\n') {
          buffer.write(r'\n');
        } else if (ch == '\r') {
          buffer.write(r'\r');
        } else if (ch == '\t') {
          buffer.write(r'\t');
        } else {
          buffer.write(ch);
        }
      } else {
        if (ch == '"') inString = true;
        buffer.write(ch);
      }
    }
    return buffer.toString();
  }
}
