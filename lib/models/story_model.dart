import 'user_model.dart';

/// Represents a story bubble in the horizontal stories tray.
class StoryModel {
  final String id;
  final UserModel user;
  final bool isViewed;
  final bool isYourStory; // The first "Your Story" bubble

  const StoryModel({
    required this.id,
    required this.user,
    this.isViewed = false,
    this.isYourStory = false,
  });
}
