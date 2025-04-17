import 'package:flutter/material.dart';
import 'comment_screen.dart';

class PostWidget extends StatefulWidget {
  final String username;
  final String imageUrl;
  final int likes;
  final int comments;

  const PostWidget({
    required this.username,
    required this.imageUrl,
    required this.likes,
    required this.comments,
    Key? key,
  }) : super(key: key);

  @override
  _PostWidgetState createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget> {
  bool isLiked = false;
  late int likeCount;

  @override
  void initState() {
    super.initState();
    likeCount = widget.likes;
  }

  void toggleLike() {
    setState(() {
      isLiked = !isLiked;
      likeCount += isLiked ? 1 : -1;
    });
  }

  void openCommentScreen(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => CommentScreen(username: widget.username),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFF61D384), // Dark background for the post
        borderRadius: BorderRadius.circular(12), // Rounded corners
        border: Border.all(width: 2), // Dark green border
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: const Color(0xFFC3F44D),
              child: Text(widget.username[0],
                  style: const TextStyle(color: Colors.black)),
            ),
            title: Text(widget.username,
                style: const TextStyle(color: Color(0xFF1A434E))),
          ),
          ClipRRect(
            borderRadius:
                BorderRadius.circular(12), // Rounded corners for the image
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(width: 2), // Black border for the image
                borderRadius: BorderRadius.circular(12), // Rounded corners
              ),
              child: Image.asset(
                widget.imageUrl,
                fit: BoxFit.cover,
                width: double.infinity, // Adjust width as needed
                height: 350, // Adjust height as needed
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                // Like Button
                IconButton(
                  icon: Icon(
                    isLiked ? Icons.favorite : Icons.favorite_border,
                    color: isLiked ? Colors.red : Colors.white,
                  ),
                  onPressed: toggleLike,
                ),
                Text('$likeCount likes',
                    style: const TextStyle(color: Colors.white)),

                const SizedBox(width: 16),

                // Comment Button
                IconButton(
                  icon: Icon(Icons.comment, color: Color(0xFF1A434E)),
                  onPressed: () => openCommentScreen(context), // Now it works!
                ),
                Text('${widget.comments} comments',
                    style: const TextStyle(color: Colors.white)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
