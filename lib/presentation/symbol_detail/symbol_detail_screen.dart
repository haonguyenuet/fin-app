import 'package:market_stream/presentation/symbol_detail/widgets/fin_chart/fin_chart.dart';
import 'package:market_stream/presentation/symbol_detail/symbol_detail_viewmodel.dart';
import 'package:market_stream/presentation/symbol_detail/widgets/interval_picker.dart';
import 'package:market_stream/presentation/symbol_detail/widgets/symbol_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SymbolDetailScreen extends ConsumerStatefulWidget {
  const SymbolDetailScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SymbolDetailState();
}

class _SymbolDetailState extends ConsumerState<SymbolDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(symbolDetailVMProvider.notifier).init();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(symbolDetailVMProvider);
    final candles = state.candles;
    final currentSymbol = state.currentSymbol;
    final currentInterval = state.currentInterval;
    return Scaffold(
      appBar: AppBar(title: const Text('FinApp')),
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
                    key: Key(currentSymbol!.id + currentInterval!.value),
                    candles: candles,
                    onFetchMoreCandles: () async {
                      await ref.read(symbolDetailVMProvider.notifier).fetchMoreCandles();
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
