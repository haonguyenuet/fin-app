class UnsubscribeStreamRequest {
  UnsubscribeStreamRequest({required this.streamNames});

  final List<String> streamNames;

  Map<String, dynamic> toMap() {
    return {
      "id": DateTime.now().millisecondsSinceEpoch,
      "method": "UNSUBSCRIBE",
      "params": streamNames,
    };
  }
}
