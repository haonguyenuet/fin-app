import 'package:fin_app/data/models/candle.dart';
import 'package:fin_app/presentation/symbol_detail/widgets/fin_chart/fin_chart_const.dart';
import 'package:fin_app/shared/consts/app_color.dart';
import 'package:fin_app/shared/consts/app_typo.dart';
import 'package:fin_app/shared/extensions/double_ext.dart';
import 'package:fin_app/shared/utils/format_util.dart';
import 'package:fin_app/shared/widgets/dash_line.dart';
import 'package:flutter/material.dart';

class CrosshairIndicators extends StatelessWidget {
  const CrosshairIndicators({
    super.key,
    required this.candles,
    required this.viewportHighestPrice,
    required this.viewportLowestPrice,
    required this.viewportHighestVolume,
    required this.viewportWidth,
    required this.viewportHeight,
    required this.candleWidth,
    required this.crosshairPosition,
    required this.shiftedRight,
  });

  final List<Candle> candles;
  final double viewportHighestPrice;
  final double viewportLowestPrice;
  final double viewportHighestVolume;
  final double viewportWidth;
  final double viewportHeight;
  final double candleWidth;
  final ValueNotifier<Offset?> crosshairPosition;
  final int shiftedRight;

  final double tooltipHeight = 20.0;
  final Color crosshairLineColor = Colors.black54;

  @override
  Widget build(BuildContext context) {
    final priceChartHeight = (viewportHeight - FinChartDimens.priceToVolumeSpacing) * 3 / 4;
    final volumeChartHeight = (viewportHeight - FinChartDimens.priceToVolumeSpacing) * 1 / 4;

    return ValueListenableBuilder<Offset?>(
      valueListenable: crosshairPosition,
      builder: (context, value, child) {
        Offset? position = value;
        if (position == null) {
          return const SizedBox.shrink();
        }

        /// Clamp the position to the viewport
        position = Offset(
          position.dx.clamp(0.0, viewportWidth),
          position.dy.clamp(0.0, viewportHeight),
        );

        /// Calculate the selected candle
        Candle? selectedCandle;
        final viewportCandleIndex = (viewportWidth - position.dx) ~/ candleWidth;
        final selectedCandleIndex = viewportCandleIndex + shiftedRight;
        if (selectedCandleIndex >= 0 && selectedCandleIndex < candles.length) {
          selectedCandle = candles[selectedCandleIndex];
        } else {
          return const SizedBox.shrink();
        }

        /// Calculate the crosshair position
        ///
        /// [crosshairX] is the center of the selected candle
        /// [crosshairY] is the y position of the long press event
        final extraSpace = viewportWidth % candleWidth;
        final crosshairX = extraSpace + position.dx ~/ candleWidth * candleWidth + candleWidth / 2;
        final crosshairY = position.dy;

        return Stack(
          clipBehavior: Clip.none,
          children: [
            _buildCrosshairXLine(
              crosshairX: crosshairX,
            ),
            _buildCrosshairXTooltip(
              crosshairX: crosshairX,
              volumeChartHeight: volumeChartHeight,
              selectedCandle: selectedCandle,
            ),
            _buildCrosshairYLine(
              crosshairY: crosshairY,
              priceChartHeight: priceChartHeight,
            ),
            _buildCrosshairYTooltip(
              crosshairY: crosshairY,
              priceChartHeight: priceChartHeight,
              volumeChartHeight: volumeChartHeight,
            ),
            _buildCrosshairIntersection(
              crosshairX: crosshairX,
              crosshairY: crosshairY,
            ),
            _buildSelectedCandleInfo(
              selectedCandle: selectedCandle,
            ),
          ],
        );
      },
    );
  }

  Widget _buildCrosshairXLine({required double crosshairX}) {
    return Positioned(
      bottom: 0,
      top: 0,
      left: crosshairX,
      child: DashLine(color: crosshairLineColor, direction: Axis.vertical),
    );
  }

  Widget _buildCrosshairXTooltip({
    required double crosshairX,
    required double volumeChartHeight,
    required Candle selectedCandle,
  }) {
    double tooltipWidth = 120.0;
    double left;
    if (crosshairX < tooltipWidth / 2) {
      left = 0;
    } else if (crosshairX > viewportWidth - tooltipWidth / 2) {
      left = viewportWidth - tooltipWidth;
    } else {
      left = crosshairX - tooltipWidth / 2;
    }
    return Positioned(
      bottom: volumeChartHeight,
      left: left,
      child: _CrosshairTooltip(
        height: tooltipHeight,
        width: tooltipWidth,
        text: formatTime(selectedCandle.date),
      ),
    );
  }

  Widget _buildCrosshairYLine({required double crosshairY, required double priceChartHeight}) {
    if (crosshairY > priceChartHeight && crosshairY < priceChartHeight + FinChartDimens.priceToVolumeSpacing) {
      return const SizedBox.shrink();
    }
    return Positioned(
      top: crosshairY,
      left: 0,
      right: 0,
      child: DashLine(color: crosshairLineColor),
    );
  }

  Widget _buildCrosshairYTooltip({
    required double crosshairY,
    required double priceChartHeight,
    required double volumeChartHeight,
  }) {
    String? tooltipText;
    if (crosshairY <= priceChartHeight) {
      final priceRange = viewportHighestPrice - viewportLowestPrice;
      final price = viewportHighestPrice - crosshairY / priceChartHeight * priceRange;
      tooltipText = formatPrice(price);
    } else if (viewportHeight - crosshairY <= volumeChartHeight) {
      final vol = (viewportHeight - crosshairY) / volumeChartHeight * viewportHighestVolume;
      tooltipText = vol.abbreviate();
    }

    if (tooltipText == null) {
      return const SizedBox.shrink();
    }
    return Positioned(
      top: crosshairY - tooltipHeight / 2,
      right: 0,
      child: _CrosshairTooltip(
        height: tooltipHeight,
        width: FinChartDimens.rightAxisWidth,
        text: tooltipText,
      ),
    );
  }

  Widget _buildCrosshairIntersection({required double crosshairX, required double crosshairY}) {
    final intersectionSize = 6.0;
    return Positioned(
      left: crosshairX - intersectionSize / 2,
      top: crosshairY - intersectionSize / 2,
      child: Container(
        width: intersectionSize,
        height: intersectionSize,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(intersectionSize / 2),
        ),
      ),
    );
  }

  Widget _buildSelectedCandleInfo({required Candle selectedCandle}) {
    return Positioned(
      left: 10,
      top: -12,
      right: FinChartDimens.rightAxisWidth,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          Text('O: ${formatPrice(selectedCandle.open)}', style: AppTypography.bodySmall),
          Text('H: ${formatPrice(selectedCandle.high)}', style: AppTypography.bodySmall),
          Text('L: ${formatPrice(selectedCandle.low)}', style: AppTypography.bodySmall),
          Text('C: ${formatPrice(selectedCandle.close)}', style: AppTypography.bodySmall),
        ],
      ),
    );
  }
}

class _CrosshairTooltip extends StatelessWidget {
  const _CrosshairTooltip({
    required this.height,
    required this.width,
    required this.text,
  });

  final double height;
  final double width;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: AppColors.primary,
      ),
      child: Text(
        text,
        style: AppTypography.bodySmall.copyWith(color: AppColors.onPrimary),
      ),
    );
  }
}
