// NotificationScreen - Create this as a new file
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:intl/intl.dart';

import 'NotificationService.dart';


class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _notifications = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final notifications = await NotificationService().getNotifications();

      setState(() {
        _notifications = notifications;
        _isLoading = false;
      });

      // Mark all as read when opened
      await NotificationService().markAllAsRead();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      // Show error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load notifications: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "Notifications",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          if (_notifications.isNotEmpty)
            IconButton(
              icon: Icon(Icons.delete_sweep, color: Colors.grey.shade700),
              onPressed: () {
                _showClearConfirmation();
              },
            ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
          ? _buildEmptyState()
          : _buildNotificationsList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off,
            size: 80,
            color: Colors.grey.shade400,
          ),
          SizedBox(height: 16),
          Text(
            'No notifications yet',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'You\'ll see updates and alerts here',
            style: TextStyle(
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsList() {
    return RefreshIndicator(
      onRefresh: _loadNotifications,
      child: AnimationLimiter(
        child: ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: _notifications.length,
          itemBuilder: (context, index) {
            final notification = _notifications[index];
            return AnimationConfiguration.staggeredList(
              position: index,
              duration: const Duration(milliseconds: 375),
              child: SlideAnimation(
                verticalOffset: 50.0,
                child: FadeInAnimation(
                  child: _buildNotificationCard(notification),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification) {
    // Extract info from notification
    final String title = notification['title'] ?? 'Notification';
    final String body = notification['body'] ?? '';
    final bool isRead = notification['isRead'] ?? false;
    final String timestamp = notification['timestamp'] != null
        ? _formatTimestamp(DateTime.parse(notification['timestamp']))
        : '';

    // Determine icon based on notification type
    IconData notificationIcon;
    Color iconColor;

    switch (notification['type']) {
      case 'payment':
        notificationIcon = Icons.payment;
        iconColor = Colors.green;
        break;
      case 'booking':
        notificationIcon = Icons.calendar_today;
        iconColor = Colors.blue;
        break;
      case 'reminder':
        notificationIcon = Icons.alarm;
        iconColor = Colors.orange;
        break;
      case 'system':
        notificationIcon = Icons.info;
        iconColor = Colors.purple;
        break;
      default:
        notificationIcon = Icons.notifications;
        iconColor = Colors.grey;
    }

    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.withOpacity(0.2)),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        leading: Stack(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Icon(
                  notificationIcon,
                  color: iconColor,
                ),
              ),
            ),
            if (!isRead)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
          ],
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4),
            Text(
              body,
              style: TextStyle(
                color: Colors.black87,
                fontSize: 14,
              ),
            ),
            SizedBox(height: 8),
            Text(
              timestamp,
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 12,
              ),
            ),
          ],
        ),
        onTap: () {
          // Handle notification tap
          _handleNotificationTap(notification);
        },
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Just now';
        } else {
          return '${difference.inMinutes} min ago';
        }
      } else {
        return '${difference.inHours} hours ago';
      }
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return DateFormat.yMMMd().format(timestamp);
    }
  }

  void _handleNotificationTap(Map<String, dynamic> notification) {
    // Mark as read
    NotificationService().markAsRead(notification['id']);

    // Navigate based on notification type
    if (notification['type'] == 'payment') {
      // Navigate to payment details
      // Navigator.push(context, MaterialPageRoute(builder: (_) => PaymentsShow()));
    } else if (notification['type'] == 'booking') {
      // Navigate to booking details
      // Navigator.push(context, MaterialPageRoute(builder: (_) => BookingDetailsScreen()));
    }

    // Show details in bottom sheet
    _showNotificationDetails(notification);
  }

  void _showNotificationDetails(Map<String, dynamic> notification) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
              // Sheet handle
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

              // Title
              Text(
                notification['title'] ?? 'Notification Details',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),

              // Timestamp
              if (notification['timestamp'] != null)
                Text(
                  DateFormat.yMMMMd().add_jm().format(
                    DateTime.parse(notification['timestamp']),
                  ),
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              SizedBox(height: 24),

              // Body
              Text(
                notification['body'] ?? '',
                style: TextStyle(
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
              SizedBox(height: 24),

              // Additional details based on notification type
              if (notification['type'] == 'payment' && notification['data'] != null) ...[
                _buildDetailRow('Service', notification['data']['service']),
                _buildDetailRow('Amount', '\$${notification['data']['amount']}'),
                _buildDetailRow('Transaction ID', notification['data']['transactionId']),
                SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // Navigate to payment details
                    // Navigator.push(context, MaterialPageRoute(builder: (_) => PaymentsShow()));
                  },
                  child: Text('View Payment Details'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    minimumSize: Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ] else if (notification['type'] == 'booking' && notification['data'] != null) ...[
                _buildDetailRow('Service', notification['data']['service']['name']),
                _buildDetailRow('Booking ID', notification['data']['bookingId']),
                if (notification['data']['service']['price'] != null)
                  _buildDetailRow('Price', '\$${notification['data']['service']['price']}'),
                SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // Navigate to booking details
                    // Navigator.push(context, MaterialPageRoute(builder: (_) => BookingDetailsScreen()));
                  },
                  child: Text(
                    'View Booking Details',
                    style: TextStyle(color: Colors.white), // Set text color to white
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white, // Ensures text and icons are white
                    minimumSize: Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),

                ),
              ],
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

  void _showClearConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Clear Notifications'),
        content: Text('Are you sure you want to clear all notifications?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await NotificationService().clearAll();
              setState(() {
                _notifications = [];
              });
            },
            child: Text('Clear All', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

