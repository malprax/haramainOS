class BusModel {
  final String id;
  final String busNumber;
  final String city;
  final String route;
  final DateTime departureTime;
  final bool isReady;

  BusModel({
    required this.id,
    required this.busNumber,
    required this.city,
    required this.route,
    required this.departureTime,
    required this.isReady,
  });
}
