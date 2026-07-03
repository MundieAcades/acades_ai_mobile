import 'package:dio/dio.dart';
import '../core/config.dart';
import '../core/logger.dart';
import '../services/supabase_service.dart';

class ApiService {
  late final Dio _dio;

  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConfig.instance.apiBaseUrl,
      connectTimeout: Duration(milliseconds: AppConfig.instance.apiTimeoutMs),
      receiveTimeout: Duration(milliseconds: AppConfig.instance.apiTimeoutMs),
      headers: {
        'Content-Type': 'application/json',
      },
    ));

    // Add interceptors for logging and auth
    _dio.interceptors.add(LoggingInterceptor());
    _dio.interceptors.add(AuthInterceptor());
  }

  /// GET request
  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
      );
      AppLogger.info('✅ GET $path - Status: ${response.statusCode}');
      return fromJson(response.data as Map<String, dynamic>);
    } catch (e, st) {
      AppLogger.error('❌ GET $path failed', e, st);
      rethrow;
    }
  }

  /// POST request
  Future<T> post<T>(
    String path, {
    required Map<String, dynamic> data,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
      );
      AppLogger.info('✅ POST $path - Status: ${response.statusCode}');
      return fromJson(response.data as Map<String, dynamic>);
    } catch (e, st) {
      AppLogger.error('❌ POST $path failed', e, st);
      rethrow;
    }
  }

  /// PUT request
  Future<T> put<T>(
    String path, {
    required Map<String, dynamic> data,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
      );
      AppLogger.info('✅ PUT $path - Status: ${response.statusCode}');
      return fromJson(response.data as Map<String, dynamic>);
    } catch (e, st) {
      AppLogger.error('❌ PUT $path failed', e, st);
      rethrow;
    }
  }

  /// DELETE request
  Future<void> delete(String path) async {
    try {
      await _dio.delete(path);
      AppLogger.info('✅ DELETE $path');
    } catch (e, st) {
      AppLogger.error('❌ DELETE $path failed', e, st);
      rethrow;
    }
  }
}

/// Logging interceptor for API calls
class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    AppLogger.debug('→ ${options.method} ${options.path}');
    AppLogger.verbose('Headers: ${options.headers}');
    if (options.data != null) {
      AppLogger.verbose('Body: ${options.data}');
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    AppLogger.debug('← ${response.statusCode} ${response.requestOptions.path}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    AppLogger.error('✗ ${err.requestOptions.path} - ${err.message}');
    handler.next(err);
  }
}

/// Auth interceptor to add JWT token
class AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final user = SupabaseService.currentUser;
    if (user != null) {
      final token = user.userMetadata?['token'] ?? '';
      if (token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }
}
