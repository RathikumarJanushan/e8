import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:e8/view/on_boarding/startup_view.dart';
import 'package:e8/view/login/welcome_view.dart';
import 'package:e8/view/user/home/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Check if user is logged in
  bool isLoggedIn = await isUserLoggedIn();

  // Run the Flutter application
  runApp(MyApp(isLoggedIn: isLoggedIn));
}

// Function to check if user is logged in using SharedPreferences
Future<bool> isUserLoggedIn() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool('isLoggedIn') ?? false; // false if not set
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Food Delivery',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: "Metropolis",
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
      initialRoute: '/',
      routes: {
        '/': (context) => isLoggedIn ? DetailsScreen() : const WelcomeView(),
        '/home': (context) => DetailsScreen(),
        '/login': (context) => const WelcomeView(),
      },
    );
  }
}

// To handle user log out, you can call this function
Future<void> logOut(BuildContext context) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('isLoggedIn', false); // Set login state to false

  // Sign out from Firebase Authentication
  await FirebaseAuth.instance.signOut();

  // Navigate to login screen
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => const WelcomeView()),
  );
}

// Example function to log in and set the login state
Future<void> logIn(BuildContext context) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('isLoggedIn', true); // Set login state to true

  // You can call Firebase sign-in logic here if needed
  // For example: await FirebaseAuth.instance.signInWithEmailAndPassword(...);

  // Navigate to home screen
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => DetailsScreen()),
  );
}
