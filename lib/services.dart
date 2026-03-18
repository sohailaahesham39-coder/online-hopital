import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import 'Bottom Navigation/Bottom Navigation/Bottom Navigation Bar.dart';
import 'Bottom Navigation/Notification/NotificationsScreen.dart';
import 'TimeSelectionScree.dart';
import 'Utility Functions.dart';


// Services Screen with fixed issues
class ServicesScreen extends StatefulWidget {
  final String userName;

  const ServicesScreen({Key? key, this.userName = ''}) : super(key: key);

  @override
  _ServicesScreenState createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'All';
  String _selectedFilter = 'Recommended';



  // Sample dynamic data
  final List<Map<String, dynamic>> _servicesData = [
    {
      'id': '1',
      'category': 'Doctors',
      'name': 'Dr. Sarah Johnson',
      'specialty': 'Cardiologist',
      'experience': '15 years',
      'rating': 4.8,
      'reviews': 127,
      'price': 150,
      'currency': 'EGP',
      'available': true,
      'image': 'assets/doctor3.jpg',
    },
    {
      'id': '2',
      'category': 'Doctors',
      'name': 'Dr. Michael Chen',
      'specialty': 'Neurologist',
      'experience': '12 years',
      'rating': 4.7,
      'reviews': 98,
      'price': 180,
      'currency': 'EGP',
      'available': true,
      'image': 'assets/doctor4.jpg',
    },
    {
      'id': '3',
      'category': 'Radiology',
      'name': 'MRI Scan',
      'specialty': 'Full Body',
      'department': 'Radiology',
      'rating': 4.5,
      'reviews': 56,
      'price': 450,
      'currency': 'EGP',
      'available': true,
      'image': 'assets/mri.jpg',
    },
    {
      'id': '4',
      'category': 'Radiology',
      'name': 'CT Scan',
      'specialty': 'Chest',
      'department': 'Radiology',
      'rating': 4.6,
      'reviews': 43,
      'price': 350,
      'currency': 'EGP',
      'available': true,
      'image': 'assets/ct.jpg',
    },
    {
      'id': '5',
      'category': 'Lab Tests',
      'name': 'Complete Blood Count',
      'specialty': 'Blood Test',
      'department': 'Laboratory',
      'rating': 4.9,
      'reviews': 112,
      'price': 80,
      'currency': 'EGP',
      'available': true,
      'image': 'assets/blood_test.jpg',
    },
    {
      'id': '6',
      'category': 'Lab Tests',
      'name': 'Thyroid Profile',
      'specialty': 'Hormone Test',
      'department': 'Laboratory',
      'rating': 4.7,
      'reviews': 87,
      'price': 120,
      'currency': 'EGP',
      'available': true,
      'image': 'assets/thyroid.jpg',
    },
    {
      'id': '7',
      'category': 'Rooms',
      'name': 'Private Room',
      'specialty': 'Single Bed',
      'department': 'In-Patient',
      'rating': 4.8,
      'reviews': 63,
      'price': 250,
      'currency': 'EGP',
      'available': true,
      'image': 'assets/private_room.jpg',
    },
    {
      'id': '8',
      'category': 'Surgeries',
      'name': 'Appendectomy',
      'specialty': 'General Surgery',
      'department': 'Surgery',
      'rating': 4.9,
      'reviews': 42,
      'price': 3500,
      'currency': 'EGP',
      'available': true,
      'image': 'assets/surgery.jpg',
    },
  ];

  List<String> get categories {
    final List<String> cats = _servicesData.map((service) => service['category'] as String).toSet().toList();
    cats.insert(0, 'All');
    return cats;
  }

