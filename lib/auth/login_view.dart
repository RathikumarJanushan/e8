import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:e8/auth/reset.dart';
import 'package:e8/auth/signup_screen.dart';
import 'package:e8/common/color_extension.dart';
import 'package:e8/common_widget/round_button.dart';
import 'package:e8/common_widget/round_textfield.dart';
import 'package:e8/view/main_tabview/main_tabview.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  TextEditingController txtEmail = TextEditingController();
  TextEditingController txtPassword = TextEditingController();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCredentials();
  }

  Future<void> _loadCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    txtEmail.text = prefs.getString('saved_email') ?? '';
    txtPassword.text = prefs.getString('saved_password') ?? '';
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _saveCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('saved_email', txtEmail.text.trim());
    await prefs.setString('saved_password', txtPassword.text.trim());
  }

  Future<void> _login() async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: txtEmail.text.trim(),
        password: txtPassword.text.trim(),
      );

      if (userCredential.user != null) {
        await _saveCredentials(); // Save the credentials on successful login
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const MainTabView(),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Incorrect email or password')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Container(
              height: media.height,
              width: media.width,
              color: const Color.fromARGB(
                  255, 36, 36, 36), // Set dark background color
              child: SingleChildScrollView(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 25, horizontal: 25),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 64),
                      Text(
                        "Login",
                        style: TextStyle(
                            color: TColor.primaryText,
                            fontSize: 30,
                            fontWeight: FontWeight.w800),
                      ),
                      Text(
                        "Add your details to login",
                        style: TextStyle(
                            color: TColor.secondaryText,
                            fontSize: 14,
                            fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 25),
                      RoundTextfield(
                        hintText: "Your Email",
                        controller: txtEmail,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 25),
                      RoundTextfield(
                        hintText: "Password",
                        controller: txtPassword,
                        obscureText: true,
                      ),
                      const SizedBox(height: 25),
                      RoundButton(
                        title: "Login",
                        onPressed: _login,
                      ),
                      const SizedBox(height: 25),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PasswordResetScreen(),
                            ),
                          );
                        },
                        child: Text(
                          "Forgot your password?",
                          style: TextStyle(
                              color: TColor.secondaryText,
                              fontSize: 14,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                      const SizedBox(height: 5),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SignupScreen(),
                            ),
                          );
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Don't have an Account? ",
                              style: TextStyle(
                                  color: TColor.secondaryText,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500),
                            ),
                            Text(
                              "Sign Up",
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
