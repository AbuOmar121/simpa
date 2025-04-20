import 'package:flutter/material.dart';
import 'package:simpa/starting_screen.dart';

class LoadingScreen extends StatelessWidget {
  LoadingScreen({super.key});

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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 20),
                  Text(
                    'Please wait...',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.pink,
                    ),
                  ),
                ],
              ),
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
