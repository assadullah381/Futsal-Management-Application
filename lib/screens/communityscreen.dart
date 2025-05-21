import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:manganuhu/models/community_model.dart';
import 'package:manganuhu/screens/challengesscreen.dart';
import 'package:manganuhu/screens/homepage.dart';
import 'package:manganuhu/screens/newsscreen.dart';
import 'package:manganuhu/screens/storescreen.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  final DatabaseReference _communitiesRef = FirebaseDatabase.instance.ref(
    'communities',
  );
  final User? _currentUser = FirebaseAuth.instance.currentUser;
  final TextEditingController _communityNameController =
      TextEditingController();
  final TextEditingController _communityDescController =
      TextEditingController();

  List<Community> _communities = [];
  int _currentIndex = 1;

  @override
  void initState() {
    super.initState();
    _loadCommunities();
  }

  void _loadCommunities() {
    _communitiesRef.onValue.listen((event) {
      if (event.snapshot.value != null) {
        final data = event.snapshot.value as Map<dynamic, dynamic>;
        final List<Community> loadedCommunities = [];

        data.forEach((key, value) {
          final community = Community.fromMap(value, key);
          if (community.members.contains(_currentUser?.uid)) {
            loadedCommunities.add(community);
          }
        });

        setState(() {
          _communities = loadedCommunities;
        });
      }
    });
  }

  Future<void> _createCommunity() async {
    if (_communityNameController.text.isEmpty) return;

    final newCommunityRef = _communitiesRef.push();
    final newCommunity = Community(
      id: newCommunityRef.key!,
      name: _communityNameController.text,
      description: _communityDescController.text,
      adminId: _currentUser?.uid ?? '',
      members: [_currentUser?.uid ?? ''],
      createdAt: DateTime.now(),
    );

    await newCommunityRef.set(newCommunity.toMap());
    _communityNameController.clear();
    _communityDescController.clear();
  }

  Future<void> _showCreateCommunityDialog() async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Create New Community'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _communityNameController,
                decoration: const InputDecoration(labelText: 'Community Name'),
              ),
              TextField(
                controller: _communityDescController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                _createCommunity();
                Navigator.pop(context);
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Communities'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showCreateCommunityDialog,
          ),
        ],
      ),
      body: _communities.isEmpty
          ? const Center(
              child: Text(
                'No communities yet. Create one or get invited!',
                style: TextStyle(fontSize: 16),
              ),
            )
          : ListView.builder(
              itemCount: _communities.length,
              itemBuilder: (context, index) {
                final community = _communities[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: ListTile(
                    title: Text(
                      community.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '${community.members.length} members • ${community.adminId == _currentUser?.uid ? 'Admin' : 'Member'}',
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              CommunityDetailScreen(community: community),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          } else if (index == 2) {
            // Marketplace tab index
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const NewsScreen()),
            );
          } else if (index == 3) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const ProductScreen()),
            );
          } else if (index == 4) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const ChallengesScreen()),
            );
          }
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF1A237E),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Community'),
          BottomNavigationBarItem(icon: Icon(Icons.newspaper), label: 'News'),
          BottomNavigationBarItem(
            icon: Icon(Icons.store),
            label: 'marketplace',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.emoji_events),
            label: 'Challenges',
          ),
        ],
      ),
    );
  }
}

class CommunityDetailScreen extends StatefulWidget {
  final Community community;

  const CommunityDetailScreen({super.key, required this.community});

  @override
  State<CommunityDetailScreen> createState() => _CommunityDetailScreenState();
}

class _CommunityDetailScreenState extends State<CommunityDetailScreen> {
  final DatabaseReference _communitiesRef = FirebaseDatabase.instance.ref(
    'communities',
  );
  final DatabaseReference _invitationsRef = FirebaseDatabase.instance.ref(
    'invitations',
  );
  final User? _currentUser = FirebaseAuth.instance.currentUser;
  final TextEditingController _messageController = TextEditingController();

