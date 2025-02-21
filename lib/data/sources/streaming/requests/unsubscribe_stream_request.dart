class UnsubscribeStreamRequest {
  UnsubscribeStreamRequest({required this.streamNames});

  final List<String> streamNames;

  Map<String, dynamic> toMap() {
    return {
      "method": "UNSUBSCRIBE",
      "params": streamNames,
    };
  }
}
