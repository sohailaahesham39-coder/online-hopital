import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:intl/intl.dart';
import '../../TimeSelectionScree.dart';
import 'Confirmation Screen.dart';

import 'PaymentService.dart';


class PaymentScreen extends StatefulWidget {
  final Map<String, dynamic>? service; // Optional service for direct payments
  final DateTime? selectedDate; // Optional date for appointments
  final String? selectedTimeSlot; // Optional time for appointments

  const PaymentScreen({
    Key? key,
    this.service,
    this.selectedDate,
    this.selectedTimeSlot,
  }) : super(key: key);

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  // State variables
  bool _isLoading = true;
  List<dynamic> _payments = [];
  List<dynamic> _paymentMethods = [];
  String? _errorMessage;
  int _selectedCardIndex = -1;
  bool _isManualEntry = false;
  bool _isServicePayment = false;
  String _userEmail = "user"; // In a real app, get from user profile

  // Controllers for text fields
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _cardHolderController = TextEditingController();
  final TextEditingController _expiryDateController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();

  // Subscription for payment updates
  StreamSubscription? _paymentSubscription;

  @override
  void initState() {
    super.initState();
    _isServicePayment = widget.service != null;
    _fetchData();

    // Subscribe to payment updates
    _paymentSubscription = PaymentService().paymentsStream.listen((payments) {
      setState(() {
        _payments = payments;
      });
    });
  }

  @override
  void dispose() {
    _paymentSubscription?.cancel();
    _cardNumberController.dispose();
    _cardHolderController.dispose();
    _expiryDateController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Use our payment service
      final paymentService = PaymentService();
      final payments = await paymentService.getPaymentHistory();
      final methods = await paymentService.getPaymentMethods();

      setState(() {
        _payments = payments;
        _paymentMethods = methods;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load payment data: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _addPaymentMethod() {
    setState(() {
      _isManualEntry = true;
      _selectedCardIndex = -1;
    });
  }

  void _processPayment() async {
    // Validate payment method selection
    if (_selectedCardIndex == -1 && !_isManualEntry) {
      _showErrorSnackBar("Please select a payment method");
      return;
    }

    // Validate manual entry if applicable
    if (_isManualEntry) {
      if (_cardNumberController.text.isEmpty ||
          _cardHolderController.text.isEmpty ||
          _expiryDateController.text.isEmpty ||
          _cvvController.text.isEmpty) {
        _showErrorSnackBar("Please complete all payment details");
        return;
      }
    }

    // Show loading indicator
    _showLoadingDialog("Processing payment...");

    try {
      // Get payment method details
      String paymentMethodId;
      String methodName;

      if (_isManualEntry) {
        // Create new payment method
        final newMethod = await _createNewPaymentMethod();
        paymentMethodId = newMethod['id'];
        methodName = 'Credit Card';
      } else {
        // Use selected payment method
        paymentMethodId = _paymentMethods[_selectedCardIndex]['id'];
        methodName = _paymentMethods[_selectedCardIndex]['type'];
      }

      // If this is a service payment, process it through our service
      if (widget.service != null && widget.selectedDate != null && widget.selectedTimeSlot != null) {
        final result = await PaymentService().processBookingPayment(
          service: widget.service!,
          selectedDate: widget.selectedDate!,
          selectedTimeSlot: widget.selectedTimeSlot!,
          paymentMethodId: paymentMethodId,
          methodName: methodName,
          email: _userEmail,
        );

        // Close the loading dialog
        Navigator.pop(context);

        // Navigate to confirmation screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ConfirmationScreen(
              service: widget.service!,
              selectedDate: widget.selectedDate!,
              selectedTimeSlot: widget.selectedTimeSlot!,
              paymentMethod: methodName,
              bookingId: result['bookingId'],
              email: _userEmail,
            ),
          ),
        );
      } else {
        // Regular payment (not for a service booking)
        final paymentData = {
          'methodId': paymentMethodId,
          'methodName': methodName,
          'amount': widget.service != null ? widget.service!['price'] : 100, // Default amount if not service
          'description': widget.service != null ? widget.service!['name'] : 'Manual payment',
          'date': DateTime.now().toIso8601String(),
        };

        // Process the payment
        await PaymentService().processPayment(paymentData);

        // Close the loading dialog
        Navigator.pop(context);

        // Show success dialog
        _showSuccessDialog(null);
      }
    } catch (e) {
      // Close the loading dialog
      Navigator.pop(context);

      // Show error
      _showErrorSnackBar("Payment failed: ${e.toString()}");
    }
  }

