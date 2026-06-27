import 'dart:async';

import 'package:flutter/material.dart';
import 'package:global_language_distribution_map/data/models/language.dart';
import 'package:global_language_distribution_map/data/repositories/language_repository.dart';
import 'package:global_language_distribution_map/data/services/fly_to_service.dart';
import 'package:latlong2/latlong.dart';

/// ViewModel for the Map screen.
///
/// Manages the map state including language markers, search, camera position,
/// and selected language details. Architecture is KML-first — the data layer
/// works with raw Language objects and coordinates, making future KML
/// generation and Liquid Galaxy integration straightforward.
///
/// Extension points:
/// - [filteredLanguages] → feed into KML generator
/// - [selectedLanguage] → highlight in Liquid Galaxy
/// - [cameraPosition] / [zoomLevel] → sync with Liquid Galaxy viewpoint
/// - [activeFilter] → map to KML folder visibility
class MapViewModel extends ChangeNotifier {
  final LanguageRepository _repository;

  MapViewModel({required LanguageRepository repository})
      : _repository = repository {
    _initializeLanguages();
  }

  // ─── State ──────────────────────────────────────────────────────────────────

  List<Language> _languagesWithCoords = [];
  List<Language> _filteredLanguages = [];
  Language? _selectedLanguage;
  String _searchQuery = '';
  List<Language> _searchResults = [];
  bool _isSearchVisible = false;
  bool _isLoading = true;
  String? _errorMessage;
  LatLng _cameraCenter = const LatLng(20.0, 0.0);
  double _zoomLevel = 1.7;
  String _endangermentFilter = 'all';
  String _familyFilter = 'all';
  String? _currentFlyToKml;

  // Debounce timer for search
  Timer? _searchDebounce;

  // ─── Getters ────────────────────────────────────────────────────────────────

  /// All languages that have valid coordinates — the full mappable dataset.
  List<Language> get languagesWithCoords => _languagesWithCoords;

  /// Currently filtered/visible languages on the map.
  /// This is the primary data source for marker generation and future KML export.
  List<Language> get filteredLanguages => _filteredLanguages;

  /// The currently selected language (tapped marker).
  Language? get selectedLanguage => _selectedLanguage;

  /// The generated FlyTo KML snippet for the currently selected language.
  String? get currentFlyToKml => _currentFlyToKml;

  /// Current search query.
  String get searchQuery => _searchQuery;

  /// Search results for the current query.
  List<Language> get searchResults => _searchResults;

  /// Whether the search overlay is visible.
  bool get isSearchVisible => _isSearchVisible;

  /// Whether the map data is still loading.
  bool get isLoading => _isLoading;

  /// Error message, if any.
  String? get errorMessage => _errorMessage;

  /// Current map center — useful for Liquid Galaxy viewpoint sync.
  LatLng get cameraCenter => _cameraCenter;

  /// Current zoom level — useful for Liquid Galaxy viewpoint sync.
  double get zoomLevel => _zoomLevel;

  /// Active endangerment filter.
  String get endangermentFilter => _endangermentFilter;

  /// Active family filter.
  String get familyFilter => _familyFilter;

  /// Total count of mappable languages.
  int get totalLanguages => _repository.totalCount;

  /// Count of languages with coordinates.
  int get languagesWithCoordinates => _repository.languagesWithCoordinates;

  /// Count of currently visible (filtered) languages.
  int get visibleCount => _filteredLanguages.length;

  /// All unique language families for filter UI.
  List<String> get languageFamilies => _repository.getLanguageFamilies();

  /// All endangerment statuses for filter UI.
  List<String> get endangermentStatuses => _repository.getEndangermentStatuses();

  // ─── Initialization ─────────────────────────────────────────────────────────

  void _initializeLanguages() {
    try {
      final all = _repository.getAllLanguages();
      _languagesWithCoords =
          all.where((lang) => lang.hasCoordinates).toList();
      _filteredLanguages = _languagesWithCoords;
      _isLoading = false;
    } catch (e) {
      _errorMessage = 'Failed to load language data: $e';
      _isLoading = false;
    }
    notifyListeners();
  }

  // ─── Search ─────────────────────────────────────────────────────────────────

