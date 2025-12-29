import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiClient {
  final Dio _dio;
  final FlutterSecureStorage _storage;
  // Production Server IP
  static String _baseUrl = 'http://46.202.170.231:3002/api';

  ApiClient({Dio? dio, FlutterSecureStorage? storage})
      : _dio = dio ?? Dio(),
        _storage = storage ?? const FlutterSecureStorage() {
    _dio.options.baseUrl = _baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);
    _dio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.read(key: 'auth_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          print('🌐 Request: [${options.method}] ${options.uri}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          print('✅ Response: [${response.statusCode}] ${response.requestOptions.uri}');
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          print('❌ Error: [${e.response?.statusCode}] ${e.requestOptions.uri} : ${e.message}');
           // Handle specific errors like 401 Unauthorized if needed
          return handler.next(e);
        },
      ),
    );
  }

  Dio get client => _dio;

  // Helper methods for common operations
  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) {
    return _dio.get(path, queryParameters: queryParameters);
  }

  Future<Response> post(String path, {dynamic data, Map<String, dynamic>? queryParameters}) {
    return _dio.post(path, data: data, queryParameters: queryParameters);
  }

  Future<Response> put(String path, {dynamic data, Map<String, dynamic>? queryParameters}) {
    return _dio.put(path, data: data, queryParameters: queryParameters);
  }

  Future<Response> delete(String path, {dynamic data, Map<String, dynamic>? queryParameters}) {
    return _dio.delete(path, data: data, queryParameters: queryParameters);
  }

  void updateBaseUrl(String url) {
    if (!url.endsWith('/api')) {
      if (url.endsWith('/')) {
        url = '${url}api';
      } else {
        url = '$url/api';
      }
    }
    _baseUrl = url;
    _dio.options.baseUrl = _baseUrl;
    print('✅ Base URL updated to: $_baseUrl');
  }
}
