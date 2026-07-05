import 'package:flutter/foundation.dart';
import '../constants/app_strings.dart';
import '../services/storage_service.dart';

class GenerationLimitProvider extends ChangeNotifier {
  int _todayCount = 0;
  int _bonusCount = 0;
  bool _isLoaded = false;

  int get todayCount => _todayCount;
  int get bonusCount => _bonusCount;
  bool get isLoaded => _isLoaded;

  int get remainingFree =>
      (AppStrings.freeGenerationsPerDay - _todayCount).clamp(0, AppStrings.freeGenerationsPerDay);

  bool get hasReachedFreeLimit => _todayCount >= AppStrings.freeGenerationsPerDay;

  bool get canGenerate => !hasReachedFreeLimit || _bonusCount > 0;

  String get statusText {
    if (!hasReachedFreeLimit) {
      return '$remainingFree free captions left today';
    } else if (_bonusCount > 0) {
      return '$_bonusCount bonus captions left';
    }
    return 'Daily limit reached';
  }

  Future<void> loadCounts() async {
    _todayCount = await StorageService.getTodayCount();
    _bonusCount = await StorageService.getBonusGenerations();
    _isLoaded = true;
    notifyListeners();
  }

  Future<bool> tryGenerate() async {
    await loadCounts();

    if (!hasReachedFreeLimit) {
      await StorageService.incrementCount();
      _todayCount++;
      notifyListeners();
      return true;
    }

    if (_bonusCount > 0) {
      await StorageService.useBonusGeneration();
      _bonusCount--;
      notifyListeners();
      return true;
    }

    return false;
  }

  Future<void> addBonusGenerations(int amount) async {
    await StorageService.addBonusGenerations(amount);
    _bonusCount += amount;
    notifyListeners();
  }
}
