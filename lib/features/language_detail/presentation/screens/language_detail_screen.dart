import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:global_language_distribution_map/app/router.dart';
import 'package:global_language_distribution_map/app/theme.dart';
import 'package:global_language_distribution_map/core/constants/app_constants.dart';
import 'package:global_language_distribution_map/data/models/language.dart';
import 'package:global_language_distribution_map/features/map/presentation/view_models/map_view_model.dart';
import 'package:global_language_distribution_map/data/services/tts_service.dart';

/// Full-screen Language Detail page.
///
/// Shows comprehensive information about a specific language including
/// status, classification, geography, and action buttons.
class LanguageDetailScreen extends StatelessWidget {
  final Language language;

  const LanguageDetailScreen({super.key, required this.language});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final statusColor = AppTheme.getEndangermentColor(language.endangeredStatus);
    final statusLabel =
        AppConstants.endangermentStatusNames[language.endangeredStatus] ??
            language.endangeredStatus;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryGreenDark,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.volume_up_rounded),
            onPressed: () {
              final desc = TtsService.buildLanguageDescription(
                name: language.name,
                family: language.languageFamily,
                endangeredStatus: language.endangeredStatus,
                countryRegion: language.countryRegion,
                latitude: language.latitude,
                longitude: language.longitude,
              );
              TtsService().speak(desc);
            },
            tooltip: 'Listen',
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {},
            tooltip: 'Share',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Green Header ─────────────────────────────────────
            Container(
              width: double.infinity,
              color: AppTheme.primaryGreenDark,
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Family chip
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${language.languageFamily} Family',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    language.name,
                    style: GoogleFonts.inter(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            // ─── Body ────────────────────────────────
            Container(
              color: colorScheme.surface,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),

                  // UNESCO Status card
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.07),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: statusColor.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.shield_rounded,
                              color: statusColor,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'UNESCO Status',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                Text(
                                  statusLabel,
                                  style: GoogleFonts.inter(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                    color: statusColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 4 Info cards grid
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      shrinkWrap: true,
                      childAspectRatio: 1.6,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _InfoCard(
                          label: 'Speakers',
                          value: _parseSpeakers(language.description),
                          icon: Icons.people_rounded,
                          iconColor: AppTheme.primaryGreen,
                        ),
                        _InfoCard(
                          label: 'Script',
                          value: _detectScript(language.name),
                          icon: Icons.text_fields_rounded,
                          iconColor: const Color(0xFF6A1B9A),
                        ),
                        _InfoCard(
                          label: 'Region',
                          value: language.countryRegion.length > 12
                              ? '${language.countryRegion.substring(0, 12)}...'
                              : language.countryRegion,
                          icon: Icons.location_on_rounded,
                          iconColor: const Color(0xFF00838F),
                        ),
                        _InfoCard(
                          label: 'Status',
                          value: AppConstants
                                  .endangermentLabels[
                                      language.endangeredStatus] ??
                              language.endangeredStatus,
                          icon: Icons.warning_amber_rounded,
                          iconColor: statusColor,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Classification section
                  _SectionHeader(title: 'Classification'),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        children: [
                          _ClassificationRow(
                              label: 'Family',
                              value: language.languageFamily),
                          _ClassificationRow(
                              label: 'Coordinates',
                              value:
                                  '${language.latitude.toStringAsFixed(3)}°, ${language.longitude.toStringAsFixed(3)}°'),
                          _ClassificationRow(
                              label: 'ID', value: language.id),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Countries / Region
                  _SectionHeader(title: 'Countries / Regions'),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: language.countryRegion
                          .split(' ')
                          .map((code) => _CountryChip(code: code))
                          .toList(),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Description
                  _SectionHeader(title: 'About'),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      language.description,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: colorScheme.onSurfaceVariant,
                        height: 1.6,
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Action buttons
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              context.pop();
                            },
                            icon: const Icon(Icons.map_outlined, size: 18),
                            label: Text(
                              'View on Map',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              context.read<MapViewModel>().selectLanguage(language);
                              context.pop();
                              context.go(RoutePaths.map);
                            },
                            icon: const Icon(
                                Icons.flight_takeoff_rounded,
                                size: 18),
                            label: Text(
                              'Fly To',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _parseSpeakers(String description) {
    final match =
        RegExp(r'speakers:\s*([\d.]+)', caseSensitive: false).firstMatch(description);
    if (match != null) {
      final count = double.tryParse(match.group(1) ?? '0') ?? 0;
      if (count == 0) return '0';
      if (count >= 1e9) return '${(count / 1e9).toStringAsFixed(1)}B';
      if (count >= 1e6) return '${(count / 1e6).toStringAsFixed(1)}M';
      if (count >= 1000) return '${(count / 1000).toStringAsFixed(0)}K';
      return count.toInt().toString();
    }
    return 'Unknown';
  }

  static String _detectScript(String name) {
    // Heuristic: check if name contains non-latin characters
    if (RegExp(r'[\u0600-\u06FF]').hasMatch(name)) return 'Arabic';
    if (RegExp(r'[\u4E00-\u9FFF]').hasMatch(name)) return 'Han';
    if (RegExp(r'[\u0900-\u097F]').hasMatch(name)) return 'Devanagari';
    if (RegExp(r'[\u0400-\u04FF]').hasMatch(name)) return 'Cyrillic';
    return 'Latin';
  }
}

class _InfoCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;

  const _InfoCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: iconColor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: iconColor.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: iconColor, size: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
      child: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: colorScheme.onSurface,
        ),
      ),
    );
  }
}

class _ClassificationRow extends StatelessWidget {
  final String label;
  final String value;

  const _ClassificationRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CountryChip extends StatelessWidget {
  final String code;

  const _CountryChip({required this.code});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Text(
        code.trim(),
        style: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: colorScheme.onSurface,
        ),
      ),
    );
  }
}
