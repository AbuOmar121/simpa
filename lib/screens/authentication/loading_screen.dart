import 'package:flutter/material.dart';
import 'package:simpa/splash.dart';
import 'package:simpa/starting_screen.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  Future<void> simulateDelay() async {
    await Future.delayed(Duration(seconds: 3));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: simulateDelay(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Show waiting screen
            return Center(
              child: Splash(),
            );
          } else {
            // Navigate to the sign-in screen after the delay
            return StartingScreen();
          }
        },
      ),
    );
  }
}
