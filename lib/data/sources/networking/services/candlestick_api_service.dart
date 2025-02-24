import 'package:market_stream/data/models/candle.dart';
import 'package:market_stream/data/models/time_interval.dart';
import 'package:market_stream/data/sources/networking/dio_client.dart';
import 'package:market_stream/data/sources/networking/requests/fetch_candles_query.dart';

class CandlestickApiService {
  CandlestickApiService(DioClient dioClient) : _dioClient = dioClient;

  final DioClient _dioClient;

  Future<List<Candle>> fetchCandles({
    required String symbol,
    required TimeInterval interval,
    int? endTime,
  }) async {
    final query = FetchCandlesQuery(symbol: symbol, interval: interval, endTime: endTime);
    final response = await _dioClient.get<List<dynamic>>("/klines?${query.toString()}");
    if (response != null) {
      return response.map((e) => Candle.fromList(e)).toList();
    }
    return [];
  }
}
