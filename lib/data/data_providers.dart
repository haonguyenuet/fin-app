import 'package:fin_app/data/repositories/candlestick_repository.dart';
import 'package:fin_app/data/repositories/market_repository.dart';
import 'package:fin_app/data/sources/networking/dio_client.dart';
import 'package:fin_app/data/sources/networking/services/candlestick_api_service.dart';
import 'package:fin_app/data/sources/networking/services/market_api_service.dart';
import 'package:fin_app/data/sources/streaming/streaming_service.dart';
import 'package:fin_app/data/sources/streaming/websocket_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// =============================== SERVICES ===============================

final dioClientProvider = Provider<DioClient>(
  (ref) => DioClient(baseUrl: 'https://api.binance.com/api/v3'),
);

final marketApiService = Provider<MarketApiService>(
  (ref) => MarketApiService(ref.read(dioClientProvider)),
);

final candlestickApiService = Provider<CandlestickApiService>(
  (ref) => CandlestickApiService(ref.read(dioClientProvider)),
);

final streamingServiceProvider = Provider<StreamingService>((ref) {
  final wsService = WebsocketService(wsUrl: 'wss://stream.binance.com:9443/ws');
  wsService.connect();
  ref.onDispose(() => wsService.close());
  return wsService;
});

/// =============================== REPOSITORIES ===============================

final marketRepository = Provider(
  (ref) => MarketRepository(
    ref.read(marketApiService),
    ref.read(streamingServiceProvider),
  ),
);

final candlestickRepository = Provider(
  (ref) => CandlestickRepository(
    ref.read(candlestickApiService),
    ref.read(streamingServiceProvider),
  ),
);
