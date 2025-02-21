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

  String get name => '$baseAsset/$quoteAsset';

  factory MarketSymbol.fromMap(Map<String, dynamic> map) {
    return MarketSymbol(
      value: map['symbol'],
      baseAsset: map['baseAsset'],
      quoteAsset: map['quoteAsset'],
    );
  }
}
