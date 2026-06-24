import 'dart:typed_data';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:pocketbase/pocketbase.dart';

import 'package:haramain_os/app/data/models/document_status.dart';
import 'package:haramain_os/app/data/models/jamaah_document_model.dart';

class DocumentRepository {
  final PocketBase _pb = Get.find<PocketBase>();

  static const String collectionName = 'jamaah_documents';

  // ==========================================================
  // ADMIN
  // ==========================================================

  Future<List<JamaahDocumentModel>> getAllDocuments() async {
    final records = await _pb
        .collection(collectionName)
        .getFullList(sort: '-created');

    return records.map(_recordToModel).toList();
  }

  Future<List<JamaahDocumentModel>> getPendingDocuments() async {
    return getDocumentsByStatus(DocumentStatus.pending);
  }

  Future<List<JamaahDocumentModel>> getApprovedDocuments() async {
    return getDocumentsByStatus(DocumentStatus.approved);
  }

  Future<List<JamaahDocumentModel>> getRejectedDocuments() async {
    return getDocumentsByStatus(DocumentStatus.rejected);
  }

  Future<List<JamaahDocumentModel>> getDocumentsByStatus(
    DocumentStatus status,
  ) async {
    final records = await _pb
        .collection(collectionName)
        .getFullList(filter: 'status="${status.name}"', sort: '-created');

    return records.map(_recordToModel).toList();
  }

  // ==========================================================
  // JAMAAH
  // ==========================================================

  Future<List<JamaahDocumentModel>> getDocumentsByJamaahId(
    String jamaahId,
  ) async {
    final cleanJamaahId = jamaahId.trim();

    if (cleanJamaahId.isEmpty) {
      return [];
    }

    final records = await _pb
        .collection(collectionName)
        .getFullList(filter: 'jamaahId="$cleanJamaahId"', sort: '-created');

    return records.map(_recordToModel).toList();
  }

  Future<JamaahDocumentModel?> getDocumentByRequirement({
    required String jamaahId,
    required String documentRequirementId,
  }) async {
    final cleanJamaahId = jamaahId.trim();
    final cleanRequirementId = documentRequirementId.trim();

    if (cleanJamaahId.isEmpty || cleanRequirementId.isEmpty) {
      return null;
    }

    final result = await _pb
        .collection(collectionName)
        .getList(
          page: 1,
          perPage: 1,
          filter:
              'jamaahId="$cleanJamaahId" && documentRequirementId="$cleanRequirementId"',
        );

    if (result.items.isEmpty) {
      return null;
    }

    return _recordToModel(result.items.first);
  }

  Future<JamaahDocumentModel> uploadDocument({
    required String jamaahId,
    required String documentRequirementId,
    required Uint8List fileBytes,
    required String fileName,
  }) async {
    final cleanJamaahId = jamaahId.trim();
    final cleanRequirementId = documentRequirementId.trim();
    final cleanFileName = fileName.trim().isEmpty
        ? 'jamaah_document_${DateTime.now().millisecondsSinceEpoch}.jpg'
        : fileName.trim();

    final existing = await getDocumentByRequirement(
      jamaahId: cleanJamaahId,
      documentRequirementId: cleanRequirementId,
    );

    final body = {
      'jamaahId': cleanJamaahId,
      'documentRequirementId': cleanRequirementId,
      'status': DocumentStatus.pending.name,
      'note': '',
    };

    final files = [
      http.MultipartFile.fromBytes('file', fileBytes, filename: cleanFileName),
    ];

    if (existing != null && existing.id != null && existing.id!.isNotEmpty) {
      final record = await _pb
          .collection(collectionName)
          .update(existing.id!, body: body, files: files);

      return _recordToModel(record);
    }

    final record = await _pb
        .collection(collectionName)
        .create(body: body, files: files);

    return _recordToModel(record);
  }

  // ==========================================================
  // VERIFICATION
  // ==========================================================

  Future<void> approveDocument(String documentId) async {
    final cleanDocumentId = documentId.trim();

    if (cleanDocumentId.isEmpty) return;

    await _pb
        .collection(collectionName)
        .update(
          cleanDocumentId,
          body: {'status': DocumentStatus.approved.name, 'note': ''},
        );
  }

  Future<void> rejectDocument({
    required String documentId,
    required String note,
  }) async {
    final cleanDocumentId = documentId.trim();

    if (cleanDocumentId.isEmpty) return;

    await _pb
        .collection(collectionName)
        .update(
          cleanDocumentId,
          body: {'status': DocumentStatus.rejected.name, 'note': note.trim()},
        );
  }

  Future<void> deleteDocument(String documentId) async {
    final cleanDocumentId = documentId.trim();

    if (cleanDocumentId.isEmpty) return;

    await _pb.collection(collectionName).delete(cleanDocumentId);
  }

  // ==========================================================
  // MAPPER
  // ==========================================================

  JamaahDocumentModel _recordToModel(RecordModel record) {
    final json = Map<String, dynamic>.from(record.data);

    json['id'] = record.id;
    json['created'] = record.created;
    json['updated'] = record.updated;

    final rawFile = json['file'];

    if (rawFile is String && rawFile.isNotEmpty) {
      json['fileUrl'] = _pb.files.getUrl(record, rawFile).toString();
    }

    return JamaahDocumentModel.fromJson(json);
  }
}
