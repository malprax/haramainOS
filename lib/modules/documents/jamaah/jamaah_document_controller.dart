import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pocketbase/pocketbase.dart';

import 'package:haramain_os/app/data/models/document_requirement_model.dart';
import 'package:haramain_os/app/data/models/document_status.dart';
import 'package:haramain_os/app/data/models/jamaah_document_model.dart';
import 'package:haramain_os/app/data/models/package_document_requirement_model.dart';
import 'package:haramain_os/app/data/repositories/document_repository.dart';
import 'package:haramain_os/modules/auth/auth_controller.dart';

class JamaahDocumentController extends GetxController {
  final AuthController authController = Get.find<AuthController>();
  final PocketBase _pb = Get.find<PocketBase>();
  final DocumentRepository _documentRepository = DocumentRepository();

  final documentRequirements = <DocumentRequirementModel>[].obs;
  final packageDocumentRequirements = <PackageDocumentRequirementModel>[].obs;
  final jamaahDocuments = <JamaahDocumentModel>[].obs;

  final isLoading = false.obs;
  final uploadingDocumentRequirementId = ''.obs;
  final deletingDocumentId = ''.obs;

  bool _isPickingFile = false;

  final selectedPackageId = 'package_umrah_sep_2026'.obs;

  String get currentJamaahId {
    final fromController = authController.currentUser.value?.id.trim() ?? '';

    if (fromController.isNotEmpty) return fromController;

    final authModel = _pb.authStore.model;

    if (authModel is RecordModel) {
      return authModel.id.trim();
    }

    return '';
  }

  bool get isUploading => uploadingDocumentRequirementId.value.isNotEmpty;

  bool isUploadingDocument(String documentRequirementId) {
    return uploadingDocumentRequirementId.value == documentRequirementId;
  }

  bool isDeletingDocument(String documentId) {
    return deletingDocumentId.value == documentId;
  }

  @override
  void onInit() {
    super.onInit();

    loadDocumentRequirements();
    loadPackageDocumentRequirements(selectedPackageId.value);
    loadJamaahDocuments();
  }

  Future<void> refreshData() async {
    await loadJamaahDocuments();
  }

  void loadDocumentRequirements() {
    documentRequirements.value = [
      DocumentRequirementModel(
        id: 'doc_paspor',
        name: 'Paspor',
        description: 'Paspor aktif minimal 6 bulan.',
        isActive: true,
        sortOrder: 1,
      ),
      DocumentRequirementModel(
        id: 'doc_ktp',
        name: 'KTP',
        description: 'Kartu Tanda Penduduk jamaah.',
        isActive: true,
        sortOrder: 2,
      ),
      DocumentRequirementModel(
        id: 'doc_kk',
        name: 'Kartu Keluarga',
        description: 'Kartu keluarga jamaah.',
        isActive: true,
        sortOrder: 3,
      ),
      DocumentRequirementModel(
        id: 'doc_foto',
        name: 'Foto 4x6',
        description: 'Foto berwarna latar putih.',
        isActive: true,
        sortOrder: 4,
      ),
      DocumentRequirementModel(
        id: 'doc_vaksin',
        name: 'Buku Vaksin',
        description: 'Bukti vaksin meningitis.',
        isActive: true,
        sortOrder: 5,
      ),
    ];
  }

  void loadPackageDocumentRequirements(String packageId) {
    packageDocumentRequirements.value = [
      PackageDocumentRequirementModel(
        id: 'pdr_001',
        packageId: packageId,
        documentRequirementId: 'doc_paspor',
        isRequired: true,
        sortOrder: 1,
      ),
      PackageDocumentRequirementModel(
        id: 'pdr_002',
        packageId: packageId,
        documentRequirementId: 'doc_ktp',
        isRequired: true,
        sortOrder: 2,
      ),
      PackageDocumentRequirementModel(
        id: 'pdr_003',
        packageId: packageId,
        documentRequirementId: 'doc_kk',
        isRequired: true,
        sortOrder: 3,
      ),
      PackageDocumentRequirementModel(
        id: 'pdr_004',
        packageId: packageId,
        documentRequirementId: 'doc_foto',
        isRequired: true,
        sortOrder: 4,
      ),
      PackageDocumentRequirementModel(
        id: 'pdr_005',
        packageId: packageId,
        documentRequirementId: 'doc_vaksin',
        isRequired: true,
        sortOrder: 5,
      ),
    ];
  }

