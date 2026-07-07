import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Helpers {
  // Format date to readable string
  static String formatDate(DateTime date) {
    return DateFormat('MMM d, yyyy').format(date);
  }

  // Format date with time
  static String formatDateTime(DateTime date) {
    return DateFormat('MMM d, yyyy • h:mm a').format(date);
  }

  // Format time only
  static String formatTime(DateTime date) {
    return DateFormat('h:mm a').format(date);
  }

  // Format duration in minutes to readable string
  static String formatDuration(int minutes) {
    if (minutes < 60) {
      return '$minutes min';
    } else {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      if (remainingMinutes == 0) {
        return '${hours}h';
      }
      return '${hours}h ${remainingMinutes}min';
    }
  }

  // Calculate pace (minutes per km)
  static double calculatePace(int minutes, double distanceKm) {
    if (distanceKm <= 0) return 0;
    return minutes / distanceKm;
  }

  // Format pace to string
  static String formatPace(double pace) {
    if (pace <= 0) return '--';
    final minutes = pace.floor();
    final seconds = ((pace - minutes) * 60).round();
    return '$minutes:$seconds';
  }

  // Calculate calories based on MET
  static int calculateCalories(
    double weightKg,
    double met,
    int minutes,
  ) {
    return (met * weightKg * (minutes / 60)).round();
  }

  // Validate email
  static bool isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  // Validate password strength
  static bool isStrongPassword(String password) {
    if (password.length < 8) return false;
    bool hasUppercase = password.contains(RegExp(r'[A-Z]'));
    bool hasLowercase = password.contains(RegExp(r'[a-z]'));
    bool hasDigits = password.contains(RegExp(r'[0-9]'));
    bool hasSpecialCharacters =
        password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    return hasUppercase && hasLowercase && hasDigits && hasSpecialCharacters;
  }

  // Get greeting based on time of day
  static String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else if (hour < 21) {
      return 'Good Evening';
    } else {
      return 'Good Night';
    }
  }

  // Truncate text with ellipsis
  static String truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  // Get initials from name
  static String getInitials(String name) {
    if (name.isEmpty) return '';
    final names = name.trim().split(' ');
    if (names.length == 1) return names[0][0].toUpperCase();
    return '${names[0][0]}${names.last[0]}'.toUpperCase();
  }

  // Check if date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  // Check if date is this week
  static bool isThisWeek(DateTime date) {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    return date.isAfter(weekAgo) && date.isBefore(now);
  }

  // Get week number
  static int getWeekNumber(DateTime date) {
    final jan1 = DateTime(date.year, 1, 1);
    final diff = date.difference(jan1).inDays;
    return (diff / 7).floor() + 1;
  }

  // Convert steps to distance (assuming average step length of 0.762 meters)
  static double stepsToKm(int steps) {
    return (steps * 0.762) / 1000;
  }

  // Convert steps to distance in miles
  static double stepsToMiles(int steps) {
    return (steps * 0.762) / 1609.34;
  }

  // Format decimal to percentage
  static String formatPercentage(double value) {
    return '${(value * 100).toStringAsFixed(1)}%';
  }

  // Get color based on value (for progress bars)
  static Color getProgressColor(double progress) {
    if (progress >= 0.8) {
      return Colors.green;
    } else if (progress >= 0.5) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  // Generate random color
  static Color getRandomColor() {
    final random = DateTime.now().millisecondsSinceEpoch % 5;
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.pink,
      Colors.amber,
    ];
    return colors[random % colors.length];
  }

  // Format number with commas
  static String formatNumber(int number) {
    return NumberFormat('#,###').format(number);
  }

  // Format currency
  static String formatCurrency(double amount) {
    return NumberFormat.currency(
      symbol: '\$',
      decimalDigits: 2,
    ).format(amount);
  }

  // Get weekday name
  static String getWeekdayName(DateTime date) {
    return DateFormat('EEEE').format(date);
  }

  // Get short weekday name
  static String getShortWeekdayName(DateTime date) {
    return DateFormat('E').format(date);
  }

  // Get month name
  static String getMonthName(DateTime date) {
    return DateFormat('MMMM').format(date);
  }

  // Get short month name
  static String getShortMonthName(DateTime date) {
    return DateFormat('MMM').format(date);
  }
}
