import '../firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ActivityTracker {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Check post content and award points
  Future<void> checkPostForEcoActivities(String postContent) async {
    final user = _auth.currentUser;
    if (user == null) return;

    // Get all eco activities
    final snapshot = await _dbRef.child('ecoActivities').get();
    if (snapshot.exists) {
      final activities = snapshot.value as Map<dynamic, dynamic>;
      final awardedActivities = <String, int>{};

      // Check both personal and community activities
      for (final category in ['personal', 'community']) {
        if (activities[category] != null) {
          final categoryActivities =
              activities[category] as Map<dynamic, dynamic>;

          for (final activityKey in categoryActivities.keys) {
            final activity =
                categoryActivities[activityKey] as Map<dynamic, dynamic>;
            final keywords = activity['keywords'] as List<dynamic>;

            // Check if post contains any keywords
            if (_containsKeywords(postContent, keywords)) {
              awardedActivities[activityKey] = activity['points'] as int;
            }
          }
        }
      }

      // Award points for matched activities
      if (awardedActivities.isNotEmpty) {
        await _awardPoints(user.uid, awardedActivities);
      }
    }
  }

  bool _containsKeywords(String content, List<dynamic> keywords) {
    final lowerContent = content.toLowerCase();
    return keywords.any(
      (keyword) => lowerContent.contains(keyword.toString().toLowerCase()),
    );
  }

  Future<void> _awardPoints(String userId, Map<String, int> activities) async {
    final updates = <String, dynamic>{};
    final now = DateTime.now().toUtc().toIso8601String();
    int totalPointsToAdd = 0;

    // Get current points
    final userSnapshot = await _dbRef.child('userPoints/$userId').get();
    int currentTotal = 0;
    Map<dynamic, dynamic> currentActivities = {};

    if (userSnapshot.exists) {
      final userData = userSnapshot.value as Map<dynamic, dynamic>;
      currentTotal = userData['totalPoints'] as int? ?? 0;
      currentActivities =
          userData['activities'] as Map<dynamic, dynamic>? ?? {};
    }

    // Prepare updates
    activities.forEach((activityId, points) {
      totalPointsToAdd += points;

      if (currentActivities.containsKey(activityId)) {
        final activityData =
            currentActivities[activityId] as Map<dynamic, dynamic>;
        updates['userPoints/$userId/activities/$activityId/count'] =
            (activityData['count'] as int? ?? 0) + 1;
      } else {
        updates['userPoints/$userId/activities/$activityId'] = {
          'count': 1,
          'lastEarned': now,
        };
      }

      updates['userPoints/$userId/activities/$activityId/lastEarned'] = now;
    });

    updates['userPoints/$userId/totalPoints'] = currentTotal + totalPointsToAdd;

    // Apply updates
    await _dbRef.update(updates);
  }
}
