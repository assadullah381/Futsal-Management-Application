import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

// Reuse the same green color palette
const Color darkForestGreen = Color(0xFF0A2810);
const Color pineGreen = Color(0xFF1A3F1A);
const Color fernGreen = Color(0xFF3A5F3A);
const Color leafGreen = Color(0xFF4C8C4C);
const Color mintGreen = Color(0xFF8FC18F);
const Color lightMint = Color(0xFFC1E1C1);

class ChallengesScreen extends StatefulWidget {
  const ChallengesScreen({super.key});

  @override
  State<ChallengesScreen> createState() => _ChallengesScreenState();
}

class _ChallengesScreenState extends State<ChallengesScreen> {
  final DatabaseReference _challengesRef = FirebaseDatabase.instance.ref(
    'challenges',
  );
  final DatabaseReference _usersRef = FirebaseDatabase.instance.ref('users');
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  late Stream<DatabaseEvent> _challengesStream;
  late Stream<DatabaseEvent> _completedChallengesStream;
  late StreamSubscription<DatabaseEvent> _challengesSubscription;
  late StreamSubscription<DatabaseEvent> _completedChallengesSubscription;

  Map<dynamic, dynamic>? _challengesData;
  Map<dynamic, dynamic>? _completedChallengesData;

  @override
  void initState() {
    super.initState();
    _challengesStream = _challengesRef.onValue;
    if (_currentUser != null) {
      _completedChallengesStream = _usersRef
          .child(_currentUser!.uid)
          .child('completedChallenges')
          .onValue;
    }

    _challengesSubscription = _challengesStream.listen((event) {
      if (event.snapshot.value != null) {
        setState(() {
          _challengesData = event.snapshot.value as Map<dynamic, dynamic>;
        });
      }
    });

    if (_currentUser != null) {
      _completedChallengesSubscription = _completedChallengesStream.listen((
        event,
      ) {
        if (event.snapshot.value != null) {
          setState(() {
            _completedChallengesData =
                event.snapshot.value as Map<dynamic, dynamic>;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _challengesSubscription.cancel();
    if (_currentUser != null) {
      _completedChallengesSubscription.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Challenges',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: pineGreen,
          iconTheme: const IconThemeData(color: Colors.white),
          bottom: TabBar(
            indicatorColor: leafGreen,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: const [
              Tab(icon: Icon(Icons.emoji_events), text: 'All Challenges'),
              Tab(icon: Icon(Icons.done_all), text: 'Completed'),
            ],
          ),
        ),
        backgroundColor: lightMint.withOpacity(0.1),
        body: TabBarView(
          children: [_buildAllChallengesTab(), _buildCompletedChallengesTab()],
        ),
      ),
    );
  }

  Widget _buildAllChallengesTab() {
    if (_challengesData == null) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(leafGreen),
        ),
      );
    }

    final challenges = _challengesData!.entries.toList();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: challenges.length,
      itemBuilder: (context, index) {
        final challenge = challenges[index];
        final data = challenge.value as Map<dynamic, dynamic>;
        final deadline = DateTime.fromMillisecondsSinceEpoch(
          data['deadline'] as int,
        );
        final timeRemaining = deadline.difference(DateTime.now());

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            onTap: () => _showChallengeDetails(context, challenge, deadline),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.emoji_events, size: 24, color: leafGreen),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          data['title'] as String,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: darkForestGreen,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (data['image'] != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: SizedBox(
                        height: 150,
                        width: double.infinity,
                        child: Image.memory(
                          base64Decode(data['image'] as String),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.star, size: 16, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        '${data['rewardPoints']} points',
                        style: TextStyle(color: fernGreen),
                      ),
                      const Spacer(),
                      Icon(Icons.timer, size: 16, color: fernGreen),
                      const SizedBox(width: 4),
                      Text(
                        _formatTimeRemaining(timeRemaining),
                        style: TextStyle(
                          color:
                              timeRemaining.isNegative ? Colors.red : leafGreen,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCompletedChallengesTab() {
    if (_currentUser == null) {
      return Center(
        child: Text(
          'Please login to view completed challenges',
          style: TextStyle(color: fernGreen),
        ),
      );
    }

    if (_completedChallengesData == null) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(leafGreen),
        ),
      );
    }

    final completedIds = _completedChallengesData!.keys.toList();

    return FutureBuilder<Map<dynamic, dynamic>>(
      future: _getChallengesByIds(completedIds.cast<String>()),
      builder: (context, challengeSnapshot) {
        if (challengeSnapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(leafGreen),
            ),
          );
        }

        if (!challengeSnapshot.hasData || challengeSnapshot.data!.isEmpty) {
          return Center(
            child: Text(
              'No completed challenges found',
              style: TextStyle(color: fernGreen),
            ),
          );
        }

        final challenges = challengeSnapshot.data!;

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: challenges.length,
          itemBuilder: (context, index) {
            final challengeId = challenges.keys.elementAt(index);
            final data = challenges[challengeId] as Map<dynamic, dynamic>;
            final completionDate = DateTime.fromMillisecondsSinceEpoch(
              _completedChallengesData![challengeId] as int,
            );

            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data['title'] as String,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: darkForestGreen,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (data['image'] != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: SizedBox(
                          height: 120,
                          width: double.infinity,
                          child: Image.memory(
                            base64Decode(data['image'] as String),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.star, size: 16, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(
                          '${data['rewardPoints']} points earned',
                          style: TextStyle(color: fernGreen),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Completed on: ${DateFormat('yyyy-MM-dd – kk:mm').format(completionDate)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: fernGreen.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ... [Keep all your existing methods unchanged until _showChallengeDetails]

  void _showChallengeDetails(
    BuildContext context,
    MapEntry<dynamic, dynamic> challenge,
    DateTime deadline,
  ) {
    final timeRemaining = deadline.difference(DateTime.now());
    final challengeId = challenge.key.toString();
    final data = challenge.value as Map<dynamic, dynamic>;
    final isCompleted =
        _completedChallengesData?.containsKey(challengeId) ?? false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 5,
              ),
            ],
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    data['title'] as String,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: darkForestGreen,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (data['image'] != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      height: 200,
                      width: double.infinity,
                      child: Image.memory(
                        base64Decode(data['image'] as String),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                Text(
                  data['description'] as String,
                  style: TextStyle(color: fernGreen),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.amber),
                    const SizedBox(width: 8),
                    Text(
                      'Reward: ${data['rewardPoints']} points',
                      style: TextStyle(color: fernGreen),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.calendar_today, color: fernGreen),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Deadline: ${DateFormat('yyyy-MM-dd').format(deadline)}',
                          style: TextStyle(color: fernGreen),
                        ),
                        Text(
                          timeRemaining.isNegative
                              ? 'Challenge expired'
                              : 'Time remaining: ${_formatTimeRemaining(timeRemaining)}',
                          style: TextStyle(
                            color: timeRemaining.isNegative
                                ? Colors.red
                                : leafGreen,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                if (!timeRemaining.isNegative && !isCompleted)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: leafGreen,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () => _completeChallenge(challengeId),
                      child: const Text(
                        'Complete Challenge',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                if (isCompleted)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: mintGreen,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        'Already Completed',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatTimeRemaining(Duration duration) {
    if (duration.isNegative) {
      return 'Expired';
    }

    if (duration.inDays > 0) {
      return '${duration.inDays}d ${duration.inHours.remainder(24)}h left';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes.remainder(60)}m left';
    } else {
      return '${duration.inMinutes}m left';
    }
  }

  // ... [Keep all remaining methods unchanged]

  Future<void> _completeChallenge(String challengeId) async {
    if (_currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to complete challenges')),
      );
      return;
    }

    try {
      await _usersRef
          .child(_currentUser!.uid)
          .child('completedChallenges')
          .update({challengeId: DateTime.now().millisecondsSinceEpoch});

      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Challenge completed! Points awarded')),
      );
      _updateUserPoints(
        _currentUser!.uid,
        (_challengesData![challengeId]['rewardPoints'] as int?) ?? 0,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to complete challenge: ${e.toString()}'),
        ),
      );
    }
  }

  Future<void> _updateUserPoints(String userId, int points) async {
    if (points <= 0) return;

    try {
      await _usersRef.child(userId).child('pointsEarned').runTransaction((
        mutableData,
      ) {
        final currentPoints = (mutableData as num?)?.toInt() ?? 0;
        return Transaction.success(currentPoints + points);
      });
    } catch (e) {
      debugPrint('Error updating points: $e');
      rethrow;
    }
  }

  Future<Map<dynamic, dynamic>> _getChallengesByIds(List<String> ids) async {
    final Map<dynamic, dynamic> challenges = {};
    for (final id in ids) {
      final snapshot = await _challengesRef.child(id).get();
      if (snapshot.exists) {
        challenges[id] = snapshot.value;
      }
    }
    return challenges;
  }
}
