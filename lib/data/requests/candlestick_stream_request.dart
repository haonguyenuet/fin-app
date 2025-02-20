import 'dart:convert';

import 'package:fin_chart/data/models/time_interval.dart';

class CandlestickStreamRequest {
  final int id;
  final String symbol;
  final TimeInterval interval;
  final bool isSubscribe;

  CandlestickStreamRequest({
    required this.id,
    required this.symbol,
    required this.interval,
    required this.isSubscribe,
  });

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "method": isSubscribe ? "SUBSCRIBE" : "UNSUBSCRIBE",
      "params": ["${symbol.toLowerCase()}@kline_${interval.value}"],
    };
  }

  String toJson() => jsonEncode(toMap());
}
