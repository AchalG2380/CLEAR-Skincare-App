import 'package:flutter/material.dart';
import '../screens/widgets/auth_widgets.dart';
import '../screens/register_screen.dart';
import '../../core/app_colors.dart';
import '../screens/resetPassword.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.backgroundColor,
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
                      "Welcome back. You’re just a few taps away from clearer skin.",
                      style: TextStyle(
                        fontSize: 14,
                        color: const Color.fromARGB(255, 199, 199, 199),
                      ),
                    ),
                    SizedBox(height: 12),
                    Container(
                      margin: const EdgeInsets.all(24),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 50, 14, 95),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color.fromARGB(255, 79, 35, 123),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            "Login",
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 24),
                          ListBuild(title: "Email"),
                          ListBuild(title: "Password"),
                          SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: () {},
                            child: Text(
                              "Login",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Color.fromRGBO(140, 110, 255, 1),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Align(
                      alignment: AlignmentGeometry.topRight,
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const Resetpassword(),
                            ),
                          );
                        },
                        child: Text(
                          "Reset Password",
                          style: TextStyle(
                            color: Color.fromARGB(255, 255, 182, 182),
                          ),
                        ),
                      ),
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
                    "Don't have an account?",
                    style: TextStyle(
                      color: const Color.fromARGB(255, 199, 199, 199),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RegisterScreen(),
                        ),
                      );
                    },
                    child: Text(
                      "Register",
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
