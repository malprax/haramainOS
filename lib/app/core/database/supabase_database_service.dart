import 'package:supabase_flutter/supabase_flutter.dart';

import 'database_service.dart';

class SupabaseDatabaseService implements DatabaseService {
  final SupabaseClient _client = Supabase.instance.client;

  @override
  Future<void> create({
    required String collection,
    required String documentId,
    required Map<String, dynamic> data,
  }) async {
    final payload = {'id': documentId, ...data};

    await _client.from(collection).insert(payload);
  }

  @override
  Future<Map<String, dynamic>?> read({
    required String collection,
    required String documentId,
  }) async {
    final result = await _client
        .from(collection)
        .select()
        .eq('id', documentId)
        .maybeSingle();

    return result;
  }

  @override
  Future<List<Map<String, dynamic>>> readAll({
    required String collection,
  }) async {
    final result = await _client.from(collection).select();

    return List<Map<String, dynamic>>.from(result);
  }

  @override
  Future<void> update({
    required String collection,
    required String documentId,
    required Map<String, dynamic> data,
  }) async {
    await _client.from(collection).update(data).eq('id', documentId);
  }

  @override
  Future<void> delete({
    required String collection,
    required String documentId,
  }) async {
    await _client.from(collection).delete().eq('id', documentId);
  }
}
