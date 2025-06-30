class AppConstants {
  // App Information
  static const String appName = 'ToDoMini';
  static const String appVersion = '1.0.0';
  
  // Task Categories
  static const List<String> taskCategories = [
    'Personal',
    'Work',
    'Shopping',
    'Health',
    'Education',
    'Finance',
    'Travel',
    'Other',
  ];
  
  // Task Priorities
  static const List<String> taskPriorities = [
    'Low',
    'Medium',
    'High',
  ];
  
  // Database
  static const String databaseName = 'todomini.db';
  static const int databaseVersion = 1;
  
  // Shared Preferences Keys
  static const String themeKey = 'theme_mode';
  static const String firstLaunchKey = 'first_launch';
  
  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);
  
  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double borderRadius = 12.0;
  static const double cardElevation = 2.0;
  
  // Task Constants
  static const int maxTaskTitleLength = 100;
  static const int maxTaskDescriptionLength = 500;
  
  // Reminder Constants
  static const List<int> reminderMinutes = [5, 15, 30, 60, 120, 1440]; // 5min, 15min, 30min, 1hr, 2hr, 1day
  static const List<String> reminderLabels = ['5 min', '15 min', '30 min', '1 hour', '2 hours', '1 day'];
} 