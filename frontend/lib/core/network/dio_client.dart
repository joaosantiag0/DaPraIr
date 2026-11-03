import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'auth_interceptor.dart';

class DioClient {
  late final Dio dio;

  static String get defaultBaseUrl {
    if (kIsWeb) return 'http://localhost:3333';
    try {
      if (Platform.isAndroid) {
        return 'http://10.0.2.2:3333';
      }
    } catch (_) {}
    return 'http://localhost:3333';
  }

  DioClient({String? baseUrl}) {
    final effectiveBaseUrl = baseUrl ?? defaultBaseUrl;

    dio = Dio(
      BaseOptions(
        baseUrl: effectiveBaseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.addAll([
      AuthInterceptor(),
      LogInterceptor(
        request: false,
        requestHeader: false,
        responseHeader: false,
        responseBody: false,
        error: true,
      ),
    ]);
  }
}
