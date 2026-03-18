import 'package:flutter/material.dart';
import '../Notification/NotificationService.dart';

class PaymentNotificationHelper {
  // Create notification for a service payment
  static Future<void> createServicePaymentNotification({
    required Map<String, dynamic> service,
    String? bookingId,
    String? paymentMethod,
    String? email,
  }) async {
    // Get the notification service
    final notificationService = NotificationService();

    // Create the notification data
    final notificationData = {
      'id': 'notif_${DateTime.now().millisecondsSinceEpoch}',
      'title': 'New Booking Confirmed',
      'body': 'Your booking for ${service['name']} has been confirmed.',
      'type': 'booking',
      'data': {
        'service': service,
        'bookingId': bookingId ?? 'BK${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
        'timestamp': DateTime.now().toIso8601String(),
        'paymentMethod': paymentMethod ?? 'Credit Card',
        'email': email,
      },
      'timestamp': DateTime.now().toIso8601String(),
      'isRead': false,
    };

    // Add to notification system
    notificationService.addNotification(notificationData);
  }

  // Create notification for a payment
  static Future<void> createPaymentNotification({
    required Map<String, dynamic> payment,
  }) async {
    // Get the notification service
    final notificationService = NotificationService();

    // Create the notification data
    final notificationData = {
      'id': 'notif_${DateTime.now().millisecondsSinceEpoch}',
      'title': 'Payment Successful',
      'body': 'Your payment of \$${payment['amount']} for ${payment['service']} was successful.',
      'type': 'payment',
      'data': payment,
      'timestamp': DateTime.now().toIso8601String(),
      'isRead': false,
    };

    // Add to notification system
    notificationService.addNotification(notificationData);
  }

  // Create notification for a booking cancellation
  static Future<void> createBookingCancellationNotification({
    required Map<String, dynamic> booking,
  }) async {
    // Get the notification service
    final notificationService = NotificationService();

    // Create the notification data
    final notificationData = {
      'id': 'notif_${DateTime.now().millisecondsSinceEpoch}',
      'title': 'Booking Cancelled',
      'body': 'Your booking for ${booking['service']} has been cancelled.',
      'type': 'booking_cancellation',
      'data': booking,
      'timestamp': DateTime.now().toIso8601String(),
      'isRead': false,
    };

    // Add to notification system
    notificationService.addNotification(notificationData);
  }

  // Create notification for an upcoming appointment reminder
  static Future<void> createAppointmentReminderNotification({
    required Map<String, dynamic> booking,
  }) async {
    // Get the notification service
    final notificationService = NotificationService();

    // Create the notification data
    final notificationData = {
      'id': 'notif_${DateTime.now().millisecondsSinceEpoch}',
      'title': 'Appointment Reminder',
      'body': 'Your appointment for ${booking['service']} is scheduled for tomorrow at ${booking['time']}.',
      'type': 'reminder',
      'data': booking,
      'timestamp': DateTime.now().toIso8601String(),
      'isRead': false,
    };

    // Add to notification system
    notificationService.addNotification(notificationData);
  }
}

// Add this function to the Payment Screen class

// Helper function to get the appropriate image for each service category
String getServiceImage(String? category) {
  if (category == null) return 'assets/images/default_service.png';

  switch (category.toLowerCase()) {
    case 'mri':
      return 'assets/images/mri_scan.png';
    case 'ct':
      return 'assets/images/ct_scan.png';
    case 'xray':
      return 'assets/images/xray.png';
    case 'ultrasound':
      return 'assets/images/ultrasound.png';
    case 'lab':
      return 'assets/images/lab_test.png';
    case 'consultation':
      return 'assets/images/consultation.png';
    default:
      return 'assets/images/default_service.png';
  }
}