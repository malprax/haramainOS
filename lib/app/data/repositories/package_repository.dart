import 'package:get/get.dart';

import '../../core/database/database_service.dart';
import '../models/package_model.dart';

class PackageRepository {
  final DatabaseService _database = Get.find();

  static const String collection = 'packages';

  Future<void> createPackage(PackageModel package) async {
    await _database.create(
      collection: collection,
      documentId: package.id ?? '',
      data: package.toJson(),
    );
  }

  Future<List<PackageModel>> getPackages() async {
    final result = await _database.readAll(collection: collection);

    return result.map((item) {
      return PackageModel.fromJson(item);
    }).toList();
  }

  Future<void> updatePackage(PackageModel package) async {
    if (package.id == null || package.id!.isEmpty) {
      throw Exception('Package ID tidak boleh kosong saat update');
    }

    await _database.update(
      collection: collection,
      documentId: package.id!,
      data: package.toJson(),
    );
  }

  Future<void> deletePackage(String packageId) async {
    if (packageId.isEmpty) {
      throw Exception('Package ID tidak boleh kosong saat delete');
    }

    await _database.delete(collection: collection, documentId: packageId);
  }
}
