
import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'NotificationService.dart';


class NotificationBadge extends StatefulWidget {
final Widget child;

const NotificationBadge({
Key? key,
required this.child,
}) : super(key: key);

@override
_NotificationBadgeState createState() => _NotificationBadgeState();
}

class _NotificationBadgeState extends State<NotificationBadge> {
int _unreadCount = 0;
StreamSubscription? _subscription;

@override
void initState() {
super.initState();
_loadUnreadCount();

// Subscribe to unread count updates
_subscription = NotificationService().unreadCountStream.listen((count) {
setState(() {
_unreadCount = count;
});
});
}

Future<void> _loadUnreadCount() async {
final count = NotificationService().getUnreadCount();
setState(() {
_unreadCount = count;
});
}

@override
void dispose() {
_subscription?.cancel();
super.dispose();
}

@override
Widget build(BuildContext context) {
return Stack(
clipBehavior: Clip.none,
children: [
widget.child,
if (_unreadCount > 0)
Positioned(
top: 0,
right: 0,
child: Container(
padding: EdgeInsets.all(_unreadCount > 9 ? 4 : 6),
decoration: BoxDecoration(
color: Colors.red,
shape: BoxShape.circle,
),
child: Text(
_unreadCount > 9 ? '9+' : _unreadCount.toString(),
style: TextStyle(
color: Colors.white,
fontSize: 10,
fontWeight: FontWeight.bold,
),
),
),
),
],
);
}
}