import 'package:haramain_os/app/data/models/document_status.dart';

class JamaahDocumentModel {
  String? id;
  String? jamaahId;
  String? documentRequirementId;

  String? file;
  String? fileUrl;

  DocumentStatus? status;
  String? note;

  DateTime? created;
  DateTime? updated;

  JamaahDocumentModel({
    this.id,
    this.jamaahId,
    this.documentRequirementId,
    this.file,
    this.fileUrl,
    this.status,
    this.note,
    this.created,
    this.updated,
  });

  factory JamaahDocumentModel.fromJson(Map<String, dynamic> json) {
    return JamaahDocumentModel(
      id: json['id']?.toString(),
      jamaahId: json['jamaahId']?.toString(),
      documentRequirementId: json['documentRequirementId']?.toString(),
      file: json['file']?.toString(),
      fileUrl: json['fileUrl']?.toString(),
      status: _parseStatus(json['status']),
      note: json['note']?.toString(),
      created: DateTime.tryParse(json['created']?.toString() ?? ''),
      updated: DateTime.tryParse(json['updated']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'jamaahId': jamaahId,
      'documentRequirementId': documentRequirementId,
      'status': status?.name,
      'note': note,
    };

    data.removeWhere((key, value) => value == null);

    return data;
  }

  JamaahDocumentModel copyWith({
    String? id,
    String? jamaahId,
    String? documentRequirementId,
    String? file,
    String? fileUrl,
    DocumentStatus? status,
    String? note,
    DateTime? created,
    DateTime? updated,
  }) {
    return JamaahDocumentModel(
      id: id ?? this.id,
      jamaahId: jamaahId ?? this.jamaahId,
      documentRequirementId:
          documentRequirementId ?? this.documentRequirementId,
      file: file ?? this.file,
      fileUrl: fileUrl ?? this.fileUrl,
      status: status ?? this.status,
      note: note ?? this.note,
      created: created ?? this.created,
      updated: updated ?? this.updated,
    );
  }

  static DocumentStatus _parseStatus(dynamic value) {
    final statusText = value?.toString();

    if (statusText == null || statusText.isEmpty) {
      return DocumentStatus.notUploaded;
    }

    return DocumentStatus.values.firstWhere(
      (item) => item.name == statusText,
      orElse: () => DocumentStatus.notUploaded,
    );
  }
}
