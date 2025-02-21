import 'dart:developer';

import 'package:dio/dio.dart';


class LoggingInterceptor implements Interceptor {
  LoggingInterceptor();

  @override
  void onError(DioException exception, ErrorInterceptorHandler handler) {
    log('❌ ❌ ❌ Dio Exception!');
    log('❌ ❌ ❌ Url: ${exception.requestOptions.uri}');
    log('❌ ❌ ❌ ${exception.stackTrace}');
    log('❌ ❌ ❌ Response Errors: ${exception.response?.data}');
    log('-------------------------');
    return handler.next(exception);
  }

  /// Method that intercepts Dio request
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    log('➡️➡️➡️ Sending request');
    log('➡️➡️➡️ ${options.method} ${options.baseUrl}${options.path}');
    log('➡️➡️➡️ Query params: ${options.queryParameters}');
    log('-------------------------');
    return handler.next(options);
  }

  /// Method that intercepts Dio response
  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300) {
      log('⬅️ ⬅️ ⬅️ Retrieved response');
      log('⬅️ ⬅️ ⬅️ Response');
      log('<---- ${response.statusCode != 200 ? '❌ ${response.statusCode} ❌' : '✅ 200 ✅'} ${response.requestOptions.baseUrl}${response.requestOptions.path}');
      log('Query params: ${response.requestOptions.queryParameters}');
      log('-------------------------');
    }

    return handler.next(response);
  }
}
