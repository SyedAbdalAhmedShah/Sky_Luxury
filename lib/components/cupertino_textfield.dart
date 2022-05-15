import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sky_luxury/components/strings.dart';

class CustomCupertinoTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? hint;
  final bool isGrey;
  final bool readOnly;
  final TextInputType? keyboardType;
  final double? padding;
  CustomCupertinoTextField({
    this.keyboardType,
    required this.isGrey,
    this.controller,
    this.hint,
    this.padding,
    required this.readOnly,
  });
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return CupertinoTextField(
      readOnly: readOnly,
      controller: controller,
      keyboardType: keyboardType,
      padding: EdgeInsets.all(padding ?? 20),
      placeholder: hint,
      placeholderStyle: TextStyle(color: isGrey ? Colors.grey : Colors.black),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(size.width * 0.02),
          border: Border.all(color: Strings.kSecondaryColor, width: 1.2)),
    );
  }
}
