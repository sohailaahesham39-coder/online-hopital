import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ChatDetailScreen extends StatefulWidget {
  final ChatItem chat;

  ChatDetailScreen({required this.chat});

  @override
  _ChatDetailScreenState createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;

  final List<Message> _messages = [];

  @override
  void initState() {
    super.initState();

    // Add some dummy messages
    _messages.addAll([
      Message(
        sender: 'You',
        text: 'Hello, I\'ve been experiencing headaches lately.',
        timestamp: DateTime.now().subtract(Duration(days: 1, hours: 2)),
        isFromUser: true,
      ),
      Message(
        sender: widget.chat.name,
        text: 'I\'m sorry to hear that. How long have you been experiencing them?',
        timestamp: DateTime.now().subtract(Duration(days: 1, hours: 1, minutes: 58)),
        isFromUser: false,
      ),
      Message(
        sender: 'You',
        text: 'For about a week now. They\'re worse in the morning.',
        timestamp: DateTime.now().subtract(Duration(days: 1, hours: 1, minutes: 55)),
        isFromUser: true,
      ),
      Message(
        sender: widget.chat.name,
        text: 'Have you changed your sleep routine recently?',
        timestamp: DateTime.now().subtract(Duration(days: 1, hours: 1, minutes: 50)),
        isFromUser: false,
      ),
      Message(
        sender: 'You',
        text: 'Actually, I\'ve been staying up later to finish some work.',
        timestamp: DateTime.now().subtract(Duration(days: 1, hours: 1, minutes: 45)),
        isFromUser: true,
      ),
      Message(
        sender: widget.chat.name,
        text: widget.chat.lastMessage,
        timestamp: widget.chat.timestamp,
        isFromUser: false,
      ),
    ]);

    // Scroll to bottom after frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Color(0x201976D2),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  widget.chat.name.substring(0, 1),
                  style: TextStyle(
                    color: Color(0xFF1976D2),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.chat.name,
                  style: TextStyle(
                    color: Color(0xFF1976D2),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  _isTyping ? 'Typing...' : 'Online',
                  style: TextStyle(
                    color: _isTyping ? Color(0xFF1976D2) : Color(0xFF4CAF50),
                    fontWeight: FontWeight.normal,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.phone, color: Color(0xFF4CAF50)),
            onPressed: () {
              // Voice call
              Navigator.pop(context);
            },
          ),
          IconButton(
            icon: Icon(Icons.videocam, color: Color(0xFF1976D2)),
            onPressed: () {
              // Video call
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? _buildEmptyChat()
                : ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final bool showDateSeparator = index == 0 ||
                    !_isSameDay(
                        _messages[index - 1].timestamp, message.timestamp);

                return Column(
                  children: [
                    if (showDateSeparator) _buildDateSeparator(message.timestamp),
                    _buildMessage(message),
                  ],
                );
              },
            ),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildEmptyChat() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat,
            size: 80,
            color: Color(0xFFB0BEC5),
          ),
          SizedBox(height: 16),
          Text(
            'No messages yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF607D8B),
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Start the conversation with ${widget.chat.name}',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF90A4AE),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSeparator(DateTime timestamp) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: Divider(
              color: Color(0xFFB0BEC5),
              thickness: 1,
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              _formatDateSeparator(timestamp),
              style: TextStyle(
                color: Color(0xFF607D8B),
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Divider(
              color: Color(0xFFB0BEC5),
              thickness: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessage(Message message) {
    return Align(
      alignment:
      message.isFromUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          bottom: 8,
          left: message.isFromUser ? 64 : 0,
          right: message.isFromUser ? 0 : 64,
        ),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: message.isFromUser
              ? Color(0xFF1976D2)
              : Colors.white,
          borderRadius: BorderRadius.circular(16).copyWith(
            bottomLeft: message.isFromUser ? Radius.circular(16) : Radius.circular(4),
            bottomRight: message.isFromUser ? Radius.circular(4) : Radius.circular(16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.text,
              style: TextStyle(
                color: message.isFromUser ? Colors.white : Color(0xFF263238),
                fontSize: 14,
              ),
            ),
            SizedBox(height: 4),
            Text(
              _formatMessageTimestamp(message.timestamp),
              style: TextStyle(
                color: message.isFromUser
                    ? Colors.white.withOpacity(0.7)
                    : Color(0xFF90A4AE),
                fontSize: 10,
              ),
              textAlign: TextAlign.right,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.attach_file, color: Color(0xFF90A4AE)),
            onPressed: () {
              // Attachment functionality
            },
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Color(0xFFF5F7FA),
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  hintStyle: TextStyle(color: Color(0xFF90A4AE)),
                  border: InputBorder.none,
                ),
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
                onChanged: (value) {
                  // Show typing indicator to other user
                },
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send, color: Color(0xFF1976D2)),
            onPressed: () {
              _sendMessage();
            },
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    setState(() {
      _messages.add(
        Message(
          sender: 'You',
          text: _messageController.text.trim(),
          timestamp: DateTime.now(),
          isFromUser: true,
        ),
      );
    });

    // Scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

    // Clear input field
    _messageController.clear();

    // Simulate response after a short delay
    setState(() {
      _isTyping = true;
    });

    Future.delayed(Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isTyping = false;
          _messages.add(
            Message(
              sender: widget.chat.name,
              text: 'Thank you for sharing that. It sounds like your sleep schedule might be contributing to your headaches. I recommend trying to maintain a consistent sleep routine and taking breaks when working for extended periods.',
              timestamp: DateTime.now(),
              isFromUser: false,
            ),
          );
        });

        // Scroll to bottom again after adding the response
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
      }
    });
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  String _formatDateSeparator(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(Duration(days: 1));
    final dateDay = DateTime(date.year, date.month, date.day);

    if (dateDay == today) {
      return 'Today';
    } else if (dateDay == yesterday) {
      return 'Yesterday';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  String _formatMessageTimestamp(DateTime timestamp) {
    final hour = timestamp.hour.toString().padLeft(2, '0');
    final minute = timestamp.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

// Updated ChatItem class to match the one in the main file
class ChatItem {
  final String name;
  final String avatar;
  final String lastMessage;
  final DateTime timestamp;
  int unreadCount;

  ChatItem({
    required this.name,
    required this.avatar,
    required this.lastMessage,
    required this.timestamp,
    required this.unreadCount,
  });
}


class Message {
  final String sender;
  final String text;
  final DateTime timestamp;
  final bool isFromUser;

  Message({
    required this.sender,
    required this.text,
    required this.timestamp,
    required this.isFromUser,
  });
}