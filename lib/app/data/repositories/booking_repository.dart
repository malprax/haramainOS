import 'package:get/get.dart';

import '../../core/database/database_service.dart';
import '../models/booking_model.dart';

class BookingRepository {
  final DatabaseService _database = Get.find();

  static const String collection = 'bookings';

  Future<void> createBooking(BookingModel booking) async {
    await _database.create(
      collection: collection,
      documentId: booking.id!,
      data: booking.toJson(),
    );
  }

  Future<List<BookingModel>> getBookings() async {
    final result = await _database.readAll(collection: collection);

    return result.map((item) => BookingModel.fromJson(item)).toList();
  }

  Future<void> updateBooking(BookingModel booking) async {
    await _database.update(
      collection: collection,
      documentId: booking.id!,
      data: booking.toJson(),
    );
  }

  Future<void> deleteBooking(String bookingId) async {
    await _database.delete(collection: collection, documentId: bookingId);
  }
}
