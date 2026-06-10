import 'package:flutter/material.dart';
import 'package:global_language_distribution_map/app/theme.dart';
import 'package:global_language_distribution_map/data/models/language.dart';
import 'package:google_fonts/google_fonts.dart';

/// A bottom sheet that displays detailed information about a selected language.
///
/// Shows language name, family, country/region, endangerment status with
/// color-coded badge, coordinates, and description.
///
/// Designed to be modular — future versions can add:
/// - "View on Liquid Galaxy" button
/// - "Export KML" action
/// - "Add to Tour" action
class LanguageDetailSheet extends StatelessWidget {
  final Language language;
  final VoidCallback? onClose;

  const LanguageDetailSheet({
    super.key,
    required this.language,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final endangermentColor =
        AppTheme.getEndangermentColor(language.endangeredStatus);

    return Container(
      constraints: const BoxConstraints(maxHeight: 380),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 8),
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Content
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header row: name + close button
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              language.name,
                              style: GoogleFonts.inter(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              language.languageFamily,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (onClose != null)
                        IconButton(
                          onPressed: onClose,
                          icon: Icon(
                            Icons.close_rounded,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          style: IconButton.styleFrom(
                            backgroundColor: colorScheme.surfaceContainerHigh,
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Status badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: endangermentColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: endangermentColor.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: endangermentColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          language.endangeredStatus.toUpperCase(),
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: endangermentColor,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Info rows
                  _buildInfoRow(
                    context,
                    icon: Icons.public_rounded,
                    label: 'Country / Region',
                    value: language.countryRegion,
                  ),
                  const SizedBox(height: 10),
                  _buildInfoRow(
                    context,
                    icon: Icons.location_on_rounded,
                    label: 'Coordinates',
                    value:
                        '${language.latitude.toStringAsFixed(4)}, ${language.longitude.toStringAsFixed(4)}',
                  ),
                  const SizedBox(height: 10),
                  _buildInfoRow(
                    context,
                    icon: Icons.tag_rounded,
                    label: 'Glottolog ID',
                    value: language.id,
                  ),

                  // Description
                  if (language.description.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Divider(color: colorScheme.outlineVariant),
                    const SizedBox(height: 12),
                    Text(
                      language.description,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: colorScheme.onSurfaceVariant,
                        height: 1.5,
                      ),
                    ),
                  ],

                  // Future action buttons placeholder
                  // TODO: Add "View on Liquid Galaxy", "Export KML", "Add to Tour"
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                ),
              ),
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
