import '../../models/post_model.dart';
import '../../models/story_model.dart';
import '../../models/user_model.dart';

/// Pure data layer — no Flutter dependencies.
/// In a real app, this would be an HTTP client calling the Instagram API.
/// Here we return crafted mock data with realistic Unsplash image URLs.
class MockDataService {
  // ---------------------------------------------------------------------------
  // Static user pool — reused across posts and stories
  // ---------------------------------------------------------------------------
  static final List<UserModel> _users = [
    UserModel(
      id: 'u1',
      username: 'alex.captures',
      displayName: 'Alex Rivera',
      avatarUrl: 'https://i.pravatar.cc/150?img=1',
      isVerified: false,
    ),
    UserModel(
      id: 'u2',
      username: 'nat.geo.fan',
      displayName: 'Natalie Green',
      avatarUrl: 'https://i.pravatar.cc/150?img=5',
      isVerified: true,
    ),
    UserModel(
      id: 'u3',
      username: 'urban.frames',
      displayName: 'Marco Di Silva',
      avatarUrl: 'https://i.pravatar.cc/150?img=8',
    ),
    UserModel(
      id: 'u4',
      username: 'wanderlust.co',
      displayName: 'Sophia Park',
      avatarUrl: 'https://i.pravatar.cc/150?img=12',
      isVerified: true,
    ),
    UserModel(
      id: 'u5',
      username: 'studio.lenses',
      displayName: 'James Chen',
      avatarUrl: 'https://i.pravatar.cc/150?img=15',
    ),
    UserModel(
      id: 'u6',
      username: 'the.minimalist',
      displayName: 'Emma Wilson',
      avatarUrl: 'https://i.pravatar.cc/150?img=20',
    ),
    UserModel(
      id: 'u7',
      username: 'coastal.vibes',
      displayName: 'Liam Torres',
      avatarUrl: 'https://i.pravatar.cc/150?img=25',
    ),
    UserModel(
      id: 'u8',
      username: 'dark.room.dev',
      displayName: 'Aria Patel',
      avatarUrl: 'https://i.pravatar.cc/150?img=30',
      isVerified: true,
    ),
  ];

  // "Your Story" user — represents the logged-in user
  static final UserModel _currentUser = UserModel(
    id: 'me',
    username: 'you',
    displayName: 'You',
    avatarUrl: 'https://i.pravatar.cc/150?img=50',
  );

  // ---------------------------------------------------------------------------
  // High-quality Unsplash image pools
  // ---------------------------------------------------------------------------
  static const List<String> _singleImages = [
    'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=1080&q=80',
    'https://images.unsplash.com/photo-1469474968028-56623f02e42e?w=1080&q=80',
    'https://images.unsplash.com/photo-1501854140801-50d01698950b?w=1080&q=80',
    'https://images.unsplash.com/photo-1447752875215-b2761acb3c5d?w=1080&q=80',
    'https://images.unsplash.com/photo-1433086966358-54859d0ed716?w=1080&q=80',
    'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?w=1080&q=80',
    'https://images.unsplash.com/photo-1518173946687-a4c8892bbd9f?w=1080&q=80',
    'https://images.unsplash.com/photo-1475924156734-496f6cac6ec1?w=1080&q=80',
    'https://images.unsplash.com/photo-1465146344425-f00d5f5c8f07?w=1080&q=80',
    'https://images.unsplash.com/photo-1455218873509-8097305ee378?w=1080&q=80',
    'https://images.unsplash.com/photo-1486870591958-9b9d0d1dda99?w=1080&q=80',
    'https://images.unsplash.com/photo-1519681393784-d120267933ba?w=1080&q=80',
    'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=1080&q=80',
    'https://images.unsplash.com/photo-1476514525535-07fb3b4ae5f1?w=1080&q=80',
    'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?w=1080&q=80',
    'https://images.unsplash.com/photo-1500534314209-a25ddb2bd429?w=1080&q=80',
    'https://images.unsplash.com/photo-1534430480872-3498386e7856?w=1080&q=80',
    'https://images.unsplash.com/photo-1522199755839-a2bacb67c546?w=1080&q=80',
    'https://images.unsplash.com/photo-1488646953014-85cb44e25828?w=1080&q=80',
    'https://images.unsplash.com/photo-1504280390367-361c6d9f38f4?w=1080&q=80',
  ];

