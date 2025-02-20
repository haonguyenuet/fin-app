import 'dart:async';
import 'dart:convert';

import 'package:fin_app/data/models/candle.dart';
import 'package:fin_app/data/models/candlestick_event.dart';
import 'package:fin_app/data/models/symbol.dart';
import 'package:fin_app/data/models/time_interval.dart';
import 'package:fin_app/data/requests/candlestick_stream_request.dart';
import 'package:fin_app/data/requests/fetch_candles_request.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:riverpod/riverpod.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

final cryptoRepositoryProvider = Provider<CryptoRepository>((ref) => BinancesCryptoRepository());

/// An abstract class that defines the methods that a crypto repository should implement.
abstract class CryptoRepository {
  Stream<CandlestickEvent> get candlestickStream;

  void connectWebsocket();

  Future<List<CryptoSymbol>> fetchSymbols();

  Future<List<TimeInterval>> fetchIntervals();

  Future<List<Candle>> fetchCandles({required String symbol, required TimeInterval interval, int? endTime});

  void subscribeCandlestickStream({required String symbol, required TimeInterval interval});

  void unsubscribeCandlestickStream({required String symbol, required TimeInterval interval});

  void dispose();
}

/// A repository that fetches data from Binance's API.
///
/// https://developers.binance.com/docs
class BinancesCryptoRepository implements CryptoRepository {
  static String wsUrl = 'wss://stream.binance.com:9443/ws';
  static String apiUrl = 'https://api.binance.com/api/v3';

  WebSocketChannel? _channel;
  int _messageId = 1;

  final _candlestickStreamController = StreamController<CandlestickEvent>.broadcast();

  @override
  Stream<CandlestickEvent> get candlestickStream => _candlestickStreamController.stream;

  @override
  Future<List<CryptoSymbol>> fetchSymbols() async {
    try {
      final uri = Uri.parse("$apiUrl/exchangeInfo");
      final res = await http.get(uri);
      return compute(parseSymbols, res.body);
    } catch (e) {
      print("Error: $e");
      return [];
    }
  }

  @override
  Future<List<TimeInterval>> fetchIntervals() async {
    return TimeInterval.values;
  }

  @override
  Future<List<Candle>> fetchCandles({
    required String symbol,
    required TimeInterval interval,
    int? endTime,
  }) async {
    try {
      final request = FetchCandlesRequest(symbol: symbol, interval: interval, endTime: endTime);
      final uri = Uri.parse("$apiUrl/klines?${request.toQueryString()}");
      final res = await http.get(uri);
      return compute(parseCandles, res.body);
    } catch (e) {
      print("Error: $e");
      return [];
    }
  }

  @override
  void connectWebsocket() {
    if (_channel != null) return;

    _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
    _channel?.stream.listen(
      (event) {
        if (event is! String) return;
        final map = jsonDecode(event) as Map<String, dynamic>;

        if (map['e'] == "kline") {
          _candlestickStreamController.sink.add(CandlestickEvent.fromMap(map));
        }
      },
      onError: (error) {
        print("Error: $error");
      },
      onDone: () {
        print("Connection closed: ${_channel?.closeReason}");
      },
    );
  }

  /// Sub/Unsub to Candlestick Streams
  ///
  /// https://developers.binance.com/docs/derivatives/usds-margined-futures/websocket-market-streams/Live-Subscribing-Unsubscribing-to-streams
  /// https://developers.binance.com/docs/derivatives/usds-margined-futures/websocket-market-streams/Kline-Candlestick-Streams
  @override
  void subscribeCandlestickStream({required String symbol, required TimeInterval interval}) {
    _messageId++;
    final request = CandlestickStreamRequest(
      id: _messageId,
      symbol: symbol,
      interval: interval,
      isSubscribe: true,
    );
    _channel?.sink.add(request.toJson());
  }

  @override
  void unsubscribeCandlestickStream({required String symbol, required TimeInterval interval}) {
    _messageId++;
    final request = CandlestickStreamRequest(
      id: _messageId,
      symbol: symbol,
      interval: interval,
      isSubscribe: false,
    );
    _channel?.sink.add(request.toJson());
  }

  @override
  void dispose() {
    _closeWebSocket();
    if (!_candlestickStreamController.isClosed) {
      _candlestickStreamController.close();
    }
  }

  void _closeWebSocket() {
    if (_channel != null && _channel!.closeCode == null) {
      _channel?.sink.close();
      _messageId = 1;
    }
  }
}
