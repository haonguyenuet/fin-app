abstract class HttpService {
  Map<String, String> get headers;

  Future<T?> get<T>(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    String? customBaseUrl,
  });

  Future<T?> post<T>();
  Future<T?> put<T>();
  Future<T?> delete<T>();
}
