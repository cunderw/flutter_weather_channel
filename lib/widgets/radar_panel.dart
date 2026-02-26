import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../config/theme.dart';

/// Displays a static radar image overlaid on a map tile from OpenStreetMap.
class RadarPanel extends StatelessWidget {
  final String? radarUrl;
  final String locationName;
  final double latitude;
  final double longitude;

  const RadarPanel({
    super.key,
    required this.radarUrl,
    required this.locationName,
    required this.latitude,
    required this.longitude,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'REGIONAL RADAR',
            style: WeatherTextStyles.heading(
              size: 20,
              color: WeatherColors.textCyan,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            height: 2,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  WeatherColors.textCyan.withValues(alpha: 0.5),
                  WeatherColors.textCyan,
                  WeatherColors.textCyan.withValues(alpha: 0.5),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            locationName,
            style: WeatherTextStyles.body(
              size: 14,
              color: WeatherColors.textGray,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: _buildRadarImage(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRadarImage() {
    if (radarUrl == null) {
      return Container(
        color: WeatherColors.backgroundDark,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.radar, color: WeatherColors.textGray, size: 48),
              const SizedBox(height: 8),
              Text(
                'Radar unavailable',
                style: WeatherTextStyles.body(color: WeatherColors.textGray),
              ),
            ],
          ),
        ),
      );
    }

    // Compute the fractional position of the location within the tile.
    // The tile integer coords give us the top-left corner; the fractional
    // remainder tells us where inside the tile the point sits.
    const zoom = 6;
    final tileXExact = _lonToTileXDouble(longitude, zoom);
    final tileYExact = _latToTileYDouble(latitude, zoom);
    final x = tileXExact.floor();
    final y = tileYExact.floor();
    final fracX = tileXExact - x; // 0.0 = left edge, 1.0 = right edge
    final fracY = tileYExact - y; // 0.0 = top edge, 1.0 = bottom edge

    // Dark-themed base map from Stadia Maps (Alidade Smooth Dark).
    // Free for light usage, no API key needed.
    final baseMapUrl =
        'https://tiles.stadiamaps.com/tiles/alidade_smooth_dark/$zoom/$x/$y@2x.png';

    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          fit: StackFit.expand,
          children: [
            // Base map tile (dark theme with roads, borders, labels)
            CachedNetworkImage(
              imageUrl: baseMapUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) =>
                  Container(color: const Color(0xFF1A2A3A)),
              errorWidget: (context, url, error) =>
                  Container(color: const Color(0xFF1A2A3A)),
            ),

            // Radar precipitation overlay
            CachedNetworkImage(
              imageUrl: radarUrl!,
              fit: BoxFit.cover,
              placeholder: (context, url) => const SizedBox.shrink(),
              errorWidget: (context, url, error) => const SizedBox.shrink(),
            ),

            // Location marker positioned at the correct fractional offset
            Positioned(
              left: fracX * constraints.maxWidth - 6,
              top: fracY * constraints.maxHeight - 6,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: WeatherColors.textRed.withValues(alpha: 0.8),
                  border: Border.all(
                    color: WeatherColors.textWhite,
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Converts longitude to fractional tile X (OSM slippy-map convention).
  static double _lonToTileXDouble(double lon, int zoom) {
    return (lon + 180) / 360 * (1 << zoom);
  }

  /// Converts latitude to fractional tile Y (OSM slippy-map convention).
  static double _latToTileYDouble(double lat, int zoom) {
    final latRad = lat * math.pi / 180;
    return (1 - math.log(math.tan(latRad) + 1 / math.cos(latRad)) / math.pi) /
        2 *
        (1 << zoom);
  }
}
