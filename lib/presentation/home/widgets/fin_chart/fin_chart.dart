import 'dart:math';

import 'package:fin_chart/data/models/candle.dart';
import 'package:fin_chart/presentation/home/widgets/fin_chart/fin_chart_const.dart';
import 'package:fin_chart/presentation/home/widgets/fin_chart/widgets/crosshair_indicators.dart';
import 'package:fin_chart/presentation/home/widgets/fin_chart/widgets/date_axis_grid.dart';
import 'package:fin_chart/presentation/home/widgets/fin_chart/widgets/price_chart.dart';
import 'package:fin_chart/presentation/home/widgets/fin_chart/widgets/volume_chart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FinChart extends ConsumerStatefulWidget {
  const FinChart({
    super.key,
    required this.candles,
    required this.onFetchMoreCandles,
  });

  final List<Candle> candles;
  final AsyncCallback onFetchMoreCandles;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _FinChartState();
}

class _FinChartState extends ConsumerState<FinChart> {
  List<Candle> get candles => widget.candles;

  /// The [_shiftedRight]: displacement (in candle units) from the viewport's right edge.
  ///
  /// [_shiftedRight] = -10: latest candle is 10 candles away from the right of the viewport.
  /// [_shiftedRight] =   0: latest candle touches the right.
  /// [_shiftedRight] =  10: latest candle scrolled out, 10th candle touches the right.
  int _shiftedRight = FinChartDefaults.shiftedRight;
  int _prevShiftedRight = FinChartDefaults.shiftedRight;

  double _targetCandleWidth = FinChartDimens.autoCandleWidth;
  double _prevCandleWidth = FinChartDimens.autoCandleWidth;

  double _prevDragX = 0;
  bool _isFetchingMore = false;

  final _crosshairPosition = ValueNotifier<Offset?>(null);

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      tween: Tween(begin: _prevCandleWidth, end: _targetCandleWidth),
      duration: FinChartAnimation.shortDuration,
      builder: (context, candleWidth, child) {
        return LayoutBuilder(builder: (context, constraints) {
          /// Calculate the viewport dimensions, [viewport] is the area where the chart that users can see.
          final viewportHeight = constraints.maxHeight - FinChartDimens.bottomAxisWidth;
          final viewportWidth = constraints.maxWidth - FinChartDimens.rightAxisWidth;

          /// Calculate the number of candles that can fit in the viewport
          final totalCandleCount = candles.length;
          final viewportCandleCount = viewportWidth ~/ candleWidth;
          final rightmostCandleIndex = max(_shiftedRight, 0);
          final leftmostCandleIndex = min(_shiftedRight + viewportCandleCount, totalCandleCount - 1);
          final viewportCandles = candles.getRange(rightmostCandleIndex, leftmostCandleIndex + 1).toList();
          if (leftmostCandleIndex == totalCandleCount - 1 && !_isFetchingMore) {
            _isFetchingMore = true;
            widget.onFetchMoreCandles().then((_) {
              _isFetchingMore = false;
            });
          }

          /// Calculate the highest volume in the viewport
          final viewportHighestVolume = viewportCandles.map((c) => c.volume).reduce(max);
          final viewportLowestVolume = viewportCandles.map((c) => c.volume).reduce(min);

          /// Calculate the highest and lowest price in the viewport
          double viewportHighestPrice = 0;
          double viewportLowestPrice = 0;
          viewportHighestPrice = viewportCandles.map((c) => c.high).reduce(max);
          viewportLowestPrice = viewportCandles.map((c) => c.low).reduce(min);

          if (viewportLowestPrice == viewportHighestPrice) {
            viewportHighestPrice += 10;
            viewportLowestPrice -= 10;
          }

          return Stack(
            children: [
              Positioned.fill(
                right: FinChartDimens.rightAxisWidth,
                child: DateAxisGrid(
                  candles: candles,
                  candleWidth: candleWidth,
                  shiftedRight: _shiftedRight,
                ),
              ),
              Positioned.fill(
                bottom: FinChartDimens.bottomAxisWidth,
                child: Column(
                  children: [
                    Expanded(
                      flex: 3,
                      child: PriceChart(
                        candles: candles,
                        candleWidth: candleWidth,
                        viewportLowestPrice: viewportLowestPrice,
                        viewportHighestPrice: viewportHighestPrice,
                        shiftedRight: _shiftedRight,
                        onVerticalScale: (scaleY) {},
                      ),
                    ),
                    const SizedBox(
                      height: FinChartDimens.priceToVolumeSpacing,
                    ),
                    Expanded(
                      flex: 1,
                      child: VolumeChart(
                        candles: candles,
                        barWidth: candleWidth,
                        viewportHighestVolume: viewportHighestVolume,
                        viewportLowestVolume: viewportLowestVolume,
                        shiftedRight: _shiftedRight,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned.fill(
                bottom: FinChartDimens.bottomAxisWidth,
                child: CrosshairIndicators(
                  candles: candles,
                  viewportHighestPrice: viewportHighestPrice,
                  viewportLowestPrice: viewportLowestPrice,
                  viewportHighestVolume: viewportHighestVolume,
                  viewportWidth: viewportWidth,
                  viewportHeight: viewportHeight,
                  candleWidth: candleWidth,
                  crosshairPosition: _crosshairPosition,
                  shiftedRight: _shiftedRight,
                ),
              ),
              Positioned.fill(
                right: FinChartDimens.rightAxisWidth,
                bottom: FinChartDimens.bottomAxisWidth,
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onScaleStart: (details) {
                    _prevDragX = details.localFocalPoint.dx;
                    _prevShiftedRight = _shiftedRight;
                    if (_crosshairPosition.value != null) {
                      _crosshairPosition.value = null;
                    }
                  },
                  onScaleUpdate: (details) {
                    if (details.scale == 1) {
                      setState(() {
                        final dragDistance = details.localFocalPoint.dx - _prevDragX;
                        final dragCandles = dragDistance ~/ candleWidth;
                        _shiftedRight = _prevShiftedRight + dragCandles;
                        _shiftedRight = _shiftedRight.clamp(FinChartDefaults.shiftedRight, candles.length - 1);
                      });
                    } else {
                      final scale = details.scale.clamp(0.9, 1.1);
                      final newCandleWidth = (_targetCandleWidth * scale).clamp(
                        FinChartDimens.minCandleWidth,
                        FinChartDimens.maxCandleWidth,
                      );
                      setState(() {
                        _prevCandleWidth = _targetCandleWidth;
                        _targetCandleWidth = newCandleWidth;
                      });
                    }
                  },
                  onScaleEnd: (_) {
                    _prevShiftedRight = _shiftedRight;
                  },
                  onLongPressStart: (details) {
                    _crosshairPosition.value = details.localPosition;
                  },
                  onLongPressMoveUpdate: (details) {
                    _crosshairPosition.value = details.localPosition;
                  },
                  onTap: () {
                    if (_crosshairPosition.value != null) {
                      _crosshairPosition.value = null;
                    }
                  },
                ),
              ),
            ],
          );
        });
      },
    );
  }
}
