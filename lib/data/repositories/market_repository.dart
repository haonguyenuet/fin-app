import 'package:fin_app/data/models/symbol.dart';
import 'package:fin_app/data/repositories/base_repository.dart';
import 'package:fin_app/data/sources/networking/services/market_api_service.dart';

class MarketRepository extends BaseRepository {
  MarketRepository(MarketApiService httpService) : _apiService = httpService;

  final MarketApiService _apiService;

  Future<List<MarketSymbol>> fetchSymbols() async {
    final exchangeInfo = await _fetchExchangeInfo();
    final symbolSnapshots = await safeCallApi(request: _apiService.fetchTicker24Hours());
    if (symbolSnapshots != null) {
      for (final snapshot in symbolSnapshots) {
        exchangeInfo[snapshot.symbol]?.updateSnapshot(snapshot);
      }
    }
    return exchangeInfo.values.toList();
  }

  Future<Map<String, MarketSymbol>> _fetchExchangeInfo() async {
    final allSymbols = await safeCallApi(request: _apiService.fetchExchangeInfo());
    if (allSymbols != null) {
      final usdtSymbols = allSymbols.where((e) => e.quoteAsset.toUpperCase() == 'USDT').toList();
      return {for (final symbol in usdtSymbols) symbol.value: symbol};
    }
    return {};
  }
}
