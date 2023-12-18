import 'package:app_ontapkienthuc/ui/forms_account/register_form.dart';
import 'package:flutter/material.dart';
import 'package:app_ontapkienthuc/ui/background/background.dart';

class RegisterAccount extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Background(),
          const RegisterForm(),
        ],
      ),
    );
  }
}
