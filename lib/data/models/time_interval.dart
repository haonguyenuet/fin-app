enum TimeInterval {
  m5,
  m15,
  m30,
  h1,
  h2,
  h4,
  h8,
  h12,
  d1,
  d3,
  w1,
  m1;

  String get value {
    switch (this) {
      case TimeInterval.m5:
        return '5m';
      case TimeInterval.m15:
        return '15m';
      case TimeInterval.m30:
        return '30m';
      case TimeInterval.h1:
        return '1h';
      case TimeInterval.h2:
        return '2h';
      case TimeInterval.h4:
        return '4h';
      case TimeInterval.h8:
        return '8h';
      case TimeInterval.h12:
        return '12h';
      case TimeInterval.d1:
        return '1d';
      case TimeInterval.d3:
        return '3d';
      case TimeInterval.w1:
        return '1w';
      case TimeInterval.m1:
        return '1M';
    }
  }

  bool get isPinned {
    switch (this) {
      case TimeInterval.h1:
      case TimeInterval.h4:
      case TimeInterval.d1:
      case TimeInterval.w1:
      case TimeInterval.m1:
        return true;
      default:
        return false;
    }
  }
}
