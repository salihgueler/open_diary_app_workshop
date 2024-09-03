class UserInformation {
  const UserInformation({
    required this.id,
    required this.email,
    required this.username,
    required this.fullName,
  });

  final String id;
  final String email;
  final String username;
  final String fullName;

  @override
  int get hashCode => Object.hashAll([
        id,
        email,
        username,
        fullName,
      ]);

  @override
  bool operator ==(Object other) {
    return other is UserInformation &&
        (id == other.id) &&
        (email == other.email) &&
        (username == other.username) &&
        (fullName == other.fullName);
  }
}
