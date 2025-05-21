import 'dart:convert';
import 'dart:io';

import 'package:badges/badges.dart' as badges;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:manganuhu/models/comment_model.dart';
import 'package:manganuhu/models/post_model.dart';
import 'package:manganuhu/post/FullScreenImageView.dart';
import 'package:manganuhu/post/createpostscreen.dart';
import 'package:manganuhu/screens/challengesscreen.dart';
import 'package:manganuhu/screens/communityscreen.dart';
import 'package:manganuhu/screens/newsscreen.dart';
import 'package:manganuhu/screens/notificationscreen.dart';
import 'package:manganuhu/screens/profilescreen.dart';
import 'package:manganuhu/screens/storescreen.dart';

class HomeScreen extends StatefulWidget {
  final Map<String, dynamic>? userData;

  const HomeScreen({Key? key, this.userData}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _selectedCategory;
  String? _selectedSubCategory;
  Map<String, List<String>> _categories = {};
  bool _isLoadingCategories = false;
  int _currentIndex = 0;
  final List<Post> _posts = [];
  final DatabaseReference _postsRef = FirebaseDatabase.instance.ref('posts');
  // Add these variables
  int _unreadNotificationCount = 0;
  final DatabaseReference _notificationsRef = FirebaseDatabase.instance.ref(
    'notifications',
  );

  // Method to pick an image from gallery

  // Add this method to load notification count
  void _loadNotificationCount() {
    final currentUserEmail = FirebaseAuth.instance.currentUser?.email;
    if (currentUserEmail == null) return;

    _notificationsRef
        .orderByChild('receiverEmail')
        .equalTo(currentUserEmail)
        .onValue
        .listen((event) {
      if (event.snapshot.value != null) {
        final data = event.snapshot.value as Map<dynamic, dynamic>;
        final pendingNotifications = data.values
            .where(
              (notification) => notification['status'] == 'pending',
            )
            .length;

        setState(() {
          _unreadNotificationCount = pendingNotifications;
        });
      } else {
        setState(() {
          _unreadNotificationCount = 0;
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _loadPosts();
    _loadNotificationCount();
  }

  void _loadPosts() {
    _postsRef.orderByChild('timestamp').onValue.listen((event) {
      if (event.snapshot.value != null) {
        final data = event.snapshot.value as Map<dynamic, dynamic>;
        final loadedPosts = data.entries.map((entry) {
          return Post.fromMap(entry.value, entry.key);
        }).toList();

        // Sort posts by timestamp in descending order (newest first)
        loadedPosts.sort((a, b) => b.timestamp.compareTo(a.timestamp));

        setState(() {
          _posts
            ..clear()
            ..addAll(loadedPosts); // No need for .reversed now since we sorted
        });
      }
    });
  }

  Future<void> _addComment(Post post, String content) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || content.isEmpty) return;

    final commentsRef = _postsRef.child(post.id).child('comments');
    final newCommentRef = commentsRef.push();

    final newComment = Comment(
      id: newCommentRef.key!,
      postId: post.id,
      userId: user.uid,
      userName: user.displayName ?? 'Anonymous',
      userAvatarUrl: user.photoURL,
      content: content,
      timestamp: DateTime.now(),
    );

    await newCommentRef.set(newComment.toMap());
  }

  Future<void> _toggleLike(Post post) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final postRef = _postsRef.child(post.id);
    final isLiked = post.likedBy.contains(userId);
    final newLikedBy = List<String>.from(post.likedBy);

    if (isLiked) {
      newLikedBy.remove(userId);
    } else {
      newLikedBy.add(userId);
    }

    await postRef.update({
      'likedBy': newLikedBy,
      'likes': newLikedBy.length,
      'isLiked': !isLiked,
    });
  }

  void _showCommentsSheet(Post post) {
    final commentController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            color: Color.fromRGBO(0, 0, 0, 0.5),
            child: GestureDetector(
              onTap: () {},
              child: DraggableScrollableSheet(
                initialChildSize: 0.7,
                minChildSize: 0.5,
                maxChildSize: 0.9,
                builder: (context, scrollController) {
                  return Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    padding: EdgeInsets.only(
                      left: 16,
                      right: 16,
                      top: 16,
                      bottom: MediaQuery.of(context).viewInsets.bottom,
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Comments',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: StreamBuilder(
                            stream: _postsRef
                                .child(post.id)
                                .child('comments')
                                .onValue,
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }

                              final commentsData = snapshot.data!.snapshot.value
                                      as Map<dynamic, dynamic>? ??
                                  {};
                              final comments =
                                  commentsData.entries.map((entry) {
                                return Comment.fromMap(
                                  entry.value,
                                  entry.key,
                                );
                              }).toList();

                              if (comments.isEmpty) {
                                return const Center(
                                  child: Text('No comments yet'),
                                );
                              }

                              return ListView.builder(
                                controller: scrollController,
                                itemCount: comments.length,
                                itemBuilder: (context, index) {
                                  final comment = comments[index];
                                  return ListTile(
                                    leading: CircleAvatar(
                                      backgroundImage:
                                          comment.userAvatarUrl != null
                                              ? NetworkImage(
                                                  comment.userAvatarUrl!,
                                                )
                                              : null,
                                      child: comment.userAvatarUrl == null
                                          ? const Icon(Icons.person)
                                          : null,
                                    ),
                                    title: Text(comment.userName),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(comment.content),
                                        Text(
                                          comment.relativeTime,
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: commentController,
                                  decoration: InputDecoration(
                                    hintText: 'Write a comment...',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(24),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.send),
                                onPressed: () {
                                  if (commentController.text
                                      .trim()
                                      .isNotEmpty) {
                                    _addComment(post, commentController.text);
                                    commentController.clear();
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _markNotificationsAsRead() async {
    final currentUserEmail = FirebaseAuth.instance.currentUser?.email;
    if (currentUserEmail == null) return;

    final snapshot = await _notificationsRef
        .orderByChild('receiverEmail')
        .equalTo(currentUserEmail)
        .once();

    if (snapshot.snapshot.value != null) {
      final data = snapshot.snapshot.value as Map<dynamic, dynamic>;
      final updates = <String, dynamic>{};

      data.forEach((key, value) {
        if (value['status'] == 'pending') {
          updates['$key/status'] = 'read';
        }
      });

      if (updates.isNotEmpty) {
        await _notificationsRef.update(updates);
        setState(() {
          _unreadNotificationCount = 0;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ecomanga'),
        actions: [
          badges.Badge(
            position: badges.BadgePosition.topEnd(top: -10, end: -10),
            badgeContent: Text(
              _unreadNotificationCount > 0
                  ? _unreadNotificationCount.toString()
                  : '',
              style: const TextStyle(color: Colors.white, fontSize: 10),
            ),
            showBadge: _unreadNotificationCount > 0,
            child: IconButton(
              icon: const Icon(Icons.notifications),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NotificationsScreen(),
                  ),
                );
                // Mark notifications as read when opening
                _markNotificationsAsRead();
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ProfileScreen(),
              ),
            ),
          ),
        ],
      ),
      body: _posts.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _posts.length,
              itemBuilder: (context, index) => _PostCard(
                post: _posts[index],
                onToggleLike: _toggleLike,
                onShowComments: _showCommentsSheet,
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CreatePostScreen()),
        ),
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  BottomNavigationBar _buildBottomNavBar() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) {
        setState(() => _currentIndex = index);
        if (index == 1) {
          // Community tab index
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CommunityScreen()),
          );
        } else if (index == 2) {
          // Marketplace tab index
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const NewsScreen()),
          );
        } else if (index == 3) {
          // Marketplace tab index
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ProductScreen()),
          );
        } else if (index == 4) {
          // Challenges tab index
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ChallengesScreen()),
          );
        } else {
          // Home tab index
          setState(() => _currentIndex = index);
        }
      },
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF1A237E),
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Community'),
        BottomNavigationBarItem(icon: Icon(Icons.newspaper), label: 'news'),
        BottomNavigationBarItem(icon: Icon(Icons.store), label: 'Marketplace'),
        BottomNavigationBarItem(
          icon: Icon(Icons.emoji_events),
          label: 'Challenges',
        ),
      ],
    );
  }
}

