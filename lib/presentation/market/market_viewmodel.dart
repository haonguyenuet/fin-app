import 'dart:async';

import 'package:fin_app/data/data_providers.dart';
import 'package:fin_app/data/events/symbol_ticker_event.dart';
import 'package:fin_app/data/models/symbol.dart';
import 'package:fin_app/data/repositories/market_repository.dart';
import 'package:fin_app/shared/extensions/interable_ext.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final marketVMProvider = StateNotifierProvider<MarketViewmodel, MarketState>((ref) {
  final marketRepository = ref.watch(marketRepositoryProvider);
  return MarketViewmodel(marketRepository);
});

class MarketViewmodel extends StateNotifier<MarketState> {
  MarketViewmodel(this._marketRepository) : super(MarketState());

  final MarketRepository _marketRepository;

  StreamSubscription? _miniTickerStreamSubscription;

  void init() async {
    _fetchSymbols();

    /// Websocket streams handling
    _miniTickerStreamSubscription = _marketRepository.symbolMiniTickerStream.listen(_onMiniTickerEvent);
  }

  Future<void> _fetchSymbols() async {
    final symbols = await _marketRepository.fetchSymbols();
    symbols.sort((a, b) {
      final volumeA = a.snapshot?.quoteVolume ?? 0;
      final volumeB = b.snapshot?.quoteVolume ?? 0;
      return volumeB.compareTo(volumeA);
    });

    state = state.copyWith(
      symbolIds: symbols.map((symbol) => symbol.id).toList(),
      symbolMap: symbols.associateBy(keySelector: (symbol) => symbol.id),
    );
  }

  void _onMiniTickerEvent(SymbolMiniTickerEvent event) {
    final updatedSymbolMap = Map.of(state.symbolMap);
    updatedSymbolMap[event.symbol]?.updateSnapshot(event.snapshot);
    state = state.copyWith(symbolMap: updatedSymbolMap);
  }

  @override
  void dispose() {
    _miniTickerStreamSubscription?.cancel();
    super.dispose();
  }
}

class MarketState {
  MarketState({
    this.symbolIds = const [],
    this.symbolMap = const {},
  });

  final List<String> symbolIds;
  final Map<String, MarketSymbol> symbolMap;

  MarketState copyWith({
    List<String>? symbolIds,
    Map<String, MarketSymbol>? symbolMap,
  }) {
    return MarketState(
      symbolMap: symbolMap ?? this.symbolMap,
      symbolIds: symbolIds ?? this.symbolIds,
    );
  }
}
