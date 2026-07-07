import 'package:clear/core/app_colors.dart';
import 'package:flutter/material.dart';
import '../screens/widgets/auth_widgets.dart';

class ForgotpasswordScreen extends StatelessWidget {
  const ForgotpasswordScreen({super.key});

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
                title: "Forgot Password",
                lists: ["Phone Number", "OTP", "New Password"],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
