/// Application-wide constants.
class AppConstants {
  AppConstants._();

  static const String appName = 'Language Map';
  static const String appVersion = '1.0.0';

  /// Data source attributions
  static const String glottologAttribution =
      'Language data from Glottolog 5.0 (https://glottolog.org). '
      'Licensed under CC BY 4.0.';

  static const String unescoAttribution =
      'Endangerment data from UNESCO Atlas of the World\'s Languages in Danger. '
      'Published by The Guardian.';

  /// Endangerment status display labels (used in UI)
  static const Map<String, String> endangermentLabels = {
    'not endangered': 'Safe',
    'threatened': 'Vulnerable',
    'shifting': 'Definitely',
    'moribund': 'Severely',
    'nearly extinct': 'Critically',
    'extinct': 'Extinct',
  };

  /// Display colors per status (hex string for reference)
  static const Map<String, String> endangermentStatusNames = {
    'not endangered': 'Safe',
    'threatened': 'Vulnerable',
    'shifting': 'Definitely Endangered',
    'moribund': 'Severely Endangered',
    'nearly extinct': 'Critically Endangered',
    'extinct': 'Extinct',
  };

  /// Developer info
  static const String developerName = 'Raksha AK';
  static const String organization = 'Liquid Galaxy Project';
  static const String program = 'Google Summer of Code 2026';
  static const String githubUrl = 'https://github.com/rakshaak/global_language_distribution_map';

  /// Predefined language family speaker counts (approximate, for Families screen)
  static const Map<String, String> familySpeakerCounts = {
    'Indo-European': '3.2 Billion',
    'Sino-Tibetan': '1.4 Billion',
    'Afro-Asiatic': '400 Million',
    'Niger-Congo': '700 Million',
    'Austronesian': '386 Million',
    'Dravidian': '250 Million',
    'Turkic': '200 Million',
    'Japonic': '128 Million',
    'Koreanic': '82 Million',
    'Tai-Kadai': '93 Million',
    'Austroasiatic': '117 Million',
    'Uralic': '25 Million',
  };

  /// Predefined family emoji icons
  static const Map<String, String> familyEmojis = {
    'Indo-European': '🌍',
    'Sino-Tibetan': '🏮',
    'Afro-Asiatic': '🌙',
    'Niger-Congo': '🥁',
    'Austronesian': '🏝️',
    'Dravidian': '🛕',
    'Turkic': '⭐',
    'Japonic': '🌸',
    'Koreanic': '🎋',
    'Tai-Kadai': '🎐',
    'Austroasiatic': '🎍',
    'Uralic': '❄️',
    'Bookkeeping': '📚',
    'Tuu': '🌿',
    'Khoe-Kwadi': '🌾',
  };

  /// Guided tours configuration
  static const List<Map<String, dynamic>> guidedTours = [
    {
      'name': 'Languages of Africa',
      'description': 'Explore 2,143 languages across the African continent',
      'langCount': '2,143 langs',
      'color': '0xFF2E7D32',
      'dotColor': '0xFF4CAF50',
      'regions': ['Africa', 'AF'],
    },
    {
      'name': 'Languages of India',
      'description': 'Discover 1,000+ languages of the Indian subcontinent',
      'langCount': '1,000 langs',
      'color': '0xFF6A1B9A',
      'dotColor': '0xFFAB47BC',
      'regions': ['IN', 'South Asia'],
    },
    {
      'name': 'Americas Indigenous',
      'description': 'Journey through 984 indigenous American languages',
      'langCount': '984 langs',
      'color': '0xFFE65100',
      'dotColor': '0xFFFF9800',
      'regions': ['Americas', 'NA', 'SA'],
    },
    {
      'name': 'Pacific Languages',
      'description': 'Explore 289 languages of the Pacific Islands',
      'langCount': '289 langs',
      'color': '0xFF00838F',
      'dotColor': '0xFF26C6DA',
      'regions': ['Papunesia', 'Pacific'],
    },
    {
      'name': 'European Languages',
      'description': 'Discover the rich diversity of European tongues',
      'langCount': '285 langs',
      'color': '0xFF1565C0',
      'dotColor': '0xFF42A5F5',
      'regions': ['Europe', 'EU'],
    },
  ];

  /// Diversity hotspots (approximate, for Heatmap screen)
  static const List<Map<String, dynamic>> diversityHotspots = [
    {
      'name': 'Papua New Guinea',
      'description': 'Highest diversity region',
      'count': 840,
    },
    {
      'name': 'West Africa',
      'description': 'Very high linguistic density',
      'count': 520,
    },
    {
      'name': 'Southeast Asia',
      'description': 'High diversity region',
      'count': 410,
    },
    {
      'name': 'South Asia',
      'description': 'Diverse language families',
      'count': 390,
    },
    {
      'name': 'Central Africa',
      'description': 'Niger-Congo heartland',
      'count': 320,
    },
    {
      'name': 'Amazon Basin',
      'description': 'Indigenous language hub',
      'count': 280,
    },
    {
      'name': 'Caucasus Region',
      'description': 'Mountain of languages',
      'count': 50,
    },
  ];
}
