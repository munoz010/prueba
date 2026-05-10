class UserModel {
  final String uid;
  final String email;
  final String firstName;
  final String lastName;

  const UserModel({
    required this.uid,
    required this.email,
    required this.firstName,
    required this.lastName,
  });

  String get fullName => '$firstName $lastName';

  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid: uid,
      email: map['email'] ?? '',
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
        'email': email,
        'firstName': firstName,
        'lastName': lastName,
      };
}
