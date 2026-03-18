import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:intl/intl.dart';
import '../booking/BookingService.dart';
import 'PaymentNotificationHelper.dart';


class ConfirmationScreen extends StatelessWidget {
  final Map<String, dynamic> service;
  final DateTime selectedDate;
  final String selectedTimeSlot;
  final String paymentMethod;
  final String bookingId;
  final String email;

  const ConfirmationScreen({
    Key? key,
    required this.service,
    required this.selectedDate,
    required this.selectedTimeSlot,
    required this.paymentMethod,
    required this.bookingId,
    required this.email,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Create booking and notification when screen is first built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _createBookingAndNotification();
    });

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  // Success animation and message
                  AnimationConfiguration.synchronized(
                    duration: const Duration(milliseconds: 600),
                    child: FadeInAnimation(
                      child: Column(
                        children: [
                          // Success icon with animation
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Icon(
                                Icons.check_circle,
                                size: 80,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ),
                          SizedBox(height: 24),

                          // Thank you message
                          Text(
                            "Thank You!",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          SizedBox(height: 12),
                          Text(
                            "Your booking has been confirmed",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            "We have sent the details to your email",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),

                  // Booking details card
                  AnimationConfiguration.synchronized(
                    duration: const Duration(milliseconds: 800),
                    child: SlideAnimation(
                      verticalOffset: 50.0,
                      child: FadeInAnimation(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          padding: EdgeInsets.all(24),
                          child: Column(
                            children: [
                              // Booking ID and QR code placeholder
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Booking ID",
                                          style: TextStyle(
                                            color: Colors.grey.shade600,
                                            fontSize: 14,
                                          ),
                                        ),
                                        SizedBox(height: 6),
                                        Text(
                                          bookingId,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // QR Code placeholder
                                  Container(
                                    width: 70,
                                    height: 70,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade200,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Center(
                                      child: Icon(
                                        Icons.qr_code,
                                        size: 40,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 24),

                              // Detail items
                              _buildDetailItem(context, "Service", service['name']),
                              _buildDetailItem(context, "Email", email),
                              _buildDetailItem(
                                  context,
                                  "Date & Time",
                                  "${DateFormat.yMMMMd().format(selectedDate)} at $selectedTimeSlot"
                              ),
                              _buildDetailItem(context, "Amount", "\$${service['price']}"),
                              _buildDetailItem(context, "Payment Method", paymentMethod),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 32),

                  // Continue button
                  AnimationConfiguration.synchronized(
                    duration: const Duration(milliseconds: 900),
                    child: SlideAnimation(
                      verticalOffset: 50.0,
                      child: FadeInAnimation(
                        child: Container(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            onPressed: () {
                              // In a real app, navigate back to home screen
                              // For this example, just pop back to first screen
                              Navigator.of(context).popUntil((route) => route.isFirst);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              elevation: 2,
                            ),
                            child: Text(
                              "Continue to Home",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Helper method to build detail items
  Widget _buildDetailItem(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to create booking and notification
  Future<void> _createBookingAndNotification() async {
    try {
      // Create booking in the booking service
      final bookingService = BookingService();
      await bookingService.createBooking(
        service: service,
        selectedDate: selectedDate,
        selectedTimeSlot: selectedTimeSlot,
        paymentMethod: paymentMethod,
        bookingId: bookingId,
        email: email,
      );

      // Create notification for the booking
      await PaymentNotificationHelper.createServicePaymentNotification(
        service: service,
        bookingId: bookingId,
        paymentMethod: paymentMethod,
        email: email,
      );
    } catch (e) {
      print('Error creating booking/notification: $e');
    }
  }
}