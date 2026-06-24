import 'package:haramain_os/app/data/models/package_document_requirement_model.dart';

class PackageDocumentRequirementRepository {
  final List<PackageDocumentRequirementModel> _items = [];

  Future<List<PackageDocumentRequirementModel>> getByPackageId(
    String packageId,
  ) async {
    return _items.where((item) => item.packageId == packageId).toList()
      ..sort((a, b) => (a.sortOrder ?? 0).compareTo(b.sortOrder ?? 0));
  }

  Future<void> saveForPackage({
    required String packageId,
    required List<String> documentRequirementIds,
  }) async {
    _items.removeWhere((item) => item.packageId == packageId);

    for (int i = 0; i < documentRequirementIds.length; i++) {
      _items.add(
        PackageDocumentRequirementModel(
          id: '${packageId}_doc_$i',
          packageId: packageId,
          documentRequirementId: documentRequirementIds[i],
          isRequired: true,
          sortOrder: i + 1,
        ),
      );
    }
  }

  Future<void> deleteByPackageId(String packageId) async {
    _items.removeWhere((item) => item.packageId == packageId);
  }
}
