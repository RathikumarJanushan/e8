// import 'package:flutter/material.dart';
// import 'package:audioplayers/audioplayers.dart';

// class NotificationPage extends StatefulWidget {
//   @override
//   _NotificationPageState createState() => _NotificationPageState();
// }

// class _NotificationPageState extends State<NotificationPage> {
//   final AudioPlayer _audioPlayer = AudioPlayer();

//   @override
//   void initState() {
//     super.initState();
//     playNotificationSound(); // Automatically play the sound when the page opens.
//   }

//   Future<void> playNotificationSound() async {
//     try {
//       await _audioPlayer.play(AssetSource('sounds/notification.mp3'));
//     } catch (e) {
//       print("Error playing sound: $e");
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Notification Sound Player'),
//       ),
//       body: Center(
//         child: Text(
//           'Playing notification sound...',
//           style: TextStyle(fontSize: 18),
//         ),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _audioPlayer.dispose();
//     super.dispose();
//   }
// }
