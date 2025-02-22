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
  final double closePrice;
  final double openPrice;
  final double highPrice;
  final double lowPrice;
  final double totalTradedBaseAssetVolume;
  final double totalTradedQuoteAssetVolume;

  SymbolSnapshot get snapshot => SymbolSnapshot(
        symbol: symbol,
        lastPrice: closePrice,
        openPrice: openPrice,
        highPrice: highPrice,
        lowPrice: lowPrice,
        priceChange: closePrice - openPrice,
        priceChangePercent: (closePrice - openPrice) / openPrice * 100,
        baseVolume: totalTradedBaseAssetVolume,
        quoteVolume: totalTradedQuoteAssetVolume,
      );

  factory SymbolMiniTickerEvent.fromMap(Map<String, dynamic> map) {
    return SymbolMiniTickerEvent(
      eventType: map['e'],
      eventTime: map['E'],
      symbol: map['s'],
      closePrice: double.parse(map['c']),
      openPrice: double.parse(map['o']),
      highPrice: double.parse(map['h']),
      lowPrice: double.parse(map['l']),
      totalTradedBaseAssetVolume: double.parse(map['v']),
      totalTradedQuoteAssetVolume: double.parse(map['q']),
    );
  }
}
