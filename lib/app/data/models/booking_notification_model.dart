class BookingNotificationModel {
  String? id;
  String? jamaahId;
  String? packageId;
  int? seatNumber;
  String? status;
  String? title;
  String? message;
  String? routeName;
  bool isRead;
  DateTime? createdAt;

  BookingNotificationModel({
    this.id,
    this.jamaahId,
    this.packageId,
    this.seatNumber,
    this.status,
    this.title,
    this.message,
    this.routeName,
    this.isRead = false,
    this.createdAt,
  });

  factory BookingNotificationModel.fromJson(Map<String, dynamic> json) {
    return BookingNotificationModel(
      id: json['id']?.toString(),
      jamaahId: json['jamaahId']?.toString(),
      packageId: json['packageId']?.toString(),
      seatNumber: int.tryParse(json['seatNumber']?.toString() ?? ''),
      status: json['status']?.toString(),
      title: json['title']?.toString(),
      message: json['message']?.toString(),
      routeName: json['routeName']?.toString(),
      isRead: json['isRead'] == true,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'jamaahId': jamaahId,
      'packageId': packageId,
      'seatNumber': seatNumber,
      'status': status,
      'title': title,
      'message': message,
      'routeName': routeName,
      'isRead': isRead,
      'createdAt': _formatPocketBaseDate(createdAt),
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
