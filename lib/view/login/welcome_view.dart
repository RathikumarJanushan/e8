import 'package:flutter/material.dart';

import 'package:e8/auth/login_view.dart';
import 'package:e8/auth/signup_screen.dart';
import 'package:e8/common/color_extension.dart';
import 'package:e8/common_widget/round_button.dart';

class WelcomeView extends StatefulWidget {
  const WelcomeView({super.key});

  @override
  State<WelcomeView> createState() => _WelcomeViewState();
}

class _WelcomeViewState extends State<WelcomeView> {
  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        height: media.height, // Ensure the container takes full screen height
        width: media.width, // Ensure the container takes full screen width
        color: const Color.fromARGB(
            255, 36, 36, 36), // Set a dark background color
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: media.width * 0.5), // Adjust spacing
              Text(
                "QuickRun",
                style: TextStyle(
                  fontSize: media.width * 0.15, // Adjust font size as needed
                  color: Colors.white, // Use white for contrast
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                height: media.width * 0.5,
                child: Image.asset(
                  "assets/img/quickrun.jpeg", // Replace with your logo image path
                  fit: BoxFit.contain, // Adjust the fit as needed
                ),
              ),
              SizedBox(height: media.width * 0.05), // Adjust spacing
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: RoundButton(
                  title: "Login",
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginView(),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: media.width * 0.1), // Adjust spacing
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: RoundButton(
                  title: "Sign up",
                  type: RoundButtonType.textPrimary,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SignupScreen(),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 40),
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
                      "Admin Login ",
                      style: TextStyle(
                        color: TColor.secondaryText,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      "Admin Login",
                      style: TextStyle(
                        color: TColor.primary,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
