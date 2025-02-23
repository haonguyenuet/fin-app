import 'dart:async';
import 'dart:math';

import 'package:fin_app/presentation/market/market_viewmodel.dart';
import 'package:fin_app/presentation/market/widgets/market_symbol_row.dart';
import 'package:fin_app/shared/extensions/global_key_ext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MarketScreen extends ConsumerStatefulWidget {
  const MarketScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MarketScreenState();
}

class _MarketScreenState extends ConsumerState<MarketScreen> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _viewportKey = GlobalKey();

  Set<String> _visibleSymbolIds = {};
  double _lastOffset = 0.0;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(marketVMProvider.notifier).init();
      _listenForFirstTimeSymbolsLoad();
    });
  }

  void _onScroll() {
    _debounceTimer?.cancel();

    /// Skip if the scroll offset is not changed significantly
    if ((_scrollController.offset - _lastOffset).abs() < 30) return;

    _debounceTimer = Timer(Duration(milliseconds: 300), () {
      _lastOffset = _scrollController.offset;
      _updateAndTrackVisibleSymbols();
    });
  }

  void _listenForFirstTimeSymbolsLoad() {
    late final ProviderSubscription subscription;
    subscription = ref.listenManual(
      marketVMProvider.select((state) => state.symbolIds),
      (previous, current) {
        if ((previous == null || previous.isEmpty) && current.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) => _updateAndTrackVisibleSymbols());
          subscription.close();
        }
      },
    );
  }

  void _updateAndTrackVisibleSymbols() {
    final symbolIds = ref.read(marketVMProvider.select((state) => state.symbolIds));

    final viewportSymbolRows = (_viewportKey.height / MarketSymbolRow.height).ceil();
    final firstIndex = max(_scrollController.offset ~/ MarketSymbolRow.height, 0);
    final lastIndex = min(firstIndex + viewportSymbolRows, symbolIds.length - 1);
    final newVisibleSymbolIds = symbolIds.toList().sublist(firstIndex, lastIndex + 1).toSet();

    if (newVisibleSymbolIds.difference(_visibleSymbolIds).isNotEmpty) {
      _visibleSymbolIds = newVisibleSymbolIds;
      ref.read(marketVMProvider.notifier).trackPriceOf(_visibleSymbolIds);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final symbolIds = ref.watch(marketVMProvider.select((state) => state.symbolIds)).toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Market')),
      body: symbolIds.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              key: _viewportKey,
              controller: _scrollController,
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
