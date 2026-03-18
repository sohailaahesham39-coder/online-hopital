import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Assuming you have a LoginScreen widget somewhere
import '../../Authentication.dart';


class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Map<String, String> userData;
  bool _isEditing = false;
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // Initialize with Firebase user data if available
    final user = FirebaseAuth.instance.currentUser;
    userData = {
      'name': user?.displayName ?? 'Takeiahmed',
      'email': user?.email ?? 'Takeiahmed81@gmail.com',
      'phone': user?.phoneNumber ?? '+1 (555) 123-4567',
    };

    _nameController = TextEditingController(text: userData['name']);
    _emailController = TextEditingController(text: userData['email']);
    _phoneController = TextEditingController(text: userData['phone']);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _toggleEditMode() {
    setState(() {
      _isEditing = !_isEditing;
      if (_isEditing) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        userData['name'] = _nameController.text;
        userData['email'] = _emailController.text;
        userData['phone'] = _phoneController.text;
        _isEditing = false;
      });
      _animationController.reverse();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully'),
          backgroundColor: Color(0xFF1976D2),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _logout() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Close confirmation dialog

              // Show loading indicator
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const Center(
                  child: CircularProgressIndicator(),
                ),
              );

              try {
                // Sign out from Firebase
                await FirebaseAuth.instance.signOut();

                // Sign out from Google if used
                final googleSignIn = GoogleSignIn();
                if (await googleSignIn.isSignedIn()) {
                  await googleSignIn.signOut();
                }

                // Sign out from Facebook if used
                await FacebookAuth.instance.logOut();

                // Clear shared preferences
                final prefs = await SharedPreferences.getInstance();
                await prefs.clear();

                // Remove loading indicator
                Navigator.pop(context);

                // Navigate to login screen and remove all previous routes
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) =>  LoginScreen()), // Replace with your login screen
                      (route) => false,
                );
              } catch (e) {
                // Remove loading indicator
                Navigator.pop(context);

                // Show error message
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Logout failed: ${e.toString()}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Logout'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FE),
      appBar: AppBar(
        title: const Text(
          'My Profile',
          style: TextStyle(color: Color(0xFF1976D2), fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.close : Icons.edit),
            color: const Color(0xFF1976D2),
            onPressed: _toggleEditMode,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildProfileHeader(),
            const SizedBox(height: 24),
            _isEditing ? _buildEditForm() : _buildProfileDetails(),
            const SizedBox(height: 32),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  // Rest of your widget methods remain the same
  Widget _buildProfileHeader() {
    return Center(
      child: Column(
        children: [
          Container(
            height: 120,
            width: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 5),
                ),
              ],
              border: Border.all(
                color: const Color(0xFF1976D2).withOpacity(0.2),
                width: 4,
              ),
            ),
            child: ClipOval(
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  const Icon(
                    Icons.person,
                    size: 80,
                    color: Color(0xFF1976D2),
                  ),
                  if (_isEditing)
                    Container(
                      color: const Color(0xFF1976D2).withOpacity(0.7),
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (!_isEditing)
            Text(
              userData['name'] ?? 'User Name',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF303F9F),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProfileDetails() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildInfoRow(Icons.email, 'Email', userData['email'] ?? 'Not provided'),
          const Divider(height: 32),
          _buildInfoRow(Icons.phone, 'Phone', userData['phone'] ?? 'Not provided'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          height: 50,
          width: 50,
          decoration: BoxDecoration(
            color: const Color(0xFF1976D2).withOpacity(0.1),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(icon, color: const Color(0xFF1976D2)),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey[600]),
              ),
              Text(
                value,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF303F9F)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEditForm() {
    return Form(
      key: _formKey,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            TextFormField(
              controller: _nameController,
              decoration: _inputDecoration('Full Name', Icons.person),
              validator: (value) => value?.isEmpty ?? true ? 'Please enter your name' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              decoration: _inputDecoration('Email Address', Icons.email),
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Please enter your email';
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              decoration: _inputDecoration('Phone Number', Icons.phone),
              validator: (value) => value?.isEmpty ?? true ? 'Please enter your phone number' : null,
            ),
            const SizedBox(height: 24),
            _buildAnimatedButton('Save Changes', Icons.check, const Color(0xFF1976D2), _saveProfile),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: const Color(0xFF1976D2)),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF1976D2), width: 2),
      ),
      filled: true,
      fillColor: Colors.grey.withOpacity(0.05),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        if (!_isEditing) ...[
          _buildAnimatedButton('Change Password', Icons.lock, const Color(0xFF303F9F), () {
            // Implement password change functionality
          }),
          const SizedBox(height: 16),
          _buildAnimatedButton('Logout', Icons.exit_to_app, const Color(0xFFE57373), () => _logout()),
        ],
      ],
    );
  }

  Widget _buildAnimatedButton(String label, IconData icon, Color color, VoidCallback onPressed) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 1.0, end: 1.0),
      duration: const Duration(milliseconds: 300),
      builder: (context, scale, child) {
        return GestureDetector(
          onTap: onPressed,
          child: Container(
            width: double.infinity,
            height: 60,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: color.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}