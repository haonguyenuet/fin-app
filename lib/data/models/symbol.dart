List<MarketSymbol> parseMarketSymbols(List<dynamic> symbols) {
  return symbols.map((e) => MarketSymbol.fromMap(e)).where((e) => e.quoteAsset.toUpperCase() == 'USDT').toList();
}

/// This data represents a trading pair on the exchange.
class MarketSymbol {
  MarketSymbol({
    required this.value,
    required this.baseAsset,
    required this.quoteAsset,
  });

  final String value;
  final String baseAsset;
  final String quoteAsset;

  String get name => '$baseAsset/$quoteAsset';

  SymbolSnapshot? _snapshot;
  SymbolSnapshot? get snapshot => _snapshot;
  void updateSnapshot(SymbolSnapshot snapshot) {
    _snapshot = snapshot;
  }

  factory MarketSymbol.fromMap(Map<String, dynamic> map) {
    return MarketSymbol(
      value: map['symbol'],
      baseAsset: map['baseAsset'],
      quoteAsset: map['quoteAsset'],
    );
  }
}

/// This data is a snapshot of the symbol's state over the last 24hr.
class SymbolSnapshot {
  SymbolSnapshot({
    required this.symbol,
    required this.lastPrice,
    required this.priceChange,
    required this.priceChangePercent,
    required this.highPrice,
    required this.lowPrice,
    required this.volume,
  });

  final String symbol;
  final double lastPrice;
  final double priceChange;
  final double priceChangePercent;
  final double highPrice;
  final double lowPrice;
  final double volume;

  factory SymbolSnapshot.fromMap(Map<String, dynamic> map) {
    return SymbolSnapshot(
      symbol: map['symbol'],
      lastPrice: double.parse(map['lastPrice']),
      priceChange: double.parse(map['priceChange']),
      priceChangePercent: double.parse(map['priceChangePercent']),
      highPrice: double.parse(map['highPrice']),
      lowPrice: double.parse(map['lowPrice']),
      volume: double.parse(map['volume']),
    );
  }
}
