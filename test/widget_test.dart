// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package.

import 'package:flutter_test/flutter_test.dart';
import 'package:global_language_distribution_map/data/models/language.dart';

void main() {
  group('Language model', () {
    test('should create from JSON correctly', () {
      final json = {
        'id': 'test1234',
        'name': 'Test Language',
        'languageFamily': 'Test Family',
        'countryRegion': 'TS',
        'latitude': 12.34,
        'longitude': 56.78,
        'endangeredStatus': 'threatened',
        'description': 'A test language.',
      };

      final language = Language.fromJson(json);

      expect(language.id, 'test1234');
      expect(language.name, 'Test Language');
      expect(language.languageFamily, 'Test Family');
      expect(language.countryRegion, 'TS');
      expect(language.latitude, 12.34);
      expect(language.longitude, 56.78);
      expect(language.endangeredStatus, 'threatened');
      expect(language.description, 'A test language.');
      expect(language.hasCoordinates, isTrue);
      expect(language.isEndangered, isTrue);
    });

    test('should serialize to JSON correctly', () {
      const language = Language(
        id: 'test1234',
        name: 'Test Language',
        languageFamily: 'Test Family',
        countryRegion: 'TS',
        latitude: 12.34,
        longitude: 56.78,
        endangeredStatus: 'not endangered',
        description: 'A test language.',
      );

      final json = language.toJson();

      expect(json['id'], 'test1234');
      expect(json['name'], 'Test Language');
      expect(language.isEndangered, isFalse);
    });

    test('should handle missing JSON fields with defaults', () {
      final language = Language.fromJson({});

      expect(language.id, '');
      expect(language.name, '');
      expect(language.languageFamily, 'Unclassified');
      expect(language.countryRegion, 'Unknown');
      expect(language.latitude, 0.0);
      expect(language.longitude, 0.0);
      expect(language.endangeredStatus, 'not endangered');
      expect(language.description, '');
      expect(language.hasCoordinates, isFalse);
    });
  });
}