  Future<Map<String, dynamic>> _createNewPaymentMethod() async {
    final newMethod = {
      'type': 'Credit Card',
      'number': _cardNumberController.text.substring(
          max(0, _cardNumberController.text.length - 4)),
      'expiry': _expiryDateController.text,
      'holderName': _cardHolderController.text,
    };

    // Add the payment method through our service
    return await PaymentService().addPaymentMethod(newMethod);
  }

  void _showLoadingDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          Center(
            child: Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                    color: Theme.of(context).primaryColor,
                  ),
                  SizedBox(height: 20),
                  Text(
                    message,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  void _showSuccessDialog(String? bookingId) {
    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green),
                SizedBox(width: 8),
                Text("Payment Successful"),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Your payment has been processed successfully."),
                if (bookingId != null) ...[
                  SizedBox(height: 12),
                  Text("Booking ID: $bookingId",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Return to previous screen
                },
                child: Text("OK"),
              ),
            ],
          ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showDeleteConfirmation(dynamic method) {
    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: Text('Remove Payment Method'),
            content: Text(
                'Are you sure you want to remove this payment method?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);

                  // Show loading indicator
                  _showLoadingDialog("Removing payment method...");

                  try {
                    // Remove through our service
                    await PaymentService().removePaymentMethod(method['id']);

                    setState(() {
                      _paymentMethods.removeWhere((m) =>
                      m['id'] == method['id']);
                      if (_selectedCardIndex >= _paymentMethods.length) {
                        _selectedCardIndex = -1;
                      }
                    });

                    // Close loading dialog
                    Navigator.pop(context);
                  } catch (e) {
                    // Close loading dialog and show error
                    Navigator.pop(context);
                    _showErrorSnackBar(
                        "Failed to remove payment method: ${e.toString()}");
                  }
                },
                child: Text('Remove', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }

  void _showPaymentDetailsBottomSheet(Map<String, dynamic> payment) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: EdgeInsets.all(20),
          child: ListView(
            controller: scrollController,
            children: [
              Center(
                child: Container(
                  width: 60,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Center(
                child: Text(
                  "Transaction Details",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 20),
              _buildDetailRow("Service", payment['service'] ?? 'Unknown service'),
              _buildDetailRow("Date", payment['date'] != null
                  ? DateFormat.yMMMd().format(DateTime.parse(payment['date']))
                  : 'Unknown date'),
              _buildDetailRow("Amount", "\$${(payment['amount'] as num).toStringAsFixed(2)}"),
              _buildDetailRow("Status", payment['status'] ?? 'Completed'),
              _buildDetailRow("Payment Method", payment['method'] ?? 'Card'),
              if (payment.containsKey('transactionId'))
                _buildDetailRow("Transaction ID", payment['transactionId']),
              if (payment.containsKey('bookingId'))
                _buildDetailRow("Booking ID", payment['bookingId']),
              SizedBox(height: 30),
              if (payment['status'] == 'Completed')
                ElevatedButton.icon(
                  icon: Icon(Icons.download, color: Colors.white), // ✅ تأكيد اللون الأبيض للأيقونة
                  label: Text(
                    "Download Receipt",
                    style: TextStyle(color: Colors.white), // ✅ تأكيد اللون الأبيض للنص
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white, // ✅ يضمن أن النص والأيقونة باللون الأبيض
                    minimumSize: Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    // Download receipt functionality
                    Navigator.pop(context);
                    _showSuccessSnackBar("Receipt download started");
                  },
                ),

            ],
          ),
        ),
      ),
    );
  }

  IconData _getPaymentIcon(String type) {
    switch (type.toLowerCase()) {
      case 'credit card':
      case 'visa':
      case 'mastercard':
      case 'amex':
        return Icons.credit_card;
      case 'paypal':
        return Icons.account_balance_wallet;
      case 'apple pay':
        return Icons.apple;
      case 'google pay':
        return Icons.g_mobiledata;
      default:
        return Icons.payment;
    }
  }

