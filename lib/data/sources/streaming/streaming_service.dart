import 'package:fin_app/data/events/candlestick_event.dart';
import 'package:fin_app/data/models/time_interval.dart';

abstract class StreamingService {
  void connect();

  Stream<CandlestickEvent> get candlestickStream;

  void subscribeCandlestickStream({required String symbol, required TimeInterval interval});

  void unsubscribeCandlestickStream({required String symbol, required TimeInterval interval});

  void disconnect();
}
