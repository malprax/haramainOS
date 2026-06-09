import 'package:get/get.dart';
import 'package:pocketbase/pocketbase.dart';

import 'database_service.dart';

class PocketBaseDatabaseService implements DatabaseService {
  final PocketBase _pb = Get.find<PocketBase>();

  @override
  Future<void> create({
    required String collection,
    required String documentId,
    required Map<String, dynamic> data,
  }) async {
    final payload = Map<String, dynamic>.from(data);
    payload.remove('id');

    await _pb.collection(collection).create(body: payload);
  }

  @override
  Future<Map<String, dynamic>?> read({
    required String collection,
    required String documentId,
  }) async {
    try {
      final record = await _pb.collection(collection).getOne(documentId);
      return _recordToMap(record);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> readAll({
    required String collection,
  }) async {
    final records = await _pb
        .collection(collection)
        .getFullList(sort: '-created');

    return records.map(_recordToMap).toList();
  }

  @override
  Future<void> update({
    required String collection,
    required String documentId,
    required Map<String, dynamic> data,
  }) async {
    final payload = Map<String, dynamic>.from(data);
    payload.remove('id');

    await _pb.collection(collection).update(documentId, body: payload);
  }

  @override
  Future<void> delete({
    required String collection,
    required String documentId,
  }) async {
    await _pb.collection(collection).delete(documentId);
  }

  Map<String, dynamic> _recordToMap(RecordModel record) {
    final map = Map<String, dynamic>.from(record.data);
    map['id'] = record.id;
    return map;
  }
}
