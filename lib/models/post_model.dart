import 'user_model.dart';

/// Represents a single Instagram post (single image or carousel).
/// [imageUrls] length > 1 means it's a carousel post.
class PostModel {
  final String id;
  final UserModel author;
  final List<String> imageUrls; // Multiple = carousel
  final String? caption;
  final int likeCount;
  final int commentCount;
  final DateTime createdAt;
  final String? locationTag;

  const PostModel({
    required this.id,
    required this.author,
    required this.imageUrls,
    this.caption,
    required this.likeCount,
    required this.commentCount,
    required this.createdAt,
    this.locationTag,
  });

  /// Whether this post has multiple images (carousel)
  bool get isCarousel => imageUrls.length > 1;

  /// Convenience: first image for thumbnail or single-image display
  String get primaryImageUrl => imageUrls.first;

  PostModel copyWith({
    String? id,
    UserModel? author,
    List<String>? imageUrls,
    String? caption,
    int? likeCount,
    int? commentCount,
    DateTime? createdAt,
    String? locationTag,
  }) {
    return PostModel(
      id: id ?? this.id,
      author: author ?? this.author,
      imageUrls: imageUrls ?? this.imageUrls,
      caption: caption ?? this.caption,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      createdAt: createdAt ?? this.createdAt,
      locationTag: locationTag ?? this.locationTag,
    );
  }
}