  List<CommunityMessage> _messages = [];
  bool _isAdmin = false;
  List<String> _inviteEmails = [];
  final TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _isAdmin = widget.community.adminId == _currentUser?.uid;
    _loadMessages();
  }

  void _loadMessages() {
    _communitiesRef.child(widget.community.id).child('messages').onValue.listen(
      (event) {
        if (event.snapshot.value != null) {
          final data = event.snapshot.value as Map<dynamic, dynamic>;
          final List<CommunityMessage> loadedMessages = [];

          data.forEach((key, value) {
            loadedMessages.add(CommunityMessage.fromMap(value, key));
          });

          setState(() {
            _messages = loadedMessages;
            _messages.sort((a, b) => b.timestamp.compareTo(a.timestamp));
          });
        }
      },
    );
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.isEmpty) return;

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      final userName = currentUser?.displayName ?? 'User';

      final newMessageRef =
          _communitiesRef.child(widget.community.id).child('messages').push();

      final newMessage = CommunityMessage(
        id: newMessageRef.key!,
        communityId: widget.community.id,
        senderId: currentUser?.uid ?? '',
        senderName: userName,
        content: _messageController.text,
        timestamp: DateTime.now(),
      );

      await newMessageRef.set(newMessage.toMap());
      _messageController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send message: ${e.toString()}')),
      );
    }
  }

  Future<void> _sendInvitations() async {
    if (_inviteEmails.isEmpty) return;

    try {
      // Get current community members
      final communitySnapshot =
          await _communitiesRef.child(widget.community.id).get();
      final members = List<String>.from(
        communitySnapshot.child('members').value as List? ?? [],
      );

      // Get all users from database to check emails against UIDs
      final usersSnapshot = await FirebaseDatabase.instance.ref('users').get();
      final usersData = usersSnapshot.value as Map<dynamic, dynamic>? ?? {};

      final Map<String, Object?> updates = {};
      int successfulInvites = 0;
      List<String> invalidEmails = [];

      for (final email in _inviteEmails) {
        try {
          // Find user in database by email
          String? userId;
          usersData.forEach((key, value) {
            if (value['email']?.toString().toLowerCase() ==
                email.toLowerCase()) {
              userId = key;
            }
          });

          if (userId == null) {
            invalidEmails.add(email);
            continue; // User not found in database
          }

          if (members.contains(userId)) {
            invalidEmails.add(email);
            continue; // Skip users already in community
          }

          // Create invitation
          final newInvitationKey = _invitationsRef.push().key;
          updates['invitations/$newInvitationKey'] = {
            'communityId': widget.community.id,
            'communityName': widget.community.name,
            'senderId': _currentUser?.uid ?? '',
            'senderName': _currentUser?.displayName ?? 'Community Admin',
            'receiverEmail': email.trim(),
            'receiverId': userId,
            'sentAt': DateTime.now().millisecondsSinceEpoch,
            'status': 'pending',
          };
          successfulInvites++;
        } catch (e) {
          invalidEmails.add(email);
        }
      }

      if (updates.isNotEmpty) {
        await FirebaseDatabase.instance.ref().update(updates);
      }

      String message =
          'Sent $successfulInvites/${_inviteEmails.length} invitations';
      if (invalidEmails.isNotEmpty) {
        message += '\nInvalid emails: ${invalidEmails.join(', ')}';
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));

      setState(() {
        _inviteEmails.clear();
        _emailController.clear();
      });
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send invitations: ${e.toString()}')),
      );
    }
  }

  Future<void> _showInviteDialog() async {
    return showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Invite Members'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _emailController,
                            decoration: const InputDecoration(
                              labelText: 'Email Address',
                              hintText: 'user@example.com',
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () async {
                            if (_emailController.text.isNotEmpty) {
                              final email = _emailController.text.trim();

                              try {
                                // Query users in Realtime Database where email matches
                                final query = await FirebaseDatabase.instance
                                    .ref('users')
                                    .orderByChild('email')
                                    .equalTo(email)
                                    .once();

                                if (query.snapshot.value == null) {
                                  // No user found with this email
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('$email is not registered'),
                                    ),
                                  );
                                  return;
                                }

                                // Get the first user (should be only one since emails are unique)
                                final userData = (query.snapshot.value as Map)
                                    .values
                                    .first as Map;
                                final isVerified =
                                    userData['emailVerified'] ?? false;
                                final userId = userData['uid'] as String?;

                                if (!isVerified) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        '$email is not verified yet',
                                      ),
                                    ),
                                  );
                                  return;
                                }

                                if (userId == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Invalid user data for $email',
                                      ),
                                    ),
                                  );
                                  return;
                                }

                                if (_inviteEmails.contains(email)) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        '$email is already in invite list',
                                      ),
                                    ),
                                  );
                                  return;
                                }

                                // Check if user is already in community
                                final communitySnapshot = await _communitiesRef
                                    .child(widget.community.id)
                                    .get();
                                final members = List<String>.from(
                                  communitySnapshot.child('members').value
                                          as List? ??
                                      [],
                                );

                                if (members.contains(userId)) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        '$email is already in this community',
                                      ),
                                    ),
                                  );
                                  return;
                                }

                                // All checks passed - add to invite list
                                setState(() {
                                  _inviteEmails.add(email);
                                  _emailController.clear();
                                });
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Error checking user: ${e.toString()}',
                                    ),
                                  ),
                                );
                              }
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (_inviteEmails.isNotEmpty) ...[
                      const Text('Inviting:'),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 150,
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: _inviteEmails.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              title: Text(_inviteEmails[index]),
                              trailing: IconButton(
                                icon: const Icon(Icons.remove, size: 20),
                                onPressed: () {
                                  setState(() {
                                    _inviteEmails.removeAt(index);
                                  });
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: _inviteEmails.isEmpty ? null : _sendInvitations,
                  child: const Text('Send Invites'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _togglePostingPermission() async {
    await _communitiesRef.child(widget.community.id).update({
      'allowAllMembersToPost': !widget.community.allowAllMembersToPost,
    });
  }

  Future<void> _showSettingsDialog() async {
    return showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Community Settings'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      title: const Text('Allow all members to post'),
                      trailing: Switch(
                        value: widget.community.allowAllMembersToPost,
                        onChanged: (value) => _togglePostingPermission(),
                      ),
                    ),
                    const Divider(),
                    ElevatedButton(
                      onPressed: _showInviteDialog,
                      child: const Text('Invite Members'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.community.name),
        actions: [
          if (_isAdmin)
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: _showSettingsDialog,
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.community.description,
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                Text(
                  '${widget.community.members.length} members • ${_isAdmin ? 'You are admin' : 'Admin only'}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: _messages.isEmpty
                ? const Center(
                    child: Text('No messages yet. Start the conversation!'),
                  )
                : ListView.builder(
                    reverse: true,
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      return ListTile(
                        leading: CircleAvatar(
                          child: Text(
                            message.senderName.isNotEmpty
                                ? message.senderName[0].toUpperCase()
                                : 'U',
                          ),
                        ),
                        title: Text(message.senderName),
                        subtitle: Text(message.content),
                        trailing: Text(
                          DateFormat('h:mm a').format(message.timestamp),
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      );
                    },
                  ),
          ),
          if (widget.community.allowAllMembersToPost || _isAdmin)
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey.shade300)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
