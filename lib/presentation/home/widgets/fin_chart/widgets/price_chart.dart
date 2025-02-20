import 'package:fin_chart/data/models/candle.dart';
import 'package:fin_chart/presentation/home/widgets/fin_chart/fin_chart_const.dart';
import 'package:fin_chart/presentation/home/widgets/fin_chart/widgets/dash_line.dart';
import 'package:fin_chart/presentation/home/utils/helpers.dart';
import 'package:flutter/material.dart';

class PriceChart extends StatelessWidget {
  const PriceChart({
    super.key,
    required this.candles,
    required this.candleWidth,
    required this.viewportLowestPrice,
    required this.viewportHighestPrice,
    required this.shiftedRight,
    required this.onVerticalScale,
  });

  final List<Candle> candles;
  final double candleWidth;
  final double viewportLowestPrice;
  final double viewportHighestPrice;
  final int shiftedRight;
  final Function(double) onVerticalScale;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(
          top: -(FinChartTypo.axisLabel.fontSize!),
          child: _PriceAxisGrid(
            viewportLowestPrice: viewportLowestPrice,
            viewportHighestPrice: viewportHighestPrice,
            latestCandle: candles.first,
            onVerticalScale: onVerticalScale,
          ),
        ),
        Positioned.fill(
          right: FinChartDimens.rightAxisWidth,
          child: RepaintBoundary(
            child: CustomPaint(
              size: Size.infinite,
              painter: _CandlestickPainter(
                candles: candles,
                candleWidth: candleWidth,
                viewportHighestPrice: viewportHighestPrice,
                viewportLowestPrice: viewportLowestPrice,
                shiftedRight: shiftedRight,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// The price axis grid with price labels and an indicator.
class _PriceAxisGrid extends StatelessWidget {
  const _PriceAxisGrid({
    required this.viewportLowestPrice,
    required this.viewportHighestPrice,
    required this.onVerticalScale,
    required this.latestCandle,
  });

  final double viewportLowestPrice;
  final double viewportHighestPrice;
  final ValueChanged<double> onVerticalScale;
  final Candle latestCandle;

  double get priceRange => viewportHighestPrice - viewportLowestPrice;

  @override
  Widget build(BuildContext context) {
    const labelCount = 6;
    final priceStep = priceRange / (labelCount - 1);

    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onVerticalDragUpdate: (details) => onVerticalScale(details.delta.dy),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(labelCount, (index) {
                  return _buildPriceLabel(price: viewportHighestPrice - priceStep * index);
                }),
              ),
              _buildLatestIndicator(axisHeight: constraints.maxHeight),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPriceLabel({required double price}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        SizedBox(
          width: FinChartDimens.rightAxisWidth,
          child: Text(
            formatPrice(price),
            textAlign: TextAlign.center,
            style: FinChartTypo.axisLabel,
          ),
        ),
        Divider(),
      ],
    );
  }

  Widget _buildLatestIndicator({required double axisHeight}) {
    const indicatorHeight = 20.0;
    final indicatorColor = latestCandle.isBull ? FinChartColors.bullColor : FinChartColors.bearColor;
    final chartHeight = axisHeight - FinChartTypo.axisLabel.fontSize!;

    final bottomPosition = _calculateLatestPricePosition(
      latestPrice: latestCandle.close,
      indicatorHeight: indicatorHeight,
      chartHeight: chartHeight,
    );

    return AnimatedPositioned(
      right: 0,
      left: 0,
      bottom: bottomPosition,
      duration: FinChartAnimation.shortDuration,
      child: Row(
        children: [
          Expanded(
            child: DashLine(color: indicatorColor.withValues(alpha: 0.5)),
          ),
          Container(
            height: indicatorHeight,
            width: FinChartDimens.rightAxisWidth,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: indicatorColor,
            ),
            child: Text(
              formatPrice(latestCandle.close),
              style: FinChartTypo.tooltip,
            ),
          ),
        ],
      ),
    );
  }

  double _calculateLatestPricePosition({
    required double latestPrice,
    required double indicatorHeight,
    required double chartHeight,
  }) {
    if (latestPrice > viewportHighestPrice) {
      return chartHeight + indicatorHeight;
    }
    if (latestPrice < viewportLowestPrice) {
      return -indicatorHeight;
    }
    final factor = (latestPrice - viewportLowestPrice) / priceRange;
    return factor * chartHeight - indicatorHeight / 2;
  }
}

/// Custom painter for drawing candlesticks on the price chart.
class _CandlestickPainter extends CustomPainter {
  _CandlestickPainter({
    required this.candles,
    required this.candleWidth,
    required this.viewportLowestPrice,
    required this.viewportHighestPrice,
    required this.shiftedRight,
  }) : _close = candles.first.close;

  final List<Candle> candles;
  final double candleWidth;
  final double viewportLowestPrice;
  final double viewportHighestPrice;
  final int shiftedRight;
  final double _close;

  @override
  void paint(Canvas canvas, Size size) {
    final heightPerPrice = size.height / (viewportHighestPrice - viewportLowestPrice);
    final visibleCandleCount = size.width ~/ candleWidth;

    for (int index = 0; index < visibleCandleCount; index++) {
      final candleIndex = index + shiftedRight;
      if (candleIndex < 0 || candleIndex >= candles.length) continue;

      _drawCandle(
        canvas: canvas,
        size: size,
        index: index,
        candle: candles[candleIndex],
        heightPerPrice: heightPerPrice,
      );
    }
  }

  void _drawCandle({
    required Canvas canvas,
    required Size size,
    required int index,
    required Candle candle,
    required double heightPerPrice,
  }) {
    final paint = Paint()
      ..color = candle.isBull ? FinChartColors.bullColor : FinChartColors.bearColor
      ..style = PaintingStyle.stroke;

    final x = size.width - (index + 0.5) * candleWidth;

    _drawWick(canvas, x, candle, heightPerPrice, paint);
    _drawBody(canvas, x, candle, heightPerPrice, paint);
  }

  void _drawWick(Canvas canvas, double x, Candle candle, double heightPerPrice, Paint paint) {
    final highY = (viewportHighestPrice - candle.high) * heightPerPrice;
    final lowY = (viewportHighestPrice - candle.low) * heightPerPrice;

    canvas.drawLine(
      Offset(x, highY),
      Offset(x, lowY),
      paint..strokeWidth = 1,
    );
  }

  void _drawBody(Canvas canvas, double x, Candle candle, double heightPerPrice, Paint paint) {
    final openY = (viewportHighestPrice - candle.open) * heightPerPrice;
    final closeY = (viewportHighestPrice - candle.close) * heightPerPrice;
    final bodyHeight = (openY - closeY).abs();

    if (bodyHeight > 1) {
      canvas.drawLine(
        Offset(x, openY),
        Offset(x, closeY),
        paint..strokeWidth = candleWidth * 0.8,
      );
    } else {
      canvas.drawLine(
        Offset(x, openY - 0.5),
        Offset(x, openY + 0.5),
        paint..strokeWidth = candleWidth * 0.8,
      );
    }
  }

  @override
  bool shouldRepaint(_CandlestickPainter oldDelegate) {
    /// First comparasion: The latest candle is still in viewport and the current close is different from the previous close
    return (shiftedRight <= 0 && oldDelegate._close != _close) ||
        oldDelegate.candleWidth != candleWidth ||
        oldDelegate.viewportLowestPrice != viewportLowestPrice ||
        oldDelegate.viewportHighestPrice != viewportHighestPrice ||
        oldDelegate.shiftedRight != shiftedRight;
  }
}
