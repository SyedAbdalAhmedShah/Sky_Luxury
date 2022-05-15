import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sky_luxury/choose_login.dart';
import 'package:sky_luxury/components/strings.dart';
import 'package:sky_luxury/registration/login.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({Key? key}) : super(key: key);

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen>
    with WidgetsBindingObserver {
  late Timer timer;
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print(state);
    timer = new Timer(Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => LoginScreen()),
            ((route) => false));
      }
    });
    super.didChangeAppLifecycleState(state);
  }

  @override
  void initState() {
    WidgetsBinding.instance!.addObserver(this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          // Container(
          //   width: MediaQuery.of(context).size.width * 0.4,
          //   height: MediaQuery.of(context).size.height * 0.4,
          //   margin: EdgeInsets.only(left: 20, top: 20),
          //   child: Align(
          //     alignment: Alignment.topLeft,
          //     child: Image.asset(
          //       "assets/images/logo-v3.png",
          //       fit: BoxFit.contain,
          //     ),
          //   ),
          // ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "We have emailed a link to you. Please verify your email address to complete registration.",
                style: TextStyle(
                    fontSize: 20,
                    fontFamily: "WorkSans",
                    fontWeight: FontWeight.bold,
                    color: Strings.kPrimaryColor),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
