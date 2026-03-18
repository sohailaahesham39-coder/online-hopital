import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Authentication.dart';

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingItem> _onboardingData = [
    OnboardingItem(
      title: "Find Doctors Easily",
      description: "Search and find trusted doctors nearby with detailed profiles and reviews",
      image: "assets/find_doctors.jpg",
      icon: Icons.search,
      color: Color(0xFF1E88E5),
    ),
    OnboardingItem(
      title: "Book Appointments",
      description: "Schedule appointments with your preferred doctors at your convenient time",
      image: "assets/images/appointment.jpg",
      icon: Icons.calendar_today,
      color: Color(0xFF26C6DA),
    ),
    OnboardingItem(
      title: "Virtual Consultations",
      description: "Consult with specialists through video calls from the comfort of your home",
      image: "assets/images/payment.jpg",
      icon: Icons.video_call,
      color: Color(0xFF66BB6A),
    ),
  ];

  void _markFirstTimeComplete() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isFirstTime', false); // Mark onboarding as completed
    } catch (e) {
      // Log or handle potential errors
      debugPrint('Error saving isFirstTime to preferences: $e');
    }
  }

  void _onSkip() {
    // Mark onboarding complete and navigate to LoginScreen
    _markFirstTimeComplete();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => LoginScreen()),
    );
  }

  void _onNextPage() {
    if (_currentPage < _onboardingData.length - 1) {
      // Move to the next onboarding page
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Mark onboarding complete and navigate to LoginScreen after last page
      _markFirstTimeComplete();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _onSkip,
                    child: Text(
                      "Skip",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _onboardingData.length,
                onPageChanged: (int page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                itemBuilder: (context, index) {
                  return buildOnboardingPage(_onboardingData[index]);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Page indicator
                  Row(
                    children: List.generate(
                      _onboardingData.length,
                          (index) => Container(
                        margin: const EdgeInsets.only(right: 6),
                        height: 10,
                        width: _currentPage == index ? 25 : 10,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? Theme.of(context).primaryColor
                              : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ),
                  ),
                  // Next button
                  ElevatedButton(
                    onPressed: _onNextPage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      _currentPage == _onboardingData.length - 1
                          ? "Get Started"
                          : "Next",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildOnboardingPage(OnboardingItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // For a real app, use the actual image here
          Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              color: item.color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              item.icon,
              size: 100,
              color: item.color,
            ),
          ),
          const SizedBox(height: 40),
          Text(
            item.title,
            style: Theme.of(context).textTheme.displayMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            item.description,
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// Onboarding item data class
class OnboardingItem {
  final String title;
  final String description;
  final String image;
  final IconData icon;
  final Color color;

  OnboardingItem({
    required this.title,
    required this.description,
    required this.image,
    required this.icon,
    required this.color,
  });
}