import 'package:flutter/material.dart';
import 'comment_model.dart';
import 'dart:convert';

class Post {
  final String id;
  final String userId;
  final String userName;
  final String? userAvatarUrl;
  final String subject;
  final String content;
  final bool isPublic;
  final DateTime timestamp;
  int likes;
  bool isLiked;
  final String? imageBase64; // Changed from imageUrl to store base64
  final List<String> likedBy;
  final List<String> tags;
  final List<Comment> comments;
  final int? imageSizeKB; // Track image size for optimization
  final String? category;
  final String? subCategory;

  Post({
    required this.id,
    required this.userId,
    required this.userName,
    this.userAvatarUrl,
    required this.subject,
    required this.content,
    required this.isPublic,
    required this.timestamp,
    this.likes = 0,
    this.isLiked = false,
    this.imageBase64,
    this.imageSizeKB,
    this.likedBy = const [],
    this.tags = const [],
    this.comments = const [],
    this.category,
    this.subCategory,
  });

  factory Post.fromMap(Map<dynamic, dynamic> map, String id) {
    // Handle comments conversion
    final commentsMap = map['comments'] as Map<dynamic, dynamic>? ?? {};
    final comments = commentsMap.entries.map((entry) {
      return Comment.fromMap(
        entry.value as Map<dynamic, dynamic>,
        entry.key as String,
      );
    }).toList();

    // Calculate image size if exists
    final imageBase64 = map['imageBase64'] as String?;
    final imageSizeKB = imageBase64 != null
        ? (base64Decode(imageBase64).lengthInBytes / 1024).round()
        : null;

    return Post(
      id: id,
      userId: map['userId'] ?? 'unknown',
      userName: map['userName'] ?? 'Anonymous',
      userAvatarUrl: map['userAvatarUrl'],
      subject: map['subject'] ?? '',
      content: map['content'] ?? '',
      isPublic: map['isPublic'] ?? true,
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] ?? 0),
      likes: map['likes'] ?? 0,
      isLiked: map['isLiked'] ?? false,
      imageBase64: imageBase64,
      imageSizeKB: imageSizeKB,
      likedBy: List<String>.from(map['likedBy'] ?? []),
      tags: List<String>.from(map['tags'] ?? []),
      comments: comments,
      category: map['category'] as String?,
      subCategory: map['subCategory'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    // Convert comments to map
    final commentsMap = {
      for (var comment in comments) comment.id: comment.toMap(),
    };

    return {
      'userId': userId,
      'userName': userName,
      'userAvatarUrl': userAvatarUrl,
      'subject': subject,
      'content': content,
      'isPublic': isPublic,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'likes': likes,
      'isLiked': isLiked,
      'imageBase64': imageBase64,
      'likedBy': likedBy,
      'tags': tags,
      'comments': commentsMap,
      'category': category,
      'subCategory': subCategory,
    };
  }

  // Helper methods
  bool get hasImage => imageBase64 != null && imageBase64!.isNotEmpty;

  bool hasTag(String tag) => tags.contains(tag);

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

  void addComment(Comment comment) {
    comments.add(comment);
  }

  void removeComment(String commentId) {
    comments.removeWhere((comment) => comment.id == commentId);
  }

  int get commentCount => comments.length;

  // Image utility methods
  ImageProvider? get imageProvider {
    if (!hasImage) return null;
    return MemoryImage(base64Decode(imageBase64!));
  }

  String get imageSizeInfo {
    if (imageSizeKB == null) return 'No image';
    return '${imageSizeKB}KB';
  }
}
