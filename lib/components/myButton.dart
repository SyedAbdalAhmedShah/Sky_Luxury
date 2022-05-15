import 'package:flutter/material.dart';
import 'package:sky_luxury/components/strings.dart';

class MyButton extends StatelessWidget {
  final String buttonText;
  final Function()? onTap;
  final Color? color;
  final Color? borderColor;
  final EdgeInsets? margin;
  const MyButton(
      {required this.buttonText,
      required this.onTap,
      this.color,
      this.margin,
      this.borderColor});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        margin: margin ?? EdgeInsets.symmetric(horizontal: size.width * 0.025),
        height: size.height * 0.08,
        decoration: BoxDecoration(
            border: Border.all(color: borderColor ?? Colors.transparent),
            color: color ?? Strings.kPrimaryColor,
            borderRadius: BorderRadius.circular(size.width * 0.02)),
        child: Text(
          buttonText,
          style: TextStyle(
              color: borderColor ?? Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 16),
        ),
      ),
    );
  }
}
