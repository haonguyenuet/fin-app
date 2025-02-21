import 'package:fin_app/data/models/symbol.dart';
import 'package:fin_app/data/repositories/base_repository.dart';
import 'package:fin_app/data/sources/networking/http_service.dart';
import 'package:flutter/foundation.dart';

class MarketRepository extends BaseRepository {
  MarketRepository({required HttpService httpService}) : _httpService = httpService;

  final HttpService _httpService;

  Future<List<MarketSymbol>> fetchSymbols() async {
    final response = await safeCallApi(
      () => _httpService.get<Map<String, dynamic>>("/exchangeInfo"),
    );
    if (response != null && response.containsKey('symbols')) {
      return await compute(parseMarketSymbols, response['symbols'] as List<dynamic>);
    }
    return [];
  }
}
