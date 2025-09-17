class UserSettings {
  static int restingHeartRate = 65;
  static int maxHeartRate = 180;
  static int dailyStepsGoal = 10000;
  static int dailyCaloriesGoal = 500;
  static int lowSpO2Threshold = 95;
  static int criticalSpO2Threshold = 92;
  static bool enableRealTimeUpdates = true;
  static bool enableHealthAlerts = true;
  static String preferredUnits = 'Metric';
  
  // Alert thresholds
  static Map<String, Map<String, int>> alertThresholds = {
    'heartRate': {
      'low': 50,
      'high': 120,
    },
    'spo2': {
      'low': 92,
      'critical': 88,
    },
    'steps': {
      'daily_goal': 10000,
    },
    'calories': {
      'daily_goal': 500,
    },
  };
  
  static void updateRestingHeartRate(int value) {
    restingHeartRate = value;
  }
  
  static void updateStepsGoal(int value) {
    dailyStepsGoal = value;
    alertThresholds['steps']!['daily_goal'] = value;
  }
  
  static void updateCaloriesGoal(int value) {
    dailyCaloriesGoal = value;
    alertThresholds['calories']!['daily_goal'] = value;
  }
  
  static void updateSpO2Thresholds(int low, int critical) {
    lowSpO2Threshold = low;
    criticalSpO2Threshold = critical;
    alertThresholds['spo2']!['low'] = critical;
  }
}