// A simple model class to represent user data
class UserModel {
  final String? uid;
  final String? email;
  final String? displayName;
  final String? photoURL;

  UserModel({this.uid, this.email, this.displayName, this.photoURL});

  // Create a UserModel from Firebase User
  factory UserModel.fromFirebaseUser(dynamic user) {
    if (user == null) return UserModel();

    return UserModel(
      uid: user.uid,
      email: user.email,
      displayName: user.displayName,
      photoURL: user.photoURL,
    );
  }

  // Check if the user is authenticated
  bool get isAuthenticated => uid != null;
}
