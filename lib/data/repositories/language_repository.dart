import 'package:global_language_distribution_map/data/models/language.dart';
import 'package:global_language_distribution_map/data/services/local_data_service.dart';

/// Repository that provides language data with querying and filtering capabilities.
///
/// Acts as the single source of truth for language data in the application.
class LanguageRepository {
  final LocalDataService _dataService;

  List<Language> _allLanguages = [];
  bool _isLoaded = false;

  LanguageRepository({LocalDataService? dataService})
      : _dataService = dataService ?? LocalDataService();

  /// Whether the language data has been loaded.
  bool get isLoaded => _isLoaded;

  /// Total number of languages in the dataset.
  int get totalCount => _allLanguages.length;

  /// Load all language data from the local data service.
  Future<void> loadData() async {
    if (_isLoaded) return;
    _allLanguages = await _dataService.loadLanguages();
    _isLoaded = true;
  }

  /// Returns all loaded languages.
  List<Language> getAllLanguages() => List.unmodifiable(_allLanguages);

  /// Search languages by name, family, or country/region.
  List<Language> searchLanguages(String query) {
    if (query.isEmpty) return getAllLanguages();

    final lowerQuery = query.toLowerCase();
    return _allLanguages.where((lang) {
      return lang.name.toLowerCase().contains(lowerQuery) ||
          lang.languageFamily.toLowerCase().contains(lowerQuery) ||
          lang.countryRegion.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  /// Filter languages by endangerment status.
  List<Language> filterByEndangerment(String status) {
    if (status.isEmpty || status == 'all') return getAllLanguages();
    return _allLanguages
        .where((lang) => lang.endangeredStatus == status)
        .toList();
  }

  /// Filter languages by family.
  List<Language> filterByFamily(String family) {
    if (family.isEmpty || family == 'all') return getAllLanguages();
    return _allLanguages
        .where((lang) => lang.languageFamily == family)
        .toList();
  }

  /// Combined search and filter.
  List<Language> searchAndFilter({
    String query = '',
    String endangermentFilter = '',
    String familyFilter = '',
  }) {
    var results = _allLanguages.toList();

    if (query.isNotEmpty) {
      final lowerQuery = query.toLowerCase();
      results = results.where((lang) {
        return lang.name.toLowerCase().contains(lowerQuery) ||
            lang.languageFamily.toLowerCase().contains(lowerQuery) ||
            lang.countryRegion.toLowerCase().contains(lowerQuery);
      }).toList();
    }

    if (endangermentFilter.isNotEmpty && endangermentFilter != 'all') {
      results = results
          .where((lang) => lang.endangeredStatus == endangermentFilter)
          .toList();
    }

    if (familyFilter.isNotEmpty && familyFilter != 'all') {
      results =
          results.where((lang) => lang.languageFamily == familyFilter).toList();
    }

    return results;
  }

  /// Returns all unique language families, sorted alphabetically.
  List<String> getLanguageFamilies() {
    final families =
        _allLanguages.map((l) => l.languageFamily).toSet().toList();
    families.sort();
    return families;
  }

  /// Returns all unique endangerment statuses.
  List<String> getEndangermentStatuses() {
    return [
      'not endangered',
      'threatened',
      'shifting',
      'moribund',
      'nearly extinct',
      'extinct',
    ];
  }

  /// Returns the count of languages per endangerment status.
  Map<String, int> getEndangermentCounts() {
    final counts = <String, int>{};
    for (final lang in _allLanguages) {
      counts[lang.endangeredStatus] =
          (counts[lang.endangeredStatus] ?? 0) + 1;
    }
    return counts;
  }

  /// Returns how many languages have valid coordinates.
  int get languagesWithCoordinates =>
      _allLanguages.where((l) => l.hasCoordinates).length;
}
