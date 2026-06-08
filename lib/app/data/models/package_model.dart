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
      id: json['id'],
      packageName: json['packageName'],
      durationDays: json['durationDays'],
      capacity: json['capacity'],
      bookedSeats: json['bookedSeats'],
      price: (json['price'] ?? 0).toDouble(),
      departureDate: json['departureDate'] == null
          ? null
          : DateTime.parse(json['departureDate']),
      returnDate: json['returnDate'] == null
          ? null
          : DateTime.parse(json['returnDate']),
      makkahHotel: json['makkahHotel'],
      makkahHotelStars: json['makkahHotelStars'],
      madinahHotel: json['madinahHotel'],
      madinahHotelStars: json['madinahHotelStars'],
      guideId: json['guideId'],
      isActive: json['isActive'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'packageName': packageName,
      'durationDays': durationDays,
      'capacity': capacity,
      'bookedSeats': bookedSeats,
      'price': price,
      'departureDate': departureDate?.toIso8601String(),
      'returnDate': returnDate?.toIso8601String(),
      'makkahHotel': makkahHotel,
      'makkahHotelStars': makkahHotelStars,
      'madinahHotel': madinahHotel,
      'madinahHotelStars': madinahHotelStars,
      'guideId': guideId,
      'isActive': isActive,
    };
  }
}
