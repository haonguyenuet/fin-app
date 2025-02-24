import 'package:market_stream/data/repositories/candlestick_repository.dart';
import 'package:market_stream/data/repositories/market_repository.dart';
import 'package:market_stream/data/sources/networking/dio_client.dart';
import 'package:market_stream/data/sources/networking/services/candlestick_api_service.dart';
import 'package:market_stream/data/sources/networking/services/market_api_service.dart';
import 'package:market_stream/data/sources/streaming/streaming_service.dart';
import 'package:market_stream/data/sources/streaming/websocket_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// =============================== SERVICES ===============================

final dioClientProvider = Provider<DioClient>(
  (ref) => DioClient(baseUrl: 'https://api.binance.com/api/v3'),
);

final marketApiServiceProvider = Provider<MarketApiService>(
  (ref) => MarketApiService(ref.read(dioClientProvider)),
);

final candlestickApiServiceProvider = Provider<CandlestickApiService>(
  (ref) => CandlestickApiService(ref.read(dioClientProvider)),
);

final streamingServiceProvider = Provider<StreamingService>((ref) {
  final wsService = WebsocketService(wsUrl: 'wss://stream.binance.com:9443/ws');
  wsService.connect();
  ref.onDispose(() => wsService.close());
  return wsService;
});

/// =============================== REPOSITORIES ===============================

final marketRepositoryProvider = Provider(
  (ref) => MarketRepository(
    ref.read(marketApiServiceProvider),
    ref.read(streamingServiceProvider),
  ),
);

final candlestickRepositoryProvider = Provider(
  (ref) => CandlestickRepository(
    ref.read(candlestickApiServiceProvider),
    ref.read(streamingServiceProvider),
  ),
);
