import 'intl.dart';

class Comment {
  final String id;
  final String postId; // Reference to the parent post
  final String userId;
  final String userName;
  final String? userAvatarUrl;
  final String content;
  final DateTime timestamp;
  int likes;
  bool isLiked;
  final List<String> likedBy;
  final String? imageUrl; // For image comments

  Comment({
    required this.id,
    required this.postId,
    required this.userId,
    required this.userName,
    this.userAvatarUrl,
    required this.content,
    required this.timestamp,
    this.likes = 0,
    this.isLiked = false,
    this.likedBy = const [],
    this.imageUrl,
  });

  factory Comment.fromMap(Map<dynamic, dynamic> map, String id) {
    return Comment(
      id: id,
      postId: map['postId'] ?? '',
      userId: map['userId'] ?? 'unknown',
      userName: map['userName'] ?? 'Anonymous',
      userAvatarUrl: map['userAvatarUrl'],
      content: map['content'] ?? '',
      timestamp: DateTime.fromMillisecondsSinceEpoch(
        map['timestamp'] ?? DateTime.now().millisecondsSinceEpoch,
      ),
      likes: map['likes'] ?? 0,
      isLiked: map['isLiked'] ?? false,
      likedBy: List<String>.from(map['likedBy'] ?? []),
      imageUrl: map['imageUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'postId': postId,
      'userId': userId,
      'userName': userName,
      'userAvatarUrl': userAvatarUrl,
      'content': content,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'likes': likes,
      'isLiked': isLiked,
      'likedBy': likedBy,
      'imageUrl': imageUrl,
    };
  }

  void toggleLike(String userId) {
    if (likedBy.contains(userId)) {
      likedBy.remove(userId);
      likes--;
      isLiked = false;
    } else {
      likedBy.add(userId);
      likes++;
      isLiked = true;
    }
  }

  bool get hasImage => imageUrl != null && imageUrl!.isNotEmpty;

  // Get relative time (e.g., "2 minutes ago")
  String get relativeTime {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inDays < 30) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else {
      return DateFormat('MMM d, y').format(timestamp);
    }
  }
}
