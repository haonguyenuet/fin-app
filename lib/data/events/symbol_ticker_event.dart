import 'package:fin_app/data/models/symbol.dart';

/// Sample data:
///
/// {
///   "e": "24hrMiniTicker", | Event type
///   "E": 123456789,        | Event time
///   "s": "BTCUSDT",        | Symbol
///   "c": "0.0025",         | Close price
///   "o": "0.0010",         | Open price
///   "h": "0.0025",         | High price
///   "l": "0.0010",         | Low price
///   "v": "10000",          | Total traded base asset volume
///   "q": "18"              | Total traded quote asset volume
/// }

class SymbolMiniTickerEvent {
  SymbolMiniTickerEvent({
    required this.eventType,
    required this.eventTime,
    required this.symbol,
    required this.closePrice,
    required this.openPrice,
    required this.highPrice,
    required this.lowPrice,
    required this.totalTradedBaseAssetVolume,
    required this.totalTradedQuoteAssetVolume,
  });

  final String eventType;
  final int eventTime;
  final String symbol;
  final String closePrice;
  final String openPrice;
  final String highPrice;
  final String lowPrice;
  final String totalTradedBaseAssetVolume;
  final String totalTradedQuoteAssetVolume;

  SymbolSnapshot get snapshot => SymbolSnapshot(
        symbol: symbol,
        lastPrice: double.parse(closePrice),
        priceChange: double.parse(closePrice) - double.parse(openPrice),
        priceChangePercent: (double.parse(closePrice) - double.parse(openPrice)) / double.parse(openPrice) * 100,
        highPrice: double.parse(highPrice),
        lowPrice: double.parse(lowPrice),
        volume: double.parse(totalTradedBaseAssetVolume),
      );

  factory SymbolMiniTickerEvent.fromMap(Map<String, dynamic> map) {
    return SymbolMiniTickerEvent(
      eventType: map['e'],
      eventTime: map['E'],
      symbol: map['s'],
      closePrice: map['c'],
      openPrice: map['o'],
      highPrice: map['h'],
      lowPrice: map['l'],
      totalTradedBaseAssetVolume: map['v'],
      totalTradedQuoteAssetVolume: map['q'],
    );
  }
}
