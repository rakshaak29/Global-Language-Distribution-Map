import 'package:global_language_distribution_map/data/models/language.dart';
import 'package:xml/xml.dart';

/// Represents a single spatial bin/cell for linguistic diversity.
class HeatmapCell {
  final double minLat;
  final double maxLat;
  final double minLng;
  final double maxLng;
  final int count;

  const HeatmapCell({
    required this.minLat,
    required this.maxLat,
    required this.minLng,
    required this.maxLng,
    required this.count,
  });

  double get centerLat => (minLat + maxLat) / 2;
  double get centerLng => (minLng + maxLng) / 2;
}

/// Service for calculating linguistic density and generating heatmap KML overlays.
class HeatmapService {
  HeatmapService._();

  /// Calculates language density using spatial binning on a grid of [gridSize] degrees.
  static List<HeatmapCell> calculateDensity(List<Language> languages, {double gridSize = 5.0}) {
    final bins = <String, List<Language>>{};

    for (final lang in languages) {
      if (!lang.hasCoordinates) continue;

      // Spatial bin keys
      final latBin = (lang.latitude / gridSize).floor();
      final lngBin = (lang.longitude / gridSize).floor();
      final key = '$latBin,$lngBin';

      bins.putIfAbsent(key, () => []).add(lang);
    }

    final cells = <HeatmapCell>[];
    for (final entry in bins.entries) {
      final parts = entry.key.split(',');
      final latBin = int.parse(parts[0]);
      final lngBin = int.parse(parts[1]);

      final minLat = latBin * gridSize;
      final maxLat = minLat + gridSize;
      final minLng = lngBin * gridSize;
      final maxLng = minLng + gridSize;

      cells.add(
        HeatmapCell(
          minLat: minLat,
          maxLat: maxLat,
          minLng: minLng,
          maxLng: maxLng,
          count: entry.value.length,
        ),
      );
    }

    // Sort cells by language density descending
    cells.sort((a, b) => b.count.compareTo(a.count));
    return cells;
  }

  /// Generates a KML document containing semi-transparent colored polygons representing diversity density.
  static String generateHeatmapKml(List<HeatmapCell> cells) {
    final builder = XmlBuilder();
    builder.processing('xml', 'version="1.0" encoding="UTF-8"');
    builder.element('kml',
        namespaces: {'http://www.opengis.net/kml/2.2': ''},
        namespace: 'http://www.opengis.net/kml/2.2', nest: () {
      builder.element('Document', nest: () {
        builder.element('name', nest: 'Linguistic Diversity Heatmap');
        builder.element('open', nest: '1');

        // Style definitions
        _buildStyle(builder, 'low-density', '502e7d32'); // Green with ~30% alpha
        _buildStyle(builder, 'mid-density', '50ffc107'); // Yellow with ~30% alpha
        _buildStyle(builder, 'high-density', '50ff5722'); // Orange/Red with ~30% alpha

        // Draw cells as colored polygons
        for (final cell in cells) {
          String styleId = 'low-density';
          if (cell.count >= 20) {
            styleId = 'high-density';
          } else if (cell.count >= 5) {
            styleId = 'mid-density';
          }

          builder.element('Placemark', nest: () {
            builder.element('name', nest: '${cell.count} languages');
            builder.element('description', nest: () {
              builder.text('Spatial bin coordinates:\n'
                  'Latitude: ${cell.minLat.toStringAsFixed(1)}° to ${cell.maxLat.toStringAsFixed(1)}°\n'
                  'Longitude: ${cell.minLng.toStringAsFixed(1)}° to ${cell.maxLng.toStringAsFixed(1)}°\n'
                  'Total languages: ${cell.count}');
            });
            builder.element('styleUrl', nest: '#$styleId');

            // Draw square/rectangle polygon
            builder.element('Polygon', nest: () {
              builder.element('outerBoundaryIs', nest: () {
                builder.element('LinearRing', nest: () {
                  builder.element('coordinates', nest: () {
                    builder.text('${cell.minLng},${cell.minLat},0\n'
                        '${cell.maxLng},${cell.minLat},0\n'
                        '${cell.maxLng},${cell.maxLat},0\n'
                        '${cell.minLng},${cell.maxLat},0\n'
                        '${cell.minLng},${cell.minLat},0');
                  });
                });
              });
            });
          });
        }
      });
    });

    return builder.buildDocument().toXmlString(pretty: true, indent: '  ');
  }

  static void _buildStyle(XmlBuilder builder, String id, String colorHex) {
    builder.element('Style', attributes: {'id': id}, nest: () {
      builder.element('LineStyle', nest: () {
        builder.element('color', nest: colorHex.replaceAll(RegExp(r'^..'), '99')); // Slightly higher opacity border
        builder.element('width', nest: '1.5');
      });
      builder.element('PolyStyle', nest: () {
        builder.element('color', nest: colorHex);
        builder.element('fill', nest: '1');
        builder.element('outline', nest: '1');
      });
    });
  }
}