  Color _getCardColor(String type) {
    switch (type.toLowerCase()) {
      case 'visa':
        return Color(0xFF1E3A8A);
      case 'mastercard':
        return Color(0xFFB91C1C);
      case 'amex':
        return Color(0xFF2E5AAC);
      case 'paypal':
        return Color(0xFF00457C);
      default:
        return Color(0xFF1976D2);
    }
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Payment",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Color(0xFF1976D2)),
            onPressed: _fetchData,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? _buildErrorView()
          : _buildContentView(),
      bottomNavigationBar: _isServicePayment
          ? _buildPaymentButton()
          : null,
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 50, color: Colors.red),
          SizedBox(height: 16),
          Text(
            'Something went wrong',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(_errorMessage!, style: TextStyle(color: Colors.grey[600])),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: _fetchData,
            child: Text('Try Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF1976D2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentView() {
    return AnimationLimiter(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: AnimationConfiguration.toStaggeredList(
            duration: const Duration(milliseconds: 375),
            childAnimationBuilder: (widget) =>
                SlideAnimation(
                  horizontalOffset: 50.0,
                  child: FadeInAnimation(
                    child: widget,
                  ),
                ),
            children: [
              // Booking summary if this is a service payment
              if (widget.service != null)
                Padding(
                  padding: const EdgeInsets.all(16.0),
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
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min, // Added this to prevent overflow
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Booking Summary",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            if (widget.selectedDate != null)
                              Flexible( // Added Flexible here
                                child: Text(
                                  "${DateFormat.yMMMd().format(widget.selectedDate!)} at ${widget.selectedTimeSlot}",
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                  overflow: TextOverflow.ellipsis, // Added overflow handling
                                ),
                              ),
                          ],
                        ),
                        Divider(height: 24),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center, // Improved alignment
                          children: [
                            // Service image
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.asset(
                                  getServiceImage(widget.service?['category']),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            SizedBox(width: 12),

                            // Service details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min, // Added this to prevent overflow
                                children: [
                                  Text(
                                    widget.service?['name'] ?? '',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                    overflow: TextOverflow.ellipsis, // Added overflow handling
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    widget.service?['specialty'] ?? '',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 13,
                                    ),
                                    overflow: TextOverflow.ellipsis, // Added overflow handling
                                  ),
                                ],
                              ),
                            ),

                            // Price - added SizedBox for spacing
                            SizedBox(width: 8),
                            Text(
                              "\$${widget.service?['price'] ?? 'N/A'}",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

              // Payment methods section
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  "Payment Methods",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),

              // Saved cards
              if (_paymentMethods.isNotEmpty)
                Container(
                  height: 150,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    itemCount: _paymentMethods.length + 1,
                    // +1 for add new card option
                    itemBuilder: (context, index) {
                      // Add new card option
                      if (index == _paymentMethods.length) {
                        return GestureDetector(
                          onTap: _addPaymentMethod,
                          child: Container(
                            width: 280,
                            margin: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: _isManualEntry
                                    ? Theme.of(context).primaryColor
                                    : Colors.grey.shade300,
                                width: _isManualEntry ? 2 : 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.03),
                                  blurRadius: 5,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add_circle_outline,
                                    size: 40,
                                    color: Colors.grey.shade400,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    "Add New Card",
                                    style: TextStyle(
                                      color: Colors.grey.shade700,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }

                      // Saved card
                      final method = _paymentMethods[index];
                      final isSelected = index == _selectedCardIndex;
                      final cardType = method['type'] ?? 'Credit Card';
                      final cardColor = _getCardColor(cardType);

                      // Extract info with null checking
                      String subtitle = '';
                      if (method.containsKey('number') &&
                          method['number'] != null) {
                        subtitle = '**** **** **** ${method['number']}';
                      } else if (method.containsKey('email') &&
                          method['email'] != null) {
                        subtitle = method['email'];
                      }

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedCardIndex = index;
                            _isManualEntry = false;
                          });
                        },
                        child: AnimatedContainer(
                          duration: Duration(milliseconds: 300),
                          width: 280,
                          margin: EdgeInsets.symmetric(
                              horizontal: 8, vertical: 8),
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: isSelected ? 10 : 5,
                                spreadRadius: isSelected ? 2 : 0,
                              ),
                            ],
                            border: isSelected
                                ? Border.all(color: Colors.white, width: 2)
                                : null,
                          ),
                          child: Stack(
                            children: [
                              // Card content
                              // Card content
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min, // Ensures column takes minimum space
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Flexible( // Added Flexible to handle long card type names
                                          child: Text(
                                            cardType,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                            ),
                                            overflow: TextOverflow.ellipsis, // Add overflow handling
                                          ),
                                        ),
                                        Icon(
                                          _getPaymentIcon(cardType),
                                          color: Colors.white,
                                          size: 30,
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 12), // Reduced from 15
                                    Text(
                                      subtitle,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        letterSpacing: 2,
                                      ),
                                      overflow: TextOverflow.ellipsis, // Add overflow handling
                                    ),
                                    SizedBox(height: 12), // Reduced from 15
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Flexible( // Added Flexible for card holder name
                                          flex: 3, // Give more space to card holder name
                                          child: Text(
                                            method.containsKey('holderName')
                                                ? method['holderName']
                                                : 'Card Holder',
                                            style: TextStyle(
                                              color: Colors.white.withOpacity(0.8),
                                              fontSize: 13,
                                            ),
                                            overflow: TextOverflow.ellipsis, // Add overflow handling
                                          ),
                                        ),
                                        SizedBox(width: 4), // Add some spacing
                                        Flexible( // Added Flexible for expiry date
                                          flex: 2, // Give less space to expiry
                                          child: Text(
                                            method.containsKey('expiry')
                                                ? "Exp: ${method['expiry']}"
                                                : "",
                                            style: TextStyle(
                                              color: Colors.white.withOpacity(0.8),
                                              fontSize: 13,
                                            ),
                                            overflow: TextOverflow.ellipsis, // Add overflow handling
                                            textAlign: TextAlign.right, // Align text to the right
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              // Selection indicator
                              if (isSelected)
                                Positioned(
                                  top: 10,
                                  right: 10,
                                  child: Container(
                                    padding: EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.check,
                                      color: Theme.of(context).primaryColor,
                                      size: 16,
                                    ),
                                  ),
                                ),

                              // Options button
                              Positioned(
                                bottom: 10,
                                right: 10,
                                child: InkWell(
                                  onTap: () {
                                    _showDeleteConfirmation(method);
                                  },
                                  child: Container(
                                    padding: EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.3),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.more_horiz,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Card(
                    margin: EdgeInsets.only(bottom: 16),
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: Colors.grey.withOpacity(0.2)),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.credit_card,
                              size: 48,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'No payment methods added yet',
                              style: TextStyle(
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

              // Add payment method button (if not already showing manual entry)
              if (!_isManualEntry)
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  child: OutlinedButton.icon(
                    onPressed: _addPaymentMethod,
                    icon: Icon(Icons.add),
                    label: Text('Add Payment Method'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Color(0xFF1976D2),
                      side: BorderSide(color: Color(0xFF1976D2)),
                      minimumSize: Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),

              // Manual card entry form
              if (_isManualEntry)
                Padding(
                  padding: const EdgeInsets.all(16.0),
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
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Card Details",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 20),

                        // Card Number
                        TextField(
                          controller: _cardNumberController,
                          decoration: InputDecoration(
                            labelText: "Card Number",
                            hintText: "1234 5678 9012 3456",
                            prefixIcon: Icon(Icons.credit_card),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 16),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                        SizedBox(height: 16),

                        // Card Holder
                        TextField(
                          controller: _cardHolderController,
                          decoration: InputDecoration(
                            labelText: "Card Holder Name",
                            hintText: "John Smith",
                            prefixIcon: Icon(Icons.person),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 16),
                          ),
                        ),
                        SizedBox(height: 16),

                        // Expiry Date and CVV
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _expiryDateController,
                                decoration: InputDecoration(
                                  labelText: "Expiry Date",
                                  hintText: "MM/YY",
                                  prefixIcon: Icon(Icons.calendar_today),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 16),
                                ),
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: TextField(
                                controller: _cvvController,
                                decoration: InputDecoration(
                                  labelText: "CVV",
                                  hintText: "123",
                                  prefixIcon: Icon(Icons.security),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 16),
                                ),
                                keyboardType: TextInputType.number,
                                obscureText: true,
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 16),

                        // Cancel button for manual entry
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _isManualEntry = false;
                            });
                          },
                          child: Text("Cancel"),
                        ),
                      ],
                    ),
                  ),
                ),

              // Payment History Section (only show if not making a direct payment)
              if (!_isServicePayment) ...[
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Payment History",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      if (_payments.isNotEmpty)
                        TextButton(
                          onPressed: () {
                            // Navigate to detailed payment history
                          },
                          child: Text('See All'),
                          style: TextButton.styleFrom(
                            foregroundColor: Color(0xFF1976D2),
                          ),
                        ),
                    ],
                  ),
                ),

                // Payment history list
                // Fixed Payment History List Section with proper string interpolation
