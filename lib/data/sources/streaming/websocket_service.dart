import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:fin_app/data/events/ack_event.dart';
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

  /// Map to track pending requests (id -> success/failure completer)
  final Map<int, Completer<bool>> _pendingRequests = {};

  /// Set to track active streams
  final Set<String> _activeStreams = {};

  /// Number of reconnection attempts
  int _reconnectAttempts = 0;

  WebSocketChannel? _channel;
  bool get isConnected => _channel != null && _channel!.closeCode == null;

  @override
  void connect() {
    if (_channel != null) return;
    _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
    _channel?.stream.listen(
      _onEvent,
      onError: _onError,
      onDone: _onDone,
    );
  }

  void _onEvent(dynamic event) {
    if (event is! String) return;
    final decodedEvent = jsonDecode(event);

    if (decodedEvent is Map<String, dynamic>) {
      if (decodedEvent.containsKey('ping')) {
        _handlePingResponse();
        return;
      }

      if (decodedEvent.containsKey('id')) {
        _handleAckEvent(decodedEvent);
        return;
      }

      final eventType = decodedEvent['e'];
      switch (eventType) {
        case EventTypes.candlestick:
          _candlestickStreamController.sink.add(CandlestickEvent.fromMap(decodedEvent));
          break;
        case EventTypes.symbolMiniTicker:
          _symbolMiniTickerStreamController.sink.add(SymbolMiniTickerEvent.fromMap(decodedEvent));
          break;
        default:
          print("Unhandled event type: $eventType");
          break;
      }
    }
  }

  void _handlePingResponse() {
    _channel?.sink.add(jsonEncode({'pong': DateTime.now().millisecondsSinceEpoch}));
  }

  void _handleAckEvent(Map<String, dynamic> response) {
    final ackEvent = AckEvent.fromMap(response);
    final requestId = ackEvent.id;
    final completer = _pendingRequests.remove(requestId);
    if (completer != null) {
      if (ackEvent.isError) {
        print("Error: ${ackEvent.errorMsg} (Code: ${ackEvent.errorCode})");
        completer.complete(false);
      } else {
        completer.complete(ackEvent.isSuccess);
      }
    }
  }

  void _onError(dynamic error) {
    if (error is WebSocketChannelException || error is SocketException) {
      print("Temporary error detected");
      reconnect();
    } else if (error is HttpException && error.message.contains("403")) {
      print("Access denied (403 Forbidden). Check API permissions.");
    } else if (error is HttpException && error.message.contains("400")) {
      print("Bad request (400). Check the request format.");
    } else {
      print("Unknown error: $error");
    }
  }

  void _onDone() {
    print("Connection closed: ${_channel?.closeReason ?? 'Unknown reason'}");
    if (_channel?.closeCode == null || _channel?.closeCode != 1000) {
      reconnect();
    }
  }

  @override
  void reconnect() async {
    disconnect();

    if (_reconnectAttempts >= 5) {
      print("Maximum reconnection attempts reached");
      return;
    }

    print("Attempting to reconnect (${_reconnectAttempts + 1}/5)...");
    _reconnectAttempts++;
    await Future.delayed(Duration(seconds: 2 * _reconnectAttempts));
    connect();

    if (isConnected) {
      _reconnectAttempts = 0;
      // Resubscribe to active streams
      if (_activeStreams.isNotEmpty) {
        final request = SubscribeStreamRequest(streamNames: _activeStreams.toList());
        await _sendRequest(request.toMap());
      }
    }
  }

  Future<bool> _sendRequest(Map<String, dynamic> request) async {
    if (!isConnected) {
      print("WebSocket is not connected. Cannot send request: $request");
      return false;
    }

    final completer = Completer<bool>();
    _pendingRequests[request['id']] = completer;
    _channel?.sink.add(jsonEncode(request));

    final isSuccess = await completer.future;
    if (isSuccess && request.containsKey('params')) {
      final streamNames = request['params'];
      if (request['method'] == 'SUBSCRIBE') {
        _activeStreams.addAll(streamNames);
      } else if (request['method'] == 'UNSUBSCRIBE') {
        _activeStreams.removeAll(streamNames);
      }
    }
    return isSuccess;
  }

  @override
  void disconnect() {
    for (final completer in _pendingRequests.values) {
      completer.complete(false);
    }
    _pendingRequests.clear();
    _channel?.sink.close();
    _channel = null;
  }

  @override
  void close() {
    disconnect();
    _candlestickStreamController.close();
    _symbolMiniTickerStreamController.close();
  }

  /// =============================== Kline/Candlestick Streams ===============================

  @override
  Stream<CandlestickEvent> get candlestickStream => _candlestickStreamController.stream;

  @override
  Future<bool> subscribeCandlestickStream({required String symbol, required TimeInterval interval}) async {
    final request = SubscribeStreamRequest(
      streamNames: ["${symbol.toLowerCase()}@kline_${interval.value}"],
    );
    return _sendRequest(request.toMap());
  }

  @override
  Future<bool> unsubscribeCandlestickStream({required String symbol, required TimeInterval interval}) async {
    final request = UnsubscribeStreamRequest(
      streamNames: ["${symbol.toLowerCase()}@kline_${interval.value}"],
    );
    return _sendRequest(request.toMap());
  }

  /// =============================== Individual Symbol Mini Ticker Streams ===============================

  @override
  Stream<SymbolMiniTickerEvent> get symbolMiniTickerStream => _symbolMiniTickerStreamController.stream;

  @override
  Future<bool> subscribeSymbolMiniTickerStream({required List<String> symbols}) async {
    final request = SubscribeStreamRequest(
      streamNames: symbols.map((symbol) => "${symbol.toLowerCase()}@miniTicker").toList(),
    );
    return _sendRequest(request.toMap());
  }

  @override
  Future<bool> unsubscribeSymbolMiniTickerStream({required List<String> symbols}) async {
    final request = UnsubscribeStreamRequest(
      streamNames: symbols.map((symbol) => "${symbol.toLowerCase()}@miniTicker").toList(),
    );
    return _sendRequest(request.toMap());
  }
}

class EventTypes {
  static const String candlestick = 'kline';
  static const String symbolMiniTicker = '24hrMiniTicker';
}
