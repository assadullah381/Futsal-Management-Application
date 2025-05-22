import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:manganuhu/screens/homepage.dart';
import 'package:manganuhu/authentication/login.dart';

class RegisterScreen extends StatefulWidget {
  final String? referralCode;
  const RegisterScreen({Key? key, this.referralCode}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final DatabaseReference _usersRef = FirebaseDatabase.instance.ref('users');
  final DatabaseReference _referralCodesRef = FirebaseDatabase.instance.ref(
    'referralCodes',
  );
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController referralCodeController = TextEditingController();
  bool isPasswordHidden = true;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill referral code if provided in constructor
    if (widget.referralCode != null) {
      referralCodeController.text = widget.referralCode!;
    }
  }

  void togglePasswordView() {
    setState(() {
      isPasswordHidden = !isPasswordHidden;
    });
  }

  Future<String> _generateUniqueReferralCode() async {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    String code;
    bool codeExists;

    do {
      code = '';
      for (var i = 0; i < 6; i++) {
        code += chars[random.nextInt(chars.length)];
      }

      final snapshot = await _referralCodesRef.child(code).once();
      codeExists = snapshot.snapshot.exists;
    } while (codeExists);

    return code;
  }

  Future<void> registerUser() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final referralCode = referralCodeController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all required fields")),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // Register the user with Firebase Authentication
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      User? firebaseUser = userCredential.user;

      if (firebaseUser != null) {
        await firebaseUser.updateDisplayName(name);

        // Generate a unique referral code for the new user
        final userReferralCode = await _generateUniqueReferralCode();

        // Determine which referral code to use (precedence to manually entered one)
        final usedReferralCode =
            referralCode.isNotEmpty ? referralCode : widget.referralCode;

        // Store user data
        await _usersRef.child(firebaseUser.uid).set({
          'uid': firebaseUser.uid,
          'name': name,
          'email': email,
          'createdAt': ServerValue.timestamp,
          'emailVerified': false,
          'profileImage': '',
          'bio': '',
          'pointsEarned': 0,
          'referralCode': userReferralCode,
          'referralCodeUsed': usedReferralCode,
        });

        // Store the referral code mapping
        await _referralCodesRef.child(userReferralCode).set({
          'userId': firebaseUser.uid,
          'createdAt': ServerValue.timestamp,
        });

        // If a referral code was provided, handle the referral
        if (usedReferralCode != null && usedReferralCode.isNotEmpty) {
          await _handleReferralCodeUsage(usedReferralCode, firebaseUser.uid);
        }

        // Send email verification
        await firebaseUser.sendEmailVerification();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Verification email sent! Please verify your email."),
            duration: Duration(seconds: 5),
          ),
        );

        _checkEmailVerification(firebaseUser);
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        isLoading = false;
      });

      String errorMessage = "Registration failed";
      if (e.code == 'email-already-in-use') {
        errorMessage = "This email is already in use.";
      } else if (e.code == 'weak-password') {
        errorMessage = "The password is too weak.";
      } else if (e.code == 'invalid-email') {
        errorMessage = "The email address is invalid.";
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errorMessage)));
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Something went wrong: ${e.toString()}")),
      );
    }
  }

  Future<void> _handleReferralCodeUsage(
    String referralCode,
    String newUserId,
  ) async {
    try {
      // Get the referral code info
      final codeSnapshot = await _referralCodesRef.child(referralCode).once();
      if (codeSnapshot.snapshot.exists) {
        final referrerUserId =
            codeSnapshot.snapshot.child('userId').value as String?;

        if (referrerUserId != null) {
          // Get referrer's data
          final referrerSnapshot = await _usersRef.child(referrerUserId).once();
          if (referrerSnapshot.snapshot.exists) {
            // Update referrer's points (add 10 points as an example)
            int currentPoints =
                referrerSnapshot.snapshot.child('pointsEarned').value as int? ??
                    0;
            await _usersRef.child(referrerUserId).update({
              'pointsEarned': currentPoints + 10,
            });

            // Record the referral in the referrer's data
            await _usersRef
                .child(referrerUserId)
                .child('referrals')
                .push()
                .set({
              'referredUserId': newUserId,
              'timestamp': ServerValue.timestamp,
              'pointsAwarded': 10,
            });

            // Record the referral in the new user's data
            await _usersRef.child(newUserId).update({
              'referredBy': referrerUserId,
              'referralPointsUsed': 10, // Points given to new user
            });
          }
        }
      }
    } catch (e) {
      debugPrint("Error handling referral code: $e");
    }
  }

  void _checkEmailVerification(User user) async {
    // Reload user to get fresh verification status
    await user.reload();
    user = FirebaseAuth.instance.currentUser!;

    if (user.emailVerified) {
      // Update verification status in database
      await _usersRef.child(user.uid).update({
        'emailVerified': true,
        'verifiedAt': ServerValue.timestamp,
      });

      // Email is verified, navigate to home screen
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } else {
      // Email not verified yet, check again after delay
      await Future.delayed(const Duration(seconds: 5));
      _checkEmailVerification(user);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const Text(
                  'Create Account',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A237E),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Sign up to get started',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 40),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: const Icon(Icons.person),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: passwordController,
                  obscureText: isPasswordHidden,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        isPasswordHidden
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: togglePasswordView,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: referralCodeController,
                  decoration: InputDecoration(
                    labelText: 'Referral Code (optional)',
                    prefixIcon: const Icon(Icons.card_giftcard),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    hintText: 'Enter a friend\'s referral code',
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: isLoading ? null : registerUser,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 22, 102, 32),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Register',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                ),
                const SizedBox(height: 20),
                const Text("Already have an account?"),
                TextButton(
                  onPressed: isLoading
                      ? null
                      : () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginScreen(),
                            ),
                          );
                        },
                  child: const Text(
                    'Login',
                    style: TextStyle(color: Color.fromARGB(255, 22, 102, 32)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
