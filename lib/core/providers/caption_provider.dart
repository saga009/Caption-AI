import 'package:flutter/foundation.dart';
import '../models/caption_model.dart';
import '../models/category_model.dart';
import '../services/gemini_service.dart';

enum CaptionState { idle, loading, success, error }

class CaptionProvider extends ChangeNotifier {
  CaptionState _state = CaptionState.idle;
  CaptionModel? _caption;
  String? _errorMessage;
  CategoryModel? _selectedCategory;
  String _description = '';
  int _generateCount = 0;

  CaptionState get state => _state;
  CaptionModel? get caption => _caption;
  String? get errorMessage => _errorMessage;
  CategoryModel? get selectedCategory => _selectedCategory;
  String get description => _description;
  int get generateCount => _generateCount;

  void selectCategory(CategoryModel category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setDescription(String value) {
    _description = value;
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
