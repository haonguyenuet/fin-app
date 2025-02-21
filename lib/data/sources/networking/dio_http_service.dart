import 'package:dio/dio.dart';
import 'package:fin_app/data/sources/networking/http_service.dart';
import 'package:fin_app/data/sources/networking/interceptors/log_interceptor.dart';

class DioHttpService implements HttpService {
  DioHttpService({required String baseUrl}) {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        headers: headers,
        validateStatus: (status) => status != null && status >= 200 && status < 300,
      ),
    );
    // Add background transformer for isolates support
    _dio.transformer = BackgroundTransformer();

    // Add interceptors
    _dio.interceptors.add(LoggingInterceptor());
  }

  late final Dio _dio;

  @override
  Map<String, String> headers = {'accept': 'application/json', 'content-type': 'application/json'};

  @override
  Future<T?> get<T>(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    String? customBaseUrl,
  }) async {
    final response = await _dio.get<T>(
      endpoint,
      queryParameters: queryParameters,
    );
    return response.data;
  }

  @override
  Future<T?> post<T>() {
    throw UnimplementedError();
  }

  @override
  Future<T?> put<T>() {
    throw UnimplementedError();
  }

  @override
  Future<T?> delete<T>() {
    throw UnimplementedError();
  }
}
