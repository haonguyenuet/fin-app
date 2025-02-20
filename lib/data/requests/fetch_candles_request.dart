import 'package:fin_chart/data/models/time_interval.dart';

class FetchCandlesRequest {
  final String symbol;
  final TimeInterval interval;
  final int? endTime;

  FetchCandlesRequest({
    required this.symbol,
    required this.interval,
    this.endTime,
  });

  String toQueryString() {
    String query = 'symbol=$symbol&interval=${interval.value}';
    if (endTime != null) {
      query += '&endTime=$endTime';
    }
    return query;
  }
}
