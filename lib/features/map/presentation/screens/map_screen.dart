import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:global_language_distribution_map/app/router.dart';
import 'package:global_language_distribution_map/data/models/language.dart';
import 'package:global_language_distribution_map/features/map/presentation/utils/map_tile_config.dart';
import 'package:global_language_distribution_map/features/map/presentation/utils/marker_builder.dart';
import 'package:global_language_distribution_map/features/map/presentation/view_models/map_view_model.dart';
import 'package:global_language_distribution_map/features/map/presentation/widgets/language_detail_sheet.dart';
import 'package:global_language_distribution_map/app/theme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
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
  int? _lastSelectionEventId;
  String _currentTileUrl = MapTileConfig.voyagerTileUrl;

  Color _stringToFlutterColor(String str) {
    int hash = 0;
    for (int i = 0; i < str.length; i++) {
      hash = str.codeUnitAt(i) + ((hash << 5) - hash);
    }
    final r = (hash & 0xFF0000) >> 16;
    final g = (hash & 0x00FF00) >> 8;
    final b = (hash & 0x0000FF);
    return Color.fromARGB(76, r, g, b); // ~30% opacity, matching KML
  }

  Color _stringToFlutterBorderColor(String str) {
    int hash = 0;
    for (int i = 0; i < str.length; i++) {
      hash = str.codeUnitAt(i) + ((hash << 5) - hash);
    }
    final r = (hash & 0xFF0000) >> 16;
    final g = (hash & 0x00FF00) >> 8;
    final b = (hash & 0x0000FF);
    return Color.fromARGB(255, r, g, b); // Solid border
  }

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
    viewModel.selectLanguage(language);
  }

  void _onSearchLanguageSelected(Language language) {
    final viewModel = context.read<MapViewModel>();
    viewModel.selectLanguage(language);
    viewModel.closeSearch();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final viewModel = context.watch<MapViewModel>();

    final selected = viewModel.selectedLanguage;
    if (selected != null && viewModel.selectionEventId != _lastSelectionEventId) {
      _lastSelectionEventId = viewModel.selectionEventId;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _animatedMove(LatLng(selected.latitude, selected.longitude), 12);
      });
    } else if (selected == null) {
      _lastSelectionEventId = null;
    }

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
              minZoom: 1.3,
              maxZoom: 18,
              // Constrain camera center to single world view — allows zooming out to see the whole world without cutting off languages at the edge
              cameraConstraint: CameraConstraint.containCenter(
                bounds: LatLngBounds(
                  const LatLng(-85, -180),
                  const LatLng(85, 180),
                ),
              ),
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
                urlTemplate: _currentTileUrl,
                userAgentPackageName:
                    'com.example.global_language_distribution_map',
                maxZoom: 19,
                retinaMode: true,
              ),

              // Highlight selected language region (circle)
              if (viewModel.selectedLanguage != null)
                CircleLayer(
                  circles: [
                    CircleMarker(
                      point: LatLng(
                        viewModel.selectedLanguage!.latitude,
                        viewModel.selectedLanguage!.longitude,
                      ),
                      radius: 40000.0, // 40km, matching KML
                      useRadiusInMeter: true,
                      color: _stringToFlutterColor(viewModel.selectedLanguage!.id),
                      borderColor: _stringToFlutterBorderColor(viewModel.selectedLanguage!.id),
                      borderStrokeWidth: 2,
                    ),
                  ],
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

          // ─── Search & Filter Floating Card at Top ─────────────────
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      height: 52,
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainer.withValues(alpha: 0.96),
                        borderRadius: BorderRadius.circular(26), // pill-shaped search bar
                        border: Border.all(
                          color: colorScheme.outlineVariant.withValues(alpha: 0.8),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 16),
                          Icon(
                            Icons.search_rounded,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              onChanged: (val) {
                                if (!viewModel.isSearchVisible && val.isNotEmpty) {
                                  viewModel.toggleSearch();
                                }
                                viewModel.updateSearchQuery(val);
                              },
                              onSubmitted: (val) {
                                if (viewModel.searchResults.isNotEmpty) {
                                  _onSearchLanguageSelected(viewModel.searchResults.first);
                                }
                              },
                              style: GoogleFonts.inter(
                                fontSize: 15,
                                color: colorScheme.onSurface,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Search languages, families...',
                                hintStyle: GoogleFonts.inter(
                                  color: colorScheme.onSurfaceVariant,
                                  fontSize: 14,
                                ),
                                border: InputBorder.none,
                                isDense: true,
                              ),
                            ),
                          ),
                          // KML Export Button
                          IconButton(
                            icon: const Icon(Icons.file_download_outlined),
                            color: colorScheme.onSurfaceVariant,
                            tooltip: 'Export KML',
                            onPressed: () => context.push(RoutePaths.kmlExport),
                          ),
                          // Filter toggle button
                          IconButton(
                            icon: Icon(
                              viewModel.endangermentFilter != 'all'
                                  ? Icons.filter_alt_rounded
                                  : Icons.filter_alt_outlined,
                            ),
                            color: viewModel.endangermentFilter != 'all'
                                ? colorScheme.primary
                                : colorScheme.onSurfaceVariant,
                            onPressed: () => _showFilterSheet(context, viewModel),
                          ),
                          const SizedBox(width: 8),
                        ],
                      ),
                    ),
                    
                    // Search dropdown results
                    if (viewModel.isSearchVisible && viewModel.searchQuery.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Container(
                        constraints: const BoxConstraints(maxHeight: 280),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainer.withValues(alpha: 0.98),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: colorScheme.outlineVariant),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: viewModel.searchResults.isEmpty
                              ? Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Center(
                                    child: Text(
                                      'No languages found',
                                      style: GoogleFonts.inter(
                                        fontSize: 13,
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ),
                                )
                              : ListView.builder(
                                  shrinkWrap: true,
                                  padding: const EdgeInsets.symmetric(vertical: 6),
                                  itemCount: viewModel.searchResults.length,
                                  itemBuilder: (context, index) {
                                    final language = viewModel.searchResults[index];
                                    return ListTile(
                                      leading: const Icon(Icons.location_on_rounded, color: AppTheme.primaryGreen),
                                      title: Text(
                                        language.name,
                                        style: GoogleFonts.inter(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      ),
                                      subtitle: Text(
                                        '${language.languageFamily} · ${language.countryRegion}',
                                        style: GoogleFonts.inter(fontSize: 12),
                                      ),
                                      onTap: () => _onSearchLanguageSelected(language),
                                    );
                                  },
                                ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),

          // ─── Layer Toggle FAB ─────────────────────────────────
          Positioned(
            right: 16,
            bottom: viewModel.selectedLanguage != null ? 340 : 16,
            child: FloatingActionButton(
              heroTag: 'map_layer_fab',
              backgroundColor: AppTheme.primaryGreen,
              foregroundColor: Colors.white,
              shape: const CircleBorder(),
              onPressed: () => _showLayerDialog(context),
              child: const Icon(Icons.layers_rounded),
            ),
          ),

          // ─── Selected Language Detail Sheet (full-width bottom sheet) ────
          if (viewModel.selectedLanguage != null)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: LanguageDetailSheet(
                key: ValueKey(viewModel.selectedLanguage!.id),
                language: viewModel.selectedLanguage!,
                onClose: viewModel.clearSelection,
                onFlyTo: () {
                  final lang = viewModel.selectedLanguage!;
                  _animatedMove(LatLng(lang.latitude, lang.longitude), 12);
                },
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

  void _showLayerDialog(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      backgroundColor: colorScheme.surfaceContainer,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Map Style',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.map_rounded),
                  title: const Text('Voyager (Default)'),
                  trailing: _currentTileUrl == MapTileConfig.voyagerTileUrl
                      ? Icon(Icons.check_circle_rounded, color: AppTheme.primaryGreen)
                      : null,
                  onTap: () {
                    setState(() => _currentTileUrl = MapTileConfig.voyagerTileUrl);
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.wb_sunny_rounded),
                  title: const Text('Positron (Light)'),
                  trailing: _currentTileUrl == MapTileConfig.lightTileUrl
                      ? Icon(Icons.check_circle_rounded, color: AppTheme.primaryGreen)
                      : null,
                  onTap: () {
                    setState(() => _currentTileUrl = MapTileConfig.lightTileUrl);
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.nightlight_round_rounded),
                  title: const Text('Dark Matter (Dark)'),
                  trailing: _currentTileUrl == MapTileConfig.darkTileUrl
                      ? Icon(Icons.check_circle_rounded, color: AppTheme.primaryGreen)
                      : null,
                  onTap: () {
                    setState(() => _currentTileUrl = MapTileConfig.darkTileUrl);
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.public_rounded),
                  title: const Text('OpenStreetMap'),
                  trailing: _currentTileUrl == MapTileConfig.osmTileUrl
                      ? Icon(Icons.check_circle_rounded, color: AppTheme.primaryGreen)
                      : null,
                  onTap: () {
                    setState(() => _currentTileUrl = MapTileConfig.osmTileUrl);
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

}
