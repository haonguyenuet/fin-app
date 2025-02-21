import 'package:fin_app/data/repositories/candlestick_repository.dart';
import 'package:fin_app/data/repositories/market_repository.dart';
import 'package:fin_app/data/sources/networking/dio_http_service.dart';
import 'package:fin_app/data/sources/networking/http_service.dart';
import 'package:fin_app/data/sources/streaming/streaming_service.dart';
import 'package:fin_app/data/sources/streaming/websocket_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// =============================== SERVICES ===============================

final httpServiceProvider = Provider<HttpService>(
  (ref) => DioHttpService(baseUrl: 'https://api.binance.com/api/v3'),
);

final streamingServiceProvider = Provider<StreamingService>(
  (ref) {
    final wsService = WebsocketService(wsUrl: 'wss://stream.binance.com:9443/ws');
    wsService.connect();
    ref.onDispose(() => wsService.disconnect());
    return wsService;
  },
);

/// =============================== REPOSITORIES ===============================

final marketRepository = Provider(
  (ref) => MarketRepository(
    httpService: ref.read(httpServiceProvider),
  ),
);

final candlestickRepository = Provider(
  (ref) => CandlestickRepository(
    httpService: ref.read(httpServiceProvider),
    streamingService: ref.read(streamingServiceProvider),
  ),
);
