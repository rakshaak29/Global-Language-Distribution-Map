import 'dart:async';
import 'package:flutter/material.dart';
import 'package:global_language_distribution_map/data/models/language.dart';
import 'package:global_language_distribution_map/data/repositories/language_repository.dart';

/// ViewModel for the Endangered Languages screen.
class EndangeredViewModel extends ChangeNotifier {
  final LanguageRepository _repository;

  List<Language> _allEndangered = [];
  List<Language> _filteredLanguages = [];
  String _selectedCategory = 'all';
  String _searchQuery = '';
  Timer? _debounce;

  // Maps internal statuses to the display category labels (from screenshots)
  static const Map<String, String> _categoryLabels = {
    'all': 'All',
    'threatened': 'Vulnerable',
    'shifting': 'Definitely',
    'moribund': 'Severely',
    'nearly extinct': 'Critically',
    'extinct': 'Extinct',
  };

  EndangeredViewModel({required LanguageRepository repository})
      : _repository = repository {
    _loadEndangered();
  }

  List<Language> get filteredLanguages => _filteredLanguages;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  Map<String, String> get categoryLabels => _categoryLabels;

  int get totalCount => _allEndangered.length;

  void _loadEndangered() {
    _allEndangered = _repository
        .getAllLanguages()
        .where((l) => l.isEndangered)
        .toList();
    _filteredLanguages = _allEndangered;
    notifyListeners();
  }

  void setCategory(String status) {
    _selectedCategory = status;
    _applyFilters();
  }

  void search(String query) {
    _searchQuery = query;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), _applyFilters);
  }

  void _applyFilters() {
    var results = _allEndangered.toList();

    if (_selectedCategory != 'all') {
      results = results
          .where((l) => l.endangeredStatus == _selectedCategory)
          .toList();
    }

    if (_searchQuery.isNotEmpty) {
      final lower = _searchQuery.toLowerCase();
      results = results
          .where((l) =>
              l.name.toLowerCase().contains(lower) ||
              l.countryRegion.toLowerCase().contains(lower))
          .toList();
    }

    _filteredLanguages = results;
    notifyListeners();
  }

  /// Returns human-readable category label for a status.
  static String labelFor(String status) {
    return _categoryLabels[status] ?? status;
  }

  /// Returns approximate speaker count display string from description or hash fallback.
  static String speakerCountFor(Language lang) {
    final count = lang.speakerCount;
    if (count == 0) return '0';
    if (count >= 1000000000) {
      return '${(count / 1000000000).toStringAsFixed(1)}B';
    }
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    }
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(0)}K';
    }
    return count.toInt().toString();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
