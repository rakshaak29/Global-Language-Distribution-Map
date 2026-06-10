

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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Language && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Language(id: $id, name: $name, family: $languageFamily)';
}
