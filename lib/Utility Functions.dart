import 'package:flutter/material.dart';

// Utility function to extract first name from username
String extractFirstNameFromUsername(String username) {
  // Return empty string if username is null or empty
  if (username.isEmpty) return '';

  // Method 1: Try to split by common separators first
  List<String> parts = username.split(RegExp(r'[._-]'));
  if (parts.length > 1) {
    // If we have separators, take the first part
    return capitalizeFirstLetter(parts.first);
  }

  // Method 2: Try to identify where the first name ends by looking for numbers
  RegExp namePattern = RegExp(r'^([a-zA-Z]+)(?:[0-9]|[A-Z])');
  var match = namePattern.firstMatch(username);
  if (match != null && match.group(1) != null) {
    return capitalizeFirstLetter(match.group(1)!);
  }

  // Method 3: For usernames like "sohila hesham" (no numbers),
  // try to split on camel case or when lowercase changes to uppercase
  RegExp camelCasePattern = RegExp(r'([a-z])([A-Z])');
  String withSpaces = username.replaceAllMapped(
      camelCasePattern,
          (match) => '${match.group(1)} ${match.group(2)}'
  );

  if (withSpaces.contains(' ')) {
    return capitalizeFirstLetter(withSpaces.split(' ').first);
  }

  // Method 4: If all else fails, just return the first 6 characters or the whole username
  // if it's shorter than 6 characters, as a reasonable guess for a first name
  if (username.length > 6) {
    return capitalizeFirstLetter(username.substring(0, 6));
  }

  // Return the full username if it's short
  return capitalizeFirstLetter(username);
}

// Helper function to capitalize first letter
String capitalizeFirstLetter(String text) {
  if (text.isEmpty) return '';
  return text[0].toUpperCase() + text.substring(1).toLowerCase();
}

// Function to get greeting based on time of day
String getGreetingByTime(String name) {
  if (name.isEmpty) return '';

  final hour = DateTime.now().hour;
  String greeting = '';

  if (hour < 12) {
    greeting = 'Good morning';
  } else if (hour < 17) {
    greeting = 'Good afternoon';
  } else {
    greeting = 'Good evening';
  }

  return '$greeting, $name';
}