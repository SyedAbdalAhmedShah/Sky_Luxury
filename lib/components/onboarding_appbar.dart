import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Components {
  static PreferredSizeWidget onBoardingAppbar() {
    return AppBar(
      leading: InkWell(
        child: Icon(
          Icons.adaptive.arrow_back,
          color: Colors.black,
        ),
        onTap: () => Get.back(),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
    );
  }
}
