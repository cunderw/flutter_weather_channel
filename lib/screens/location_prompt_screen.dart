import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/location/location_bloc.dart';
import '../blocs/location/location_event.dart';
import '../blocs/location/location_state.dart';
import '../config/theme.dart';

/// Initial screen that prompts the user to enter a zip code.
class LocationPromptScreen extends StatefulWidget {
  const LocationPromptScreen({super.key});

  @override
  State<LocationPromptScreen> createState() => _LocationPromptScreenState();
}

class _LocationPromptScreenState extends State<LocationPromptScreen> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _submitZip() {
    final query = _controller.text.trim();
    if (query.isNotEmpty) {
      context.read<LocationBloc>().add(ZipCodeSubmitted(query));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: WeatherColors.backgroundGradient,
        ),
        child: SafeArea(
          child: BlocListener<LocationBloc, LocationState>(
            listener: (context, state) {
              if (state is LocationLoaded) {
                Navigator.of(
                  context,
                ).pushReplacementNamed('/tv', arguments: state.location);
              } else if (state is LocationError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: WeatherColors.textRed,
                  ),
                );
              }
            },
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Title
                    const Icon(
                      Icons.tv,
                      color: WeatherColors.textCyan,
                      size: 64,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'THE WEATHER\nCHANNEL',
                      textAlign: TextAlign.center,
                      style: WeatherTextStyles.led(
                        size: 42,
                        color: WeatherColors.textYellow,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Local Forecast',
                      style: WeatherTextStyles.body(
                        size: 18,
                        color: WeatherColors.textGray,
                      ),
                    ),
                    const SizedBox(height: 48),

                    // Zip code input
                    Text(
                      'Enter Your Zip Code',
                      style: WeatherTextStyles.body(
                        size: 16,
                        color: WeatherColors.textCyan,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: 200,
                      child: TextField(
                        controller: _controller,
                        focusNode: _focusNode,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        style: WeatherTextStyles.led(
                          size: 36,
                          color: WeatherColors.textYellow,
                        ),
                        decoration: InputDecoration(
                          hintText: '00000',
                          hintStyle: WeatherTextStyles.led(
                            size: 36,
                            color: WeatherColors.textGray.withValues(
                              alpha: 0.3,
                            ),
                          ),
                          filled: true,
                          fillColor: Colors.black26,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: WeatherColors.borderGlow,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: WeatherColors.borderGlow.withValues(
                                alpha: 0.5,
                              ),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: WeatherColors.textCyan,
                              width: 2,
                            ),
                          ),
                        ),
                        onSubmitted: (_) => _submitZip(),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Submit button
                    SizedBox(
                      width: 200,
                      child: ElevatedButton(
                        onPressed: _submitZip,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: WeatherColors.tickerBlue,
                          foregroundColor: WeatherColors.textWhite,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'GO',
                          style: WeatherTextStyles.body(
                            size: 18,
                            weight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Loading indicator
                    BlocBuilder<LocationBloc, LocationState>(
                      builder: (context, state) {
                        if (state is LocationLoading) {
                          return const Padding(
                            padding: EdgeInsets.only(top: 16),
                            child: CircularProgressIndicator(
                              color: WeatherColors.textCyan,
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
