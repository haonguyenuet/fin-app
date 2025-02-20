import 'dart:async';

import 'package:fin_chart/data/models/candle.dart';
import 'package:fin_chart/data/models/candlestick_event.dart';
import 'package:fin_chart/data/models/symbol.dart';
import 'package:fin_chart/data/models/time_interval.dart';
import 'package:fin_chart/data/repositories/crypto_repository.dart';
import 'package:riverpod/riverpod.dart';

final homeViewmodelProvider = StateNotifierProvider.autoDispose<HomeViewmodel, HomeState>((ref) {
  final cryptoRepository = ref.watch(cryptoRepositoryProvider);
  return HomeViewmodel(cryptoRepository);
});

class HomeViewmodel extends StateNotifier<HomeState> {
  HomeViewmodel(this._cryptoRepository) : super(HomeState());

  final CryptoRepository _cryptoRepository;

  void init() async {
    await _fetchSymbols();
    await _fetchIntervals();
    _fetchNewCandles();

    /// Websocket streams handling
    _cryptoRepository.connectWebsocket();
    _cryptoRepository.candlestickStream.listen(_onCandlestickEvent);
  }

  Future<void> _fetchSymbols() async {
    final symbols = await _cryptoRepository.fetchSymbols();
    state = state.copyWith(
      symbols: symbols,
      selectedSymbol: symbols.first,
    );
  }

  Future<void> _fetchIntervals() async {
    final intervals = await _cryptoRepository.fetchIntervals();
    state = state.copyWith(
      intervals: intervals,
      selectedInterval: intervals.where((interval) => interval.isPinned).first,
    );
  }

  Future<void> _fetchNewCandles() async {
    final symbol = state.selectedSymbol;
    final interval = state.selectedInterval;
    if (symbol == null || interval == null) return;

    _cryptoRepository.unsubscribeCandlestickStream(symbol: symbol.value, interval: interval);
    final candles = await _cryptoRepository.fetchCandles(symbol: symbol.value, interval: interval);
    if (candles.isNotEmpty) {
      state = state.copyWith(candles: candles);
      _cryptoRepository.subscribeCandlestickStream(symbol: symbol.value, interval: interval);
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

  void onSymbolSelected(CryptoSymbol symbol) {
    state = state.copyWith(selectedSymbol: symbol);
    _fetchNewCandles();
  }

  void onIntervalSelected(TimeInterval interval) {
    state = state.copyWith(selectedInterval: interval);
    _fetchNewCandles();
  }

  Future<void> fetchMoreCandles() async {
    final candles = state.candles;
    final symbol = state.selectedSymbol;
    final interval = state.selectedInterval;
    if (candles == null || candles.isEmpty || symbol == null || interval == null) return;

    final newCandles = await _cryptoRepository.fetchCandles(
      symbol: symbol.value,
      interval: interval,
      endTime: candles.last.date.millisecondsSinceEpoch + 1,
    );

    if (newCandles.length > 1) {
      state = state.copyWith(candles: [...candles, ...newCandles]);
    }
  }

  @override
  void dispose() {
    super.dispose();
    _cryptoRepository.dispose();
  }
}

class HomeState {
  HomeState({
    this.symbols,
    this.intervals,
    this.candles,
    this.selectedInterval,
    this.selectedSymbol,
  });

  final List<CryptoSymbol>? symbols;
  final List<TimeInterval>? intervals;
  final List<Candle>? candles;
  final TimeInterval? selectedInterval;
  final CryptoSymbol? selectedSymbol;

  HomeState copyWith({
    List<CryptoSymbol>? symbols,
    List<TimeInterval>? intervals,
    List<Candle>? candles,
    TimeInterval? selectedInterval,
    CryptoSymbol? selectedSymbol,
  }) {
    return HomeState(
      symbols: symbols ?? this.symbols,
      intervals: intervals ?? this.intervals,
      candles: candles ?? this.candles,
      selectedInterval: selectedInterval ?? this.selectedInterval,
      selectedSymbol: selectedSymbol ?? this.selectedSymbol,
    );
  }
}
