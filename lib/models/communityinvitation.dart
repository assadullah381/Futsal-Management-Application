class CommunityInvitation {
  final String id;
  final String communityId;
  final String communityName;
  final String senderId;
  final String senderName;
  final String receiverEmail; // Or receiverId if you prefer
  final String receiverId;
  final DateTime sentAt;
  final String status; // 'pending', 'accepted', 'rejected'

  CommunityInvitation({
    required this.id,
    required this.communityId,
    required this.communityName,
    required this.senderId,
    required this.senderName,
    required this.receiverEmail,
    required this.receiverId,
    required this.sentAt,
    this.status = 'pending',
  });

  factory CommunityInvitation.fromMap(Map<dynamic, dynamic> map, String id) {
    return CommunityInvitation(
      id: id,
      communityId: map['communityId'] ?? '',
      communityName: map['communityName'] ?? '',
      senderId: map['senderId'] ?? '',
      senderName: map['senderName'] ?? '',
      receiverEmail: map['receiverEmail'] ?? '',
      receiverId: map['receiverId'] ?? '',
      sentAt: DateTime.fromMillisecondsSinceEpoch(map['sentAt'] ?? 0),
      status: map['status'] ?? 'pending',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'communityId': communityId,
      'communityName': communityName,
      'senderId': senderId,
      'senderName': senderName,
      'receiverEmail': receiverEmail,
      'receiverId': receiverId,
      'sentAt': sentAt.millisecondsSinceEpoch,
      'status': status,
    };
  }
}