  static const List<List<String>> _carouselSets = [
    [
      'https://images.unsplash.com/photo-1527631746610-bca00a040d60?w=1080&q=80',
      'https://images.unsplash.com/photo-1503220317375-aaad61436b1b?w=1080&q=80',
      'https://images.unsplash.com/photo-1548574505-5e239809ee19?w=1080&q=80',
    ],
    [
      'https://images.unsplash.com/photo-1476514525535-07fb3b4ae5f1?w=1080&q=80',
      'https://images.unsplash.com/photo-1478391679764-b2d8b3cd1e94?w=1080&q=80',
      'https://images.unsplash.com/photo-1488085061387-422e29b40080?w=1080&q=80',
    ],
    [
      'https://images.unsplash.com/photo-1527004773467-83e4793cf6fb?w=1080&q=80',
      'https://images.unsplash.com/photo-1531366936337-7c912a4589a7?w=1080&q=80',
      'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=1080&q=80',
    ],
  ];

  static const List<String> _captions = [
    'Lost in the mountains. Found myself. 🏔️ #hiking #travel #nature',
    'Golden hour never disappoints ✨ #photography #sunset #golden',
    'City lights and midnight flights 🌃 #urban #city #nightlife',
    'The ocean is my happy place 🌊 #beach #ocean #waves',
    'Adventure awaits around every corner 🗺️ #adventure #explore #wanderlust',
    'Silence is golden when you\'re surrounded by nature 🌿 #forest #peace',
    'Chasing waterfalls and good vibes 💧 #waterfall #nature #travel',
    'Not all those who wander are lost 🧭 #travel #wanderlust',
    'The mountains are calling and I must go 🏕️ #camping #mountains',
    'Every sunset is a gift 🌅 #sunset #sky #photography',
    'Life is short. Eat the gelato. 🍦 #foodie #travel #italy',
    'New city, same wanderlust ✈️ #travel #explore #newplaces',
  ];

  static const List<String> _locations = [
    'Patagonia, Argentina',
    'Santorini, Greece',
    'Kyoto, Japan',
    'Dolomites, Italy',
    'Bali, Indonesia',
    'Iceland',
    'Maldives',
    'Swiss Alps',
    'New Zealand',
    'Amalfi Coast, Italy',
  ];

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Returns stories list — first item is always "Your Story"
  Future<List<StoryModel>> fetchStories() async {
    await Future.delayed(const Duration(milliseconds: 1500)); // Fake network latency

    final stories = <StoryModel>[
      StoryModel(
        id: 'story_me',
        user: _currentUser,
        isYourStory: true,
        isViewed: false,
      ),
    ];

    for (int i = 0; i < _users.length; i++) {
      stories.add(StoryModel(
        id: 'story_$i',
        user: _users[i],
        isViewed: i > 3, // First 3 unviewed, rest viewed
      ));
    }

    return stories;
  }

  /// Returns [pageSize] posts for [page] (0-indexed).
  /// Returns empty list when out of pages to signal end of feed.
  Future<List<PostModel>> fetchPosts({
    required int page,
    int pageSize = 10,
  }) async {
    await Future.delayed(const Duration(milliseconds: 1500)); // Simulate network

    // Simulate 4 pages max (~40 posts total)
    if (page >= 4) return [];

    final posts = <PostModel>[];
    final baseIndex = page * pageSize;

    for (int i = 0; i < pageSize; i++) {
      final globalIndex = baseIndex + i;
      final user = _users[globalIndex % _users.length];
      final isCarousel = globalIndex % 4 == 3; // Every 4th post is a carousel

      final imageUrls = isCarousel
          ? _carouselSets[globalIndex % _carouselSets.length]
          : [_singleImages[globalIndex % _singleImages.length]];

      posts.add(PostModel(
        id: 'post_$globalIndex',
        author: user,
        imageUrls: imageUrls,
        caption: _captions[globalIndex % _captions.length],
        likeCount: 1200 + (globalIndex * 137) % 50000,
        commentCount: 24 + (globalIndex * 53) % 2000,
        createdAt: DateTime.now().subtract(
          Duration(hours: globalIndex + 1),
        ),
        locationTag: globalIndex % 3 == 0
            ? _locations[globalIndex % _locations.length]
            : null,
      ));
    }

    return posts;
  }
}
