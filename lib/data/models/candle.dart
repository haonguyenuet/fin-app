import 'dart:convert';

List<Candle> parseCandles(String body) {
  final List<dynamic> data = jsonDecode(body);
  final candles = data.map((e) => Candle.fromList(e)).toList();

  // we want the latest candle to be the first element in the list, so we reverse the list.
  return candles.reversed.toList();
}

class Candle {
  Candle({
    required this.date,
    required this.high,
    required this.low,
    required this.open,
    required this.close,
    required this.volume,
  });

  final double high;
  final double low;
  final double open;
  final double close;
  final double volume;
  final DateTime date;

  bool get isBull => open <= close;

  factory Candle.fromList(List<dynamic> list) {
    return Candle(
      date: DateTime.fromMillisecondsSinceEpoch(list[0]),
      open: double.parse(list[1]),
      high: double.parse(list[2]),
      low: double.parse(list[3]),
      close: double.parse(list[4]),
      volume: double.parse(list[5]),
    );
  }

  factory Candle.fromMap(Map<String, dynamic> map) {
    return Candle(
      date: DateTime.fromMillisecondsSinceEpoch(map["t"]),
      high: double.parse(map["h"]),
      low: double.parse(map["l"]),
      open: double.parse(map["o"]),
      close: double.parse(map["c"]),
      volume: double.parse(map["v"]),
    );
  }
}
