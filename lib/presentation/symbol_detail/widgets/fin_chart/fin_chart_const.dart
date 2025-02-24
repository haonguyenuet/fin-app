import 'package:market_stream/shared/consts/app_typo.dart';

class FinChartDefaults {
  /// The amount of candles to shift right (negative value means shifting left)
  static const int shiftedRight = -10;
}

class FinChartDimens {
  /// Width of the right axis in pixels
  static const double rightAxisWidth = 80;

  /// Height of the bottom axis in pixels
  static const double bottomAxisWidth = 80;

  /// Default width of a single candle when auto-sizing
  static const double autoCandleWidth = 8;

  /// Minimum allowed width of a candle
  static const double minCandleWidth = 2;

  /// Maximum allowed width of a candle
  static const double maxCandleWidth = 20;

  /// Spacing between the price chart and the volume chart
  static const double priceToVolumeSpacing = 40;

  /// The height of the axis label
  static final double axisLabelHeight = AppTypography.axisLabel.fontSize! * AppTypography.axisLabel.height!;
}
