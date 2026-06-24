import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:haramain_os/app/data/models/document_status.dart';
import 'package:haramain_os/app/data/models/jamaah_document_model.dart';

import 'admin_document_controller.dart';

class AdminDocumentView extends GetView<AdminDocumentController> {
  const AdminDocumentView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verifikasi Dokumen'),
        centerTitle: true,
      ),
      body: Obx(() {
        final isLoading = controller.isLoading.value;
        final selectedFilter = controller.selectedStatusFilter.value;
        final documents = controller.filteredDocuments;

        if (isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: controller.refreshData,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _SummaryCard(controller: controller),
              const SizedBox(height: 14),
              _SearchAndFilter(
                controller: controller,
                selectedFilter: selectedFilter,
              ),
              const SizedBox(height: 14),
              if (documents.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 40),
                  child: Center(
                    child: Text('Belum ada dokumen sesuai filter.'),
                  ),
                )
              else
                ...documents.map(
                  (document) => _AdminDocumentCard(
                    document: document,
                    controller: controller,
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final AdminDocumentController controller;

  const _SummaryCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Ringkasan Verifikasi',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _ProgressInfo(
                    label: 'Total',
                    value: controller.totalDocumentCount.toString(),
                    color: Colors.blueGrey,
                  ),
                ),
                Expanded(
                  child: _ProgressInfo(
                    label: 'Pending',
                    value: controller.pendingDocumentCount.toString(),
                    color: Colors.orange,
                  ),
                ),
                Expanded(
                  child: _ProgressInfo(
                    label: 'Approved',
                    value: controller.approvedDocumentCount.toString(),
                    color: Colors.green,
                  ),
                ),
                Expanded(
                  child: _ProgressInfo(
                    label: 'Rejected',
                    value: controller.rejectedDocumentCount.toString(),
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchAndFilter extends StatelessWidget {
  final AdminDocumentController controller;
  final String selectedFilter;

  const _SearchAndFilter({
    required this.controller,
    required this.selectedFilter,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: controller.searchController,
          onChanged: (_) => controller.refreshSearch(),
          decoration: InputDecoration(
            hintText: 'Cari nama jamaah atau dokumen...',
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _FilterChipButton(
                label: 'Semua',
                selectedFilter: selectedFilter,
                onTap: controller.changeStatusFilter,
              ),
              _FilterChipButton(
                label: 'Pending',
                selectedFilter: selectedFilter,
                onTap: controller.changeStatusFilter,
              ),
              _FilterChipButton(
                label: 'Approved',
                selectedFilter: selectedFilter,
                onTap: controller.changeStatusFilter,
              ),
              _FilterChipButton(
                label: 'Rejected',
                selectedFilter: selectedFilter,
                onTap: controller.changeStatusFilter,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FilterChipButton extends StatelessWidget {
  final String label;
  final String selectedFilter;
  final ValueChanged<String> onTap;

  const _FilterChipButton({
    required this.label,
    required this.selectedFilter,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final selected = selectedFilter == label;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) {
          onTap(label);
        },
      ),
    );
  }
}

class _AdminDocumentCard extends StatelessWidget {
  final JamaahDocumentModel document;
  final AdminDocumentController controller;

  const _AdminDocumentCard({required this.document, required this.controller});

  @override
  Widget build(BuildContext context) {
    final status = document.status ?? DocumentStatus.pending;
    final fileUrl = document.fileUrl ?? '';
    final note = document.note ?? '';

    final documentName = controller.getRequirementName(
      document.documentRequirementId,
    );

    final description = controller.getRequirementDescription(
      document.documentRequirementId,
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _StatusIcon(status: status),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        documentName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Jamaah: ${controller.getJamaahFullName(document.jamaahId)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        controller.getJamaahEmail(document.jamaahId),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _StatusChip(status: status),
                      if (note.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Catatan: $note',
                          style: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Hapus dokumen',
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () {
                    _showDeleteDialog(document, controller);
                  },
                ),
              ],
            ),
            if (fileUrl.isNotEmpty) ...[
              const SizedBox(height: 12),
              _UploadedFilePreview(fileUrl: fileUrl, status: status),
            ],
            const SizedBox(height: 12),
            _ActionButtons(
              status: status,
              onApprove: () => _showApproveDialog(document, controller),
              onReject: () => _showRejectDialog(document, controller),
            ),
          ],
        ),
      ),
    );
  }

  void _showApproveDialog(
    JamaahDocumentModel document,
    AdminDocumentController controller,
  ) {
    Get.dialog(
      AlertDialog(
        title: const Text('Approve Dokumen'),
        content: Text(
          'Setujui dokumen ${controller.getRequirementName(document.documentRequirementId)}?',
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Batal')),
          ElevatedButton.icon(
            onPressed: () async {
              Get.back();
              await controller.approveDocument(document);
            },
            icon: const Icon(Icons.check),
            label: const Text('Approve'),
          ),
        ],
      ),
    );
  }

  void _showRejectDialog(
    JamaahDocumentModel document,
    AdminDocumentController controller,
  ) {
    final noteController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text('Reject Dokumen'),
        content: TextField(
          controller: noteController,
          maxLines: 4,
          decoration: const InputDecoration(
            labelText: 'Catatan penolakan',
            hintText: 'Contoh: Foto KTP buram, mohon upload ulang.',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Batal')),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              final note = noteController.text.trim();
              Get.back();

              await controller.rejectDocument(document: document, note: note);
            },
            icon: const Icon(Icons.close),
            label: const Text('Reject'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(
    JamaahDocumentModel document,
    AdminDocumentController controller,
  ) {
    Get.dialog(
      AlertDialog(
        title: const Text('Hapus Dokumen'),
        content: const Text(
          'Dokumen akan dihapus permanen dari database. Lanjutkan?',
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Batal')),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Get.back();
              await controller.deleteDocument(document);
            },
            icon: const Icon(Icons.delete),
            label: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  final DocumentStatus status;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const _ActionButtons({
    required this.status,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final isApproved = status == DocumentStatus.approved;
    final isRejected = status == DocumentStatus.rejected;

    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: isRejected ? null : onReject,
            icon: const Icon(Icons.close),
            label: const Text('Reject'),
            style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: isApproved ? null : onApprove,
            icon: const Icon(Icons.check),
            label: const Text('Approve'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade700,
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}

class _UploadedFilePreview extends StatelessWidget {
  final String fileUrl;
  final DocumentStatus status;

  const _UploadedFilePreview({required this.fileUrl, required this.status});

  bool get _isImage {
    final url = fileUrl.toLowerCase();

    return url.endsWith('.jpg') ||
        url.endsWith('.jpeg') ||
        url.endsWith('.png') ||
        url.contains('.jpg?') ||
        url.contains('.jpeg?') ||
        url.contains('.png?');
  }

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(status);

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => _openPreview(),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.18)),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: _isImage
                  ? Image.network(
                      fileUrl,
                      width: 64,
                      height: 64,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _fileIcon(color),
                    )
                  : _fileIcon(color),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Preview Dokumen',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    _isImage
                        ? 'Ketuk untuk melihat gambar'
                        : 'Ketuk untuk membuka file',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                  ),
                ],
              ),
            ),
            Icon(Icons.visibility_outlined, color: color),
          ],
        ),
      ),
    );
  }

  Widget _fileIcon(Color color) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(Icons.description_outlined, color: color),
    );
  }

  void _openPreview() {
    if (_isImage) {
      Get.dialog(
        Dialog(
          insetPadding: const EdgeInsets.all(18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  color: Colors.green.shade50,
                  child: Row(
                    children: [
                      const Icon(
                        Icons.description_outlined,
                        color: Colors.green,
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Preview Dokumen',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      IconButton(
                        onPressed: Get.back,
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: Container(
                    color: Colors.black,
                    child: InteractiveViewer(
                      minScale: 0.8,
                      maxScale: 4,
                      child: Image.network(fileUrl, fit: BoxFit.contain),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      return;
    }

    launchUrl(Uri.parse(fileUrl), mode: LaunchMode.externalApplication);
  }

  Color _statusColor(DocumentStatus status) {
    switch (status) {
      case DocumentStatus.pending:
        return Colors.orange;
      case DocumentStatus.approved:
        return Colors.green;
      case DocumentStatus.rejected:
        return Colors.red;
      case DocumentStatus.notUploaded:
        return Colors.grey;
    }
  }
}

class _ProgressInfo extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _ProgressInfo({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(label),
      ],
    );
  }
}

class _StatusIcon extends StatelessWidget {
  final DocumentStatus status;

  const _StatusIcon({required this.status});

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case DocumentStatus.pending:
        return const CircleAvatar(
          backgroundColor: Colors.orange,
          child: Icon(Icons.hourglass_top, color: Colors.white),
        );
      case DocumentStatus.approved:
        return const CircleAvatar(
          backgroundColor: Colors.green,
          child: Icon(Icons.check, color: Colors.white),
        );
      case DocumentStatus.rejected:
        return const CircleAvatar(
          backgroundColor: Colors.red,
          child: Icon(Icons.close, color: Colors.white),
        );
      case DocumentStatus.notUploaded:
        return const CircleAvatar(
          backgroundColor: Colors.grey,
          child: Icon(Icons.upload_file, color: Colors.white),
        );
    }
  }
}

class _StatusChip extends StatelessWidget {
  final DocumentStatus status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _statusText(status),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  String _statusText(DocumentStatus status) {
    switch (status) {
      case DocumentStatus.pending:
        return 'Menunggu Verifikasi';
      case DocumentStatus.approved:
        return 'Disetujui';
      case DocumentStatus.rejected:
        return 'Ditolak';
      case DocumentStatus.notUploaded:
        return 'Belum Upload';
    }
  }

  Color _statusColor(DocumentStatus status) {
    switch (status) {
      case DocumentStatus.pending:
        return Colors.orange;
      case DocumentStatus.approved:
        return Colors.green;
      case DocumentStatus.rejected:
        return Colors.red;
      case DocumentStatus.notUploaded:
        return Colors.grey;
    }
  }
}
