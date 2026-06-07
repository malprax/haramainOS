class HotelModel {
  final String id;
  final String hotelName;
  final String city;
  final DateTime checkIn;
  final DateTime checkOut;
  final bool isReady;

  HotelModel({
    required this.id,
    required this.hotelName,
    required this.city,
    required this.checkIn,
    required this.checkOut,
    required this.isReady,
  });
}
