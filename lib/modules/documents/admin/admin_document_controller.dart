import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:haramain_os/app/data/repositories/booking_notification_repository.dart';
import 'package:haramain_os/routes/app_routes.dart';
import 'package:pocketbase/pocketbase.dart';

import 'package:haramain_os/app/data/models/document_requirement_model.dart';
import 'package:haramain_os/app/data/models/document_status.dart';
import 'package:haramain_os/app/data/models/jamaah_document_model.dart';
import 'package:haramain_os/app/data/models/user_model.dart';
import 'package:haramain_os/app/data/repositories/document_repository.dart';

class AdminDocumentController extends GetxController {
  final DocumentRepository _repository = DocumentRepository();
  final BookingNotificationRepository _notificationRepository =
      BookingNotificationRepository();
  final PocketBase _pb = Get.find<PocketBase>();

  final documents = <JamaahDocumentModel>[].obs;
  final documentRequirements = <DocumentRequirementModel>[].obs;
  final jamaahUsers = <String, UserModel>{}.obs;

  final isLoading = false.obs;
  final selectedStatusFilter = 'Semua'.obs;

  final searchController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    loadDocumentRequirements();
    loadInitialData();
  }

  Future<void> loadInitialData() async {
    isLoading.value = true;

    try {
      await loadDocuments();
      await loadJamaahUsers();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshData() async {
    await loadInitialData();
  }

  void loadDocumentRequirements() {
    documentRequirements.assignAll([
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
    ]);
  }

  Future<void> loadJamaahUsers() async {
    try {
      final records = await _pb.collection('users').getFullList();

      final mappedUsers = <String, UserModel>{};

      for (final record in records) {
        final json = Map<String, dynamic>.from(record.data);

        json['id'] = record.id.trim();
        json['role'] = json['role']?.toString().trim() ?? '';
        json['fullName'] = json['fullName']?.toString().trim() ?? '';
        json['email'] = json['email']?.toString().trim() ?? '';
        json['phoneNumber'] = json['phoneNumber']?.toString().trim() ?? '';

        final user = UserModel.fromJson(json);

        mappedUsers[record.id.trim()] = user;

        debugPrint(
          'USER MAP => ${record.id.trim()} | ${user.fullName} | ${user.email}',
        );
      }

      jamaahUsers.assignAll(mappedUsers);
      jamaahUsers.refresh();

      debugPrint('TOTAL USERS MAPPED: ${jamaahUsers.length}');

      for (final document in documents) {
        debugPrint(
          'CHECK DOC USER => jamaahId=${document.jamaahId} found=${jamaahUsers.containsKey(document.jamaahId?.trim())}',
        );
      }
    } catch (error) {
      debugPrint('LOAD USERS ERROR: $error');
    }
  }

  Future<void> loadDocuments() async {
    try {
      final data = await _repository.getAllDocuments();

      documents.assignAll(data);
      documents.refresh();

      debugPrint('TOTAL ADMIN DOCUMENTS: ${documents.length}');
    } catch (error) {
      debugPrint('LOAD ADMIN DOCUMENT ERROR: $error');

      Get.snackbar(
        'Gagal memuat dokumen',
        error.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  DocumentRequirementModel? getRequirementById(String? documentRequirementId) {
    final id = documentRequirementId?.trim() ?? '';

    if (id.isEmpty) return null;

    return documentRequirements.firstWhereOrNull((item) => item.id == id);
  }

  String getRequirementName(String? documentRequirementId) {
    final requirement = getRequirementById(documentRequirementId);

    return requirement?.name.trim().isNotEmpty == true
        ? requirement!.name.trim()
        : documentRequirementId ?? '-';
  }

  String getRequirementDescription(String? documentRequirementId) {
    final requirement = getRequirementById(documentRequirementId);

    return requirement?.description.trim().isNotEmpty == true
        ? requirement!.description.trim()
        : '-';
  }

  UserModel? getJamaahUser(String? jamaahId) {
    final id = jamaahId?.trim() ?? '';

    if (id.isEmpty) return null;

    return jamaahUsers[id];
  }

  String getJamaahFullName(String? jamaahId) {
    final user = getJamaahUser(jamaahId);

    if (user == null) {
      return 'Jamaah tidak ditemukan (${jamaahId ?? '-'})';
    }

    if (user.fullName.trim().isNotEmpty) {
      return user.fullName.trim();
    }

    if (user.email.trim().isNotEmpty) {
      return user.email.trim();
    }

    return 'Jamaah tanpa nama';
  }

  String getJamaahEmail(String? jamaahId) {
    final user = getJamaahUser(jamaahId);

    if (user == null) return '-';

    return user.email.trim().isEmpty ? '-' : user.email.trim();
  }

  String getJamaahPhone(String? jamaahId) {
    final user = getJamaahUser(jamaahId);

    if (user == null) return '-';

    final phone = user.phoneNumber?.trim() ?? '';

    return phone.isEmpty ? '-' : phone;
  }

  String getJamaahAvatar(String? jamaahId) {
    final user = getJamaahUser(jamaahId);

    if (user == null) return '';

    return user.avatar?.trim() ?? '';
  }

  int get totalDocumentCount => documents.length;

  int get pendingDocumentCount {
    return documents
        .where((item) => item.status == DocumentStatus.pending)
        .length;
  }

  int get approvedDocumentCount {
    return documents
        .where((item) => item.status == DocumentStatus.approved)
        .length;
  }

  int get rejectedDocumentCount {
    return documents
        .where((item) => item.status == DocumentStatus.rejected)
        .length;
  }

  List<JamaahDocumentModel> get filteredDocuments {
    final keyword = searchController.text.trim().toLowerCase();
    final filter = selectedStatusFilter.value;

    return documents.where((document) {
      final status = document.status ?? DocumentStatus.pending;

      final requirementName = getRequirementName(
        document.documentRequirementId,
      ).toLowerCase();

      final requirementDescription = getRequirementDescription(
        document.documentRequirementId,
      ).toLowerCase();

      final jamaahName = getJamaahFullName(document.jamaahId).toLowerCase();
      final jamaahEmail = getJamaahEmail(document.jamaahId).toLowerCase();
      final jamaahPhone = getJamaahPhone(document.jamaahId).toLowerCase();

      final matchesSearch =
          keyword.isEmpty ||
          requirementName.contains(keyword) ||
          requirementDescription.contains(keyword) ||
          jamaahName.contains(keyword) ||
          jamaahEmail.contains(keyword) ||
          jamaahPhone.contains(keyword);

      final matchesStatus =
          filter == 'Semua' ||
          (filter == 'Pending' && status == DocumentStatus.pending) ||
          (filter == 'Approved' && status == DocumentStatus.approved) ||
          (filter == 'Rejected' && status == DocumentStatus.rejected);

      return matchesSearch && matchesStatus;
    }).toList();
  }

  void changeStatusFilter(String value) {
    selectedStatusFilter.value = value;
  }

  void refreshSearch() {
    documents.refresh();
  }

  Future<void> approveDocument(JamaahDocumentModel document) async {
    final documentId = document.id?.trim() ?? '';

    if (documentId.isEmpty) {
      Get.snackbar(
        'Dokumen tidak valid',
        'ID dokumen tidak ditemukan',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      await _repository.approveDocument(documentId);

      await _notificationRepository.createBookingNotification(
        jamaahId: document.jamaahId ?? '',
        packageId: '',
        seatNumber: 0,
        status: 'approved',
        title:
            '${getRequirementName(document.documentRequirementId)} Disetujui',
        message:
            'Dokumen ${getRequirementName(document.documentRequirementId)} telah diverifikasi admin.',
        routeName: AppRoutes.jamaahDocuments,
      );

      await loadDocuments();

      Get.snackbar(
        'Berhasil',
        'Dokumen berhasil disetujui',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (error) {
      debugPrint('APPROVE DOCUMENT ERROR: $error');

      Get.snackbar(
        'Gagal approve dokumen',
        error.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> rejectDocument({
    required JamaahDocumentModel document,
    required String note,
  }) async {
    final documentId = document.id?.trim() ?? '';
    final cleanNote = note.trim();

    if (documentId.isEmpty) {
      Get.snackbar(
        'Dokumen tidak valid',
        'ID dokumen tidak ditemukan',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (cleanNote.isEmpty) {
      Get.snackbar(
        'Catatan wajib diisi',
        'Tuliskan alasan dokumen ditolak',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      await _repository.rejectDocument(documentId: documentId, note: cleanNote);

      await _notificationRepository.createBookingNotification(
        jamaahId: document.jamaahId ?? '',
        packageId: '',
        seatNumber: 0,
        status: 'rejected',
        title: '${getRequirementName(document.documentRequirementId)} Ditolak',
        message: 'Catatan: $cleanNote. Silakan unggah ulang dokumen.',
        routeName: AppRoutes.jamaahDocuments,
      );

      await loadDocuments();

      Get.snackbar(
        'Berhasil',
        'Dokumen berhasil ditolak',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (error) {
      debugPrint('REJECT DOCUMENT ERROR: $error');

      Get.snackbar(
        'Gagal reject dokumen',
        error.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> deleteDocument(JamaahDocumentModel document) async {
    final documentId = document.id?.trim() ?? '';

    if (documentId.isEmpty) return;

    try {
      await _repository.deleteDocument(documentId);
      await loadDocuments();

      Get.snackbar(
        'Berhasil',
        'Dokumen berhasil dihapus',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (error) {
      debugPrint('DELETE DOCUMENT ERROR: $error');

      Get.snackbar(
        'Gagal hapus dokumen',
        error.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
