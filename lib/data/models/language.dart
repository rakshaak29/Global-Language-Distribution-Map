

/// Represents a language with its geographic, classification, and endangerment data.
/// Normalized from Glottolog and UNESCO data sources.
class Language {
  final String id;
  final String name;
  final String languageFamily;
  final String countryRegion;
  final double latitude;
  final double longitude;
  final String endangeredStatus;
  final String description;

  const Language({
    required this.id,
    required this.name,
    required this.languageFamily,
    required this.countryRegion,
    required this.latitude,
    required this.longitude,
    required this.endangeredStatus,
    required this.description,
  });

  factory Language.fromJson(Map<String, dynamic> json) {
    return Language(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      languageFamily: json['languageFamily'] as String? ?? 'Unclassified',
      countryRegion: json['countryRegion'] as String? ?? 'Unknown',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      endangeredStatus: json['endangeredStatus'] as String? ?? 'not endangered',
      description: json['description'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'languageFamily': languageFamily,
      'countryRegion': countryRegion,
      'latitude': latitude,
      'longitude': longitude,
      'endangeredStatus': endangeredStatus,
      'description': description,
    };
  }

  /// Whether this language has valid geographic coordinates.
  bool get hasCoordinates => latitude != 0.0 || longitude != 0.0;

  /// Whether this language is endangered in any form.
  bool get isEndangered => endangeredStatus != 'not endangered';

  /// Raw speaker count parsed from description, or estimated using deterministic ID hash.
  double get speakerCount {
    final desc = description.toLowerCase();
    final match = RegExp(r'speakers:\s*([\d.]+)').firstMatch(desc);
    if (match != null) {
      return double.tryParse(match.group(1) ?? '0') ?? 0.0;
    }
    
    // Deterministic imputation using the language ID's hash code
    final int hash = id.hashCode.abs();
    switch (endangeredStatus) {
      case 'extinct':
        return 0.0;
      case 'nearly extinct':
        return (10 + (hash % 90)).toDouble(); // 10 to 100
      case 'moribund':
        return (100 + (hash % 900)).toDouble(); // 100 to 1,000
      case 'shifting':
        return (1000 + (hash % 14000)).toDouble(); // 1,000 to 15,000
      case 'threatened':
        return (15000 + (hash % 85000)).toDouble(); // 15,000 to 100,000
      default:
        return (100000 + (hash % 900000)).toDouble(); // 100,000 to 1,000,000
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Language && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Language(id: $id, name: $name, family: $languageFamily)';
}
