import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:haramain_os/app/data/models/document_requirement_model.dart';
import 'package:haramain_os/app/data/models/package_model.dart';

import 'package:haramain_os/app/data/repositories/package_repository.dart';
import 'package:haramain_os/app/data/repositories/package_document_requirement_repository.dart';

import '../../../routes/app_routes.dart';

class JamaahPackageController extends GetxController {
  final PackageRepository _packageRepository = PackageRepository();

  final PackageDocumentRequirementRepository
  _packageDocumentRequirementRepository =
      PackageDocumentRequirementRepository();

  final isLoading = false.obs;

  final packages = <PackageModel>[].obs;
  final selectedPackage = Rxn<PackageModel>();

  final documentRequirements = <DocumentRequirementModel>[].obs;
  final selectedDocumentRequirementIds = <String>[].obs;

  final selectedStatusFilter = 'Semua'.obs;
  final calculatedDurationDays = 0.obs;

  final selectedMakkahHotelStars = RxnInt();
  final selectedMadinahHotelStars = RxnInt();

  final searchController = TextEditingController();
  final packageNameController = TextEditingController();
  final capacityController = TextEditingController();
  final priceController = TextEditingController();
  final makkahHotelController = TextEditingController();
  final madinahHotelController = TextEditingController();
  final departureDateController = TextEditingController();
  final returnDateController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    loadDocumentRequirements();
    initializeData();
  }

  Future<void> initializeData() async {
    isLoading.value = true;

    try {
      packages.assignAll(await _packageRepository.getPackages());
      packages.refresh();
    } catch (error) {
      Get.snackbar(
        'Gagal memuat paket',
        error.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadPackages() async {
    packages.assignAll(await _packageRepository.getPackages());
    packages.refresh();
  }

  List<PackageModel> get filteredPackages {
    final keyword = searchController.text.trim().toLowerCase();

    return packages.where((package) {
      final packageName = (package.packageName ?? '').toLowerCase();

      final matchesSearch = keyword.isEmpty || packageName.contains(keyword);

      final matchesStatus =
          selectedStatusFilter.value == 'Semua' ||
          (selectedStatusFilter.value == 'Aktif' && package.isActive == true) ||
          (selectedStatusFilter.value == 'Tidak Aktif' &&
              package.isActive == false);

      return matchesSearch && matchesStatus;
    }).toList();
  }

  List<PackageModel> get activePackages {
    return packages.where((package) => package.isActive == true).toList();
  }

  void changeStatusFilter(String value) {
    selectedStatusFilter.value = value;
  }

  void refreshSearch() {
    packages.refresh();
  }

  void openCreateForm() {
    selectedPackage.value = null;

    packageNameController.clear();
    capacityController.text = '25';
    priceController.clear();
    makkahHotelController.clear();
    madinahHotelController.clear();
    departureDateController.clear();
    returnDateController.clear();

    selectedMakkahHotelStars.value = null;
    selectedMadinahHotelStars.value = null;
    calculatedDurationDays.value = 0;

    selectedDocumentRequirementIds.clear();

    Get.toNamed(AppRoutes.adminPackageForm);
  }

  Future<void> openEditForm(PackageModel package) async {
    selectedPackage.value = package;

    packageNameController.text = package.packageName ?? '';
    capacityController.text = '${package.capacity ?? 25}';
    priceController.text = package.price == null
        ? ''
        : '${package.price!.toInt()}';

    makkahHotelController.text = package.makkahHotel ?? '';
    madinahHotelController.text = package.madinahHotel ?? '';

    departureDateController.text = formatDateInput(package.departureDate);
    returnDateController.text = formatDateInput(package.returnDate);

    selectedMakkahHotelStars.value = package.makkahHotelStars;
    selectedMadinahHotelStars.value = package.madinahHotelStars;

    selectedDocumentRequirementIds.clear();

    if (package.id != null && package.id!.isNotEmpty) {
      await loadSelectedDocumentRequirements(package.id!);
    }

    calculateDurationDays();

    Get.toNamed(AppRoutes.adminPackageForm);
  }

  Future<void> loadSelectedDocumentRequirements(String packageId) async {
    final items = await _packageDocumentRequirementRepository.getByPackageId(
      packageId,
    );

    selectedDocumentRequirementIds.assignAll(
      items
          .map((item) => item.documentRequirementId)
          .whereType<String>()
          .toList(),
    );
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

  void toggleDocumentRequirement({
    required String documentRequirementId,
    required bool isChecked,
  }) {
    if (documentRequirementId.isEmpty) return;

    if (isChecked) {
      if (!selectedDocumentRequirementIds.contains(documentRequirementId)) {
        selectedDocumentRequirementIds.add(documentRequirementId);
      }
    } else {
      selectedDocumentRequirementIds.remove(documentRequirementId);
    }

    selectedDocumentRequirementIds.refresh();
  }

  Future<void> pickDepartureDate(BuildContext context) async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate:
          parseDisplayDate(departureDateController.text) ?? DateTime.now(),
      firstDate: DateTime(2025),
      lastDate: DateTime(2035),
    );

    if (selectedDate == null) return;

    departureDateController.text = formatDateInput(selectedDate);
    calculateDurationDays();
  }

  Future<void> pickReturnDate(BuildContext context) async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate:
          parseDisplayDate(returnDateController.text) ??
          parseDisplayDate(departureDateController.text) ??
          DateTime.now(),
      firstDate: DateTime(2025),
      lastDate: DateTime(2035),
    );

    if (selectedDate == null) return;

    returnDateController.text = formatDateInput(selectedDate);
    calculateDurationDays();
  }

  String formatDateInput(DateTime? date) {
    if (date == null) return '';

    return '${date.day.toString().padLeft(2, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.year}';
  }

  DateTime? parseDisplayDate(String text) {
    try {
      if (text.trim().isEmpty) return null;

      final parts = text.trim().split('-');
      if (parts.length != 3) return null;

      return DateTime(
        int.parse(parts[2]),
        int.parse(parts[1]),
        int.parse(parts[0]),
      );
    } catch (_) {
      return null;
    }
  }

  void calculateDurationDays() {
    final departureDate = parseDisplayDate(departureDateController.text);
    final returnDate = parseDisplayDate(returnDateController.text);

    if (departureDate == null || returnDate == null) {
      calculatedDurationDays.value = 0;
      return;
    }

    if (returnDate.isBefore(departureDate)) {
      calculatedDurationDays.value = 0;
      return;
    }

    calculatedDurationDays.value =
        returnDate.difference(departureDate).inDays + 1;
  }

  Future<void> savePackage() async {
    if (isLoading.value) return;

    isLoading.value = true;

    try {
      final editingPackage = selectedPackage.value;

      final packageId =
          editingPackage?.id ??
          'package_${DateTime.now().millisecondsSinceEpoch}';

      final packageName = packageNameController.text.trim();
      final inputCapacity = int.tryParse(capacityController.text.trim()) ?? 25;
      final fixedCapacity = inputCapacity > 25 ? 25 : inputCapacity;
      final price = double.tryParse(priceController.text.trim()) ?? 0;

      final departureDate = parseDisplayDate(departureDateController.text);
      final returnDate = parseDisplayDate(returnDateController.text);

      final makkahHotel = makkahHotelController.text.trim();
      final madinahHotel = madinahHotelController.text.trim();

      final makkahStars = selectedMakkahHotelStars.value;
      final madinahStars = selectedMadinahHotelStars.value;

      if (packageName.isEmpty) {
        Get.snackbar(
          'Gagal',
          'Nama paket wajib diisi',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      if (departureDate == null || returnDate == null) {
        Get.snackbar(
          'Gagal',
          'Tanggal keberangkatan dan kepulangan wajib dipilih dari kalender',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      if (returnDate.isBefore(departureDate)) {
        Get.snackbar(
          'Gagal',
          'Tanggal kepulangan tidak boleh sebelum tanggal keberangkatan',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      final durationDays = returnDate.difference(departureDate).inDays + 1;

      if (durationDays <= 0) {
        Get.snackbar(
          'Gagal',
          'Durasi paket belum valid',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      if (fixedCapacity <= 0) {
        Get.snackbar(
          'Gagal',
          'Kapasitas wajib lebih dari 0',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      if (inputCapacity > 25) {
        Get.snackbar(
          'Kapasitas dibatasi',
          'Maksimal kapasitas satu gelombang adalah 25 jamaah',
          snackPosition: SnackPosition.BOTTOM,
        );
      }

      if (makkahHotel.isEmpty && makkahStars != null) {
        Get.snackbar(
          'Gagal',
          'Isi nama hotel Makkah terlebih dahulu',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      if (makkahHotel.isNotEmpty && makkahStars == null) {
        Get.snackbar(
          'Gagal',
          'Pilih bintang hotel Makkah',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      if (madinahHotel.isEmpty && madinahStars != null) {
        Get.snackbar(
          'Gagal',
          'Isi nama hotel Madinah terlebih dahulu',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      if (madinahHotel.isNotEmpty && madinahStars == null) {
        Get.snackbar(
          'Gagal',
          'Pilih bintang hotel Madinah',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      final package = PackageModel(
        id: packageId,
        packageName: packageName,
        durationDays: durationDays,
        capacity: fixedCapacity,
        bookedSeats: editingPackage?.bookedSeats ?? 0,
        price: price,
        departureDate: departureDate,
        returnDate: returnDate,
        makkahHotel: makkahHotel,
        makkahHotelStars: makkahStars,
        madinahHotel: madinahHotel,
        madinahHotelStars: madinahStars,
        guideId: editingPackage?.guideId ?? '',
        isActive: editingPackage?.isActive ?? true,
      );

      if (editingPackage == null) {
        await _packageRepository.createPackage(package);
      } else {
        await _packageRepository.updatePackage(package);
      }

      await _packageDocumentRequirementRepository.saveForPackage(
        packageId: packageId,
        documentRequirementIds: selectedDocumentRequirementIds.toList(),
      );

      await loadPackages();

      Get.offNamed(AppRoutes.adminPackages);

      Future.delayed(const Duration(milliseconds: 300), () {
        Get.snackbar(
          'Berhasil',
          editingPackage == null
              ? 'Paket berhasil dibuat'
              : 'Paket berhasil diperbarui',
          snackPosition: SnackPosition.BOTTOM,
        );
      });
    } catch (error) {
      Get.snackbar(
        'Gagal menyimpan paket',
        error.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deletePackage(PackageModel package) async {
    if (package.id == null || package.id!.isEmpty) return;

    try {
      await _packageRepository.deletePackage(package.id!);

      await _packageDocumentRequirementRepository.deleteByPackageId(
        package.id!,
      );

      await loadPackages();

      Get.snackbar(
        'Berhasil',
        'Paket berhasil dihapus',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (error) {
      Get.snackbar(
        'Gagal menghapus paket',
        error.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void openAdminBooking(PackageModel package) {
    if (package.id == null || package.id!.isEmpty) {
      Get.snackbar(
        'Paket belum dipilih',
        'Silakan pilih paket terlebih dahulu',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    Get.toNamed(AppRoutes.adminBooking, arguments: package);
  }

  void openJamaahBooking(PackageModel package) {
    if (package.id == null || package.id!.isEmpty) {
      Get.snackbar(
        'Paket belum dipilih',
        'Silakan pilih paket terlebih dahulu',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    Get.toNamed(AppRoutes.jamaahBooking, arguments: package);
  }

  void openBooking(PackageModel package) {
    openAdminBooking(package);
  }

  @override
  void onClose() {
    searchController.dispose();
    packageNameController.dispose();
    capacityController.dispose();
    priceController.dispose();
    makkahHotelController.dispose();
    madinahHotelController.dispose();
    departureDateController.dispose();
    returnDateController.dispose();
    super.onClose();
  }
}
