import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_interceptor.dart';

typedef SessionRevokedCallback = void Function(String message);

class AdminApiClient {
  final Dio _dio;
  static SessionRevokedCallback? onSessionRevoked;

  AdminApiClient({Dio? dio, String baseUrl = 'http://localhost:3000/api/v1'})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: baseUrl,
                connectTimeout: const Duration(seconds: 10),
                receiveTimeout: const Duration(seconds: 10),
                headers: {
                  'Content-Type': 'application/json',
                  'Accept': 'application/json',
                },
              ),
            ) {
    _dio.interceptors.add(AuthInterceptor());
    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (DioException err, ErrorInterceptorHandler handler) async {
          if (err.response?.statusCode == 401) {
            final data = err.response?.data;
            final isRevoked = data is Map && data['code'] == 'SESSION_REVOKED';
            final message = isRevoked
                ? (data['message'] as String? ?? 'Sessão revogada por moderação.')
                : 'Sessão expirada.';

            // Remove stored token
            final prefs = await SharedPreferences.getInstance();
            await prefs.remove(AuthInterceptor.tokenKey);

            if (isRevoked) {
              onSessionRevoked?.call(message);
            }
          }
          return handler.next(err);
        },
      ),
    );
  }

  Dio get dio => _dio;

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.get<T>(path, queryParameters: queryParameters, options: options);
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.post<T>(path, data: data, queryParameters: queryParameters, options: options);
  }

  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.patch<T>(path, data: data, queryParameters: queryParameters, options: options);
  }

  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.delete<T>(path, data: data, queryParameters: queryParameters, options: options);
  }
}
