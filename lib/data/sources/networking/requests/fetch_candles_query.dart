import 'package:fin_app/data/models/time_interval.dart';

class FetchCandlesQuery {
  final String symbol;
  final TimeInterval interval;
  final int? endTime;

  FetchCandlesQuery({
    required this.symbol,
    required this.interval,
    this.endTime,
  });

  @override
  String toString() {
    String query = 'symbol=$symbol&interval=${interval.value}';
    if (endTime != null) {
      query += '&endTime=$endTime';
    }
    return query;
  }
}
