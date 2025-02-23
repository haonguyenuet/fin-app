import 'dart:async';

import 'package:fin_app/data/data_providers.dart';
import 'package:fin_app/data/events/symbol_ticker_event.dart';
import 'package:fin_app/data/models/symbol.dart';
import 'package:fin_app/data/repositories/market_repository.dart';
import 'package:fin_app/shared/extensions/interable_ext.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final marketVMProvider = StateNotifierProvider.autoDispose<MarketViewmodel, MarketState>((ref) {
  final marketRepository = ref.watch(marketRepositoryProvider);
  return MarketViewmodel(marketRepository);
});

class MarketViewmodel extends StateNotifier<MarketState> {
  MarketViewmodel(this._marketRepository) : super(MarketState());

  final MarketRepository _marketRepository;

  StreamSubscription? _miniTickerStreamSubscription;
  Set<String> _currentSubscribedSymbolIds = {};

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
      symbolIds: symbols.map((symbol) => symbol.id).toSet(),
      symbolMap: symbols.associateBy(keySelector: (symbol) => symbol.id),
    );
  }

  void _onMiniTickerEvent(SymbolMiniTickerEvent event) {
    final symbol = state.symbolMap[event.symbol];
    if (symbol != null && symbol.snapshot?.lastPrice != event.snapshot.lastPrice) {
      state = state.copyWith(
        symbolMap: {
          ...state.symbolMap,
          symbol.id: symbol.copyWith(snapshot: event.snapshot),
        },
      );
    }
  }

  void trackPriceOf(Set<String> symbolIds) async {
    /// Unsubscribe from symbols that are not in the new list
    final symbolIdsToUnsubscribe = _currentSubscribedSymbolIds.where((s) => !symbolIds.contains(s)).toList();

    /// Subscribe to symbols that are not in the current list, overlapping symbols will be ignored
    final symbolIdsToSubscribe = symbolIds.where((s) => !_currentSubscribedSymbolIds.contains(s)).toList();

    if (symbolIdsToUnsubscribe.isNotEmpty) {
      _marketRepository.unsubscribeSymbolMiniTickerStream(symbols: symbolIdsToUnsubscribe);
    }

    if (symbolIdsToSubscribe.isNotEmpty) {
      final isSuccess = await _marketRepository.subscribeSymbolMiniTickerStream(symbols: symbolIdsToSubscribe);
      if (isSuccess) {
        _currentSubscribedSymbolIds = symbolIds;
      }
    }
  }

  @override
  void dispose() {
    _miniTickerStreamSubscription?.cancel();
    super.dispose();
  }
}

class MarketState {
  MarketState({
    this.symbolIds = const {},
    this.symbolMap = const {},
  });

  final Set<String> symbolIds;
  final Map<String, MarketSymbol> symbolMap;

  MarketState copyWith({
    Set<String>? symbolIds,
    Map<String, MarketSymbol>? symbolMap,
  }) {
    return MarketState(
      symbolMap: symbolMap ?? this.symbolMap,
      symbolIds: symbolIds ?? this.symbolIds,
    );
  }
}
