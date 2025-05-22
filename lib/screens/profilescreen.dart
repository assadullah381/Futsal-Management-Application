import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:manganuhu/authentication/login.dart';
import 'package:flutter/services.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Color palette
  static const Color darkForestGreen = Color(0xFF0A2810);
  static const Color pineGreen = Color(0xFF1A3F1A);
  static const Color fernGreen = Color(0xFF3A5F3A);
  static const Color leafGreen = Color(0xFF4C8C4C);
  static const Color mintGreen = Color(0xFF8FC18F);
  static const Color lightMint = Color(0xFFC1E1C1);

  late User? user;
  int pointsEarned = 0;
  String referralCode = 'Loading...';
  String referredBy = 'None';
  String referrerName = 'Loading...';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    if (user == null) return;

    try {
      final userRef = FirebaseDatabase.instance.ref('users').child(user!.uid);
      final snapshot = await userRef.get();

      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;

        setState(() {
          pointsEarned = (data['pointsEarned'] as num?)?.toInt() ?? 0;
          referralCode = data['referralCode']?.toString() ?? 'Not available';

          if (data['referredBy'] != null) {
            referredBy = data['referredBy'].toString();
            _fetchReferrerName(data['referredBy'].toString());
          } else {
            referredBy = 'None';
            referrerName = 'Not applicable';
          }

          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
      debugPrint('Error fetching user data: $e');
    }
  }

  Future<void> _fetchReferrerName(String referrerId) async {
    try {
      final snapshot = await FirebaseDatabase.instance
          .ref('users')
          .child(referrerId)
          .child('name')
          .get();

      if (snapshot.exists) {
        setState(() {
          referrerName = snapshot.value.toString();
        });
      } else {
        setState(() {
          referrerName = 'Unknown user';
        });
      }
    } catch (e) {
      debugPrint('Error fetching referrer name: $e');
      setState(() {
        referrerName = 'Error loading name';
      });
    }
  }

  Future<void> _copyToClipboard(String text, BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Copied to clipboard'),
        backgroundColor: leafGreen,
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    final shouldLogout = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        backgroundColor: lightMint,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: darkForestGreen),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'Log Out',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      await FirebaseAuth.instance.signOut();
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final String displayName = user?.displayName ?? 'No Name';
    final String email = user?.email ?? 'No Email';

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile', style: TextStyle(color: Colors.white)),
        backgroundColor: darkForestGreen,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            CircleAvatar(
              radius: 60,
              backgroundColor: pineGreen,
              backgroundImage:
                  user?.photoURL != null ? NetworkImage(user!.photoURL!) : null,
              child: user?.photoURL == null
                  ? const Icon(Icons.person, size: 60, color: Colors.white)
                  : null,
            ),
            const SizedBox(height: 20),
            Text(
              displayName,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: darkForestGreen,
                  ),
            ),
            const SizedBox(height: 5),
            Text(
              email,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: fernGreen),
            ),
            const SizedBox(height: 10),
            // Points display
            isLoading
                ? const CircularProgressIndicator(color: leafGreen)
                : Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: lightMint,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: mintGreen),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.star, color: leafGreen),
                            const SizedBox(width: 8),
                            Text(
                              '$pointsEarned points',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: darkForestGreen,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Referral code display
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: lightMint,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: mintGreen),
                        ),
                        child: InkWell(
                          onTap: () => _copyToClipboard(referralCode, context),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.share, color: leafGreen),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Your referral code',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: fernGreen,
                                    ),
                                  ),
                                  Text(
                                    referralCode,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: darkForestGreen,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
            const SizedBox(height: 30),
            _buildProfileSection(context, 'Referral Information', [
              _buildProfileItem(
                context,
                'Your Referral Code',
                referralCode,
                isAction: true,
                icon: Icons.content_copy,
                onTap: () => _copyToClipboard(referralCode, context),
              ),
              _buildProfileItem(
                context,
                'Referred By',
                referredBy == 'None' ? 'No one' : referrerName,
                subtitle: referredBy == 'None' ? null : 'User ID: $referredBy',
              ),
            ]),
            const SizedBox(height: 20),
            _buildProfileSection(context, 'Personal Information', [
              _buildProfileItem(context, 'Full Name', displayName),
              _buildProfileItem(context, 'Email', email),
              _buildProfileItem(
                context,
                'Phone',
                user?.phoneNumber ?? 'Not provided',
              ),
              _buildProfileItem(
                context,
                'Email Verified',
                user?.emailVerified ?? false ? 'Verified' : 'Not verified',
              ),
            ]),
            const SizedBox(height: 20),
            _buildProfileSection(context, 'Account Settings', [
              _buildProfileItem(context, 'Change Password', '', isAction: true),
              _buildProfileItem(
                context,
                'Privacy Settings',
                '',
                isAction: true,
              ),
              _buildProfileItem(
                context,
                'Notification Preferences',
                '',
                isAction: true,
              ),
            ]),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: lightMint,
                  foregroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: const BorderSide(color: Colors.red),
                  ),
                ),
                onPressed: () => _logout(context),
                child: const Text('Log Out'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection(
    BuildContext context,
    String title,
    List<Widget> children,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: darkForestGreen,
              ),
        ),
        const SizedBox(height: 10),
        Card(
          elevation: 2,
          color: lightMint,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(color: mintGreen),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(children: children),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileItem(
    BuildContext context,
    String title,
    String value, {
    String? subtitle,
    bool isAction = false,
    IconData? icon,
    VoidCallback? onTap,
  }) {
    return ListTile(
      title: Text(title, style: TextStyle(color: darkForestGreen)),
      subtitle: subtitle != null
          ? Text(subtitle, style: TextStyle(color: fernGreen))
          : null,
      trailing: isAction
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) Icon(icon, color: leafGreen, size: 20),
                const SizedBox(width: 4),
                Icon(Icons.chevron_right, color: leafGreen),
              ],
            )
          : Text(value, style: TextStyle(color: pineGreen)),
      onTap: isAction ? onTap : null,
    );
  }
}
