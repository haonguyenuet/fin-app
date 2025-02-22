List<MarketSymbol> parseMarketSymbols(List<dynamic> symbols) {
  return symbols.map((e) => MarketSymbol.fromMap(e)).where((e) => e.quoteAsset.toUpperCase() == 'USDT').toList();
}

/// This data represents a trading pair on the exchange.
class MarketSymbol {
  MarketSymbol({
    required this.id,
    required this.baseAsset,
    required this.quoteAsset,
  });

  final String id;
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
      id: map['symbol'],
      baseAsset: map['baseAsset'],
      quoteAsset: map['quoteAsset'],
    );
  }
}

/// This data is a snapshot of the symbol's state over the last 24hr.
class SymbolSnapshot {
  SymbolSnapshot({
    required this.symbol,
    required this.openPrice,
    required this.lastPrice,
    required this.highPrice,
    required this.lowPrice,
    required this.priceChange,
    required this.priceChangePercent,
    required this.baseVolume,
    required this.quoteVolume,
  });

  final String symbol;
  final double lastPrice;
  final double openPrice;
  final double highPrice;
  final double lowPrice;
  final double priceChange;
  final double priceChangePercent;
  final double baseVolume;
  final double quoteVolume;

  factory SymbolSnapshot.fromMap(Map<String, dynamic> map) {
    return SymbolSnapshot(
      symbol: map['symbol'],
      lastPrice: double.parse(map['lastPrice']),
      openPrice: double.parse(map['openPrice']),
      highPrice: double.parse(map['highPrice']),
      lowPrice: double.parse(map['lowPrice']),
      priceChange: double.parse(map['priceChange']),
      priceChangePercent: double.parse(map['priceChangePercent']),
      baseVolume: double.parse(map['volume']),
      quoteVolume: double.parse(map['quoteVolume']),
    );
  }
}
