import 'package:fin_app/data/events/symbol_ticker_event.dart';
import 'package:fin_app/data/models/symbol.dart';
import 'package:fin_app/data/repositories/base_repository.dart';
import 'package:fin_app/data/sources/networking/services/market_api_service.dart';
import 'package:fin_app/data/sources/streaming/streaming_service.dart';
import 'package:fin_app/shared/extensions/interable_ext.dart';

class MarketRepository extends BaseRepository {
  MarketRepository(MarketApiService apiService, StreamingService streamingService)
      : _apiService = apiService,
        _streamingService = streamingService;

  final MarketApiService _apiService;
  final StreamingService _streamingService;

  /// Fetches the list of market symbols along with their latest snapshot data.
  Future<List<MarketSymbol>> fetchSymbols() async {
    final exchangeInfo = await _fetchExchangeInfo();
    final snapshots = await safeCallApi(request: _apiService.fetchTicker24Hours());

    // If snapshot data is available, update the corresponding market symbols
    if (snapshots != null) {
      for (final snapshot in snapshots) {
        exchangeInfo[snapshot.symbol]?.updateSnapshot(snapshot);
      }
    }
    return exchangeInfo.values.toList();
  }

  /// Fetches exchange information and filters only USDT trading pairs.
  Future<Map<String, MarketSymbol>> _fetchExchangeInfo() async {
    final allSymbols = await safeCallApi(request: _apiService.fetchExchangeInfo());

    // If data is available, filter symbols that have USDT as the quote asset
    if (allSymbols != null) {
      final usdtSymbols = allSymbols.where((e) => e.quoteAsset.toUpperCase() == 'USDT').toList();
      return usdtSymbols.associateBy(keySelector: (symbol) => symbol.id);
    }
    return {};
  }

  Stream<SymbolMiniTickerEvent> get symbolMiniTickerStream => _streamingService.symbolMiniTickerStream;

  Future<bool> subscribeSymbolMiniTickerStream({required List<MarketSymbol> symbols}) {
    return _streamingService.subscribeSymbolMiniTickerStream(symbols: symbols.map((s) => s.id).toList());
  }

  Future<bool> unsubscribeSymbolMiniTickerStream({required List<MarketSymbol> symbols}) {
    return _streamingService.unsubscribeSymbolMiniTickerStream(symbols: symbols.map((s) => s.id).toList());
  }
}
