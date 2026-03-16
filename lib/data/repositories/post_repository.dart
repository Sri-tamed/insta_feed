import '../../models/post_model.dart';
import '../../models/story_model.dart';
import '../services/mock_data_service.dart';

/// Abstract contract — allows swapping MockDataService for a real API client
/// without touching any provider or UI code. Classic Repository pattern.
abstract class PostRepositoryBase {
  Future<List<StoryModel>> getStories();
  Future<List<PostModel>> getPosts({required int page, int pageSize = 10});
}

/// Concrete implementation backed by [MockDataService].
/// In production, replace MockDataService with an ApiClient (Dio/http).
class PostRepository implements PostRepositoryBase {
  final MockDataService _service;

  /// Dependency-injected so we can swap with a test double in unit tests.
  PostRepository({MockDataService? service})
      : _service = service ?? MockDataService();

  @override
  Future<List<StoryModel>> getStories() => _service.fetchStories();

  @override
  Future<List<PostModel>> getPosts({
    required int page,
    int pageSize = 10,
  }) =>
      _service.fetchPosts(page: page, pageSize: pageSize);
}
