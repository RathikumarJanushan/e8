// import 'package:e8/view/user/home/home_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:e8/view/user/calculation.dart';
// import 'package:e8/view/user/qr.dart';
// import 'package:e8/common_widget/round_button.dart';

// class ActionsScreen extends StatelessWidget {
//   const ActionsScreen({Key? key}) : super(key: key);

//   Future<String?> getCurrentAvailability() async {
//     try {
//       final user = FirebaseAuth.instance.currentUser;
//       if (user != null) {
//         final userRef =
//             FirebaseFirestore.instance.collection('available').doc(user.uid);
//         final userDoc = await userRef.get();
//         if (userDoc.exists) {
//           return userDoc.data()?['available'];
//         }
//       }
//     } catch (e) {
//       print('Error checking current availability: $e');
//     }
//     return null;
//   }

//   Future<void> checkAvailabilityAndPerformAction(
//       String action, BuildContext context) async {
//     try {
//       final user = FirebaseAuth.instance.currentUser;
//       if (user != null) {
//         final userRef =
//             FirebaseFirestore.instance.collection('available').doc(user.uid);
//         final userDoc = await userRef.get();
//         if (userDoc.exists) {
//           final availability = userDoc.data()?['available'];

//           if (availability == 'break') {
//             ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//               content: Text('Cannot perform action. Availability is on break.'),
//               duration: Duration(seconds: 2),
//             ));
//           } else {
//             await _updateAvailability(action);
//           }
//         }
//       }
//     } catch (e) {
//       print('Error checking availability: $e');
//     }
//   }

//   Future<void> _updateAvailability(String availability) async {
//     try {
//       final user = FirebaseAuth.instance.currentUser;
//       if (user != null) {
//         final userRef =
//             FirebaseFirestore.instance.collection('available').doc(user.uid);
//         final userEmail = user.email;

//         final userDoc = await userRef.get();
//         if (userDoc.exists) {
//           await userRef.update({'available': availability, 'email': userEmail});
//         } else {
//           await userRef.set({'available': availability, 'email': userEmail});
//         }
//       }
//     } catch (e) {
//       print('Error updating availability: $e');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Actions")),
//       body: Padding(
//         padding: const EdgeInsets.all(20.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             RoundButton(
//               title: "Start",
//               onPressed: () async {
//                 final availability = await getCurrentAvailability();
//                 if (availability == 'start') {
//                   ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//                     content: Text('Your availability is already "start".'),
//                     duration: Duration(seconds: 2),
//                   ));
//                 } else {
//                   Navigator.push(context,
//                       MaterialPageRoute(builder: (context) => HomeScreen()));
//                 }
//               },
//             ),
//             SizedBox(height: 10),
//             RoundButton(
//               title: "End",
//               onPressed: () async {
//                 final availability = await getCurrentAvailability();
//                 if (availability == 'end') {
//                   ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//                     content: Text('Your availability is already "end".'),
//                     duration: Duration(seconds: 2),
//                   ));
//                 } else {
//                   await checkAvailabilityAndPerformAction('end', context);
//                   Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                           builder: (context) => FirestoreExample()));
//                 }
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
