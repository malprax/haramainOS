import 'database_service.dart';

class LocalDatabaseService implements DatabaseService {
  final Map<String, Map<String, Map<String, dynamic>>> _storage = {};

  @override
  Future<void> create({
    required String collection,
    required String documentId,
    required Map<String, dynamic> data,
  }) async {
    _storage.putIfAbsent(collection, () => {});
    _storage[collection]![documentId] = data;
  }

  @override
  Future<Map<String, dynamic>?> read({
    required String collection,
    required String documentId,
  }) async {
    return _storage[collection]?[documentId];
  }

  @override
  Future<List<Map<String, dynamic>>> readAll({
    required String collection,
  }) async {
    return _storage[collection]?.values.toList() ?? [];
  }

  @override
  Future<void> update({
    required String collection,
    required String documentId,
    required Map<String, dynamic> data,
  }) async {
    _storage.putIfAbsent(collection, () => {});
    _storage[collection]![documentId] = data;
  }

  @override
  Future<void> delete({
    required String collection,
    required String documentId,
  }) async {
    _storage[collection]?.remove(documentId);
  }
}
