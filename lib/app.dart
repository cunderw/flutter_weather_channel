import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'blocs/display/display_cubit.dart';
import 'blocs/location/location_bloc.dart';
import 'blocs/weather/weather_bloc.dart';
import 'config/theme.dart';
import 'models/location.dart';
import 'screens/location_prompt_screen.dart';
import 'screens/tv_weather_screen.dart';
import 'services/geocoding_service.dart';
import 'services/weather_service.dart';

class WeatherChannelApp extends StatelessWidget {
  const WeatherChannelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (_) => GeocodingService()),
        RepositoryProvider(create: (_) => WeatherService()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (ctx) =>
                LocationBloc(geocodingService: ctx.read<GeocodingService>()),
          ),
          BlocProvider(
            create: (ctx) =>
                WeatherBloc(weatherService: ctx.read<WeatherService>()),
          ),
          BlocProvider(create: (_) => DisplayCubit()),
        ],
        child: MaterialApp(
          title: 'The Weather Channel',
          debugShowCheckedModeBanner: false,
          theme: weatherTheme(),
          initialRoute: '/',
          onGenerateRoute: (settings) {
            switch (settings.name) {
              case '/':
                return MaterialPageRoute(
                  builder: (_) => const LocationPromptScreen(),
                );
              case '/tv':
                final location = settings.arguments as Location;
                return MaterialPageRoute(
                  builder: (_) => TvWeatherScreen(location: location),
                );
              default:
                return MaterialPageRoute(
                  builder: (_) => const LocationPromptScreen(),
                );
            }
          },
        ),
      ),
    );
  }
}
