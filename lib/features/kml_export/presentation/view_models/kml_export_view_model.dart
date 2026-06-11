import 'dart:convert';
import 'dart:typed_data';

import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:global_language_distribution_map/data/models/language.dart';
import 'package:global_language_distribution_map/data/repositories/language_repository.dart';
import 'package:global_language_distribution_map/data/services/kml_service.dart';

/// ViewModel for KML export functionality.
///
/// Manages the export workflow state and orchestrates KML generation + file saving.
/// Uses [KmlService] for generation and [FileSaver] for cross-platform file saving.
class KmlExportViewModel extends ChangeNotifier {
  final LanguageRepository _repository;

  KmlExportViewModel({required LanguageRepository repository})
      : _repository = repository;

  // ─── State ──────────────────────────────────────────────────────────────────

  bool _isExporting = false;
  String? _lastExportFilename;
  String? _exportError;
  String _exportProgress = '';
  int _lastExportedCount = 0;

  // ─── Getters ────────────────────────────────────────────────────────────────

  /// Whether an export is currently in progress.
  bool get isExporting => _isExporting;

  /// Name of the last successfully exported file, or null.
  String? get lastExportFilename => _lastExportFilename;

  /// Error message if the last export failed, or null.
  String? get exportError => _exportError;

  /// Progress text during export (e.g., "Generating placemarks…").
  String get exportProgress => _exportProgress;

  /// Number of languages in the last export.
  int get lastExportedCount => _lastExportedCount;

  /// Whether an export has completed successfully.
  bool get hasExported => _lastExportFilename != null;

  /// Total number of languages with valid coordinates.
  int get totalMappableLanguages => _repository.languagesWithCoordinates;

  // ─── Export Methods ─────────────────────────────────────────────────────────

  /// Export all languages with valid coordinates to a KML file.
  Future<void> exportAllLanguages() async {
    final languages = _repository.getAllLanguages();
    final mappable = languages.where((l) => l.hasCoordinates).toList();

    await _performExport(
      languages: mappable,
      filename: 'global_languages',
      title: 'Global Language Distribution Map',
      description:
          '${mappable.length} languages from Glottolog & UNESCO datasets.',
    );
  }

  /// Export a filtered subset of languages to a KML file.
  ///
  /// [languages] should be pre-filtered (e.g., from MapViewModel.filteredLanguages).
  /// [filterName] is used in the filename and document title.
  Future<void> exportFilteredLanguages(
    List<Language> languages,
    String filterName,
  ) async {
    final mappable = languages.where((l) => l.hasCoordinates).toList();
    final safeName = filterName
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]'), '_')
        .replaceAll(RegExp(r'_+'), '_');

    await _performExport(
      languages: mappable,
      filename: 'languages_$safeName',
      title: 'Languages — ${_capitalize(filterName)}',
      description:
          '${mappable.length} $filterName languages from Glottolog & UNESCO datasets.',
    );
  }

  /// Clear the export state (error, filename, progress).
  void clearExportState() {
    _exportError = null;
    _lastExportFilename = null;
    _exportProgress = '';
    _lastExportedCount = 0;
    notifyListeners();
  }

  // ─── Private Implementation ─────────────────────────────────────────────────

  Future<void> _performExport({
    required List<Language> languages,
    required String filename,
    required String title,
    String? description,
  }) async {
    if (_isExporting) return;

    _isExporting = true;
    _exportError = null;
    _lastExportFilename = null;
    _exportProgress = 'Generating KML for ${languages.length} languages…';
    notifyListeners();

    try {
      // Step 1: Generate KML content
      _exportProgress = 'Building placemarks and styles…';
      notifyListeners();

      // Use a microtask delay to let the UI update before heavy computation
      await Future.delayed(const Duration(milliseconds: 50));

      final kmlContent = KmlService.generateKml(
        languages,
        title: title,
        description: description,
      );

      // Step 2: Save the file
      _exportProgress = 'Saving file…';
      notifyListeners();

      final timestampedFilename =
          '${filename}_${DateTime.now().millisecondsSinceEpoch}';

      final bytes = Uint8List.fromList(utf8.encode(kmlContent));
      await FileSaver.instance.saveFile(
        name: timestampedFilename,
        bytes: bytes,
        ext: 'kml',
        mimeType: MimeType.other,
      );

      // Step 3: Success
      _lastExportFilename = '$timestampedFilename.kml';
      _lastExportedCount = languages.length;
      _exportProgress = '';
      _exportError = null;
    } catch (e) {
      _exportError = 'Export failed: $e';
      _exportProgress = '';
    } finally {
      _isExporting = false;
      notifyListeners();
    }
  }

  static String _capitalize(String text) {
    if (text.isEmpty) return text;
    return '${text[0].toUpperCase()}${text.substring(1)}';
  }
}
