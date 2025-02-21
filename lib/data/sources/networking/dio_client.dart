import 'package:dio/dio.dart';
import 'package:fin_app/data/sources/networking/interceptors/log_interceptor.dart';

class DioClient {
  DioClient({required String baseUrl}) {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        headers: {'accept': 'application/json', 'content-type': 'application/json'},
        validateStatus: (status) => status != null && status >= 200 && status < 300,
      ),
    );
    // Add background transformer for isolates support
    _dio.transformer = BackgroundTransformer();

    // Add interceptors
    _dio.interceptors.add(LoggingInterceptor());
  }

  late final Dio _dio;

  Future<T?> get<T>(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
  }) async {
    final response = await _dio.get<T>(
      endpoint,
      queryParameters: queryParameters,
    );
    return response.data;
  }

  Future<T?> post<T>() {
    throw UnimplementedError();
  }

  Future<T?> put<T>() {
    throw UnimplementedError();
  }

  Future<T?> delete<T>() {
    throw UnimplementedError();
  }
}
