import 'package:fin_app/presentation/home/widgets/fin_chart/fin_chart.dart';
import 'package:fin_app/presentation/home/home_viewmodel.dart';
import 'package:fin_app/presentation/home/widgets/interval_picker.dart';
import 'package:fin_app/presentation/home/widgets/symbol_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(homeViewmodelProvider.notifier).init();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(homeViewmodelProvider);
    final candles = state.candles;
    final currentSymbol = state.selectedSymbol;
    final selectedInterval = state.selectedInterval;

    return Scaffold(
      appBar: AppBar(title: const Text('FinChart')),
      body: Builder(
        builder: (context) {
          if (candles == null) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (candles.isEmpty) {
            return const Center(
              child: Text('No data'),
            );
          }

          return SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SymbolPicker(),
                IntervalPicker(),
                SizedBox(height: 40),
                Expanded(
                  child: FinChart(
                    key: Key(currentSymbol!.value + selectedInterval!.value),
                    candles: candles,
                    onFetchMoreCandles: () async {
                      await ref.read(homeViewmodelProvider.notifier).fetchMoreCandles();
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
