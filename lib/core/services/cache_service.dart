import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CacheService {
  static final CacheService _instance = CacheService._internal();

  factory CacheService() => _instance;

  CacheService._internal();

  static CacheService get instance => _instance;

  late SharedPreferences _prefs;

  /// KEYS
  static const String _cachedProfileKey = 'cached_profile';
  static const String _cachedContactsKey = 'cached_emergency_contacts';
  static const String _onboardingCompleteKey = 'onboarding_complete';
  static const String _lastCacheTimeKey = 'last_cache_time';

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// ONBOARDING

  bool get isOnboardingComplete =>
      _prefs.getBool(_onboardingCompleteKey) ?? false;

  Future<void> setOnboardingComplete() async {
    await _prefs.setBool(_onboardingCompleteKey, true);
  }

  Future<void> clearContactsCache() async {
    await _prefs.remove(_cachedContactsKey);
  }

  /// CACHE FRESHNESS

  DateTime? get lastCacheTime {
    final ms = _prefs.getInt(_lastCacheTimeKey);
    if (ms == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(ms);
  }

  bool get isCacheStale {
    final last = lastCacheTime;
    if (last == null) return true;
    return DateTime.now().difference(last).inMinutes > 30;
  }

  Future<void> _updateCacheTimestamp() async {
    await _prefs.setInt(
      _lastCacheTimeKey,
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  Future<void> clearAll() async {
    await _prefs.clear();
  }
}
