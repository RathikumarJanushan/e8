import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:e8/auth/auth_service.dart';
import 'package:e8/auth/login_view.dart';
import 'package:e8/common/color_extension.dart';
import 'package:e8/common_widget/round_button.dart';
import 'package:e8/common_widget/round_textfield.dart';
import 'package:e8/view/main_tabview/main_tabview.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _auth = AuthService();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    if (_name.text.isEmpty || _email.text.isEmpty || _password.text.isEmpty) {
      _showErrorDialog("Please fill in all fields.");
      return;
    }

    try {
      final user = await _auth.createUserWithEmailAndPassword(
        _email.text.trim(),
        _password.text.trim(),
      );

      if (user != null) {
        log("User Created Successfully");
        await _saveUserDetails(user.uid, _name.text.trim(), _email.text.trim());
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainTabView()),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        _showErrorDialog(
          "This email is already in use. Please use a different email.",
        );
      } else {
        _showErrorDialog("Signup failed. Please try again.");
      }
    } catch (e) {
      _showErrorDialog("Signup failed. Please try again.");
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Error"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveUserDetails(
      String userId, String name, String email) async {
    try {
      await FirebaseFirestore.instance
          .collection('usersdetails')
          .doc(userId)
          .set({
        'name': name,
        'email': email,
        'userId': userId,
      });
      log("Saving user details - UserID: $userId, Name: $name, Email: $email");
    } catch (e) {
      _showErrorDialog("Failed to save user details. Please try again.");
    }
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        height: media.height,
        width: media.width,
        color:
            const Color.fromARGB(255, 36, 36, 36), // Set dark background color
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 64),
                Text(
                  "Signup",
                  style: TextStyle(
                      color: TColor.primaryText,
                      fontSize: 30,
                      fontWeight: FontWeight.w800),
                ),
                Text(
                  "Add your details to create an account",
                  style: TextStyle(
                      color: TColor.secondaryText,
                      fontSize: 14,
                      fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 25),
                RoundTextfield(
                  hintText: "Your Name",
                  controller: _name,
                  keyboardType: TextInputType.text,
                ),
                const SizedBox(height: 25),
                RoundTextfield(
                  hintText: "Your Email",
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 25),
                RoundTextfield(
                  hintText: "Password",
                  controller: _password,
                  obscureText: true,
                ),
                const SizedBox(height: 25),
                RoundButton(
                  title: "Signup",
                  onPressed: _signup,
                ),
                const SizedBox(height: 25),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginView()),
                    );
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Already have an Account? ",
                        style: TextStyle(
                            color: TColor.secondaryText,
                            fontSize: 14,
                            fontWeight: FontWeight.w500),
                      ),
                      Text(
                        "Login",
                        style: TextStyle(
                            color: TColor.primary,
                            fontSize: 14,
                            fontWeight: FontWeight.w700),
                      ),
                    ],
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
