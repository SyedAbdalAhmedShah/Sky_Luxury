import 'package:flutter/material.dart';
import 'package:sky_luxury/components/strings.dart';

class HeaderText extends StatelessWidget {
  final String title;
  final String subtitle;
  const HeaderText({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Padding(
      padding: MediaQuery.of(context).viewPadding +
          EdgeInsets.symmetric(horizontal: size.width * 0.05),
      child: RichText(
          text: TextSpan(children: [
        TextSpan(
            text: title,
            style: const TextStyle(
                color: Colors.black,
                fontSize: 22,
                fontWeight: FontWeight.w600)),
        TextSpan(
            text: subtitle,
            style: const TextStyle(
                color: Colors.black, fontSize: 17, fontWeight: FontWeight.w400))
      ])),
    );
  }
}
