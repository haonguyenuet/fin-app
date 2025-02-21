List<MarketSymbol> parseMarketSymbols(List<dynamic> symbols) {
  return symbols.map((e) => MarketSymbol.fromMap(e)).where((e) => e.quoteAsset.toUpperCase() == 'USDT').toList();
}

class MarketSymbol {
  MarketSymbol({
    required this.value,
    required this.baseAsset,
    required this.quoteAsset,
  });

  final String value;
  final String baseAsset;
  final String quoteAsset;
  SymbolSnapshot? snapshot;

  String get name => '$baseAsset/$quoteAsset';

  void updateSnapshot(SymbolSnapshot snapshot) {
    this.snapshot = snapshot;
  }

  factory MarketSymbol.fromMap(Map<String, dynamic> map) {
    return MarketSymbol(
      value: map['symbol'],
      baseAsset: map['baseAsset'],
      quoteAsset: map['quoteAsset'],
    );
  }
}

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
