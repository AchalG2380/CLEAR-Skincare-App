import 'package:flutter/material.dart';
import '../screens/widgets/auth_widgets.dart';
import '../screens/login_screen.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 14, 5, 68),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 36),
                    Text(
                      "Clear",
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      "Welcome. You’re just a few taps away from clearer skin.",
                      style: TextStyle(
                        fontSize: 14,
                        color: const Color.fromARGB(255, 199, 199, 199),
                      ),
                    ),
                    SizedBox(height: 12),
                    InfoContainer(
                      title: "Register",
                      lists: [
                        "Name",
                        "Phone Number",
                        "Email",
                        "Password",
                        "Confirm Password",
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Already have an account?",
                    style: TextStyle(
                      color: const Color.fromARGB(255, 199, 199, 199),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      );
                    },
                    child: Text(
                      "Login",
                      style: TextStyle(
                        color: const Color.fromARGB(255, 255, 182, 182),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
