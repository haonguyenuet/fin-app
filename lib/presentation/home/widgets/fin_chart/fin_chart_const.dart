import 'package:flutter/material.dart';

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
}

class FinChartColors {
  /// Color used for bullish (upward) price movements
  static const Color bullColor = Color(0xFF26A69A);

  /// Color used for bearish (downward) price movements
  static const Color bearColor = Color(0xFFEF5350);

  /// Color used for axis labels text
  static const Color axisLabelColor = Color(0XFF8F8F8F);

}

class FinChartTypo {
  static const TextStyle axisLabel = TextStyle(
    fontSize: 12,
    height: 1,
    color: FinChartColors.axisLabelColor,
  );

   static const TextStyle tooltip = TextStyle(
    fontSize: 12,
    height: 1,
    color: Color(0xFFFFFFFF),
  );
}

class FinChartAnimation {
  static const Duration shortDuration = Duration(milliseconds: 300);
}
