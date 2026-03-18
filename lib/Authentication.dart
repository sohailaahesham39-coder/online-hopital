import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
// Add Firebase imports
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import 'Utility Functions.dart';
import 'services.dart';

// Keys used in SharedPreferences
class PreferenceKeys {
  static const String isFirstTime = 'isFirstTime';
  static const String isLoggedIn = 'isLoggedIn';
  static const String userFirstName = 'user_first_name';
  static const String userLastName = 'user_last_name';
  static const String userEmail = 'user_email';
  static const String userPhone = 'user_phone';
  static const String userGender = 'user_gender';
  static const String userDOB = 'user_dob';
}

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _isLogin = true;
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  bool _rememberMe = true;
  late TabController _tabController;
  String _selectedGender = 'Male'; // Default gender
  DateTime _selectedDate = DateTime.now().subtract(
      Duration(days: 365 * 25)); // Default age 25

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _isLogin = _tabController.index == 0;
      });
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  Future<void> _saveLoginState(String email) async {
    final prefs = await SharedPreferences.getInstance();

    // Save login state for all users
    await prefs.setBool(PreferenceKeys.isLoggedIn, true);
    await prefs.setString(PreferenceKeys.userEmail, email);

    // Mark first time as completed
    await prefs.setBool(PreferenceKeys.isFirstTime, false);

    // Save user information based on registration type
    if (_isLogin) {
      String firstName = extractFirstNameFromUsername(email);
      await prefs.setString(PreferenceKeys.userFirstName, firstName);
    } else {
      await prefs.setString(
          PreferenceKeys.userFirstName, _firstNameController.text.trim());
      await prefs.setString(
          PreferenceKeys.userLastName, _lastNameController.text.trim());
      await prefs.setString(
          PreferenceKeys.userPhone, _phoneController.text.trim());
      await prefs.setString(PreferenceKeys.userGender, _selectedGender);
      await prefs.setString(
          PreferenceKeys.userDOB, _selectedDate.toIso8601String());
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1940),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        String email = _emailController.text.trim();

        // Save login state
        await _saveLoginState(email);

        // Simulate API call
        await Future.delayed(const Duration(seconds: 2));

        if (mounted) {
          setState(() {
            _isLoading = false;
          });

          // Determine first name
          String firstName = _isLogin
              ? extractFirstNameFromUsername(email)
              : _firstNameController.text.trim();

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ServicesScreen(userName: firstName),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('An error occurred: $e')),
          );
        }
      }
    }
  }

  // Method to handle social login success
  void _handleSocialLoginSuccess(String? firstName) async {
    try {
      // Save basic login state
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(PreferenceKeys.isLoggedIn, true);
      await prefs.setBool(PreferenceKeys.isFirstTime, false);

      // Save name if available
      if (firstName != null && firstName.isNotEmpty) {
        await prefs.setString(PreferenceKeys.userFirstName, firstName);
      } else {
        // Default name if none provided
        await prefs.setString(PreferenceKeys.userFirstName, "User");
      }

      // Navigate to Services screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ServicesScreen(userName: firstName ?? "User"),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving login state: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).primaryColor.withOpacity(0.8),
              Colors.indigo.shade800,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 30),
                  // Logo and welcome text with enhanced design
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 15,
                                offset: Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.local_hospital,
                            size: 60,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          "ONLINE HOSPITAL",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _isLogin
                              ? "Welcome back"
                              : "Join our healthcare network",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white.withOpacity(0.9),
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Card for form content
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          // Tab bar for login/register
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: TabBar(
                              controller: _tabController,
                              indicator: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                gradient: LinearGradient(
                                  colors: [
                                    Theme.of(context).primaryColor,
                                    Colors.indigo.shade700,
                                  ],
                                ),
                              ),
                              labelColor: Colors.white,
                              unselectedLabelColor: Colors.grey.shade600,
                              labelStyle: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                              tabs: const [
                                Tab(text: "Login"),
                                Tab(text: "Register"),
                              ],
                            ),
                          ),
                          const SizedBox(height: 30),

                          // Form
                          Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                // Register-specific fields
                                if (!_isLogin) ...[
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextFormField(
                                          controller: _firstNameController,
                                          decoration: _buildInputDecoration(
                                            "First Name",
                                            "Enter first name",
                                            Icons.person_outline,
                                          ),
                                          validator: (value) {
                                            if (value == null || value.isEmpty) {
                                              return "Required";
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      Expanded(
                                        child: TextFormField(
                                          controller: _lastNameController,
                                          decoration: _buildInputDecoration(
                                            "Last Name",
                                            "Enter last name",
                                            Icons.person_outline,
                                          ),
                                          validator: (value) {
                                            if (value == null || value.isEmpty) {
                                              return "Required";
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 15),
                                  TextFormField(
                                    controller: _phoneController,
                                    keyboardType: TextInputType.phone,
                                    decoration: _buildInputDecoration(
                                      "Phone Number",
                                      "Enter phone number",
                                      Icons.phone_outlined,
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return "Please enter your phone number";
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 15),
                                  // Gender selection
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 12),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: Colors.grey.shade300),
                                      color: Colors.grey.shade50,
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        value: _selectedGender,
                                        isExpanded: true,
                                        icon: Icon(Icons.arrow_drop_down),
                                        items: ['Male', 'Female', 'Other']
                                            .map((String value) {
                                          return DropdownMenuItem<String>(
                                            value: value,
                                            child: Row(
                                              children: [
                                                Icon(
                                                  value == 'Male'
                                                      ? Icons.male
                                                      : value == 'Female'
                                                      ? Icons.female
                                                      : Icons.person,
                                                  color: Colors.grey.shade700,
                                                ),
                                                SizedBox(width: 10),
                                                Text(value),
                                              ],
                                            ),
                                          );
                                        }).toList(),
                                        onChanged: (newValue) {
                                          setState(() {
                                            _selectedGender = newValue!;
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 15),
                                  // Date of birth
                                  GestureDetector(
                                    onTap: () => _selectDate(context),
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        vertical: 15,
                                        horizontal: 12,
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: Colors.grey.shade300),
                                        color: Colors.grey.shade50,
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.calendar_today,
                                            color: Colors.grey.shade700,
                                          ),
                                          SizedBox(width: 10),
                                          Text(
                                            "Date of Birth: ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}",
                                            style: TextStyle(
                                              color: Colors.grey.shade700,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 15),
                                ],

                                // Common fields for both login and register
                                TextFormField(
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: _buildInputDecoration(
                                    "Email",
                                    "Enter your email",
                                    Icons.email_outlined,
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return "Please enter your email";
                                    }
                                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                        .hasMatch(value)) {
                                      return "Please enter a valid email";
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 15),
                                TextFormField(
                                  controller: _passwordController,
                                  obscureText: !_isPasswordVisible,
                                  decoration: InputDecoration(
                                    labelText: "Password",
                                    hintText: "Enter your password",
                                    prefixIcon: Icon(Icons.lock_outline),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _isPasswordVisible
                                            ? Icons.visibility_off
                                            : Icons.visibility,
                                        color: Colors.grey,
                                      ),
                                      onPressed: _togglePasswordVisibility,
                                    ),
                                    contentPadding: EdgeInsets.symmetric(
                                      vertical: 15,
                                      horizontal: 15,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: Colors.grey.shade300),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: Colors.grey.shade300),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: Theme.of(context).primaryColor),
                                    ),
                                    filled: true,
                                    fillColor: Colors.grey.shade50,
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return "Please enter your password";
                                    }
                                    if (!_isLogin && value.length < 6) {
                                      return "Password must be at least 6 characters";
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 15),

                                // Remember me and forgot password
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        SizedBox(
                                          height: 24,
                                          width: 24,
                                          child: Checkbox(
                                            value: _rememberMe,
                                            onChanged: (value) {
                                              setState(() {
                                                _rememberMe = value!;
                                              });
                                            },
                                            activeColor: Theme.of(context).primaryColor,
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          "Remember me",
                                          style: TextStyle(
                                            color: Colors.grey.shade700,
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (_isLogin)
                                      TextButton(
                                        onPressed: () {
                                          // Forgot password functionality would go here
                                        },
                                        child: Text(
                                          "Forgot Password?",
                                          style: TextStyle(
                                            color: Theme.of(context).primaryColor,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 20),

                                // Submit button
                                SizedBox(
                                  width: double.infinity,
                                  height: 50,
                                  child: ElevatedButton(
                                    onPressed: _isLoading ? null : _submitForm,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Theme.of(context).primaryColor,
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: _isLoading
                                        ? CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                    )
                                        : Text(
                                      _isLogin ? "Login" : "Register",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),

                                // Social login buttons
                                SocialLoginButtons(onLoginSuccess: _handleSocialLoginSuccess),
                              ],
                            ),
                          ),
                        ],
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

  // Helper method to build consistent input decoration
  InputDecoration _buildInputDecoration(String label, String hint, IconData icon) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, color: Colors.grey),
      contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Theme.of(context).primaryColor),
      ),
      filled: true,
      fillColor: Colors.grey.shade50,
    );
  }
}

