import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:haramain_os/app/data/models/document_status.dart';

import 'jamaah_document_controller.dart';

class JamaahDocumentView extends GetView<JamaahDocumentController> {
  const JamaahDocumentView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Checklist Dokumen'), centerTitle: true),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildProgressCard(),
              const SizedBox(height: 16),
              Expanded(child: _buildDocumentList()),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildProgressCard() {
    final total = controller.totalRequiredDocumentCount;
    final approved = controller.approvedDocumentCount;
    final pending = controller.pendingDocumentCount;
    final rejected = controller.rejectedDocumentCount;
    final percentage = controller.completionPercentage;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Kelengkapan Dokumen',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: percentage,
              minHeight: 8,
              borderRadius: BorderRadius.circular(20),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _ProgressInfo(
                    label: 'Approved',
                    value: approved.toString(),
                    color: Colors.green,
                  ),
                ),
                Expanded(
                  child: _ProgressInfo(
                    label: 'Pending',
                    value: pending.toString(),
                    color: Colors.orange,
                  ),
                ),
                Expanded(
                  child: _ProgressInfo(
                    label: 'Rejected',
                    value: rejected.toString(),
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '$approved dari $total dokumen telah diverifikasi',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentList() {
    if (controller.packageDocumentRequirements.isEmpty) {
      return const Center(child: Text('Belum ada dokumen yang diwajibkan.'));
    }

    return RefreshIndicator(
      onRefresh: controller.loadJamaahDocuments,
      child: ListView.builder(
        itemCount: controller.packageDocumentRequirements.length,
        itemBuilder: (context, index) {
          final packageDoc = controller.packageDocumentRequirements[index];
          final documentRequirementId = packageDoc.documentRequirementId;

          final requirement = controller.getRequirementById(
            documentRequirementId,
          );

          if (requirement == null) {
            return const SizedBox();
          }

          final jamaahDocument = controller.getJamaahDocumentByRequirementId(
            documentRequirementId,
          );

          final status = jamaahDocument?.status ?? DocumentStatus.notUploaded;
          final note = jamaahDocument?.note ?? '';
          final fileUrl = jamaahDocument?.fileUrl ?? '';
          final hasFile = fileUrl.isNotEmpty;

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
                              requirement.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),

                            const SizedBox(height: 4),

                            Text(
                              requirement.description,
                              style: TextStyle(color: Colors.grey.shade700),
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

                      const SizedBox(width: 8),

                      Column(
                        children: [
                          Obx(() {
                            final isUploading = controller.isUploadingDocument(
                              documentRequirementId,
                            );

                            final isApproved =
                                status == DocumentStatus.approved;

                            return ElevatedButton.icon(
                              onPressed: isUploading || isApproved
                                  ? null
                                  : () async {
                                      await controller.pickAndUploadDocument(
                                        documentRequirementId:
                                            documentRequirementId,
                                      );
                                    },
                              icon: const Icon(Icons.upload_file, size: 18),
                              label: Text(
                                status == DocumentStatus.notUploaded ||
                                        status == DocumentStatus.rejected
                                    ? 'Upload'
                                    : 'Ganti',
                              ),
                            );
                          }),

                          const SizedBox(height: 8),

                          OutlinedButton.icon(
                            onPressed: status == DocumentStatus.approved
                                ? null
                                : () async {
                                    final document = controller
                                        .getJamaahDocumentByRequirementId(
                                          documentRequirementId,
                                        );

                                    if (document == null) return;

                                    final confirm = await Get.dialog<bool>(
                                      AlertDialog(
                                        title: const Text('Hapus Dokumen'),
                                        content: const Text(
                                          'Yakin ingin menghapus dokumen ini?',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Get.back(result: false),
                                            child: const Text('Batal'),
                                          ),
                                          ElevatedButton(
                                            onPressed: () =>
                                                Get.back(result: true),
                                            child: const Text('Hapus'),
                                          ),
                                        ],
                                      ),
                                    );

                                    if (confirm == true) {
                                      await controller.deleteDocument(
                                        document.id!,
                                      );
                                    }
                                  },
                            icon: const Icon(Icons.delete_outline, size: 18),
                            label: const Text('Hapus'),
                          ),
                        ],
                      ),
                    ],
                  ),

                  if (hasFile) ...[
                    const SizedBox(height: 14),

                    _UploadedFilePreview(fileUrl: fileUrl, status: status),
                  ],
                ],
              ),
            ),
          );
        },
      ),
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
      onTap: () => _openPreview(context),
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
                      width: 54,
                      height: 54,
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
                    'Dokumen sudah terunggah',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    _isImage
                        ? 'Ketuk untuk melihat preview'
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
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(Icons.description_outlined, color: color),
    );
  }

  void _openPreview(BuildContext context) {
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
