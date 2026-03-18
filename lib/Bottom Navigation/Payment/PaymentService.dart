import 'dart:async';
import '../Notification/NotificationService.dart';
import 'PaymentNotificationHelper.dart';

class PaymentService {
  // Singleton pattern for global access
  static final PaymentService _instance = PaymentService._internal();
  factory PaymentService() => _instance;
  PaymentService._internal();

  // Mock data storage
  List<Map<String, dynamic>> _payments = [];
  List<Map<String, dynamic>> _paymentMethods = [
    {
      'id': 'card1',
      'type': 'Visa',
      'number': '4321',
      'expiry': '09/26',
      'holderName': 'John Smith',
    },
    {
      'id': 'card2',
      'type': 'Mastercard',
      'number': '8765',
      'expiry': '11/25',
      'holderName': 'John Smith',
    }
  ];

  // Stream controllers for live updates
  final _paymentsController = StreamController<List<Map<String, dynamic>>>.broadcast();
  Stream<List<Map<String, dynamic>>> get paymentsStream => _paymentsController.stream;

  // Getters
  Future<List<Map<String, dynamic>>> getPaymentHistory() async {
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: 800));
    return _payments;
  }

  Future<List<Map<String, dynamic>>> getPaymentMethods() async {
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: 800));
    return _paymentMethods;
  }

  // Process a new payment
  Future<Map<String, dynamic>> processPayment(Map<String, dynamic> paymentData) async {
    // Simulate payment processing
    await Future.delayed(Duration(seconds: 1));

    final newPayment = {
      'id': 'pay_${DateTime.now().millisecondsSinceEpoch}',
      'service': paymentData['description'],
      'amount': paymentData['amount'],
      'method': paymentData['methodName'] ?? 'Credit Card',
      'status': 'Completed',
      'date': DateTime.now().toIso8601String(),
      'transactionId': 'TX${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      'bookingId': paymentData['bookingId'],
    };

    _payments.insert(0, newPayment); // Add to beginning of list
    _paymentsController.add(_payments); // Notify listeners

    // Create payment notification
    await PaymentNotificationHelper.createPaymentNotification(payment: newPayment);

    return newPayment;
  }

  // Process a service booking payment
  Future<Map<String, dynamic>> processBookingPayment({
    required Map<String, dynamic> service,
    required DateTime selectedDate,
    required String selectedTimeSlot,
    required String paymentMethodId,
    String? methodName,
    String? email,
  }) async {
    // Generate booking ID
    final bookingId = 'BK${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

    // Prepare payment data
    final paymentData = {
      'methodId': paymentMethodId,
      'methodName': methodName,
      'amount': service['price'],
      'description': service['name'],
      'date': DateTime.now().toIso8601String(),
      'bookingId': bookingId,
    };

    // Process the payment
    final paymentResult = await processPayment(paymentData);

    // Create booking notification
    await PaymentNotificationHelper.createServicePaymentNotification(
      service: service,
      bookingId: bookingId,
      paymentMethod: methodName,
      email: email,
    );

    // Return the result with booking info
    return {
      ...paymentResult,
      'bookingId': bookingId,
      'selectedDate': selectedDate.toIso8601String(),
      'selectedTimeSlot': selectedTimeSlot,
    };
  }

  // Add a new payment method
  Future<Map<String, dynamic>> addPaymentMethod(Map<String, dynamic> methodData) async {
    // Simulate API call
    await Future.delayed(Duration(seconds: 1));

    final newMethod = {
      'id': 'method_${DateTime.now().millisecondsSinceEpoch}',
      ...methodData,
    };

    _paymentMethods.add(newMethod);

    return newMethod;
  }

  // Remove a payment method
  Future<bool> removePaymentMethod(String methodId) async {
    // Simulate API call
    await Future.delayed(Duration(seconds: 1));

    _paymentMethods.removeWhere((method) => method['id'] == methodId);

    return true;
  }

  void dispose() {
    _paymentsController.close();
  }
}