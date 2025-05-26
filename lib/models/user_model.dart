import '../utils/calorie_calculator.dart';

// A comprehensive model class to represent user data
class UserModel {
  final String id;
  final String email;
  final String? displayName;
  final String? photoURL;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final double? weight; // in kg
  final double? height; // in cm
  final String? gender; // 'Male', 'Female', 'Other'
  final int? age;
  final String?
  activityLevel; // 'Sedentary', 'Lightly Active', 'Moderately Active', 'Very Active', 'Extremely Active'
  final String? goal; // 'Lose Weight', 'Maintain Weight', 'Gain Weight'
  final int? dailyCalorieTarget;
  final bool? isOnboardingCompleted;

  UserModel({
    required this.id,
    required this.email,
    this.displayName,
    this.photoURL,
    this.createdAt,
    this.updatedAt,
    this.weight,
    this.height,
    this.gender,
    this.age,
    this.activityLevel,
    this.goal,
    this.dailyCalorieTarget,
    this.isOnboardingCompleted,
  });

  // Create a UserModel from Firebase User (for authentication)
  static UserModel? fromFirebaseUser(dynamic user) {
    if (user == null) {
      return null;
    }

    return UserModel(
      id: user.uid,
      email: user.email ?? '',
      displayName: user.displayName,
      photoURL: user.photoURL,
      // Other fields will be loaded from Firestore
    );
  }

  // Create a UserModel from Firestore data
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      displayName: map['displayName'],
      photoURL: map['photoURL'],
      createdAt: map['createdAt']?.toDate(),
      updatedAt: map['updatedAt']?.toDate(),
      weight:
          (map['weight'] != null) ? (map['weight'] as num).toDouble() : null,
      height:
          (map['height'] != null) ? (map['height'] as num).toDouble() : null,
      gender: map['gender'],
      age: map['age'],
      activityLevel: map['activityLevel'],
      goal: map['goal'],
      dailyCalorieTarget: map['dailyCalorieTarget'],
      isOnboardingCompleted: map['isOnboardingCompleted'],
    );
  }

  // Convert UserModel to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'weight': weight,
      'height': height,
      'gender': gender,
      'age': age,
      'activityLevel': activityLevel,
      'goal': goal,
      'dailyCalorieTarget': dailyCalorieTarget,
      'isOnboardingCompleted': isOnboardingCompleted,
    };
  }

  // Create a copy of UserModel with updated fields
  UserModel copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoURL,
    DateTime? createdAt,
    DateTime? updatedAt,
    double? weight,
    double? height,
    String? gender,
    int? age,
    String? activityLevel,
    String? goal,
    int? dailyCalorieTarget,
    bool? isOnboardingCompleted,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      gender: gender ?? this.gender,
      age: age ?? this.age,
      activityLevel: activityLevel ?? this.activityLevel,
      goal: goal ?? this.goal,
      dailyCalorieTarget: dailyCalorieTarget ?? this.dailyCalorieTarget,
      isOnboardingCompleted:
          isOnboardingCompleted ?? this.isOnboardingCompleted,
    );
  }

  // Check if the user is authenticated
  bool get isAuthenticated => id.isNotEmpty;

  // Get display name or fallback to email
  String get displayText => displayName ?? email.split('@').first;

  // Check if user has a profile picture
  bool get hasProfilePicture => photoURL != null && photoURL!.isNotEmpty;

  // Calculate BMI if height and weight are available
  double? get bmi {
    if (height != null && weight != null && height! > 0) {
      // BMI = weight(kg) / (height(m))^2
      final heightInMeters = height! / 100;
      return weight! / (heightInMeters * heightInMeters);
    }
    return null;
  }

  // Get BMI category
  String? get bmiCategory {
    final userBmi = bmi;
    if (userBmi == null) return null;

    if (userBmi < 18.5) {
      return 'Underweight';
    } else if (userBmi < 25) {
      return 'Normal';
    } else if (userBmi < 30) {
      return 'Overweight';
    } else {
      return 'Obese';
    }
  }

  // Calculate BMR (Basal Metabolic Rate) using Mifflin-St Jeor Equation
  double? get bmr {
    if (weight == null || height == null || age == null || gender == null) {
      return null;
    }

    return CalorieCalculator.calculateBMR(
      weight: weight!,
      height: height!,
      age: age!,
      gender: gender!,
    );
  }

  // Calculate TDEE (Total Daily Energy Expenditure)
  double? get tdee {
    final userBmr = bmr;
    if (userBmr == null || activityLevel == null) return null;

    return CalorieCalculator.calculateTDEE(
      bmr: userBmr,
      activityLevel: activityLevel!,
    );
  }

  // Calculate recommended daily calorie target based on goal
  int? get recommendedDailyCalorieTarget {
    final userTdee = tdee;
    if (userTdee == null || goal == null) return null;

    return CalorieCalculator.calculateDailyCalorieTarget(
      tdee: userTdee,
      goal: goal!,
    );
  }

  // Check if user has enough data for automatic calorie calculation
  bool get canCalculateCalories {
    return weight != null &&
        height != null &&
        age != null &&
        gender != null &&
        activityLevel != null &&
        goal != null;
  }

  // Get the effective daily calorie target (manual or calculated)
  int? get effectiveDailyCalorieTarget {
    // If user has set a manual target, use that
    if (dailyCalorieTarget != null && dailyCalorieTarget! > 0) {
      return dailyCalorieTarget;
    }

    // Otherwise, use the calculated recommendation
    return recommendedDailyCalorieTarget;
  }

  // Override toString for debugging
  @override
  String toString() {
    return 'UserModel(id: $id, email: $email, displayName: $displayName)';
  }

  // Override equality operator
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel &&
        other.id == id &&
        other.email == email &&
        other.displayName == displayName &&
        other.photoURL == photoURL &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.weight == weight &&
        other.height == height &&
        other.gender == gender &&
        other.age == age &&
        other.activityLevel == activityLevel &&
        other.goal == goal &&
        other.dailyCalorieTarget == dailyCalorieTarget &&
        other.isOnboardingCompleted == isOnboardingCompleted;
  }

  // Override hashCode
  @override
  int get hashCode {
    return id.hashCode ^
        email.hashCode ^
        displayName.hashCode ^
        photoURL.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode ^
        weight.hashCode ^
        height.hashCode ^
        gender.hashCode ^
        age.hashCode ^
        activityLevel.hashCode ^
        goal.hashCode ^
        dailyCalorieTarget.hashCode ^
        isOnboardingCompleted.hashCode;
  }
}
