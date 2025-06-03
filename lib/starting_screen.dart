import 'package:flutter/material.dart';
import 'package:simpa/screens/authentication/sign_in/sign_in_screen.dart';
import 'package:simpa/screens/authentication/sign_up/screen/sign_up_screen.dart';

class StartingScreen extends StatelessWidget {
  const StartingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(36),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 90),
              Hero(
                tag: 'logo',
                child: Image.asset(
                  'assets/images/Simpa for app@4x.png',
                  // width: 368,
                  height: 250,
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(height: 32),

              // Welcome Text
              Text(
                'Welcome to\nSimpa App',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Urbanist',
                  color: Color.fromARGB(255, 246, 74, 74),
                  fontSize: 36,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'The best application to care for your pet and its health',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Urbanist',
                  color: Color.fromARGB(255, 108, 87, 87),
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 32),
              Text(
                'Periodic appointments, grafts, tips from the best veterinarians!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Manrope',
                  color: Color.fromARGB(255, 108, 87, 87),
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 32),

              // Sign In Button
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SignInScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 246, 74, 74),
                  minimumSize: Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                child: Text(
                  'Sign In',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              SizedBox(height: 16),

              // Create Account Button
              OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SignUpScreen()),
                  );
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: Color.fromARGB(255, 246, 74, 74),
                    width: 2,
                  ),
                  minimumSize: Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                child: Text(
                  'Create Account',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    color: Color.fromARGB(255, 246, 74, 74),
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
