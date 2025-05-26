// A comprehensive model class to represent user data
class UserModel {
  final String id;
  final String email;
  final String? displayName;
  final String? photoURL;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserModel({
    required this.id,
    required this.email,
    this.displayName,
    this.photoURL,
    this.createdAt,
    this.updatedAt,
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
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Check if the user is authenticated
  bool get isAuthenticated => id.isNotEmpty;

  // Get display name or fallback to email
  String get displayText => displayName ?? email.split('@').first;

  // Check if user has a profile picture
  bool get hasProfilePicture => photoURL != null && photoURL!.isNotEmpty;

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
        other.photoURL == photoURL;
  }

  // Override hashCode
  @override
  int get hashCode {
    return id.hashCode ^
        email.hashCode ^
        displayName.hashCode ^
        photoURL.hashCode;
  }
}
