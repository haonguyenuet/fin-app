import 'package:fin_app/data/events/candlestick_event.dart';
import 'package:fin_app/data/events/symbol_ticker_event.dart';
import 'package:fin_app/data/models/time_interval.dart';

abstract class StreamingService {
  void connect();
  void reconnect();
  void disconnect();
  void close();

  /// =============================== Kline/Candlestick Streams ===============================
  ///
  /// The Kline/Candlestick Stream push updates to the current klines/candlestick every 250 milliseconds (if existing).

  Stream<CandlestickEvent> get candlestickStream;

  void subscribeCandlestickStream({required String symbol, required TimeInterval interval});

  void unsubscribeCandlestickStream({required String symbol, required TimeInterval interval});

  /// =============================== Individual Symbol Mini Ticker Streams ===============================
  ///
  /// 24hr rolling window mini-ticker statistics for a single symbol. These are NOT the statistics of the UTC day,
  /// but a 24hr rolling window from requestTime to 24hrs before.
  Stream<SymbolMiniTickerEvent> get symbolMiniTickerStream;

  Future<bool> subscribeSymbolMiniTickerStream({required List<String> symbols});

  Future<bool> unsubscribeSymbolMiniTickerStream({required List<String> symbols});
}
