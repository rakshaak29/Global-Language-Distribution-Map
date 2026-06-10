import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:global_language_distribution_map/data/models/language.dart';

/// Service responsible for loading language data from local JSON assets.
class LocalDataService {
  static const String _assetPath = 'assets/data/languages.json';

  List<Language>? _cachedLanguages;

  /// Loads all language data from the bundled JSON asset.
  ///
  /// Results are cached in memory after the first load.
  Future<List<Language>> loadLanguages() async {
    if (_cachedLanguages != null) {
      return _cachedLanguages!;
    }

    final jsonString = await rootBundle.loadString(_assetPath);
    final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;

    _cachedLanguages = jsonList
        .map((item) => Language.fromJson(item as Map<String, dynamic>))
        .toList();

    return _cachedLanguages!;
  }

  /// Clears the in-memory cache, forcing a reload on next access.
  void clearCache() {
    _cachedLanguages = null;
  }
}
