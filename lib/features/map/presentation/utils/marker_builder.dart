import 'package:flutter/material.dart';
import 'package:global_language_distribution_map/app/theme.dart';
import 'package:google_fonts/google_fonts.dart';

/// Utility to build language name label markers and cluster markers.
///
/// Instead of colored dots, each marker displays the language name
/// as a compact text label with an endangerment-colored accent.
class MarkerBuilder {
  MarkerBuilder._();

  /// Height of individual language markers.
  static const double markerHeight = 28.0;

  /// Width of individual language markers.
  static const double markerWidth = 120.0;

  /// Size of cluster markers (base — scales with count).
  static const double clusterBaseSize = 44.0;

  /// Builds a label marker widget showing the language name.
  ///
  /// Displays the name with a small colored dot indicator for
  /// the endangerment status.
  static Widget buildLanguageMarker({
    required String name,
    required String endangeredStatus,
    bool isSelected = false,
  }) {
    final color = AppTheme.getEndangermentColor(endangeredStatus);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: isSelected
            ? color.withValues(alpha: 0.9)
            : Colors.black.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isSelected
              ? Colors.white
              : color.withValues(alpha: 0.8),
          width: isSelected ? 1.5 : 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isSelected ? 0.5 : 0.3),
            blurRadius: isSelected ? 6 : 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Endangerment color dot
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: isSelected ? Colors.white : color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          // Language name
          Flexible(
            child: Text(
              name,
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: Colors.white,
                height: 1.2,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a cluster marker widget showing the count of grouped languages.
  ///
  /// Size scales logarithmically with count to avoid oversized clusters.
  static Widget buildClusterMarker({
    required int count,
    required Color color,
  }) {
    // Scale cluster size: base 44px + log-scale growth
    final size = clusterBaseSize + (count.clamp(1, 10000) / 100).clamp(0, 20);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.85),
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.9),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.4),
            blurRadius: 6,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Center(
        child: Text(
          _formatCount(count),
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            height: 1,
          ),
        ),
      ),
    );
  }

  /// Format large numbers for compact display: 1,234 → "1.2K"
  static String _formatCount(int count) {
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }

  /// Returns a color for a cluster based on density.
  static Color getClusterColor(int count) {
    if (count > 500) return const Color(0xFFFF5722); // Deep orange
    if (count > 100) return const Color(0xFFFF9800); // Orange
    if (count > 50) return const Color(0xFFFFC107);  // Amber
    if (count > 10) return const Color(0xFF6C63FF);  // Primary
    return const Color(0xFF03DAC6); // Secondary/teal
  }
}
