import 'package:dio/dio.dart';
import '../core/logger.dart';

class WeatherService {
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5';
  static const String _apiKey =
      'YOUR_OPENWEATHER_API_KEY'; // Add your API key here

  late final Dio _dio;

  WeatherService() {
    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(milliseconds: 5000),
      receiveTimeout: const Duration(milliseconds: 5000),
      headers: {
        'Content-Type': 'application/json',
      },
    ));
  }

  /// Get current weather for a location
  Future<WeatherData> getCurrentWeather(String location) async {
    try {
      final response = await _dio.get(
        '/weather',
        queryParameters: {
          'q': location,
          'appid': _apiKey,
          'units': 'metric', // Use Celsius
        },
      );

      AppLogger.info('✅ Current weather fetched for $location');
      return WeatherData.fromJson(response.data as Map<String, dynamic>);
    } catch (e, st) {
      AppLogger.error('❌ Failed to fetch current weather for $location', e, st);
      rethrow;
    }
  }

  /// Get weather forecast for a location (5 days, 3-hour intervals)
  Future<ForecastData> getForecast(String location) async {
    try {
      final response = await _dio.get(
        '/forecast',
        queryParameters: {
          'q': location,
          'appid': _apiKey,
          'units': 'metric',
        },
      );

      AppLogger.info('✅ Forecast fetched for $location');
      return ForecastData.fromJson(response.data as Map<String, dynamic>);
    } catch (e, st) {
      AppLogger.error('❌ Failed to fetch forecast for $location', e, st);
      rethrow;
    }
  }

  /// Get current weather by coordinates
  Future<WeatherData> getWeatherByCoordinates(double lat, double lon) async {
    try {
      final response = await _dio.get(
        '/weather',
        queryParameters: {
          'lat': lat,
          'lon': lon,
          'appid': _apiKey,
          'units': 'metric',
        },
      );

      AppLogger.info('✅ Current weather fetched for coordinates: $lat, $lon');
      return WeatherData.fromJson(response.data as Map<String, dynamic>);
    } catch (e, st) {
      AppLogger.error('❌ Failed to fetch weather by coordinates', e, st);
      rethrow;
    }
  }
}

class WeatherData {
  final String location;
  final double temperature;
  final double feelsLike;
  final double tempMin;
  final double tempMax;
  final int humidity;
  final int pressure;
  final double windSpeed;
  final String description;
  final String main;
  final int rainProbability;
  final int cloudiness;
  final DateTime dateTime;

  WeatherData({
    required this.location,
    required this.temperature,
    required this.feelsLike,
    required this.tempMin,
    required this.tempMax,
    required this.humidity,
    required this.pressure,
    required this.windSpeed,
    required this.description,
    required this.main,
    required this.rainProbability,
    required this.cloudiness,
    required this.dateTime,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    final main = json['main'] as Map<String, dynamic>? ?? {};
    final weather =
        (json['weather'] as List?)?.first as Map<String, dynamic>? ?? {};
    final wind = json['wind'] as Map<String, dynamic>? ?? {};
    final clouds = json['clouds'] as Map<String, dynamic>? ?? {};

    return WeatherData(
      location: json['name'] ?? 'Unknown',
      temperature: (main['temp'] as num?)?.toDouble() ?? 0.0,
      feelsLike: (main['feels_like'] as num?)?.toDouble() ?? 0.0,
      tempMin: (main['temp_min'] as num?)?.toDouble() ?? 0.0,
      tempMax: (main['temp_max'] as num?)?.toDouble() ?? 0.0,
      humidity: (main['humidity'] as num?)?.toInt() ?? 0,
      pressure: (main['pressure'] as num?)?.toInt() ?? 0,
      windSpeed: (wind['speed'] as num?)?.toDouble() ?? 0.0,
      description: weather['description'] ?? 'Unknown',
      main: weather['main'] ?? 'Unknown',
      rainProbability: (json['pop'] as num?)?.toInt() ?? 0,
      cloudiness: (clouds['all'] as num?)?.toInt() ?? 0,
      dateTime: DateTime.fromMillisecondsSinceEpoch(
        ((json['dt'] as num?) ?? 0).toInt() * 1000,
      ),
    );
  }
}

class ForecastData {
  final List<ForecastItem> forecasts;

  ForecastData({required this.forecasts});

  factory ForecastData.fromJson(Map<String, dynamic> json) {
    final list = (json['list'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    return ForecastData(
      forecasts: list.map((item) => ForecastItem.fromJson(item)).toList(),
    );
  }
}

class ForecastItem {
  final double temperature;
  final String description;
  final String main;
  final int humidity;
  final double windSpeed;
  final int rainProbability;
  final DateTime dateTime;

  ForecastItem({
    required this.temperature,
    required this.description,
    required this.main,
    required this.humidity,
    required this.windSpeed,
    required this.rainProbability,
    required this.dateTime,
  });

  factory ForecastItem.fromJson(Map<String, dynamic> json) {
    final main = json['main'] as Map<String, dynamic>? ?? {};
    final weather =
        (json['weather'] as List?)?.first as Map<String, dynamic>? ?? {};
    final wind = json['wind'] as Map<String, dynamic>? ?? {};

    return ForecastItem(
      temperature: (main['temp'] as num?)?.toDouble() ?? 0.0,
      description: weather['description'] ?? 'Unknown',
      main: weather['main'] ?? 'Unknown',
      humidity: (main['humidity'] as num?)?.toInt() ?? 0,
      windSpeed: (wind['speed'] as num?)?.toDouble() ?? 0.0,
      rainProbability: (json['pop'] as num?)?.toInt() ?? 0,
      dateTime: DateTime.fromMillisecondsSinceEpoch(
        ((json['dt'] as num?) ?? 0).toInt() * 1000,
      ),
    );
  }
}
