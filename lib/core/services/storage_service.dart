import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class StorageService {
  static const String _countKey = 'daily_generation_count';
  static const String _dateKey = 'last_generation_date';
  static const String _bonusKey = 'bonus_generations';

  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  static String get _today => DateFormat('yyyy-MM-dd').format(DateTime.now());

  static Future<void> _resetIfNewDay() async {
    await init();
    final lastDate = _prefs!.getString(_dateKey) ?? '';
    if (lastDate != _today) {
      await _prefs!.setInt(_countKey, 0);
      await _prefs!.setString(_dateKey, _today);
    }
  }

  static Future<int> getTodayCount() async {
    await _resetIfNewDay();
    return _prefs!.getInt(_countKey) ?? 0;
  }

  static Future<void> incrementCount() async {
    await init();
    final current = await getTodayCount();
    await _prefs!.setInt(_countKey, current + 1);
  }

  static Future<int> getBonusGenerations() async {
    await init();
    final savedDate = _prefs!.getString('bonus_date') ?? '';
    if (savedDate != _today) {
      await _prefs!.setInt(_bonusKey, 0);
      await _prefs!.setString('bonus_date', _today);
    }
    return _prefs!.getInt(_bonusKey) ?? 0;
  }

  static Future<void> addBonusGenerations(int amount) async {
    await init();
    final current = await getBonusGenerations();
    await _prefs!.setInt(_bonusKey, current + amount);
    await _prefs!.setString('bonus_date', _today);
  }

  static Future<void> useBonusGeneration() async {
    await init();
    final current = await getBonusGenerations();
    if (current > 0) {
      await _prefs!.setInt(_bonusKey, current - 1);
    }
  }
}
