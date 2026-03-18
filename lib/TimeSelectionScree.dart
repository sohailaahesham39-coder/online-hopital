import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:intl/intl.dart';

import 'Bottom Navigation/Payment/Payment Screen.dart';

// Time Selection Screen - For booking appointments
class TimeSelectionScreen extends StatefulWidget {
  final Map<String, dynamic> service;

  const TimeSelectionScreen({Key? key, required this.service}) : super(key: key);

  @override
  _TimeSelectionScreenState createState() => _TimeSelectionScreenState();
}

class _TimeSelectionScreenState extends State<TimeSelectionScreen> {
  DateTime _selectedDate = DateTime.now();
  String? _selectedTimeSlot;

  // Generate next 7 days for date selection
  List<DateTime> get _availableDates {
    final List<DateTime> dates = [];
    final now = DateTime.now();
    for (int i = 0; i < 7; i++) {
      dates.add(DateTime(now.year, now.month, now.day + i));
    }
    return dates;
  }

  // Generate time slots (dynamic - could come from API)
  List<String> get _availableTimeSlots {
    // In a real app, this might change based on the selected date and service
    return [
      "09:00 AM", "09:30 AM", "10:00 AM", "10:30 AM",
      "11:00 AM", "11:30 AM", "01:00 PM", "01:30 PM",
      "02:00 PM", "02:30 PM", "03:00 PM", "03:30 PM",
      "04:00 PM", "04:30 PM", "05:00 PM"
    ];
  }

  bool _isTimeSlotAvailable(String timeSlot) {
    // In a real app, this would check with the backend
    // For this example, make some time slots unavailable randomly
    final slotIndex = _availableTimeSlots.indexOf(timeSlot);

    // Make a few specific slots unavailable
    return ![2, 5, 8].contains(slotIndex);
  }

  void _confirmBooking() {
    if (_selectedTimeSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please select a time slot"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Navigate to PaymentScreen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentScreen(
          service: widget.service,
          selectedDate: _selectedDate,
          selectedTimeSlot: _selectedTimeSlot!,
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Select Date & Time",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Service info card
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: AnimationConfiguration.synchronized(
              duration: const Duration(milliseconds: 500),
              child: SlideAnimation(
                verticalOffset: 50.0,
                child: FadeInAnimation(
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
                    padding: EdgeInsets.all(16),
                    child: Row(
                      children: [
                        // Service image
                        Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            image: DecorationImage(
                              image: AssetImage(
                                getServiceImage(widget.service['category']), // Get image based on category
                              ),
                              fit: BoxFit.cover, // Makes sure the image fills the container
                            ),
                          ),
                        ),
                        SizedBox(width: 16),

                        // Service details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.service['name'],
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                widget.service['specialty'],
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 14,
                                ),
                              ),
                              SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                    size: 16,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    "${widget.service['rating']} (${widget.service['reviews']} reviews)",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Price
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              "\$${widget.service['price']}",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              widget.service['currency'],
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                  ),
                ),
              ),
            ),
          ),

          // Date Selection
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              "Select Date",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          SizedBox(height: 12),

          // Horizontal date picker
          SizedBox(
            height: 90,
            child: AnimationLimiter(
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 12),
                itemCount: _availableDates.length,
                itemBuilder: (context, index) {
                  final date = _availableDates[index];
                  final isSelected = _selectedDate.day == date.day &&
                      _selectedDate.month == date.month &&
                      _selectedDate.year == date.year;

                  return AnimationConfiguration.staggeredList(
                    position: index,
                    duration: const Duration(milliseconds: 300),
                    child: SlideAnimation(
                      horizontalOffset: 50.0,
                      child: FadeInAnimation(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedDate = date;
                            });
                          },
                          child: Container(
                            width: 65,
                            margin: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? Theme.of(context).primaryColor : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 5,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  DateFormat('E').format(date).substring(0, 3),
                                  style: TextStyle(
                                    color: isSelected ? Colors.white : Colors.grey.shade700,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(height: 6),
                                Container(
                                  height: 36,
                                  width: 36,
                                  decoration: BoxDecoration(
                                    color: isSelected ? Colors.white.withOpacity(0.3) : Colors.transparent,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      date.day.toString(),
                                      style: TextStyle(
                                        color: isSelected ? Colors.white : Colors.black87,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
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
                },
              ),
            ),
          ),

          // Time Selection
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Select Time",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  DateFormat.yMMMd().format(_selectedDate),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
          ),

          // Time slots grid
          Expanded(
            child: AnimationLimiter(
              child: GridView.builder(
                padding: EdgeInsets.all(16),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 2.5,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: _availableTimeSlots.length,
                itemBuilder: (context, index) {
                  final timeSlot = _availableTimeSlots[index];
                  final isAvailable = _isTimeSlotAvailable(timeSlot);
                  final isSelected = _selectedTimeSlot == timeSlot;

                  return AnimationConfiguration.staggeredGrid(
                    position: index,
                    duration: const Duration(milliseconds: 300),
                    columnCount: 2,
                    child: ScaleAnimation(
                      scale: 0.9,
                      child: FadeInAnimation(
                        child: GestureDetector(
                          onTap: isAvailable
                              ? () {
                            setState(() {
                              _selectedTimeSlot = timeSlot;
                            });
                          }
                              : null,
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Theme.of(context).primaryColor
                                  : isAvailable
                                  ? Colors.white
                                  : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? Theme.of(context).primaryColor
                                    : isAvailable
                                    ? Colors.grey.shade300
                                    : Colors.grey.shade200,
                              ),
                            ),
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.access_time,
                                    size: 16,
                                    color: isSelected
                                        ? Colors.white
                                        : isAvailable
                                        ? Theme.of(context).primaryColor
                                        : Colors.grey.shade400,
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    timeSlot,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: isSelected
                                          ? Colors.white
                                          : isAvailable
                                          ? Colors.black87
                                          : Colors.grey.shade400,
                                    ),
                                  ),
                                ],
                              ),
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

          // Confirm booking button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: AnimationConfiguration.synchronized(
              duration: const Duration(milliseconds: 400),
              child: SlideAnimation(
                verticalOffset: 50.0,
                child: FadeInAnimation(
                  child: Container(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _confirmBooking,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 2,
                      ),
                      child: Text(
                        "Confirm Booking",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white, // Ensure text is white
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

        ],
      ),
    );
  }
}

String getServiceImage(String category) {
  switch (category) {
    case 'Doctors':
      return 'assets/doctor3.jpg';
    case 'Radiology':
      return 'assets/mri.jpg';
    case 'Lab Tests':
      return 'assets/blood_test.jpg';
    case 'Rooms':
      return 'assets/private_room.jpg';
    case 'Surgery':
      return 'assets/surgery.jpg';
    default:
      return 'assets/default_image.png'; // Fallback image
  }
}
