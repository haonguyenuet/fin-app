import 'package:fin_app/data/models/time_interval.dart';
import 'package:fin_app/presentation/home/home_viewmodel.dart';
import 'package:fin_app/shared/widgets/bottom_sheet_handle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class IntervalPicker extends ConsumerWidget {
  const IntervalPicker({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedInterval = ref.watch(homeViewmodelProvider.select((value) => value.selectedInterval));
    final allIntervals = ref.watch(homeViewmodelProvider.select((value) => value.intervals)) ?? [];
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
              isSelected: interval == selectedInterval,
              onPressed: () => ref.read(homeViewmodelProvider.notifier).onIntervalSelected(interval),
            ),
          ),
          MoreIntervalButton(
            selectedInterval: selectedInterval,
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
      backgroundColor: isSelected ? Colors.black87 : Colors.grey.shade100,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius)),
    );
  }

  static TextStyle getTextStyle({required bool isSelected}) {
    return TextStyle(
      fontSize: 14,
      color: isSelected ? Colors.white : Colors.grey.shade600,
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
    required this.selectedInterval,
    required this.onPressed,
  });

  final TimeInterval? selectedInterval;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final hasSelectedInterval = selectedInterval != null && !selectedInterval!.isPinned;
    return SizedBox(
      height: 30,
      child: TextButton(
        onPressed: onPressed,
        style: IntervalButton.getStyle(
          isSelected: hasSelectedInterval,
          padding: const EdgeInsets.symmetric(horizontal: 12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              hasSelectedInterval ? selectedInterval!.value : 'More',
              style: IntervalButton.getTextStyle(isSelected: hasSelectedInterval),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down,
              size: 20,
              color: hasSelectedInterval ? Colors.white : Colors.grey.shade600,
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
    final selectedInterval = ref.watch(homeViewmodelProvider.select((value) => value.selectedInterval));
    final intervals = ref.watch(homeViewmodelProvider.select((value) => value.intervals)) ?? [];

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const BottomSheetHandle(),
          const Text(
            'Select Interval',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          _buildIntervalGrid(context, ref, intervals, selectedInterval),
        ],
      ),
    );
  }

  Widget _buildIntervalGrid(
    BuildContext context,
    WidgetRef ref,
    List<TimeInterval> intervals,
    TimeInterval? selectedInterval,
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
                  isSelected: interval == selectedInterval,
                  onPressed: () {
                    ref.read(homeViewmodelProvider.notifier).onIntervalSelected(interval);
                    Navigator.pop(context);
                  },
                ))
            .toList(),
      ),
    );
  }
}
