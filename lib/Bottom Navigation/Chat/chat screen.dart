
import 'package:flutter/material.dart';
import 'ChatDetailScreen.dart';
import '../profile/Profile Screen.dart';


class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  bool _isInCall = false;
  bool _isVideoCall = false;
  bool _isMuted = false;
  bool _isFrontCamera = true;

  late AnimationController _callAnimationController;

  final List<ChatItem> _chats = [
    ChatItem(
      name: 'Dr. Sarah Johnson',
      avatar: 'assets/avatars/dr_johnson.png',
      lastMessage: 'Your test results look good. No need to worry.',
      timestamp: DateTime.now().subtract(Duration(minutes: 30)),
      unreadCount: 0,
    ),
    ChatItem(
      name: 'Dr. Michael Chen',
      avatar: 'assets/avatars/dr_chen.png',
      lastMessage: 'Please remember to take your medication as prescribed.',
      timestamp: DateTime.now().subtract(Duration(hours: 2)),
      unreadCount: 3,
    ),
    ChatItem(
      name: 'Nurse Emily',
      avatar: 'assets/avatars/nurse_emily.png',
      lastMessage: 'Your appointment has been confirmed for tomorrow at 2 PM.',
      timestamp: DateTime.now().subtract(Duration(days: 1)),
      unreadCount: 0,
    ),
    ChatItem(
      name: 'Receptionist',
      avatar: 'assets/avatars/receptionist.png',
      lastMessage: 'Your insurance details have been updated in our system.',
      timestamp: DateTime.now().subtract(Duration(days: 3)),
      unreadCount: 0,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _callAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _callAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _buildChatList(),
        if (_isInCall) _buildCallInterface(),
      ],
    );
  }

  Widget _buildChatList() {
    return Scaffold(
      backgroundColor: Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Chats',
          style: TextStyle(
            color: Color(0xFF1976D2),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Color(0xFF1976D2)),
            onPressed: () {
              // Implement search functionality
            },
          ),
          IconButton(
            icon: Icon(Icons.person, color: Color(0xFF1976D2)),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfileScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: _chats.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: _chats.length,
        itemBuilder: (context, index) {
          // Staggered animation timing
          return AnimatedBuilder(
            animation: TweenSequence<double>([
              TweenSequenceItem(
                tween: Tween<double>(begin: 0.0, end: 1.0)
                    .chain(CurveTween(curve: Curves.easeOut)),
                weight: 1.0,
              ),
            ]).animate(CurvedAnimation(
              parent: ModalRoute.of(context)!.animation!,
              curve: Interval(
                0.1 * index,
                0.1 * index + 0.5,
                curve: Curves.easeOut,
              ),
            )),
            builder: (context, child) {
              return Transform.scale(
                scale: ModalRoute.of(context)!.animation!.value,
                child: child,
              );
            },
            child: _buildChatCard(_chats[index]),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 80,
            color: Color(0xFFB0BEC5),
          ),
          SizedBox(height: 16),
          Text(
            'No conversations yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF607D8B),
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Start a conversation with your healthcare provider',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF90A4AE),
            ),
          ),
          SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              // Start new conversation
            },
            icon: Icon(Icons.add),
            label: Text('New Conversation'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF1976D2),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatCard(ChatItem chat) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          _openChatDetail(chat);
        },
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAvatar(chat),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          chat.name,
                          style: TextStyle(
                            fontWeight: chat.unreadCount > 0
                                ? FontWeight.bold
                                : FontWeight.w500,
                            fontSize: 16,
                            color: Color(0xFF263238),
                          ),
                        ),
                        Text(
                          _formatTimestamp(chat.timestamp),
                          style: TextStyle(
                            fontSize: 12,
                            color: chat.unreadCount > 0
                                ? Color(0xFF1976D2)
                                : Color(0xFFB0BEC5),
                            fontWeight: chat.unreadCount > 0
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 6),
                    Text(
                      chat.lastMessage,
                      style: TextStyle(
                        fontSize: 14,
                        color: chat.unreadCount > 0
                            ? Color(0xFF455A64)
                            : Color(0xFF78909C),
                        fontWeight: chat.unreadCount > 0
                            ? FontWeight.w500
                            : FontWeight.normal,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        _buildCallButton(
                          icon: Icons.phone,
                          color: Color(0xFF4CAF50),
                          onPressed: () => _startCall(chat, false),
                        ),
                        SizedBox(width: 8),
                        _buildCallButton(
                          icon: Icons.videocam,
                          color: Color(0xFF1976D2),
                          onPressed: () => _startCall(chat, true),
                        ),
                        Spacer(),
                        if (chat.unreadCount > 0)
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Color(0xFF1976D2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${chat.unreadCount}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(ChatItem chat) {
    // This would normally use a real image from the network or assets
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: Color(0x201976D2),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          chat.name.substring(0, 1),
          style: TextStyle(
            color: Color(0xFF1976D2),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildCallButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, size: 16),
        color: color,
        padding: EdgeInsets.zero,
        onPressed: onPressed,
      ),
    );
  }



  void _openChatDetail(ChatItem chat) {
    setState(() {
      chat.unreadCount = 0;
    });

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatDetailScreen(chat: chat),
      ),
    );
  }


  void _startCall(ChatItem chat, bool isVideo) {
    setState(() {
      _isInCall = true;
      _isVideoCall = isVideo;
    });
    _callAnimationController.forward();
  }

  Widget _buildCallInterface() {
    return AnimatedBuilder(
      animation: _callAnimationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _callAnimationController,
          child: child,
        );
      },
      child: Scaffold(
        backgroundColor: _isVideoCall
            ? Colors.black
            : Color(0xFF1976D2).withOpacity(0.9),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: _isVideoCall
                    ? _buildVideoCallContent()
                    : _buildVoiceCallContent(),
              ),
              _buildCallControls(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVideoCallContent() {
    return Stack(
      children: [
        // Main video (remote user)
        Container(
          width: double.infinity,
          height: double.infinity,
          color: Color(0xFF263238),
          child: Center(
            child: Icon(
              Icons.person,
              size: 120,
              color: Colors.white.withOpacity(0.5),
            ),
          ),
        ),
        // Small video (self view)
        Positioned(
          top: 16,
          right: 16,
          child: GestureDetector(
            onTap: () {
              setState(() {
                _isFrontCamera = !_isFrontCamera;
              });
            },
            child: Container(
              width: 120,
              height: 180,
              decoration: BoxDecoration(
                color: Color(0xFF455A64),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Center(
                child: Icon(
                  Icons.person,
                  size: 60,
                  color: Colors.white.withOpacity(0.5),
                ),
              ),
            ),
          ),
        ),
        // Call info
        Positioned(
          top: 16,
          left: 16,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Color(0x201976D2),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      'D',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dr. Sarah Johnson',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '05:23',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVoiceCallContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                'D',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(height: 24),
          Text(
            'Dr. Sarah Johnson',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '05:23',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 16,
            ),
          ),
          SizedBox(height: 16),
          _isMuted
              ? Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.3),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              'Muted',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
              : SizedBox.shrink(),
        ],
      ),
    );
  }

  Widget _buildCallControls() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildCallControlButton(
            icon: _isMuted ? Icons.mic_off : Icons.mic,
            color: _isMuted ? Colors.red : Colors.white,
            label: _isMuted ? 'Unmute' : 'Mute',
            onPressed: () {
              setState(() {
                _isMuted = !_isMuted;
              });
            },
          ),
          _buildCallControlButton(
            icon: Icons.call_end,
            color: Colors.red,
            label: 'End',
            background: Colors.red,
            onPressed: () {
              _callAnimationController.reverse().then((_) {
                setState(() {
                  _isInCall = false;
                  _isMuted = false;
                });
              });
            },
          ),
          if (_isVideoCall)
            _buildCallControlButton(
              icon: _isFrontCamera ? Icons.camera_rear : Icons.camera_front,
              color: Colors.white,
              label: 'Switch',
              onPressed: () {
                setState(() {
                  _isFrontCamera = !_isFrontCamera;
                });
              },
            )
          else
            _buildCallControlButton(
              icon: Icons.volume_up,
              color: Colors.white,
              label: 'Speaker',
              onPressed: () {
                // Toggle speaker
              },
            ),
        ],
      ),
    );
  }

  Widget _buildCallControlButton({
    required IconData icon,
    required Color color,
    required String label,
    Color? background,
    required VoidCallback onPressed,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: background ?? Colors.black.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: Icon(icon),
            color: color,
            onPressed: onPressed,
          ),
        ),
        SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      if (difference.inDays == 1) {
        return 'Yesterday';
      } else if (difference.inDays < 7) {
        final weekday = [
          'Monday',
          'Tuesday',
          'Wednesday',
          'Thursday',
          'Friday',
          'Saturday',
          'Sunday'
        ];
        return weekday[timestamp.weekday - 1];
      } else {
        return '${timestamp.day}/${timestamp.month}';
      }
    } else if (difference.inHours > 0) {
      return '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}


