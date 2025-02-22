class AckEvent {
  AckEvent({
    required this.id,
    this.result,
    this.errorCode,
    this.errorMsg,
  });

  final int id;
  final Object? result;
  final int? errorCode;
  final String? errorMsg;

  bool get isError => errorCode != null;
  bool get isSuccess => result == null;

  factory AckEvent.fromMap(Map<String, dynamic> map) {
    return AckEvent(
      id: map['id'],
      result: map['result'],
      errorCode: map['code'],
      errorMsg: map['msg'],
    );
  }
}
