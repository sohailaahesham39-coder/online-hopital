import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:intl/intl.dart';
import 'BookingService.dart';


class BookingsScreen extends StatefulWidget {
  @override
  _BookingsScreenState createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  List<dynamic> _upcomingBookings = [];
  List<dynamic> _pastBookings = [];
  String? _errorMessage;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchBookings();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchBookings() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Use our BookingService to fetch bookings
      final bookingService = BookingService();
      final upcomingBookings = await bookingService.getUpcomingBookings();
      final pastBookings = await bookingService.getPastBookings();

      setState(() {
        _upcomingBookings = upcomingBookings;
        _pastBookings = pastBookings;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load bookings: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _cancelBooking(String id) async {
    try {
      setState(() {
        // Optimistic UI update
        final bookingIndex = _upcomingBookings.indexWhere((booking) => booking['id'] == id);
        if (bookingIndex != -1) {
          _upcomingBookings[bookingIndex]['status'] = 'Cancelling...';
        }
      });

      // Cancel through our booking service
      final bookingService = BookingService();
      await bookingService.cancelBooking(id);

      // Refresh the data
      _fetchBookings();
    } catch (e) {
      // Revert the optimistic update on error
      _fetchBookings();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error cancelling booking: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          'My Bookings',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _fetchBookings,
            color: Color(0xFF1976D2),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Theme.of(context).primaryColor,
          labelColor: Theme.of(context).primaryColor,
          unselectedLabelColor: Colors.grey.shade600,
          tabs: [
            Tab(text: "Upcoming"),
            Tab(text: "Past"),
          ],
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? _buildErrorView()
          : TabBarView(
        controller: _tabController,
        children: [
          // Upcoming bookings tab
          _upcomingBookings.isEmpty
              ? _buildEmptyState("No upcoming bookings", "Book an appointment to see it here")
              : _buildBookingsList(_upcomingBookings, true),

          // Past bookings tab
          _pastBookings.isEmpty
              ? _buildEmptyState("No past bookings", "Your appointment history will appear here")
              : _buildBookingsList(_pastBookings, false),
        ],
      ),
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
            onPressed: _fetchBookings,
            child: Text('Try Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF1976D2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String title, String subtitle) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_today_outlined,
            size: 70,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingsList(List<dynamic> bookings, bool isUpcoming) {
    return RefreshIndicator(
      onRefresh: _fetchBookings,
      child: AnimationLimiter(
        child: ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: bookings.length,
          itemBuilder: (context, index) {
            final booking = bookings[index];

            // Create staggered animation for each card
            return AnimationConfiguration.staggeredList(
              position: index,
              duration: Duration(milliseconds: 375),
              child: SlideAnimation(
                verticalOffset: 50.0,
                child: FadeInAnimation(
                  child: _buildBookingCard(booking, isUpcoming, index),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBookingCard(dynamic booking, bool isUpcoming, int index) {
    // Define status color
    Color statusColor;
    final status = booking['status'] ?? 'Unknown';

    switch (status) {
      case 'Upcoming':
        statusColor = Color(0xFF1976D2);
        break;
      case 'Completed':
        statusColor = Colors.green;
        break;
      case 'Cancelled':
        statusColor = Colors.red;
        break;
      case 'Cancelling...':
        statusColor = Colors.orange;
        break;
      default:
        statusColor = Colors.grey;
    }

    // Format date
    String formattedDate = 'No date';
    if (booking['date'] != null) {
      try {
        final date = DateTime.parse(booking['date']);
        formattedDate = DateFormat.yMMMd().format(date);
      } catch (e) {
        // If date parsing fails, use the raw date string
        formattedDate = booking['date'].toString();
      }
    }

    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking['service'] ?? 'Unknown Service',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4),
                      if (booking['doctor'] != null)
                        Text(
                          booking['doctor'],
                          style: TextStyle(
                            color: Colors.grey[700],
                          ),
                        ),
                      if (booking['department'] != null)
                        Text(
                          booking['department'],
                          style: TextStyle(
                            color: Colors.grey[700],
                          ),
                        ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: Colors.grey[600],
                ),
                SizedBox(width: 8),
                Text(
                  formattedDate,
                  style: TextStyle(
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(width: 16),
                Icon(
                  Icons.access_time,
                  size: 16,
                  color: Colors.grey[600],
                ),
                SizedBox(width: 8),
                Text(
                  booking['time'] ?? 'No time',
                  style: TextStyle(
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
            if (booking['bookingId'] != null) ...[
              SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.confirmation_number,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  SizedBox(width: 8),
                  Text(
                    "Booking ID: ${booking['bookingId']}",
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
            if (booking['price'] != null) ...[
              SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.attach_money,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  SizedBox(width: 8),
                  Text(
                    "\$${booking['price']}",
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Spacer(),
                  if (booking['paymentMethod'] != null)
                    Text(
                      "Paid with ${booking['paymentMethod']}",
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ],
            SizedBox(height: 16),
            if (isUpcoming && status == 'Upcoming')
              OutlinedButton(
                onPressed: () => _showCancelConfirmation(booking['id']),
                child: Text('Cancel Booking'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            if (status == 'Cancelling...')
              OutlinedButton.icon(
                onPressed: null,
                icon: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                  ),
                ),
                label: Text('Cancelling...'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.orange,
                  side: BorderSide(color: Colors.orange),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            if (!isUpcoming && status == 'Completed')
              OutlinedButton.icon(
                onPressed: () {
                  // Show booking details or receipt
                  _showBookingDetailsBottomSheet(booking);
                },
                icon: Icon(Icons.receipt),
                label: Text('View Details'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Theme.of(context).primaryColor,
                  side: BorderSide(color: Theme.of(context).primaryColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showCancelConfirmation(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Cancel Booking'),
        content: Text('Are you sure you want to cancel this booking?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('No, Keep it'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _cancelBooking(id);
            },
            child: Text('Yes, Cancel', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showBookingDetailsBottomSheet(dynamic booking) {
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
                  "Booking Details",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 20),
              _buildDetailRow("Service", booking['service'] ?? 'Unknown service'),
              if (booking['doctor'] != null)
                _buildDetailRow("Doctor", booking['doctor']),
              if (booking['department'] != null)
                _buildDetailRow("Department", booking['department']),
              _buildDetailRow("Date", booking['date'] != null
                  ? DateFormat.yMMMd().format(DateTime.parse(booking['date']))
                  : 'Unknown date'),
              _buildDetailRow("Time", booking['time'] ?? 'Unknown time'),
              _buildDetailRow("Status", booking['status'] ?? 'Unknown'),
              if (booking['price'] != null)
                _buildDetailRow("Price", "\$${booking['price']}"),
              if (booking['paymentMethod'] != null)
                _buildDetailRow("Payment Method", booking['paymentMethod']),
              if (booking['bookingId'] != null)
                _buildDetailRow("Booking ID", booking['bookingId']),
              SizedBox(height: 30),
              if (booking['status'] == 'Completed')
                ElevatedButton.icon(
                  icon: Icon(Icons.download),
                  label: Text("Download Receipt"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    minimumSize: Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    // Download receipt functionality
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Receipt download started"),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
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
}