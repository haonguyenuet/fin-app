import 'package:market_stream/data/events/candlestick_event.dart';
import 'package:market_stream/data/models/candle.dart';
import 'package:market_stream/data/models/time_interval.dart';
import 'package:market_stream/data/repositories/base_repository.dart';
import 'package:market_stream/data/sources/networking/services/candlestick_api_service.dart';
import 'package:market_stream/data/sources/streaming/streaming_service.dart';

class CandlestickRepository extends BaseRepository {
  CandlestickRepository(CandlestickApiService apiService, StreamingService streamingService)
      : _apiService = apiService,
        _streamingService = streamingService;

  final CandlestickApiService _apiService;
  final StreamingService _streamingService;

  Future<List<TimeInterval>> fetchIntervals() async {
    return TimeInterval.values;
  }

  Future<List<Candle>> fetchCandles({
    required String symbol,
    required TimeInterval interval,
    int? endTime,
  }) async {
    final candles = await safeCallApi(
      request: _apiService.fetchCandles(symbol: symbol, interval: interval, endTime: endTime),
    );
    if (candles != null) {
      /// Reverse the list to display the latest candlestick first
      return candles.reversed.toList();
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
