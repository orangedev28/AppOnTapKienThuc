import 'package:flutter/material.dart';
import 'package:app_ontapkienthuc/ui/background/background.dart';
import 'package:app_ontapkienthuc/ui/forms/login_form.dart';

class MyAccount extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Background(),
          const LoginForm(),
        ],
      ),
    );
  }
}
