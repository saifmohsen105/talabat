class UserProfile {
  const UserProfile({required this.id, required this.fullName, this.phone});

  final String id;
  final String fullName;
  final String? phone;

  factory UserProfile.fromMap(Map<String, dynamic> map) => UserProfile(
        id: map['id'] as String,
        fullName: map['full_name'] as String? ?? '',
        phone: map['phone'] as String?,
      );
}
