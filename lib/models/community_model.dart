class Community {
  final String id;
  final String name;
  final String description;
  final String adminId;
  final List<String> members;
  final DateTime createdAt;
  bool allowAllMembersToPost;

  Community({
    required this.id,
    required this.name,
    required this.description,
    required this.adminId,
    required this.members,
    required this.createdAt,
    this.allowAllMembersToPost = true,
  });

  factory Community.fromMap(Map<dynamic, dynamic> map, String id) {
    return Community(
      id: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      adminId: map['adminId'] ?? '',
      members: List<String>.from(map['members'] ?? []),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      allowAllMembersToPost: map['allowAllMembersToPost'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'adminId': adminId,
      'members': members,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'allowAllMembersToPost': allowAllMembersToPost,
    };
  }
}

class CommunityMessage {
  final String id;
  final String communityId;
  final String senderId;
  final String senderName;
  final String content;
  final DateTime timestamp;

  CommunityMessage({
    required this.id,
    required this.communityId,
    required this.senderId,
    required this.senderName,
    required this.content,
    required this.timestamp,
  });

  factory CommunityMessage.fromMap(Map<dynamic, dynamic> map, String id) {
    return CommunityMessage(
      id: id,
      communityId: map['communityId'] ?? '',
      senderId: map['senderId'] ?? '',
      senderName: map['senderName'] ?? '',
      content: map['content'] ?? '',
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] ?? 0),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'communityId': communityId,
      'senderId': senderId,
      'senderName': senderName,
      'content': content,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }
}
