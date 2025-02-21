class BaseRepository {
  Future<T?> safeCallApi<T>({required Future<T> request}) async {
    try {
      return await request;
    } catch (error) {
      print("API error: $error");
      return null;
    }
  }
}
