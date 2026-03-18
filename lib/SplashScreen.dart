import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'OnboardingScreen.dart';
import 'Authentication.dart';
import 'services.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _controller.forward();

    // Navigate after a delay
    _navigateAfterSplash();
  }

  Future<void> _navigateAfterSplash() async {
    // Wait for 3 seconds
    await Future.delayed(const Duration(seconds: 3));

    // Check preferences and navigate
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isFirstTime = prefs.getBool('isFirstTime') ?? true;
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    String? userName = prefs.getString(PreferenceKeys.userFirstName);

    if (isFirstTime) {
      // First time user: navigate to onboarding
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => OnboardingScreen()),
      );
    } else if (isLoggedIn && userName != null) {
      // Returning logged-in user: navigate to services
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => ServicesScreen(userName: userName)),
      );
    } else {
      // User has seen onboarding but is not logged in: navigate to login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LoginScreen()),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: ScaleTransition(
          scale: _animation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).primaryColor.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.local_hospital,
                    size: 80,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              FadeTransition(
                opacity: _animation,
                child: Text(
                  "Online Hospital",
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              FadeTransition(
                opacity: _animation,
                child: Text(
                  "Your Health, Our Priority",
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}