  /// Toggle search overlay visibility.
  void toggleSearch() {
    _isSearchVisible = !_isSearchVisible;
    if (!_isSearchVisible) {
      _searchQuery = '';
      _searchResults = [];
    }
    notifyListeners();
  }

  /// Close search overlay.
  void closeSearch() {
    _isSearchVisible = false;
    _searchQuery = '';
    _searchResults = [];
    notifyListeners();
  }

  /// Update search query with debouncing.
  void updateSearchQuery(String query) {
    _searchQuery = query;
    _searchDebounce?.cancel();

    if (query.isEmpty) {
      _searchResults = [];
      notifyListeners();
      return;
    }

    _searchDebounce = Timer(const Duration(milliseconds: 250), () {
      _performSearch(query);
    });
  }

  void _performSearch(String query) {
    final lowerQuery = query.toLowerCase();
    _searchResults = _languagesWithCoords.where((lang) {
      return lang.name.toLowerCase().contains(lowerQuery) ||
          lang.languageFamily.toLowerCase().contains(lowerQuery) ||
          lang.countryRegion.toLowerCase().contains(lowerQuery);
    }).take(50).toList(); // Limit results for performance
    notifyListeners();
  }

  int _selectionEventId = 0;
  
  /// A counter that increments every time a language is selected.
  /// Useful for triggering animations even if the same language is selected again.
  int get selectionEventId => _selectionEventId;

  // ─── Selection ──────────────────────────────────────────────────────────────

  /// Select a language (e.g., when a marker is tapped).
  /// Returns the LatLng for camera animation.
  LatLng? selectLanguage(Language language) {
    _selectionEventId++;
    _selectedLanguage = language;
    _currentFlyToKml = FlyToService.generateFlyToKml(
      latitude: language.latitude,
      longitude: language.longitude,
      name: language.name,
    );
    notifyListeners();
    return LatLng(language.latitude, language.longitude);
  }

  /// Convenience entry point for external screens (Endangered, Families, Tours).
  /// Clears existing filters, selects the language, and generates FlyTo KML.
  /// Callers should navigate to the Map tab after calling this.
  LatLng? flyToLanguage(Language language) {
    _endangermentFilter = 'all';
    _familyFilter = 'all';
    _filteredLanguages = _languagesWithCoords;
    return selectLanguage(language);
  }

  /// Clear the selected language.
  void clearSelection() {
    _selectionEventId++;
    _selectedLanguage = null;
    _currentFlyToKml = null;
    notifyListeners();
  }

  // ─── Camera ─────────────────────────────────────────────────────────────────

  /// Update stored camera position (for Liquid Galaxy sync).
  void updateCameraPosition(LatLng center, double zoom) {
    _cameraCenter = center;
    _zoomLevel = zoom;
    // Don't notify — this is called during camera move, no UI rebuild needed.
  }

  /// Get the LatLng for navigating to a specific language.
  LatLng getLanguagePosition(Language language) {
    return LatLng(language.latitude, language.longitude);
  }

  // ─── Filtering ──────────────────────────────────────────────────────────────

  /// Filter by endangerment status.
  void setEndangermentFilter(String status) {
    _endangermentFilter = status;
    _applyFilters();
  }

  /// Filter by language family.
  void setFamilyFilter(String family) {
    _familyFilter = family;
    _applyFilters();
  }

  /// Clear all filters.
  void clearFilters() {
    _endangermentFilter = 'all';
    _familyFilter = 'all';
    _filteredLanguages = _languagesWithCoords;
    notifyListeners();
  }

  void _applyFilters() {
    var results = _languagesWithCoords.toList();

    if (_endangermentFilter != 'all') {
      results = results
          .where((l) => l.endangeredStatus == _endangermentFilter)
          .toList();
    }

    if (_familyFilter != 'all') {
      results =
          results.where((l) => l.languageFamily == _familyFilter).toList();
    }

    _filteredLanguages = results;
    notifyListeners();
  }

  // ─── Cleanup ────────────────────────────────────────────────────────────────

  @override
  void dispose() {
    _searchDebounce?.cancel();
    super.dispose();
  }
}
