import 'package:flutter/foundation.dart';
import '../models/caption_model.dart';
import '../models/category_model.dart';
import '../services/gemini_service.dart';

enum CaptionState { idle, loading, success, error }

const List<String> kToneOptions = ['Confident', 'Casual', 'Funny', 'Professional', 'Poetic'];
const List<String> kLengthOptions = ['Short', 'Medium', 'Long'];
const List<String> kEmojiLevelOptions = ['None', 'Low', 'Medium', 'High'];

class CaptionProvider extends ChangeNotifier {
  CaptionState _state = CaptionState.idle;
  CaptionModel? _caption;
  String? _errorMessage;
  CategoryModel? _selectedCategory;
  String _description = '';
  int _generateCount = 0;
  String _tone = kToneOptions.first;
  String _length = kLengthOptions[1];
  String _emojiLevel = kEmojiLevelOptions[2];

  CaptionState get state => _state;
  CaptionModel? get caption => _caption;
  String? get errorMessage => _errorMessage;
  CategoryModel? get selectedCategory => _selectedCategory;
  String get description => _description;
  int get generateCount => _generateCount;
  String get tone => _tone;
  String get length => _length;
  String get emojiLevel => _emojiLevel;

  void selectCategory(CategoryModel category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setDescription(String value) {
    _description = value;
    notifyListeners();
  }

  void setTone(String value) {
    _tone = value;
    notifyListeners();
  }

  void setLength(String value) {
    _length = value;
    notifyListeners();
  }

  void setEmojiLevel(String value) {
    _emojiLevel = value;
    notifyListeners();
  }

  Future<void> generateCaption() async {
    if (_selectedCategory == null || _description.trim().isEmpty) return;

    _state = CaptionState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _caption = await GeminiService.generateCaption(
        category: _selectedCategory!.promptHint,
        description: _description.trim(),
        tone: _tone,
        length: _length,
        emojiLevel: _emojiLevel,
      );
      _state = CaptionState.success;
      _generateCount++;
    } catch (e) {
      _state = CaptionState.error;
      _errorMessage = e.toString().replaceAll('Exception:', '').trim();
    }

    notifyListeners();
  }

  void reset() {
    _state = CaptionState.idle;
    _caption = null;
    _errorMessage = null;
    notifyListeners();
  }
}
