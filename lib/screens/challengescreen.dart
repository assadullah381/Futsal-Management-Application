import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

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

  // Use BehaviorSubject or ValueNotifier to share stream data
  late Stream<DatabaseEvent> _challengesStream;
  late Stream<DatabaseEvent> _completedChallengesStream;
  late StreamSubscription<DatabaseEvent> _challengesSubscription;
  late StreamSubscription<DatabaseEvent> _completedChallengesSubscription;

  // Store the latest snapshot values
  Map<dynamic, dynamic>? _challengesData;
  Map<dynamic, dynamic>? _completedChallengesData;

  @override
  void initState() {
    super.initState();
    // Create the stream once
    _challengesStream = _challengesRef.onValue;
    if (_currentUser != null) {
      _completedChallengesStream = _usersRef
          .child(_currentUser!.uid)
          .child('completedChallenges')
          .onValue;
    }

    // Listen to the streams and store the data
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
          title: const Text('Challenges'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.emoji_events), text: 'All Challenges'),
              Tab(icon: Icon(Icons.done_all), text: 'Completed'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // All Challenges Tab
            _buildAllChallengesTab(),
            // Completed Challenges Tab
            _buildCompletedChallengesTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildAllChallengesTab() {
    if (_challengesData == null) {
      return const Center(child: CircularProgressIndicator());
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
          child: InkWell(
            onTap: () => _showChallengeDetails(context, challenge, deadline),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.emoji_events, size: 24),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          data['title'] as String,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (data['image'] != null)
                    SizedBox(
                      height: 150,
                      width: double.infinity,
                      child: Image.memory(
                        base64Decode(data['image'] as String),
                        fit: BoxFit.cover,
                      ),
                    ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 16, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text('${data['rewardPoints']} points'),
                      const Spacer(),
                      const Icon(Icons.timer, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        _formatTimeRemaining(timeRemaining),
                        style: TextStyle(
                          color: timeRemaining.isNegative
                              ? Colors.red
                              : Colors.green,
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
      return const Center(
        child: Text('Please login to view completed challenges'),
      );
    }

    if (_completedChallengesData == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final completedIds = _completedChallengesData!.keys.toList();

    return FutureBuilder<Map<dynamic, dynamic>>(
      future: _getChallengesByIds(completedIds.cast<String>()),
      builder: (context, challengeSnapshot) {
        if (challengeSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!challengeSnapshot.hasData || challengeSnapshot.data!.isEmpty) {
          return const Center(child: Text('No completed challenges found'));
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
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data['title'] as String,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (data['image'] != null)
                      SizedBox(
                        height: 120,
                        width: double.infinity,
                        child: Image.memory(
                          base64Decode(data['image'] as String),
                          fit: BoxFit.cover,
                        ),
                      ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 16, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text('${data['rewardPoints']} points earned'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Completed on: ${DateFormat('yyyy-MM-dd – kk:mm').format(completionDate)}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
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
      builder: (context) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  data['title'] as String,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (data['image'] != null)
                SizedBox(
                  height: 200,
                  width: double.infinity,
                  child: Image.memory(
                    base64Decode(data['image'] as String),
                    fit: BoxFit.contain,
                  ),
                ),
              const SizedBox(height: 16),
              Text(
                data['description'] as String,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber),
                  const SizedBox(width: 8),
                  Text(
                    'Reward: ${data['rewardPoints']} points',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.calendar_today),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Deadline: ${DateFormat('yyyy-MM-dd').format(deadline)}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      Text(
                        timeRemaining.isNegative
                            ? 'Challenge expired'
                            : 'Time remaining: ${_formatTimeRemaining(timeRemaining)}',
                        style: TextStyle(
                          color: timeRemaining.isNegative
                              ? Colors.red
                              : Colors.green,
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
                    onPressed: () => _completeChallenge(challengeId),
                    child: const Text('Complete Challenge'),
                  ),
                ),
              if (isCompleted)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    child: const Text('Already Completed'),
                  ),
                ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

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
}
