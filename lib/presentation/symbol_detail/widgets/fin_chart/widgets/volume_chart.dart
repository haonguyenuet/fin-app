import 'package:fin_app/data/models/candle.dart';
import 'package:fin_app/presentation/symbol_detail/widgets/fin_chart/fin_chart_const.dart';
import 'package:fin_app/shared/consts/app_color.dart';
import 'package:fin_app/shared/consts/app_typo.dart';
import 'package:fin_app/shared/extensions/double_ext.dart';
import 'package:flutter/material.dart';

class VolumeChart extends StatelessWidget {
  const VolumeChart({
    super.key,
    required this.candles,
    required this.barWidth,
    required this.viewportHighestVolume,
    required this.viewportLowestVolume,
    required this.shiftedRight,
  });

  final List<Candle> candles;
  final double barWidth;
  final double viewportHighestVolume;
  final double viewportLowestVolume;
  final int shiftedRight;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: RepaintBoundary(
            child: CustomPaint(
              size: Size.infinite,
              painter: _VolumeBarsPainter(
                candles: candles,
                barWidth: barWidth,
                viewportHighestVolume: viewportHighestVolume,
                shiftedRight: shiftedRight,
              ),
            ),
          ),
        ),
        _VolumeAxis(
          viewportHighestVolume: viewportHighestVolume,
          viewportLowestVolume: viewportLowestVolume,
        ),
      ],
    );
  }
}

class _VolumeAxis extends StatelessWidget {
  const _VolumeAxis({
    required this.viewportHighestVolume,
    required this.viewportLowestVolume,
  });

  final double viewportHighestVolume;
  final double viewportLowestVolume;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: FinChartDimens.rightAxisWidth,
      child: Column(
        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            viewportHighestVolume.abbreviate(),
            style: AppTypography.axisLabel,
          ),
          // Text(
          //   viewportLowestVolume.abbreviate(),
          //   style: FinChartTypo.axisLabel,
          // ),
        ],
      ),
    );
  }
}

class _VolumeBarsPainter extends CustomPainter {
  _VolumeBarsPainter({
    required this.candles,
    required this.barWidth,
    required this.viewportHighestVolume,
    required this.shiftedRight,
  });

  final List<Candle> candles;
  final double barWidth;
  final double viewportHighestVolume;
  final int shiftedRight;

  @override
  void paint(Canvas canvas, Size size) {
    final heightPerVolume = size.height / viewportHighestVolume;
    final visibleBarCount = size.width ~/ barWidth;

    for (int index = 0; index < visibleBarCount; index++) {
      final candleIndex = index + shiftedRight;
      if (candleIndex < 0 || candleIndex >= candles.length) continue;

      _drawVolBar(canvas, size, index, candles[candleIndex], heightPerVolume);
    }
  }

  void _drawVolBar(Canvas canvas, Size size, int index, Candle candle, double heightPerVolume) {
    final paint = Paint()
      ..color = candle.isBull ? AppColors.bull : AppColors.bear
      ..strokeWidth = barWidth - 1;

    final x = size.width - (index + 0.5) * barWidth;

    canvas.drawLine(
      Offset(x, (viewportHighestVolume - candle.volume) * heightPerVolume),
      Offset(x, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(_VolumeBarsPainter oldDelegate) {
    return oldDelegate.candles != candles ||
        oldDelegate.barWidth != barWidth ||
        oldDelegate.viewportHighestVolume != viewportHighestVolume ||
        oldDelegate.shiftedRight != shiftedRight;
  }
}
