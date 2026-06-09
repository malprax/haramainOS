class PackageModel {
  String? id;
  String? packageName;
  int? durationDays;
  int? capacity;
  int? bookedSeats;
  double? price;
  DateTime? departureDate;
  DateTime? returnDate;
  String? makkahHotel;
  int? makkahHotelStars;
  String? madinahHotel;
  int? madinahHotelStars;
  String? guideId;
  bool? isActive;

  PackageModel({
    this.id,
    this.packageName,
    this.durationDays,
    this.capacity,
    this.bookedSeats,
    this.price,
    this.departureDate,
    this.returnDate,
    this.makkahHotel,
    this.makkahHotelStars,
    this.madinahHotel,
    this.madinahHotelStars,
    this.guideId,
    this.isActive,
  });

  factory PackageModel.fromJson(Map<String, dynamic> json) {
    return PackageModel(
      id: json['id']?.toString(),
      packageName: json['packageName']?.toString(),
      durationDays: int.tryParse(json['durationDays']?.toString() ?? ''),
      capacity: int.tryParse(json['capacity']?.toString() ?? ''),
      bookedSeats: int.tryParse(json['bookedSeats']?.toString() ?? '') ?? 0,
      price: double.tryParse(json['price']?.toString() ?? '') ?? 0,
      departureDate: DateTime.tryParse(json['departureDate']?.toString() ?? ''),
      returnDate: DateTime.tryParse(json['returnDate']?.toString() ?? ''),
      makkahHotel: json['makkahHotel']?.toString(),
      makkahHotelStars: int.tryParse(
        json['makkahHotelStars']?.toString() ?? '',
      ),
      madinahHotel: json['madinahHotel']?.toString(),
      madinahHotelStars: int.tryParse(
        json['madinahHotelStars']?.toString() ?? '',
      ),
      guideId: json['guideId']?.toString(),
      isActive: json['isActive'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'packageName': packageName,
      'durationDays': durationDays,
      'capacity': capacity,
      'bookedSeats': bookedSeats ?? 0,
      'price': price ?? 0,
      'departureDate': _formatPocketBaseDate(departureDate),
      'returnDate': _formatPocketBaseDate(returnDate),
      'makkahHotel': makkahHotel,
      'makkahHotelStars': makkahHotelStars,
      'madinahHotel': madinahHotel,
      'madinahHotelStars': madinahHotelStars,
      'isActive': isActive ?? true,
    };

    if (guideId != null && guideId!.trim().isNotEmpty) {
      data['guideId'] = guideId;
    }

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
