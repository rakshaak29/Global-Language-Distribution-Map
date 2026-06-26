import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:global_language_distribution_map/app/theme.dart';
import 'package:global_language_distribution_map/core/constants/app_constants.dart';

/// Diversity Heatmap Screen.
///
/// Shows linguistic diversity hotspot regions with a map preview
/// and a ranked list of top language density zones.
class HeatmapScreen extends StatefulWidget {
  const HeatmapScreen({super.key});

  @override
  State<HeatmapScreen> createState() => _HeatmapScreenState();
}

class _HeatmapScreenState extends State<HeatmapScreen> {
  bool _showHeatmap = true;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final hotspots = AppConstants.diversityHotspots;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Diversity Heatmap'),
        backgroundColor: AppTheme.primaryGreenDark,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Toggle ──────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  Text(
                    'Show Heatmap',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const Spacer(),
                  Switch.adaptive(
                    value: _showHeatmap,
                    onChanged: (v) => setState(() => _showHeatmap = v),
                    activeColor: AppTheme.primaryGreen,
                  ),
                ],
              ),
            ),

            // ─── Map Preview ──────────────────────────────────────
            if (_showHeatmap) ...[
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                height: 450,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: colorScheme.outlineVariant),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    children: [
                      FlutterMap(
                        options: MapOptions(
                          initialCenter: const LatLng(10, 10),
                          initialZoom: 1.6,
                          minZoom: 1.3,
                          maxZoom: 8,
                          cameraConstraint: CameraConstraint.containCenter(
                            bounds: LatLngBounds(
                              const LatLng(-85, -180),
                              const LatLng(85, 180),
                            ),
                          ),
                          interactionOptions: const InteractionOptions(
                            flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                          ),
                        ),
                        children: [
                          TileLayer(
                            urlTemplate: 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
                            subdomains: const ['a', 'b', 'c', 'd'],
                          ),
                          MarkerLayer(
                            markers: hotspots.map((spot) {
                              final lat = spot['lat'] as double;
                              final lng = spot['lng'] as double;
                              final count = spot['count'] as int;
                              
                              Color color = const Color(0xFFFF5722);
                              if (count < 300) color = const Color(0xFF2E7D32);
                              else if (count < 500) color = const Color(0xFFFFC107);
                              
                              double size = 40.0 + (count / 20.0);
                              if (size > 100) size = 100;
                              
                              return Marker(
                                point: LatLng(lat, lng),
                                width: size,
                                height: size,
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: RadialGradient(
                                      colors: [
                                        color.withValues(alpha: 0.8),
                                        color.withValues(alpha: 0.3),
                                        Colors.transparent,
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                      // Legend
                      Positioned(
                        bottom: 12,
                        left: 12,
                        child: _HeatmapLegend(),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],

            // ─── Top Hotspots ─────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text(
                'TOP HOTSPOTS',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurfaceVariant,
                  letterSpacing: 1.2,
                ),
              ),
            ),

            ...List.generate(hotspots.length, (index) {
              final spot = hotspots[index];
              return Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: _HotspotTile(
                  rank: index + 1,
                  name: spot['name'] as String,
                  description: spot['description'] as String,
                  count: spot['count'] as int,
                ),
              );
            }),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

}

class _HeatmapLegend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _legendItem(const Color(0xFF2E7D32), 'Low'),
          const SizedBox(width: 8),
          _legendItem(const Color(0xFFFFC107), 'Medium'),
          const SizedBox(width: 8),
          _legendItem(const Color(0xFFFF5722), 'High'),
        ],
      ),
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _HotspotTile extends StatelessWidget {
  final int rank;
  final String name;
  final String description;
  final int count;

  const _HotspotTile({
    required this.rank,
    required this.name,
    required this.description,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final rankColor = rank <= 3
        ? [
            const Color(0xFFFF5722),
            const Color(0xFFFF9800),
            const Color(0xFFFFC107),
          ][rank - 1]
        : AppTheme.primaryGreen;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          // Rank badge
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: rankColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                '#$rank',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: rankColor,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Name + description
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          // Count
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: rankColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$count langs',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: rankColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

