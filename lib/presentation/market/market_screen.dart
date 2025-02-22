import 'package:fin_app/presentation/market/market_viewmodel.dart';
import 'package:fin_app/presentation/market/widgets/market_symbol_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MarketScreen extends ConsumerStatefulWidget {
  const MarketScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MarketScreenState();
}

class _MarketScreenState extends ConsumerState<MarketScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(marketVMProvider.notifier).init();
    });
  }

  @override
  Widget build(BuildContext context) {
    final symbolIds = ref.watch(marketVMProvider.select((state) => state.symbolIds));

    return Scaffold(
      appBar: AppBar(title: const Text('Market')),
      body: symbolIds.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemExtent: MarketSymbolRow.height,
              itemCount: symbolIds.length,
              itemBuilder: (context, index) {
                final symbolId = symbolIds[index];
                return MarketSymbolRow(symbolId: symbolId);
              },
            ),
    );
  }
}
