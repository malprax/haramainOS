import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package_controller.dart';

class PackageForm extends GetView<PackageController> {
  const PackageForm({super.key});

  @override
  Widget build(BuildContext context) {
    final isEdit = controller.selectedPackage.value != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Paket' : 'Buat Paket'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: controller.packageNameController,
            decoration: const InputDecoration(
              labelText: 'Nama Paket',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),

          TextField(
            controller: controller.departureDateController,
            readOnly: true,
            onTap: () => controller.pickDepartureDate(context),
            decoration: const InputDecoration(
              labelText: 'Tanggal Keberangkatan',
              border: OutlineInputBorder(),
              suffixIcon: Icon(Icons.calendar_month),
            ),
          ),
          const SizedBox(height: 12),

          TextField(
            controller: controller.returnDateController,
            readOnly: true,
            onTap: () => controller.pickReturnDate(context),
            decoration: const InputDecoration(
              labelText: 'Tanggal Kepulangan',
              border: OutlineInputBorder(),
              suffixIcon: Icon(Icons.calendar_month),
            ),
          ),
          const SizedBox(height: 8),

          Obx(
            () => Text(
              controller.calculatedDurationDays.value > 0
                  ? 'Durasi paket: ${controller.calculatedDurationDays.value} hari'
                  : 'Durasi otomatis dihitung dari tanggal keberangkatan dan kepulangan.',
              style: TextStyle(
                color: controller.calculatedDurationDays.value > 0
                    ? Colors.green.shade800
                    : Colors.grey.shade700,
                fontStyle: FontStyle.italic,
                fontWeight: controller.calculatedDurationDays.value > 0
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
          ),

          const SizedBox(height: 12),

          TextField(
            controller: controller.capacityController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Kapasitas Maksimal 25',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),

          TextField(
            controller: controller.priceController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Harga Paket',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),

          TextField(
            controller: controller.makkahHotelController,
            onChanged: (_) {
              if (controller.makkahHotelController.text.trim().isEmpty) {
                controller.selectedMakkahHotelStars.value = null;
              }
            },
            decoration: const InputDecoration(
              labelText: 'Hotel Makkah',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),

          Obx(
            () => DropdownButtonFormField<int>(
              value: controller.selectedMakkahHotelStars.value,
              decoration: const InputDecoration(
                labelText: 'Bintang Hotel Makkah',
                border: OutlineInputBorder(),
              ),
              hint: const Text('Pilih bintang hotel'),
              items: List.generate(5, (index) {
                final star = index + 1;
                return DropdownMenuItem<int>(
                  value: star,
                  child: Text('${'⭐' * star} ($star)'),
                );
              }),
              onChanged: (value) {
                controller.selectedMakkahHotelStars.value = value;
              },
            ),
          ),

          const SizedBox(height: 12),

          TextField(
            controller: controller.madinahHotelController,
            onChanged: (_) {
              if (controller.madinahHotelController.text.trim().isEmpty) {
                controller.selectedMadinahHotelStars.value = null;
              }
            },
            decoration: const InputDecoration(
              labelText: 'Hotel Madinah',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),

          Obx(
            () => DropdownButtonFormField<int>(
              value: controller.selectedMadinahHotelStars.value,
              decoration: const InputDecoration(
                labelText: 'Bintang Hotel Madinah',
                border: OutlineInputBorder(),
              ),
              hint: const Text('Pilih bintang hotel'),
              items: List.generate(5, (index) {
                final star = index + 1;
                return DropdownMenuItem<int>(
                  value: star,
                  child: Text('${'⭐' * star} ($star)'),
                );
              }),
              onChanged: (value) {
                controller.selectedMadinahHotelStars.value = value;
              },
            ),
          ),

          const SizedBox(height: 20),

          Obx(
            () => SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed: controller.isLoading.value
                    ? null
                    : controller.savePackage,
                icon: controller.isLoading.value
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save),
                label: Text(
                  controller.isLoading.value ? 'Menyimpan...' : 'Simpan Paket',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade800,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