  Future<void> loadJamaahDocuments() async {
    final jamaahId = currentJamaahId;

    if (jamaahId.isEmpty) return;

    isLoading.value = true;

    try {
      final data = await _documentRepository.getDocumentsByJamaahId(jamaahId);

      jamaahDocuments.assignAll(data);
      jamaahDocuments.refresh();

      debugPrint('CURRENT JAMAAH ID DOCUMENT: $jamaahId');
      debugPrint('TOTAL JAMAAH DOCUMENTS: ${jamaahDocuments.length}');
    } catch (error) {
      debugPrint('LOAD JAMAAH DOCUMENT ERROR: $error');

      Get.snackbar(
        'Gagal memuat dokumen',
        error.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  DocumentRequirementModel? getRequirementById(String? documentRequirementId) {
    if (documentRequirementId == null || documentRequirementId.isEmpty) {
      return null;
    }

    return documentRequirements.firstWhereOrNull(
      (item) => item.id == documentRequirementId,
    );
  }

  JamaahDocumentModel? getJamaahDocumentByRequirementId(
    String? documentRequirementId,
  ) {
    if (documentRequirementId == null || documentRequirementId.isEmpty) {
      return null;
    }

    return jamaahDocuments.firstWhereOrNull(
      (item) => item.documentRequirementId == documentRequirementId,
    );
  }

  DocumentStatus getDocumentStatus(String? documentRequirementId) {
    return getJamaahDocumentByRequirementId(documentRequirementId)?.status ??
        DocumentStatus.notUploaded;
  }

  String getDocumentNote(String? documentRequirementId) {
    return getJamaahDocumentByRequirementId(documentRequirementId)?.note ?? '';
  }

  bool hasUploadedFile(String? documentRequirementId) {
    final fileUrl =
        getJamaahDocumentByRequirementId(documentRequirementId)?.fileUrl ?? '';

    return fileUrl.isNotEmpty;
  }

  int get totalRequiredDocumentCount => packageDocumentRequirements.length;

  int get uploadedDocumentCount => jamaahDocuments.length;

  int get approvedDocumentCount {
    return jamaahDocuments
        .where((item) => item.status == DocumentStatus.approved)
        .length;
  }

  int get pendingDocumentCount {
    return jamaahDocuments
        .where((item) => item.status == DocumentStatus.pending)
        .length;
  }

  int get rejectedDocumentCount {
    return jamaahDocuments
        .where((item) => item.status == DocumentStatus.rejected)
        .length;
  }

  int get notUploadedDocumentCount {
    final value = totalRequiredDocumentCount - uploadedDocumentCount;
    return value < 0 ? 0 : value;
  }

  bool get hasCompletedAllDocuments {
    return approvedDocumentCount == totalRequiredDocumentCount &&
        totalRequiredDocumentCount > 0;
  }

  double get completionPercentage {
    if (totalRequiredDocumentCount == 0) return 0;
    return approvedDocumentCount / totalRequiredDocumentCount;
  }

  Future<void> pickAndUploadDocument({
    required String documentRequirementId,
  }) async {
    final id = documentRequirementId.trim();

    if (id.isEmpty) {
      Get.snackbar(
        'Dokumen tidak valid',
        'Jenis dokumen belum dipilih',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (_isPickingFile || uploadingDocumentRequirementId.value.isNotEmpty) {
      return;
    }

    final existingDocument = getJamaahDocumentByRequirementId(id);

    if (existingDocument?.status == DocumentStatus.approved) {
      Get.snackbar(
        'Dokumen sudah disetujui',
        'Dokumen yang sudah disetujui tidak dapat diganti',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final jamaahId = currentJamaahId;

    debugPrint('UPLOAD DOCUMENT CURRENT JAMAAH ID: $jamaahId');

    if (jamaahId.isEmpty) {
      Get.snackbar(
        'Akun tidak ditemukan',
        'Silakan login ulang terlebih dahulu',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      _isPickingFile = true;

      final pickedFileData = await _pickDocumentFile();

      _isPickingFile = false;

      if (pickedFileData == null) {
        return;
      }

      uploadingDocumentRequirementId.value = id;

      await _documentRepository.uploadDocument(
        jamaahId: jamaahId,
        documentRequirementId: id,
        fileBytes: pickedFileData.bytes,
        fileName: pickedFileData.fileName,
      );

      await loadJamaahDocuments();

      Get.snackbar(
        'Berhasil',
        'Dokumen berhasil diupload dan menunggu verifikasi',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (error) {
      _isPickingFile = false;

      debugPrint('UPLOAD JAMAAH DOCUMENT ERROR: $error');

      Get.snackbar(
        'Gagal upload dokumen',
        error.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      uploadingDocumentRequirementId.value = '';
      _isPickingFile = false;
    }
  }

  Future<void> deleteDocument(String documentId) async {
    final id = documentId.trim();

    if (id.isEmpty) return;

    final document = jamaahDocuments.firstWhereOrNull((item) => item.id == id);

    if (document == null) {
      Get.snackbar(
        'Dokumen tidak ditemukan',
        'Dokumen sudah tidak tersedia',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (document.status == DocumentStatus.approved) {
      Get.snackbar(
        'Tidak dapat dihapus',
        'Dokumen yang sudah disetujui admin tidak dapat dihapus',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (deletingDocumentId.value.isNotEmpty) return;

    try {
      deletingDocumentId.value = id;

      await _documentRepository.deleteDocument(id);

      await loadJamaahDocuments();

      Get.snackbar(
        'Berhasil',
        'Dokumen berhasil dihapus',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (error) {
      debugPrint('DELETE JAMAAH DOCUMENT ERROR: $error');

      Get.snackbar(
        'Gagal hapus dokumen',
        error.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      deletingDocumentId.value = '';
    }
  }

  Future<_PickedDocumentFile?> _pickDocumentFile() async {
    debugPrint('========================');
    debugPrint('OPEN DOCUMENT PICKER');
    debugPrint('Platform: ${defaultTargetPlatform.name}');
    debugPrint('isWeb: $kIsWeb');
    debugPrint('========================');

    if (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
      return _pickMobileImage();
    }

    return _pickFilePickerFile();
  }

  Future<_PickedDocumentFile?> _pickMobileImage() async {
    final imagePicker = ImagePicker();

    final image = await imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (image == null) {
      debugPrint('IMAGE PICKER CANCELLED');
      return null;
    }

    final bytes = await image.readAsBytes();

    debugPrint('IMAGE PICKED: ${image.name}');
    debugPrint('IMAGE SIZE: ${bytes.length}');

    return _PickedDocumentFile(fileName: image.name, bytes: bytes);
  }

  Future<_PickedDocumentFile?> _pickFilePickerFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
      allowMultiple: false,
      withData: kIsWeb,
    );

    debugPrint('FILE PICKER CLOSED');
    debugPrint('Result null: ${result == null}');

    if (result == null || result.files.isEmpty) {
      return null;
    }

    final pickedFile = result.files.single;

    final bytes = await _readPickedFileBytes(pickedFile);

    if (bytes == null) {
      return null;
    }

    debugPrint('FILE NAME : ${pickedFile.name}');
    debugPrint('FILE PATH : ${pickedFile.path}');
    debugPrint('FILE SIZE : ${pickedFile.size}');
    debugPrint('HAS BYTES : ${pickedFile.bytes != null}');

    return _PickedDocumentFile(fileName: pickedFile.name, bytes: bytes);
  }

  Future<Uint8List?> _readPickedFileBytes(PlatformFile pickedFile) async {
    if (kIsWeb) {
      return pickedFile.bytes;
    }

    if (pickedFile.bytes != null) {
      return pickedFile.bytes;
    }

    final path = pickedFile.path;

    if (path == null || path.isEmpty) {
      return null;
    }

    return File(path).readAsBytes();
  }
}

class _PickedDocumentFile {
  final String fileName;
  final Uint8List bytes;

  const _PickedDocumentFile({required this.fileName, required this.bytes});
}
