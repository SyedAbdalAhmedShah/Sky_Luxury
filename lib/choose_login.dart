import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sky_luxury/components/myButton.dart';
import 'package:sky_luxury/components/strings.dart';
import 'package:sky_luxury/registration/login.dart';

import 'admin/registration/admin_login.dart';

class ChooseLoginScreen extends StatelessWidget {
  const ChooseLoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Image(image: AssetImage(Strings.chooseLoginImage)),
          verticalGap(size),
          _buildContinueText(),
          verticalGap(size),
          MyButton(
              buttonText: Strings.loginAsAgent,
              onTap: () => Get.to(() => LoginScreen())),
          verticalGap(size),
          MyButton(
            buttonText: Strings.loginAsAdmin,
            onTap: () => Get.to(() => AdminLoginScreen()),
            color: Colors.white,
            borderColor: Strings.kPrimaryColor,
          ),
          verticalGap(size),
        ],
      ),
    );
  }

  SizedBox verticalGap(Size size) {
    return SizedBox(
      height: size.height * 0.05,
    );
  }

  Text _buildContinueText() {
    return const Text(
      Strings.loginAsAAToCont,
      textAlign: TextAlign.center,
      style: TextStyle(
          color: Colors.black, fontSize: 26, fontWeight: FontWeight.w500),
    );
  }
}
