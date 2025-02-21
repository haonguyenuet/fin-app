import 'dart:async';
import 'dart:convert';

import 'package:fin_app/data/events/candlestick_event.dart';
import 'package:fin_app/data/events/symbol_ticker_event.dart';
import 'package:fin_app/data/models/time_interval.dart';
import 'package:fin_app/data/sources/streaming/requests/subscribe_stream_request.dart';
import 'package:fin_app/data/sources/streaming/requests/unsubscribe_stream_request.dart';
import 'package:fin_app/data/sources/streaming/streaming_service.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

// https://developers.binance.com/docs/derivatives/usds-margined-futures/websocket-market-streams
class WebsocketService implements StreamingService {
  WebsocketService({required this.wsUrl});

  final String wsUrl;
  final _candlestickStreamController = StreamController<CandlestickEvent>.broadcast();
  final _symbolMiniTickerStreamController = StreamController<SymbolMiniTickerEvent>.broadcast();

  WebSocketChannel? _channel;
  int _messageId = 1;

  @override
  void connect() {
    if (_channel != null) return;
    _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
    _channel?.stream.listen(
      onEvent,
      onError: onError,
      onDone: onDone,
    );
  }

  void onEvent(dynamic event) {
    if (event is! String) return;
    final decodedEvent = jsonDecode(event);

    if (decodedEvent is Map<String, dynamic>) {
      final eventType = decodedEvent['e'];
      if (eventType == EventTypes.candlestick) {
        _candlestickStreamController.sink.add(CandlestickEvent.fromMap(decodedEvent));
      } else if (eventType == EventTypes.symbolMiniTicker) {
        _symbolMiniTickerStreamController.sink.add(SymbolMiniTickerEvent.fromMap(decodedEvent));
      }
    } else if (decodedEvent is List) {
      /// Handle other types of events
    }
  }

  void onError(dynamic error) {
    print("Error: $error");
  }

  void onDone() {
    print("Connection closed: ${_channel?.closeReason}");
  }

  @override
  void disconnect() {
    if (_channel != null && _channel!.closeCode == null) {
      _channel?.sink.close();
      _messageId = 1;
    }
    if (!_candlestickStreamController.isClosed) {
      _candlestickStreamController.close();
    }
    if (!_symbolMiniTickerStreamController.isClosed) {
      _symbolMiniTickerStreamController.close();
    }
  }

  void sendRequest(Map<String, dynamic> request) {
    _messageId++;
    request['id'] = _messageId;
    _channel?.sink.add(jsonEncode(request));
  }

  /// =============================== Kline/Candlestick Streams ===============================

  @override
  Stream<CandlestickEvent> get candlestickStream => _candlestickStreamController.stream;

  @override
  void subscribeCandlestickStream({required String symbol, required TimeInterval interval}) {
    final request = SubscribeStreamRequest(
      streamNames: ["${symbol.toLowerCase()}@kline_${interval.value}"],
    );
    sendRequest(request.toMap());
  }

  @override
  void unsubscribeCandlestickStream({required String symbol, required TimeInterval interval}) {
    final request = UnsubscribeStreamRequest(
      streamNames: ["${symbol.toLowerCase()}@kline_${interval.value}"],
    );
    sendRequest(request.toMap());
  }

  /// =============================== Individual Symbol Mini Ticker Streams ===============================

  @override
  Stream<SymbolMiniTickerEvent> get symbolMiniTickerStream => _symbolMiniTickerStreamController.stream;

  @override
  void subscribeSymbolMiniTickerStream({required List<String> symbols}) {
    final request = SubscribeStreamRequest(
      streamNames: symbols.map((e) => "${e.toLowerCase()}@miniTicker").toList(),
    );
    sendRequest(request.toMap());
  }

  @override
  void unsubscribeSymbolMiniTickerStream({required List<String> symbols}) {
    final request = UnsubscribeStreamRequest(
      streamNames: symbols.map((e) => "${e.toLowerCase()}@miniTicker").toList(),
    );
    sendRequest(request.toMap());
  }
}

class EventTypes {
  static const String candlestick = 'kline';
  static const String symbolMiniTicker = '24hrMiniTicker';
}
