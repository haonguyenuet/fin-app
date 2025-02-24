import 'package:market_stream/data/models/candle.dart';

/// Sample Data:
///
/// {
///   "e": "kline",          | Event type
///   "E": 1638747660000,    | Event time
///   "s": "BTCUSDT",        | Symbol
///   "k": {
///     "t": 1638747660000,  | Kline start time
///     "T": 1638747719999,  | Kline close time
///     "s": "BTCUSDT",      | Symbol
///     "i": "1m",           | Interval
///     "f": 100,            | First trade ID
///     "L": 200,            | Last trade ID
///     "o": "0.0010",       | Open price
///     "c": "0.0020",       | Close price
///     "h": "0.0025",       | High price
///     "l": "0.0015",       | Low price
///     "v": "1000",         | Base asset volume
///     "n": 100,            | Number of trades
///     "x": false,          | Is this kline closed?
///     "q": "1.0000",       | Quote asset volume
///     "V": "500",          | Taker buy base asset volume
///     "Q": "0.500",        | Taker buy quote asset volume
///     "B": "123456"        | Ignore
///   }
/// }

class CandlestickEvent {
  final String eventType;
  final int eventTime;
  final String symbol;
  final Candle candle;

  CandlestickEvent({
    required this.eventType,
    required this.eventTime,
    required this.symbol,
    required this.candle,
  });

  factory CandlestickEvent.fromMap(Map<String, dynamic> map) {
    return CandlestickEvent(
      eventType: map['e'],
      eventTime: map['E'],
      symbol: map['s'],
      candle: Candle.fromMap(map['k']),
    );
  }
}