// and additional fixes to prevent overflow issues

// Payment history list
                _payments.isEmpty
                    ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Card(
                    margin: EdgeInsets.only(bottom: 16),
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: Colors.grey.withOpacity(0.2)),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.receipt_long,
                              size: 48,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'No payment history yet',
                              style: TextStyle(
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
                    : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: min(3, _payments.length), // Show only the latest 3 payments
                    itemBuilder: (context, index) {
                      final payment = _payments[index];

                      final String date = payment['date'] != null
                          ? DateFormat.yMMMd().format(DateTime.parse(payment['date']))
                          : 'Unknown date';
                      final double amount = payment['amount'] != null
                          ? (payment['amount'] as num).toDouble()
                          : 0.0;
                      final String status = payment['status'] ?? 'Completed';
                      final String paymentMethod = payment['method'] ?? 'Card';

                      return Card(
                        margin: EdgeInsets.only(bottom: 12),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.grey.withOpacity(0.2)),
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          leading: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: status == 'Completed'
                                  ? Colors.green.withOpacity(0.1)
                                  : status == 'Pending'
                                  ? Colors.orange.withOpacity(0.1)
                                  : Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Icon(
                                _getPaymentIcon(paymentMethod),
                                color: status == 'Completed'
                                    ? Colors.green
                                    : status == 'Pending'
                                    ? Colors.orange
                                    : Colors.red,
                              ),
                            ),
                          ),
                          title: Text(
                            payment['service'] ?? 'Unknown service',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            date,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                          trailing: SizedBox(
                            width: 80, // Fixed width for the trailing element
                            child: Column(
                              mainAxisSize: MainAxisSize.min, // Important fix to prevent overflow
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                // Fixed: Properly interpolate the amount value
                                Text(
                                  "\$${amount.toStringAsFixed(2)}",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: status == 'Completed'
                                        ? Colors.green.withOpacity(0.1)
                                        : status == 'Pending'
                                        ? Colors.orange.withOpacity(0.1)
                                        : Colors.red.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    status,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                      color: status == 'Completed'
                                          ? Colors.green
                                          : status == 'Pending'
                                          ? Colors.orange
                                          : Colors.red,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          onTap: () {
                            // Show payment details in a modal
                            _showPaymentDetailsBottomSheet(payment);
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }



// Fix for the Payment Screen Total amount display
// In PaymentScreen class (_PaymentScreenState)

  Widget _buildPaymentButton() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.service != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Total",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // Fixed: properly display the price
                  Text(
                    "\$${widget.service!['price']}",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _processPayment,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF1976D2),
                minimumSize: Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                "Pay Now",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

// Fix for the payment history item display in PaymentScreen
  Widget _buildPaymentHistoryItem(Map<String, dynamic> payment) {
    final String date = payment['date'] != null
        ? DateFormat.yMMMd().format(DateTime.parse(payment['date']))
        : 'Unknown date';
    final double amount = payment['amount'] != null
        ? (payment['amount'] as num).toDouble()
        : 0.0;
    final String status = payment['status'] ?? 'Completed';
    final String paymentMethod = payment['method'] ?? 'Card';

    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.withOpacity(0.2)),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: status == 'Completed'
                ? Colors.green.withOpacity(0.1)
                : status == 'Pending'
                ? Colors.orange.withOpacity(0.1)
                : Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Icon(
              _getPaymentIcon(paymentMethod),
              color: status == 'Completed'
                  ? Colors.green
                  : status == 'Pending'
                  ? Colors.orange
                  : Colors.red,
            ),
          ),
        ),
        title: Text(
          payment['service'] ?? 'Unknown service',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          date,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 12,
          ),
        ),
        trailing: Column(
          mainAxisSize: MainAxisSize.min, // Fixed: Add this to prevent overflow
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              "\$${amount.toStringAsFixed(2)}",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Theme.of(context).primaryColor,
              ),
            ),
            SizedBox(height: 4),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 3,
              ),
              decoration: BoxDecoration(
                color: status == 'Completed'
                    ? Colors.green.withOpacity(0.1)
                    : status == 'Pending'
                    ? Colors.orange.withOpacity(0.1)
                    : Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                status,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: status == 'Completed'
                      ? Colors.green
                      : status == 'Pending'
                      ? Colors.orange
                      : Colors.red,
                ),
              ),
            ),
          ],
        ),
        onTap: () {
          // Show payment details in a modal
          _showPaymentDetailsBottomSheet(payment);
        },
      ),
    );
  }

  // Helper method for min calculation
  int min(int a, int b) {
    return a < b ? a : b;
  }

  // Helper method for max calculation
  int max(int a, int b) {
    return a > b ? a : b;
  }
}