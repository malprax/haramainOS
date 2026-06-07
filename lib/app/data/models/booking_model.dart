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
      id: json['id'],
      packageId: json['packageId'],
      jamaahId: json['jamaahId'],
      seatNumber: json['seatNumber'],
      status: BookingStatus.values.firstWhere(
        (item) => item.name == json['status'],
        orElse: () => BookingStatus.available,
      ),
      bookingDate: json['bookingDate'] == null
          ? null
          : DateTime.parse(json['bookingDate']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'packageId': packageId,
      'jamaahId': jamaahId,
      'seatNumber': seatNumber,
      'status': status?.name,
      'bookingDate': bookingDate?.toIso8601String(),
    };
  }
}
