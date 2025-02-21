import 'package:fin_app/data/models/symbol.dart';
import 'package:fin_app/data/sources/networking/dio_client.dart';

class MarketApiService {
  MarketApiService(DioClient dioClient) : _dioClient = dioClient;

  final DioClient _dioClient;

  Future<List<SymbolSnapshot>> fetchTicker24Hours() async {
    final response = await _dioClient.get<List<dynamic>>("/ticker/24hr");
    if (response != null) {
      return response.map((e) => SymbolSnapshot.fromMap(e)).toList();
    }
    return [];
  }

  Future<List<MarketSymbol>> fetchExchangeInfo() async {
    final response = await _dioClient.get<Map<String, dynamic>>("/exchangeInfo");
    if (response != null && response.containsKey('symbols')) {
      return (response["symbols"] as List).map((e) => MarketSymbol.fromMap(e)).toList();
    }
    return [];
  }
}
