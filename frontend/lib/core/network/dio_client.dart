import 'package:dio/dio.dart';
import 'auth_interceptor.dart';

class DioClient {
  late final Dio dio;

  DioClient({String baseUrl = 'http://localhost:3000'}) {
    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
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
