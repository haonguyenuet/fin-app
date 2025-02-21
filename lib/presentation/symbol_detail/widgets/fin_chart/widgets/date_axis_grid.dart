import 'package:fin_app/data/models/candle.dart';
import 'package:fin_app/presentation/symbol_detail/widgets/fin_chart/fin_chart_const.dart';
import 'package:fin_app/shared/consts/app_color.dart';
import 'package:fin_app/shared/consts/app_typo.dart';
import 'package:fin_app/shared/utils/format_util.dart';
import 'package:flutter/material.dart';

class DateAxisGrid extends StatefulWidget {
  const DateAxisGrid({
    super.key,
    required this.candles,
    required this.candleWidth,
    required this.shiftedRight,
  });

  final List<Candle> candles;
  final double candleWidth;
  final int shiftedRight;

  @override
  State<DateAxisGrid> createState() => _DateAxisGridState();
}

class _DateAxisGridState extends State<DateAxisGrid> {
  final ScrollController _scrollController = ScrollController();

  @override
  void didUpdateWidget(DateAxisGrid oldWidget) {
    if (oldWidget.shiftedRight != widget.shiftedRight || oldWidget.candleWidth != widget.candleWidth) {
      _scrollController.jumpTo((widget.shiftedRight - FinChartDefaults.shiftedRight) * widget.candleWidth);
    }
    super.didUpdateWidget(oldWidget);
  }

  /// Calculates number of candles between two time labels
  int _determineCandlesPerLabel() {
    if (widget.candleWidth < 3) {
      return 63;
    } else if (widget.candleWidth < 5) {
      return 39;
    } else if (widget.candleWidth < 7) {
      return 27;
    } else {
      return 19;
    }
  }

  /// Calculates label time for the label at [labelIndex]
  DateTime? _calculateLabelTime(int candlesPerLabel, int labelIndex, Duration labelInterval) {
    final candleIndex = candlesPerLabel * labelIndex + (candlesPerLabel - 1) ~/ 2 + FinChartDefaults.shiftedRight;
    if (candleIndex >= 0 && candleIndex < widget.candles.length) {
      return widget.candles[candleIndex].date;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.candles.isEmpty) {
      return const SizedBox();
    }

    final candleInterval = widget.candles[0].date.difference(widget.candles[1].date);
    final candlesPerLabel = _determineCandlesPerLabel();

    final labelInterval = candleInterval * candlesPerLabel;
    final labelExtent = widget.candleWidth * candlesPerLabel;

    /// Because [FinChartDefaults.shiftedRight] is negative, we need to add it to the length of the candles list
    final labelCount = (widget.candles.length - FinChartDefaults.shiftedRight) ~/ candlesPerLabel;
    return ListView.builder(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom + 20,
      ),
      controller: _scrollController,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: labelCount,
      scrollDirection: Axis.horizontal,
      itemExtent: labelExtent,
      reverse: true,
      itemBuilder: (context, index) {
        final labelTime = _calculateLabelTime(candlesPerLabel, index, labelInterval);
        return _buildTimeLabel(
          labelTime,
          showTimeOfDay: candleInterval < const Duration(days: 1),
        );
      },
    );
  }

  Widget _buildTimeLabel(DateTime? labelTime, {bool showTimeOfDay = true}) {
    if (labelTime == null) return const SizedBox();
    return Column(
      children: [
        Expanded(
          child: Container(
            width: 1,
            color: AppColors.divider,
          ),
        ),
        Text(
          formatTime(labelTime, showTimeOfDay: showTimeOfDay),
          style: AppTypography.axisLabel,
        ),
      ],
    );
  }
}