class SocialLoginButtons extends StatelessWidget {
  final Function(String?) onLoginSuccess;

   SocialLoginButtons({Key? key, required this.onLoginSuccess}) : super(key: key);

  // Firebase instance
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Google Sign-In
  Future<void> _signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return; // User canceled sign-in

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _auth.signInWithCredential(credential);
      print("Google login successful: ${_auth.currentUser?.displayName}");

      // Call the success callback with user's display name
      onLoginSuccess(_auth.currentUser?.displayName?.split(' ').first);
    } catch (e) {
      print("Google sign-in error: $e");
    }
  }

  // Facebook Sign-In
  Future<void> _signInWithFacebook() async {
    try {
      final LoginResult result = await FacebookAuth.instance.login();
      if (result.status == LoginStatus.success) {
        final AccessToken? accessToken = result.accessToken;
        final OAuthCredential credential = FacebookAuthProvider.credential(accessToken!.tokenString);
        await _auth.signInWithCredential(credential);
        print("Facebook login successful: ${_auth.currentUser?.displayName}");

        // Call the success callback with user's display name
        onLoginSuccess(_auth.currentUser?.displayName?.split(' ').first);
      } else {
        print("Facebook sign-in failed: ${result.message}");
      }
    } catch (e) {
      print("Facebook sign-in error: $e");
    }
  }

  // Apple Sign-In
  Future<void> _signInWithApple() async {
    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [AppleIDAuthorizationScopes.email, AppleIDAuthorizationScopes.fullName],
      );

      final OAuthCredential credential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      await _auth.signInWithCredential(credential);
      print("Apple login successful: ${_auth.currentUser?.displayName}");

      // Call the success callback with user's display name or default name
      String? firstName = _auth.currentUser?.displayName?.split(' ').first;
      onLoginSuccess(firstName ?? "Apple User");
    } catch (e) {
      print("Apple sign-in error: $e");
    }
  }

  // Build Social Button Widget
  Widget _buildSocialButton({required IconData icon, required Color color, required VoidCallback onPressed}) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
        ),
        child: Icon(icon, color: Colors.white, size: 30),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: Divider(color: Colors.grey.shade400, thickness: 1)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                "Or continue with",
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
              ),
            ),
            Expanded(child: Divider(color: Colors.grey.shade400, thickness: 1)),
          ],
        ),
        const SizedBox(height: 20),

        // Social login buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildSocialButton(
              icon: Icons.g_mobiledata,
              color: Colors.red,
              onPressed: _signInWithGoogle,
            ),
            const SizedBox(width: 20),
            _buildSocialButton(
              icon: Icons.facebook,
              color: Colors.blue,
              onPressed: _signInWithFacebook,
            ),
            const SizedBox(width: 20),
            _buildSocialButton(
              icon: Icons.apple,
              color: Colors.black,
              onPressed: _signInWithApple,
            ),
          ],
        ),
      ],
    );
  }
}