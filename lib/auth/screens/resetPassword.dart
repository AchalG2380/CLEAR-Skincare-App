import 'package:clear/core/app_colors.dart';
import 'package:flutter/material.dart';
import '../screens/widgets/auth_widgets.dart';
import 'forgotPassword_screen.dart';

class Resetpassword extends StatelessWidget {
  const Resetpassword({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.backgroundColor,
      body: SafeArea(
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
              SizedBox(height: 12),
              InfoContainer(
                title: "Reset Password",
                lists: [
                  "Email",
                  "Old Password",
                  "New Password",
                  "Confirm Password",
                ],
              ),
              Align(
                alignment: AlignmentGeometry.topRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ForgotpasswordScreen(),
                      ),
                    );
                  },
                  child: Text(
                    "Forgot Password ?",
                    style: TextStyle(color: Color.fromARGB(255, 255, 182, 182)),
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
