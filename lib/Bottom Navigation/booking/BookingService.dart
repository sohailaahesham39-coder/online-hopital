import 'dart:async';
import 'package:flutter/material.dart';
import '../Payment/PaymentNotificationHelper.dart';


class BookingService {
  // Singleton pattern
  static final BookingService _instance = BookingService._internal();
  factory BookingService() => _instance;
  BookingService._internal() {
    _initializeData();
    _setupReminders();
  }

  // Storage for bookings
  List<Map<String, dynamic>> _bookings = [];

  // Stream controllers for live updates
  final _bookingsController = StreamController<List<Map<String, dynamic>>>.broadcast();
  Stream<List<Map<String, dynamic>>> get bookingsStream => _bookingsController.stream;

  void _initializeData() {
    // Add some sample bookings for demonstration
    final now = DateTime.now();

    _bookings = [
      {
        'id': 'bk_001',
        'service': 'General Checkup',
        'date': DateTime(now.year, now.month, now.day + 5).toIso8601String(),
        'time': '10:00 AM',
        'status': 'Upcoming',
        'price': 150,
        'doctor': 'Dr. Sarah Johnson',
        'bookingId': 'BK12345678',
        'paymentMethod': 'Credit Card',
      },
      {
        'id': 'bk_002',
        'service': 'Dental Cleaning',
        'date': DateTime(now.year, now.month, now.day + 7).toIso8601String(),
        'time': '2:30 PM',
        'status': 'Upcoming',
        'price': 120,
        'doctor': 'Dr. Michael Chen',
        'bookingId': 'BK23456789',
        'paymentMethod': 'Credit Card',
      },
      {
        'id': 'bk_003',
        'service': 'Eye Examination',
        'date': DateTime(now.year, now.month, now.day + 10).toIso8601String(),
        'time': '11:15 AM',
        'status': 'Upcoming',
        'price': 180,
        'doctor': 'Dr. Lisa Cooper',
        'bookingId': 'BK34567890',
        'paymentMethod': 'PayPal',
      },
      {
        'id': 'bk_004',
        'service': 'Physical Therapy',
        'date': DateTime(now.year, now.month, now.day - 7).toIso8601String(),
        'time': '3:00 PM',
        'status': 'Completed',
        'price': 200,
        'doctor': 'Dr. James Wilson',
        'bookingId': 'BK45678901',
        'paymentMethod': 'Credit Card',
      },
      {
        'id': 'bk_005',
        'service': 'MRI Scan',
        'date': DateTime(now.year, now.month, now.day - 14).toIso8601String(),
        'time': '9:30 AM',
        'status': 'Completed',
        'price': 450,
        'department': 'Radiology',
        'bookingId': 'BK56789012',
        'paymentMethod': 'Insurance',
      },
    ];
  }

  // Get all bookings
  Future<List<Map<String, dynamic>>> getBookings() async {
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: 800));
    return _bookings;
  }

  // Get upcoming bookings
  Future<List<Map<String, dynamic>>> getUpcomingBookings() async {
    await Future.delayed(Duration(milliseconds: 600));
    return _bookings.where((booking) => booking['status'] == 'Upcoming').toList();
  }

  // Get past bookings
  Future<List<Map<String, dynamic>>> getPastBookings() async {
    await Future.delayed(Duration(milliseconds: 600));
    return _bookings.where((booking) =>
    booking['status'] == 'Completed' ||
        booking['status'] == 'Cancelled').toList();
  }

  // Get booking by ID
  Future<Map<String, dynamic>?> getBookingById(String id) async {
    await Future.delayed(Duration(milliseconds: 300));
    final booking = _bookings.firstWhere(
          (booking) => booking['id'] == id,
      orElse: () => {},
    );
    return booking.isEmpty ? null : booking;
  }

  // Add a new booking
  Future<Map<String, dynamic>> addBooking(Map<String, dynamic> bookingData) async {
    // Simulate API call
    await Future.delayed(Duration(seconds: 1));

    final newBooking = {
      'id': 'bk_${DateTime.now().millisecondsSinceEpoch}',
      ...bookingData,
      'status': 'Upcoming',
    };

    _bookings.insert(0, newBooking);
    _bookingsController.add(_bookings);

    return newBooking;
  }

  // Create booking from service and payment
  Future<Map<String, dynamic>> createBooking({
    required Map<String, dynamic> service,
    required DateTime selectedDate,
    required String selectedTimeSlot,
    required String paymentMethod,
    required String bookingId,
    String? email,
  }) async {
    // Build booking data
    final bookingData = {
      'service': service['name'],
      'date': selectedDate.toIso8601String(),
      'time': selectedTimeSlot,
      'status': 'Upcoming',
      'price': service['price'],
      'bookingId': bookingId,
      'paymentMethod': paymentMethod,
      'email': email,
    };

    // For doctors, add the doctor name
    if (service['category'] == 'Doctors') {
      bookingData['doctor'] = service['name'];
    } else {
      bookingData['department'] = service['category'];
    }

    // Create the booking
    final newBooking = await addBooking(bookingData);

    return newBooking;
  }

  // Cancel a booking
  Future<bool> cancelBooking(String id) async {
    // Simulate API call
    await Future.delayed(Duration(seconds: 1));

    final bookingIndex = _bookings.indexWhere((booking) => booking['id'] == id);

    if (bookingIndex != -1) {
      // Get the booking before updating
      final booking = _bookings[bookingIndex];

      // Update booking status
      _bookings[bookingIndex] = {
        ..._bookings[bookingIndex],
        'status': 'Cancelled',
        'cancelledAt': DateTime.now().toIso8601String(),
      };

      _bookingsController.add(_bookings);

      // Create cancellation notification
      await PaymentNotificationHelper.createBookingCancellationNotification(
        booking: booking,
      );

      return true;
    }

    return false;
  }

  // Set up periodic reminder for upcoming bookings
  void _setupReminders() {
    // Check for upcoming appointments daily
    Timer.periodic(Duration(hours: 24), (timer) {
      _checkForUpcomingAppointments();
    });
  }

  // Check for appointments coming up tomorrow and send reminders
  void _checkForUpcomingAppointments() async {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);

    for (var booking in _bookings) {
      if (booking['status'] != 'Upcoming') continue;

      final bookingDate = DateTime.parse(booking['date']);

      // Check if the booking is tomorrow
      if (bookingDate.year == tomorrow.year &&
          bookingDate.month == tomorrow.month &&
          bookingDate.day == tomorrow.day) {

        // Send a reminder notification
        await PaymentNotificationHelper.createAppointmentReminderNotification(
          booking: booking,
        );
      }
    }
  }

  void dispose() {
    _bookingsController.close();
  }
}