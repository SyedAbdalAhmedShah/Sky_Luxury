import 'package:flutter/material.dart';
import 'package:sky_luxury/components/strings.dart';

class CustomTextField extends StatelessWidget {
  final String hint;
  final TextEditingController controller;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  CustomTextField(
      {required this.hint,
      required this.controller,
      this.validator,
      this.keyboardType,
      required this.obscureText});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: size.width * 0.025, vertical: size.height * 0.02),
      child: TextFormField(
        autovalidateMode: AutovalidateMode.onUserInteraction,
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
            label: Text(
              hint,
              style: TextStyle(color: Strings.kSecondaryColor),
            ),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(
              horizontal: size.width * 0.03,
              vertical: size.height * 0.03,
            ),
            disabledBorder: _border(Strings.kPrimaryColor, size),
            focusedErrorBorder: _border(Theme.of(context).errorColor, size),
            errorBorder: _border(Theme.of(context).errorColor, size),
            focusedBorder: _border(Strings.kPrimaryColor, size),
            enabledBorder: _border(Strings.kSecondaryColor, size)),
      ),
    );
  }

  OutlineInputBorder _border(Color color, Size size) {
    return OutlineInputBorder(
        borderSide: BorderSide(color: color, width: 1.4),
        borderRadius: BorderRadius.circular(size.width * 0.03));
  }
}
