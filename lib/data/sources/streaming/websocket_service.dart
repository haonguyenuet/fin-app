import 'dart:async';
import 'dart:convert';

import 'package:fin_app/data/events/candlestick_event.dart';
import 'package:fin_app/data/models/time_interval.dart';
import 'package:fin_app/data/sources/streaming/requests/candlestick_stream_request.dart';
import 'package:fin_app/data/sources/streaming/streaming_service.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

// https://developers.binance.com/docs/derivatives/usds-margined-futures/websocket-market-streams
class WebsocketService implements StreamingService {
  WebsocketService({required this.wsUrl});

  final String wsUrl;
  final StreamController<CandlestickEvent> _candlestickStreamCtlr = StreamController<CandlestickEvent>.broadcast();

  WebSocketChannel? _channel;
  int _messageId = 1;

  @override
  Stream<CandlestickEvent> get candlestickStream => _candlestickStreamCtlr.stream;

  @override
  void connect() {
    if (_channel != null) return;

    _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
    _channel?.stream.listen(
      (event) {
        if (event is! String) return;

        final map = jsonDecode(event) as Map<String, dynamic>;
        if (map['e'] == "kline") {
          _candlestickStreamCtlr.sink.add(CandlestickEvent.fromMap(map));
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
  void disconnect() {
    if (_channel != null && _channel!.closeCode == null) {
      _channel?.sink.close();
      _messageId = 1;
    }
    if (!_candlestickStreamCtlr.isClosed) {
      _candlestickStreamCtlr.close();
    }
  }
}
