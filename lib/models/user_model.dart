/// Represents an Instagram user (post author or story author).
/// Kept immutable — state changes go through providers, not mutations.
class UserModel {
  final String id;
  final String username;
  final String displayName;
  final String avatarUrl;
  final bool isVerified;

  const UserModel({
    required this.id,
    required this.username,
    required this.displayName,
    required this.avatarUrl,
    this.isVerified = false,
  });

  /// Factory constructor for quick mock data creation
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as String,
      username: map['username'] as String,
      displayName: map['displayName'] as String,
      avatarUrl: map['avatarUrl'] as String,
      isVerified: (map['isVerified'] as bool?) ?? false,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'username': username,
        'displayName': displayName,
        'avatarUrl': avatarUrl,
        'isVerified': isVerified,
      };
}
