abstract class DatabaseService {
  Future<void> create({
    required String collection,
    required String documentId,
    required Map<String, dynamic> data,
  });

  Future<Map<String, dynamic>?> read({
    required String collection,
    required String documentId,
  });

  Future<List<Map<String, dynamic>>> readAll({required String collection});

  Future<void> update({
    required String collection,
    required String documentId,
    required Map<String, dynamic> data,
  });

  Future<void> delete({required String collection, required String documentId});
}
