import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Document Status', () {
    test('Approved document counted correctly', () {
      final documents = ['approved', 'approved', 'pending', 'rejected'];

      final approved = documents.where((e) => e == 'approved').length;

      expect(approved, equals(2));
    });
  });
}
