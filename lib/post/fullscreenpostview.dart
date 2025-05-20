import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:manganuhu/models/post_model.dart';

class FullScreenPostView extends StatelessWidget {
  final Post post;
  final VoidCallback onClose;

  const FullScreenPostView({
    super.key,
    required this.post,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 50), // Space for close button
                // User info
                Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: post.userAvatarUrl != null
                          ? NetworkImage(post.userAvatarUrl!)
                          : null,
                      child: post.userAvatarUrl == null
                          ? const Icon(Icons.person)
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.userName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          DateFormat(
                            'MMM d, y • h:mm a',
                          ).format(post.timestamp),
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Post content
                if (post.subject.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      post.subject,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                Text(
                  post.content,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
                const SizedBox(height: 16),
                // Image (if exists)
                if (post.imageBase64 != null)
                  Center(
                    child: InteractiveViewer(
                      panEnabled: true,
                      minScale: 0.5,
                      maxScale: 3.0,
                      child: Image.memory(
                        base64Decode(post.imageBase64!),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Close button
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            right: 16,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 30),
              onPressed: onClose,
            ),
          ),
        ],
      ),
    );
  }
}