class _PostCard extends StatelessWidget {
  final Post post;
  final Function(Post) onToggleLike;
  final Function(Post) onShowComments;

  const _PostCard({
    required this.post,
    required this.onToggleLike,
    required this.onShowComments,
  });

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    final isLikeda =
        currentUserId != null && post.likedBy.contains(currentUserId);
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => _showFullScreenPost(context),
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with user info
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: post.userAvatarUrl != null
                        ? NetworkImage(post.userAvatarUrl!)
                        : null,
                    child: post.userAvatarUrl == null
                        ? const Icon(Icons.person, size: 20)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.userName,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          DateFormat(
                            'MMM d, y • h:mm a',
                          ).format(post.timestamp),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Post content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (post.subject.isNotEmpty) ...[
                    Text(
                      post.subject,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                  ],
                  // Replace the current image display code in _PostCard with:
                  if (post.imageBase64 != null && post.imageBase64!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FullScreenImageView(
                                imageFile: File.fromRawPath(
                                  base64Decode(post.imageBase64!),
                                ),
                                onClose: () => Navigator.pop(context),
                              ),
                            ),
                          ),
                          child: Image.memory(
                            base64Decode(post.imageBase64!),
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  Text(
                    post.content,
                    style: theme.textTheme.bodyMedium,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),

            // Action buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      isLikeda ? Icons.favorite : Icons.favorite_border,
                      color: isLikeda ? Colors.red : theme.iconTheme.color,
                    ),
                    onPressed: () => onToggleLike(post),
                  ),
                  Text(post.likes.toString(), style: theme.textTheme.bodySmall),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.comment_outlined),
                    onPressed: () => onShowComments(post),
                  ),
                  Text(
                    post.commentCount.toString(),
                    style: theme.textTheme.bodySmall,
                  ),
                  const Spacer(),
                  if (post.hasImage)
                    Text(
                      '${post.imageSizeKB}KB',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFullScreenPost(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    final isLikeda =
        currentUserId != null && post.likedBy.contains(currentUserId);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.black,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          backgroundColor: Colors.black,
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User info
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundImage: post.userAvatarUrl != null
                            ? NetworkImage(post.userAvatarUrl!)
                            : null,
                        child: post.userAvatarUrl == null
                            ? const Icon(Icons.person, size: 24)
                            : null,
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            post.userName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            DateFormat(
                              'MMM d, y • h:mm a',
                            ).format(post.timestamp),
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Post content
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (post.subject.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(
                            post.subject,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      Text(
                        post.content,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),

                // Image (if exists)
                if (post.imageBase64 != null)
                  InteractiveViewer(
                    panEnabled: true,
                    minScale: 0.5,
                    maxScale: 3.0,
                    child: Center(
                      child: Image.memory(
                        base64Decode(post.imageBase64!),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),

                // Action buttons
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          isLikeda ? Icons.favorite : Icons.favorite_border,
                          color: isLikeda ? Colors.red : Colors.white,
                          size: 28,
                        ),
                        onPressed: () {
                          onToggleLike(post);
                          Navigator.pop(context);
                        },
                      ),
                      Text(
                        post.likes.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 16),
                      IconButton(
                        icon: const Icon(
                          Icons.comment_outlined,
                          color: Colors.white,
                          size: 28,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          onShowComments(post);
                        },
                      ),
                      Text(
                        post.commentCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
