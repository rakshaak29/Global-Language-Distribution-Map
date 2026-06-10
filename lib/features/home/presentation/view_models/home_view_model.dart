import 'package:flutter/material.dart';
import 'package:global_language_distribution_map/core/utils/debouncer.dart';
import 'package:global_language_distribution_map/data/models/language.dart';
import 'package:global_language_distribution_map/data/repositories/language_repository.dart';

/// ViewModel for the Home screen.
///
/// Manages search, filtering, and the displayed language list.
class HomeViewModel extends ChangeNotifier {
  final LanguageRepository _repository;
  final Debouncer _debouncer = Debouncer(milliseconds: 300);

  List<Language> _filteredLanguages = [];
  String _searchQuery = '';
  String _selectedEndangerment = 'all';
  Language? _selectedLanguage;
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
  bool get isSearching => _isSearching;

  int get totalCount => _repository.totalCount;
  int get filteredCount => _filteredLanguages.length;

  List<String> get endangermentStatuses =>
      ['all', ..._repository.getEndangermentStatuses()];

  Map<String, int> get endangermentCounts =>
      _repository.getEndangermentCounts();

  // ─── Actions ─────────────────────────────────────────────────────────────

  /// Update the search query with debouncing.
  void onSearchChanged(String query) {
    _searchQuery = query;
    _isSearching = query.isNotEmpty;
    notifyListeners();

    _debouncer.run(() {
      _applyFilters();
    });
  }

  /// Set the endangerment filter.
  void setEndangermentFilter(String status) {
    _selectedEndangerment = status;
    _applyFilters();
  }

  /// Clear all filters and search.
  void clearFilters() {
    _searchQuery = '';
    _selectedEndangerment = 'all';
    _isSearching = false;
    _filteredLanguages = _repository.getAllLanguages();
    notifyListeners();
  }

  /// Select a language to view details.
  void selectLanguage(Language? language) {
    _selectedLanguage = language;
    notifyListeners();
  }

  /// Apply current search and filter criteria.
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
