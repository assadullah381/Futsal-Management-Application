import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:manganuhu/models/CommunityInvitation.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final DatabaseReference _invitationsRef = FirebaseDatabase.instance.ref(
    'invitations',
  );
  final DatabaseReference _communitiesRef = FirebaseDatabase.instance.ref(
    'communities',
  );
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  List<CommunityInvitation> _invitations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInvitations();
  }

  void _loadInvitations() {
    _invitationsRef
        .orderByChild('receiverEmail')
        .equalTo(_currentUser?.email)
        .onValue
        .listen((event) {
      if (event.snapshot.value != null) {
        final data = event.snapshot.value as Map<dynamic, dynamic>;
        final List<CommunityInvitation> loadedInvitations = [];

        data.forEach((key, value) {
          final invitation = CommunityInvitation.fromMap(value, key);
          if (invitation.status == 'pending') {
            loadedInvitations.add(invitation);
          }
        });

        setState(() {
          _invitations = loadedInvitations;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  Future<void> _respondToInvitation(
    CommunityInvitation invitation,
    bool accept,
  ) async {
    try {
      // Update invitation status
      await _invitationsRef.child(invitation.id).update({
        'status': accept ? 'accepted' : 'rejected',
      });

      if (accept) {
        // Add user to community members
        final communityRef = _communitiesRef.child(invitation.communityId);
        final communitySnapshot = await communityRef.get();

        if (communitySnapshot.exists) {
          final members = List<String>.from(
            communitySnapshot.child('members').value as List? ?? [],
          );
          if (!members.contains(_currentUser?.uid)) {
            members.add(_currentUser?.uid ?? '');
            await communityRef.update({'members': members});
          }
        }
      }

      setState(() {
        _invitations.removeWhere((inv) => inv.id == invitation.id);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            accept
                ? 'Joined ${invitation.communityName}'
                : 'Invitation declined',
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to process invitation: ${e.toString()}'),
        ),
      );
    }
  }

  Future<void> _handleBulkAccept() async {
    try {
      //final batch = FirebaseDatabase.instance.ref().push();
      final Map<String, Object?> updates = {};
      final Map<String, Object?> communityUpdates = {};

      // Group invitations by community
      final communities = <String, List<String>>{};
      for (final invitation in _invitations) {
        communities
            .putIfAbsent(invitation.communityId, () => [])
            .add(invitation.id);
      }

      // Prepare updates
      for (final entry in communities.entries) {
        final communityId = entry.key;
        final invitationIds = entry.value;

        // Update invitation statuses
        for (final id in invitationIds) {
          updates['invitations/$id/status'] = 'accepted';
        }

        // Add user to community
        communityUpdates[
            'communities/$communityId/members/${_currentUser?.uid}'] = true;
      }

      // Execute batch update
      await FirebaseDatabase.instance.ref().update(updates);
      await FirebaseDatabase.instance.ref().update(communityUpdates);

      setState(() {
        _invitations.clear();
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Accepted all invitations')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to accept all: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Community Invitations'),
        actions: [
          if (_invitations.isNotEmpty)
            TextButton(
              onPressed: _handleBulkAccept,
              child: const Text(
                'Accept All',
                style: TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _invitations.isEmpty
              ? const Center(
                  child: Text(
                    'No pending invitations',
                    style: TextStyle(fontSize: 16),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () async {
                    setState(() {
                      _isLoading = true;
                      _invitations.clear();
                    });
                    _loadInvitations();
                  },
                  child: ListView.builder(
                    itemCount: _invitations.length,
                    itemBuilder: (context, index) {
                      final invitation = _invitations[index];
                      return Dismissible(
                        key: Key(invitation.id),
                        background: Container(color: Colors.green),
                        secondaryBackground: Container(color: Colors.red),
                        confirmDismiss: (direction) async {
                          if (direction == DismissDirection.startToEnd) {
                            await _respondToInvitation(invitation, true);
                            return false;
                          } else {
                            await _respondToInvitation(invitation, false);
                            return false;
                          }
                        },
                        child: Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: ListTile(
                            title: Text(
                              'Invitation to ${invitation.communityName}',
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('From: ${invitation.senderName}'),
                                Text(
                                  DateFormat(
                                    'MMM dd, yyyy - hh:mm a',
                                  ).format(invitation.sentAt),
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.check,
                                    color: Colors.green,
                                  ),
                                  onPressed: () =>
                                      _respondToInvitation(invitation, true),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.close,
                                    color: Colors.red,
                                  ),
                                  onPressed: () =>
                                      _respondToInvitation(invitation, false),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
