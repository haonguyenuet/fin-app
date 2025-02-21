import 'package:fin_app/data/models/time_interval.dart';
import 'package:fin_app/presentation/symbol_detail/symbol_detail_viewmodel.dart';
import 'package:fin_app/shared/consts/app_color.dart';
import 'package:fin_app/shared/consts/app_typo.dart';
import 'package:fin_app/shared/widgets/bottom_sheet_handle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class IntervalPicker extends ConsumerWidget {
  const IntervalPicker({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentInterval = ref.watch(symbolDetailVMProvider.select((value) => value.currentInterval));
    final allIntervals = ref.watch(symbolDetailVMProvider.select((value) => value.intervals)) ?? [];
    final pinnedIntervals = allIntervals.where((interval) => interval.isPinned).toList();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        spacing: 8,
        children: [
          ...pinnedIntervals.map(
            (interval) => IntervalButton(
              interval: interval,
              isSelected: interval == currentInterval,
              onPressed: () => ref.read(symbolDetailVMProvider.notifier).onIntervalChanged(interval),
            ),
          ),
          MoreIntervalButton(
            currentInterval: currentInterval,
            onPressed: () => showModalBottomSheet(
              context: context,
              builder: (context) => const SelectIntervalSheet(),
            ),
          ),
        ],
      ),
    );
  }
}

class IntervalButton extends StatelessWidget {
  const IntervalButton({
    super.key,
    required this.interval,
    required this.isSelected,
    required this.onPressed,
    this.width,
    this.height,
  });

  final TimeInterval interval;
  final VoidCallback onPressed;
  final bool isSelected;
  final double? width;
  final double? height;

  static ButtonStyle getStyle({required bool isSelected, double borderRadius = 4, EdgeInsetsGeometry? padding}) {
    return TextButton.styleFrom(
      padding: padding ?? EdgeInsets.zero,
      backgroundColor: isSelected ? AppColors.primary : AppColors.secondary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius)),
    );
  }

  static TextStyle getTextStyle({required bool isSelected}) {
    return AppTypography.button.copyWith(
      color: isSelected ? AppColors.onPrimary : AppColors.onSecondary,
      fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? 50,
      height: height ?? 28,
      child: TextButton(
        onPressed: onPressed,
        style: getStyle(isSelected: isSelected),
        child: Text(interval.value, style: getTextStyle(isSelected: isSelected)),
      ),
    );
  }
}

class MoreIntervalButton extends StatelessWidget {
  const MoreIntervalButton({
    super.key,
    required this.currentInterval,
    required this.onPressed,
  });

  final TimeInterval? currentInterval;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final hasCurrentInterval = currentInterval?.isPinned == false;
    return SizedBox(
      height: 30,
      child: TextButton(
        onPressed: onPressed,
        style: IntervalButton.getStyle(
          isSelected: hasCurrentInterval,
          padding: const EdgeInsets.symmetric(horizontal: 12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              hasCurrentInterval ? currentInterval!.value : 'More',
              style: IntervalButton.getTextStyle(isSelected: hasCurrentInterval),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down,
              size: 20,
              color: hasCurrentInterval ? AppColors.onPrimary : AppColors.onSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

class SelectIntervalSheet extends ConsumerWidget {
  const SelectIntervalSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentInterval = ref.watch(symbolDetailVMProvider.select((value) => value.currentInterval));
    final intervals = ref.watch(symbolDetailVMProvider.select((value) => value.intervals)) ?? [];

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const BottomSheetHandle(),
          const Text('Select Interval', style: AppTypography.title),
          _buildIntervalGrid(context, ref, intervals, currentInterval),
        ],
      ),
    );
  }

  Widget _buildIntervalGrid(
    BuildContext context,
    WidgetRef ref,
    List<TimeInterval> intervals,
    TimeInterval? currentInterval,
  ) {
    final spacing = 8.0;
    final padding = 16.0;
    final itemWidth = (MediaQuery.of(context).size.width - spacing * 2 - padding * 2) / 3;
    return Padding(
      padding: EdgeInsets.all(padding),
      child: Wrap(
        spacing: spacing,
        runSpacing: spacing,
        children: intervals
            .map((interval) => IntervalButton(
                  width: itemWidth,
                  height: 40,
                  interval: interval,
                  isSelected: interval == currentInterval,
                  onPressed: () {
                    ref.read(symbolDetailVMProvider.notifier).onIntervalChanged(interval);
                    Navigator.pop(context);
                  },
                ))
            .toList(),
      ),
    );
  }
}
