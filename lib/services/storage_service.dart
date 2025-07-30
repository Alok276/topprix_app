// lib/services/storage_service.dart - COMPLETE VERSION WITH ALL MISSING FUNCTIONS
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:topprix/models/search_result_model.dart';
import '../models/user_model.dart';

class StorageService {
  static SharedPreferences? _prefs;

  // Storage keys
  static const String _keyToken = 'auth_token';
  static const String _keyUser = 'user_data';
  static const String _keyUserEmail = 'user_email';
  static const String _keyOnboardingCompleted = 'onboarding_completed';
  static const String _keyRecentSearches = 'recent_searches';
  static const String _keySearchHistory = 'search_history';
  static const String _keyFavoriteStores = 'favorite_stores';
  static const String _keyAppPreferences = 'app_preferences';
  static const String _keyNotificationSettings = 'notification_settings';
  static const String _keyLocationPermission = 'location_permission';
  static const String _keyLastKnownLocation = 'last_known_location';
  static const String _keyThemeMode = 'theme_mode';
  static const String _keyLanguage = 'language';
  static const String _keyFirstTimeUser = 'first_time_user';

  // Initialize SharedPreferences
  static Future<void> init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      print('StorageService initialized successfully');
    } catch (e) {
      print('Error initializing StorageService: $e');
      rethrow;
    }
  }

  // Ensure preferences are initialized
  static Future<void> _ensureInitialized() async {
    if (_prefs == null) {
      await init();
    }
  }

  // ========== TOKEN OPERATIONS ==========

  static Future<void> saveToken(String token) async {
    try {
      await _ensureInitialized();
      await _prefs!.setString(_keyToken, token);
      print('Token saved successfully');
    } catch (e) {
      print('Error saving token: $e');
      rethrow;
    }
  }

  static Future<String?> getToken() async {
    try {
      await _ensureInitialized();
      return _prefs!.getString(_keyToken);
    } catch (e) {
      print('Error getting token: $e');
      return null;
    }
  }

  static Future<void> removeToken() async {
    try {
      await _ensureInitialized();
      await _prefs!.remove(_keyToken);
      print('Token removed successfully');
    } catch (e) {
      print('Error removing token: $e');
    }
  }

  // ========== USER OPERATIONS ==========

  static Future<void> saveUser(UserModel user) async {
    try {
      await _ensureInitialized();
      final userJson = jsonEncode(user.toJson());
      await _prefs!.setString(_keyUser, userJson);
      await _prefs!.setString(_keyUserEmail, user.email);
      print('User saved successfully: ${user.email}');
    } catch (e) {
      print('Error saving user: $e');
      rethrow;
    }
  }

  static Future<UserModel?> getUser() async {
    try {
      await _ensureInitialized();
      final userString = _prefs!.getString(_keyUser);
      if (userString != null) {
        final userJson = jsonDecode(userString) as Map<String, dynamic>;
        return UserModel.fromJson(userJson);
      }
      return null;
    } catch (e) {
      print('Error getting user: $e');
      return null;
    }
  }

  static Future<String?> getUserEmail() async {
    try {
      await _ensureInitialized();
      return _prefs!.getString(_keyUserEmail);
    } catch (e) {
      print('Error getting user email: $e');
      return null;
    }
  }

  static Future<void> removeUser() async {
    try {
      await _ensureInitialized();
      await _prefs!.remove(_keyUser);
      await _prefs!.remove(_keyUserEmail);
      print('User removed successfully');
    } catch (e) {
      print('Error removing user: $e');
    }
  }

  // ========== ONBOARDING OPERATIONS ==========

  static Future<void> completeOnboarding() async {
    try {
      await _ensureInitialized();
      await _prefs!.setBool(_keyOnboardingCompleted, true);
      await _prefs!.setBool(_keyFirstTimeUser, false);
      print('Onboarding marked as completed');
    } catch (e) {
      print('Error completing onboarding: $e');
    }
  }

  static Future<bool> isOnboardingCompleted() async {
    try {
      await _ensureInitialized();
      return _prefs!.getBool(_keyOnboardingCompleted) ?? false;
    } catch (e) {
      print('Error checking onboarding status: $e');
      return false;
    }
  }

  static Future<bool> isFirstTimeUser() async {
    try {
      await _ensureInitialized();
      return _prefs!.getBool(_keyFirstTimeUser) ?? true;
    } catch (e) {
      print('Error checking first time user: $e');
      return true;
    }
  }

  // ========== SEARCH HISTORY OPERATIONS ==========

  static Future<void> addToSearchHistory(String query) async {
    try {
      await _ensureInitialized();
      final history = await getSearchHistory();

      // Remove if already exists to avoid duplicates
      history.removeWhere((item) => item.query == query);

      // Add new search to beginning
      final newItem = SearchHistoryItem(
        query: query,
        timestamp: DateTime.now(),
        resultCount: 0,
      );
      history.insert(0, newItem);

      // Keep only last 50 searches
      if (history.length > 50) {
        history.removeRange(50, history.length);
      }

      // Save back to storage
      final historyJson = history.map((item) => item.toJson()).toList();
      await _prefs!.setString(_keySearchHistory, jsonEncode(historyJson));
      print('Search query added to history: $query');
    } catch (e) {
      print('Error adding to search history: $e');
    }
  }

  static Future<List<SearchHistoryItem>> getSearchHistory() async {
    try {
      await _ensureInitialized();
      final historyString = _prefs!.getString(_keySearchHistory);
      if (historyString != null) {
        final historyList = jsonDecode(historyString) as List;
        return historyList
            .map((item) => SearchHistoryItem.fromJson(item))
            .toList();
      }
      return [];
    } catch (e) {
      print('Error getting search history: $e');
      return [];
    }
  }

  static Future<void> clearSearchHistory() async {
    try {
      await _ensureInitialized();
      await _prefs!.remove(_keySearchHistory);
      print('Search history cleared');
    } catch (e) {
      print('Error clearing search history: $e');
    }
  }

  static Future<void> removeFromSearchHistory(String query) async {
    try {
      await _ensureInitialized();
      final history = await getSearchHistory();
      history.removeWhere((item) => item.query == query);

      final historyJson = history.map((item) => item.toJson()).toList();
      await _prefs!.setString(_keySearchHistory, jsonEncode(historyJson));
      print('Removed from search history: $query');
    } catch (e) {
      print('Error removing from search history: $e');
    }
  }

  // ========== RECENT SEARCHES (Simple String List) ==========

  static Future<void> addRecentSearch(String search) async {
    try {
      await _ensureInitialized();
      final searches = await getRecentSearches();

      // Remove if already exists
      searches.remove(search);

      // Add to beginning
      searches.insert(0, search);

      // Keep only last 10 searches
      if (searches.length > 10) {
        searches.removeRange(10, searches.length);
      }

      await _prefs!.setStringList(_keyRecentSearches, searches);
      print('Recent search added: $search');
    } catch (e) {
      print('Error adding recent search: $e');
    }
  }

  static Future<List<String>> getRecentSearches() async {
    try {
      await _ensureInitialized();
      return _prefs!.getStringList(_keyRecentSearches) ?? [];
    } catch (e) {
      print('Error getting recent searches: $e');
      return [];
    }
  }

  static Future<void> clearRecentSearches() async {
    try {
      await _ensureInitialized();
      await _prefs!.remove(_keyRecentSearches);
      print('Recent searches cleared');
    } catch (e) {
      print('Error clearing recent searches: $e');
    }
  }

  // ========== LOCATION OPERATIONS ==========

  /// Save last known location
  static Future<bool> saveLastKnownLocation(
    double latitude,
    double longitude,
  ) async {
    try {
      await _ensureInitialized();
      final locationData = {
        'latitude': latitude,
        'longitude': longitude,
        'timestamp': DateTime.now().toIso8601String(),
      };

      return await _prefs!.setString(
        _keyLastKnownLocation,
        jsonEncode(locationData),
      );
    } catch (e) {
      print('Error saving last known location: $e');
      return false;
    }
  }

  /// Get last known location
  static Future<Map<String, dynamic>?> getLastKnownLocation() async {
    try {
      await _ensureInitialized();
      final locationString = _prefs!.getString(_keyLastKnownLocation);

      if (locationString != null) {
        final locationData = jsonDecode(locationString) as Map<String, dynamic>;
        return {
          'latitude': locationData['latitude'],
          'longitude': locationData['longitude'],
          'timestamp': locationData['timestamp'],
        };
      }

      return null;
    } catch (e) {
      print('Error getting last known location: $e');
      return null;
    }
  }

  /// Clear last known location
  static Future<bool> clearLastKnownLocation() async {
    try {
      await _ensureInitialized();
      return await _prefs!.remove(_keyLastKnownLocation);
    } catch (e) {
      print('Error clearing last known location: $e');
      return false;
    }
  }

  // ========== FAVORITE STORES ==========

  static Future<void> addFavoriteStore(String storeId) async {
    try {
      await _ensureInitialized();
      final favorites = await getFavoriteStores();
      if (!favorites.contains(storeId)) {
        favorites.add(storeId);
        await _prefs!.setStringList(_keyFavoriteStores, favorites);
        print('Store added to favorites: $storeId');
      }
    } catch (e) {
      print('Error adding favorite store: $e');
    }
  }

  static Future<void> removeFavoriteStore(String storeId) async {
    try {
      await _ensureInitialized();
      final favorites = await getFavoriteStores();
      favorites.remove(storeId);
      await _prefs!.setStringList(_keyFavoriteStores, favorites);
      print('Store removed from favorites: $storeId');
    } catch (e) {
      print('Error removing favorite store: $e');
    }
  }

  static Future<List<String>> getFavoriteStores() async {
    try {
      await _ensureInitialized();
      return _prefs!.getStringList(_keyFavoriteStores) ?? [];
    } catch (e) {
      print('Error getting favorite stores: $e');
      return [];
    }
  }

  static Future<bool> isFavoriteStore(String storeId) async {
    try {
      final favorites = await getFavoriteStores();
      return favorites.contains(storeId);
    } catch (e) {
      print('Error checking favorite store: $e');
      return false;
    }
  }

  // ========== APP PREFERENCES ==========

  static Future<void> saveAppPreferences(
      Map<String, dynamic> preferences) async {
    try {
      await _ensureInitialized();
      await _prefs!.setString(_keyAppPreferences, jsonEncode(preferences));
      print('App preferences saved');
    } catch (e) {
      print('Error saving app preferences: $e');
    }
  }

  static Future<Map<String, dynamic>> getAppPreferences() async {
    try {
      await _ensureInitialized();
      final prefsString = _prefs!.getString(_keyAppPreferences);
      if (prefsString != null) {
        return jsonDecode(prefsString) as Map<String, dynamic>;
      }
      return {};
    } catch (e) {
      print('Error getting app preferences: $e');
      return {};
    }
  }

  // ========== NOTIFICATION SETTINGS ==========

  static Future<void> saveNotificationSettings(
      Map<String, bool> settings) async {
    try {
      await _ensureInitialized();
      await _prefs!.setString(_keyNotificationSettings, jsonEncode(settings));
      print('Notification settings saved');
    } catch (e) {
      print('Error saving notification settings: $e');
    }
  }

  static Future<Map<String, bool>> getNotificationSettings() async {
    try {
      await _ensureInitialized();
      final settingsString = _prefs!.getString(_keyNotificationSettings);
      if (settingsString != null) {
        final settings = jsonDecode(settingsString) as Map<String, dynamic>;
        return settings.map((key, value) => MapEntry(key, value as bool));
      }
      return {
        'deals': true,
        'price_drops': true,
        'new_stores': false,
        'promotions': true,
        'reminders': true,
      };
    } catch (e) {
      print('Error getting notification settings: $e');
      return {};
    }
  }

  // ========== THEME AND LANGUAGE ==========

  static Future<void> setThemeMode(String mode) async {
    try {
      await _ensureInitialized();
      await _prefs!.setString(_keyThemeMode, mode);
    } catch (e) {
      print('Error setting theme mode: $e');
    }
  }

  static String getThemeMode() {
    try {
      return _prefs?.getString(_keyThemeMode) ?? 'system';
    } catch (e) {
      print('Error getting theme mode: $e');
      return 'system';
    }
  }

  static Future<void> setLanguage(String languageCode) async {
    try {
      await _ensureInitialized();
      await _prefs!.setString(_keyLanguage, languageCode);
    } catch (e) {
      print('Error setting language: $e');
    }
  }

  static String getLanguage() {
    try {
      return _prefs?.getString(_keyLanguage) ?? 'en';
    } catch (e) {
      print('Error getting language: $e');
      return 'en';
    }
  }

  // ========== LOCATION PERMISSION ==========

  static Future<void> setLocationPermissionAsked(bool asked) async {
    try {
      await _ensureInitialized();
      await _prefs!.setBool(_keyLocationPermission, asked);
    } catch (e) {
      print('Error setting location permission: $e');
    }
  }

  static bool hasLocationPermissionBeenAsked() {
    try {
      return _prefs?.getBool(_keyLocationPermission) ?? false;
    } catch (e) {
      print('Error getting location permission: $e');
      return false;
    }
  }

  // ========== GENERIC OPERATIONS ==========

  static Future<void> setString(String key, String value) async {
    try {
      await _ensureInitialized();
      await _prefs!.setString(key, value);
    } catch (e) {
      print('Error setting string for key $key: $e');
    }
  }

  static Future<String?> getString(String key) async {
    try {
      await _ensureInitialized();
      return _prefs!.getString(key);
    } catch (e) {
      print('Error getting string for key $key: $e');
      return null;
    }
  }

  static Future<void> setBool(String key, bool value) async {
    try {
      await _ensureInitialized();
      await _prefs!.setBool(key, value);
    } catch (e) {
      print('Error setting bool for key $key: $e');
    }
  }

  static Future<bool> getBool(String key, {bool defaultValue = false}) async {
    try {
      await _ensureInitialized();
      return _prefs!.getBool(key) ?? defaultValue;
    } catch (e) {
      print('Error getting bool for key $key: $e');
      return defaultValue;
    }
  }

  static Future<void> setInt(String key, int value) async {
    try {
      await _ensureInitialized();
      await _prefs!.setInt(key, value);
    } catch (e) {
      print('Error setting int for key $key: $e');
    }
  }

  static Future<int> getInt(String key, {int defaultValue = 0}) async {
    try {
      await _ensureInitialized();
      return _prefs!.getInt(key) ?? defaultValue;
    } catch (e) {
      print('Error getting int for key $key: $e');
      return defaultValue;
    }
  }

  // ========== CLEAR ALL DATA ==========

  static Future<void> clearAll() async {
    try {
      await _ensureInitialized();
      await _prefs!.clear();
      print('All storage data cleared');
    } catch (e) {
      print('Error clearing all data: $e');
    }
  }

  static Future<void> clearUserData() async {
    try {
      await _ensureInitialized();

      // Remove user-specific data but keep app preferences
      await _prefs!.remove(_keyToken);
      await _prefs!.remove(_keyUser);
      await _prefs!.remove(_keyUserEmail);
      await _prefs!.remove(_keyFavoriteStores);
      await _prefs!.remove(_keySearchHistory);
      await _prefs!.remove(_keyRecentSearches);

      print('User data cleared');
    } catch (e) {
      print('Error clearing user data: $e');
    }
  }

  // ========== DEBUG METHODS ==========

  static Future<void> printAllKeys() async {
    try {
      await _ensureInitialized();
      final keys = _prefs!.getKeys();
      print('All storage keys: $keys');

      for (final key in keys) {
        final value = _prefs!.get(key);
        print('$key: $value');
      }
    } catch (e) {
      print('Error printing all keys: $e');
    }
  }

  static Future<bool> hasKey(String key) async {
    try {
      await _ensureInitialized();
      return _prefs!.containsKey(key);
    } catch (e) {
      print('Error checking key $key: $e');
      return false;
    }
  }

  static Future<void> removeKey(String key) async {
    try {
      await _ensureInitialized();
      await _prefs!.remove(key);
      print('Key removed: $key');
    } catch (e) {
      print('Error removing key $key: $e');
    }
  }
}
