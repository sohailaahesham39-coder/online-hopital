// Notification Service - Create this as Notification Service.dart
import 'dart:async';
import 'package:flutter/material.dart';

class NotificationService {
  // Singleton pattern
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  // Storage for notifications
  List<Map<String, dynamic>> _notifications = [];

  // Stream controllers for live updates
  final _notificationsController = StreamController<List<Map<String, dynamic>>>.broadcast();
  Stream<List<Map<String, dynamic>>> get notificationsStream => _notificationsController.stream;

  // Unread count controller
  final _unreadCountController = StreamController<int>.broadcast();
  Stream<int> get unreadCountStream => _unreadCountController.stream;

  // Get all notifications
  Future<List<Map<String, dynamic>>> getNotifications() async {
    await Future.delayed(Duration(milliseconds: 800));
    return _notifications;
  }

  // Get unread count
  int getUnreadCount() {
    return _notifications.where((n) => n['isRead'] == false).length;
  }

  // Add notification
  void addNotification(Map<String, dynamic> notification) {
    _notifications.insert(0, notification);
    _notificationsController.add(_notifications);
    _unreadCountController.add(getUnreadCount());

    // Show a system notification or snackbar here if the app is in the background
  }

  // Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    final index = _notifications.indexWhere((n) => n['id'] == notificationId);
    if (index != -1) {
      _notifications[index]['isRead'] = true;
      _notificationsController.add(_notifications);
      _unreadCountController.add(getUnreadCount());
    }
  }

  // Mark all as read
  Future<void> markAllAsRead() async {
    for (var notification in _notifications) {
      notification['isRead'] = true;
    }
    _notificationsController.add(_notifications);
    _unreadCountController.add(0);
  }

  // Clear all notifications
  Future<void> clearAll() async {
    _notifications.clear();
    _notificationsController.add(_notifications);
    _unreadCountController.add(0);
  }

  void dispose() {
    _notificationsController.close();
    _unreadCountController.close();
  }
}
