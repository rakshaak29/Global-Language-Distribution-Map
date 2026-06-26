import 'package:flutter/material.dart';
import 'package:global_language_distribution_map/core/utils/debouncer.dart';
import 'package:global_language_distribution_map/data/models/language.dart';
import 'package:global_language_distribution_map/data/repositories/language_repository.dart';
import 'package:global_language_distribution_map/data/services/fly_to_service.dart';

/// ViewModel for the Home screen (dashboard).
class HomeViewModel extends ChangeNotifier {
  final LanguageRepository _repository;
  final Debouncer _debouncer = Debouncer(milliseconds: 300);

  List<Language> _filteredLanguages = [];
  String _searchQuery = '';
  String _selectedEndangerment = 'all';
  Language? _selectedLanguage;
  String? _currentFlyToKml;
  bool _isSearching = false;

  HomeViewModel({required LanguageRepository repository})
      : _repository = repository {
    _filteredLanguages = _repository.getAllLanguages();
  }

  // ─── Getters ─────────────────────────────────────────────────────────────

  List<Language> get filteredLanguages => _filteredLanguages;
  String get searchQuery => _searchQuery;
  String get selectedEndangerment => _selectedEndangerment;
  Language? get selectedLanguage => _selectedLanguage;
  String? get currentFlyToKml => _currentFlyToKml;
  bool get isSearching => _isSearching;

  int get totalCount => _repository.totalCount;
  int get filteredCount => _filteredLanguages.length;

  /// Total unique language families.
  int get totalFamilies => _repository.getLanguageFamilies().length;

  /// Count of all endangered languages (any non-safe status).
  int get endangeredCount {
    return _repository
        .getAllLanguages()
        .where((l) => l.isEndangered)
        .length;
  }

  /// Count of languages shown on the map (with coordinates).
  int get mappableCount => _repository.languagesWithCoordinates;

  List<String> get endangermentStatuses =>
      ['all', ..._repository.getEndangermentStatuses()];

  Map<String, int> get endangermentCounts =>
      _repository.getEndangermentCounts();

  // ─── Actions ─────────────────────────────────────────────────────────────

  void onSearchChanged(String query) {
    _searchQuery = query;
    _isSearching = query.isNotEmpty;
    notifyListeners();

    _debouncer.run(() {
      _applyFilters();
    });
  }

  void setEndangermentFilter(String status) {
    _selectedEndangerment = status;
    _applyFilters();
  }

  void clearFilters() {
    _searchQuery = '';
    _selectedEndangerment = 'all';
    _isSearching = false;
    _filteredLanguages = _repository.getAllLanguages();
    notifyListeners();
  }

  void selectLanguage(Language? language) {
    _selectedLanguage = language;
    if (language != null) {
      _currentFlyToKml = FlyToService.generateFlyToKml(
        latitude: language.latitude,
        longitude: language.longitude,
        name: language.name,
      );
    } else {
      _currentFlyToKml = null;
    }
    notifyListeners();
  }

  void _applyFilters() {
    _filteredLanguages = _repository.searchAndFilter(
      query: _searchQuery,
      endangermentFilter: _selectedEndangerment,
    );
    notifyListeners();
  }

  @override
  void dispose() {
    _debouncer.dispose();
    super.dispose();
  }
}
