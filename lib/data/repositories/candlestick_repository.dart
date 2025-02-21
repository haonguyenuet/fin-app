import 'package:fin_app/data/events/candlestick_event.dart';
import 'package:fin_app/data/models/candle.dart';
import 'package:fin_app/data/models/time_interval.dart';
import 'package:fin_app/data/repositories/base_repository.dart';
import 'package:fin_app/data/sources/networking/http_service.dart';
import 'package:fin_app/data/sources/networking/requests/fetch_candles_request.dart';
import 'package:fin_app/data/sources/streaming/streaming_service.dart';
import 'package:flutter/foundation.dart';

class CandlestickRepository extends BaseRepository {
  CandlestickRepository({
    required HttpService httpService,
    required StreamingService streamingService,
  })  : _httpService = httpService,
        _streamingService = streamingService;

  final HttpService _httpService;
  final StreamingService _streamingService;

  Future<List<TimeInterval>> fetchIntervals() async {
    return TimeInterval.values;
  }

  Future<List<Candle>> fetchCandles({
    required String symbol,
    required TimeInterval interval,
    int? endTime,
  }) async {
    final request = FetchCandlesRequest(symbol: symbol, interval: interval, endTime: endTime);
    final response = await safeCallApi(
      () => _httpService.get<List<dynamic>>("/klines?${request.toQueryString()}"),
    );
    if (response != null) {
      return await compute(parseCandles, response);
    }
    return [];
  }

  Stream<CandlestickEvent> get candlestickStream => _streamingService.candlestickStream;

  void subscribeCandlestickStream({required String symbol, required TimeInterval interval}) {
    _streamingService.subscribeCandlestickStream(symbol: symbol, interval: interval);
  }

  void unsubscribeCandlestickStream({required String symbol, required TimeInterval interval}) {
    _streamingService.unsubscribeCandlestickStream(symbol: symbol, interval: interval);
  }
}
