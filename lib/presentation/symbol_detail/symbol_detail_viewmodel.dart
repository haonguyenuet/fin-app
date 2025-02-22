import 'dart:async';

import 'package:fin_app/data/data_providers.dart';
import 'package:fin_app/data/models/candle.dart';
import 'package:fin_app/data/events/candlestick_event.dart';
import 'package:fin_app/data/models/symbol.dart';
import 'package:fin_app/data/models/time_interval.dart';
import 'package:fin_app/data/repositories/candlestick_repository.dart';
import 'package:fin_app/data/repositories/market_repository.dart';
import 'package:riverpod/riverpod.dart';

final symbolDetailVMProvider = StateNotifierProvider.autoDispose<SymbolDetailViewModel, SymbolDetailState>((ref) {
  return SymbolDetailViewModel(
    ref.read(marketRepositoryProvider),
    ref.read(candlestickRepositoryProvider),
  );
});

class SymbolDetailViewModel extends StateNotifier<SymbolDetailState> {
  SymbolDetailViewModel(this._marketRepository, this._candlestickRepository) : super(SymbolDetailState());

  final MarketRepository _marketRepository;
  final CandlestickRepository _candlestickRepository;

  StreamSubscription? _candlestickStreamSubscription;

  void init() async {
    await _fetchSymbols();
    await _fetchIntervals();
    _fetchNewCandles();

    /// Websocket streams handling
    _candlestickStreamSubscription = _candlestickRepository.candlestickStream.listen(_onCandlestickEvent);
  }

  Future<void> _fetchSymbols() async {
    final symbols = await _marketRepository.fetchSymbols();
    state = state.copyWith(
      symbols: symbols,
      currentSymbol: symbols.first,
    );
  }

  Future<void> _fetchIntervals() async {
    final intervals = await _candlestickRepository.fetchIntervals();
    state = state.copyWith(
      intervals: intervals,
      currentInterval: intervals.where((interval) => interval.isPinned).first,
    );
  }

  Future<void> _fetchNewCandles() async {
    final symbol = state.currentSymbol;
    final interval = state.currentInterval;
    if (symbol == null || interval == null) return;

    _candlestickRepository.unsubscribeCandlestickStream(symbol: symbol.id, interval: interval);
    final candles = await _candlestickRepository.fetchCandles(symbol: symbol.id, interval: interval);
    if (candles.isNotEmpty) {
      state = state.copyWith(candles: candles);
      _candlestickRepository.subscribeCandlestickStream(symbol: symbol.id, interval: interval);
    }
  }

  void _onCandlestickEvent(CandlestickEvent event) {
    final candles = List.of(state.candles ?? <Candle>[]);
    if (candles.isEmpty) return;

    final incommingCandle = event.candle;
    final latestCandle = candles.first;
    // Check if incoming candle is an update on current latest candle, or a new one
    if (latestCandle.date == incommingCandle.date && latestCandle.open == incommingCandle.open) {
      candles[0] = incommingCandle;
      state = state.copyWith(candles: candles);
    }
    // check if incoming new candle is next candle so the difrence
    // between times must be the same as last existing 2 candles
    else if (incommingCandle.date.difference(latestCandle.date) == latestCandle.date.difference(candles[1].date)) {
      candles.insert(0, incommingCandle);
      state = state.copyWith(candles: candles);
    }
  }

  void onSymbolChanged(MarketSymbol symbol) {
    state = state.copyWith(currentSymbol: symbol);
    _fetchNewCandles();
  }

  void onIntervalChanged(TimeInterval interval) {
    state = state.copyWith(currentInterval: interval);
    _fetchNewCandles();
  }

  Future<void> fetchMoreCandles() async {
    final candles = state.candles;
    final symbol = state.currentSymbol;
    final interval = state.currentInterval;
    if (candles == null || candles.isEmpty || symbol == null || interval == null) return;

    final newCandles = await _candlestickRepository.fetchCandles(
      symbol: symbol.id,
      interval: interval,
      endTime: candles.last.date.millisecondsSinceEpoch + 1,
    );

    if (newCandles.length > 1) {
      state = state.copyWith(candles: [...candles, ...newCandles]);
    }
  }

  @override
  void dispose() {
    _candlestickStreamSubscription?.cancel();
    super.dispose();
  }
}

class SymbolDetailState {
  SymbolDetailState({
    this.symbols,
    this.intervals,
    this.candles,
    this.currentInterval,
    this.currentSymbol,
  });

  final List<MarketSymbol>? symbols;
  final List<TimeInterval>? intervals;
  final List<Candle>? candles;
  final TimeInterval? currentInterval;
  final MarketSymbol? currentSymbol;

  SymbolDetailState copyWith({
    List<MarketSymbol>? symbols,
    List<TimeInterval>? intervals,
    List<Candle>? candles,
    TimeInterval? currentInterval,
    MarketSymbol? currentSymbol,
  }) {
    return SymbolDetailState(
      symbols: symbols ?? this.symbols,
      intervals: intervals ?? this.intervals,
      candles: candles ?? this.candles,
      currentInterval: currentInterval ?? this.currentInterval,
      currentSymbol: currentSymbol ?? this.currentSymbol,
    );
  }
}
