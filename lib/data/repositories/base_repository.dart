class BaseRepository {
  Future<T?> safeCallApi<T>(Future<T> Function() apiCall) async {
    try {
      return await apiCall();
    } catch (error) {
      print("API error: $error");
      return null;
    }
  }
}
