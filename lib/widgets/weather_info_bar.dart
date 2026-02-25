import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../config/theme.dart';

/// Top info bar showing the city name, live clock, and current date.
class WeatherInfoBar extends StatefulWidget {
  final String locationName;

  const WeatherInfoBar({super.key, required this.locationName});

  @override
  State<WeatherInfoBar> createState() => _WeatherInfoBarState();
}

class _WeatherInfoBarState extends State<WeatherInfoBar> {
  late Timer _clockTimer;
  late DateTime _now;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _clockTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final timeStr = DateFormat('h:mm:ss a').format(_now);
    final dateStr = DateFormat('EEEE, MMMM d, yyyy').format(_now);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: const BoxDecoration(
        color: WeatherColors.infoBarOverlay,
        border: Border(
          bottom: BorderSide(color: WeatherColors.textYellow, width: 1),
        ),
      ),
      child: Row(
        children: [
          // Location name
          Expanded(
            child: Text(
              widget.locationName.toUpperCase(),
              style: WeatherTextStyles.heading(
                size: 18,
                color: WeatherColors.textCyan,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Date
          Text(
            dateStr,
            style: WeatherTextStyles.body(
              size: 14,
              color: WeatherColors.textGray,
            ),
          ),
          const SizedBox(width: 16),

          // Live clock
          Text(
            timeStr,
            style: WeatherTextStyles.led(
              size: 22,
              color: WeatherColors.textYellow,
            ),
          ),
        ],
      ),
    );
  }
}
