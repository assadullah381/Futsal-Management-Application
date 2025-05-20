import 'dart:io';

import 'package:flutter/material.dart';

class FullScreenImageView extends StatelessWidget {
  final dynamic imageFile; // Can be File or MemoryImage
  final VoidCallback onClose;

  const FullScreenImageView({
    super.key,
    required this.imageFile,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: InteractiveViewer(
              panEnabled: true,
              minScale: 0.5,
              maxScale: 3.0,
              child: imageFile is File
                  ? Image.file(imageFile)
                  : Image(image: imageFile),
            ),
          ),
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
