enum BookingStatus { available, pending, approved, rejected }

class BookingModel {
  String? id;
  String? packageId;
  String? jamaahId;
  int? seatNumber;
  BookingStatus? status;
  DateTime? bookingDate;

  BookingModel({
    this.id,
    this.packageId,
    this.jamaahId,
    this.seatNumber,
    this.status,
    this.bookingDate,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id']?.toString(),
      packageId: json['packageId']?.toString(),
      jamaahId: json['jamaahId']?.toString(),
      seatNumber: int.tryParse(json['seatNumber']?.toString() ?? ''),
      status: BookingStatus.values.firstWhere(
        (item) => item.name == json['status']?.toString(),
        orElse: () => BookingStatus.available,
      ),
      bookingDate: DateTime.tryParse(json['bookingDate']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'packageId': packageId,
      'jamaahId': jamaahId,
      'seatNumber': seatNumber,
      'status': status?.name,
      'bookingDate': _formatPocketBaseDate(bookingDate),
    };

    data.removeWhere((key, value) => value == null);

    return data;
  }

  String? _formatPocketBaseDate(DateTime? date) {
    if (date == null) return null;

    final utc = date.toUtc();

    return '${utc.year.toString().padLeft(4, '0')}-'
        '${utc.month.toString().padLeft(2, '0')}-'
        '${utc.day.toString().padLeft(2, '0')} '
        '${utc.hour.toString().padLeft(2, '0')}:'
        '${utc.minute.toString().padLeft(2, '0')}:'
        '${utc.second.toString().padLeft(2, '0')}.'
        '${utc.millisecond.toString().padLeft(3, '0')}Z';
  }
}
