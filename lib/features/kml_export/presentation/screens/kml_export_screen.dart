import 'package:flutter/material.dart';
import 'package:global_language_distribution_map/features/kml_export/presentation/view_models/kml_export_view_model.dart';
import 'package:global_language_distribution_map/features/map/presentation/view_models/map_view_model.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

/// The KML Export Screen.
///
/// Provides options to generate and download KML files from the language dataset.
/// Follows the existing card-based design language from the Settings screen.
class KmlExportScreen extends StatelessWidget {
  const KmlExportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final exportVm = context.watch<KmlExportViewModel>();
    final mapVm = context.watch<MapViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Export KML',
          style: GoogleFonts.inter(fontWeight: FontWeight.w700),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          // ─── Header ──────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        colorScheme.primary.withValues(alpha: 0.15),
                        colorScheme.secondary.withValues(alpha: 0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.public_rounded,
                    color: colorScheme.primary,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'KML File Generator',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Generate KML files for Google Earth & Liquid Galaxy',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ─── Export Options ──────────────────────────────────────
          _buildSectionHeader(context, 'Export Options'),

          // Export All Languages
          Card(
            child: InkWell(
              onTap: exportVm.isExporting
                  ? null
                  : () => exportVm.exportAllLanguages(),
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.language_rounded,
                        color: Color(0xFF4CAF50),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Export All Languages',
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${exportVm.totalMappableLanguages} languages with coordinates',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.download_rounded,
                      color: colorScheme.primary,
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 4),

          // Export Filtered Languages
          Card(
            child: InkWell(
              onTap: exportVm.isExporting
                  ? null
                  : () {
                      final filtered = mapVm.filteredLanguages;
                      final filterName = _buildFilterName(mapVm);
                      exportVm.exportFilteredLanguages(filtered, filterName);
                    },
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.filter_alt_rounded,
                        color: colorScheme.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Export Filtered Languages',
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${mapVm.visibleCount} languages (${_buildFilterName(mapVm)})',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.download_rounded,
                      color: colorScheme.primary,
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // ─── Export Status ──────────────────────────────────────
          if (exportVm.isExporting ||
              exportVm.hasExported ||
              exportVm.exportError != null) ...[
            _buildSectionHeader(context, 'Export Status'),
            _buildStatusCard(context, exportVm),
            const SizedBox(height: 16),
          ],

          // ─── Instructions ───────────────────────────────────────
          _buildSectionHeader(context, 'How to Use'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInstructionStep(
                    context,
                    step: 1,
                    title: 'Generate the KML file',
                    description:
                        'Tap "Export All Languages" or "Export Filtered" above to download a .kml file.',
                  ),
                  const Divider(height: 24),
                  _buildInstructionStep(
                    context,
                    step: 2,
                    title: 'Open in Google Earth',
                    description:
                        'Open the downloaded .kml file in Google Earth Pro (desktop) or import it at earth.google.com/web.',
                  ),
                  const Divider(height: 24),
                  _buildInstructionStep(
                    context,
                    step: 3,
                    title: 'Explore languages',
                    description:
                        'Click any marker to see the language name, family, region, and endangerment status.',
                  ),
                  const Divider(height: 24),
                  _buildInstructionStep(
                    context,
                    step: 4,
                    title: 'Liquid Galaxy (coming soon)',
                    description:
                        'In a future update, KML files can be sent directly to a Liquid Galaxy rig via SSH.',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ─── KML Info ──────────────────────────────────────────
          _buildSectionHeader(context, 'About KML'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color:
                              colorScheme.secondary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.info_outline_rounded,
                          color: colorScheme.secondary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'What is KML?',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'KML (Keyhole Markup Language) is an XML-based format '
                    'for displaying geographic data in applications like '
                    'Google Earth, Google Maps, and Liquid Galaxy. '
                    'Each language is represented as a placemark with '
                    'its coordinates, metadata, and an endangerment-colored icon.',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: colorScheme.onSurfaceVariant,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  Widget _buildSectionHeader(BuildContext context, String title) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: colorScheme.primary,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildStatusCard(
      BuildContext context, KmlExportViewModel exportVm) {
    final colorScheme = Theme.of(context).colorScheme;

    if (exportVm.isExporting) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  exportVm.exportProgress,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (exportVm.exportError != null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colorScheme.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.error_outline_rounded,
                  color: colorScheme.error,
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Export Failed',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.error,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      exportVm.exportError!,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => exportVm.clearExportState(),
                icon: Icon(
                  Icons.close_rounded,
                  size: 18,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (exportVm.hasExported) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: Color(0xFF4CAF50),
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Export Successful',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF4CAF50),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${exportVm.lastExportedCount} languages → ${exportVm.lastExportFilename}',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => exportVm.clearExportState(),
                icon: Icon(
                  Icons.close_rounded,
                  size: 18,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildInstructionStep(
    BuildContext context, {
    required int step,
    required String title,
    required String description,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '$step',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: colorScheme.primary,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _buildFilterName(MapViewModel mapVm) {
    if (mapVm.endangermentFilter != 'all') {
      return mapVm.endangermentFilter;
    }
    if (mapVm.familyFilter != 'all') {
      return mapVm.familyFilter;
    }
    return 'all filters';
  }
}
