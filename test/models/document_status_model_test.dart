import 'package:flutter_test/flutter_test.dart';
import 'package:haramain_os/app/data/models/document_status.dart';

void main() {
  group('DocumentStatus Model', () {
    test('should contain approved status', () {
      expect(DocumentStatus.approved.name, equals('approved'));
    });

    test('should contain pending status', () {
      expect(DocumentStatus.pending.name, equals('pending'));
    });

    test('should contain rejected status', () {
      expect(DocumentStatus.rejected.name, equals('rejected'));
    });

    test('should contain notUploaded status', () {
      expect(DocumentStatus.notUploaded.name, equals('notUploaded'));
    });
  });
}