  List<Map<String, dynamic>> get filteredServices {
    return _servicesData.where((service) {
      // Apply category filter
      if (_selectedCategory != 'All' && service['category'] != _selectedCategory) {
        return false;
      }

      // Apply search query
      if (_searchQuery.isNotEmpty) {
        final name = service['name'].toString().toLowerCase();
        final specialty = service['specialty'].toString().toLowerCase();
        final searchLower = _searchQuery.toLowerCase();
        if (!name.contains(searchLower) && !specialty.contains(searchLower)) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  void _sortServices() {
    final services = filteredServices;
    services.sort((a, b) {
      switch (_selectedFilter) {
        case 'Price: Low to High':
          return (a['price'] as num).compareTo(b['price'] as num);
        case 'Price: High to Low':
          return (b['price'] as num).compareTo(a['price'] as num);
        case 'Rating':
          return (b['rating'] as num).compareTo(a['rating'] as num);
        case 'Recommended':
        default:
        // For recommended, use a combination of rating and reviews
          final aScore = (a['rating'] as num) * 0.7 + (a['reviews'] as num) / 100 * 0.3;
          final bScore = (b['rating'] as num) * 0.7 + (b['reviews'] as num) / 100 * 0.3;
          return bScore.compareTo(aScore);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Widget to display the greeting
  Widget _buildGreetingWidget() {
    return AnimationConfiguration.synchronized(
      duration: const Duration(milliseconds: 600),
      child: SlideAnimation(
        verticalOffset: 50.0,
        child: FadeInAnimation(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Theme.of(context).primaryColor, Theme.of(context).primaryColor.withOpacity(0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).primaryColor.withOpacity(0.3),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                getGreetingByTime(widget.userName),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _sortServices();

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App Bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.menu, color: Colors.black87), // Changed from back button to menu
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => MainScreen()),
                      );
                      // Open drawer or show menu
                      Scaffold.of(context).openDrawer();
                    },
                  ),
                  Expanded(
                    child: Text(
                      "Hospital Services",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.notifications_outlined, color: Colors.black87),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => NotificationsScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),

            // Greeting widget
            if (widget.userName.isNotEmpty) _buildGreetingWidget(),

            // Search Bar
            AnimationConfiguration.synchronized(
              duration: const Duration(milliseconds: 500),
              child: SlideAnimation(
                verticalOffset: 50.0,
                child: FadeInAnimation(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                        },
                        decoration: InputDecoration(
                          hintText: "Search services, doctors...",
                          prefixIcon: Icon(Icons.search, color: Colors.grey),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                            icon: Icon(Icons.clear, color: Colors.grey),
                            onPressed: () {
                              setState(() {
                                _searchController.clear();
                                _searchQuery = '';
                              });
                            },
                          )
                              : null,
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 15),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Filters row
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Filter dropdown
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedFilter,
                        icon: Icon(Icons.filter_list, size: 18),
                        style: TextStyle(color: Colors.black87, fontSize: 14),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              _selectedFilter = newValue;
                            });
                          }
                        },
                        items: <String>[
                          'Recommended',
                          'Rating',
                          'Price: Low to High',
                          'Price: High to Low',
                        ].map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ),
                  ),

                  // View toggle (grid/list)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.grid_view,
                              color: Theme.of(context).primaryColor),
                          onPressed: () {
                            // Set to grid view (already in grid view)
                          },
                          iconSize: 20,
                          padding: EdgeInsets.all(8),
                          constraints: BoxConstraints(),
                        ),
                        IconButton(
                          icon: Icon(Icons.view_list, color: Colors.grey),
                          onPressed: () {
                            // Toggle to list view
                          },
                          iconSize: 20,
                          padding: EdgeInsets.all(8),
                          constraints: BoxConstraints(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Categories
            Container(
              height: 40,
              child: AnimationConfiguration.synchronized(
                duration: const Duration(milliseconds: 400),
                child: SlideAnimation(
                  horizontalOffset: 50.0,
                  child: FadeInAnimation(
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final category = categories[index];
                        final isSelected = category == _selectedCategory;

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedCategory = category;
                            });
                          },
                          child: Container(
                            margin: EdgeInsets.only(right: 12),
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Theme.of(context).primaryColor
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected
                                    ? Theme.of(context).primaryColor
                                    : Colors.grey.shade300,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              category,
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.black87,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),

            // Services Grid
            Expanded(
              child: filteredServices.isEmpty
                  ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                  Icon(
                  Icons.search_off,
                  size: 70,
                  color: Colors.grey.shade400,
                ),
                SizedBox(height: 16),
                Text(
                  "No services found",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey.shade600,
                  ),
                ),
                  SizedBox(height: 8),
                Text(
        "Try changing your search or filters",
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey.shade500,
        ),
      ),
      ],
    ),
    )
        : AnimationLimiter(
      child: GridView.builder(
        padding: EdgeInsets.all(16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: filteredServices.length,
        itemBuilder: (context, index) {
          final service = filteredServices[index];

          return AnimationConfiguration.staggeredGrid(
            position: index,
            duration: const Duration(milliseconds: 300),
            columnCount: 2,
            child: ScaleAnimation(
              scale: 0.9,
              child: FadeInAnimation(
                child: GestureDetector(
                  onTap: () {
                    // Navigate to time selection screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TimeSelectionScreen(service: service),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Image with category tag
                        Container(
                          height: 120,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(16),
                              topRight: Radius.circular(16),
                            ),
                            image: DecorationImage(
                              image: AssetImage(service['image']),
                              fit: BoxFit.cover,
                            ),
                          ),
                          child: Stack(
                            children: [
                              Positioned(
                                top: 8,
                                left: 8,
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).primaryColor,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    service['category'],
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Service details
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                service['name'],
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 4),
                              Text(
                                service['specialty'],
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 12,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                    size: 16,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    "${service['rating']}",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    "(${service['reviews']})",
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "\$${service['price']}",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: service['available']
                                          ? Colors.green.shade100
                                          : Colors.red.shade100,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      service['available'] ? "Available" : "Unavailable",
                                      style: TextStyle(
                                        color: service['available']
                                            ? Colors.green.shade800
                                            : Colors.red.shade800,
                                        fontSize: 10,
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
              ),
            ),
          );
        },
      ),
    ),
    ),
              ],
          ),
        ),
    );
  }
}