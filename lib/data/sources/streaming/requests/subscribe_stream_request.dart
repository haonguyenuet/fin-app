class SubscribeStreamRequest {
  SubscribeStreamRequest({required this.streamNames});

  final List<String> streamNames;

  Map<String, dynamic> toMap() {
    return {
      "method": "SUBSCRIBE",
      "params": streamNames,
    };
  }
}
