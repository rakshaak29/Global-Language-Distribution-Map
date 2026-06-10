import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:global_language_distribution_map/data/models/language.dart';
import 'package:global_language_distribution_map/features/map/presentation/utils/map_tile_config.dart';
import 'package:global_language_distribution_map/features/map/presentation/utils/marker_builder.dart';
import 'package:global_language_distribution_map/features/map/presentation/view_models/map_view_model.dart';
import 'package:global_language_distribution_map/features/map/presentation/widgets/language_detail_sheet.dart';
import 'package:global_language_distribution_map/features/map/presentation/widgets/map_search_bar.dart';
import 'package:global_language_distribution_map/app/theme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

/// The Language Map Screen.
///
/// Displays all languages with valid coordinates on an interactive map
/// using flutter_map (OpenStreetMap). Architecture is KML-first —
/// the map is just a visualization layer over coordinate data that
/// can also be exported to KML for Liquid Galaxy.
///
/// Features:
/// - Clustered markers with endangerment-based colors
/// - Tap marker → detail bottom sheet
/// - Search → animate camera to language
/// - Dark/light map tiles matching app theme
/// - Viewport stats overlay
class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with TickerProviderStateMixin {
  final MapController _mapController = MapController();

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  /// Animate the map camera to a specific position.
  void _animatedMove(LatLng target, double zoom) {
    final camera = _mapController.camera;
    final latTween =
        Tween<double>(begin: camera.center.latitude, end: target.latitude);
    final lngTween =
        Tween<double>(begin: camera.center.longitude, end: target.longitude);
    final zoomTween = Tween<double>(begin: camera.zoom, end: zoom);

    final controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    final animation = CurvedAnimation(
      parent: controller,
      curve: Curves.easeInOutCubic,
    );

    controller.addListener(() {
      _mapController.move(
        LatLng(latTween.evaluate(animation), lngTween.evaluate(animation)),
        zoomTween.evaluate(animation),
      );
    });

    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.dispose();
      }
    });

    controller.forward();
  }

  void _onMarkerTapped(Language language) {
    final viewModel = context.read<MapViewModel>();
    final position = viewModel.selectLanguage(language);
    if (position != null) {
      _animatedMove(position, _mapController.camera.zoom.clamp(6, 12));
    }
  }

  void _onSearchLanguageSelected(Language language) {
    final viewModel = context.read<MapViewModel>();
    viewModel.selectLanguage(language);
    viewModel.closeSearch();
    _animatedMove(LatLng(language.latitude, language.longitude), 8);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final viewModel = context.watch<MapViewModel>();

    if (viewModel.isLoading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: colorScheme.primary),
              const SizedBox(height: 16),
              Text(
                'Loading language data...',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (viewModel.errorMessage != null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline_rounded,
                    size: 48, color: colorScheme.error),
                const SizedBox(height: 16),
                Text(
                  viewModel.errorMessage!,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    final languages = viewModel.filteredLanguages;

    return Scaffold(
      body: Stack(
        children: [
          // ─── Map ───────────────────────────────────────────────
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: viewModel.cameraCenter,
              initialZoom: viewModel.zoomLevel,
              minZoom: 2,
              maxZoom: 18,
              onPositionChanged: (position, hasGesture) {
                viewModel.updateCameraPosition(
                  position.center,
                  position.zoom,
                );
              },
              onTap: (tapPosition, point) {
                // Dismiss selection and search on map tap
                viewModel.clearSelection();
                if (viewModel.isSearchVisible) {
                  viewModel.closeSearch();
                }
              },
            ),
            children: [
              // Tile layer
              TileLayer(
                urlTemplate: MapTileConfig.getTileUrl(isDark),
                userAgentPackageName:
                    'com.example.global_language_distribution_map',
                maxZoom: 19,
                retinaMode: true,
              ),

              // Clustered markers
              MarkerClusterLayerWidget(
                options: MarkerClusterLayerOptions(
                  maxClusterRadius: 80,
                  disableClusteringAtZoom: 12,
                  size: const Size(40, 40),
                  padding: const EdgeInsets.all(50),
                  markers: _buildMarkers(languages, viewModel.selectedLanguage),
                  builder: (context, markers) {
                    return MarkerBuilder.buildClusterMarker(
                      count: markers.length,
                      color: MarkerBuilder.getClusterColor(markers.length),
                    );
                  },
                ),
              ),

              // Attribution
              RichAttributionWidget(
                alignment: AttributionAlignment.bottomLeft,
                attributions: [
                  TextSourceAttribution(
                    'OpenStreetMap contributors',
                    onTap: () {},
                  ),
                  TextSourceAttribution(
                    'CARTO',
                    onTap: () {},
                  ),
                ],
              ),
            ],
          ),

          // ─── Top Controls ──────────────────────────────────────
          SafeArea(
            child: Column(
              children: [
                // App bar area
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                  child: Row(
                    children: [
                      // Title chip
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainer
                              .withValues(alpha: 0.92),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: colorScheme.outlineVariant
                                  .withValues(alpha: 0.5)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.map_rounded,
                              size: 18,
                              color: colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${_formatCount(viewModel.visibleCount)} languages',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Spacer(),

                      // Filter button
                      _buildControlButton(
                        context,
                        icon: viewModel.endangermentFilter != 'all'
                            ? Icons.filter_alt_rounded
                            : Icons.filter_alt_outlined,
                        isActive: viewModel.endangermentFilter != 'all',
                        onPressed: () => _showFilterSheet(context, viewModel),
                      ),

                      const SizedBox(width: 8),

                      // Search button
                      _buildControlButton(
                        context,
                        icon: viewModel.isSearchVisible
                            ? Icons.search_off_rounded
                            : Icons.search_rounded,
                        isActive: viewModel.isSearchVisible,
                        onPressed: () => viewModel.toggleSearch(),
                      ),
                    ],
                  ),
                ),

                // Search overlay
                if (viewModel.isSearchVisible)
                  MapSearchBar(
                    searchResults: viewModel.searchResults,
                    onSearchChanged: viewModel.updateSearchQuery,
                    onLanguageSelected: _onSearchLanguageSelected,
                    onClose: viewModel.closeSearch,
                  ),
              ],
            ),
          ),

          // ─── Selected Language Detail Sheet ─────────────────────
          if (viewModel.selectedLanguage != null)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: LanguageDetailSheet(
                language: viewModel.selectedLanguage!,
                onClose: viewModel.clearSelection,
              ),
            ),
        ],
      ),
    );
  }

  /// Build map markers from filtered languages.
  List<Marker> _buildMarkers(
      List<Language> languages, Language? selectedLanguage) {
    return languages.map((language) {
      final isSelected = selectedLanguage?.id == language.id;
      return Marker(
        point: LatLng(language.latitude, language.longitude),
        width: MarkerBuilder.markerWidth,
        height: MarkerBuilder.markerHeight,
        child: GestureDetector(
          onTap: () => _onMarkerTapped(language),
          child: MarkerBuilder.buildLanguageMarker(
            name: language.name,
            endangeredStatus: language.endangeredStatus,
            isSelected: isSelected,
          ),
        ),
      );
    }).toList();
  }

  Widget _buildControlButton(
    BuildContext context, {
    required IconData icon,
    required bool isActive,
    required VoidCallback onPressed,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: isActive
          ? colorScheme.primary.withValues(alpha: 0.15)
          : colorScheme.surfaceContainer.withValues(alpha: 0.92),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isActive
                  ? colorScheme.primary.withValues(alpha: 0.3)
                  : colorScheme.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
          child: Icon(
            icon,
            size: 20,
            color:
                isActive ? colorScheme.primary : colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  void _showFilterSheet(BuildContext context, MapViewModel viewModel) {
    final colorScheme = Theme.of(context).colorScheme;
    final statuses = ['all', ...viewModel.endangermentStatuses];

    showModalBottomSheet(
      context: context,
      backgroundColor: colorScheme.surfaceContainer,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color:
                        colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Text(
                'Filter by Endangerment',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: statuses.map((status) {
                  final isSelected = viewModel.endangermentFilter == status;
                  final color = status == 'all'
                      ? colorScheme.primary
                      : AppTheme.getEndangermentColor(status);

                  return FilterChip(
                    label: Text(
                      status == 'all' ? 'All Languages' : status,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: isSelected ? color : colorScheme.onSurfaceVariant,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (_) {
                      viewModel.setEndangermentFilter(status);
                      Navigator.pop(context);
                    },
                    selectedColor: color.withValues(alpha: 0.15),
                    checkmarkColor: color,
                    side: BorderSide(
                      color: isSelected
                          ? color.withValues(alpha: 0.4)
                          : colorScheme.outlineVariant,
                    ),
                  );
                }).toList(),
              ),

              if (viewModel.endangermentFilter != 'all') ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () {
                      viewModel.clearFilters();
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Clear Filters',
                      style: GoogleFonts.inter(
                        color: colorScheme.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  String _formatCount(int count) {
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }
}
