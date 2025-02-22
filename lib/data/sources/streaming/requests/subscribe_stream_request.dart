class SubscribeStreamRequest {
  SubscribeStreamRequest({required this.streamNames});

  final List<String> streamNames;

  Map<String, dynamic> toMap() {
    return {
      "id": DateTime.now().millisecondsSinceEpoch,
      "method": "SUBSCRIBE",
      "params": streamNames,
    };
  }
}
