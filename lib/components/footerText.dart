import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:sky_luxury/components/strings.dart';

class FooterText extends StatelessWidget {
  final String firstText;
  final String secondText;
  final Function()? onTap;
  const FooterText(
      {required this.firstText, required this.secondText, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: RichText(
          text: TextSpan(children: [
        TextSpan(
            text: firstText,
            style: const TextStyle(
                color: Colors.black,
                fontSize: 15,
                fontWeight: FontWeight.w500)),
        TextSpan(
            recognizer: TapGestureRecognizer()..onTap = onTap,
            text: secondText,
            style: const TextStyle(
                color: Strings.kPrimaryColor,
                fontSize: 15,
                fontWeight: FontWeight.w500))
      ])),
    );
  }
}
