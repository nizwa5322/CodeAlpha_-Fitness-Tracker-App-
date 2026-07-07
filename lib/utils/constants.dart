import 'package:flutter/material.dart';

class AppConstants {
  static const String appName = 'Fitness Tracker';
  static const String dbName = 'fitness_tracker.db';
  static const int dbVersion = 2;

  // Colors
  static const Color primaryColor = Color(0xFF00BCD4);
  static const Color secondaryColor = Color(0xFF4CAF50);
  static const Color accentColor = Color(0xFF00E676);
  static const Color backgroundColor = Color(0xFF121212);
  static const Color cardColor = Color(0xFF1E1E1E);
  static const Color textColor = Color(0xFFFFFFFF);
  static const Color subtextColor = Color(0xFF9E9E9E);

  // Icons
  static const IconData stepsIcon = Icons.directions_walk;
  static const IconData caloriesIcon = Icons.local_fire_department;
  static const IconData workoutIcon = Icons.fitness_center;
  static const IconData calendarIcon = Icons.calendar_today;

  // Workout Types
  static const List<String> workoutTypes = [
    'Running',
    'Cycling',
    'Weightlifting',
    'Yoga',
    'Walking',
    'Swimming',
    'HIIT',
    'Pilates',
    'Dancing',
    'Boxing',
  ];

  // Workout Icons Map
  IconData getIcon(String type) {
    switch (type.toLowerCase()) {
      case 'running':
        return Icons.directions_run;
      case 'cycling':
        return Icons.directions_bike; // Fixed: Changed from Icons.cycling
      case 'weightlifting':
        return Icons.fitness_center;
      case 'yoga':
        return Icons.self_improvement;
      case 'walking':
        return Icons.directions_walk;
      case 'swimming':
        return Icons.pool;
      case 'hiit':
        return Icons.flash_on;
      default:
        return Icons.fitness_center;
    }
  }

  // Workout Colors Map
  static const Map<String, Color> workoutColors = {
    'Running': Colors.blue,
    'Cycling': Colors.green,
    'Weightlifting': Colors.orange,
    'Yoga': Colors.purple,
    'Walking': Colors.teal,
    'Swimming': Colors.cyan,
    'HIIT': Colors.red,
    'Pilates': Colors.pink,
    'Dancing': Colors.amber,
    'Boxing': Colors.deepOrange,
  };

  // Duration Options
  static const List<int> durationOptions = [
    5,
    10,
    15,
    20,
    25,
    30,
    35,
    40,
    45,
    50,
    55,
    60,
    75,
    90,
    120
  ];

  // Calories Burned Reference (per 30 minutes)
  static const Map<String, int> caloriesPer30Min = {
    'Running': 300,
    'Cycling': 250,
    'Weightlifting': 200,
    'Yoga': 150,
    'Walking': 120,
    'Swimming': 280,
    'HIIT': 350,
    'Pilates': 170,
    'Dancing': 220,
    'Boxing': 320,
  };

  // Default Values
  static const int defaultSteps = 0;
  static const int defaultCalories = 0;
  static const int defaultDuration = 0;
  static const String defaultWorkoutType = 'Running';

  // Chart Settings
  static const int chartDays = 7;
  static const double chartHeight = 200;
  static const double chartBarWidth = 4;
  static const double chartDotRadius = 5;

  // Animation Durations
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration pageTransitionDuration = Duration(milliseconds: 500);

  // Spacing
  static const double spacingSmall = 8;
  static const double spacingMedium = 16;
  static const double spacingLarge = 24;
  static const double spacingXL = 32;
  static const double spacingXXL = 48;

  // Border Radius
  static const double radiusSmall = 8;
  static const double radiusMedium = 12;
  static const double radiusLarge = 16;
  static const double radiusXL = 20;
  static const double radiusXXL = 24;

  // Text Styles
  static const TextStyle headingStyle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: textColor,
  );

  static const TextStyle subheadingStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: textColor,
  );

  static const TextStyle bodyStyle = TextStyle(
    fontSize: 14,
    color: textColor,
  );

  static const TextStyle captionStyle = TextStyle(
    fontSize: 12,
    color: subtextColor,
  );

  // Shared Preferences Keys
  static const String prefUserLoggedIn = 'user_logged_in';
  static const String prefUserName = 'user_name';
  static const String prefUserEmail = 'user_email';
  static const String prefDailyGoal = 'daily_goal';
  static const String prefLastSync = 'last_sync';

  // Firebase Collections (if using Firebase)
  static const String firebaseUsers = 'users';
  static const String firebaseRecords = 'fitness_records';
  static const String firebaseGoals = 'goals';

  // Notification Channels
  static const String notificationChannelId = 'fitness_channel';
  static const String notificationChannelName = 'Fitness Tracker Notifications';
  static const String notificationChannelDescription =
      'Reminders for fitness activities';

  // Graph Colors
  static const List<Color> graphColors = [
    Color(0xFF00BCD4),
    Color(0xFF4CAF50),
    Color(0xFFFF9800),
    Color(0xFF9C27B0),
    Color(0xFFF44336),
    Color(0xFF03A9F4),
    Color(0xFF8BC34A),
  ];

  // Goal Defaults
  static const int dailyStepGoal = 10000;
  static const int dailyCalorieGoal = 500;
  static const int dailyWorkoutGoal = 30;

  // Local Storage Keys
  static const String storageUserData = 'user_data';
  static const String storageFitnessRecords = 'fitness_records';
  static const String storageSettings = 'settings';
}
