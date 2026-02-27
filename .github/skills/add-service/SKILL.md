---
name: add-service
description: Guides creation of a new service class with HTTP client injection, custom exceptions, and tests. Use when the user wants to add a new API client, external integration, or reusable business logic service.
argument-hint: "[service name]"
---

# Adding a New Service

Use this when making API calls, integrating external services, implementing business logic that doesn't belong in BLoCs, or creating reusable operations.

## Steps

1. **Create service file** (`lib/services/service_name.dart`):

   ```dart
   import 'dart:convert';
   import 'package:http/http.dart' as http;
   import '../models/result_model.dart';
   import '../utils/constants.dart';

   class ServiceName {
     final http.Client _client;

     ServiceName({http.Client? client}) : _client = client ?? http.Client();

     Future<ResultModel> fetchData({required String parameter}) async {
       final uri = Uri.parse(
         '${ApiConstants.someApiUrl}?param=$parameter',
       );

       final response = await _client.get(uri);

       if (response.statusCode != 200) {
         throw ServiceNameException('API returned status ${response.statusCode}');
       }

       final data = json.decode(response.body) as Map<String, dynamic>;
       return ResultModel.fromJson(data);
     }
   }

   class ServiceNameException implements Exception {
     final String message;
     ServiceNameException(this.message);

     @override
     String toString() => 'ServiceNameException: $message';
   }
   ```

2. **Register in app.dart:**

   ```dart
   RepositoryProvider(create: (_) => ServiceName()),
   ```

3. **Add tests** (`test/services/service_name_test.dart`):

   ```dart
   import 'package:flutter_test/flutter_test.dart';
   import 'package:mocktail/mocktail.dart';
   import 'package:http/http.dart' as http;
   import 'package:flutter_weather_channel/services/service_name.dart';

   class MockClient extends Mock implements http.Client {}

   void main() {
     group('ServiceName', () {
       late ServiceName service;
       late MockClient mockClient;

       setUp(() {
         mockClient = MockClient();
         service = ServiceName(client: mockClient);
       });

       test('fetchData returns result on success', () async {
         when(() => mockClient.get(any())).thenAnswer(
           (_) async => http.Response('{"field": "value"}', 200),
         );

         final result = await service.fetchData(parameter: 'test');
         expect(result, isA<ResultModel>());
       });

       test('fetchData throws on error', () {
         when(() => mockClient.get(any())).thenAnswer(
           (_) async => http.Response('Error', 500),
         );

         expect(
           () => service.fetchData(parameter: 'test'),
           throwsA(isA<ServiceNameException>()),
         );
       });
     });
   }
   ```

## Conventions

- All services accept an optional `http.Client` for testing
- Services throw custom exceptions (e.g., `WeatherException`, `GeocodingException`)
- Use descriptive method names (`fetchWeather`, `search`)
- Use named parameters for clarity
- Keep services stateless; store no data between calls
- Use records for multiple return values: `({Weather weather, Forecast forecast})`
- All API URLs stored in `ApiConstants` class

## Testing tips

- Mock HTTP client using `mocktail`
- Test both success and error cases
- Verify proper exception throwing
- Test edge cases (null values, empty responses)
- Register any objects used in `when()` with `registerFallbackValue()`
- Use `thenAnswer()` for async methods, `thenReturn()` for sync
