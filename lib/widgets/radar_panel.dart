import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../config/theme.dart';

/// Displays a static radar image fetched from RainViewer.
class RadarPanel extends StatelessWidget {
  final String? radarUrl;
  final String locationName;

  const RadarPanel({
    super.key,
    required this.radarUrl,
    required this.locationName,
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
              const Icon(
                Icons.radar,
                color: WeatherColors.textGray,
                size: 48,
              ),
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

    return Stack(
      fit: StackFit.expand,
      children: [
        // Dark base map background
        Container(color: const Color(0xFF1A2A3A)),

        // Radar overlay
        CachedNetworkImage(
          imageUrl: radarUrl!,
          fit: BoxFit.contain,
          placeholder: (context, url) => const Center(
            child: CircularProgressIndicator(
              color: WeatherColors.borderGlow,
            ),
          ),
          errorWidget: (context, url, error) => Center(
            child: Text(
              'Failed to load radar',
              style: WeatherTextStyles.body(color: WeatherColors.textGray),
            ),
          ),
        ),

        // Center crosshair marker for location
        Center(
          child: Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: WeatherColors.textRed.withValues(alpha: 0.8),
              border: Border.all(color: WeatherColors.textWhite, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
