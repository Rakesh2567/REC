class AppConstants {
  // BLE Constants
  static const String bleServiceUUID = '0000180F-0000-1000-8000-00805F9B34FB';
  static const String bleCharacteristicUUID =
      '00002A19-0000-1000-8000-00805F9B34FB';
  static const String bleDevicePrefix = 'ATTENDIFY_';

  // Session Constants
  static const int defaultSessionDuration = 60; // minutes
  static const int bleSignalRefreshInterval = 2; // seconds
  static const int proximityThreshold = -70; // RSSI threshold

  // Points System
  static const int pointsPerAttendance = 100;
  static const int pointsForPerfectWeek = 500;
  static const int pointsForEarlyArrival = 50;

  // Storage Keys
  static const String keyCurrentUser = 'current_user';
  static const String keyUserType = 'user_type';
  static const String keyThemeMode = 'theme_mode';
}
