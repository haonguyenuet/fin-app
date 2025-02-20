import 'dart:convert';

List<CryptoSymbol> parseSymbols(String body) {
  final map = jsonDecode(body) as Map<String, dynamic>;
  final symbols = map['symbols'] as List<dynamic>;
  return symbols.map((e) => CryptoSymbol.fromMap(e)).toList();
}

class CryptoSymbol {
  CryptoSymbol({
    required this.value,
    required this.baseAsset,
    required this.quoteAsset,
  });

  final String value;
  final String baseAsset;
  final String quoteAsset;

  String get name => '$baseAsset/$quoteAsset';

  factory CryptoSymbol.fromMap(Map<String, dynamic> map) {
    return CryptoSymbol(
      value: map['symbol'],
      baseAsset: map['baseAsset'],
      quoteAsset: map['quoteAsset'],
    );
  }
}
